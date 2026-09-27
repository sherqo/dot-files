#!/usr/bin/env bash
#
# task-timer.sh — Waybar task-timer module (tofi prompts + notify-send alarm).
#
# Poll-driven: waybar re-runs this script (every 1s for display, plus once per
# click/scroll with an argument). There is NO persistent process, so all state
# lives in the scratch file below.
#
# === STATE FILE (scratch cache — read this first) ===
# Path: ~/.cache/waybar-task-timer.json
# A SINGLE small JSON object, OVERWRITTEN IN PLACE on every change
# (write-temp-then-rename, never append, never grows). NOT a log: no history,
# no CSV, one entry only. Schema:
#   {"task": "<name>", "status": "idle|running|paused",
#    "end": <epoch seconds, when running, else 0>,
#    "remaining": <frozen seconds left, when paused, else 0>,
#    "total_minutes": <session length in minutes>}
#
# Usage (wired from waybar config):
#   task-timer.sh          display poll, prints {"text":..,"tooltip":..,"class":..}
#   task-timer.sh click    left-click:  idle->start | running->pause | paused->resume
#   task-timer.sh right    right-click: running/paused->cancel (idle: no-op)
#   task-timer.sh up       scroll up:   +1 minute (idle: no-op)
#   task-timer.sh down     scroll down: -1 minute, floor at 1 min left (idle: no-op)
#
# Deps: tofi, notify-send, jq, coreutils (date/printf/mv).

set -u

# --- scratch state file (single JSON object, overwritten every change) ---
STATE_FILE="${HOME}/.cache/waybar-task-timer.json"
LOCK_FILE="${STATE_FILE}.lock"   # serialises the expiry prompt only

# --- fast epoch seconds, no fork (same trick as timer.sh) ---
now_s() {
    printf -v NOW '%(%s)T' -1 || NOW=$(date +%s)
    printf '%s' "$NOW"
}

# --- state: load into TASK/STATUS/END_TS/REMAINING/TOTAL (defaults: idle) ---
load_state() {
    TASK=""; STATUS="idle"; END_TS=0; REMAINING=0; TOTAL=0
    if [ -f "$STATE_FILE" ]; then
        local s
        s=$(jq -r '[.task // "", .status // "idle", (.end // 0), (.remaining // 0), (.total_minutes // 0)] | @tsv' "$STATE_FILE" 2>/dev/null) || s=""
        if [ -n "$s" ]; then
            IFS=$'\t' read -r TASK STATUS END_TS REMAINING TOTAL <<< "$s"
        fi
    fi
    case "$STATUS" in idle|running|paused) ;; *) STATUS="idle" ;; esac
    [[ "$END_TS" =~ ^[0-9]+$ ]]   || END_TS=0
    [[ "$REMAINING" =~ ^[0-9]+$ ]] || REMAINING=0
    [[ "$TOTAL" =~ ^[0-9]+$ ]]     || TOTAL=0
}

# --- state: overwrite the single JSON object atomically (tmp + rename) ---
save_state() { # args: task status end remaining total_minutes
    local tmp="${STATE_FILE}.tmp.$$"
    jq -n --arg task "$1" --arg status "$2" \
        --argjson end "$3" --argjson remaining "$4" --argjson total "$5" \
        '{task: $task, status: $status, end: $end, remaining: $remaining, total_minutes: $total}' > "$tmp" 2>/dev/null \
        && mv -f "$tmp" "$STATE_FILE"
    rm -f "$tmp"
}

save_idle() { save_state "" "idle" 0 0 0; }

# --- MM:SS (MM may exceed 59, e.g. 90:00) ---
fmt_mmss() {
    local s=$1
    [ "$s" -lt 0 ] && s=0
    printf '%02d:%02d' $(( s / 60 )) $(( s % 60 ))
}

# --- free-text tofi prompt; prints answer, rc!=0 or empty means aborted ---
tofi_ask() { # $1 = prompt text
    printf '' | tofi --prompt-text "$1 " --require-match=false 2>/dev/null
}

# --- emit waybar JSON (jq handles escaping of task names) ---
emit() { # $1=text $2=tooltip $3=class
    jq -n -c --arg text "$1" --arg tip "$2" --arg cls "$3" \
        '{text: $text, tooltip: $tip, class: $cls}'
}

# --- expiry: notify + Done/Extend. Runs inside display poll when now >= end.
# Serialised with a lock so overlapping 1s polls can't double-prompt. ---
handle_expiry() {
    exec 9>"$LOCK_FILE" 2>/dev/null || { save_idle; return; }
    flock -n 9 2>/dev/null || {
        # another instance is already prompting; just show zeroed text
        emit "${TASK} — 00:00" "Timer expired…" "running"
        return
    }

    # Alarm (fire-and-forget) + tofi picker. Notification-daemon action
    # buttons are unreliable (mako swallows the clicks, so -A actions never
    # resolve), so the Done/Extend choice lives in tofi, which always works.
    notify-send -u critical -t 10000 \
        "Time's up: ${TASK}" "Done or need more time?" 2>/dev/null &
    local action=""
    action=$(printf 'Extend\nDone\n' | tofi --prompt-text "Time's up: ${TASK} — " 2>/dev/null)

    if [ "$action" = "Extend" ]; then
        local extra now2
        extra=$(tofi_ask "How many extra minutes?")
        if [[ "$extra" =~ ^[0-9]+$ ]] && [ "$extra" -ge 1 ]; then
            now2=$(now_s)
            save_state "$TASK" "running" $(( now2 + extra * 60 )) 0 $(( TOTAL + extra ))
            load_state
            emit "${TASK} — $(fmt_mmss $(( END_TS - now2 )))" \
                "${TASK} — extended" "running"
            return
        fi
        # empty/invalid answer (or dismissed fallback notify) = done
    fi
    save_idle
    emit "No Task" "No task — left click: start a task" "idle"
}

# --- left-click while idle: two tofi prompts, then running ---
start_task() {
    local name mins now0
    name=$(tofi_ask "What are you doing?")
    [ -n "$name" ] || return 0                        # Esc/empty = abort
    mins=$(tofi_ask "How many minutes?")
    [[ "$mins" =~ ^[0-9]+$ ]] && [ "$mins" -ge 1 ] || return 0
    now0=$(now_s)
    save_state "$name" "running" $(( now0 + mins * 60 )) 0 "$mins"
}

# --- controller (action invocations from waybar) ---
if [ -n "${1:-}" ]; then
    load_state
    NOW=$(now_s)
    case "$1" in
        click)
            case "$STATUS" in
                idle) start_task ;;
                running)
                    REM=$(( END_TS - NOW ))
                    [ "$REM" -lt 0 ] && REM=0
                    save_state "$TASK" "paused" 0 "$REM" "$TOTAL"
                    ;;
                paused)
                    save_state "$TASK" "running" $(( NOW + REMAINING )) 0 "$TOTAL"
                    ;;
            esac
            ;;
        right)
            # cancel: running/paused -> idle; idle -> no-op
            case "$STATUS" in
                running|paused) save_idle ;;
            esac
            ;;
        up)
            case "$STATUS" in
                running)
                    save_state "$TASK" "running" $(( END_TS + 60 )) 0 $(( TOTAL + 1 ))
                    ;;
                paused)
                    save_state "$TASK" "paused" 0 $(( REMAINING + 60 )) $(( TOTAL + 1 ))
                    ;;
            esac
            ;;
        down)
            case "$STATUS" in
                running)
                    NEW_END=$(( END_TS - 60 ))
                    MIN_END=$(( NOW + 60 ))          # floor: 1 minute remaining
                    [ "$NEW_END" -lt "$MIN_END" ] && NEW_END=$MIN_END
                    NEW_TOTAL=$(( TOTAL - 1 ))
                    [ "$NEW_TOTAL" -lt 1 ] && NEW_TOTAL=1
                    save_state "$TASK" "running" "$NEW_END" 0 "$NEW_TOTAL"
                    ;;
                paused)
                    NEW_REM=$(( REMAINING - 60 ))
                    [ "$NEW_REM" -lt 60 ] && NEW_REM=60   # floor: 1 minute
                    NEW_TOTAL=$(( TOTAL - 1 ))
                    [ "$NEW_TOTAL" -lt 1 ] && NEW_TOTAL=1
                    save_state "$TASK" "paused" 0 "$NEW_REM" "$NEW_TOTAL"
                    ;;
            esac
            ;;
    esac
    exit 0
fi

# --- display poll (waybar exec, interval 1) ---
load_state
NOW=$(now_s)

case "$STATUS" in
    idle)
        emit "No Task" "No task — left click: start a task" "idle"
        ;;
    paused)
        LEFT="$REMAINING"
        emit "⏸ ${TASK} — $(fmt_mmss "$LEFT") left" \
            "${TASK} — paused, $(fmt_mmss "$LEFT") left (${TOTAL} min total) — left click: resume — right click: cancel — scroll: ±1 min" \
            "paused"
        ;;
    running)
        LEFT=$(( END_TS - NOW ))
        if [ "$LEFT" -le 0 ]; then
            handle_expiry
        else
            emit "${TASK} — $(fmt_mmss "$LEFT")" \
                "${TASK} — $(fmt_mmss "$LEFT") left (${TOTAL} min total) — left click: pause — right click: cancel — scroll: ±1 min" \
                "running"
        fi
        ;;
esac
