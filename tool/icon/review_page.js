// Builds the self-contained icon review page from the rendered concepts.
// Everything is inlined (SVG markup + PNG data URIs) because the artifact CSP
// blocks every external request.
//
//   node review_page.js <concepts_dir> <out.html>
const fs = require('fs');
const path = require('path');

const SRC = process.argv[2] || path.join(__dirname, 'concepts');
const DST = process.argv[3] || path.join(__dirname, 'review.html');

const manifest = JSON.parse(fs.readFileSync(path.join(SRC, 'manifest.json'), 'utf8'));
const dataUri = (file) =>
  `data:image/png;base64,${fs.readFileSync(path.join(SRC, file)).toString('base64')}`;
// Gradient ids are global once several of these sit in one document, so every
// concept gets its own namespace — otherwise all five would silently render
// with the first one's fills.
const inlineSvg = (name) =>
  fs
    .readFileSync(path.join(SRC, `${name}.svg`), 'utf8')
    .replace(/width="1024" height="1024"/, 'width="100%" height="100%" aria-hidden="true"')
    .replace(/id="([\w-]+)"/g, `id="${name}-$1"`)
    .replace(/url\(#([\w-]+)\)/g, `url(#${name}-$1)`);

// Honest per-variant assessment. Written here rather than in the page body so
// the copy travels with the render that produced it.
const NOTES = {
  v0_basis: {
    verdict: 'Kontrollgruppe',
    keeps: 'Ruhigste Form, sauberste Tiefe. Der Bogen bleibt bis 48 px eindeutig.',
    costs:
      'Ohne Spiele-Signal: auf einem fremden Homescreen liest das genauso gut als Meditations- oder Reise-App.',
  },
  v1_pixel: {
    verdict: 'Signal ohne Motiv',
    keeps:
      '8-Bit-Stufung sagt „Spiel“, ohne ein Gegenstand zu sein — kein Controller, keine Figur, trotzdem sofort einsortiert. Bleibt eine reine Form, altert deshalb besser als ein Geräte-Motiv.',
    costs:
      'Retro-Pixel ist eine Behauptung über Geschmack: die App ist keine Retro-App. Und bei 48 px fällt die Stufung mit dem echten Pixelraster zusammen, der Effekt verpufft dort.',
  },
  v2_held: {
    verdict: 'Erzählend',
    keeps: 'Die Figur an der Schwelle macht aus dem Bild eine Handlung: du gehst da rein.',
    costs:
      'Bei 48 px ist die Figur vier Pixel breit und wird zum dunklen Fleck. Eine Figur setzt außerdem einen Avatar voraus, den die App nicht hat.',
  },
  v3_controller: {
    verdict: 'Eindeutig, aber erwartbar',
    keeps: 'Niemand muss die Geschichte kennen — ein Gamepad wird von jedem gelesen.',
    costs:
      'Genau das Klischee, das wir am alten Icon verworfen haben, nur hübscher. Sagt außerdem „Spiel“, während GamerGrove kein Spiel ist, sondern ein Katalog über Spiele.',
  },
  v4_sammlung: {
    verdict: 'Am nächsten an der App',
    keeps:
      'Cover-Silhouetten sagen „Sammlung von Spielen“ — das ist, was die App wirklich tut. Verwandt mit Letterboxd oder Goodreads, nicht mit einem Spiel.',
    costs:
      'Cover können auch Bücher oder Filme sein; das Signal ist „Katalog“, nicht zwingend „Games“. Bei 48 px bleibt eine dunkle Gruppe, die Bedeutung geht verloren.',
  },
};

const cards = manifest.concepts
  .map(({ name, title, cue }) => {
    const n = NOTES[name] || { verdict: '', keeps: '', costs: '' };
    const sizes = manifest.sizes
      .map(
        (s) =>
          `<figure class="truesize">
             <img src="${dataUri(`${name}_${s}.png`)}" width="${s}" height="${s}" alt="${title} bei ${s} Pixeln">
             <figcaption>${s}</figcaption>
           </figure>`,
      )
      .join('');
    return `<article class="variant" id="${name}">
      <header class="variant__head">
        <p class="eyebrow">${n.verdict}</p>
        <h3>${title}</h3>
        <p class="cue">${cue}</p>
      </header>
      <div class="variant__body">
        <div class="stage">${inlineSvg(name)}</div>
        <div class="evidence">
          <div class="sizes">
            ${sizes}
            <figure class="truesize truesize--zoom">
              <img src="${dataUri(`${name}_48.png`)}" width="48" height="48" alt="${title}, 48 Pixel vergrößert">
              <figcaption>48 · 4×</figcaption>
            </figure>
          </div>
          <dl class="ledger">
            <dt>Dafür</dt><dd>${n.keeps}</dd>
            <dt>Dagegen</dt><dd>${n.costs}</dd>
          </dl>
        </div>
      </div>
    </article>`;
  })
  .join('\n');

const homescreen = manifest.concepts
  .map(
    ({ name, title }) =>
      `<figure class="app">
         <img src="${dataUri(`${name}_192.png`)}" width="192" height="192" alt="${title}">
         <figcaption>${title.split('—')[0].trim()}</figcaption>
       </figure>`,
  )
  .join('');

const html = `<title>GamerGrove — Icon-Entwürfe</title>
<style>
  :root {
    color-scheme: dark;
    --ground: #0A1412;
    --surface: #14231F;
    --surface-hi: #1B2E29;
    --line-solid: #223731;
    --gold: #F2A63C;
    --gold-hi: #FFD68F;
    --ink: #EAE6DB;
    --ink-dim: #93A49D;
    --mono: ui-monospace, SFMono-Regular, "SF Mono", Menlo, Consolas, monospace;
    --sans: system-ui, -apple-system, "Segoe UI", Roboto, sans-serif;
    --measure: 68ch;
    --step: clamp(1.5rem, 1rem + 2vw, 3rem);
  }
  /* Deliberately single-world: these icons are dark-ground artwork and have to
     be judged against the dark they were drawn for. The light case is covered
     by the wallpaper switch in the homescreen test, which is the honest test. */
  * { box-sizing: border-box; }
  body {
    margin: 0;
    background: var(--ground);
    color: var(--ink);
    font-family: var(--sans);
    font-size: 1rem;
    line-height: 1.65;
    -webkit-font-smoothing: antialiased;
  }
  .wrap { width: min(100% - 2.5rem, 78rem); margin-inline: auto; }
  .eyebrow {
    font-family: var(--mono);
    font-size: .72rem;
    letter-spacing: .16em;
    text-transform: uppercase;
    color: var(--gold);
    margin: 0;
  }
  h1, h2, h3 { text-wrap: balance; margin: 0; }
  h1 {
    font-family: var(--mono);
    font-size: clamp(2rem, 1.2rem + 3.6vw, 3.6rem);
    line-height: 1.02;
    letter-spacing: -.035em;
    font-weight: 700;
  }
  h2 {
    font-family: var(--mono);
    font-size: clamp(1.3rem, 1.05rem + 1vw, 1.75rem);
    letter-spacing: -.02em;
  }
  h3 { font-family: var(--mono); font-size: 1.25rem; letter-spacing: -.015em; }
  p { margin: 0; max-width: var(--measure); }

  header.masthead { padding: var(--step) 0 calc(var(--step) * .75); }
  .masthead__grid { display: flex; flex-direction: column; gap: 1.1rem; }
  .lede { font-size: 1.15rem; color: var(--ink-dim); }
  .lede strong { color: var(--ink); font-weight: 600; }

  .story {
    display: grid;
    gap: 1px;
    grid-template-columns: repeat(auto-fit, minmax(15rem, 1fr));
    background: var(--line-solid);
    border: 1px solid var(--line-solid);
    border-radius: 14px;
    overflow: hidden;
    margin-block: var(--step);
  }
  .story > div { background: var(--surface); padding: 1.25rem 1.35rem; }
  .story dt {
    font-family: var(--mono);
    font-size: .72rem;
    letter-spacing: .14em;
    text-transform: uppercase;
    color: var(--gold);
    margin-bottom: .45rem;
  }
  .story dd { margin: 0; color: var(--ink-dim); font-size: .95rem; }

  section { padding-block: var(--step); }
  .section-head { display: flex; flex-direction: column; gap: .6rem; margin-bottom: 1.75rem; }

  .variant {
    border-top: 1px solid var(--line-solid);
    padding-block: 2rem;
  }
  .variant__head { display: flex; flex-direction: column; gap: .35rem; margin-bottom: 1.4rem; }
  .cue { color: var(--ink-dim); font-size: .95rem; }
  .variant__body {
    display: grid;
    grid-template-columns: minmax(0, 22rem) minmax(0, 1fr);
    gap: clamp(1.25rem, 3vw, 2.75rem);
    align-items: start;
  }
  @media (max-width: 54rem) { .variant__body { grid-template-columns: 1fr; } }
  .stage {
    aspect-ratio: 1;
    border-radius: 22%;
    overflow: hidden;
    background: var(--surface);
    box-shadow: 0 18px 44px rgb(0 0 0 / .5);
  }
  .stage svg { display: block; }

  .evidence { display: flex; flex-direction: column; gap: 1.6rem; }
  .sizes {
    display: flex;
    flex-wrap: wrap;
    align-items: flex-end;
    gap: 1.5rem;
    padding: 1.25rem;
    border: 1px solid var(--line-solid);
    border-radius: 14px;
    background: var(--surface);
  }
  .truesize { margin: 0; display: flex; flex-direction: column; align-items: center; gap: .5rem; }
  .truesize img { display: block; border-radius: 22%; }
  .truesize figcaption {
    font-family: var(--mono);
    font-size: .68rem;
    letter-spacing: .1em;
    color: var(--ink-dim);
    font-variant-numeric: tabular-nums;
  }
  .truesize--zoom img { width: 192px; height: 192px; image-rendering: pixelated; }

  .ledger { display: grid; grid-template-columns: auto 1fr; gap: .5rem 1.1rem; margin: 0; }
  .ledger dt {
    font-family: var(--mono);
    font-size: .7rem;
    letter-spacing: .13em;
    text-transform: uppercase;
    color: var(--gold);
    padding-top: .2rem;
  }
  .ledger dd { margin: 0; color: var(--ink-dim); font-size: .95rem; }

  .homescreen {
    border: 1px solid var(--line-solid);
    border-radius: 18px;
    overflow: hidden;
    background: var(--surface);
  }
  .homescreen__bar {
    display: flex;
    flex-wrap: wrap;
    align-items: center;
    justify-content: space-between;
    gap: 1rem;
    padding: 1rem 1.25rem;
    border-bottom: 1px solid var(--line-solid);
  }
  .switch { display: flex; gap: .4rem; }
  .switch button {
    font-family: var(--mono);
    font-size: .75rem;
    letter-spacing: .08em;
    text-transform: uppercase;
    color: var(--ink-dim);
    background: transparent;
    border: 1px solid var(--line-solid);
    border-radius: 999px;
    padding: .45rem 1rem;
    cursor: pointer;
    transition: color .18s, border-color .18s, background-color .18s;
  }
  .switch button:hover { color: var(--ink); border-color: var(--gold); }
  .switch button[aria-pressed="true"] { color: var(--ground); background: var(--gold); border-color: var(--gold); }
  .switch button:focus-visible { outline: 2px solid var(--gold-hi); outline-offset: 2px; }

  .wallpaper {
    padding: 2.5rem 1.5rem;
    display: flex;
    flex-wrap: wrap;
    gap: 2rem 2.5rem;
    justify-content: center;
    background:
      radial-gradient(120% 90% at 20% 0%, #1d2b3a 0%, #0b1017 60%, #05080b 100%);
    transition: background .25s;
  }
  body[data-wall="light"] .wallpaper {
    background: radial-gradient(120% 90% at 20% 0%, #f3efe6 0%, #d9d2c4 60%, #c3bcae 100%);
  }
  body[data-wall="photo"] .wallpaper {
    background:
      radial-gradient(70% 55% at 72% 18%, rgb(255 190 120 / .55), transparent 62%),
      linear-gradient(155deg, #3d2a4d 0%, #7a3f52 42%, #2a2740 100%);
  }
  .app { margin: 0; display: flex; flex-direction: column; align-items: center; gap: .6rem; width: 5.5rem; }
  .app img { width: 48px; height: 48px; border-radius: 22%; }
  .app figcaption {
    font-size: .7rem;
    line-height: 1.25;
    text-align: center;
    color: #E9E6DE;
    text-shadow: 0 1px 3px rgb(0 0 0 / .7);
  }
  body[data-wall="light"] .app figcaption { color: #1d211f; text-shadow: none; }

  .decision { border-top: 1px solid var(--line-solid); }
  .decision ol { max-width: var(--measure); padding-left: 1.2rem; color: var(--ink-dim); }
  .decision li { margin-bottom: .55rem; }
  .decision li strong { color: var(--ink); }
  footer { padding-block: var(--step); color: var(--ink-dim); font-size: .85rem; }
  footer code { font-family: var(--mono); color: var(--gold-hi); }

  @media (prefers-reduced-motion: reduce) {
    * { transition: none !important; }
  }
</style>

<div class="wrap">
  <header class="masthead">
    <div class="masthead__grid">
      <p class="eyebrow">GamerGrove · App-Icon · Entwurfsstand 2</p>
      <h1>Ein Tor im Dunkeln</h1>
      <p class="lede">
        Die Richtung steht: <strong>das Portal</strong>. Offen ist nur noch, welches
        Spiele-Signal es trägt — die Geschichte kennst du, ein Fremder auf seinem
        Homescreen kennt sie nicht.
      </p>
    </div>

    <dl class="story">
      <div>
        <dt>Der Ort</dt>
        <dd>Die Höhle des Gamers. Nicht abwertend, sondern der sichere eigene Raum — deshalb ist die App dunkel: das Dunkel ist der Raum, nicht ein Design-Modus.</dd>
      </div>
      <div>
        <dt>Das Licht</dt>
        <dd>Warmes Gold ist das Einzige, was leuchtet: der Weg in neue Welten. Es wird später die Markenfarbe der App und der Anker für das Farbschema.</dd>
      </div>
      <div>
        <dt>Der Test</dt>
        <dd>Jedes Icon muss bei 48 px bestehen. Genau daran scheitert das aktuelle Icon: 2–3 px feine Linien werden auf dem Launcher zu grauem Matsch.</dd>
      </div>
    </dl>
  </header>

  <section>
    <div class="section-head">
      <p class="eyebrow">Der Homescreen-Test</p>
      <h2>So sehen sie da aus, wo sie wirklich stehen</h2>
      <p class="lede">
        Alle fünf bei 48 px nebeneinander. Wechsle den Hintergrund — ein dunkles Icon
        auf hellem Wallpaper ist der Fall, in dem viele Entwürfe verschwinden.
      </p>
    </div>
    <div class="homescreen">
      <div class="homescreen__bar">
        <p class="eyebrow">Wallpaper</p>
        <div class="switch" role="group" aria-label="Wallpaper wählen">
          <button type="button" data-wall="dark" aria-pressed="true">Dunkel</button>
          <button type="button" data-wall="light" aria-pressed="false">Hell</button>
          <button type="button" data-wall="photo" aria-pressed="false">Bunt</button>
        </div>
      </div>
      <div class="wallpaper">${homescreen}</div>
    </div>
  </section>

  <section>
    <div class="section-head">
      <p class="eyebrow">Die Varianten</p>
      <h2>Was jede Fassung gewinnt und was sie kostet</h2>
      <p class="lede">
        Gleiche Basis, fünf verschiedene Antworten auf „woran erkennt man, dass es um
        Spiele geht?“. Rechts jeweils die echten Launcher-Größen und die
        48-px-Fassung vergrößert — das sind die Pixel, die Android wirklich zeichnet.
      </p>
    </div>
    ${cards}
  </section>

  <section class="decision">
    <div class="section-head">
      <p class="eyebrow">Wenn du entschieden hast</p>
      <h2>Was dann passiert</h2>
    </div>
    <ol>
      <li><strong>Alle Layer aus einer Quelle:</strong> Voll-Icon, Adaptive Background und Foreground getrennt (Motiv in der 66-%-Safe-Zone, damit nichts mehr angeschnitten wird), Monochrome für Android 13 und ein Splash-Logo.</li>
      <li><strong>Farbschema aus der Palette ableiten:</strong> Gold und Jade werden zu Design-Tokens und lösen <code>FlexScheme.material</code> als Default ab.</li>
      <li><strong>Dann erst die Screens:</strong> Tokens und Theme, danach der Grove-Home, danach die Detailseiten — ein PR pro Etappe.</li>
    </ol>
  </section>

  <footer>
    Quelle: <code>tool/icon/concepts.js</code> — handgeschriebener Vektor, gerastert mit resvg.
    Diese Seite wird aus denselben Dateien gebaut (<code>tool/icon/review_page.js</code>),
    zeigt also exakt das, was auch im Repo liegt.
  </footer>
</div>

<script>
  const buttons = document.querySelectorAll('.switch button');
  buttons.forEach((btn) => {
    btn.addEventListener('click', () => {
      document.body.dataset.wall = btn.dataset.wall;
      buttons.forEach((b) => b.setAttribute('aria-pressed', String(b === btn)));
    });
  });
  document.body.dataset.wall = 'dark';
</script>
`;

fs.writeFileSync(DST, html);
console.log('wrote', DST, `(${(html.length / 1024).toFixed(0)} kB)`);
