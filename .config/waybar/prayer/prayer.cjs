#!/usr/bin/env node
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
const fmt = mins >= 60 ? `${Math.floor(mins / 60)}h ${mins % 60}m` : `${mins}m`;
const fmtTime = d => d.toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit', hour12: false });

const f = times.fajr.getTime(),
  m = times.maghrib.getTime(),
  n = now.getTime();
const isAwake = n >= f && n < m;
const status = isAwake ? `${Math.round(((n - f) / (m - f)) * 100)}%` : 'sleep';

const stateFile = '/tmp/waybar-prayer-notification-state.json';
let lastAlert = null;
try {
  const raw = fs.readFileSync(stateFile, 'utf8');
  lastAlert = JSON.parse(raw).alert || null;
} catch (err) {
  lastAlert = null;
}

const quote = s => `'${s.replace(/'/g, "'\"'\"'")}'`;
const notify = (title, message) => {
  exec(`notify-send -u critical ${quote(title)} ${quote(message)}`);
  exec('paplay /usr/share/sounds/freedesktop/stereo/complete.oga >/dev/null 2>&1');
};

if (mins === 15 && nextDate) {
  const alertId = `${next}-${nextDate.toISOString().slice(0, 16)}`;
  if (alertId !== lastAlert) {
    try {
      fs.writeFileSync(stateFile, JSON.stringify({ alert: alertId }));
    } catch (err) {}
    notify(`15 minutes until ${next}`, `${next} prayer starts at ${fmtTime(nextDate)}`);
  }
}

console.log(
  JSON.stringify({
    text: `${status} | ${next} in ${fmt}`,
    tooltip: order.map(p => `${p}: ${fmtTime(times[p.toLowerCase()])}`).join('\n'),
    class: `prayer${mins === 15 ? ' urgent' : ''}`,
    isAwake,
    urgent: mins === 15,
  })
);
