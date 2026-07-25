// Renders the competing GamerGrove icon directions for review.
// Each concept is a self-contained hand-authored vector; the winner gets
// promoted into render.js as the single source of truth for all layers.
//
// Brand platform (decided): "Dein Ort" — a grove is a place, not a tree.
// Every mark here shows a bounded place with your games inside it.
// Palette: deep jade-black ground (under the canopy) + warm gold (the light
// that falls into the clearing) + parchment covers.
const { Resvg } = require('@resvg/resvg-js');
const fs = require('fs');
const path = require('path');

const OUT = process.argv[2] || path.join(__dirname, 'concepts');
fs.mkdirSync(OUT, { recursive: true });

const palette = `
  <linearGradient id="ground" x1="0" y1="0" x2="0.4" y2="1">
    <stop offset="0" stop-color="#12241F"/><stop offset="1" stop-color="#070F0D"/></linearGradient>
  <radialGradient id="light" cx="50%" cy="34%" r="60%">
    <stop offset="0" stop-color="#FFC46B" stop-opacity=".26"/>
    <stop offset="100%" stop-color="#FFC46B" stop-opacity="0"/></radialGradient>
  <linearGradient id="gold" x1="0" y1="0" x2="0.3" y2="1">
    <stop offset="0" stop-color="#FFD68F"/><stop offset="1" stop-color="#EE9A3C"/></linearGradient>`;

const backdrop = `
  <rect width="1024" height="1024" fill="url(#ground)"/>
  <rect width="1024" height="1024" fill="url(#light)"/>`;

// Standing cover cards — the collection that lives inside the place.
const covers = (cx, baseY, scale = 1, gold = 'url(#gold)') => {
  const w = 118 * scale, gap = 20 * scale;
  const h = [178 * scale, 250 * scale, 178 * scale];
  const xs = [cx - w - gap, cx, cx + w + gap];
  return xs
    .map((x, i) => {
      const fill = i === 1 ? gold : i === 0 ? '#F2EFE6' : '#C9C6BC';
      const rot = i === 0 ? -5 : i === 2 ? 5 : 0;
      return `<rect x="${x - w / 2}" y="${baseY - h[i]}" width="${w}" height="${h[i]}"
        rx="${26 * scale}" fill="${fill}" transform="rotate(${rot} ${x} ${baseY})"/>`;
    })
    .join('');
};

// ------------------------------------------------------------- A: Die Lichtung
// A clearing: the boundary is the grove, and it opens at the bottom — that
// gap is the way in. Doubles as a G without ever being a letter exercise.
const arcGap = (r, w, stroke, gapDeg, centerDeg = 90) => {
  const a0 = ((centerDeg + gapDeg) * Math.PI) / 180;
  const a1 = ((centerDeg - gapDeg + 360) * Math.PI) / 180;
  const p = (a) => `${(512 + r * Math.cos(a)).toFixed(1)} ${(512 + r * Math.sin(a)).toFixed(1)}`;
  return `<path d="M ${p(a0)} A ${r} ${r} 0 1 1 ${p(a1)}" fill="none"
    stroke="${stroke}" stroke-width="${w}" stroke-linecap="round"/>`;
};

const conceptA = `
  ${backdrop}
  <circle cx="512" cy="512" r="300" fill="#0E1F1A"/>
  ${arcGap(332, 58, 'url(#gold)', 30)}
  ${covers(512, 704, 1.14)}`;

// ------------------------------------------------------------------ B: Das Tor
// A threshold. You step into your grove; following someone means stepping
// into theirs. The strongest silhouette of the three at launcher size.
// A filled doorway reads as a threshold; a stroked one reads as a horseshoe.
const arch = (x0, x1, bottom, top, r) =>
  `M${x0} ${bottom} L${x0} ${top} a${r} ${r} 0 0 1 ${x1 - x0} 0 L${x1} ${bottom} Z`;

const conceptB = `
  ${backdrop}
  <path d="${arch(266, 758, 872, 512, 246)}" fill="url(#gold)"/>
  <path d="${arch(342, 682, 872, 512, 170)}" fill="#0E1F1A"/>
  ${covers(512, 848, 0.72)}`;

// ----------------------------------------------------------------- C: Der Claim
// A place marker whose head holds the collection: the most literal reading of
// "somewhere that is yours", and the easiest to read at 48dp.
const conceptC = `
  ${backdrop}
  <path d="M512 916 C 512 916 236 640 236 452 a276 276 0 1 1 552 0 C 788 640 512 916 512 916 Z"
    fill="url(#gold)"/>
  <circle cx="512" cy="446" r="192" fill="#0E1F1A"/>
  ${covers(512, 556, 0.66)}`;

const concepts = {
  a_lichtung: { title: 'A — Die Lichtung', svg: conceptA },
  b_tor: { title: 'B — Das Tor', svg: conceptB },
  c_claim: { title: 'C — Der Claim', svg: conceptC },
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

// Manifest so the contact sheet always matches the current concept set.
const manifest = Object.entries(concepts).map(([name, { title }]) => ({ name, title }));
fs.writeFileSync(path.join(OUT, 'manifest.json'), JSON.stringify({ sizes: SIZES.slice(1), concepts: manifest }, null, 2));
console.log('done ->', OUT);
