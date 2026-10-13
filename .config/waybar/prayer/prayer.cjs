#!/usr/bin/env node
const fs = require('fs');
const { exec } = require('child_process');
const { PrayerTimes, Coordinates, CalculationMethod } = require('adhan');

const coords = new Coordinates(30.0444, 31.2357);
const now = new Date();
const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
const times = new PrayerTimes(coords, today, CalculationMethod.Egyptian());

const order = ['Fajr', 'Sunrise', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
let next = order.find(n => times[n.toLowerCase()].getTime() > now.getTime());
let nextDate = next ? times[next.toLowerCase()] : null;

if (!next) {
  const tmrw = new PrayerTimes(coords, new Date(today.getTime() + 864e5), CalculationMethod.Egyptian());
  next = 'Fajr';
  nextDate = tmrw.fajr;
}

const mins = Math.max(0, Math.floor((nextDate - now) / 6e4));
const fmt = `${Math.floor(mins / 60)}:${String(mins % 60).padStart(2, '0')}`;
const fmtTime = d => d.toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit', hour12: false });

const n = now.getTime();

// Alert state lives in RAM (tmpfs), so polling every minute never touches the disk
const stateFile = '/dev/shm/waybar-prayer-notification-state.json';
let state = {};
try {
  state = JSON.parse(fs.readFileSync(stateFile, 'utf8')) || {};
} catch (err) {}

const quote = s => `'${s.replace(/'/g, "'\"'\"'")}'`;
const notify = (urgency, sound, title, message) => {
  exec(`notify-send -a Prayer -u ${urgency} ${quote(title)} ${quote(message)}`);
  exec(`paplay /usr/share/sounds/freedesktop/stereo/${sound}.oga >/dev/null 2>&1`);
};

// Fire each alert once, keyed by prayer + its date/time
const alertOnce = (kind, prayer, date, send) => {
  const id = `${prayer}-${date.toISOString().slice(0, 16)}`;
  if (state[kind] === id) return;
  state[kind] = id;
  try {
    fs.writeFileSync(stateFile, JSON.stringify(state));
  } catch (err) {}
  send();
};

// 15 minutes before: critical
if (mins === 15) {
  alertOnce('warn', next, nextDate, () =>
    notify('critical', 'complete', `15 minutes until ${next}`, `${next} prayer starts at ${fmtTime(nextDate)}`)
  );
}

// At prayer time (within the first 2 minutes, to survive a skipped poll): normal priority
const started = order.find(p => p !== 'Sunrise' && n - times[p.toLowerCase()].getTime() >= 0 && n - times[p.toLowerCase()].getTime() < 12e4);
if (started) {
  const date = times[started.toLowerCase()];
  alertOnce('now', started, date, () =>
    notify('normal', 'message', `It's time for ${started}`, `${started} prayer started at ${fmtTime(date)}`)
  );
}

console.log(
  JSON.stringify({
    text: `${next} in ${fmt}`,
    tooltip: order.map(p => `${p}: ${fmtTime(times[p.toLowerCase()])}`).join('\n'),
    class: `prayer${mins === 15 ? ' urgent' : ''}`,
    urgent: mins === 15,
  })
);
