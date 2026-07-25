# App icon source — "Pixel Portal"

The GamerGrove icon is a hand-authored vector rasterised to PNG layers, then
fed to `flutter_launcher_icons` / `flutter_native_splash`. `render.js` is the
single source of truth — never edit the generated PNGs.

## The idea

A grove is a place, not a plant. GamerGrove's place is the gamer's cave: not a
put-down but a refuge, your own dark corner where you do what you love and dive
into new worlds from. The mark is the lit way through, standing in that dark.

That story also settles the app's palette: it is dark because the dark **is the
room**, not because dark mode is fashionable, and the one warm colour is the
light you are heading for.

The games cue lives in the *making*, not in an object. It is drawn as 8-bit
pixel art — one shared grid, flat fills, ordered dithering — so it reads as
"games" without a gamepad. A device motif ages with the hardware; a technique
does not.

## Palette

| Token | Hex | Role |
|-------|-----|------|
| cave | `#0B1614` | the room you sit in; the app's ground colour |
| frame | `#F0C179` | the doorway, lit from within |
| shadow | `#2A1A0A` | the mouth of the tunnel |
| deep / mid / near | `#7A4A18` `#C9781F` `#F2A63C` | the tunnel receding into light |
| core | `#FFF1D2` | the world at the far end |
| sill | `#8A5F2A` `#4A3418` | light pooling out of the doorway |
| glow | `#3A331C` `#282311` `#1B1D11` `#13180F` | dither bands, brightest nearest the arch |

`#F2A63C` is the brand accent and the seed for the app's colour scheme.

## Regenerate

```bash
cd tool/icon
npm install                 # one-time; @resvg/resvg-js
node render.js ../..        # writes assets/icon/*.png + assets/splash/*.png
cd ../..
dart run flutter_launcher_icons
dart run flutter_native_splash:create
python3 tool/icon/verify.py . tool/icon/concepts/_verify.png   # proof sheet
```

`verify.py` composites the layers the way Android does, crops them with the
masks launchers actually ship, and renders the result at real launcher sizes —
including the layers that ended up in `android/app/src/main/res`, which is the
only artwork the launcher ever reads.

## Layers

| File | Purpose |
|------|---------|
| `app_icon.png` | full-bleed icon: iOS, legacy Android, web, store listing |
| `app_icon_background.png` | adaptive background — ground plus glow |
| `app_icon_foreground.png` | adaptive foreground — the mark, inside the safe zone |
| `app_icon_monochrome.png` | Android 13+ themed icons |
| `splash/splash_logo.png` | splash mark, transparent |
| `splash/splash_logo_android12.png` | 1152px canvas Android 12+ expects |

## Two things that are easy to get wrong

**The safe zone.** Android stacks two 108dp layers and crops with a mask that
only guarantees the inner 72dp (66%). Masks range from squircles to full
circles — Pixel uses a circle — so `render.js` fits the mark by its **diagonal**,
not its bounding box. Fitting the box alone lets a circular mask bite the
corners off the arch legs. This is exactly how the previous icon broke: its
`image_path` and `adaptive_icon_foreground` both pointed at the same full-bleed
PNG, so the motif was cropped and its dark background was laid over the
background colour twice.

**The extra inset.** `flutter_launcher_icons` insets foreground *and*
monochrome by a further 16% by default. Since the vector already places the
mark precisely, `adaptive_icon_foreground_inset: 0` is set in `pubspec.yaml` —
otherwise the mark is shrunk twice.

`test/icon/launcher_assets_test.dart` guards both: it decodes the generated
layers and fails if the mark leaves the safe circle.
