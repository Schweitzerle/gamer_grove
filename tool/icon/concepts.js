// Renders the competing GamerGrove icon directions for review.
// Each concept is a self-contained hand-authored vector; the winner gets
// promoted into render.js as the single source of truth for all layers.
const { Resvg } = require('@resvg/resvg-js');
const fs = require('fs');
const path = require('path');

const OUT = process.argv[2] || path.join(__dirname, 'concepts');
fs.mkdirSync(OUT, { recursive: true });

// ---------------------------------------------------------------- A: Canopy
// A tree whose crown is built from game tiles. Silhouette carries the small
// sizes, the card grid only reveals itself when the icon is big.
const canopyDefs = `
  <linearGradient id="aBg" x1="0" y1="0" x2="0.6" y2="1">
    <stop offset="0" stop-color="#0F3A2B"/><stop offset="1" stop-color="#06201A"/></linearGradient>
  <radialGradient id="aGlow" cx="50%" cy="38%" r="60%">
    <stop offset="0" stop-color="#6EE7A8" stop-opacity=".22"/>
    <stop offset="100%" stop-color="#6EE7A8" stop-opacity="0"/></radialGradient>
  <linearGradient id="aLeaf" x1="0" y1="0" x2="0.4" y2="1">
    <stop offset="0" stop-color="#5BE49B"/><stop offset="1" stop-color="#9BE04F"/></linearGradient>
  <linearGradient id="aLeaf2" x1="0" y1="0" x2="0.4" y2="1">
    <stop offset="0" stop-color="#34C77F"/><stop offset="1" stop-color="#6FCB52"/></linearGradient>
  <linearGradient id="aTrunk" x1="0" y1="0" x2="1" y2="0">
    <stop offset="0" stop-color="#C98A4E"/><stop offset="1" stop-color="#9A6234"/></linearGradient>`;

const tile = (cx, cy, fill, rot = 0, s = 206) =>
  `<rect x="${cx - s / 2}" y="${cy - s / 2}" width="${s}" height="${s}" rx="46"
     fill="${fill}" transform="rotate(${rot} ${cx} ${cy})"/>`;

// Overlapping tiles, distinguished by tone rather than by gaps: the crown
// stays one solid silhouette at 48dp but resolves into cards when large.
const canopyCrown = `
  ${tile(352, 396, 'url(#aLeaf2)', -6, 224)}
  ${tile(672, 396, 'url(#aLeaf2)', 6, 224)}
  ${tile(512, 286, 'url(#aLeaf)', 0, 246)}
  ${tile(412, 536, '#F3FBEF', -4, 214)}
  ${tile(614, 536, '#FFC46B', 4, 214)}
  ${tile(512, 430, 'url(#aLeaf)', 0, 236)}`;

const canopyTrunk = `
  <path d="M462 604 L562 604 L590 872 a30 30 0 0 1 -30 34 L464 906 a30 30 0 0 1 -30 -34 Z"
    fill="url(#aTrunk)"/>`;

const conceptA = `
  <rect width="1024" height="1024" fill="url(#aBg)"/>
  <rect width="1024" height="1024" fill="url(#aGlow)"/>
  ${canopyTrunk}${canopyCrown}`;

// ------------------------------------------------------------- B: Heartwood
// Growth rings of a cut trunk, opened into a G. One green shoot at the core:
// the collection is still alive, not an archive.
const heartDefs = `
  <linearGradient id="bBg" x1="0" y1="0" x2="0.5" y2="1">
    <stop offset="0" stop-color="#2A1C0E"/><stop offset="1" stop-color="#150E06"/></linearGradient>
  <radialGradient id="bGlow" cx="50%" cy="50%" r="58%">
    <stop offset="0" stop-color="#F2B45C" stop-opacity=".20"/>
    <stop offset="100%" stop-color="#F2B45C" stop-opacity="0"/></radialGradient>
  <linearGradient id="bRing" x1="0" y1="0" x2="1" y2="1">
    <stop offset="0" stop-color="#FFD79A"/><stop offset="1" stop-color="#E08A3C"/></linearGradient>`;

// Arc with a wedge cut on the right — the counter of the G.
const ring = (r, w, stroke, gapDeg) => {
  const a = (gapDeg * Math.PI) / 180;
  const x1 = 512 + r * Math.cos(a), y1 = 512 + r * Math.sin(a);
  const x2 = 512 + r * Math.cos(-a), y2 = 512 + r * Math.sin(-a);
  return `<path d="M ${x1.toFixed(1)} ${y1.toFixed(1)} A ${r} ${r} 0 1 1 ${x2.toFixed(1)} ${y2.toFixed(1)}"
    fill="none" stroke="${stroke}" stroke-width="${w}" stroke-linecap="round"/>`;
};

const conceptB = `
  <rect width="1024" height="1024" fill="url(#bBg)"/>
  <rect width="1024" height="1024" fill="url(#bGlow)"/>
  ${ring(352, 64, 'url(#bRing)', 32)}
  ${ring(246, 56, '#C9762F', 32)}
  <rect x="470" y="482" width="336" height="60" rx="30" fill="url(#bRing)"/>
  <g transform="translate(470 512) scale(1.9)">
    <path d="M0 66 C -9 8 -9 -24 0 -68 C 9 -24 9 8 0 66 Z" fill="#7FD168"/>
    <path d="M0 -6 C -36 -18 -55 -46 -57 -80 C -21 -74 -4 -46 0 -6 Z" fill="#5FB84E"/>
    <path d="M0 22 C 32 12 48 -12 50 -42 C 18 -36 4 -14 0 22 Z" fill="#9BE04F"/>
  </g>`;

// ---------------------------------------------------------- C: Standing Three
// Three covers stood upright on open ground like a small stand of trees —
// the Top 3 as the literal shape of the mark.
const standDefs = `
  <linearGradient id="cBg" x1="0" y1="0" x2="0.4" y2="1">
    <stop offset="0" stop-color="#123240"/><stop offset="1" stop-color="#08191F"/></linearGradient>
  <radialGradient id="cGlow" cx="50%" cy="30%" r="62%">
    <stop offset="0" stop-color="#5FD3C2" stop-opacity=".22"/>
    <stop offset="100%" stop-color="#5FD3C2" stop-opacity="0"/></radialGradient>
  <linearGradient id="cGold" x1="0" y1="0" x2="0.3" y2="1">
    <stop offset="0" stop-color="#FFD98A"/><stop offset="1" stop-color="#F0A244"/></linearGradient>`;

const card = (cx, top, h, fill, rot, w = 214) =>
  `<rect x="${cx - w / 2}" y="${top}" width="${w}" height="${h}" rx="40"
     fill="${fill}" transform="rotate(${rot} ${cx} ${top + h})"/>`;

const conceptC = `
  <rect width="1024" height="1024" fill="url(#cBg)"/>
  <rect width="1024" height="1024" fill="url(#cGlow)"/>
  <path d="M104 802 Q512 736 920 802 L920 834 Q512 768 104 834 Z" fill="#2C6B70" opacity=".85"/>
  ${card(258, 452, 350, '#E9F2EE', -11)}
  ${card(766, 452, 350, '#C9DBD6', 11)}
  ${card(512, 300, 502, 'url(#cGold)', 0, 226)}
  <g transform="translate(512 262) scale(1.75)">
    <path d="M0 44 C -7 12 -7 -16 0 -48 C 7 -16 7 12 0 44 Z" fill="#7FD168"/>
    <path d="M0 -4 C -32 -14 -47 -38 -49 -66 C -17 -60 -4 -34 0 -4 Z" fill="#5FB84E"/>
    <path d="M0 16 C 28 8 41 -12 43 -38 C 15 -32 3 -12 0 16 Z" fill="#9BE04F"/>
  </g>`;

const concepts = {
  a_canopy: { defs: canopyDefs, body: conceptA },
  b_heartwood: { defs: heartDefs, body: conceptB },
  c_standing_three: { defs: standDefs, body: conceptC },
};

const wrap = (c) =>
  `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024" width="1024" height="1024">
     <defs>${c.defs}</defs>${c.body}</svg>`;

// Launcher-masked variant: approximates the squircle Android crops icons to.
const wrapMasked = (c) =>
  `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024" width="1024" height="1024">
     <defs>${c.defs}<clipPath id="mask"><rect width="1024" height="1024" rx="232"/></clipPath></defs>
     <g clip-path="url(#mask)">${c.body}</g></svg>`;

const SIZES = [1024, 192, 96, 72, 48];

for (const [name, c] of Object.entries(concepts)) {
  fs.writeFileSync(path.join(OUT, `${name}.svg`), wrap(c));
  for (const size of SIZES) {
    const svg = size === 1024 ? wrap(c) : wrapMasked(c);
    const r = new Resvg(svg, { fitTo: { mode: 'width', value: size } });
    fs.writeFileSync(path.join(OUT, `${name}_${size}.png`), r.render().asPng());
  }
  console.log('rendered', name);
}
console.log('done ->', OUT);
