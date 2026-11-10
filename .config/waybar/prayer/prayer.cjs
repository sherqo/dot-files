#!/usr/bin/env node
const fs = require('fs');
const { exec } = require('child_process');
const { PrayerTimes, Coordinates, CalculationMethod } = require('adhan');

const coords = new Coordinates(30.138411, 31.373985);
const now = new Date();
const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
const tomorrowDay = new Date(today.getTime() + 864e5);

const order = ['Fajr', 'Sunrise', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
const prayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

// Iqama is 15 minutes after the adhan, except Maghrib (5 minutes)
const iqamaDelay = { Fajr: 15, Dhuhr: 15, Asr: 15, Maghrib: 5, Isha: 15 };

const timesFor = day => new PrayerTimes(coords, day, CalculationMethod.Egyptian());
const times = timesFor(today);
const tmrw = timesFor(tomorrowDay);

const iqamaOf = (prayer, adhan) => new Date(adhan.getTime() + iqamaDelay[prayer] * 6e4);

// Adhan events (today + tomorrow) drive the pre-prayer warning
const adhans = [];
for (const pt of [times, tmrw]) {
  for (const p of order) adhans.push({ prayer: p, time: pt[p.toLowerCase()] });
}
const nextAdhan = adhans.find(e => e.time.getTime() > now.getTime());

// Iqama events (today + tomorrow) drive the bar text, so the countdown never runs dry
const iqamas = [];
for (const pt of [times, tmrw]) {
  for (const p of prayers) {
    const adhan = pt[p.toLowerCase()];
    iqamas.push({ prayer: p, adhan, iqama: iqamaOf(p, adhan) });
  }
}
const nextIqama = iqamas.find(e => e.iqama.getTime() > now.getTime());

const n = now.getTime();

// Between an adhan and its iqama the bar counts down to the iqama ("Iqama in 0:14"),
// otherwise it keeps counting down to the next prayer ("Asr in 3:31")
const waiting = iqamas.find(e => e.adhan.getTime() <= n && n < e.iqama.getTime());
const target = waiting ? waiting.iqama : nextAdhan.time;
const label = waiting ? 'Iqama' : nextAdhan.prayer;

const mins = Math.max(0, Math.floor((target - now) / 6e4));
const fmt = `${Math.floor(mins / 60)}:${String(mins % 60).padStart(2, '0')}`;
const iqamaMins = Math.max(0, Math.floor((nextIqama.iqama - now) / 6e4));
const iqamaFmt = `${Math.floor(iqamaMins / 60)}:${String(iqamaMins % 60).padStart(2, '0')}`;
const fmtTime = d => d.toLocaleTimeString('en-GB', { hour: '2-digit', minute: '2-digit', hour12: false });

// The bar warns while the adhan is inside its last quarter hour
const adhanMins = nextAdhan ? (nextAdhan.time.getTime() - n) / 6e4 : Infinity;
const urgent = adhanMins > 0 && adhanMins <= 15;

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

// Inside the last 15 minutes before the adhan: critical
if (nextAdhan && urgent) {
  const { prayer, time } = nextAdhan;
  alertOnce('warn', prayer, time, () =>
    notify('critical', 'complete', `15 minutes until ${prayer}`, `${prayer} starts at ${fmtTime(time)}`)
  );
}

// At the adhan (within the first 2 minutes, to survive a skipped poll): normal priority
const started = adhans.find(e => e.prayer !== 'Sunrise' && n - e.time.getTime() >= 0 && n - e.time.getTime() < 12e4);
if (started) {
  alertOnce('now', started.prayer, started.time, () =>
    notify('normal', 'message', `It's time for ${started.prayer}`, `${started.prayer} started at ${fmtTime(started.time)}`)
  );
}

// At the iqama (same 2 minute window): medium priority
const iqamaNow = iqamas.find(e => n - e.iqama.getTime() >= 0 && n - e.iqama.getTime() < 12e4);
if (iqamaNow) {
  alertOnce('iqama', iqamaNow.prayer, iqamaNow.iqama, () =>
    notify('normal', 'message', `Iqama for ${iqamaNow.prayer}`, `${iqamaNow.prayer} iqama at ${fmtTime(iqamaNow.iqama)}`)
  );
}

const tooltip = [
  ...prayers.map(p => {
    const adhan = times[p.toLowerCase()];
    return `${p}: ${fmtTime(adhan)}  ·  iqama ${fmtTime(iqamaOf(p, adhan))}`;
  }),
  `Sunrise: ${fmtTime(times.sunrise)}`,
  `Iqama for ${nextIqama.prayer} at ${fmtTime(nextIqama.iqama)} (in ${iqamaFmt})`,
].join('\n');

console.log(
  JSON.stringify({
    text: `${label} in ${fmt}`,
    tooltip,
    class: `prayer${urgent ? ' urgent' : ''}`,
    urgent,
  })
);
