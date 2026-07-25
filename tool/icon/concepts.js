// Renders the competing GamerGrove icon directions for review.
// Each concept is a self-contained hand-authored vector; the winner gets
// promoted into render.js as the single source of truth for all layers.
//
// Brand platform (decided with the user): the gamer's cave — not a negative
// place but a safe one. Your own dark corner where you do what you love, and
// from which you dive into new worlds. That is why the app is dark: the dark
// is the room, and the warm light is what happens in it.
//
// Palette: near-black jade (the cave) + warm gold (the light / the world) +
// parchment (the collection).
const { Resvg } = require('@resvg/resvg-js');
const fs = require('fs');
const path = require('path');

const OUT = process.argv[2] || path.join(__dirname, 'concepts');
fs.mkdirSync(OUT, { recursive: true });

const palette = `
  <linearGradient id="cave" x1="0" y1="0" x2="0.4" y2="1">
    <stop offset="0" stop-color="#13231F"/><stop offset="1" stop-color="#060C0B"/></linearGradient>
  <radialGradient id="spill" cx="50%" cy="52%" r="52%">
    <stop offset="0" stop-color="#FFB65A" stop-opacity=".34"/>
    <stop offset="100%" stop-color="#FFB65A" stop-opacity="0"/></radialGradient>
  <linearGradient id="world" x1="0" y1="0" x2="0" y2="1">
    <stop offset="0" stop-color="#FFE3A8"/><stop offset="0.55" stop-color="#FFB65A"/>
    <stop offset="1" stop-color="#EE8A3C"/></linearGradient>
  <linearGradient id="gold" x1="0" y1="0" x2="0.3" y2="1">
    <stop offset="0" stop-color="#FFD68F"/><stop offset="1" stop-color="#EE9A3C"/></linearGradient>
  <linearGradient id="screen" x1="0" y1="0" x2="0.2" y2="1">
    <stop offset="0" stop-color="#FFE7B4"/><stop offset="1" stop-color="#F5A94B"/></linearGradient>`;

const caveWall = `<rect width="1024" height="1024" fill="url(#cave)"/>`;

// --------------------------------------------------------------- A: Die Höhle
// Seen from inside: the dark is where you sit, the opening is the world you
// dive into. The mouth is stepped on a coarse grid — at icon size it reads as
// rock, up close it reads as pixels. That is the gaming signal, without neon.
// Stepping the outline turned it into a ziggurat: a bright shape standing on
// the floor reads as a mountain, never as a hole. The opening has to be
// irregular but smooth, and rock has to close around it on every side.
const mouth = `M262 786
  C 258 640 286 512 344 424
  C 402 336 470 286 528 288
  C 596 290 664 340 712 430
  C 758 516 776 646 772 786 Z`;

const conceptA = `
  ${caveWall}
  <defs><clipPath id="mouthClip"><path d="${mouth}"/></clipPath></defs>
  <g clip-path="url(#mouthClip)">
    <rect width="1024" height="1024" fill="url(#world)"/>
    <circle cx="530" cy="470" r="88" fill="#FFF6DE" opacity=".95"/>
    <path d="M240 700 L360 618 L470 690 L580 606 L700 686 L790 640 L790 800 L240 800 Z"
      fill="#1C4038" opacity=".7"/>
  </g>
  <path d="${mouth}" fill="none" stroke="#24443C" stroke-width="16" opacity=".8"/>
  <rect width="1024" height="1024" fill="url(#spill)"/>
  <path d="M200 786 L836 786 L906 872 L128 872 Z" fill="url(#gold)" opacity=".14"/>`;

// -------------------------------------------------------------- B: Das Portal
// A built gateway standing in the dark, its opening full of light: the moment
// before you step through. Same threshold idea as before, but now the opening
// glows instead of holding covers — worlds, not storage.
const arch = (x0, x1, bottom, top, r) =>
  `M${x0} ${bottom} L${x0} ${top} a${r} ${r} 0 0 1 ${x1 - x0} 0 L${x1} ${bottom} Z`;

// Nested arches receding to a bright core: a tunnel, not a picture frame.
// Sun-over-hills inside an arch is the universal "image missing" glyph — the
// depth stack is what keeps this reading as a way through.
const RINGS = [
  { x0: 252, x1: 772, bottom: 892, top: 512, r: 260, fill: 'url(#gold)' },
  { x0: 320, x1: 704, bottom: 892, top: 548, r: 192, fill: '#3A2A16' },
  { x0: 356, x1: 668, bottom: 892, top: 578, r: 156, fill: '#8A5F2A' },
  { x0: 396, x1: 628, bottom: 892, top: 622, r: 116, fill: '#D89544' },
  { x0: 434, x1: 590, bottom: 892, top: 664, r: 78, fill: 'url(#world)' },
  { x0: 466, x1: 558, bottom: 892, top: 706, r: 46, fill: '#FFF6DE' },
];

const tunnel = (rings) =>
  rings.map((s) => `<path d="${arch(s.x0, s.x1, s.bottom, s.top, s.r)}" fill="${s.fill}"/>`).join('');

const floorSpill = `<path d="M300 892 L724 892 L806 962 L218 962 Z" fill="url(#gold)" opacity=".2"/>`;

const conceptB = `
  ${caveWall}
  <rect width="1024" height="1024" fill="url(#spill)"/>
  ${tunnel(RINGS)}
  ${floorSpill}`;

// B2 — the collection standing in the doorway, backlit. Dark covers against
// the light read at any size; bright covers against bright light do not.
const conceptB2 = `
  ${caveWall}
  <rect width="1024" height="1024" fill="url(#spill)"/>
  ${tunnel(RINGS.slice(0, 5))}
  <g fill="#120A04">
    <rect x="404" y="716" width="66" height="176" rx="16" transform="rotate(-6 437 892)"/>
    <rect x="479" y="668" width="66" height="224" rx="16"/>
    <rect x="554" y="716" width="66" height="176" rx="16" transform="rotate(6 587 892)"/>
  </g>
  ${floorSpill}`;

// B3 — two rings instead of five: the same gateway with far less to lose at
// launcher size.
const conceptB3 = `
  ${caveWall}
  <rect width="1024" height="1024" fill="url(#spill)"/>
  ${tunnel([
    { x0: 252, x1: 772, bottom: 892, top: 512, r: 260, fill: 'url(#gold)' },
    { x0: 336, x1: 688, bottom: 892, top: 556, r: 176, fill: '#241608' },
    { x0: 396, x1: 628, bottom: 892, top: 610, r: 116, fill: 'url(#world)' },
  ])}
  ${floorSpill}`;

// ------------------------------------------------------------ C: Die Sammlung
// The den from the inside, with what is actually in it: your games, lit. The
// ceiling closes over them, so the dark is shelter rather than emptiness.
const covers = (cx, baseY, scale) => {
  const w = 118 * scale, gap = 22 * scale;
  const h = [196 * scale, 272 * scale, 196 * scale];
  return [cx - w - gap, cx, cx + w + gap]
    .map((x, i) => {
      const fill = i === 1 ? 'url(#world)' : i === 0 ? '#F4EFE2' : '#CFC7B4';
      const rot = i === 0 ? -6 : i === 2 ? 6 : 0;
      return `<rect x="${x - w / 2}" y="${baseY - h[i]}" width="${w}" height="${h[i]}"
        rx="${26 * scale}" fill="${fill}" transform="rotate(${rot} ${x} ${baseY})"/>`;
    })
    .join('');
};

const conceptC = `
  ${caveWall}
  <ellipse cx="512" cy="612" rx="330" ry="290" fill="#FFB65A" opacity=".16"/>
  ${covers(512, 762, 1.16)}
  <path d="M0 0 L1024 0 L1024 316 C 860 168 660 96 512 96 C 364 96 164 168 0 316 Z" fill="#060C0B"/>
  <path d="M0 316 C 164 168 364 96 512 96 C 660 96 860 168 1024 316"
    fill="none" stroke="#24443C" stroke-width="18"/>
  <path d="M188 764 L836 764 L906 856 L118 856 Z" fill="url(#gold)" opacity=".14"/>`;

const concepts = {
  b1_portal: { title: 'B1 — Portal, Tunnel', svg: conceptB },
  b2_portal_sammlung: { title: 'B2 — Portal + Sammlung', svg: conceptB2 },
  b3_portal_klar: { title: 'B3 — Portal, reduziert', svg: conceptB3 },
  a_hoehle: { title: 'A — Höhle (verworfen)', svg: conceptA },
  c_sammlung: { title: 'C — Sammlung (verworfen)', svg: conceptC },
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
fs.writeFileSync(
  path.join(OUT, 'manifest.json'),
  JSON.stringify({ sizes: SIZES.slice(1), concepts: manifest }, null, 2),
);
console.log('done ->', OUT);
