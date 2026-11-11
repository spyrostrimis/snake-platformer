// Draws all of v5's art as SVG and renders it to PNG with sharp.
// Run: node art_src/make_art.js <sharp module dir> <output dir>
// Everything here is original art made for SNAGMAN (formerly Snake Hangman: Jungle Jam).
const path = require("path");
const fs = require("fs");
const sharp = require(process.argv[2] || "sharp");
const OUT = process.argv[3] || path.join(__dirname, "png");
fs.mkdirSync(OUT, { recursive: true });

const svg = (w, h, body, defs = "") =>
  `<svg xmlns="http://www.w3.org/2000/svg" width="${w}" height="${h}" viewBox="0 0 ${w} ${h}"><defs>${defs}</defs>${body}</svg>`;
const jobs = [];
const save = (name, w, h, body, defs) =>
  jobs.push(sharp(Buffer.from(svg(w, h, body, defs))).png().toFile(path.join(OUT, name + ".png")));

// ---------- Colours ----------
const C = {
  grass: "#55c42a", grassLight: "#9be84a", grassDark: "#2c8a16", grassLine: "#185a0c",
  dirt: "#6e3f1c", stone: "#b9773f", stoneLight: "#e0a86a", stoneDark: "#7a4720", mortar: "#4a2a10",
  snake: "#5cc433", snakeDark: "#1f6b12", snakeSpot: "#3f9a22", belly: "#e2f27a",
};

// ---------- Tiles (32 x 32; tile 0 is empty) ----------
function stones(seed) {
  // A cobble pattern that stays inside the tile, so tiles join cleanly.
  const sets = [
    [[8, 9, 7, 6], [23, 8, 7, 6], [7, 23, 6, 7], [21, 22, 9, 7], [16, 15, 4, 3]],
    [[9, 7, 8, 5], [24, 12, 6, 7], [10, 21, 8, 7], [24, 26, 6, 4], [3, 14, 3, 4]],
  ];
  return sets[seed % 2].map(([x, y, rx, ry]) =>
    `<ellipse cx="${x}" cy="${y}" rx="${rx}" ry="${ry}" fill="url(#st)" stroke="${C.mortar}" stroke-width="1.5"/>` +
    `<ellipse cx="${x - rx * 0.3}" cy="${y - ry * 0.35}" rx="${rx * 0.4}" ry="${ry * 0.3}" fill="${C.stoneLight}" opacity="0.7"/>`
  ).join("");
}
const stoneGrad = `<linearGradient id="st" x1="0" y1="0" x2="0.6" y2="1"><stop offset="0" stop-color="${C.stoneLight}"/><stop offset="0.5" stop-color="${C.stone}"/><stop offset="1" stop-color="${C.stoneDark}"/></linearGradient>
<linearGradient id="gr" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="${C.grassLight}"/><stop offset="0.6" stop-color="${C.grass}"/><stop offset="1" stop-color="${C.grassDark}"/></linearGradient>
<linearGradient id="log" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#d89a52"/><stop offset="1" stop-color="#7a4416"/></linearGradient>
<linearGradient id="rock" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#c6c3d8"/><stop offset="1" stop-color="#6c6886"/></linearGradient>`;
const dirt = (seed) => `<rect width="32" height="32" fill="${C.dirt}"/>${stones(seed)}`;
const grassTop = (left, right) => {
  // A grass band with blades hanging over, and rounded ends where the ground stops.
  let blades = "";
  for (let x = 1; x < 32; x += 4) blades += `<path d="M${x} 9 L${x + 2} ${13 + ((x * 7) % 4)} L${x + 4} 9 Z" fill="${C.grass}" stroke="${C.grassLine}" stroke-width="0.8"/>`;
  const l = left ? `<circle cx="2" cy="7" r="6" fill="url(#gr)" stroke="${C.grassLine}" stroke-width="1.2"/>` : "";
  const r = right ? `<circle cx="30" cy="7" r="6" fill="url(#gr)" stroke="${C.grassLine}" stroke-width="1.2"/>` : "";
  return `<rect x="${left ? 2 : 0}" y="1" width="${32 - (left ? 2 : 0) - (right ? 2 : 0)}" height="10" fill="url(#gr)"/>
    <line x1="${left ? 2 : 0}" y1="1" x2="${right ? 30 : 32}" y2="1" stroke="${C.grassLine}" stroke-width="1.5"/>${blades}${l}${r}
    <path d="M4 4 q3 -2 6 0 M16 3 q3 -2 6 0" stroke="#d6ff9a" stroke-width="1.2" fill="none" opacity="0.8"/>`;
};
const tiles = [
  "",                                                   // 0 empty
  dirt(0) + grassTop(false, false),                     // 1 grass
  dirt(0),                                              // 2 dirt A
  dirt(1),                                              // 3 dirt B
  dirt(1) + grassTop(true, false),                      // 4 grass, left end
  dirt(0) + grassTop(false, true),                      // 5 grass, right end
  dirt(1) + `<rect x="0" y="22" width="32" height="10" fill="#3a1e08" opacity="0.55"/>
    <path d="M6 32 q2 -6 0 -10 M18 32 q-2 -5 1 -9 M27 32 q1 -4 -1 -8" stroke="#2a1404" stroke-width="2" fill="none"/>`, // 6 dirt underside
  `<rect x="0" y="2" width="32" height="11" rx="5" fill="url(#log)" stroke="#4a2608" stroke-width="1.5"/>
    <circle cx="5" cy="7.5" r="3" fill="none" stroke="#5a3010" stroke-width="1"/><line x1="11" y1="5" x2="28" y2="5" stroke="#f0c07a" stroke-width="1.2"/>
    <line x1="10" y1="10" x2="24" y2="10" stroke="#5a3010" stroke-width="1"/>`, // 7 log platform (one-way)
  `<rect x="1" y="1" width="30" height="30" rx="4" fill="url(#rock)" stroke="#3c3850" stroke-width="2"/>
    <path d="M8 3 L13 12 L9 18 L15 29 M24 4 L20 13 L26 19" stroke="#3c3850" stroke-width="1.6" fill="none"/>
    <path d="M5 6 L10 5" stroke="#ffffff" stroke-width="1.5" opacity="0.7"/>`, // 8 cracked block (breakable)
  `<path d="M0 32 L4 16 L8 32 L12 16 L16 32 L20 16 L24 32 L28 16 L32 32 Z" fill="url(#rock)" stroke="#33304a" stroke-width="1.5"/>
    <path d="M3 22 L4 17 M11 22 L12 17 M19 22 L20 17 M27 22 L28 17" stroke="#fff" stroke-width="1" opacity="0.8"/>`, // 9 spikes
  dirt(0) + grassTop(true, true),                       // 10 grass, single column
];
// Each tile is clipped to its own 32 x 32 square so rounded grass ends cannot spill into a neighbour.
save("spr_tiles", 32 * tiles.length, 32,
  tiles.map((t, i) => `<g transform="translate(${i * 32},0)" clip-path="url(#cell)">${t}</g>`).join(""),
  stoneGrad + `<clipPath id="cell"><rect x="0" y="0" width="32" height="32"/></clipPath>`);

// ---------- Parallax backgrounds (seamless left to right) ----------
function ridge(w, h, base, amps, periods, phase = 0) {
  // A wavy ridge whose waves all repeat exactly across the width, so the image tiles.
  let d = `M0 ${h} `;
  for (let x = 0; x <= w; x += 8) {
    let y = base;
    amps.forEach((a, i) => (y -= a * Math.sin((x / w) * Math.PI * 2 * periods[i] + phase * (i + 1))));
    d += `L${x} ${y.toFixed(1)} `;
  }
  return d + `L${w} ${h} Z`;
}
save("spr_bg_mountains", 1024, 260,
  `<path d="${ridge(1024, 260, 150, [40, 22, 9], [3, 7, 17], 0.5)}" fill="#3d3a9e"/>
   <path d="${ridge(1024, 260, 175, [26, 14, 6], [4, 9, 23], 1.7)}" fill="#2c2a7e"/>
   <path d="${ridge(1024, 260, 150, [40, 22, 9], [3, 7, 17], 0.5)}" fill="none" stroke="#7b78e0" stroke-width="3" opacity="0.6"/>`);
let trees = "";
for (let i = 0; i < 16; i++) {
  const x = i * 64 + 20 + ((i * 37) % 30);
  const y = 120 - ((i * 53) % 30);
  trees += `<rect x="${x - 3}" y="${y}" width="6" height="${200 - y}" fill="#2d5a20"/>
    <circle cx="${x}" cy="${y}" r="${22 + (i % 3) * 5}" fill="#3f8a2a"/><circle cx="${x - 8}" cy="${y - 6}" r="12" fill="#5aae38"/>`;
}
save("spr_bg_hills", 1024, 200, trees +
  `<path d="${ridge(1024, 200, 140, [22, 10], [2, 5], 0.3)}" fill="#2f7a26"/>
   <path d="${ridge(1024, 200, 160, [16, 8], [3, 8], 2.1)}" fill="#246a1c"/>`);
let clouds = "";
for (let i = 0; i < 6; i++) {
  const x = i * 170 + 60;
  const y = 40 + ((i * 29) % 50);
  clouds += `<g opacity="0.85"><ellipse cx="${x}" cy="${y}" rx="46" ry="16" fill="#ffffff"/><circle cx="${x - 18}" cy="${y - 10}" r="16" fill="#ffffff"/>
    <circle cx="${x + 12}" cy="${y - 14}" r="20" fill="#ffffff"/><ellipse cx="${x}" cy="${y + 6}" rx="44" ry="8" fill="#c8dcff"/></g>`;
}
save("spr_bg_clouds", 1024, 130, clouds);

// ---------- The snake (facing right) ----------
function head(frame) {
  const eye = frame === 1
    ? `<path d="M19 14 q5 4 10 0" stroke="#10300a" stroke-width="2.4" fill="none" stroke-linecap="round"/>`
    : frame === 3
    ? `<path d="M20 10 L28 18 M28 10 L20 18" stroke="#10300a" stroke-width="2.6" stroke-linecap="round"/>`
    : `<ellipse cx="24" cy="14" rx="6.5" ry="7.5" fill="#fff" stroke="#10300a" stroke-width="1.6"/>
       <circle cx="26.5" cy="15" r="3.2" fill="#111"/><circle cx="27.6" cy="13.6" r="1.1" fill="#fff"/>`;
  const mouth = frame === 2
    ? `<path d="M29 22 L40 18 L40 30 Z" fill="#7a0f1c" stroke="${C.snakeDark}" stroke-width="1.5"/>`
    : frame === 3
    ? `<path d="M30 27 q2 -2 4 0 q2 2 4 0" stroke="#10300a" stroke-width="1.6" fill="none"/>`
    : `<path d="M29 26 q5 3 9 -2" stroke="#10300a" stroke-width="1.8" fill="none" stroke-linecap="round"/>`;
  return `<ellipse cx="17" cy="21" rx="15" ry="12.5" fill="${C.snake}" stroke="${C.snakeDark}" stroke-width="2"/>
    <ellipse cx="29" cy="23" rx="10" ry="8" fill="${C.snake}" stroke="${C.snakeDark}" stroke-width="2"/>
    <ellipse cx="22" cy="23" rx="15" ry="9" fill="${C.snake}"/>
    <ellipse cx="22" cy="29" rx="13" ry="4.5" fill="${C.belly}"/>
    <circle cx="10" cy="22" r="2.6" fill="${C.snakeSpot}"/><circle cx="15" cy="15" r="2" fill="${C.snakeSpot}"/>
    <path d="M3 13 Q16 2 30 9" stroke="#6b3a12" stroke-width="3.5" fill="none"/>
    <circle cx="12" cy="8" r="5.2" fill="#7fe3ff" stroke="#c9ccd8" stroke-width="2"/><circle cx="10.5" cy="6.5" r="1.6" fill="#fff"/>
    <circle cx="36" cy="20" r="1" fill="#10300a"/>${eye}${mouth}`;
}
for (let f = 0; f < 4; f++) save("spr_snake_head_" + f, 42, 36, head(f));
save("spr_snake_body", 24, 24,
  `<circle cx="12" cy="12" r="10" fill="${C.snake}" stroke="${C.snakeDark}" stroke-width="2"/>
   <path d="M3 15 Q12 22 21 15 L20 19 Q12 24 4 19 Z" fill="${C.belly}"/>
   <circle cx="9" cy="8" r="2.4" fill="${C.snakeSpot}"/><circle cx="15" cy="10" r="1.6" fill="${C.snakeSpot}"/>
   <path d="M6 6 q3 -3 7 -2" stroke="#c8ff9a" stroke-width="1.5" fill="none"/>`);
save("spr_snake_tail", 18, 18,
  `<circle cx="9" cy="9" r="6.5" fill="${C.snake}" stroke="${C.snakeDark}" stroke-width="2"/><circle cx="7" cy="7" r="1.6" fill="${C.snakeSpot}"/>`);
save("spr_snake_ball", 44, 44,
  `<circle cx="22" cy="22" r="19" fill="${C.snake}" stroke="${C.snakeDark}" stroke-width="2.2"/>
   <path d="M22 22 m-3 0 a3 3 0 1 1 6 0 a7 7 0 1 1 -14 0 a11 11 0 1 1 22 0 a15 15 0 1 1 -30 0" stroke="${C.snakeDark}" stroke-width="2.2" fill="none"/>
   <path d="M8 30 a15 15 0 0 0 28 0" stroke="${C.belly}" stroke-width="3" fill="none" opacity="0.8"/>
   <ellipse cx="30" cy="12" rx="4.5" ry="5" fill="#fff" stroke="#10300a" stroke-width="1.3"/><circle cx="31.5" cy="12.5" r="2" fill="#111"/>
   <circle cx="14" cy="11" r="3.4" fill="#7fe3ff" stroke="#c9ccd8" stroke-width="1.5"/>`);

// ---------- Enemies ----------
function bug(f) {
  const legs = f === 0 ? "M10 22 L6 28 M18 23 L18 29 M26 22 L30 28" : "M10 22 L13 28 M18 23 L15 29 M26 22 L23 28";
  return `<path d="${legs}" stroke="#2a1040" stroke-width="2.5" stroke-linecap="round"/>
    <path d="M3 22 Q4 4 18 4 Q32 4 31 22 Z" fill="#8a3fd1" stroke="#2a1040" stroke-width="2"/>
    <path d="M18 5 L18 22" stroke="#2a1040" stroke-width="1.5"/>
    <ellipse cx="11" cy="10" rx="4" ry="2.5" fill="#d8b0ff" opacity="0.8"/>
    <circle cx="31" cy="18" r="6" fill="#3a1a55" stroke="#1a0828" stroke-width="1.5"/>
    <circle cx="33" cy="16" r="2.2" fill="#fff"/><circle cx="33.6" cy="16.3" r="1" fill="#111"/>
    <path d="M30 12 L35 13.5" stroke="#1a0828" stroke-width="1.6"/>`;
}
save("spr_bug_0", 38, 30, bug(0));
save("spr_bug_1", 38, 30, bug(1));
function bee(f) {
  const wing = f === 0
    ? `<ellipse cx="14" cy="5" rx="7" ry="5" fill="#cdeeff" opacity="0.85" stroke="#6aa0c8"/><ellipse cx="22" cy="4" rx="7" ry="5" fill="#cdeeff" opacity="0.85" stroke="#6aa0c8"/>`
    : `<ellipse cx="13" cy="10" rx="7" ry="3" fill="#cdeeff" opacity="0.85" stroke="#6aa0c8"/><ellipse cx="23" cy="10" rx="7" ry="3" fill="#cdeeff" opacity="0.85" stroke="#6aa0c8"/>`;
  return `${wing}<path d="M4 19 L-1 21 L4 23 Z" fill="#333"/>
    <ellipse cx="18" cy="20" rx="14" ry="11" fill="#ffd21c" stroke="#3a2a00" stroke-width="2"/>
    <path d="M11 10 Q9 20 11 30 M18 9 Q16 20 18 31" stroke="#2a2000" stroke-width="3.5" fill="none"/>
    <circle cx="26" cy="17" r="4.5" fill="#fff" stroke="#3a2a00" stroke-width="1.2"/><circle cx="27.5" cy="17.5" r="2" fill="#111"/>
    <path d="M23 12 L30 13" stroke="#3a2a00" stroke-width="1.8"/><path d="M27 25 q2 2 4 0" stroke="#3a2a00" stroke-width="1.4" fill="none"/>`;
}
save("spr_bee_0", 36, 34, bee(0));
save("spr_bee_1", 36, 34, bee(1));

// ---------- Pickups and props ----------
save("spr_carrot", 22, 32,
  `<path d="M8 6 Q4 0 2 2 M11 6 Q11 -1 14 1 M13 7 Q19 2 20 6" stroke="#2c9a1a" stroke-width="3" fill="none" stroke-linecap="round"/>
   <path d="M5 8 Q11 5 17 8 L12 31 Q11 32 10 31 Z" fill="#ff8a1c" stroke="#9a3e00" stroke-width="1.6"/>
   <path d="M7 13 L11 13 M9 19 L13 18 M10 25 L12 25" stroke="#b85000" stroke-width="1.3"/><path d="M8 10 L9 20" stroke="#ffc07a" stroke-width="1.5"/>`);
save("spr_gem", 22, 22,
  `<path d="M11 1 L21 9 L11 21 L1 9 Z" fill="#ff2e5a" stroke="#7a0020" stroke-width="1.6"/>
   <path d="M1 9 L21 9 M6 9 L11 1 L16 9 L11 21 Z" stroke="#7a0020" stroke-width="1" fill="none"/>
   <path d="M7 8 L11 3 L10 8 Z" fill="#ffd0dc"/>`);
save("spr_orb", 34, 34,
  `<circle cx="17" cy="17" r="15" fill="url(#ob)" stroke="#ffffff" stroke-width="1.8" opacity="0.95"/>
   <path d="M7 12 A11 11 0 0 1 16 5" stroke="#fff" stroke-width="3" fill="none" stroke-linecap="round"/>`,
  `<radialGradient id="ob" cx="0.4" cy="0.35" r="0.7"><stop offset="0" stop-color="#e8fbff"/><stop offset="0.6" stop-color="#64c8ff"/><stop offset="1" stop-color="#1c5fd0"/></radialGradient>`);
save("spr_heart", 20, 18,
  `<path d="M10 17 L2 9 A4.5 4.5 0 0 1 10 3 A4.5 4.5 0 0 1 18 9 Z" fill="#ff3360" stroke="#7a0020" stroke-width="1.6"/>
   <ellipse cx="6" cy="7" rx="2" ry="1.4" fill="#ffd0dc"/>`);
function spring(f) {
  const top = f === 0 ? 4 : 13;
  let coil = "";
  for (let y = top + 5, i = 0; y < 21; y += f === 0 ? 4 : 2.5, i++) coil += `L${i % 2 ? 9 : 23} ${y} `;
  return `<path d="M16 ${top + 5} ${coil}" stroke="#c9ccd8" stroke-width="2.5" fill="none"/>
    <rect x="4" y="21" width="24" height="5" rx="2" fill="#6c6886" stroke="#33304a"/>
    <rect x="2" y="${top}" width="28" height="6" rx="3" fill="#ff3d3d" stroke="#7a0010" stroke-width="1.5"/>`;
}
save("spr_spring_0", 32, 28, spring(0));
save("spr_spring_1", 32, 28, spring(1));
function door(open) {
  const inside = open
    ? `<rect x="11" y="16" width="26" height="46" rx="12" fill="#0c1a2a"/><circle cx="24" cy="36" r="10" fill="#6aff7a" opacity="0.5"/><circle cx="24" cy="36" r="5" fill="#d8ffd8"/>`
    : `<rect x="11" y="16" width="26" height="46" rx="12" fill="#a8642a" stroke="#4a2608" stroke-width="1.5"/>
       <path d="M17 20 L17 60 M24 17 L24 61 M31 20 L31 60" stroke="#6a3a12" stroke-width="1.5"/>
       <rect x="18" y="34" width="12" height="10" rx="2" fill="#ffd21c" stroke="#7a5a00" stroke-width="1.5"/>
       <path d="M20 34 V30 A4 4 0 0 1 28 30 V34" stroke="#7a5a00" stroke-width="2" fill="none"/>`;
  return `<path d="M4 63 V20 A20 20 0 0 1 44 20 V63 Z" fill="url(#rock)" stroke="#33304a" stroke-width="2"/>${inside}
    <path d="M9 24 A15 15 0 0 1 22 8" stroke="#fff" stroke-width="2" fill="none" opacity="0.6"/>`;
}
save("spr_door_0", 48, 64, door(false), stoneGrad);
save("spr_door_1", 48, 64, door(true), stoneGrad);
function flag(up) {
  const f = up ? `<path d="M12 6 L24 11 L12 16 Z" fill="#3ee07a" stroke="#0a6a2a" stroke-width="1.3"/>`
               : `<path d="M12 30 L20 35 L12 40 Z" fill="#ff4a4a" stroke="#7a0010" stroke-width="1.3"/>`;
  return `<rect x="10" y="4" width="3" height="42" fill="#c9ccd8" stroke="#33304a"/><circle cx="11.5" cy="4" r="3" fill="#ffd21c"/>
    <rect x="4" y="44" width="16" height="4" rx="2" fill="#6c6886"/>${f}`;
}
save("spr_flag_0", 26, 48, flag(false));
save("spr_flag_1", 26, 48, flag(true));
save("spr_flower", 16, 24,
  `<path d="M8 24 Q7 16 8 10" stroke="#2c8a16" stroke-width="2" fill="none"/><path d="M8 18 Q3 15 2 17" stroke="#2c8a16" stroke-width="2" fill="none"/>
   <circle cx="8" cy="6" r="3" fill="#ffd21c"/><g fill="#ff5ac8"><circle cx="8" cy="1.8" r="2.4"/><circle cx="12.2" cy="6" r="2.4"/><circle cx="8" cy="10.2" r="2.4"/><circle cx="3.8" cy="6" r="2.4"/></g>
   <circle cx="8" cy="6" r="2.2" fill="#ffd21c"/>`);
save("spr_mushroom", 22, 20,
  `<rect x="8" y="10" width="6" height="10" rx="2" fill="#f4ead2" stroke="#8a7a5a"/>
   <path d="M1 12 Q11 -6 21 12 Z" fill="#e8283a" stroke="#6a0010" stroke-width="1.5"/>
   <circle cx="7" cy="7" r="2" fill="#fff"/><circle cx="14" cy="5" r="1.6" fill="#fff"/><circle cx="16" cy="10" r="1.3" fill="#fff"/>`);
save("spr_bush", 52, 26,
  `<circle cx="12" cy="18" r="10" fill="#3f8a2a"/><circle cx="26" cy="12" r="12" fill="#55a83a"/><circle cx="40" cy="18" r="10" fill="#3f8a2a"/>
   <rect x="2" y="18" width="48" height="8" fill="#3f8a2a"/><circle cx="23" cy="8" r="4" fill="#8ad65a"/>`);
save("spr_vine", 12, 64,
  `<path d="M6 0 Q1 16 6 32 Q11 48 6 64" stroke="#2c8a16" stroke-width="3" fill="none"/>
   <ellipse cx="3" cy="14" rx="3" ry="5" fill="#55c42a"/><ellipse cx="9" cy="38" rx="3" ry="5" fill="#55c42a"/><ellipse cx="3" cy="56" rx="3" ry="4" fill="#55c42a"/>`);

// ---------- Bosses (facing right; frames: 0 stand, 1 move, 2 attack, 3 hurt) ----------
function mouse(f) {
  const grey = "#9a98ac", dark = "#34324a", pink = "#f4a3b8";
  const lean = f === 2 ? -6 : 0;
  const legs = f === 1 ? `<ellipse cx="30" cy="77" rx="9" ry="5" fill="${pink}" stroke="${dark}" stroke-width="2"/><ellipse cx="56" cy="74" rx="9" ry="5" fill="${pink}" stroke="${dark}" stroke-width="2"/>`
                       : `<ellipse cx="32" cy="76" rx="9" ry="5" fill="${pink}" stroke="${dark}" stroke-width="2"/><ellipse cx="54" cy="76" rx="9" ry="5" fill="${pink}" stroke="${dark}" stroke-width="2"/>`;
  const eyes = f === 3
    ? `<path d="M55 24 L61 30 M61 24 L55 30 M65 23 L71 29 M71 23 L65 29" stroke="${dark}" stroke-width="2.5" stroke-linecap="round"/>`
    : `<ellipse cx="58" cy="27" rx="4.5" ry="5.5" fill="#fff" stroke="${dark}" stroke-width="1.5"/><ellipse cx="68" cy="26" rx="4.5" ry="5.5" fill="#fff" stroke="${dark}" stroke-width="1.5"/>
       <circle cx="60" cy="28" r="2.2" fill="#111"/><circle cx="70" cy="27" r="2.2" fill="#111"/>
       <path d="M53 19 L63 23 M73 18 L65 22" stroke="${dark}" stroke-width="3" stroke-linecap="round"/>`;
  const glove = f === 2
    ? `<circle cx="20" cy="40" r="10" fill="#e8283a" stroke="#6a0010" stroke-width="2"/><path d="M16 36 q4 -3 8 0" stroke="#ffb0b8" stroke-width="2" fill="none"/>`
    : `<circle cx="72" cy="56" r="10" fill="#e8283a" stroke="#6a0010" stroke-width="2"/><path d="M68 52 q4 -3 8 0" stroke="#ffb0b8" stroke-width="2" fill="none"/>`;
  return `<g transform="translate(${lean} 0)">
    <path d="M18 60 Q2 56 4 40 Q6 30 12 34" stroke="${pink}" stroke-width="4" fill="none" stroke-linecap="round"/>
    ${legs}
    <ellipse cx="42" cy="56" rx="25" ry="20" fill="${grey}" stroke="${dark}" stroke-width="2.5"/>
    <ellipse cx="47" cy="61" rx="14" ry="11" fill="#dcdbe6"/>
    <circle cx="28" cy="54" r="9" fill="#e8283a" stroke="#6a0010" stroke-width="2"/>
    <circle cx="44" cy="12" r="11" fill="${grey}" stroke="${dark}" stroke-width="2"/><circle cx="44" cy="12" r="6" fill="${pink}"/>
    <circle cx="72" cy="10" r="11" fill="${grey}" stroke="${dark}" stroke-width="2"/><circle cx="72" cy="10" r="6" fill="${pink}"/>
    <circle cx="60" cy="30" r="17" fill="${grey}" stroke="${dark}" stroke-width="2.5"/>
    <path d="M47 20 L74 13 L70 5 Z" fill="#ffd21c" stroke="#9a6a00" stroke-width="2" stroke-linejoin="round"/>
    <circle cx="62" cy="13" r="1.8" fill="#d8a000"/><circle cx="68" cy="10" r="1.4" fill="#d8a000"/>
    <ellipse cx="74" cy="36" rx="8" ry="6" fill="${grey}" stroke="${dark}" stroke-width="2"/>
    <circle cx="81" cy="34" r="3.2" fill="${pink}" stroke="${dark}" stroke-width="1.2"/>
    <rect x="70" y="41" width="4" height="5" fill="#fff" stroke="${dark}" stroke-width="1"/><rect x="74" y="41" width="4" height="5" fill="#fff" stroke="${dark}" stroke-width="1"/>
    <path d="M76 36 L88 33 M76 38 L88 39" stroke="${dark}" stroke-width="1"/>
    ${f === 3 ? `<ellipse cx="72" cy="45" rx="4" ry="3" fill="#6a0010"/>` : ""}${eyes}${glove}</g>`;
}
for (let f = 0; f < 4; f++) save("spr_mouse_" + f, 92, 84, mouse(f));

function hen(f) {
  const ink = "#5a3a1a", comb = "#e8283a";
  const head = f === 2 ? `translate(6 10) rotate(18 58 26)` : "translate(0 0)";
  const wing = f === 1
    ? `<path d="M30 44 Q20 14 46 22 Q44 38 30 44 Z" fill="#f2f2f2" stroke="${ink}" stroke-width="2"/>`
    : `<ellipse cx="36" cy="52" rx="15" ry="10" fill="#efefef" stroke="${ink}" stroke-width="2"/>`;
  const eye = f === 3
    ? `<path d="M58 20 L64 26 M64 20 L58 26" stroke="#222" stroke-width="2.5" stroke-linecap="round"/>`
    : `<circle cx="61" cy="23" r="4" fill="#fff" stroke="${ink}" stroke-width="1.3"/><circle cx="62.5" cy="23.5" r="2" fill="#111"/>
       <path d="M54 16 L67 20" stroke="#222" stroke-width="3" stroke-linecap="round"/>`;
  const steam = f !== 3 ? `<path d="M48 4 q-4 -4 0 -8 M56 2 q-4 -4 0 -8" stroke="#fff" stroke-width="2.5" fill="none" opacity="0.8"/>` : "";
  return `<path d="M18 44 Q2 30 8 18 Q14 30 22 30 Q14 18 22 10 Q26 26 30 34 Z" fill="#fff" stroke="${ink}" stroke-width="2"/>
    <path d="M34 70 L32 82 M28 82 L36 82 M48 70 L50 82 M46 82 L54 82" stroke="#ff9a1c" stroke-width="3" stroke-linecap="round"/>
    <ellipse cx="42" cy="52" rx="26" ry="22" fill="#fff" stroke="${ink}" stroke-width="2.5"/>
    ${wing}
    <g transform="${head}">
      <path d="M48 12 Q50 2 55 8 Q58 0 62 8 Q67 2 67 13 Z" fill="${comb}" stroke="#7a0010" stroke-width="1.5"/>
      <circle cx="58" cy="26" r="14" fill="#fff" stroke="${ink}" stroke-width="2.5"/>
      <circle cx="56" cy="31" r="5" fill="#ff6a6a" opacity="0.7"/>
      <path d="M70 24 L84 28 L70 33 Z" fill="#ffc21c" stroke="#9a6a00" stroke-width="1.6" stroke-linejoin="round"/>
      <path d="M69 34 Q72 42 67 42 Q64 38 66 34 Z" fill="${comb}" stroke="#7a0010" stroke-width="1.2"/>
      ${eye}${steam}
    </g>
    ${f === 3 ? `<path d="M10 60 l6 -4 M76 56 l6 -6 M20 74 l-4 6" stroke="#fff" stroke-width="3"/>` : ""}`;
}
for (let f = 0; f < 4; f++) save("spr_hen_" + f, 92, 86, hen(f));

save("spr_cheese", 22, 18,
  `<path d="M2 16 L20 16 L20 4 Z" fill="#ffd21c" stroke="#9a6a00" stroke-width="1.8" stroke-linejoin="round"/>
   <path d="M2 16 L20 4 L14 1 Z" fill="#ffe680" stroke="#9a6a00" stroke-width="1.5" stroke-linejoin="round"/>
   <circle cx="14" cy="12" r="2" fill="#d8a000"/><circle cx="17" cy="8" r="1.4" fill="#d8a000"/>`);
save("spr_feather", 14, 26,
  `<path d="M7 25 Q1 14 7 1 Q13 14 7 25 Z" fill="#ffffff" stroke="#8a7a6a" stroke-width="1.3"/>
   <path d="M7 25 L7 4" stroke="#b8a890" stroke-width="1.2"/><path d="M7 10 L3 7 M7 15 L11 12 M7 19 L3 16" stroke="#c8b8a0" stroke-width="1"/>`);
// ---------- Eggs ----------
// The rare egg: a white egg with a face drawn on in black marker, in three moods
// (spr_egg_0..2 become the three frames of spr_egg). A dark outline keeps it easy to spot.
const eggShape = "M14 1.5 C22 1.5 26.5 12 26.5 20 C26.5 28 21 32.5 14 32.5 C7 32.5 1.5 28 1.5 20 C1.5 12 6 1.5 14 1.5 Z";
const eggDefs = `<radialGradient id="eg" cx="0.38" cy="0.3" r="0.75"><stop offset="0" stop-color="#ffffff"/><stop offset="0.65" stop-color="#f1eef6"/><stop offset="1" stop-color="#c9c2da"/></radialGradient>`;
const ink = `stroke="#1b1b1b" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" fill="none"`;
const eggFaces = [
  // Googly eyes, eyebrows up, a little smirk.
  `<circle cx="9.5" cy="16" r="4" fill="#ffffff" stroke="#1b1b1b" stroke-width="1.4"/>
   <circle cx="18.5" cy="15.5" r="4.6" fill="#ffffff" stroke="#1b1b1b" stroke-width="1.4"/>
   <circle cx="11" cy="17" r="1.9" fill="#1b1b1b"/><circle cx="20.2" cy="16.6" r="2.1" fill="#1b1b1b"/>
   <path d="M6 10.5 Q9 8.5 12 10" ${ink}/><path d="M15.5 9.4 Q18.5 7.4 22 9.4" ${ink}/>
   <path d="M11.5 25.6 Q14.5 27.2 17.6 24.8" ${ink}/>`,
  // A wink and a big grin.
  `<ellipse cx="9.5" cy="16.5" rx="2" ry="3" fill="#1b1b1b"/>
   <path d="M6.5 11 Q9.5 9 12.5 10.8" ${ink}/>
   <path d="M15.8 17 Q18.8 13.8 21.8 16.6" ${ink}/>
   <path d="M7.5 22.5 Q14 30 20.5 22.5" ${ink}/><path d="M6.6 21.6 L8.2 23.2 M21.4 21.6 L19.8 23.2" ${ink}/>`,
  // Eyes squeezed shut with laughing, tongue out.
  `<path d="M6.5 13 L11 15.8 L6.5 18.6" ${ink}/><path d="M21.5 13 L17 15.8 L21.5 18.6" ${ink}/>
   <path d="M14.6 25.8 Q15 31 18 30.6 Q20.6 30.1 19.7 25" fill="#ff6f96" stroke="#1b1b1b" stroke-width="1.3" stroke-linejoin="round"/>
   <path d="M17.3 26.3 L17.5 28.6" stroke="#c8406a" stroke-width="0.9" stroke-linecap="round"/>
   <path d="M8 22.5 Q14 29 20.2 22.5" ${ink}/>`,
];
eggFaces.forEach((face, i) => save("spr_egg_" + i, 28, 34,
  `<path d="${eggShape}" fill="url(#eg)" stroke="#2a2238" stroke-width="2"/>
   <ellipse cx="8.4" cy="8.6" rx="2" ry="3.3" fill="#ffffff" transform="rotate(-20 8.4 8.6)"/>
   ${face}`, eggDefs));

// The two-player super egg (32 x 40): a fat golden egg with orange spots and a heart
// (frame 0), then hatched: the bottom of the shell with the heart floating out (frame 1).
const goldDefs = `<linearGradient id="gold" x1="0.2" y1="0" x2="0.8" y2="1"><stop offset="0" stop-color="#ffe86e"/><stop offset="0.55" stop-color="#ffc21e"/><stop offset="1" stop-color="#ee9410"/></linearGradient>`;
const heartPath = (cx, cy, s) => {
  const p = (x, y) => `${(cx + x * s).toFixed(2)} ${(cy + y * s).toFixed(2)}`;
  return `M${p(0, 5)} C${p(-6, 0.5)} ${p(-6.5, -3)} ${p(-4.8, -4.5)} C${p(-3.2, -5.9)} ${p(-1, -5.1)} ${p(0, -3.3)} ` +
         `C${p(1, -5.1)} ${p(3.2, -5.9)} ${p(4.8, -4.5)} C${p(6.5, -3)} ${p(6, 0.5)} ${p(0, 5)} Z`;
};
const sparkle = (x, y, r) => `<path d="M${x} ${y - r} L${x + r * 0.28} ${y - r * 0.28} L${x + r} ${y} L${x + r * 0.28} ${y + r * 0.28} L${x} ${y + r} L${x - r * 0.28} ${y + r * 0.28} L${x - r} ${y} L${x - r * 0.28} ${y - r * 0.28} Z" fill="#ffffff"/>`;
save("spr_super_egg_0", 32, 40,
  `<path d="M16 3 C26.5 3 30.8 15 30.8 24 C30.8 33 24.5 38.2 16 38.2 C7.5 38.2 1.2 33 1.2 24 C1.2 15 5.5 3 16 3 Z" fill="url(#gold)" stroke="#3a1e08" stroke-width="2"/>
   <circle cx="8.5" cy="16" r="2.6" fill="#f08a1a"/><circle cx="23.5" cy="13.5" r="2.2" fill="#f08a1a"/>
   <circle cx="6.5" cy="27.5" r="2.4" fill="#f08a1a"/><circle cx="25.8" cy="27" r="2.8" fill="#f08a1a"/>
   <circle cx="15.5" cy="34" r="2.2" fill="#f08a1a"/>
   <path d="${heartPath(16, 23.5, 1.15)}" fill="#ff3d6e" stroke="#7a0f2c" stroke-width="1.3" stroke-linejoin="round"/>
   <ellipse cx="13" cy="20.4" rx="1.3" ry="1" fill="#ffc0d0"/>
   <ellipse cx="9.5" cy="9.8" rx="2.4" ry="3.8" fill="#fff8d0" opacity="0.9" transform="rotate(-25 9.5 9.8)"/>
   ${sparkle(27, 6, 4)}`, goldDefs);
save("spr_super_egg_1", 32, 40,
  `<path d="M1.8 24.5 L5.6 20.6 L9.4 24.6 L13 20.2 L16.6 24.6 L20.2 20.2 L23.8 24.6 L27.2 20.6 L30.2 24.5 C30.6 33 24.5 38.2 16 38.2 C7.5 38.2 1.4 33 1.8 24.5 Z" fill="url(#gold)" stroke="#3a1e08" stroke-width="2" stroke-linejoin="round"/>
   <circle cx="8.5" cy="31" r="2.3" fill="#f08a1a"/><circle cx="22" cy="30.5" r="2.6" fill="#f08a1a"/><circle cx="15.5" cy="35" r="1.7" fill="#f08a1a"/>
   <path d="${heartPath(16, 11.5, 1.75)}" fill="#ff3d6e" stroke="#3a1e08" stroke-width="1.8" stroke-linejoin="round"/>
   <ellipse cx="11.3" cy="6.8" rx="1.7" ry="2.3" fill="#ffb3c8" transform="rotate(-30 11.3 6.8)"/>`, goldDefs);

// ---------- Title logo: chunky 3D cartoon letters ----------
function logo3d(text, size, y, w) {
  let layers = "";
  for (let i = 8; i >= 1; i--) {
    layers += `<text x="${w / 2 + i}" y="${y + i}" text-anchor="middle" font-family="Comic Sans MS" font-weight="bold" font-size="${size}" fill="#1a5a0c" stroke="#0c2a06" stroke-width="6" stroke-linejoin="round">${text}</text>`;
  }
  return layers +
    `<text x="${w / 2}" y="${y}" text-anchor="middle" font-family="Comic Sans MS" font-weight="bold" font-size="${size}" fill="url(#lg)" stroke="#0c2a06" stroke-width="6" stroke-linejoin="round" paint-order="stroke"/>`.replace("/>", `>${text}</text>`) +
    `<text x="${w / 2 - 3}" y="${y - 4}" text-anchor="middle" font-family="Comic Sans MS" font-weight="bold" font-size="${size}" fill="none" stroke="#e8ffb0" stroke-width="2" opacity="0.6">${text}</text>`;
}
save("spr_logo", 640, 200, logo3d("SNAGMAN", 106, 136, 640),
  `<linearGradient id="lg" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#c6ff6a"/><stop offset="0.5" stop-color="#5cd62a"/><stop offset="1" stop-color="#2e9a14"/></linearGradient>`);

// ---------- HUD font strip: one 30 x 38 cell per glyph ----------
const GLYPHS = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ!?.:x-/',%()+";
fs.writeFileSync(path.join(OUT, "font_hud_glyphs.txt"), GLYPHS);
let strip = "";
[...GLYPHS].forEach((ch, i) => {
  const esc = ch.replace("&", "&amp;").replace("<", "&lt;").replace("'", "&apos;");
  strip += `<text x="${i * 30 + 15}" y="30" text-anchor="middle" font-family="Comic Sans MS" font-weight="bold" font-size="30" fill="url(#hf)" stroke="#101a40" stroke-width="5" stroke-linejoin="round" paint-order="stroke">${esc}</text>`;
});
save("font_hud", GLYPHS.length * 30, 38, strip,
  `<linearGradient id="hf" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#ffffff"/><stop offset="0.55" stop-color="#fff6a8"/><stop offset="1" stop-color="#ffb21c"/></linearGradient>`);

// =====================================================================================
// ---------- Level 4, the cavern: brown to orange ----------
// =====================================================================================
const K = {
  rock: "#b0602a", rockLight: "#e89a52", rockDark: "#62300f", mortar: "#341604", deep: "#4a2410",
  crust: "#f0a040", crustLight: "#ffd88a", crustDark: "#b0561c", crustLine: "#4a2006",
  fur: "#7a5038", furDark: "#4a2c18", furLine: "#24120a", pink: "#f4a0ac", pinkDark: "#c85a70",
};
const caveGrad = `<linearGradient id="cst" x1="0" y1="0" x2="0.6" y2="1"><stop offset="0" stop-color="${K.rockLight}"/><stop offset="0.5" stop-color="${K.rock}"/><stop offset="1" stop-color="${K.rockDark}"/></linearGradient>
<linearGradient id="cg" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="${K.crustLight}"/><stop offset="0.6" stop-color="${K.crust}"/><stop offset="1" stop-color="${K.crustDark}"/></linearGradient>
<linearGradient id="crk" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#e8b080"/><stop offset="1" stop-color="#7a3a14"/></linearGradient>`;
function caveStones(seed) {
  const sets = [
    [[8, 9, 7, 6], [23, 8, 7, 6], [7, 23, 6, 7], [21, 22, 9, 7], [16, 15, 4, 3]],
    [[9, 7, 8, 5], [24, 12, 6, 7], [10, 21, 8, 7], [24, 26, 6, 4], [3, 14, 3, 4]],
  ];
  return sets[seed % 2].map(([x, y, rx, ry]) =>
    `<ellipse cx="${x}" cy="${y}" rx="${rx}" ry="${ry}" fill="url(#cst)" stroke="${K.mortar}" stroke-width="1.5"/>` +
    `<ellipse cx="${x - rx * 0.3}" cy="${y - ry * 0.35}" rx="${rx * 0.4}" ry="${ry * 0.3}" fill="${K.rockLight}" opacity="0.6"/>`
  ).join("");
}
const caveDirt = (seed) => `<rect width="32" height="32" fill="${K.deep}"/>${caveStones(seed)}`;
const caveTop = (left, right) => {
  // An orange mineral crust instead of grass, with little drips along its lower edge.
  let drips = "";
  for (let x = 2; x < 32; x += 6) drips += `<ellipse cx="${x + 1}" cy="${10 + ((x * 5) % 3)}" rx="2.4" ry="${2 + ((x * 3) % 2)}" fill="${K.crust}" stroke="${K.crustLine}" stroke-width="0.8"/>`;
  const l = left ? `<circle cx="2" cy="6" r="5.5" fill="url(#cg)" stroke="${K.crustLine}" stroke-width="1.2"/>` : "";
  const r = right ? `<circle cx="30" cy="6" r="5.5" fill="url(#cg)" stroke="${K.crustLine}" stroke-width="1.2"/>` : "";
  return `<rect x="${left ? 2 : 0}" y="1" width="${32 - (left ? 2 : 0) - (right ? 2 : 0)}" height="9" fill="url(#cg)"/>
    <line x1="${left ? 2 : 0}" y1="1" x2="${right ? 30 : 32}" y2="1" stroke="${K.crustLine}" stroke-width="1.5"/>${drips}${l}${r}
    <path d="M5 4 q3 -2 6 0 M18 3 q3 -2 6 0" stroke="#fff0c0" stroke-width="1.2" fill="none" opacity="0.8"/>`;
};
const caveTiles = [
  "",                                                   // 0 empty
  caveDirt(0) + caveTop(false, false),                  // 1 crust
  caveDirt(0),                                          // 2 rock A
  caveDirt(1),                                          // 3 rock B
  caveDirt(1) + caveTop(true, false),                   // 4 crust, left end
  caveDirt(0) + caveTop(false, true),                   // 5 crust, right end
  caveDirt(1) + `<rect x="0" y="22" width="32" height="10" fill="#1e0c02" opacity="0.6"/>
    <path d="M4 32 L7 25 L10 32 Z M17 32 L20 23 L23 32 Z M27 32 L29 27 L31 32 Z" fill="${K.rockDark}" stroke="${K.mortar}" stroke-width="1"/>`, // 6 ceiling underside
  `<rect x="0" y="2" width="32" height="11" rx="3" fill="url(#log)" stroke="#4a2608" stroke-width="1.5"/>
    <line x1="3" y1="7.5" x2="29" y2="7.5" stroke="#5a3010" stroke-width="1"/><circle cx="4" cy="5" r="1.2" fill="#3a1a06"/><circle cx="28" cy="5" r="1.2" fill="#3a1a06"/>`, // 7 wooden plank (one-way)
  `<rect x="1" y="1" width="30" height="30" rx="4" fill="url(#crk)" stroke="#3a1806" stroke-width="2"/>
    <path d="M8 3 L13 12 L9 18 L15 29 M24 4 L20 13 L26 19" stroke="#3a1806" stroke-width="1.6" fill="none"/>
    <path d="M5 6 L10 5" stroke="#fff0d0" stroke-width="1.5" opacity="0.7"/>`, // 8 cracked block (breakable)
  `<path d="M0 32 L4 16 L8 32 L12 16 L16 32 L20 16 L24 32 L28 16 L32 32 Z" fill="url(#crk)" stroke="#3a1806" stroke-width="1.5"/>
    <path d="M3 22 L4 17 M11 22 L12 17 M19 22 L20 17 M27 22 L28 17" stroke="#fff" stroke-width="1" opacity="0.8"/>`, // 9 spikes (stalagmite points)
  caveDirt(0) + caveTop(true, true),                    // 10 crust, single column
];
save("spr_tiles_cave", 32 * caveTiles.length, 32,
  caveTiles.map((t, i) => `<g transform="translate(${i * 32},0)" clip-path="url(#cell)">${t}</g>`).join(""),
  stoneGrad + caveGrad + `<clipPath id="cell"><rect x="0" y="0" width="32" height="32"/></clipPath>`);

// Decorations: stalactites hang under ceilings (instead of vines), crystals glow on the floor.
save("spr_stalactite", 20, 36,
  `<path d="M1 0 L19 0 L13 14 L11 34 L8 16 Z" fill="url(#cst)" stroke="${K.mortar}" stroke-width="1.5" stroke-linejoin="round"/>
   <path d="M6 2 L9 14" stroke="${K.rockLight}" stroke-width="1.4" opacity="0.8"/>
   <circle cx="11" cy="35" r="1.3" fill="#9adcff" opacity="0.9"/>`, caveGrad);
save("spr_crystal", 24, 24,
  `<path d="M4 24 L6 12 L9 8 L12 24 Z" fill="#ffb24a" stroke="#6a2a06" stroke-width="1.3"/>
   <path d="M9 24 L11 6 L14 1 L17 7 L17 24 Z" fill="#ffd27a" stroke="#6a2a06" stroke-width="1.3"/>
   <path d="M15 24 L18 12 L21 15 L21 24 Z" fill="#f08a2a" stroke="#6a2a06" stroke-width="1.3"/>
   <path d="M12 8 L13 18" stroke="#fffbe0" stroke-width="1.6" opacity="0.9"/>`);

// Cave parallax (same slots as the jungle's mountains, clouds and hills).
let cfar = "";
for (let i = 0; i < 18; i++) {
  const x = i * 57 + ((i * 31) % 20);
  const h = 60 + ((i * 47) % 90);
  cfar += `<path d="M${x - 22} 260 L${x - 6} ${260 - h} L${x + 6} ${260 - h + 8} L${x + 22} 260 Z" fill="#5a2c12"/>`;
}
save("spr_bg_cave_far", 1024, 260, `<rect y="150" width="1024" height="110" fill="#4a2410"/>` + cfar +
  `<path d="${ridge(1024, 260, 170, [20, 10], [3, 8], 0.9)}" fill="#3a1a08"/>`);
let ctop = "";
for (let i = 0; i < 26; i++) {
  const x = i * 40 + ((i * 17) % 14);
  const h = 30 + ((i * 53) % 70);
  ctop += `<path d="M${x - 14} 0 L${x + 14} 0 L${x + 3} ${h} L${x} ${h + 6} L${x - 3} ${h} Z" fill="${i % 2 ? "#6a3414" : "#7e4018"}" stroke="#3a1806" stroke-width="2"/>`;
}
save("spr_bg_cave_top", 1024, 130, `<rect width="1024" height="14" fill="#3a1806"/>` + ctop);
let cnear = "";
for (let i = 0; i < 9; i++) {
  const x = i * 114 + 40 + ((i * 29) % 30);
  const w = 26 + (i % 3) * 8;
  const top = 40 + ((i * 41) % 50);
  cnear += `<path d="M${x - w / 2} 200 L${x - 3} ${top} L${x + 3} ${top} L${x + w / 2} 200 Z" fill="#8a4418"/>
    <path d="M${x - w / 2 + 6} 196 L${x - 2} ${top + 14}" stroke="#c26a2a" stroke-width="3" opacity="0.7"/>`;
}
save("spr_bg_cave_near", 1024, 200, cnear +
  `<path d="${ridge(1024, 200, 150, [20, 9], [2, 6], 1.3)}" fill="#a0521c"/>
   <path d="${ridge(1024, 200, 172, [14, 6], [3, 9], 2.4)}" fill="#6e3410"/>`);

// ---------- The bat (hangs under the ceiling, then swoops) ----------
function bat(frame) {
  const body = `<ellipse cx="20" cy="15" rx="7" ry="8" fill="#6a4058" stroke="#2a1020" stroke-width="1.6"/>
    <path d="M14 9 L13 2 L17 7 Z M26 9 L27 2 L23 7 Z" fill="#6a4058" stroke="#2a1020" stroke-width="1.3" stroke-linejoin="round"/>
    <circle cx="17.5" cy="13" r="2" fill="#ffb02a"/><circle cx="22.5" cy="13" r="2" fill="#ffb02a"/>
    <circle cx="17.8" cy="13.2" r="0.8" fill="#2a1020"/><circle cx="22.8" cy="13.2" r="0.8" fill="#2a1020"/>
    <path d="M18 18 L19 20.5 L20 18 M20 18 L21 20.5 L22 18" stroke="#fff" stroke-width="0.9" fill="#fff"/>`;
  if (frame === 0) {
    // Hanging upside down, wrapped in its wings, feet hooked on the rock above.
    return `<g transform="rotate(180 20 15)">${body}</g>
      <path d="M12 6 Q8 18 14 26 Q20 30 26 26 Q32 18 28 6 Q20 10 12 6 Z" fill="#4e2c40" stroke="#2a1020" stroke-width="1.5"/>
      <path d="M17 1 L17 5 M23 1 L23 5" stroke="#2a1020" stroke-width="1.6"/>
      <circle cx="17" cy="21" r="2" fill="#ffb02a"/><circle cx="23" cy="21" r="2" fill="#ffb02a"/>
      <circle cx="17" cy="21.3" r="0.8" fill="#2a1020"/><circle cx="23" cy="21.3" r="0.8" fill="#2a1020"/>`;
  }
  const wy = frame === 1 ? -8 : 10;   // wings up, then down
  const wing = (s) => `<path d="M${20 + s * 5} 13 Q${20 + s * 12} ${8 + wy} ${20 + s * 19} ${10 + wy * 0.6} Q${20 + s * 16} ${16 + wy * 0.4} ${20 + s * 14} ${18 + wy * 0.3} Q${20 + s * 10} ${17} ${20 + s * 6} 18 Z" fill="#4e2c40" stroke="#2a1020" stroke-width="1.5" stroke-linejoin="round"/>`;
  return wing(-1) + wing(1) + body;
}
for (let f = 0; f < 3; f++) save("bat_" + f, 40, 32, bat(f));

// ---------- The mole boss: a burly digger in a miner's helmet ----------
const moleDefs = `<radialGradient id="mf" cx="0.4" cy="0.35" r="0.7"><stop offset="0" stop-color="#9a6a48"/><stop offset="1" stop-color="${K.furDark}"/></radialGradient>`;
const helmet = (x, y, rot = 0) => `<g transform="rotate(${rot} ${x} ${y})">
    <path d="M${x - 20} ${y + 4} Q${x - 18} ${y - 18} ${x} ${y - 19} Q${x + 18} ${y - 18} ${x + 20} ${y + 4} Z" fill="#f0a020" stroke="${K.furLine}" stroke-width="2.4"/>
    <rect x="${x - 24}" y="${y + 1}" width="48" height="6" rx="3" fill="#d88410" stroke="${K.furLine}" stroke-width="2"/>
    <circle cx="${x + 10}" cy="${y - 7}" r="6" fill="#fff6a0" stroke="${K.furLine}" stroke-width="2"/>
    <path d="M${x - 10} ${y - 13} Q${x - 4} ${y - 16} ${x + 2} ${y - 15}" stroke="#ffe08a" stroke-width="2" fill="none"/></g>`;
const paw = (x, y, rot = 0) => `<g transform="rotate(${rot} ${x} ${y})">
    <ellipse cx="${x}" cy="${y}" rx="11" ry="8" fill="${K.pink}" stroke="${K.furLine}" stroke-width="2"/>
    <path d="M${x + 6} ${y - 5} l7 -2 M${x + 8} ${y} l8 0 M${x + 6} ${y + 5} l7 2" stroke="#fff4e8" stroke-width="2.6" stroke-linecap="round"/></g>`;
const moleEyes = (x, y, dizzy) => dizzy
  ? `<path d="M${x - 3} ${y} a3 3 0 1 1 3 3 a2 2 0 1 1 -2 -2" stroke="${K.furLine}" stroke-width="1.6" fill="none"/>
     <path d="M${x + 9} ${y} a3 3 0 1 1 3 3 a2 2 0 1 1 -2 -2" stroke="${K.furLine}" stroke-width="1.6" fill="none"/>`
  : `<circle cx="${x}" cy="${y}" r="2.6" fill="#120804"/><circle cx="${x + 11}" cy="${y}" r="2.6" fill="#120804"/>
     <circle cx="${x + 0.8}" cy="${y - 0.9}" r="0.9" fill="#fff"/><circle cx="${x + 11.8}" cy="${y - 0.9}" r="0.9" fill="#fff"/>
     <path d="M${x - 4} ${y - 6} L${x + 3} ${y - 3} M${x + 15} ${y - 6} L${x + 8} ${y - 3}" stroke="${K.furLine}" stroke-width="2.2" stroke-linecap="round"/>`;
const snout = (x, y) => `<ellipse cx="${x}" cy="${y}" rx="12" ry="8" fill="${K.pink}" stroke="${K.furLine}" stroke-width="2"/>
    <circle cx="${x + 9}" cy="${y - 1}" r="5" fill="${K.pinkDark}" stroke="${K.furLine}" stroke-width="1.8"/>
    <path d="M${x - 4} ${y + 2} l-14 -3 M${x - 4} ${y + 4} l-14 3 M${x + 3} ${y + 5} q3 4 8 0" stroke="${K.furLine}" stroke-width="1.3" fill="none"/>`;
function mole(f) {
  const dizzy = f === 5;
  if (f === 2) {
    // Curled up into a ball for the roll (it spins in the game).
    return `<circle cx="56" cy="54" r="26" fill="url(#mf)" stroke="${K.furLine}" stroke-width="3"/>
      <path d="M38 54 Q44 36 60 38 Q74 42 70 56 Q66 66 54 62" stroke="${K.furLine}" stroke-width="2.2" fill="none"/>
      ${paw(70, 68, 30)}${paw(40, 72, 150)}${helmet(60, 34, 20)}`;
  }
  const squash = f === 4;
  const leap = f === 3;
  const by = squash ? 60 : leap ? 46 : 52;
  const ry = squash ? 20 : leap ? 28 : 26;
  const rx = squash ? 40 : 34;
  const step = f === 1 ? 5 : f === 0 ? -5 : 0;
  const feet = leap
    ? `<ellipse cx="40" cy="78" rx="8" ry="5" fill="${K.pink}" stroke="${K.furLine}" stroke-width="2"/><ellipse cx="60" cy="79" rx="8" ry="5" fill="${K.pink}" stroke="${K.furLine}" stroke-width="2"/>`
    : `<ellipse cx="${36 + step}" cy="79" rx="9" ry="5" fill="${K.pink}" stroke="${K.furLine}" stroke-width="2"/><ellipse cx="${62 - step}" cy="79" rx="9" ry="5" fill="${K.pink}" stroke="${K.furLine}" stroke-width="2"/>`;
  const paws = leap ? paw(72, 12, -60) + paw(92, 18, -40)
    : squash ? paw(96, 74, 10) + paw(22, 74, 170)
    : paw(88, 66 + step * 0.4, 0) + paw(26, 70 - step * 0.4, 180);
  const dust = squash ? `<g fill="#e8c8a0" opacity="0.85"><circle cx="8" cy="78" r="6"/><circle cx="18" cy="74" r="5"/><circle cx="104" cy="78" r="6"/><circle cx="94" cy="73" r="5"/></g>` : "";
  const stars = dizzy ? `<path d="M40 14 l2 5 5 1 -4 3 1 5 -4 -3 -4 3 1 -5 -4 -3 5 -1 Z M80 8 l2 5 5 1 -4 3 1 5 -4 -3 -4 3 1 -5 -4 -3 5 -1 Z" fill="#ffe04a" stroke="${K.furLine}" stroke-width="1"/>` : "";
  return `${dust}${feet}
    <path d="M${56 - rx} ${by + 6} q-8 2 -10 -4" stroke="${K.furLine}" stroke-width="3" fill="none"/>
    <ellipse cx="54" cy="${by}" rx="${rx}" ry="${ry}" fill="url(#mf)" stroke="${K.furLine}" stroke-width="3"/>
    <ellipse cx="60" cy="${by + 8}" rx="${rx * 0.5}" ry="${ry * 0.55}" fill="#c89a78"/>
    ${moleEyes(72, by - 10, dizzy)}${snout(88, by - 2)}${helmet(70, by - ry + 6, 6)}${paws}${stars}`;
}
for (let f = 0; f < 6; f++) save("mole_" + f, 112, 84, mole(f), moleDefs);

// ---------- Cave hazards: a falling rock and the mole's ground shockwave ----------
save("spr_rock", 24, 24,
  `<path d="M4 9 L9 3 L17 2 L22 8 L21 17 L14 22 L6 20 L2 14 Z" fill="url(#cst)" stroke="${K.mortar}" stroke-width="1.8" stroke-linejoin="round"/>
   <path d="M7 8 L11 5 M15 12 L18 16" stroke="${K.rockLight}" stroke-width="1.5"/>`, caveGrad);
save("spr_shockwave", 48, 26,
  `<path d="M2 26 Q8 4 24 2 Q40 4 46 26 Z" fill="#e8b878" opacity="0.85" stroke="#7a3a14" stroke-width="2"/>
   <path d="M10 26 Q14 12 24 10 Q34 12 38 26" fill="#fff0d0" opacity="0.7"/>
   <circle cx="8" cy="20" r="2" fill="#7a3a14"/><circle cx="40" cy="18" r="2.4" fill="#7a3a14"/><circle cx="24" cy="6" r="1.8" fill="#7a3a14"/>`);

// =====================================================================================
// ---------- Level 5, the dark hollow: torches, boulders, little moles, the cobra ----------
// =====================================================================================

// A soft round light (white in the middle, clear at the edge): cuts holes in the darkness.
save("spr_light", 128, 128, `<circle cx="64" cy="64" r="64" fill="url(#lg)"/>`,
  `<radialGradient id="lg"><stop offset="0" stop-color="#fff" stop-opacity="1"/><stop offset="0.45" stop-color="#fff" stop-opacity="0.75"/><stop offset="1" stop-color="#fff" stop-opacity="0"/></radialGradient>`);

// A wall torch: an iron bracket, a wooden stick and a flickering flame (3 frames).
function torch(f) {
  const fl = [[0, 0, 1], [-2, 2, 0.92], [2, -1, 1.06]][f];
  const [dx, dy, k] = fl;
  const fx = 12 + dx, top = 2 + dy;
  return `<path d="M5 44 L19 44 L17 50 L7 50 Z" fill="#4a4a52" stroke="#1a1a1e" stroke-width="1.5"/>
    <path d="M12 44 L12 50" stroke="#1a1a1e" stroke-width="1.2"/>
    <rect x="9.5" y="22" width="5" height="24" rx="2" fill="#8a5426" stroke="#3a1c08" stroke-width="1.4"/>
    <path d="M8 21 L16 21 L15 27 L9 27 Z" fill="#c8a070" stroke="#3a1c08" stroke-width="1.3"/>
    <path d="M${fx} ${top} Q${fx + 8 * k} ${top + 9} ${fx + 6} ${top + 15} Q${fx + 4} ${top + 20} 12 21 Q${fx - 5} ${top + 20} ${fx - 6} ${top + 14} Q${fx - 7 * k} ${top + 8} ${fx} ${top} Z" fill="#ff8a1a" stroke="#a03a06" stroke-width="1.2"/>
    <path d="M${fx} ${top + 7} Q${fx + 4} ${top + 12} ${fx + 2} ${top + 16} Q12 ${top + 19} ${fx - 2} ${top + 16} Q${fx - 4} ${top + 12} ${fx} ${top + 7} Z" fill="#ffe25a"/>
    <circle cx="${fx - 1}" cy="${top + 15}" r="2" fill="#fffbe0"/>`;
}
for (let f = 0; f < 3; f++) save("torch_" + f, 24, 52, torch(f));

// A rolling boulder (it spins in the game).
save("spr_boulder", 40, 40,
  `<circle cx="20" cy="20" r="18" fill="url(#cst)" stroke="${K.mortar}" stroke-width="2.4"/>
   <path d="M8 14 L15 18 L13 26 M24 6 L22 14 L30 18 M26 28 L31 32" stroke="${K.mortar}" stroke-width="1.8" fill="none" stroke-linecap="round"/>
   <ellipse cx="13" cy="11" rx="5" ry="3" fill="${K.rockLight}" opacity="0.7" transform="rotate(-30 13 11)"/>
   <circle cx="27" cy="25" r="2.5" fill="${K.rockDark}"/>`, caveGrad);

// The dark tunnel the boulders roll out of.
save("spr_tunnel_mouth", 80, 76,
  `<path d="M2 76 L4 40 Q8 6 40 4 Q72 6 76 40 L78 76 Z" fill="${K.rock}" stroke="${K.mortar}" stroke-width="2.5"/>
   <path d="M12 76 L13 44 Q16 16 40 14 Q64 16 67 44 L68 76 Z" fill="#120602"/>
   <path d="M18 76 L19 48 Q22 26 40 24 Q58 26 61 48 L62 76 Z" fill="#000"/>
   <g fill="url(#cst)" stroke="${K.mortar}" stroke-width="1.5"><ellipse cx="10" cy="30" rx="7" ry="6"/><ellipse cx="26" cy="10" rx="8" ry="6"/><ellipse cx="52" cy="9" rx="8" ry="6"/><ellipse cx="70" cy="28" rx="7" ry="6"/><ellipse cx="6" cy="58" rx="5" ry="7"/><ellipse cx="74" cy="58" rx="5" ry="7"/></g>`, caveGrad);

// The little moles: pop out of the ground, scurry about, dig back in (frames: walk A, walk B,
// popping out, digging in, just the mound).
const mound = (rx = 16) => `<ellipse cx="20" cy="33" rx="${rx}" ry="5" fill="#7a4420" stroke="${K.furLine}" stroke-width="1.8"/>
    <ellipse cx="16" cy="31" rx="${rx * 0.4}" ry="2" fill="#a86a3a"/><circle cx="8" cy="33" r="2" fill="#5a3014"/><circle cx="30" cy="32" r="1.8" fill="#5a3014"/>`;
function kin(f) {
  if (f === 4) return mound(15) + `<ellipse cx="20" cy="31" rx="6" ry="2" fill="#2a1408"/>`;
  const smallPaw = (x, y, r) => `<g transform="rotate(${r} ${x} ${y})"><ellipse cx="${x}" cy="${y}" rx="4.5" ry="3.2" fill="${K.pink}" stroke="${K.furLine}" stroke-width="1.3"/>
      <path d="M${x + 3} ${y - 2} l3 -1 M${x + 3.5} ${y} l3.5 0 M${x + 3} ${y + 2} l3 1" stroke="#fff4e8" stroke-width="1.3" stroke-linecap="round"/></g>`;
  const face = (by) => `<circle cx="25" cy="${by - 4}" r="1.6" fill="#120804"/><circle cx="25.5" cy="${by - 4.6}" r="0.6" fill="#fff"/>
      <ellipse cx="32" cy="${by - 1}" rx="5.5" ry="4" fill="${K.pink}" stroke="${K.furLine}" stroke-width="1.3"/>
      <circle cx="36" cy="${by - 1.5}" r="2.2" fill="${K.pinkDark}"/>
      <path d="M29 ${by + 1} l-6 -1 M29 ${by + 2.5} l-6 1.5" stroke="${K.furLine}" stroke-width="0.8"/>`;
  if (f === 2 || f === 3) {
    // Half out of the ground (2) or half in (3), throwing dirt.
    const by = f === 2 ? 22 : 27;
    const dirt = f === 2
      ? `<g fill="#9a5a2a" stroke="${K.furLine}" stroke-width="0.8"><circle cx="5" cy="18" r="2.4"/><circle cx="36" cy="14" r="2"/><circle cx="10" cy="10" r="1.6"/><circle cx="31" cy="22" r="1.8"/></g>`
      : `<g fill="#9a5a2a" stroke="${K.furLine}" stroke-width="0.8"><circle cx="4" cy="24" r="2.6"/><circle cx="35" cy="22" r="2.2"/><circle cx="8" cy="16" r="1.8"/></g>`;
    return `<ellipse cx="20" cy="${by + 6}" rx="12" ry="10" fill="url(#mf)" stroke="${K.furLine}" stroke-width="2"/>
      ${face(by + 2)}${smallPaw(10, by + 7, 200)}${smallPaw(30, by + 7, -20)}${mound(17)}${dirt}`;
  }
  const step = f === 0 ? -2 : 2;
  return `<ellipse cx="${13 + step}" cy="34" rx="4" ry="2.5" fill="${K.pink}" stroke="${K.furLine}" stroke-width="1.2"/>
    <ellipse cx="${25 - step}" cy="34" rx="4" ry="2.5" fill="${K.pink}" stroke="${K.furLine}" stroke-width="1.2"/>
    <path d="M6 27 q-5 1 -5 -3" stroke="${K.furLine}" stroke-width="1.8" fill="none"/>
    <ellipse cx="19" cy="25" rx="14" ry="9.5" fill="url(#mf)" stroke="${K.furLine}" stroke-width="2"/>
    <ellipse cx="21" cy="29" rx="7" ry="4" fill="#c89a78"/>
    ${face(25)}${smallPaw(31, 31 + step * 0.5, 10)}`;
}
for (let f = 0; f < 5; f++) save("kin_" + f, 40, 36, kin(f), moleDefs);
// A mole hole in the floor (where little moles keep coming from) and a crack in the roof (bats).
save("spr_molehole", 40, 12,
  `<ellipse cx="20" cy="6" rx="17" ry="5" fill="#7a4420" stroke="${K.furLine}" stroke-width="1.6"/><ellipse cx="20" cy="6" rx="10" ry="3" fill="#1a0a02"/>`);
save("spr_crevice", 36, 16,
  `<path d="M0 0 L36 0 L30 4 L24 3 L20 14 L15 4 L8 6 Z" fill="#100602" stroke="${K.mortar}" stroke-width="1.4" stroke-linejoin="round"/>
   <circle cx="16" cy="5" r="1.2" fill="#ffb02a"/><circle cx="21" cy="5" r="1.2" fill="#ffb02a"/>`);

// ---------- Hissandra, the cobra queen ----------
// Frames: sway A, sway B (tongue out), tail raised, tail slam, rearing to spit, dizzy.
// 300 x 152, origin (110, 92): the coil sits on the floor, the tail slams far in front.
const CB = { scale: "#d8a640", light: "#f6d77e", band: "#5e3208", line: "#241002", belly: "#fff2c0", hood: "#c48a2c", hoodIn: "#f0c060", eye: "#ff3a2a" };
const cobraDefs = `<radialGradient id="ch" cx="0.4" cy="0.35" r="0.7"><stop offset="0" stop-color="${CB.light}"/><stop offset="1" stop-color="${CB.scale}"/></radialGradient>`;
const body = (d, w, bands = true) => `
  <path d="${d}" fill="none" stroke="${CB.line}" stroke-width="${w + 5}" stroke-linecap="round" stroke-linejoin="round"/>
  <path d="${d}" fill="none" stroke="${CB.scale}" stroke-width="${w}" stroke-linecap="round" stroke-linejoin="round"/>
  ${bands ? `<path d="${d}" fill="none" stroke="${CB.band}" stroke-width="${w}" stroke-dasharray="5 13" stroke-linejoin="round" opacity="0.85"/>` : ""}
  <path d="${d}" fill="none" stroke="${CB.light}" stroke-width="${Math.max(2, w * 0.22)}" stroke-linecap="round" opacity="0.75" transform="translate(-1,-3)"/>`;
const hood = (cx, cy, k = 1) => `
  <path d="M${cx} ${cy - 28 * k} Q${cx + 26 * k} ${cy - 26 * k} ${cx + 28 * k} ${cy} Q${cx + 26 * k} ${cy + 26 * k} ${cx} ${cy + 32 * k} Q${cx - 26 * k} ${cy + 26 * k} ${cx - 28 * k} ${cy} Q${cx - 26 * k} ${cy - 26 * k} ${cx} ${cy - 28 * k} Z" fill="${CB.hood}" stroke="${CB.line}" stroke-width="3"/>
  <path d="M${cx} ${cy - 20 * k} Q${cx + 18 * k} ${cy - 18 * k} ${cx + 20 * k} ${cy} Q${cx + 18 * k} ${cy + 18 * k} ${cx} ${cy + 23 * k} Q${cx - 18 * k} ${cy + 18 * k} ${cx - 20 * k} ${cy} Q${cx - 18 * k} ${cy - 18 * k} ${cx} ${cy - 20 * k} Z" fill="${CB.hoodIn}"/>
  <g fill="none" stroke="${CB.band}" stroke-width="3"><circle cx="${cx - 11 * k}" cy="${cy}" r="${6 * k}"/><circle cx="${cx + 11 * k}" cy="${cy}" r="${6 * k}"/><path d="M${cx - 6 * k} ${cy + 4 * k} Q${cx} ${cy + 9 * k} ${cx + 6 * k} ${cy + 4 * k}"/></g>
  <circle cx="${cx - 11 * k}" cy="${cy}" r="${2.2 * k}" fill="${CB.band}"/><circle cx="${cx + 11 * k}" cy="${cy}" r="${2.2 * k}" fill="${CB.band}"/>`;
function cobraHead(cx, cy, o = {}) {
  const eye = o.dizzy
    ? `<path d="M${cx + 2} ${cy - 5} a3 3 0 1 1 3 3 a2 2 0 1 1 -2 -2" stroke="${CB.line}" stroke-width="1.6" fill="none"/>`
    : `<ellipse cx="${cx + 5}" cy="${cy - 5}" rx="4.5" ry="4" fill="${CB.eye}" stroke="${CB.line}" stroke-width="1.5"/>
       <ellipse cx="${cx + 6}" cy="${cy - 5}" rx="1.1" ry="3.2" fill="#120400"/>
       <path d="M${cx - 2} ${cy - 11} L${cx + 11} ${cy - 8}" stroke="${CB.line}" stroke-width="2.6" stroke-linecap="round"/>`;
  const tongue = o.tongue ? `<path d="M${cx + 24} ${cy + 3} l10 0 l5 -4 M${cx + 34} ${cy + 3} l5 4" stroke="#e02040" stroke-width="2" fill="none" stroke-linecap="round"/>` : "";
  if (o.open) {
    // Jaws wide open: the venom is coming.
    return `<path d="M${cx - 18} ${cy + 4} Q${cx} ${cy + 22} ${cx + 22} ${cy + 16} L${cx + 20} ${cy + 10} Q${cx} ${cy + 12} ${cx - 10} ${cy + 2} Z" fill="${CB.belly}" stroke="${CB.line}" stroke-width="2.4"/>
      <path d="M${cx - 12} ${cy + 2} Q${cx + 4} ${cy + 12} ${cx + 20} ${cy + 10} Q${cx + 12} ${cy + 2} ${cx - 2} ${cy} Z" fill="#c8304a"/>
      <path d="M${cx - 20} ${cy + 4} Q${cx - 20} ${cy - 12} ${cx} ${cy - 15} Q${cx + 20} ${cy - 16} ${cx + 27} ${cy - 6} Q${cx + 26} ${cy} ${cx + 18} ${cy + 1} Q${cx} ${cy + 1} ${cx - 20} ${cy + 4} Z" fill="url(#ch)" stroke="${CB.line}" stroke-width="2.6"/>
      <path d="M${cx + 14} ${cy + 1} l2 7 l2 -7 M${cx + 4} ${cy + 1} l1.6 5 l1.6 -5" fill="#fff" stroke="${CB.line}" stroke-width="0.8"/>
      ${eye}<circle cx="${cx + 22}" cy="${cy - 7}" r="1.3" fill="${CB.line}"/>`;
  }
  return `<path d="M${cx - 20} ${cy + 2} Q${cx - 19} ${cy - 13} ${cx} ${cy - 14} Q${cx + 20} ${cy - 13} ${cx + 26} ${cy - 2} Q${cx + 26} ${cy + 5} ${cx + 16} ${cy + 7} L${cx - 14} ${cy + 9} Q${cx - 20} ${cy + 7} ${cx - 20} ${cy + 2} Z" fill="url(#ch)" stroke="${CB.line}" stroke-width="2.6"/>
    <path d="M${cx - 12} ${cy + 6} Q${cx + 4} ${cy + 3} ${cx + 22} ${cy + 3}" stroke="${CB.line}" stroke-width="1.6" fill="none"/>
    ${eye}<circle cx="${cx + 21}" cy="${cy - 4}" r="1.3" fill="${CB.line}"/>${tongue}`;
}
function cobra(f) {
  const coil = body("M68 126 Q68 110 110 110 Q152 110 152 126 Q152 140 110 138 Q68 138 68 126", 24) +
               body("M80 112 Q84 98 110 98 Q136 98 140 110", 22);
  let tail, neck, head, hd, extra = "";
  const s = f === 1 ? 4 : f === 0 ? -3 : 0;
  if (f === 2) {
    tail = body("M72 122 Q30 112 32 62 Q36 22 78 12", 15) + body("M78 12 Q98 6 108 18", 8, false);
    extra = `<path d="M18 40 q-8 10 -4 22 M10 30 q-10 14 -6 30" stroke="#fff0c0" stroke-width="2" fill="none" opacity="0.7"/>`;
    hd = [-8, 0];
  } else if (f === 3) {
    tail = body("M146 140 Q190 148 232 142", 15) + body("M232 142 Q262 137 288 142", 8, false);
    extra = `<g fill="#e8c8a0" opacity="0.9" stroke="#7a3a14" stroke-width="1.2"><circle cx="250" cy="138" r="7"/><circle cx="268" cy="134" r="8"/><circle cx="286" cy="138" r="7"/><circle cx="236" cy="142" r="5"/></g>
      <path d="M250 122 l-4 -10 M268 118 l0 -12 M286 122 l4 -10" stroke="#fff0c0" stroke-width="2.4" stroke-linecap="round"/>`;
    hd = [8, 4];
  } else {
    tail = body("M72 138 Q52 146 36 141", 15) + body("M36 141 Q22 137 16 126", 8, false);
    hd = [s, 0];
  }
  const [dx, dy] = hd;
  if (f === 4) {
    neck = body(`M138 112 Q158 80 132 58 Q114 42 128 22`, 20);
    return tail + coil + hood(124, 40, 1.22) + neck + cobraHead(144, 12, { open: true }) +
      `<g fill="#8cff3a" stroke="#1e5a06" stroke-width="1.2"><circle cx="176" cy="22" r="3.5"/><circle cx="186" cy="16" r="2.4"/><circle cx="170" cy="32" r="2"/></g>`;
  }
  if (f === 5) {
    neck = body(`M138 112 Q164 98 156 78 Q148 64 162 60`, 20);
    return tail + coil + hood(150, 76, 0.85) + neck + cobraHead(172, 64, { dizzy: true }) +
      `<path d="M140 30 l2 5 5 1 -4 3 1 5 -4 -3 -4 3 1 -5 -4 -3 5 -1 Z M184 22 l2 5 5 1 -4 3 1 5 -4 -3 -4 3 1 -5 -4 -3 5 -1 Z" fill="#ffe04a" stroke="${CB.line}" stroke-width="1"/>`;
  }
  neck = body(`M138 112 Q152 86 ${126 + dx} 70 Q${108 + dx} 58 ${120 + dx} ${42 + dy}`, 20);
  head = cobraHead(132 + dx, 32 + dy, { tongue: f === 1 });
  return extra + tail + coil + hood(118 + dx, 50 + dy) + neck + head;
}
for (let f = 0; f < 6; f++) save("cobra_" + f, 300, 152, cobra(f), cobraDefs);

// Her venom: a glob that flies in an arc, and the puddle it leaves on the floor.
save("spr_venom", 20, 22,
  `<path d="M10 2 Q17 9 16.5 14 A6.5 6.5 0 1 1 3.5 14 Q3 9 10 2 Z" fill="#8cff3a" stroke="#1e5a06" stroke-width="1.8"/>
   <ellipse cx="7.5" cy="13" rx="2" ry="3" fill="#e8ffc0" opacity="0.85"/>`);
save("spr_puddle", 52, 14,
  `<path d="M3 10 Q4 4 14 4 Q20 1 28 3 Q40 1 48 6 Q52 10 46 12 L8 12 Q2 12 3 10 Z" fill="#7aea2a" stroke="#1e5a06" stroke-width="1.6"/>
   <ellipse cx="18" cy="6" rx="6" ry="1.6" fill="#d8ffa0" opacity="0.8"/>
   <circle cx="34" cy="5" r="2.4" fill="#b8ff6a" stroke="#1e5a06" stroke-width="1"/><circle cx="42" cy="7" r="1.6" fill="#b8ff6a" stroke="#1e5a06" stroke-width="0.8"/>`);

// =====================================================================================
// ---------- Level 6, the bone pit: purple-brown rock, skeletons ----------
// =====================================================================================
// The cave tiles recoloured from orange-brown to purple-brown, with fossils in the rock.
const KP = {
  [K.rock]: "#7c5468", [K.rockLight]: "#bc90a8", [K.rockDark]: "#422438", [K.mortar]: "#1e0c1a", [K.deep]: "#2e1628",
  [K.crust]: "#a47896", [K.crustLight]: "#e2c4d6", [K.crustDark]: "#6a3c5e", [K.crustLine]: "#220c1c",
  "#e8b080": "#c8a0c0", "#7a3a14": "#4a2244", "#3a1806": "#200c1c", "#1e0c02": "#12060f", "#fff0c0": "#f4e0f0",
  "#fff0d0": "#f4e4f2",
};
const recolor = (s) => Object.entries(KP).reduce((t, [a, b]) => t.split(a).join(b), s);
const fossil = `<g stroke="#2a1424" stroke-width="1" fill="#d8ccb0" opacity="0.85">
    <path d="M6 22 L20 14 M5 20 a2 2 0 1 0 2 3 M19 12 a2 2 0 1 1 2 3" stroke-width="2.6" stroke="#d8ccb0" fill="none"/>
    <circle cx="25" cy="25" r="3.2"/><circle cx="24" cy="25" r="0.9" fill="#2a1424"/></g>`;
const boneTiles = caveTiles.map(recolor);
boneTiles[3] += fossil;
save("spr_tiles_bone", 32 * boneTiles.length, 32,
  boneTiles.map((t, i) => `<g transform="translate(${i * 32},0)" clip-path="url(#cell)">${t}</g>`).join(""),
  stoneGrad + recolor(caveGrad) + `<clipPath id="cell"><rect x="0" y="0" width="32" height="32"/></clipPath>`);

// Floor decorations: violet crystals (they glow) and little piles of bones.
save("spr_crystal_violet", 24, 24,
  `<path d="M4 24 L6 12 L9 8 L12 24 Z" fill="#b46aff" stroke="#2a0a40" stroke-width="1.3"/>
   <path d="M9 24 L11 6 L14 1 L17 7 L17 24 Z" fill="#dcb0ff" stroke="#2a0a40" stroke-width="1.3"/>
   <path d="M15 24 L18 12 L21 15 L21 24 Z" fill="#8a3ae0" stroke="#2a0a40" stroke-width="1.3"/>
   <path d="M12 8 L13 18" stroke="#f6e8ff" stroke-width="1.6" opacity="0.9"/>`);
const B = { bone: "#efe4c8", shade: "#c9b892", line: "#2a1824", glow: "#d070ff" };
const bone = (d, w) => `<path d="${d}" fill="none" stroke="${B.line}" stroke-width="${w + 3}" stroke-linecap="round" stroke-linejoin="round"/>
  <path d="${d}" fill="none" stroke="${B.bone}" stroke-width="${w}" stroke-linecap="round" stroke-linejoin="round"/>`;
const glowEye = (x, y, r = 2.6) => `<circle cx="${x}" cy="${y}" r="${r * 2.2}" fill="${B.glow}" opacity="0.35"/><circle cx="${x}" cy="${y}" r="${r}" fill="#f4c8ff"/>`;
save("spr_bones", 34, 20,
  bone("M4 17 L22 12", 3.5) + bone("M10 9 L28 17", 3.5) +
  `<path d="M14 18 Q12 6 20 5 Q28 5 27 14 L25 18 Z" fill="${B.bone}" stroke="${B.line}" stroke-width="1.4"/>
   <circle cx="18" cy="11" r="2.2" fill="${B.line}"/><circle cx="23.5" cy="11" r="2.2" fill="${B.line}"/>
   <path d="M18 17 v-2 M21 17 v-2 M24 17 v-2" stroke="${B.line}" stroke-width="1"/>`);

// ---------- Little skeletons with swords (frames: walk A, walk B, sword up, slash) ----------
// 76 x 52, origin (26, 34): feet at the bottom, the sword reaches far ahead when it slashes.
function skel(f) {
  const step = f === 0 ? -4 : f === 1 ? 4 : 0;
  const legs = bone(`M24 38 L${22 + step} 50`, 3.4) + bone(`M28 38 L${30 - step} 50`, 3.4) +
    `<path d="M${18 + step} 50 h6 M${28 - step} 50 h6" stroke="${B.line}" stroke-width="2.6" stroke-linecap="round"/>`;
  const ribs = `<g>${[25, 29, 33].map((y) => bone(`M19 ${y} Q26 ${y - 3} 33 ${y}`, 2.2)).join("")}</g>`;
  const spine = bone("M26 22 L26 39", 3.2) + `<path d="M20 38 Q26 35 32 38 L30 42 L22 42 Z" fill="${B.bone}" stroke="${B.line}" stroke-width="1.4"/>`;
  const skull = `<path d="M17 15 Q16 3 27 3 Q38 4 37 15 Q36 21 32 22 L22 22 Q17 21 17 15 Z" fill="${B.bone}" stroke="${B.line}" stroke-width="1.8"/>
    <path d="M17 9 Q27 0 37 9 L38 11 L16 11 Z" fill="#7a6a78" stroke="${B.line}" stroke-width="1.6"/>
    <circle cx="25" cy="14" r="3.4" fill="${B.line}"/><circle cx="33" cy="14" r="3" fill="${B.line}"/>
    ${glowEye(25.5, 14, 1.4)}${glowEye(33, 14, 1.3)}
    <path d="M23 22 v-3 M26 22 v-3 M29 22 v-3 M32 22 v-3" stroke="${B.line}" stroke-width="1"/>`;
  const blade = (x1, y1, x2, y2) => `<path d="M${x1} ${y1} L${x2} ${y2}" stroke="${B.line}" stroke-width="5.2" stroke-linecap="round"/>
    <path d="M${x1} ${y1} L${x2} ${y2}" stroke="#d6dbe6" stroke-width="3" stroke-linecap="round"/>`;
  const hilt = (x, y, rot) => `<g transform="rotate(${rot} ${x} ${y})"><rect x="${x - 1.6}" y="${y - 6}" width="3.2" height="12" rx="1" fill="#8a5a2a" stroke="${B.line}" stroke-width="1"/></g>`;
  let arms, sword, extra = "";
  if (f === 2) {
    // Sword raised high behind the head: the slash is coming.
    arms = bone("M24 24 L18 30", 2.4) + bone("M28 24 L22 12 L18 6", 2.4);
    sword = blade(16, 4, 4, -2 + 6) + hilt(17, 5, 60);
    sword = blade(17, 5, 2, 22) + hilt(17, 5, 30);
  } else if (f === 3) {
    // The slash: arm straight out, blade far ahead, a swoosh.
    arms = bone("M24 24 L18 30", 2.4) + bone("M28 24 L38 26 L44 26", 2.4);
    sword = blade(46, 26, 74, 26) + hilt(45, 26, 90);
    extra = `<path d="M44 8 Q72 10 74 24" stroke="#f4e8ff" stroke-width="3" fill="none" opacity="0.7" stroke-linecap="round"/>
      <path d="M48 14 Q66 15 68 23" stroke="#f4e8ff" stroke-width="2" fill="none" opacity="0.5" stroke-linecap="round"/>`;
  } else {
    arms = bone("M24 24 L18 31", 2.4) + bone(`M28 24 L36 ${30 + step * 0.3} L40 ${30 + step * 0.3}`, 2.4);
    sword = blade(42, 28 + step * 0.3, 52, 12 + step * 0.3) + hilt(41, 30 + step * 0.3, 32);
  }
  return extra + (f === 2 ? sword : "") + legs + spine + ribs + skull + arms + (f === 2 ? "" : sword);
}
for (let f = 0; f < 4; f++) save("skel_" + f, 76, 52, skel(f));

// ---------- Skeleton birds (frames: wings up, wings down, diving) ----------
// 56 x 40, origin (26, 20). The bird faces right.
function bonebird(f) {
  const skull = (x, y, rot) => `<g transform="rotate(${rot} ${x} ${y})">
    <path d="M${x - 7} ${y} Q${x - 6} ${y - 8} ${x + 1} ${y - 8} Q${x + 7} ${y - 7} ${x + 8} ${y - 3} L${x + 22} ${y + 1} L${x + 7} ${y + 4} Q${x - 4} ${y + 6} ${x - 7} ${y} Z" fill="${B.bone}" stroke="${B.line}" stroke-width="1.6" stroke-linejoin="round"/>
    <circle cx="${x + 1}" cy="${y - 2}" r="3" fill="${B.line}"/>${glowEye(x + 1.5, y - 2, 1.4)}</g>`;
  const body = bone("M10 22 L16 21", 2.6) + bone("M4 25 L10 22 M6 28 L10 22", 1.8) +
    `<ellipse cx="22" cy="21" rx="8" ry="6" fill="none" stroke="${B.line}" stroke-width="3.6"/><ellipse cx="22" cy="21" rx="8" ry="6" fill="none" stroke="${B.bone}" stroke-width="1.8"/>
     <path d="M17 17 v8 M21 15.5 v11 M25 16 v10" stroke="${B.bone}" stroke-width="1.4"/>` + bone("M29 19 Q32 15 34 14", 2.4);
  const legs = bone("M20 26 L18 33 L15 35 M18 33 L20 36", 1.6);
  if (f === 2) {
    // Wings folded back, beak first: the dive.
    return bone("M22 18 L10 10 L2 12", 2.6) + bone("M10 10 L4 6", 1.8) + body + legs + skull(38, 16, 35);
  }
  const up = f === 0;
  const wing = up
    ? bone("M22 18 L18 6 L8 1", 2.8) + bone("M18 6 L12 4 M8 1 L2 2 M8 1 L4 6", 1.6)
    : bone("M22 20 L16 30 L6 37", 2.8) + bone("M16 30 L10 31 M6 37 L1 35 M6 37 L4 32", 1.6);
  return wing + body + legs + skull(38, 13, 0);
}
for (let f = 0; f < 3; f++) save("bonebird_" + f, 56, 40, bonebird(f));

// ---------- Rex Bonejaw, the dinosaur skeleton ----------
// Frames: walk A, walk B, crouch (before a long jump), leap, tail whip, roar.
// 280 x 160, origin (140, 110): feet on the floor at the bottom, facing right.
function dino(f) {
  const crouch = f === 2, leap = f === 3, whip = f === 4, roar = f === 5;
  const dy = crouch ? 16 : leap ? -6 : whip ? 6 : 0;
  const hip = [118, 86 + dy];
  // Legs: hip -> knee -> ankle -> toes; the back leg is darker and drawn first.
  const legPose = (front) => {
    if (leap) return front ? [[142, 108], [152, 126], [172, 124]] : [[132, 112], [138, 132], [158, 130]];
    if (crouch) return front ? [[150, 124], [128, 148], [154, 156]] : [[134, 126], [110, 148], [134, 156]];
    const s = (f === 1 ? 1 : -1) * (front ? 1 : -1);
    return [[128 + s * 12, 118], [118 + s * 14, 146], [142 + s * 14, 156]];
  };
  const leg = (front) => {
    const [k, a, t] = legPose(front);
    const g = bone(`M${hip[0]} ${hip[1]} L${k[0]} ${k[1]}`, 11) + bone(`M${k[0]} ${k[1]} L${a[0]} ${a[1]}`, 8) + bone(`M${a[0]} ${a[1]} L${t[0]} ${t[1]}`, 6) +
      `<path d="M${t[0]} ${t[1]} l7 -2 M${t[0] - 2} ${t[1]} l6 3" stroke="${B.line}" stroke-width="3" stroke-linecap="round"/>`;
    return front ? g : `<g opacity="0.75">${g}</g>`;
  };
  // The tail: swaying behind, or lashing low and straight in the tail whip.
  const tailD = whip ? `M${hip[0]} ${hip[1] - 2} Q80 ${110} 40 ${112} Q18 ${113} 2 ${106}`
    : leap ? `M${hip[0]} ${hip[1] - 4} Q80 ${66} 44 ${60} Q22 56 6 46`
    : `M${hip[0]} ${hip[1] - 4} Q80 ${72 + dy} 48 ${76 + dy} Q24 ${80 + dy} 6 ${72 + dy}`;
  const tail = bone(tailD, 10) + `<path d="${tailD}" fill="none" stroke="${B.line}" stroke-width="10" stroke-dasharray="2 9" opacity="0.55"/>`;
  const whipLines = whip ? `<g stroke="#f0e0ff" stroke-width="3" fill="none" opacity="0.65" stroke-linecap="round">
      <path d="M20 84 Q8 96 6 120"/><path d="M44 88 Q30 100 30 124"/><path d="M70 92 Q58 104 58 126"/></g>
      <g fill="#c8a0c0" opacity="0.8"><circle cx="16" cy="150" r="6"/><circle cx="40" cy="154" r="5"/><circle cx="64" cy="152" r="5"/></g>` : "";
  // Back, neck, ribs and the little arms.
  const lean = whip ? 8 : roar ? -8 : 0;
  const back = `M${hip[0]} ${hip[1] - 6} Q150 ${62 + dy + lean * 0.5} 186 ${58 + dy + lean}`;
  const neck = `M186 ${58 + dy + lean} Q200 ${50 + dy + lean} 206 ${46 + dy + lean}`;
  let ribs = "";
  for (let i = 0; i < 5; i++) {
    const x = 134 + i * 11;
    const y = 70 + dy - i * 2 + lean * (i / 5);
    ribs += bone(`M${x} ${y} Q${x + 12} ${y + 22} ${x + 2} ${y + 40 - i * 3}`, 4.5);
  }
  const pelvis = `<path d="M100 ${hip[1] - 10} Q118 ${hip[1] - 22} 136 ${hip[1] - 10} L128 ${hip[1] + 8} L106 ${hip[1] + 8} Z" fill="${B.bone}" stroke="${B.line}" stroke-width="2.4"/>
    <circle cx="118" cy="${hip[1] - 2}" r="5" fill="${B.line}"/>`;
  const arms = bone(`M184 ${84 + dy + lean} L194 ${96 + dy + lean} L201 ${93 + dy + lean}`, 4);
  // The skull: jaw shut, or open wide in the roar.
  const hx = 0, hy = dy + lean + (roar ? -10 : 0);
  const jawRot = roar ? 26 : crouch ? 6 : 0;
  const skull = `<g transform="translate(${hx} ${hy})">
    <g transform="rotate(${jawRot} 208 56)">
      <path d="M206 56 L266 54 Q262 68 236 70 Q214 70 206 62 Z" fill="${B.shade}" stroke="${B.line}" stroke-width="2.6"/>
      <path d="M214 56 l3 -6 l3 6 M226 56 l3 -6 l3 6 M238 56 l3 -6 l3 6 M250 55 l3 -6 l3 6" fill="#fff" stroke="${B.line}" stroke-width="1"/>
    </g>
    <path d="M200 42 Q204 22 232 24 Q262 26 272 44 L270 54 L206 57 Q198 52 200 42 Z" fill="${B.bone}" stroke="${B.line}" stroke-width="2.8"/>
    <path d="M212 56 l3 7 l3 -7 M224 56 l3 7 l3 -7 M236 56 l3 7 l3 -7 M248 55 l3 7 l3 -7 M260 54 l3 6 l3 -6" fill="#fff" stroke="${B.line}" stroke-width="1"/>
    <path d="M208 30 Q216 22 230 24" stroke="${B.shade}" stroke-width="3" fill="none"/>
    <ellipse cx="222" cy="38" rx="8" ry="7" fill="${B.line}"/>${glowEye(223, 38, 3)}
    <ellipse cx="258" cy="36" rx="3.5" ry="2.5" fill="${B.line}"/>
    <path d="M238 30 L244 42" stroke="${B.line}" stroke-width="1.6"/></g>`;
  const dust = crouch ? `<g fill="#c8a0c0" opacity="0.8"><circle cx="104" cy="154" r="7"/><circle cx="168" cy="154" r="7"/></g>` : "";
  return whipLines + leg(false) + tail + pelvis + ribs + bone(back, 10) + bone(neck, 8) + arms + leg(true) + skull + dust;
}
for (let f = 0; f < 6; f++) save("dino_" + f, 280, 160, dino(f));

// =====================================================================================
// ---------- Level 7, the sunken grotto: sand, blue-grey rock, water ----------
// =====================================================================================
const KS = {
  [K.rock]: "#5e7c8c", [K.rockLight]: "#a2c6d2", [K.rockDark]: "#2e4654", [K.mortar]: "#122028", [K.deep]: "#1a2c36",
  [K.crust]: "#e4c884", [K.crustLight]: "#fff2c4", [K.crustDark]: "#b8964e", [K.crustLine]: "#4a3410",
  "#e8b080": "#b8d0d8", "#7a3a14": "#2e4654", "#3a1806": "#102028", "#1e0c02": "#0a161c", "#fff0c0": "#fff8e0",
  "#fff0d0": "#f0fbff",
};
const recolorSea = (s) => Object.entries(KS).reduce((t, [a, b]) => t.split(a).join(b), s);
const sandTiles = caveTiles.map(recolorSea);
// Sea urchins instead of stone spikes.
sandTiles[9] = `<g stroke="#140a24" stroke-width="1.6">${[6, 16, 26].map((x) => `<path d="M${x} 32 L${x} 14 M${x} 32 L${x - 8} 18 M${x} 32 L${x + 8} 18 M${x} 32 L${x - 10} 26 M${x} 32 L${x + 10} 26" />`).join("")}</g>
  ${[6, 16, 26].map((x) => `<ellipse cx="${x}" cy="29" rx="6" ry="5" fill="#3a2060" stroke="#140a24" stroke-width="1.4"/><circle cx="${x - 2}" cy="27" r="1.5" fill="#a080e0"/>`).join("")}`;
save("spr_tiles_sand", 32 * sandTiles.length, 32,
  sandTiles.map((t, i) => `<g transform="translate(${i * 32},0)" clip-path="url(#cell)">${t}</g>`).join(""),
  stoneGrad + recolorSea(caveGrad) + `<clipPath id="cell"><rect x="0" y="0" width="32" height="32"/></clipPath>`);
save("spr_shell", 20, 14,
  `<path d="M2 13 Q2 3 10 2 Q18 3 18 13 Z" fill="#f4b8a8" stroke="#6a3030" stroke-width="1.4"/>
   <path d="M10 13 L10 3 M6 13 L5 5 M14 13 L15 5" stroke="#c87868" stroke-width="1.2"/><rect x="7" y="11" width="6" height="3" rx="1" fill="#e89888" stroke="#6a3030" stroke-width="1"/>`);
save("spr_weed", 18, 34,
  `<path d="M5 34 Q1 24 6 16 Q11 8 6 1" stroke="#1e6a52" stroke-width="5" fill="none" stroke-linecap="round"/>
   <path d="M5 34 Q1 24 6 16 Q11 8 6 1" stroke="#3aa880" stroke-width="2.6" fill="none" stroke-linecap="round"/>
   <path d="M11 34 Q16 26 12 19 Q9 13 13 8" stroke="#1e6a52" stroke-width="4.4" fill="none" stroke-linecap="round"/>
   <path d="M11 34 Q16 26 12 19 Q9 13 13 8" stroke="#52c494" stroke-width="2.2" fill="none" stroke-linecap="round"/>`);

// ---------- Piranhas (frames: leaping, biting, just the fin above the water) ----------
// 40 x 32, origin (20, 16), facing right.
function piranha(f) {
  if (f === 2) return `<path d="M12 18 Q20 4 28 18 Z" fill="#c03040" stroke="#3a0a14" stroke-width="1.8"/>
    <path d="M6 19 Q20 15 34 19" stroke="#bfefff" stroke-width="2" fill="none" opacity="0.8"/>`;
  const open = f === 1;
  const jaw = open
    ? `<path d="M26 18 L38 24 L24 24 Z" fill="#7a1420" stroke="#3a0a14" stroke-width="1.4"/><path d="M28 19 l2 3 l2 -3 M31 21 l2 3 l2 -3" fill="#fff" stroke="#3a0a14" stroke-width="0.7"/>`
    : "";
  return `<path d="M8 16 L1 8 L2 24 Z" fill="#8a2030" stroke="#3a0a14" stroke-width="1.6" stroke-linejoin="round"/>
    <path d="M14 8 Q18 1 24 6" fill="#8a2030" stroke="#3a0a14" stroke-width="1.6"/>
    <path d="M7 16 Q10 5 24 5 Q36 7 38 ${open ? 14 : 17} L24 ${open ? 18 : 19} Q32 ${open ? 18 : 21} 36 21 Q30 27 20 27 Q10 27 7 16 Z" fill="#c43c4c" stroke="#3a0a14" stroke-width="2"/>
    <path d="M10 18 Q18 25 30 22" fill="#f08a5a" opacity="0.85"/>
    ${jaw}
    <circle cx="28" cy="11" r="3.2" fill="#fff4c0" stroke="#3a0a14" stroke-width="1.2"/><circle cx="29" cy="11" r="1.4" fill="#140406"/>
    <path d="M24 7 L31 9" stroke="#3a0a14" stroke-width="1.8" stroke-linecap="round"/>
    ${open ? "" : `<path d="M27 19 l2 3 l2 -3 M31 19 l1.6 2.6 l1.6 -2.6" fill="#fff" stroke="#3a0a14" stroke-width="0.7"/>`}`;
}
for (let f = 0; f < 3; f++) save("piranha_" + f, 40, 32, piranha(f));

// ---------- The banknote the crab throws like a boomerang ----------
save("spr_banknote", 36, 20,
  `<rect x="1.5" y="1.5" width="33" height="17" rx="2" fill="#8ed08a" stroke="#1e4a1c" stroke-width="1.6"/>
   <rect x="4" y="4" width="28" height="12" rx="1" fill="none" stroke="#3a8a3a" stroke-width="1"/>
   <circle cx="18" cy="10" r="4.6" fill="#d8f4c8" stroke="#1e4a1c" stroke-width="1.2"/>
   <path d="M15 11 q3 -5 6 0 M14 9 l-2 -2 M22 9 l2 -2" stroke="#c03030" stroke-width="1.3" fill="none"/>
   <path d="M6 7 h4 M6 10 h3 M26 10 h4 M27 13 h3" stroke="#1e4a1c" stroke-width="1.2"/>`);

// ---------- Baron Clawbucks, the giant red crab ----------
// Frames: idle A, idle B, claw up with a banknote, throw, claw snap, claws up, claws smash, dizzy.
// 300 x 180, origin (150, 138): legs on the floor at the bottom; the big claw is on the right.
const CR = { red: "#e0402e", light: "#ff8a5a", dark: "#8a1c14", line: "#3a0a06", belly: "#ffd0a0" };
const crabDefs = `<radialGradient id="cs" cx="0.45" cy="0.35" r="0.7"><stop offset="0" stop-color="${CR.light}"/><stop offset="0.6" stop-color="${CR.red}"/><stop offset="1" stop-color="${CR.dark}"/></radialGradient>`;
function crabClaw(x, y, rot, open, big) {
  const k = big ? 1.25 : 1;
  const gap = open ? 16 : 3;
  return `<g transform="translate(${x} ${y}) rotate(${rot}) scale(${k})">
    <path d="M-6 0 Q10 -24 34 -${12 + gap / 2} Q40 -8 32 -4 Q20 -6 14 0 Z" fill="url(#cs)" stroke="${CR.line}" stroke-width="2.4" stroke-linejoin="round"/>
    <path d="M-6 0 Q10 ${18} 30 ${8 + gap / 2} Q36 4 28 2 Q18 4 14 0 Z" fill="url(#cs)" stroke="${CR.line}" stroke-width="2.4" stroke-linejoin="round"/>
    <path d="M20 -10 l3 3 M24 -9 l3 3 M20 6 l3 -3 M24 5 l3 -3" stroke="${CR.line}" stroke-width="1.4"/>
    <ellipse cx="-4" cy="0" rx="14" ry="12" fill="url(#cs)" stroke="${CR.line}" stroke-width="2.4"/>
    <ellipse cx="-8" cy="-4" rx="5" ry="3" fill="${CR.light}" opacity="0.7"/></g>`;
}
const crabArm = (x1, y1, x2, y2) => `<path d="M${x1} ${y1} L${x2} ${y2}" stroke="${CR.line}" stroke-width="13" stroke-linecap="round"/><path d="M${x1} ${y1} L${x2} ${y2}" stroke="${CR.red}" stroke-width="9" stroke-linecap="round"/>`;
function crab(f) {
  const step = f === 1 ? 4 : 0;
  const squash = f === 6 ? 8 : 0;
  const cy = 86 + squash;
  // Legs: four a side, jointed.
  let legs = "";
  for (let i = 0; i < 4; i++) {
    const s = (i % 2 ? step : -step);
    const lx = 96 - i * 10, rx = 164 + i * 10;
    legs += `<path d="M${lx} ${cy + 10} L${lx - 26 - i * 6} ${cy + 2 + s} L${lx - 34 - i * 8} 148" stroke="${CR.line}" stroke-width="8" fill="none" stroke-linejoin="round" stroke-linecap="round"/>
      <path d="M${lx} ${cy + 10} L${lx - 26 - i * 6} ${cy + 2 + s} L${lx - 34 - i * 8} 148" stroke="${CR.dark}" stroke-width="4.5" fill="none" stroke-linejoin="round" stroke-linecap="round"/>
      <path d="M${rx} ${cy + 10} L${rx + 26 + i * 6} ${cy + 2 - s} L${rx + 34 + i * 8} 148" stroke="${CR.line}" stroke-width="8" fill="none" stroke-linejoin="round" stroke-linecap="round"/>
      <path d="M${rx} ${cy + 10} L${rx + 26 + i * 6} ${cy + 2 - s} L${rx + 34 + i * 8} 148" stroke="${CR.dark}" stroke-width="4.5" fill="none" stroke-linejoin="round" stroke-linecap="round"/>`;
  }
  const shell = `<path d="M70 ${cy} Q74 ${cy - 46} 130 ${cy - 50} Q186 ${cy - 46} 190 ${cy} Q186 ${cy + 26} 130 ${cy + 28} Q74 ${cy + 26} 70 ${cy} Z" fill="url(#cs)" stroke="${CR.line}" stroke-width="3"/>
    <path d="M84 ${cy + 8} Q130 ${cy + 26} 176 ${cy + 8}" stroke="${CR.dark}" stroke-width="2.4" fill="none"/>
    <path d="M90 ${cy - 26} Q130 ${cy - 44} 170 ${cy - 26}" stroke="${CR.light}" stroke-width="4" fill="none" opacity="0.7"/>
    <g fill="${CR.dark}"><circle cx="100" cy="${cy - 12}" r="3"/><circle cx="160" cy="${cy - 12}" r="3"/><circle cx="130" cy="${cy - 24}" r="3.4"/><circle cx="116" cy="${cy + 6}" r="2.4"/><circle cx="144" cy="${cy + 6}" r="2.4"/></g>`;
  const dizzy = f === 7;
  const eye = (x) => `<path d="M${x} ${cy - 44} L${x} ${cy - 66}" stroke="${CR.line}" stroke-width="7" stroke-linecap="round"/><path d="M${x} ${cy - 44} L${x} ${cy - 66}" stroke="${CR.red}" stroke-width="4" stroke-linecap="round"/>
    <circle cx="${x}" cy="${cy - 70}" r="9" fill="#fffbe8" stroke="${CR.line}" stroke-width="2.2"/>
    ${dizzy ? `<path d="M${x - 4} ${cy - 70} a4 4 0 1 1 4 4 a2.6 2.6 0 1 1 -2.6 -2.6" stroke="${CR.line}" stroke-width="1.6" fill="none"/>` : `<circle cx="${x + 3}" cy="${cy - 69}" r="4" fill="#140404"/><circle cx="${x + 4}" cy="${cy - 71}" r="1.3" fill="#fff"/>`}`;
  const brow = dizzy ? "" : `<path d="M108 ${cy - 82} L124 ${cy - 76} M152 ${cy - 82} L136 ${cy - 76}" stroke="${CR.line}" stroke-width="4" stroke-linecap="round"/>`;
  const mouth = `<path d="M118 ${cy - 6} Q130 ${cy + 2} 142 ${cy - 6}" stroke="${CR.line}" stroke-width="2.6" fill="${CR.dark}"/>
    <path d="M122 ${cy - 4} v4 M130 ${cy - 2} v4 M138 ${cy - 4} v4" stroke="#fff" stroke-width="1.6"/>`;
  // Claws: the small one on the left, the big one on the right.
  let arms = "", note = "", fx = "";
  if (f === 2) {
    arms = crabArm(80, cy - 4, 60, cy - 30) + crabClaw(56, cy - 36, -120, false, false) + crabArm(182, cy - 8, 196, cy - 58) + crabClaw(198, cy - 66, -70, true, true);
    note = `<g transform="translate(212 ${cy - 102}) rotate(-20)"><rect x="-17" y="-9" width="34" height="18" rx="2" fill="#8ed08a" stroke="#1e4a1c" stroke-width="1.6"/><circle cx="0" cy="0" r="4.4" fill="#d8f4c8" stroke="#1e4a1c" stroke-width="1"/></g>`;
  } else if (f === 3) {
    arms = crabArm(80, cy - 4, 60, cy - 26) + crabClaw(56, cy - 32, -130, false, false) + crabArm(182, cy - 8, 214, cy - 30) + crabClaw(222, cy - 34, -20, true, true);
    fx = `<path d="M232 ${cy - 70} Q256 ${cy - 50} 250 ${cy - 20}" stroke="#ffffff" stroke-width="3" fill="none" opacity="0.6"/>`;
  } else if (f === 4) {
    // The snap: the big claw thrust out far ahead, pincers clacking shut.
    arms = crabArm(80, cy - 4, 62, cy - 22) + crabClaw(58, cy - 28, -140, true, false) + crabArm(182, cy, 222, cy + 4) + crabClaw(232, cy + 2, 0, false, true);
    fx = `<path d="M252 ${cy - 22} l6 -8 M256 ${cy + 2} l8 0 M252 ${cy + 24} l6 8" stroke="#ffffff" stroke-width="3" stroke-linecap="round"/>`;
  } else if (f === 5) {
    arms = crabArm(80, cy - 6, 62, cy - 56) + crabClaw(60, cy - 66, -100, true, true) + crabArm(180, cy - 6, 198, cy - 56) + crabClaw(200, cy - 66, -80, true, true);
  } else if (f === 6) {
    arms = crabArm(80, cy, 50, cy + 30) + crabClaw(40, cy + 36, 160, false, true) + crabArm(180, cy, 210, cy + 30) + crabClaw(220, cy + 36, 20, false, true);
    fx = `<g fill="#e8d4a0" opacity="0.9"><circle cx="20" cy="140" r="8"/><circle cx="44" cy="146" r="6"/><circle cx="216" cy="146" r="6"/><circle cx="240" cy="140" r="8"/></g>`;
  } else {
    const b = dizzy ? 10 : step * 0.6;
    arms = crabArm(80, cy - 2, 62, cy - 18 + b) + crabClaw(56, cy - 22 + b, -150, f === 1, false) + crabArm(182, cy - 4, 202, cy - 22 - b) + crabClaw(210, cy - 28 - b, -30, f === 0, true);
  }
  const stars = dizzy ? `<path d="M100 10 l2 5 5 1 -4 3 1 5 -4 -3 -4 3 1 -5 -4 -3 5 -1 Z M160 6 l2 5 5 1 -4 3 1 5 -4 -3 -4 3 1 -5 -4 -3 5 -1 Z" fill="#ffe04a" stroke="${CR.line}" stroke-width="1"/>` : "";
  // Drawn on a 260 x 150 grid, placed with room around it for the raised and thrust claws.
  return `<g transform="translate(20 30)">${legs + eye(116) + eye(144) + shell + brow + mouth + arms + note + fx + stars}</g>`;
}
for (let f = 0; f < 8; f++) save("crab_" + f, 300, 180, crab(f), crabDefs);

// =====================================================================================
// ---------- Level 8, the deep: octopus, jellyfish, the jellyfish queen, a sunken ship ----------
// =====================================================================================
// Glowing sea anemone (a light on the sea floor) and coral.
save("spr_anemone", 32, 30,
  `${[4, 9, 14, 19, 24, 28].map((x, i) => `<path d="M16 28 Q${x} ${16 - (i % 2) * 4} ${x + (i < 3 ? -2 : 2)} ${4 + (i % 3) * 3}" stroke="#ff6ad8" stroke-width="3.4" fill="none" stroke-linecap="round"/>
     <circle cx="${x + (i < 3 ? -2 : 2)}" cy="${4 + (i % 3) * 3}" r="2.6" fill="#fff0fc"/>`).join("")}
   <ellipse cx="16" cy="27" rx="9" ry="4" fill="#a02a8a" stroke="#3a0a30" stroke-width="1.4"/>`);
save("spr_coral", 34, 30,
  `<path d="M17 30 L17 18 L9 10 L9 3 M17 18 L25 9 L25 2 M17 22 L28 16 M13 14 L5 13" stroke="#3a0c14" stroke-width="7" fill="none" stroke-linecap="round" stroke-linejoin="round"/>
   <path d="M17 30 L17 18 L9 10 L9 3 M17 18 L25 9 L25 2 M17 22 L28 16 M13 14 L5 13" stroke="#ff7a5a" stroke-width="4.4" fill="none" stroke-linecap="round" stroke-linejoin="round"/>
   <g fill="#ffd0a0"><circle cx="9" cy="3" r="1.6"/><circle cx="25" cy="2" r="1.6"/><circle cx="28" cy="16" r="1.4"/><circle cx="5" cy="13" r="1.4"/></g>`);

// ---------- The octopus (frames: idle A, idle B, puffed up to squirt ink) ----------
// 60 x 56, origin (30, 24). It faces right (its eyes look that way).
function octo(f) {
  const puff = f === 2;
  const k = puff ? 1.15 : 1;
  let legs = "";
  for (let i = 0; i < 6; i++) {
    const x = 12 + i * 7.2;
    const sway = (f === 1 ? 1 : -1) * ((i % 2) ? 4 : -4);
    legs += `<path d="M${x} 32 Q${x + sway} 44 ${x - sway * 0.6} 54" stroke="#3a0c2a" stroke-width="6.6" fill="none" stroke-linecap="round"/>
      <path d="M${x} 32 Q${x + sway} 44 ${x - sway * 0.6} 54" stroke="#c4407e" stroke-width="4" fill="none" stroke-linecap="round"/>`;
  }
  return `${legs}
    <ellipse cx="30" cy="${22 - (puff ? 2 : 0)}" rx="${17 * k}" ry="${17 * k}" fill="#d85a94" stroke="#3a0c2a" stroke-width="2.4"/>
    <ellipse cx="25" cy="13" rx="6" ry="4" fill="#f4a0c8" opacity="0.8"/>
    <circle cx="20" cy="18" r="1.6" fill="#f4a0c8"/><circle cx="38" cy="12" r="1.8" fill="#f4a0c8"/>
    <ellipse cx="36" cy="25" rx="5" ry="6" fill="#fff6e0" stroke="#3a0c2a" stroke-width="1.6"/><circle cx="38" cy="26" r="2.6" fill="#140410"/>
    <ellipse cx="25" cy="25" rx="4.4" ry="5.4" fill="#fff6e0" stroke="#3a0c2a" stroke-width="1.6"/><circle cx="27" cy="26" r="2.3" fill="#140410"/>
    <path d="M21 18 L29 21 M41 17 L34 20" stroke="#3a0c2a" stroke-width="2" stroke-linecap="round"/>
    ${puff ? `<ellipse cx="46" cy="33" rx="5" ry="4" fill="#7a1a50" stroke="#3a0c2a" stroke-width="1.6"/><circle cx="52" cy="33" r="3" fill="#2a1030"/>` : `<path d="M28 33 Q32 35 36 33" stroke="#3a0c2a" stroke-width="1.6" fill="none"/>`}`;
}
for (let f = 0; f < 3; f++) save("octo_" + f, 60, 56, octo(f));
save("spr_ink", 24, 24,
  `<path d="M12 2 Q20 4 21 11 Q23 19 14 22 Q5 23 3 15 Q1 6 12 2 Z" fill="#2a1438" stroke="#0a0410" stroke-width="1.6"/>
   <ellipse cx="9" cy="9" rx="3" ry="2" fill="#6a4a8a" opacity="0.8"/>`);

// ---------- Jellyfish (frames: pulse A, pulse B, electrified) ----------
// 44 x 60, origin (22, 18).
function jelly(f) {
  if (f === 3) return jelly(0).split("#8ac8ff").join("#f6e8a0").split("#2a5a9a").join("#a08020");   // charging: yellowing, no sparks yet
  const zap = f === 2, squeeze = f === 1;
  const w = squeeze ? 15 : 18, h = squeeze ? 15 : 13;
  let tent = "";
  for (let i = 0; i < 5; i++) {
    const x = 10 + i * 6;
    const s = (squeeze ? 2 : -2) * ((i % 2) ? 1 : -1);
    tent += `<path d="M${x} 20 Q${x + s} 34 ${x - s} 44 Q${x + s} 52 ${x} 58" stroke="${zap ? "#fff6a0" : "#9ad8ff"}" stroke-width="2.2" fill="none" opacity="0.9"/>`;
  }
  const bolts = zap ? `<g stroke="#fff27a" stroke-width="2.2" fill="none" stroke-linecap="round">
      <path d="M2 8 L7 12 L3 16 L9 20"/><path d="M42 8 L37 12 L41 16 L35 20"/><path d="M22 -2 L20 3 L24 5 L21 9" transform="translate(0 2)"/></g>` : "";
  return `${tent}
    <path d="M${22 - w} 20 Q${22 - w} ${20 - h * 1.5} 22 ${20 - h * 1.5} Q${22 + w} ${20 - h * 1.5} ${22 + w} 20 Q${22 + w * 0.5} 23 22 21 Q${22 - w * 0.5} 23 ${22 - w} 20 Z"
      fill="${zap ? "#fff0a0" : "#8ac8ff"}" fill-opacity="0.8" stroke="${zap ? "#c08a10" : "#2a5a9a"}" stroke-width="1.8"/>
    <ellipse cx="17" cy="${20 - h}" rx="4" ry="2.4" fill="#ffffff" opacity="0.7"/>
    <circle cx="18" cy="15" r="1.6" fill="#16264a"/><circle cx="26" cy="15" r="1.6" fill="#16264a"/>${bolts}`;
}
for (let f = 0; f < 4; f++) save("jelly_" + f, 44, 60, jelly(f));
save("spr_spark", 22, 22,
  `<circle cx="11" cy="11" r="9" fill="#fff27a" opacity="0.45"/>
   <path d="M11 1 L13 8 L20 6 L14 11 L21 15 L13 14 L11 21 L9 14 L1 15 L8 11 L2 6 L9 8 Z" fill="#fff8c0" stroke="#c08a10" stroke-width="1.2" stroke-linejoin="round"/>`);

// ---------- Queen Voltella, the giant jellyfish ----------
// Frames: drifting, pulse, charging, zap, diving, hurt. 260 x 340, origin (130, 108): the bell.
function queen(f) {
  const zap = f === 3, charge = f === 2, dive = f === 4, hurt = f === 5, pulse = f === 1;
  const bw = dive ? 74 : pulse ? 82 : 92;
  const bh = dive ? 82 : pulse ? 66 : 70;
  const bell = zap || charge ? "#fff0a0" : "#c49aff";
  const rim = zap || charge ? "#c08a10" : "#4a2a8a";
  let tent = "";
  for (let i = 0; i < 9; i++) {
    const x = 130 - 72 + i * 18;
    const s = (pulse ? 10 : -10) * ((i % 2) ? 1 : -1);
    const len = dive ? 196 : 180 + (i % 3) * 12;
    tent += `<path d="M${x} 104 Q${x + s} ${140} ${x - s} ${170} Q${x + s} ${200} ${x + (dive ? 0 : -s * 0.5)} ${104 + len}" stroke="${rim}" stroke-width="7" fill="none" stroke-linecap="round" opacity="0.8"/>
      <path d="M${x} 104 Q${x + s} ${140} ${x - s} ${170} Q${x + s} ${200} ${x + (dive ? 0 : -s * 0.5)} ${104 + len}" stroke="${zap ? "#fff6a0" : "#e8c8ff"}" stroke-width="3.6" fill="none" stroke-linecap="round"/>`;
  }
  // Frilly mouth-arms in the middle.
  const arms = `<path d="M112 100 Q100 150 118 190 Q104 220 122 250" stroke="#ff8ad8" stroke-width="9" fill="none" stroke-linecap="round" opacity="0.85"/>
    <path d="M148 100 Q160 150 142 190 Q156 220 138 250" stroke="#ff8ad8" stroke-width="9" fill="none" stroke-linecap="round" opacity="0.85"/>`;
  const glow = (zap || charge) ? `<ellipse cx="130" cy="70" rx="${bw + 26}" ry="${bh + 20}" fill="#fff27a" opacity="${zap ? 0.35 : 0.2}"/>` : "";
  const bolts = zap ? `<g stroke="#fff27a" stroke-width="4" fill="none" stroke-linecap="round" stroke-linejoin="round">
      <path d="M22 40 L40 58 L26 70 L46 88"/><path d="M238 40 L220 58 L234 70 L214 88"/><path d="M130 -6 L122 10 L136 16 L126 30" transform="translate(0 4)"/>
      <path d="M40 120 L58 116 L52 134 L72 130"/><path d="M220 120 L202 116 L208 134 L188 130"/></g>` : "";
  const sparks = charge ? `<g fill="#fff8c0">${[[40, 30], [220, 36], [70, 120], [196, 124], [130, 6]].map(([x, y]) => `<circle cx="${x}" cy="${y}" r="3"/>`).join("")}</g>` : "";
  const eyes = hurt
    ? `<path d="M100 60 l12 12 M112 60 l-12 12 M148 60 l12 12 M160 60 l-12 12" stroke="#2a0a40" stroke-width="4" stroke-linecap="round"/>`
    : `<ellipse cx="106" cy="66" rx="9" ry="11" fill="#fffaf0" stroke="#2a0a40" stroke-width="2.4"/><circle cx="108" cy="68" r="4.6" fill="#1a0630"/>
       <ellipse cx="154" cy="66" rx="9" ry="11" fill="#fffaf0" stroke="#2a0a40" stroke-width="2.4"/><circle cx="152" cy="68" r="4.6" fill="#1a0630"/>
       <path d="M92 50 L114 56 M168 50 L146 56" stroke="#2a0a40" stroke-width="4" stroke-linecap="round"/>`;
  const mouth = hurt ? `<path d="M118 92 Q130 84 142 92" stroke="#2a0a40" stroke-width="3" fill="none"/>`
    : `<path d="M116 86 Q130 98 144 86 Z" fill="#7a1a5a" stroke="#2a0a40" stroke-width="2.4"/><path d="M122 88 l2 4 l2 -4 M134 88 l2 4 l2 -4" fill="#fff" stroke="none"/>`;
  const crown = `<g transform="translate(0 ${-bh + 70})"><path d="M108 4 L112 -14 L120 -2 L130 -20 L140 -2 L148 -14 L152 4 Z" fill="#ffb84a" stroke="#6a3a06" stroke-width="2.2" stroke-linejoin="round"/>
    <circle cx="130" cy="-8" r="3.4" fill="#ff4a8a"/><circle cx="116" cy="-2" r="2.2" fill="#6af0ff"/><circle cx="144" cy="-2" r="2.2" fill="#6af0ff"/></g>`;
  return `${glow}${tent}${arms}
    <path d="M${130 - bw} 104 Q${130 - bw} ${104 - bh * 1.45} 130 ${104 - bh * 1.45} Q${130 + bw} ${104 - bh * 1.45} ${130 + bw} 104
      Q${130 + bw * 0.75} 114 ${130 + bw * 0.5} 106 Q${130 + bw * 0.25} 116 130 106 Q${130 - bw * 0.25} 116 ${130 - bw * 0.5} 106 Q${130 - bw * 0.75} 114 ${130 - bw} 104 Z"
      fill="${bell}" fill-opacity="0.88" stroke="${rim}" stroke-width="3.4"/>
    <ellipse cx="${130 - bw * 0.45}" cy="${104 - bh * 1.05}" rx="${bw * 0.22}" ry="${bh * 0.16}" fill="#ffffff" opacity="0.6"/>
    ${crown}${eyes}${mouth}${bolts}${sparks}`;
}
for (let f = 0; f < 6; f++) save("queen_" + f, 260, 340, `<g transform="translate(0 40)">${queen(f)}</g>`);

// ---------- The sunken ship: the bow of a huge wreck, sunk in the sand ----------
// 980 x 600, origin (0, 600). Only the front shows; the rest is beyond the level's end.
function wreck() {
  const plank = "#4e3c30", plankD = "#33261e", plankL = "#6a5644", rust = "#8a5a30", algae = "#3e6a48";
  // Hull: the bow at the left, rising to a high forecastle, running off to the right.
  const hull = `M60 600 L70 470 Q90 380 150 330 L210 300 L980 286 L980 600 Z`;
  let planks = "";
  for (let y = 320; y < 600; y += 22) planks += `<path d="M${y < 380 ? 160 - (y - 320) * 0.6 : 72} ${y} L980 ${y - 8}" stroke="${plankD}" stroke-width="2.4"/>`;
  let ribs = "";
  for (let x = 260; x < 980; x += 120) ribs += `<path d="M${x} 296 L${x + 6} 600" stroke="${plankD}" stroke-width="5" opacity="0.6"/>`;
  let ports = "";
  for (let x = 420; x < 980; x += 92) ports += `<circle cx="${x}" cy="380" r="17" fill="#1a1612" stroke="${rust}" stroke-width="6"/><circle cx="${x - 4}" cy="376" r="6" fill="#3a6a7a" opacity="0.7"/>`;
  let barn = "";
  for (let i = 0; i < 40; i++) {
    const x = 90 + ((i * 97) % 880), y = 430 + ((i * 53) % 160);
    barn += `<circle cx="${x}" cy="${y}" r="${3 + (i % 3)}" fill="#c8c0a8" stroke="#4a4438" stroke-width="1.2"/>`;
  }
  let weed = "";
  for (let i = 0; i < 14; i++) {
    const x = 100 + i * 64 + ((i * 29) % 30);
    weed += `<path d="M${x} 600 Q${x - 12} ${540} ${x + 4} ${500 - (i % 3) * 20} Q${x + 14} ${470} ${x} ${440 - (i % 4) * 16}" stroke="${algae}" stroke-width="6" fill="none" stroke-linecap="round"/>`;
  }
  // The big hole in the hull (the way in) and broken planks round it.
  const hole = `<path d="M250 600 L244 520 L262 470 L292 452 L330 462 L352 500 L360 548 L366 600 Z" fill="#0a0806" stroke="${plankD}" stroke-width="5"/>
    <path d="M244 520 L226 506 M262 470 L250 446 M330 462 L346 440 M352 500 L376 494" stroke="${plankL}" stroke-width="7" stroke-linecap="round"/>`;
  // Deck rail, the broken bowsprit, the masts and a torn sail.
  const deck = `<path d="M150 330 L210 300 L980 286" stroke="${plankL}" stroke-width="8" fill="none"/>
    ${[230, 300, 370, 440, 510, 580, 650, 720, 790, 860, 930].map((x) => `<path d="M${x} ${300 - (x - 230) * 0.02} l0 -26" stroke="${plankL}" stroke-width="5"/>`).join("")}
    <path d="M200 276 L980 262" stroke="${plankL}" stroke-width="6"/>`;
  const bowsprit = `<path d="M160 318 L10 236" stroke="${plankD}" stroke-width="16" stroke-linecap="round"/><path d="M160 318 L10 236" stroke="${plank}" stroke-width="10" stroke-linecap="round"/>
    <path d="M14 238 L160 300" stroke="#8a8070" stroke-width="2" opacity="0.7"/>`;
  const mast = (x, top, broken) => `<rect x="${x - 11}" y="${top}" width="22" height="${290 - top}" fill="${plank}" stroke="${plankD}" stroke-width="3"/>
    ${broken ? `<path d="M${x - 11} ${top} L${x - 4} ${top - 22} L${x + 3} ${top - 6} L${x + 11} ${top - 18} L${x + 11} ${top}" fill="${plank}" stroke="${plankD}" stroke-width="3"/>` : ""}
    <rect x="${x - 70}" y="${top + 60}" width="140" height="12" rx="4" fill="${plank}" stroke="${plankD}" stroke-width="3" transform="rotate(-8 ${x} ${top + 66})"/>`;
  const sail = `<path d="M560 110 L700 98 L690 170 L650 150 L640 210 L600 180 L572 230 Z" fill="#c8bca0" opacity="0.65" stroke="#7a705a" stroke-width="2.4"/>
    <path d="M590 120 L610 200 M640 112 L650 150" stroke="#7a705a" stroke-width="1.6" opacity="0.7"/>`;
  const chain = `<path d="M120 380 Q110 470 140 600" stroke="#5a5048" stroke-width="5" fill="none" stroke-dasharray="8 4"/>`;
  return `${mast(330, 40, true)}${mast(640, -40, false)}${sail}${bowsprit}
    <path d="${hull}" fill="${plank}" stroke="${plankD}" stroke-width="5"/>${planks}${ribs}
    <path d="M70 470 Q90 380 150 330" stroke="${plankL}" stroke-width="6" fill="none"/>
    ${deck}${ports}${hole}${barn}${weed}${chain}
    <path d="M60 600 L70 470 Q90 380 150 330 L210 300 L980 286 L980 600 Z" fill="${algae}" opacity="0.18"/>`;
}
save("spr_wreck", 980, 600, wreck());

// =====================================================================================
// ---------- Level 9, inside the shipwreck: wood, lanterns, pirates ----------
// =====================================================================================
const W = { plank: "#7a5030", light: "#a8743e", dark: "#4a2c16", line: "#24140a", deck: "#c08a4a", deckL: "#e0aa66", iron: "#5a5a64" };
const woodWall = (seed) => {
  let s = `<rect width="32" height="32" fill="${W.plank}"/>`;
  for (let x = 0; x < 32; x += 8) s += `<rect x="${x}" y="0" width="8" height="32" fill="${(x / 8 + seed) % 2 ? W.plank : "#6e4628"}"/><path d="M${x} 0 V32" stroke="${W.line}" stroke-width="1.2"/>`;
  s += `<path d="M${2 + seed * 8} ${10 + seed * 6} q2 -3 4 0 q-2 3 -4 0" fill="${W.dark}"/>`;
  if (seed) s += `<circle cx="4" cy="4" r="1.2" fill="${W.iron}"/><circle cx="20" cy="28" r="1.2" fill="${W.iron}"/>`;
  return s;
};
const deckTop = (left, right) => `<rect x="0" y="0" width="32" height="9" fill="${W.deck}"/><path d="M0 9 H32" stroke="${W.line}" stroke-width="2"/>
  <path d="M0 1 H32" stroke="${W.deckL}" stroke-width="2"/><path d="M11 0 V9 M27 0 V9" stroke="${W.line}" stroke-width="1"/>
  <circle cx="5" cy="5" r="1" fill="${W.iron}"/><circle cx="21" cy="5" r="1" fill="${W.iron}"/>
  ${left ? `<rect x="0" y="0" width="4" height="32" fill="${W.dark}"/>` : ""}${right ? `<rect x="28" y="0" width="4" height="32" fill="${W.dark}"/>` : ""}`;
const shipTiles = [
  "",
  woodWall(0) + deckTop(false, false),
  woodWall(0),
  woodWall(1),
  woodWall(1) + deckTop(true, false),
  woodWall(0) + deckTop(false, true),
  woodWall(1) + `<rect x="0" y="20" width="32" height="12" fill="${W.dark}"/><path d="M0 20 H32" stroke="${W.line}" stroke-width="2"/><rect x="0" y="30" width="32" height="2" fill="#000" opacity="0.4"/>`,
  `<rect x="0" y="3" width="32" height="9" rx="2" fill="${W.light}" stroke="${W.line}" stroke-width="1.5"/><path d="M2 7.5 H30" stroke="${W.dark}" stroke-width="1"/>
   <path d="M6 12 q2 6 0 12 M26 12 q-2 6 0 12" stroke="#c8b080" stroke-width="2" fill="none"/>`,
  `<rect x="1" y="1" width="30" height="30" rx="2" fill="#9a6a38" stroke="${W.line}" stroke-width="2"/><path d="M3 3 L29 29 M29 3 L3 29" stroke="${W.dark}" stroke-width="3"/>
   <rect x="1" y="1" width="30" height="30" rx="2" fill="none" stroke="${W.dark}" stroke-width="3"/><path d="M12 2 L16 10 L13 16 L18 24" stroke="${W.line}" stroke-width="1.6" fill="none"/>`,
  `<rect x="0" y="26" width="32" height="6" fill="${W.dark}"/>${[4, 12, 20, 28].map((x) => `<path d="M${x - 3} 27 L${x} 12 L${x + 3} 27 Z" fill="#9aa0aa" stroke="#2a2a30" stroke-width="1.2"/>`).join("")}`,
  woodWall(0) + deckTop(true, true),
];
save("spr_tiles_ship", 32 * shipTiles.length, 32,
  shipTiles.map((t, i) => `<g transform="translate(${i * 32},0)" clip-path="url(#cell)">${t}</g>`).join(""),
  `<clipPath id="cell"><rect x="0" y="0" width="32" height="32"/></clipPath>`);

// Inside the hull: ribs and dim portholes far back, beams and ropes above, cargo in front.
let sfar = `<rect width="1024" height="260" fill="#3a2414"/>`;
for (let x = 0; x < 1024; x += 16) sfar += `<path d="M${x} 0 V260" stroke="#2a180c" stroke-width="2"/>`;
for (let x = 64; x < 1024; x += 128) sfar += `<path d="M${x - 20} 260 Q${x - 26} 120 ${x} 30 Q${x + 26} 120 ${x + 20} 260 Z" fill="#4a2e18" stroke="#1e1006" stroke-width="3"/>
  <circle cx="${x + 64}" cy="110" r="16" fill="#2e5a4a" stroke="#6a4a2a" stroke-width="5"/><circle cx="${x + 60}" cy="105" r="5" fill="#7ac0a0" opacity="0.6"/>`;
save("spr_bg_ship_far", 1024, 260, sfar);
let stop = `<rect width="1024" height="26" fill="#2a180c"/>`;
for (let x = 0; x < 1024; x += 256) stop += `<rect x="${x}" y="20" width="256" height="20" fill="#4a2e18" stroke="#1e1006" stroke-width="3"/>`;
for (let i = 0; i < 12; i++) {
  const x = 40 + i * 86;
  stop += `<path d="M${x} 40 Q${x + 18} ${70 + (i % 3) * 20} ${x + 40} 40" stroke="#8a7a5a" stroke-width="3" fill="none"/>`;
  if (i % 3 === 0) stop += `<path d="M${x + 60} 40 V${90 + (i % 2) * 20}" stroke="#8a7a5a" stroke-width="3"/><circle cx="${x + 60}" cy="${92 + (i % 2) * 20}" r="5" fill="none" stroke="#8a7a5a" stroke-width="3"/>`;
}
save("spr_bg_ship_top", 1024, 130, stop);
let snear = "";
for (let i = 0; i < 10; i++) {
  const x = 30 + i * 104;
  if (i % 3 === 0) snear += `<rect x="${x}" y="130" width="64" height="70" fill="#2e1c0e"/><path d="M${x} 130 L${x + 64} 200 M${x + 64} 130 L${x} 200" stroke="#1e1006" stroke-width="5"/>`;
  else if (i % 3 === 1) snear += `<ellipse cx="${x + 26}" cy="160" rx="26" ry="40" fill="#34200f"/><path d="M${x} 140 H${x + 52} M${x} 180 H${x + 52}" stroke="#1e1006" stroke-width="5"/>`;
  else snear += `<rect x="${x}" y="164" width="70" height="36" rx="10" fill="#2a1a0c"/><rect x="${x + 50}" y="150" width="56" height="16" rx="6" fill="#222226" transform="rotate(-10 ${x + 60} 158)"/>`;
}
save("spr_bg_ship_near", 1024, 200, snear);

// Cargo and decorations: barrels, piles of gold, hanging ropes, lanterns (they light the dark).
save("spr_barrel", 28, 32,
  `<path d="M4 2 Q1 16 4 30 L24 30 Q27 16 24 2 Z" fill="#8a5a2c" stroke="${W.line}" stroke-width="1.8"/>
   <path d="M3 8 H25 M3 24 H25" stroke="${W.iron}" stroke-width="3"/><path d="M10 3 V29 M18 3 V29" stroke="${W.dark}" stroke-width="1"/>`);
save("spr_coins", 30, 16,
  `<path d="M2 15 Q6 4 15 3 Q24 4 28 15 Z" fill="#e8b828" stroke="#6a4a06" stroke-width="1.4"/>
   ${[[8, 11], [14, 8], [20, 11], [12, 13], [18, 5]].map(([x, y]) => `<ellipse cx="${x}" cy="${y}" rx="3.4" ry="2" fill="#ffe27a" stroke="#8a6206" stroke-width="0.8"/>`).join("")}
   <path d="M22 4 l2 -3 l1 3" stroke="#fff6c0" stroke-width="1.2" fill="none"/>`);
save("spr_rope", 12, 46,
  `<path d="M6 0 Q9 12 6 24 Q3 34 6 42" stroke="#8a7a5a" stroke-width="3.4" fill="none"/><circle cx="6" cy="42" r="3" fill="#8a7a5a"/>
   <path d="M4 8 l4 2 M4 18 l4 2 M3 28 l4 2" stroke="#5a4a32" stroke-width="1"/>`);
save("spr_lantern", 24, 40,
  `<path d="M12 0 V8" stroke="${W.iron}" stroke-width="2"/><path d="M6 8 H18 L16 12 H8 Z" fill="${W.iron}" stroke="#222" stroke-width="1"/>
   <rect x="6" y="12" width="12" height="18" rx="2" fill="#ffd27a" stroke="#3a2a10" stroke-width="1.6" opacity="0.95"/>
   <path d="M12 26 Q8 21 12 16 Q16 21 12 26 Z" fill="#ff8a1a"/><path d="M9 12 V30 M15 12 V30" stroke="#3a2a10" stroke-width="1"/>
   <path d="M5 30 H19 L17 34 H7 Z" fill="${W.iron}" stroke="#222" stroke-width="1"/>`);

// ---------- Pirate skeletons: a red bandana, an eye patch, a cutlass ----------
function pskel(f) {
  let s = skel(f);
  // The helmet becomes a red bandana with a knot; the right eye gets a patch.
  s = s.replace(`<path d="M17 9 Q27 0 37 9 L38 11 L16 11 Z" fill="#7a6a78" stroke="${B.line}" stroke-width="1.6"/>`,
    `<path d="M16 11 Q16 1 27 1 Q38 1 38 11 Z" fill="#c8303a" stroke="${B.line}" stroke-width="1.6"/>
     <circle cx="21" cy="5" r="1.2" fill="#fff"/><circle cx="31" cy="4" r="1.2" fill="#fff"/><circle cx="26" cy="8" r="1.2" fill="#fff"/>
     <path d="M16 9 L9 6 L11 12 Z" fill="#c8303a" stroke="${B.line}" stroke-width="1.2"/>`);
  s += `<ellipse cx="33" cy="14" rx="3.8" ry="3.4" fill="#111"/><path d="M17 11 L37 15" stroke="#111" stroke-width="1.2"/>`;
  return s.split("#d6dbe6").join("#e8ecf4").split("#8a5a2a").join("#e0b030");
}
for (let f = 0; f < 4; f++) save("pskel_" + f, 76, 52, pskel(f));

// ---------- Captain Octavius, the octopus pirate: eight arms, eight swords ----------
// Frames: idle A, idle B, wind-up (swords drawn back), stab (three swords thrust far ahead),
// low sweep (swords along the floor both sides), high slash (swords at head height both
// sides), hurt. 860 x 340, origin (430, 210); floor at the bottom (y 330).
function octopirate(f) {
  const P = { body: "#b84a6a", light: "#e07a96", dark: "#5a1a30", line: "#2a0814" };
  const cx = 280, hy = 150;
  // Each arm: base on the body -> hand, then a sword pointing on along the arm.
  const arm = (bx, by, hx, hy2, sx, sy, sway = 0) => {
    const mx = (bx + hx) / 2 + sway, my = (by + hy2) / 2 + 26;
    const d = `M${bx} ${by} Q${mx} ${my} ${hx} ${hy2}`;
    const len = Math.hypot(sx - hx, sy - hy2) || 1;
    const ux = (sx - hx) / len, uy = (sy - hy2) / len;
    return `<path d="${d}" stroke="${P.line}" stroke-width="15" fill="none" stroke-linecap="round"/>
      <path d="${d}" stroke="${P.body}" stroke-width="10.5" fill="none" stroke-linecap="round"/>
      <path d="M${hx - uy * 7} ${hy2 + ux * 7} L${hx + uy * 7} ${hy2 - ux * 7}" stroke="#e0b030" stroke-width="5" stroke-linecap="round"/>
      <path d="M${hx} ${hy2} L${sx} ${sy}" stroke="#2a2a30" stroke-width="7" stroke-linecap="round"/>
      <path d="M${hx} ${hy2} L${sx} ${sy}" stroke="#e8ecf4" stroke-width="4" stroke-linecap="round"/>
      <path d="M${hx + ux * 6 - uy * 2} ${hy2 + uy * 6 + ux * 2} L${sx - ux * 4 - uy * 2} ${sy - uy * 4 + ux * 2}" stroke="#ffffff" stroke-width="1.4" opacity="0.8"/>`;
  };
  // Bases round the lower body, left to right.
  const bases = [[220, 200], [236, 214], [254, 222], [272, 226], [288, 226], [306, 222], [324, 214], [340, 200]];
  let pose;
  const sw = f === 1 ? 6 : -6;
  if (f === 3) {
    // Stab: the three right arms thrust their swords far ahead; the rest hold back.
    pose = [[160, 150, 110, 120], [170, 230, 120, 250], [200, 300, 160, 325], [240, 310, 210, 330],
            [330, 160, 548, 130], [340, 220, 552, 205], [350, 280, 550, 285], [370, 300, 420, 326]];
  } else if (f === 4) {
    // Low sweep: swords flat along the floor on both sides.
    pose = [[120, 300, 24, 318], [170, 315, 70, 326], [210, 318, 130, 328], [250, 320, 200, 330],
            [310, 320, 360, 330], [350, 318, 430, 328], [390, 315, 490, 326], [440, 300, 536, 318]];
  } else if (f === 5) {
    // High slash: swords out at head height on both sides.
    pose = [[140, 120, 30, 90], [150, 160, 34, 150], [170, 200, 60, 205], [240, 300, 210, 330],
            [320, 300, 350, 330], [390, 200, 500, 205], [410, 160, 526, 150], [420, 120, 530, 90]];
  } else if (f === 2) {
    // Wind-up: swords drawn back and up.
    pose = [[180, 140, 150, 80], [190, 190, 140, 160], [210, 250, 160, 240], [240, 300, 210, 326],
            [320, 300, 350, 326], [350, 250, 400, 240], [370, 190, 420, 160], [380, 140, 410, 80]];
  } else {
    // Idle (and hurt): swords held out loosely all round.
    pose = [[170, 160, 110, 110], [170, 220, 100, 220], [200, 280, 150, 300], [240, 310, 210, 330],
            [320, 310, 350, 330], [360, 280, 410, 300], [390, 220, 460, 220], [390, 160, 450, 110]];
  }
  // The striking frames stretch the arms half as far again: a very long reach.
  if (f >= 3 && f <= 5) pose = pose.map(([hx, hy2, sx, sy]) => [280 + (hx - 280) * 1.5, hy2, 280 + (sx - 280) * 1.5, sy]);
  let arms = "";
  pose.forEach(([hx, hy2, sx, sy], i) => { arms += arm(bases[i][0], bases[i][1], hx, hy2, sx, sy, (i % 2 ? sw : -sw)); });
  const hurt = f === 6;
  const head = `<path d="M${cx - 80} 210 Q${cx - 92} ${hy - 80} ${cx} ${hy - 86} Q${cx + 92} ${hy - 80} ${cx + 80} 210 Q${cx} 236 ${cx - 80} 210 Z" fill="${P.body}" stroke="${P.line}" stroke-width="4"/>
    <ellipse cx="${cx - 40}" cy="${hy - 40}" rx="22" ry="14" fill="${P.light}" opacity="0.7"/>
    ${[[cx - 52, hy + 10], [cx + 56, hy - 6], [cx - 30, hy + 48], [cx + 40, hy + 44]].map(([x, y]) => `<circle cx="${x}" cy="${y}" r="5" fill="${P.light}" opacity="0.8"/>`).join("")}`;
  const eye = hurt
    ? `<path d="M${cx + 10} ${hy + 4} l16 16 M${cx + 26} ${hy + 4} l-16 16" stroke="${P.line}" stroke-width="5" stroke-linecap="round"/>`
    : `<ellipse cx="${cx + 20}" cy="${hy + 12}" rx="15" ry="17" fill="#fff8e8" stroke="${P.line}" stroke-width="3"/><circle cx="${cx + 24}" cy="${hy + 14}" r="7" fill="#140408"/><circle cx="${cx + 26}" cy="${hy + 11}" r="2.4" fill="#fff"/>
       <path d="M${cx + 2} ${hy - 8} L${cx + 38} ${hy - 2}" stroke="${P.line}" stroke-width="5" stroke-linecap="round"/>`;
  const patch = `<path d="M${cx - 76} ${hy - 20} L${cx + 70} ${hy + 4}" stroke="#111" stroke-width="3.4"/>
    <ellipse cx="${cx - 24}" cy="${hy + 10}" rx="16" ry="15" fill="#151515" stroke="#000" stroke-width="2"/>`;
  const mouth = `<path d="M${cx - 30} ${hy + 50} Q${cx} ${hy + 64} ${cx + 30} ${hy + 50}" stroke="${P.line}" stroke-width="4" fill="${P.dark}"/>
    <path d="M${cx - 34} ${hy + 46} Q${cx - 52} ${hy + 40} ${cx - 56} ${hy + 52} M${cx + 34} ${hy + 46} Q${cx + 52} ${hy + 40} ${cx + 56} ${hy + 52}" stroke="${P.line}" stroke-width="5" fill="none" stroke-linecap="round"/>`;
  const hat = `<path d="M${cx - 110} ${hy - 62} Q${cx - 60} ${hy - 82} ${cx} ${hy - 78} Q${cx + 60} ${hy - 82} ${cx + 110} ${hy - 62} Q${cx + 70} ${hy - 150} ${cx} ${hy - 140} Q${cx - 70} ${hy - 150} ${cx - 110} ${hy - 62} Z" fill="#1e1a20" stroke="#000" stroke-width="3"/>
    <path d="M${cx - 100} ${hy - 66} Q${cx} ${hy - 90} ${cx + 100} ${hy - 66}" stroke="#e0b030" stroke-width="4" fill="none"/>
    <circle cx="${cx}" cy="${hy - 112}" r="12" fill="#f0eadc" stroke="#000" stroke-width="2"/><circle cx="${cx - 4}" cy="${hy - 114}" r="2.6" fill="#000"/><circle cx="${cx + 4}" cy="${hy - 114}" r="2.6" fill="#000"/>
    <path d="M${cx - 16} ${hy - 96} L${cx + 16} ${hy - 86} M${cx + 16} ${hy - 96} L${cx - 16} ${hy - 86}" stroke="#f0eadc" stroke-width="4" stroke-linecap="round"/>
    ${hurt ? `<path d="M${cx - 60} ${hy - 170} l2 6 6 1 -5 4 1 6 -4 -3 -5 3 1 -6 -5 -4 6 -1 Z M${cx + 60} ${hy - 176} l2 6 6 1 -5 4 1 6 -4 -3 -5 3 1 -6 -5 -4 6 -1 Z" fill="#ffe04a" stroke="#000" stroke-width="1"/>` : ""}`;
  return `<g transform="translate(150,0)">${arms + head + patch + eye + mouth + hat}</g>`;
}
for (let f = 0; f < 7; f++) save("octopirate_" + f, 860, 340, octopirate(f));

// ======================= Level 10: the Caribbean beach =======================
// ---------- Tiles: golden sand on top, packed wet sand and coral stones below ----------
const KB = {
  [C.grass]: "#f4d27a", [C.grassLight]: "#fff0b8", [C.grassDark]: "#d8a850", [C.grassLine]: "#8a5e22",
  [C.dirt]: "#c48a48", [C.stone]: "#e8c690", [C.stoneLight]: "#fff0d0", [C.stoneDark]: "#a87840", [C.mortar]: "#7a4e22",
  "#d6ff9a": "#fffbe6",
};
const recolorBeach = (s) => Object.entries(KB).reduce((t, [a, b]) => t.split(a).join(b), s);
const beachTiles = tiles.map(recolorBeach);
beachTiles[9] = sandTiles[9];       // sea urchins instead of spikes
// A tiny starfish on some sand tops.
beachTiles[1] += `<path d="M22 6 l1.4 2.6 2.8 .2 -2.2 1.8 .8 2.8 -2.8 -1.6 -2.6 1.6 .8 -2.8 -2.2 -1.8 2.8 -.2 Z" fill="#ff8a5a" stroke="#8a3a1a" stroke-width="0.6"/>`;
save("spr_tiles_beach", 32 * beachTiles.length, 32,
  beachTiles.map((t, i) => `<g transform="translate(${i * 32},0)" clip-path="url(#cell)">${t}</g>`).join(""),
  recolorBeach(stoneGrad) + `<clipPath id="cell"><rect x="0" y="0" width="32" height="32"/></clipPath>`);

// ---------- Backgrounds: a turquoise sea with islands far away, palms and dunes in front ----------
let bfar = `<circle cx="760" cy="70" r="40" fill="#fff6c8" opacity="0.9"/><circle cx="760" cy="70" r="58" fill="#fff6c8" opacity="0.25"/>`;
const isle = (x, w, h) => `<path d="M${x - w} 180 Q${x - w * 0.4} ${180 - h} ${x} ${180 - h} Q${x + w * 0.5} ${180 - h} ${x + w} 180 Z" fill="#3a9a6a"/>
  <path d="M${x - w * 0.3} ${181 - h * 0.9} q4 -30 10 -36 m0 0 q-14 -2 -22 6 m22 -6 q12 -6 22 2 m-22 -2 q-4 -10 -14 -12" stroke="#2a7a52" stroke-width="3" fill="none"/>`;
bfar += isle(150, 90, 34) + isle(520, 60, 22) + isle(900, 120, 40);
bfar += `<rect x="0" y="178" width="1024" height="82" fill="#1ab8c8"/><rect x="0" y="178" width="1024" height="6" fill="#8ae8ee"/>`;
for (let i = 0; i < 40; i++) {
  const x = (i * 97) % 1000, y = 192 + (i * 37) % 60;
  bfar += `<path d="M${x} ${y} q8 -4 16 0" stroke="#bff6f8" stroke-width="2" fill="none" opacity="0.8"/>`;
}
save("spr_bg_beach_far", 1024, 260, bfar);
// Dunes and palm trees (seamless: the palms sit well inside the picture).
const palmShape = (x, base, h, lean, s = 1) => {
  const tx = x + lean, ty = base - h;
  let p = `<path d="M${x - 7 * s} ${base} Q${x + lean * 0.3} ${base - h * 0.5} ${tx - 4 * s} ${ty} L${tx + 4 * s} ${ty} Q${x + lean * 0.3 + 10 * s} ${base - h * 0.5} ${x + 7 * s} ${base} Z" fill="#8a5a2c" stroke="#3a2008" stroke-width="2"/>`;
  [[-1, 0.2], [-0.8, -0.5], [0, -1], [0.8, -0.5], [1, 0.2], [0.5, 0.6], [-0.5, 0.6]].forEach(([dx, dy]) => {
    const ex = tx + dx * 62 * s, ey = ty + dy * 30 * s + 18 * s;
    const d = `M${tx} ${ty} Q${(tx + ex) / 2} ${ty + dy * 20 * s - 22 * s} ${ex} ${ey}`;
    p += `<path d="${d}" stroke="#1e6a2a" stroke-width="${11 * s}" fill="none" stroke-linecap="round"/>
      <path d="${d}" stroke="#3aa83a" stroke-width="${6 * s}" fill="none" stroke-linecap="round"/>`;
  });
  p += `<circle cx="${tx - 5 * s}" cy="${ty + 6 * s}" r="${6 * s}" fill="#6a4a1a" stroke="#2a1806" stroke-width="1.5"/><circle cx="${tx + 6 * s}" cy="${ty + 7 * s}" r="${6 * s}" fill="#6a4a1a" stroke="#2a1806" stroke-width="1.5"/>`;
  return p;
};
let bnear = `<path d="M0 200 L0 150 Q120 120 260 146 Q400 170 520 140 Q660 112 800 144 Q920 168 1024 150 L1024 200 Z" fill="#e8c27a"/>`;
bnear += `<path d="M0 150 Q120 120 260 146 Q400 170 520 140 Q660 112 800 144 Q920 168 1024 150" stroke="#c89a50" stroke-width="3" fill="none"/>`;
bnear += palmShape(140, 150, 120, 26, 0.9) + palmShape(430, 160, 100, -22, 0.8) + palmShape(690, 146, 112, 30, 1) + palmShape(900, 162, 96, -18, 0.75);
save("spr_bg_beach_near", 1024, 200, bnear);

// ---------- Beach decorations ----------
save("spr_palm", 150, 150, palmShape(75, 150, 112, 18, 0.8));
save("spr_starfish", 20, 14,
  `<path d="M10 1 l2 4.5 5 .4 -3.8 3.2 1.4 4.8 -4.6 -2.6 -4.6 2.6 1.4 -4.8 -3.8 -3.2 5 -.4 Z" fill="#ff7a4a" stroke="#7a2a10" stroke-width="1.1"/>
   <circle cx="10" cy="7.6" r="1" fill="#ffd0a0"/>`);
save("spr_sandcastle", 40, 34,
  `<path d="M2 33 L4 16 L12 16 L12 10 L16 10 L16 16 L24 16 L24 10 L28 10 L28 16 L36 16 L38 33 Z" fill="#f0c878" stroke="#8a5e22" stroke-width="1.5"/>
   <rect x="16" y="22" width="8" height="11" rx="4" fill="#a87840"/><path d="M14 10 V2 L20 4 L14 6" stroke="#5a3a14" stroke-width="1.2" fill="#ff4a4a"/>`);
// The big leaning palm whose frond holds the wasp hive. 560 x 424, origin at the foot of the
// trunk (400, 420); the crown (where the hive's vine is tied) is at (190, 60).
let bigPalm = "";
{
  const x = 400, base = 420, h = 360, lean = -210;
  const tx = x + lean, ty = base - h;
  bigPalm += `<path d="M${x - 16} ${base} Q${x - 30} ${base - h * 0.6} ${tx - 6} ${ty} L${tx + 8} ${ty + 8} Q${x + 0} ${base - h * 0.55} ${x + 16} ${base} Z" fill="#8a5a2c" stroke="#3a2008" stroke-width="3"/>`;
  [[-1, 0.4], [-0.85, -0.4], [-0.1, -1], [0.7, -0.6], [1, 0.3], [0.45, 0.85], [-0.55, 0.9]].forEach(([dx, dy]) => {
    const ex = tx + dx * 120, ey = ty + dy * 46 + 34;
    const d = `M${tx} ${ty} Q${(tx + ex) / 2} ${ty + dy * 30 - 40} ${ex} ${ey}`;
    bigPalm += `<path d="${d}" stroke="#1e6a2a" stroke-width="20" fill="none" stroke-linecap="round"/><path d="${d}" stroke="#3aa83a" stroke-width="12" fill="none" stroke-linecap="round"/>
      <path d="${d}" stroke="#7ad85a" stroke-width="2" fill="none"/>`;
  });
  bigPalm += `<circle cx="${tx - 10}" cy="${ty + 10}" r="11" fill="#6a4a1a" stroke="#2a1806" stroke-width="2"/><circle cx="${tx + 10}" cy="${ty + 12}" r="11" fill="#6a4a1a" stroke="#2a1806" stroke-width="2"/>
    <circle cx="${tx}" cy="${ty + 22}" r="11" fill="#6a4a1a" stroke="#2a1806" stroke-width="2"/>`;
}
save("spr_palm_big", 560, 424, bigPalm);

// ---------- Giant oysters: snap shut, open to show a pearl and spit it ----------
// Frames: shut, peeking, open with the pearl, open (pearl spat), snapping. 60 x 46, origin (30, 44).
function oyster(f) {
  const sh = { top: "#8a8a9a", topL: "#c8c8d8", line: "#2a2a36", in: "#f4d0dc", lip: "#e890a8" };
  const bottom = `<path d="M4 34 Q6 44 30 44 Q54 44 56 34 Q50 28 30 28 Q10 28 4 34 Z" fill="${sh.top}" stroke="${sh.line}" stroke-width="2"/>
    <path d="M10 38 q4 3 8 0 M24 40 q4 3 8 0 M38 38 q4 3 8 0" stroke="${sh.line}" stroke-width="1.2" fill="none"/>`;
  const ang = [0, -14, -38, -38, 0][f];
  const lid = `<g transform="rotate(${ang} 6 33)"><path d="M4 33 Q4 12 30 10 Q56 12 56 33 Q30 38 4 33 Z" fill="url(#oy)" stroke="${sh.line}" stroke-width="2"/>
    <path d="M30 12 L30 32 M18 15 L14 32 M42 15 L46 32 M10 22 L8 32 M50 22 L52 32" stroke="${sh.line}" stroke-width="1.3" opacity="0.7"/>
    <ellipse cx="22" cy="18" rx="8" ry="3.5" fill="${sh.topL}" opacity="0.8"/>
    ${f === 0 ? `<path d="M14 26 q4 -3 8 0 M38 26 q4 -3 8 0" stroke="${sh.line}" stroke-width="2.2" fill="none" stroke-linecap="round"/>` : ""}
    ${f === 4 ? `<path d="M16 22 l6 4 M44 22 l-6 4" stroke="${sh.line}" stroke-width="2.6" stroke-linecap="round"/>` : ""}</g>`;
  let inside = "";
  if (f >= 1 && f <= 3) {
    inside = `<path d="M6 33 Q30 ${f === 1 ? 26 : 16} 54 33 Q30 36 6 33 Z" fill="${sh.in}" stroke="${sh.lip}" stroke-width="1.5"/>`;
    if (f >= 2) inside += `<circle cx="22" cy="24" r="4" fill="#fff" stroke="${sh.line}" stroke-width="1.4"/><circle cx="23" cy="24.5" r="2" fill="#111"/>
      <circle cx="38" cy="24" r="4" fill="#fff" stroke="${sh.line}" stroke-width="1.4"/><circle cx="39" cy="24.5" r="2" fill="#111"/>
      <path d="M18 18 l7 3 M42 18 l-7 3" stroke="${sh.line}" stroke-width="1.8" stroke-linecap="round"/>`;
    if (f === 2) inside += `<circle cx="30" cy="30" r="5.5" fill="url(#pearl)" stroke="#8a8aa8" stroke-width="1"/>`;
    if (f === 3) inside += `<ellipse cx="30" cy="31" rx="5" ry="3" fill="#a02040"/>`;
  }
  const teeth = f === 4 ? `<path d="M10 33 l3 4 3 -4 3 4 3 -4 3 4 3 -4 3 4 3 -4 3 4 3 -4 3 4 3 -4" stroke="#fff" stroke-width="1.6" fill="none"/>` : "";
  return bottom + inside + lid + teeth;
}
const oysterDefs = `<linearGradient id="oy" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#b8b8c8"/><stop offset="1" stop-color="#6a6a7a"/></linearGradient>
  <radialGradient id="pearl" cx="0.35" cy="0.3" r="0.8"><stop offset="0" stop-color="#ffffff"/><stop offset="0.6" stop-color="#f0e8ff"/><stop offset="1" stop-color="#b8a8d8"/></radialGradient>`;
for (let f = 0; f < 5; f++) save("oyster_" + f, 60, 46, oyster(f), oysterDefs);
save("spr_pearl", 14, 14, `<circle cx="7" cy="7" r="6" fill="url(#pearl)" stroke="#6a5a8a" stroke-width="1.2"/><circle cx="5" cy="5" r="1.6" fill="#fff"/>`, oysterDefs);

// ---------- Giant mosquitoes: wings A, wings B, aiming the needle (to dive) ----------
// 64 x 50, origin (32, 25), facing right.
function mosquito(f) {
  const w = f === 1
    ? `<ellipse cx="24" cy="20" rx="16" ry="5" fill="#d8f0ff" opacity="0.7" stroke="#6a8aa8" transform="rotate(10 24 20)"/><ellipse cx="30" cy="19" rx="14" ry="4" fill="#d8f0ff" opacity="0.6" stroke="#6a8aa8"/>`
    : `<ellipse cx="22" cy="9" rx="14" ry="6" fill="#d8f0ff" opacity="0.7" stroke="#6a8aa8" transform="rotate(-30 22 9)"/><ellipse cx="30" cy="8" rx="12" ry="5" fill="#d8f0ff" opacity="0.6" stroke="#6a8aa8" transform="rotate(-15 30 8)"/>`;
  const legs = f === 2 ? "M26 28 L14 40 L10 48 M30 29 L26 44 L24 50 M34 28 L40 42 L46 48" : "M26 28 L18 38 L18 48 M30 29 L30 42 L28 50 M34 28 L40 38 L44 46";
  const needle = f === 2 ? `<path d="M50 22 L64 22" stroke="#2a1a1a" stroke-width="2.2" stroke-linecap="round"/>` : `<path d="M50 24 L61 31" stroke="#2a1a1a" stroke-width="2.2" stroke-linecap="round"/>`;
  return `<path d="${legs}" stroke="#2a1a1a" stroke-width="1.6" fill="none" stroke-linecap="round"/>
    <path d="M24 26 Q8 30 2 24 Q8 20 24 22 Z" fill="#7a5a3a" stroke="#2a1a1a" stroke-width="1.6"/>
    <path d="M8 23 V27 M13 22 V28 M18 22 V28" stroke="#c8a070" stroke-width="1.6"/>
    ${w}
    <ellipse cx="30" cy="24" rx="9" ry="7" fill="#5a4030" stroke="#2a1a1a" stroke-width="1.8"/>
    <circle cx="44" cy="22" r="7" fill="#5a4030" stroke="#2a1a1a" stroke-width="1.8"/>
    <circle cx="46" cy="20" r="3.6" fill="#ff3a3a" stroke="#2a1a1a" stroke-width="1"/><circle cx="47" cy="19" r="1.2" fill="#fff"/>
    <path d="M42 15 L48 17" stroke="#2a1a1a" stroke-width="2"/>${needle}
    <path d="M42 16 Q40 8 46 4 M45 16 Q46 9 52 7" stroke="#2a1a1a" stroke-width="1.2" fill="none"/>`;
}
for (let f = 0; f < 3; f++) save("mosquito_" + f, 64, 50, mosquito(f));

// ---------- Beach-goers under umbrellas (bounce on the umbrella to reach high places) ----------
// Each variant: open, folded onto the head ("ouch!"), folded and dizzy, open again with a bump.
// 112 x 108, origin (56, 108); the top of the open umbrella is 96 above the origin.
const people = [
  { skin: "#f0c8a0", hair: "#5a3a1a", top: "#ff5a3a", leg: "#3a6ad8", u1: "#ff3a3a", u2: "#ffffff", hat: "glasses" },
  { skin: "#a86a40", hair: "#1a0e06", top: "#ffd23a", leg: "#2a9a6a", u1: "#2a8ae8", u2: "#ffffff", hat: "sunhat" },
  { skin: "#e8b088", hair: "#d8d8d8", top: "#ffffff", leg: "#c84a8a", u1: "#ffc81a", u2: "#2aa84a", hat: "straw" },
];
function beachgoer(v, f) {
  const P = people[v];
  const open = f === 0 || f === 3;
  const line = "#2a1a10";
  const pole = `<path d="M56 106 L56 14" stroke="#e8e8e8" stroke-width="3.4"/><path d="M56 106 L56 14" stroke="#8a8a8a" stroke-width="1.2"/>`;
  // The deck chair and the person sitting in it, facing the viewer.
  let s = pole + `<path d="M30 106 L40 78 M82 106 L72 78 M34 104 L78 104" stroke="#8a5a2c" stroke-width="3.5" stroke-linecap="round"/>
    <path d="M34 80 L78 80 L74 100 L38 100 Z" fill="#f4f0e0" stroke="${line}" stroke-width="1.6"/><path d="M38 86 H74 M38 93 H74" stroke="#e05a5a" stroke-width="3"/>`;
  s += `<path d="M46 94 L44 106 M66 94 L68 106" stroke="${P.skin}" stroke-width="7" stroke-linecap="round"/>
    <path d="M44 106 h-5 M68 106 h5" stroke="${line}" stroke-width="3" stroke-linecap="round"/>
    <path d="M42 84 Q56 80 70 84 L68 96 L44 96 Z" fill="${P.leg}" stroke="${line}" stroke-width="1.5"/>
    <path d="M44 62 Q56 56 68 62 L70 86 L42 86 Z" fill="${P.top}" stroke="${line}" stroke-width="1.6"/>`;
  // Arms: relaxing (paper / drink), flailing up when hit, holding the head when dizzy.
  if (f === 1) s += `<path d="M44 66 L32 50 M68 66 L80 50" stroke="${P.skin}" stroke-width="6" stroke-linecap="round"/>`;
  else if (f === 2) s += `<path d="M44 66 Q36 58 44 46 M68 66 Q76 58 68 46" stroke="${P.skin}" stroke-width="6" fill="none" stroke-linecap="round"/>`;
  else s += `<path d="M44 66 L40 78 L52 76 M68 66 L72 78 L62 76" stroke="${P.skin}" stroke-width="6" fill="none" stroke-linecap="round" stroke-linejoin="round"/>
    ${v === 0 ? `<rect x="48" y="68" width="16" height="11" fill="#fff" stroke="${line}" stroke-width="1.2"/><path d="M56 68 V79 M50 71 h4 M58 71 h4 M50 74 h4 M58 74 h4" stroke="#555" stroke-width="0.8"/>` : ""}
    ${v === 1 ? `<path d="M50 70 L62 70 L60 80 L52 80 Z" fill="#e8a040" stroke="${line}" stroke-width="1.2"/><path d="M60 70 L64 62" stroke="#ff4a8a" stroke-width="1.6"/>` : ""}
    ${v === 2 ? `<circle cx="56" cy="74" r="7" fill="#7a4a1a" stroke="${line}" stroke-width="1.2"/><path d="M58 68 L62 60" stroke="#ff4a8a" stroke-width="1.6"/>` : ""}`;
  // The head.
  const hy = 50;
  s += `<circle cx="56" cy="${hy}" r="12" fill="${P.skin}" stroke="${line}" stroke-width="1.8"/>`;
  if (open) {
    s += `<path d="M44 ${hy - 4} Q46 ${hy - 16} 56 ${hy - 14} Q66 ${hy - 16} 68 ${hy - 4} Q62 ${hy - 10} 56 ${hy - 9} Q50 ${hy - 10} 44 ${hy - 4} Z" fill="${P.hair}"/>`;
    if (f === 0) {
      if (P.hat === "glasses") s += `<rect x="47" y="${hy - 3}" width="8" height="5" rx="2" fill="#111"/><rect x="57" y="${hy - 3}" width="8" height="5" rx="2" fill="#111"/><path d="M55 ${hy - 1} h2" stroke="#111" stroke-width="1.4"/>`;
      else s += `<path d="M49 ${hy - 1} q2 -2 4 0 M59 ${hy - 1} q2 -2 4 0" stroke="${line}" stroke-width="1.6" fill="none"/>`;
      s += `<path d="M51 ${hy + 5} q5 4 10 0" stroke="${line}" stroke-width="1.6" fill="none"/>`;
      if (P.hat === "sunhat") s += `<ellipse cx="56" cy="${hy - 9}" rx="20" ry="4" fill="#f4e0a0" stroke="${line}" stroke-width="1.3"/><path d="M46 ${hy - 10} Q56 ${hy - 26} 66 ${hy - 10} Z" fill="#f4e0a0" stroke="${line}" stroke-width="1.3"/><path d="M47 ${hy - 12} H65" stroke="#ff4a8a" stroke-width="2.4"/>`;
      if (P.hat === "straw") s += `<ellipse cx="56" cy="${hy - 9}" rx="17" ry="3.6" fill="#e8c860" stroke="${line}" stroke-width="1.3"/><rect x="48" y="${hy - 20}" width="16" height="11" rx="3" fill="#e8c860" stroke="${line}" stroke-width="1.3"/><path d="M48 ${hy - 12} H64" stroke="#3a6ad8" stroke-width="2.4"/>`;
    } else {
      // Back up again, with a bump and a plaster on the head, and a grumpy face.
      s += `<path d="M49 ${hy - 1} l4 1.5 M63 ${hy - 1} l-4 1.5" stroke="${line}" stroke-width="1.8"/><circle cx="51" cy="${hy + 1.5}" r="1.4" fill="${line}"/><circle cx="61" cy="${hy + 1.5}" r="1.4" fill="${line}"/>
        <path d="M51 ${hy + 7} q5 -3 10 0" stroke="${line}" stroke-width="1.6" fill="none"/>
        <ellipse cx="60" cy="${hy - 14}" rx="7" ry="5.5" fill="#ff9a9a" stroke="${line}" stroke-width="1.4"/>
        <g transform="rotate(-20 60 ${hy - 15})"><rect x="53" y="${hy - 17}" width="14" height="5" rx="2" fill="#f4dcb0" stroke="${line}" stroke-width="1"/></g>
        <g transform="rotate(40 60 ${hy - 15})"><rect x="53" y="${hy - 17}" width="14" height="5" rx="2" fill="#f4dcb0" stroke="${line}" stroke-width="1"/></g>`;
    }
    // The open canopy, in stripes.
    let c = `<path d="M4 40 Q10 14 56 12 Q102 14 108 40 Z" fill="${P.u1}" stroke="${line}" stroke-width="2"/>`;
    for (let k = 0; k < 4; k++) {
      const x1 = 4 + k * 26, x2 = x1 + 13;
      c += `<path d="M${x1 + 0.5} 40 Q${(x1 + 56) / 2} 20 56 12.5 Q${(x2 + 56) / 2} 20 ${x2} 40 Q${(x1 + x2) / 2} 44 ${x1 + 0.5} 40 Z" fill="${P.u2}"/>`;
    }
    c += `<path d="M4 40 Q10 14 56 12 Q102 14 108 40" stroke="${line}" stroke-width="2" fill="none"/>`;
    for (let i = 0; i < 8; i++) { const x = 4 + i * 13; c += `<path d="M${x} 40 Q${x + 6.5} 45 ${x + 13} 40" stroke="${line}" stroke-width="1.6" fill="${i % 2 ? P.u2 : P.u1}"/>`; }
    c += `<circle cx="56" cy="10" r="3.5" fill="#8a8a8a" stroke="${line}" stroke-width="1.2"/>`;
    s += c;
  } else {
    // Folded down over the poor person's head.
    s += `<path d="M56 18 Q66 30 70 66 Q56 72 42 66 Q46 30 56 18 Z" fill="${P.u1}" stroke="${line}" stroke-width="2"/>
      <path d="M56 19 Q60 40 60 69 M56 19 Q50 40 51 69" stroke="${P.u2}" stroke-width="4" fill="none"/>
      <path d="M56 18 Q66 30 70 66 Q56 72 42 66 Q46 30 56 18 Z" fill="none" stroke="${line}" stroke-width="2"/>
      <circle cx="56" cy="12" r="3.5" fill="#8a8a8a" stroke="${line}" stroke-width="1.2"/>`;
    if (f === 1) s += `<path d="M84 22 L88 40 M88 47 L88 49" stroke="#ff2a2a" stroke-width="4" stroke-linecap="round"/><path d="M22 30 l6 4 M20 40 l7 0 M24 50 l5 -3" stroke="${line}" stroke-width="2" stroke-linecap="round"/>`;
    else s += [[36, 20], [56, 6], [76, 20]].map(([x, y]) => `<path d="M${x} ${y - 6} l1.8 4 4.2 .4 -3.2 2.8 1 4.2 -3.8 -2.2 -3.8 2.2 1 -4.2 -3.2 -2.8 4.2 -.4 Z" fill="#ffe04a" stroke="${line}" stroke-width="1"/>`).join("");
  }
  return s;
}
for (let v = 0; v < 3; v++) for (let f = 0; f < 4; f++) save(`umbrella_${v * 4 + f}`, 112, 108, beachgoer(v, f));

// ---------- The wasp hive boss and its wasps ----------
// Hive frames: idle A, idle B, wind-up (red eyes, wasps pouring out), hurt.
// 150 x 160, origin (75, 82); hangs from the top (y 0) by a vine.
function hive(f) {
  const line = "#3a2a10";
  let s = `<path d="M75 2 Q120 10 132 58 Q142 110 110 146 Q75 162 40 146 Q8 110 18 58 Q30 10 75 2 Z" fill="url(#hv)" stroke="${line}" stroke-width="3"/>`;
  for (let k = 0; k < 7; k++) {
    const y = 20 + k * 18, w = 50 + Math.sin(((k + 1) / 8) * Math.PI) * 14;
    s += `<path d="M${75 - w} ${y + 8} Q75 ${y + 20} ${75 + w} ${y + 8}" stroke="#a88a4a" stroke-width="3" fill="none" opacity="0.8"/>`;
  }
  // The entrance at the bottom: a honeycomb round a hole.
  s += `<ellipse cx="75" cy="140" rx="22" ry="12" fill="#2a1a08" stroke="${line}" stroke-width="2"/>`;
  [[62, 136], [75, 132], [88, 136], [68, 144], [82, 144]].forEach(([x, y]) => { s += `<path d="M${x - 5} ${y} l2.5 -4.3 h5 l2.5 4.3 -2.5 4.3 h-5 Z" fill="#e8b830" stroke="${line}" stroke-width="1"/>`; });
  // The face: eye holes and a buzzing mouth.
  const red = f === 2;
  if (f === 3) s += `<path d="M42 62 l18 14 M60 62 l-18 14 M90 62 l18 14 M108 62 l-18 14" stroke="${line}" stroke-width="5" stroke-linecap="round"/>
    <path d="M56 106 Q75 94 94 106" stroke="${line}" stroke-width="5" fill="none"/><path d="M40 30 L52 44 L46 52 L58 60" stroke="${line}" stroke-width="2.5" fill="none"/>`;
  else s += `<ellipse cx="52" cy="70" rx="13" ry="11" fill="#1a0e04"/><ellipse cx="98" cy="70" rx="13" ry="11" fill="#1a0e04"/>
    <circle cx="${f === 1 ? 54 : 52}" cy="71" r="${red ? 6 : 4.5}" fill="${red ? "#ff3a1a" : "#ffd23a"}"/><circle cx="${f === 1 ? 100 : 98}" cy="71" r="${red ? 6 : 4.5}" fill="${red ? "#ff3a1a" : "#ffd23a"}"/>
    <path d="M36 52 L64 62 M114 52 L86 62" stroke="${line}" stroke-width="5" stroke-linecap="round"/>
    <path d="M52 100 Q75 ${red ? 122 : 112} 98 100 Q75 108 52 100 Z" fill="#1a0e04" stroke="${line}" stroke-width="2"/>`;
  // Little wasps crawling about on it (more pour out on the wind-up).
  const wsp = (x, y, r) => `<g transform="rotate(${r} ${x} ${y})"><ellipse cx="${x - 3}" cy="${y - 3}" rx="4" ry="2.4" fill="#e8f4ff" opacity="0.9"/><ellipse cx="${x}" cy="${y}" rx="6" ry="3.2" fill="#ffd21c" stroke="#1a1000" stroke-width="1"/><path d="M${x - 2} ${y - 3} V${y + 3} M${x + 2} ${y - 3} V${y + 3}" stroke="#1a1000" stroke-width="1.4"/></g>`;
  const spots = f === 2 ? [[30, 30, 20], [120, 40, -30], [20, 100, 60], [130, 110, -60], [60, 150, 90], [92, 154, 80], [75, 156, 95], [110, 140, 40], [40, 140, 130]]
    : (f === 1 ? [[40, 36, 30], [112, 90, -70], [70, 24, 10]] : [[36, 40, 40], [114, 84, -60], [84, 26, -10]]);
  spots.forEach(([x, y, r]) => { s += wsp(x, y, r); });
  return s;
}
const hiveDefs = `<radialGradient id="hv" cx="0.4" cy="0.35" r="0.75"><stop offset="0" stop-color="#e8d098"/><stop offset="0.6" stop-color="#c8a868"/><stop offset="1" stop-color="#8a6a32"/></radialGradient>`;
for (let f = 0; f < 4; f++) save("hive_" + f, 150, 160, hive(f), hiveDefs);
// A wasp soldier (wings A, wings B), 40 x 34, origin (20, 17), facing right.
function wasp(f) {
  const w = f === 0 ? `<ellipse cx="16" cy="6" rx="9" ry="5" fill="#e8f4ff" opacity="0.85" stroke="#7a9ab8" transform="rotate(-20 16 6)"/>`
    : `<ellipse cx="15" cy="12" rx="10" ry="3.4" fill="#e8f4ff" opacity="0.85" stroke="#7a9ab8"/>`;
  return `<path d="M14 22 L10 30 M20 23 L20 31 M25 22 L29 29" stroke="#1a1000" stroke-width="1.5"/>
    <path d="M2 18 Q2 12 12 13 L16 22 Q6 26 2 18 Z" fill="#ffd21c" stroke="#1a1000" stroke-width="1.6"/><path d="M2 18 L-1 19" stroke="#1a1000" stroke-width="2"/>
    <path d="M6 13 L6 23 M10 13 L10 24" stroke="#1a1000" stroke-width="2"/>
    ${w}<ellipse cx="20" cy="18" rx="6" ry="5" fill="#2a2000" stroke="#1a1000" stroke-width="1.4"/>
    <circle cx="30" cy="16" r="6" fill="#ffd21c" stroke="#1a1000" stroke-width="1.6"/><circle cx="32" cy="14.6" r="2.4" fill="#d01a1a"/>
    <path d="M28 9 L33 11" stroke="#1a1000" stroke-width="1.8"/><path d="M33 10 Q36 4 40 4" stroke="#1a1000" stroke-width="1.2" fill="none"/>`;
}
save("wasp_0", 40, 34, wasp(0));
save("wasp_1", 40, 34, wasp(1));
// A wasp arrow: a wasp shooting along with a speed streak (it points along +x). 50 x 20, origin (30, 10).
save("spr_wasp_arrow", 50, 20,
  `<path d="M0 10 L26 7 L26 13 Z" fill="#ffe680" opacity="0.6"/><path d="M4 10 H24" stroke="#fff" stroke-width="1.4" opacity="0.8"/>
   <ellipse cx="28" cy="6" rx="7" ry="3" fill="#e8f4ff" opacity="0.9" stroke="#7a9ab8"/>
   <ellipse cx="32" cy="10" rx="9" ry="4.6" fill="#ffd21c" stroke="#1a1000" stroke-width="1.4"/><path d="M29 6 V14 M33 5.6 V14.4" stroke="#1a1000" stroke-width="1.8"/>
   <circle cx="42" cy="10" r="4.4" fill="#ffd21c" stroke="#1a1000" stroke-width="1.4"/><circle cx="43.5" cy="9" r="1.6" fill="#d01a1a"/><path d="M46 10 L50 10" stroke="#1a1000" stroke-width="1.6"/>`);
// A whirlwind of wasps spinning along the sand (3 frames). 70 x 100, origin (35, 50).
function whirl(f) {
  let s = "";
  for (let k = 0; k < 6; k++) {
    const y = 92 - k * 16, w = 10 + k * 5.5;
    s += `<ellipse cx="${35 + Math.sin(k * 1.3 + f * 2.1) * 4}" cy="${y}" rx="${w}" ry="${4 + k * 0.6}" fill="none" stroke="#f4e6b0" stroke-width="3" opacity="0.75"/>`;
  }
  for (let k = 0; k < 10; k++) {
    const a = k * 2.4 + f * 2.1, y = 90 - k * 8.5, w = 10 + (90 - y) * 0.32;
    const x = 35 + Math.cos(a) * w, front = Math.sin(a) > 0;
    s += `<g opacity="${front ? 1 : 0.55}"><ellipse cx="${x}" cy="${y}" rx="4.6" ry="2.6" fill="#ffd21c" stroke="#1a1000" stroke-width="1"/><path d="M${x - 1.5} ${y - 2.5} V${y + 2.5}" stroke="#1a1000" stroke-width="1.4"/><ellipse cx="${x - 2}" cy="${y - 3.4}" rx="3" ry="1.6" fill="#fff" opacity="0.8"/></g>`;
  }
  s += `<ellipse cx="35" cy="96" rx="20" ry="4" fill="#c8a060" opacity="0.6"/>`;
  return s;
}
for (let f = 0; f < 3; f++) save("whirl_" + f, 70, 100, whirl(f));

Promise.all(jobs).then(() => console.log("made " + jobs.length + " images in " + OUT));
