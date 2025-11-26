#!/usr/bin/env node
// ~/.config/waybar/prayer/prayer.js
const { PrayerTimes, Coordinates, CalculationMethod } = require('adhan');

// ===== CONFIG =====
// Put your coordinates here. Cairo example:
const LAT = 30.0444;
const LON = 31.2357;
// Calculation method: choose what you want. Here: Muslim World League.
// Other options: CalculationMethod.Egyptian(), CalculationMethod.UmmAlQura(), etc.
const params = CalculationMethod.Egyptian();

// ==================
const coords = new Coordinates(LAT, LON);
const now = new Date();
const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());

const times = new PrayerTimes(coords, today, params);

// Helper to get JS Date for prayer by name
const prayerMap = {
  Fajr: times.fajr,
  Sunrise: times.sunrise,
  Dhuhr: times.dhuhr,
  Asr: times.asr,
  Maghrib: times.maghrib,
  Isha: times.isha,
};

// Find next prayer (skip Sunrise)
const order = ['Fajr', 'Sunrise', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
let nextName = null;
let nextDate = null;
for (const name of order) {
  const d = prayerMap[name];
  if (!d) continue;
  if (d.getTime() > now.getTime()) {
    nextName = name;
    nextDate = d;
    break;
  }
}

// If none left today -> next is tomorrow's Fajr
if (!nextName) {
  const tomorrow = new Date(today.getTime() + 24 * 60 * 60 * 1000);
  const tTimes = new PrayerTimes(coords, tomorrow, params);
  nextName = 'Fajr';
  nextDate = tTimes.fajr;
}

// Calculate remaining
const diffMs = nextDate.getTime() - now.getTime();
const totalMins = Math.max(0, Math.floor(diffMs / 60000));
const hours = Math.floor(totalMins / 60);
const mins = totalMins % 60;
const formatted = hours > 0 ? `${hours}h ${mins}m` : `${mins}m`;

// Format time helper
const formatTime = date => {
  return date.toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit', hour12: false });
};

// Build tooltip with all prayer times
const tooltip = [
  `Fajr:    ${formatTime(times.fajr)}`,
  `Sunrise: ${formatTime(times.sunrise)}`,
  `Dhuhr:   ${formatTime(times.dhuhr)}`,
  `Asr:     ${formatTime(times.asr)}`,
  `Maghrib: ${formatTime(times.maghrib)}`,
  `Isha:    ${formatTime(times.isha)}`,
].join('\n');

// Output for Waybar (JSON format)
console.log(
  JSON.stringify({
    text: `${nextName} in ${formatted}`,
    tooltip: tooltip,
    class: 'prayer',
    name: nextName,
    time: formatted,
  })
);
