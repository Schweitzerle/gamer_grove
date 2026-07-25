// Rasterizes the locked GamerGrove "Pixel Portal" icon into every launcher and
// splash layer using @resvg/resvg-js. This file is the single source of truth
// for the mark — edit the grid here, never the generated PNGs.
//
//   node render.js <project_root>
//
// The icon is authored on one 32x32 cell grid: flat fills, no gradients, and
// ordered dithering for the glow, the way 8-bit art actually worked. Anything
// quantised against its own local grid stops lining up and reads as an
// accident rather than a decision.
const { Resvg } = require('@resvg/resvg-js');
const fs = require('fs');
const path = require('path');

const OUT = process.argv[2];
if (!OUT) {
  console.error('usage: node render.js <project_root>');
  process.exit(1);
}

const SIZE = 1024;
const GRID = 32;
const CELL = SIZE / GRID;

// Locked palette — mirrored in README.md and, later, in the app's theme.
const C = {
  cave: '#0B1614', // the room you sit in
  frame: '#F0C179', // the doorway, lit from within
  shadow: '#2A1A0A', // the mouth of the tunnel
  deep: '#7A4A18',
  mid: '#C9781F',
  near: '#F2A63C',
  core: '#FFF1D2', // the world at the far end
  sillLit: '#8A5F2A',
  sillDim: '#4A3418',
  glow: ['#3A331C', '#282311', '#1B1D11', '#13180F'],
};

const cell = (x, y, w, h, fill) =>
  `<rect x="${x * CELL}" y="${y * CELL}" width="${w * CELL}" height="${h * CELL}" fill="${fill}"/>`;

// One rect per column, so every edge lands on the shared grid by construction.
const archColumns = (left, right, springY) => {
  const r = (right - left) / 2;
  const cx = (left + right) / 2;
  const cols = [];
  for (let x = left; x < right; x++) {
    const dx = x + 0.5 - cx;
    cols.push({ x, top: Math.round(springY - Math.sqrt(Math.max(0, r * r - dx * dx))) });
  }
  return cols;
};

const archCells = (left, right, springY, floorY, fill) =>
  archColumns(left, right, springY)
    .map(({ x, top }) => cell(x, top, 1, floorY - top, fill))
    .join('');

const archMask = (left, right, springY, floorY) => {
  const set = new Set();
  for (const { x, top } of archColumns(left, right, springY)) {
    for (let y = top; y < floorY; y++) set.add(`${x},${y}`);
  }
  return set;
};

const FLOOR = 28;
const PORTAL = [
  { left: 8, right: 24, spring: 17, fill: C.frame },
  { left: 10, right: 22, spring: 18, fill: C.shadow },
  { left: 11, right: 21, spring: 19, fill: C.deep },
  { left: 13, right: 19, spring: 20, fill: C.mid },
  { left: 14, right: 18, spring: 21, fill: C.near },
  { left: 15, right: 17, spring: 22, fill: C.core },
];

const portal = PORTAL.map((p) => archCells(p.left, p.right, p.spring, FLOOR, p.fill)).join('');

// Light pooling out of the doorway, in steps rather than a soft cone.
const SILL = [
  { x: 9, y: FLOOR, w: 14, fill: C.sillLit },
  { x: 7, y: FLOOR + 1, w: 18, fill: C.sillDim },
];
const sill = SILL.map((s) => cell(s.x, s.y, s.w, 1, s.fill)).join('');

// Ordered dithering, grown outward from the silhouette so the glow follows the
// shape. Radiating from a point instead puts the checker into curtains beside
// the portal, because the portal masks the middle.
const grow = (mask) => {
  const next = new Set(mask);
  for (const k of mask) {
    const [x, y] = k.split(',').map(Number);
    next.add(`${x + 1},${y}`);
    next.add(`${x - 1},${y}`);
    next.add(`${x},${y + 1}`);
    next.add(`${x},${y - 1}`);
  }
  return next;
};

const dither = () => {
  const bands = [archMask(8, 24, 17, FLOOR)];
  for (let i = 0; i < C.glow.length; i++) bands.push(grow(bands[bands.length - 1]));
  const out = [];
  for (let b = 1; b < bands.length; b++) {
    for (const k of bands[b]) {
      if (bands[b - 1].has(k)) continue;
      const [x, y] = k.split(',').map(Number);
      const lit = b <= 2 ? (x + y) % 2 === 0 : x % 2 === 0 && y % 2 === 0;
      if (lit) out.push(cell(x, y, 1, 1, C.glow[b - 1]));
    }
  }
  return out.join('');
};

// --- Safe zone -------------------------------------------------------------
// Android composites two 108dp layers and crops with a mask that is only
// guaranteed to keep the inner 72dp (66%). Masks range from squircles to full
// circles (Pixel), so the mark is fitted by its diagonal — fitting the bounding
// box alone would let a circular mask bite the corners off the arch legs.
const MOTIF = { x0: 7, y0: 9, x1: 25, y1: FLOOR + 2 };
// 72/108 is what Android guarantees; Google's own guidance is to keep key
// content inside 66/108, so the mark is fitted to that instead of grazing the
// hard limit. Fitting exactly to 0.66 left 6px of margin on a 1024px layer.
const SAFE = 66 / 108;

const safeZoneTransform = () => {
  const w = (MOTIF.x1 - MOTIF.x0) * CELL;
  const h = (MOTIF.y1 - MOTIF.y0) * CELL;
  const cx = ((MOTIF.x0 + MOTIF.x1) / 2) * CELL;
  const cy = ((MOTIF.y0 + MOTIF.y1) / 2) * CELL;
  const scale = (SAFE * SIZE) / Math.hypot(w, h);
  const c = SIZE / 2;
  return `translate(${c} ${c}) scale(${scale.toFixed(4)}) translate(${-cx} ${-cy})`;
};

const safe = (inner) => `<g transform="${safeZoneTransform()}">${inner}</g>`;

// --- Monochrome ------------------------------------------------------------
// Android 13 themed icons tint a single-colour layer, so shape is all there
// is: the frame as a ring, plus the light at the end, plus the sill to stand
// on. Drawn through a mask because the tunnel has to be a hole, not a fill.
const monochrome = `
  <mask id="mono" maskUnits="userSpaceOnUse" x="0" y="0" width="${SIZE}" height="${SIZE}">
    <rect width="${SIZE}" height="${SIZE}" fill="black"/>
    ${archCells(8, 24, 17, FLOOR, 'white')}
    ${archCells(10, 22, 18, FLOOR, 'black')}
    ${archCells(14, 18, 21, FLOOR, 'white')}
    ${cell(9, FLOOR, 14, 1, 'white')}
  </mask>
  <rect width="${SIZE}" height="${SIZE}" fill="#FFFFFF" mask="url(#mono)"/>`;

const ground = `<rect width="${SIZE}" height="${SIZE}" fill="${C.cave}"/>`;

const layers = {
  // Full composed icon (iOS, legacy Android, web, store listing) — full bleed.
  'assets/icon/app_icon.png': { body: `${ground}${dither()}${sill}${portal}` },
  // Adaptive background: flat ground plus the glow, positioned to match the
  // foreground so the two line up once Android stacks them.
  'assets/icon/app_icon_background.png': { body: `${ground}${safe(dither())}` },
  // Adaptive foreground: the mark itself, inside the safe zone.
  'assets/icon/app_icon_foreground.png': { body: safe(`${sill}${portal}`) },
  // Android 13 themed monochrome layer.
  'assets/icon/app_icon_monochrome.png': { body: safe(monochrome) },
  // Splash mark — sits on the splash colour, so no ground of its own.
  'assets/splash/splash_logo.png': { body: `${dither()}${sill}${portal}` },
  // Android 12+ splash: the system expects a 1152px canvas and only shows the
  // inner third, so the safe-zone composition is reused at that size.
  'assets/splash/splash_logo_android12.png': {
    body: safe(`${dither()}${sill}${portal}`),
    size: 1152,
  },
};

for (const [rel, { body, size = SIZE }] of Object.entries(layers)) {
  const svg = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${SIZE} ${SIZE}" width="${SIZE}" height="${SIZE}">${body}</svg>`;
  const dst = path.join(OUT, rel);
  fs.mkdirSync(path.dirname(dst), { recursive: true });
  const r = new Resvg(svg, {
    fitTo: { mode: 'width', value: size },
    background: 'rgba(0,0,0,0)',
  });
  fs.writeFileSync(dst, r.render().asPng());
  console.log('wrote', rel, `${size}px`);
}
console.log('done');
