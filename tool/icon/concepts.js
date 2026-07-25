// Renders the competing GamerGrove icon directions for review.
// Each concept is a self-contained hand-authored vector; the winner gets
// promoted into render.js as the single source of truth for all layers.
//
// Brand platform (decided with the user): the gamer's cave — not a negative
// place but a safe one. Your own dark corner where you do what you love, and
// from which you dive into new worlds. That is also why the app is dark: the
// dark is the room, and the warm light is what happens in it.
//
// Direction (decided): the portal — a lit way through, standing in the dark.
// Open question these variants answer: the story is legible to us, but a
// stranger on a homescreen must read "games" without being told. Each variant
// carries a different games cue; the base carries none, as the control.
const { Resvg } = require('@resvg/resvg-js');
const fs = require('fs');
const path = require('path');

const OUT = process.argv[2] || path.join(__dirname, 'concepts');
fs.mkdirSync(OUT, { recursive: true });

const palette = `
  <linearGradient id="cave" x1="0" y1="0" x2="0.4" y2="1">
    <stop offset="0" stop-color="#13231F"/><stop offset="1" stop-color="#060C0B"/></linearGradient>
  <radialGradient id="spill" cx="50%" cy="56%" r="52%">
    <stop offset="0" stop-color="#FFB65A" stop-opacity=".34"/>
    <stop offset="100%" stop-color="#FFB65A" stop-opacity="0"/></radialGradient>
  <linearGradient id="world" x1="0" y1="0" x2="0" y2="1">
    <stop offset="0" stop-color="#FFE9BE"/><stop offset="1" stop-color="#F2A63C"/></linearGradient>
  <linearGradient id="gold" x1="0" y1="0" x2="0.3" y2="1">
    <stop offset="0" stop-color="#FFD68F"/><stop offset="1" stop-color="#EE9A3C"/></linearGradient>`;

const caveWall = `<rect width="1024" height="1024" fill="url(#cave)"/>`;
const floorSpill = `<path d="M300 892 L724 892 L806 962 L218 962 Z" fill="url(#gold)" opacity=".2"/>`;

// Nested arches receding to a bright core. Warm tones step up in brightness
// toward the middle so it reads as distance, not as concentric decoration.
const arch = (x0, x1, bottom, top) => {
  const r = (x1 - x0) / 2;
  return `M${x0} ${bottom} L${x0} ${top} a${r} ${r} 0 0 1 ${x1 - x0} 0 L${x1} ${bottom} Z`;
};

const RINGS = [
  { x0: 252, x1: 772, top: 512, fill: 'url(#gold)' },
  { x0: 322, x1: 702, top: 552, fill: '#2A1A0A' },
  { x0: 360, x1: 664, top: 582, fill: '#7A4A18' },
  { x0: 400, x1: 624, top: 626, fill: '#C9781F' },
  { x0: 436, x1: 588, top: 668, fill: '#F2A63C' },
  { x0: 468, x1: 556, top: 710, fill: '#FFF1D2' },
];

const tunnel = (rings = RINGS, step = null) =>
  rings
    .map((s) => {
      const d = step ? steppedArch(s.x0, s.x1, 892, s.top, step) : arch(s.x0, s.x1, 892, s.top);
      return `<path d="${d}" fill="${s.fill}"/>`;
    })
    .join('');

// Same arch quantised onto a coarse grid: an 8-bit doorway. On architecture
// the stepping reads as deliberate pixel art; on organic shapes it read as a
// ziggurat, which is why the cave direction died.
const steppedArch = (x0, x1, bottom, top, q) => {
  const r = (x1 - x0) / 2;
  const cx = (x0 + x1) / 2;
  const cols = Math.max(2, Math.round((x1 - x0) / q));
  const w = (x1 - x0) / cols;
  const pts = [`M${x0.toFixed(1)} ${bottom}`];
  for (let i = 0; i < cols; i++) {
    const x = x0 + (i + 0.5) * w;
    const dy = Math.sqrt(Math.max(0, r * r - (x - cx) ** 2));
    const y = Math.round((top - dy) / q) * q;
    pts.push(`L${(x0 + i * w).toFixed(1)} ${y}`, `L${(x0 + (i + 1) * w).toFixed(1)} ${y}`);
  }
  pts.push(`L${x1.toFixed(1)} ${bottom}`, 'Z');
  return pts.join(' ');
};

// ---------------------------------------------------------------------------
// Proper pixel build. The first stepped attempt quantised every arch against
// its own width, so the rings never shared a grid and the stepping read as an
// accident. Here the whole icon is authored on one 32x32 cell grid, filled
// flat (8-bit art has no smooth gradients) and lit with ordered dithering.
const GRID = 32;
const CELL = 1024 / GRID;

const cell = (x, y, w, h, fill) =>
  `<rect x="${x * CELL}" y="${y * CELL}" width="${w * CELL}" height="${h * CELL}" fill="${fill}"/>`;

// One rect per column, so every edge lands on the shared grid by construction.
const archColumns = (left, right, springY, floorY) => {
  const r = (right - left) / 2;
  const cx = (left + right) / 2;
  const cols = [];
  for (let x = left; x < right; x++) {
    const dx = x + 0.5 - cx;
    const dy = Math.sqrt(Math.max(0, r * r - dx * dx));
    cols.push({ x, top: Math.round(springY - dy) });
  }
  return cols;
};

const archCells = (left, right, springY, floorY, fill) =>
  archColumns(left, right, springY, floorY)
    .map(({ x, top }) => cell(x, top, 1, floorY - top, fill))
    .join('');

// Cells covered by an arch — used to keep the halo outside the portal itself.
const archMask = (left, right, springY, floorY) => {
  const set = new Set();
  for (const { x, top } of archColumns(left, right, springY, floorY)) {
    for (let y = top; y < floorY; y++) set.add(`${x},${y}`);
  }
  return set;
};

const FLOOR = 28;
const PORTAL = [
  { left: 8, right: 24, spring: 17, fill: '#F0C179' },
  { left: 10, right: 22, spring: 18, fill: '#2A1A0A' },
  { left: 11, right: 21, spring: 19, fill: '#7A4A18' },
  { left: 13, right: 19, spring: 20, fill: '#C9781F' },
  { left: 14, right: 18, spring: 21, fill: '#F2A63C' },
  { left: 15, right: 17, spring: 22, fill: '#FFF1D2' },
];

// Ordered dithering: how 8-bit art faked a glow, and it keeps the light on the
// grid. Warm, because it is gold bouncing off rock. Two earlier attempts show
// why the bands are grown outward from the silhouette: an arch-shaped halo
// spread over the canvas read as wallpaper, and one radiating from a point put
// the checker into vertical curtains, since the portal masks the middle.
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
  const solid = archMask(8, 24, 17, FLOOR);
  const bands = [solid];
  for (let i = 0; i < 4; i++) bands.push(grow(bands[bands.length - 1]));
  const shade = ['#3A331C', '#282311', '#1B1D11', '#13180F'];
  const out = [];
  for (let b = 1; b < bands.length; b++) {
    for (const k of bands[b]) {
      if (bands[b - 1].has(k)) continue;
      const [x, y] = k.split(',').map(Number);
      if (x < 0 || y < 0 || x >= GRID || y >= GRID) continue;
      const lit = b <= 2 ? (x + y) % 2 === 0 : x % 2 === 0 && y % 2 === 0;
      if (lit) out.push(cell(x, y, 1, 1, shade[b - 1]));
    }
  }
  return out.join('');
};

// Light pooling out of the doorway, in steps rather than a soft cone.
const threshold = [
  cell(9, FLOOR, 14, 1, '#8A5F2A'),
  cell(7, FLOOR + 1, 18, 1, '#4A3418'),
].join('');

const pixelPortal = `
  <rect width="1024" height="1024" fill="#0B1614"/>
  ${dither()}
  ${threshold}
  ${PORTAL.map((p) => archCells(p.left, p.right, p.spring, FLOOR, p.fill)).join('')}`;

const SILHOUETTE = '#100A03';

// Blocky avatar on the threshold: you, about to step through. Drawn on a
// 26px grid so it stays visibly pixel-made.
const hero = (() => {
  const u = 24, x = 512, base = 892;
  // cx/top in grid units, top measured upward from the floor so nothing can
  // sink through it.
  const px = (cx, top, w, h) =>
    `<rect x="${x + cx * u - (w * u) / 2}" y="${base - top * u}" width="${w * u}" height="${h * u}"/>`;
  return `<g fill="${SILHOUETTE}">
    ${px(0, 9, 3.5, 3)}
    ${px(0, 6, 4, 4)}
    ${px(-2.5, 5.5, 1, 2.5)}
    ${px(2.5, 5.5, 1, 2.5)}
    ${px(-1, 2, 1.5, 2)}
    ${px(1, 2, 1.5, 2)}
  </g>`;
})();

// A pad silhouette is the one cue nobody needs the story to decode.
const controller = `<g fill="${SILHOUETTE}" transform="translate(512 806) scale(0.74)">
  <path d="M-150 -46 C -96 -70 96 -70 150 -46 C 186 -30 196 46 166 66
           C 140 82 112 56 92 34 L -92 34 C -112 56 -140 82 -166 66
           C -196 46 -186 -30 -150 -46 Z"/>
  <g fill="#FFE9BE">
    <rect x="-104" y="-22" width="20" height="60" rx="6"/>
    <rect x="-124" y="-2" width="60" height="20" rx="6"/>
    <circle cx="86" cy="-12" r="13"/><circle cx="112" cy="14" r="13"/>
    <circle cx="60" cy="14" r="13"/><circle cx="86" cy="40" r="13"/>
  </g>
</g>`;

// The collection standing in the doorway, backlit.
const covers = `<g fill="${SILHOUETTE}">
  <rect x="404" y="716" width="66" height="176" rx="16" transform="rotate(-6 437 892)"/>
  <rect x="479" y="668" width="66" height="224" rx="16"/>
  <rect x="554" y="716" width="66" height="176" rx="16" transform="rotate(6 587 892)"/>
</g>`;

const scene = (inner) => `${caveWall}<rect width="1024" height="1024" fill="url(#spill)"/>${inner}`;

const concepts = {
  v0_basis: {
    title: 'Basis — Portal',
    cue: 'Kein Spiele-Signal (Kontrollgruppe)',
    svg: scene(`${tunnel()}${floorSpill}`),
  },
  v1_pixel: {
    title: 'V1 — Pixel-Portal (alt)',
    cue: 'Erster Wurf: Stufung pro Bogen gerundet, Verläufe und weicher Schein darunter',
    svg: scene(`${tunnel(RINGS, 32)}${floorSpill}`),
  },
  v1b_pixel_fein: {
    title: 'V1b — Pixel-Portal, sauber',
    cue: 'Ein gemeinsames 32×32-Raster, flache Flächen, gedithertes Licht, Stufen zur Schwelle',
    svg: pixelPortal,
  },
  v2_held: {
    title: 'V2 — Der Spieler',
    cue: 'Pixel-Figur an der Schwelle: du gehst hindurch',
    svg: scene(`${tunnel()}${hero}${floorSpill}`),
  },
  v3_controller: {
    title: 'V3 — Der Controller',
    cue: 'Gamepad im Licht: das eindeutigste Signal, aber auch das erwartbarste',
    svg: scene(`${tunnel()}${controller}${floorSpill}`),
  },
  v4_sammlung: {
    title: 'V4 — Die Sammlung',
    cue: 'Cover als Silhouetten: sagt „Spielesammlung“, nicht nur „Spiel“',
    svg: scene(`${tunnel(RINGS.slice(0, 5))}${covers}${floorSpill}`),
  },
};

const wrap = (body) =>
  `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024" width="1024" height="1024">
     <defs>${palette}</defs>${body}</svg>`;

// Launcher-masked variant: approximates the squircle Android crops icons to.
const wrapMasked = (body) =>
  `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024" width="1024" height="1024">
     <defs>${palette}<clipPath id="mask"><rect width="1024" height="1024" rx="232"/></clipPath></defs>
     <g clip-path="url(#mask)">${body}</g></svg>`;

const SIZES = [1024, 192, 96, 72, 48];

for (const [name, { svg: body }] of Object.entries(concepts)) {
  fs.writeFileSync(path.join(OUT, `${name}.svg`), wrap(body));
  for (const size of SIZES) {
    const svg = size === 1024 ? wrap(body) : wrapMasked(body);
    const r = new Resvg(svg, { fitTo: { mode: 'width', value: size } });
    fs.writeFileSync(path.join(OUT, `${name}_${size}.png`), r.render().asPng());
  }
  console.log('rendered', name);
}

// Manifest so the contact sheet and the review page track the concept set.
const manifest = Object.entries(concepts).map(([name, { title, cue }]) => ({ name, title, cue }));
fs.writeFileSync(
  path.join(OUT, 'manifest.json'),
  JSON.stringify({ sizes: SIZES.slice(1), concepts: manifest }, null, 2),
);
console.log('done ->', OUT);
