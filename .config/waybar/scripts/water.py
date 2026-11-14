#!/usr/bin/env python3
"""
Waybar Water Tracker Module
- Keeps all state in RAM (/dev/shm) so nothing is written to disk or preserved after reboot.
- Daily session starts at 5:00 AM (rolls over every morning at 05:00).
- Multi-stage status icons:
    * < 40 mins: Hydrated (󰖌) - White (foreground)
    * 40 - 60 mins: Refill Reminder (󰸊) - Warning color
    * > 60 mins: Thirsty Alert (󱔈) - Critical color + Desktop Notification
- Rich hover tooltip with daily hydration statistics (sips, progress, last sip).
- Left-click: Log a sip (+1 sip, reset timer)
- Right-click: Undo last sip (-1 sip)
- Middle-click: Reset tracker
"""

import sys
import os
import json
import time
import datetime
import subprocess

STATE_FILE = "/dev/shm/waybar_water.json"
REMIND_SECS = 40 * 60  # 40 minutes
URGENT_SECS = 60 * 60  # 60 minutes
DAILY_GOAL = 10        # Target sips for the day
WAYBAR_SIGNAL = 8      # RTMIN+8
SESSION_START_HOUR = 5 # Day cycle starts at 5:00 AM

def get_session_start(now_ts=None):
    if now_ts is None:
        now_dt = datetime.datetime.now()
    else:
        now_dt = datetime.datetime.fromtimestamp(now_ts)
    
    # If before 5:00 AM, today's cycle started yesterday at 5:00 AM
    if now_dt.hour < SESSION_START_HOUR:
        day = now_dt.date() - datetime.timedelta(days=1)
    else:
        day = now_dt.date()
    
    start_dt = datetime.datetime.combine(day, datetime.time(SESSION_START_HOUR, 0, 0))
    return int(start_dt.timestamp())

def load_state():
    now = int(time.time())
    current_session = get_session_start(now)
    default_state = {
        "count": 0,
        "last_drink": now,
        "session_start": current_session,
        "history": [],
        "last_notified": 0
    }
    if os.path.exists(STATE_FILE):
        try:
            with open(STATE_FILE, "r", encoding="utf-8") as f:
                data = json.load(f)
                raw_history = list(data.get("history", []))
                # Only keep sips that occurred after the current 5:00 AM start
                today_history = [t for t in raw_history if t >= current_session]
                stored_session = int(data.get("session_start", 0))

                # New day rollover with no sips logged yet today
                if stored_session < current_session and not today_history:
                    return default_state

                count = len(today_history) if today_history else int(data.get("count", 0))
                last_drink = int(data.get("last_drink", now))
                if last_drink < current_session:
                    last_drink = now

                return {
                    "count": count,
                    "last_drink": last_drink,
                    "session_start": current_session,
                    "history": today_history,
                    "last_notified": int(data.get("last_notified", 0))
                }
        except Exception:
            return default_state
    return default_state

def save_state(state):
    tmp_file = f"{STATE_FILE}.tmp"
    try:
        with open(tmp_file, "w", encoding="utf-8") as f:
            json.dump(state, f)
        os.replace(tmp_file, STATE_FILE)
    except Exception:
        pass

def signal_waybar():
    os.system(f"pkill -RTMIN+{WAYBAR_SIGNAL} waybar >/dev/null 2>&1")

def format_time_ago(secs):
    if secs < 60:
        return "just now"
    mins = secs // 60
    if mins < 60:
        return f"{mins}m ago"
    hours = mins // 60
    rem_m = mins % 60
    return f"{hours}h {rem_m}m ago"

def render():
    state = load_state()
    now = int(time.time())
    elapsed = max(0, now - state["last_drink"])
    count = state["count"]
    history = state["history"]

    # Determine status stage
    if elapsed >= URGENT_SECS:
        stage = "critical"
        icon = "󱔈"  # Water alert
        status_text = "Thirsty! (>1h elapsed)"
        next_rem_text = "Overdue"

        # Send notification if not notified yet during this overdue period
        last_notified = state.get("last_notified", 0)
        if now - last_notified >= URGENT_SECS:
            try:
                subprocess.run(
                    [
                        "notify-send",
                        "-u", "normal",
                        "-a", "Water Tracker",
                        "󱔈 Time to drink water!",
                        "It has been over 1 hour since your last sip."
                    ],
                    check=False
                )
            except Exception:
                pass
            state["last_notified"] = now
            save_state(state)

    elif elapsed >= REMIND_SECS:
        stage = "warning"
        icon = "󰸊"  # Outline reminder
        status_text = "Due for water"
        overdue_by = (elapsed - REMIND_SECS) // 60
        next_rem_text = f"Due now (+{overdue_by}m)"
    else:
        stage = "hydrated"
        icon = "󰖌"  # Hydrated water icon
        status_text = "Hydrated"
        rem_m = (REMIND_SECS - elapsed) // 60
        next_rem_text = f"in {max(1, rem_m)}m"

    # Last drink/sip formatted
    if count == 0 and not history:
        last_str = "None yet (click to log first sip)"
    else:
        last_clock = time.strftime("%H:%M", time.localtime(state["last_drink"]))
        last_str = f"{last_clock} ({format_time_ago(elapsed)})"

    # Progress bar
    bar_len = 10
    pct = int((count / DAILY_GOAL) * 100) if DAILY_GOAL > 0 else 0
    filled = min(bar_len, int(bar_len * min(1.0, count / DAILY_GOAL)))
    bar = "█" * filled + "░" * (bar_len - filled)

    # Average interval calculation
    if count == 0:
        avg_str = "None yet"
    elif len(history) >= 2:
        intervals = [history[i] - history[i-1] for i in range(1, len(history))]
        avg_mins = max(1, (sum(intervals) // len(intervals)) // 60)
        avg_str = f"{avg_mins}m"
    else:
        # 1 sip: time elapsed since that sip was taken
        sip_mins = max(1, (now - state["last_drink"]) // 60)
        avg_str = f"~{sip_mins}m"

    start_clock = time.strftime("%H:%M", time.localtime(state["session_start"]))

    tooltip_lines = [
        "󰖌 Hydration Tracker",
        "──────────────────────────────",
        f"Status:        {icon} {status_text}",
        f"Last sip:      {last_str}",
        f"Next reminder: {next_rem_text}",
        "",
        "󰄨 Today's Stats",
        f"Sips today:    {count}",
        f"Daily goal:    {count}/{DAILY_GOAL} [{bar}] {pct}%",
        f"Avg interval:  {avg_str}",
        f"Session:       Started at {start_clock}",
    ]
    tooltip = "\n".join(tooltip_lines)

    output = {
        "text": icon,
        "tooltip": tooltip,
        "class": stage
    }
    print(json.dumps(output, ensure_ascii=False))

def cmd_drink():
    state = load_state()
    now = int(time.time())
    state["count"] += 1
    state["last_drink"] = now
    state["last_notified"] = 0
    state["history"].append(now)
    save_state(state)
    signal_waybar()

def cmd_undo():
    state = load_state()
    if state["history"]:
        state["history"].pop()
        state["count"] = max(0, state["count"] - 1)
        if state["history"]:
            state["last_drink"] = state["history"][-1]
        else:
            state["last_drink"] = int(time.time())
        state["last_notified"] = 0
        save_state(state)
        signal_waybar()

def cmd_reset():
    now = int(time.time())
    state = {
        "count": 0,
        "last_drink": now,
        "session_start": get_session_start(now),
        "history": [],
        "last_notified": 0
    }
    save_state(state)
    signal_waybar()

if __name__ == "__main__":
    if len(sys.argv) > 1:
        arg = sys.argv[1].lower()
        if arg == "drink":
            cmd_drink()
        elif arg == "undo":
            cmd_undo()
        elif arg == "reset":
            cmd_reset()
        else:
            render()
    else:
        render()
