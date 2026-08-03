"""Compose store screenshots: the app on the ground it is made of.

No device frame and no gradient. The page stands on the same dark green the app
stands on, lit from above by the brand gold through the same ordered dither the
icon, the loading card and every seam in the app are drawn with — so the store
page is made of the product rather than of a template.

Play wants phone screenshots between 16:9 and 9:16. Phones shoot 9:20, which is
outside that, so the canvas is a fixed 1080x1920 and the capture is fitted into
it: the frame decides the aspect, not the device.

Usage: frame_shots.py <raw-dir> [out-dir]
"""
import pathlib
import sys

from PIL import Image, ImageDraw, ImageFont

CANVAS = (1080, 1920)

GROUND = (11, 22, 20)
GOLD = (242, 166, 60)
INK = (233, 229, 219)
MUTED = (126, 147, 141)

BAYER = [
    [0, 8, 2, 10],
    [12, 4, 14, 6],
    [3, 11, 1, 9],
    [15, 7, 13, 5],
]

ROOT = pathlib.Path(__file__).resolve().parents[2]
FONTS = ROOT / 'assets/fonts'

# The phone's own status bar. It says nothing about the app and dates the
# picture with a battery percentage.
STATUS_BAR = 96

MARGIN = 72

# The light is a lit edge along the top, and the words stand on clean ground
# below it. Set over the band, a caption at this size is unreadable — the dither
# is a field of dots at exactly the scale of the letterforms.
BAND = 250
HEADLINE_Y = 306
CAPTION_Y = 396
SHOT_TOP = 476
SHOT_BOTTOM = CANVAS[1] - 170

# One line per shot, in the order they appear in the store. The first is the one
# most people see, so it carries the whole idea.
SHOTS = [
    ('grove', 'YOUR GROVE',
     'The three that matter, and every shelf you keep'),
    ('detail', 'EVERY GAME, IN FULL',
     'Your rating, the community’s, and what it is related to'),
    ('collections', 'SHELVES YOU NAME',
     'Cozy games. Backlog 2026. Anything.'),
    ('search', 'FILTERS THAT MEAN IT',
     'Genre, platform, mode, perspective, year'),
    ('profile', 'WHAT YOU ACTUALLY PLAY',
     'Your library, counted'),
]


def mix(a, b, t):
    return tuple(round(x + (y - x) * t) for x, y in zip(a, b))


def dither_band(draw, top, height, peak, falling=True, cell=3):
    """Gold thinning out, through the app's own threshold table.

    The lit cells are gold *blended into the ground*, not gold: ordered
    dithering has sixteen levels, and drawing them opaque puts a visible
    terrace wherever the density crosses one.
    """
    lit = mix(GROUND, GOLD, 0.62)
    rows = height // cell
    for row in range(rows):
        ratio = row / rows if falling else 1 - row / rows
        density = ((1 - ratio) ** 2.4) * peak
        if density <= 0:
            continue
        for col in range(CANVAS[0] // cell + 1):
            if density > (BAYER[row & 3][col & 3] + 0.5) / 16:
                x, y = col * cell, top + row * cell
                draw.rectangle([x, y, x + cell - 1, y + cell - 1], fill=lit)


def content_height(shot: Image.Image) -> int:
    """Where the screen stops saying anything.

    Several screens end in a lot of empty surface — the collections list is
    half air below four cards. Cropped to a fixed fraction, that air is what the
    store shows; measured, it is not. The floor keeps a short screen from being
    blown up so far that it stops matching the others.
    """
    pixels = shot.convert('RGB').load()
    width, height = shot.size
    floor = int(height * 0.45)
    step = max(1, width // 60)
    for y in range(height - 1, floor, -1):
        row = [pixels[x, y] for x in range(0, width, step)]
        spread = max(max(c) - min(c) for c in row)
        brightest = max(sum(c) for c in row)
        # A row that is all one near-black tone is the surface, not content.
        if spread > 26 or brightest > 210:
            return min(height, y + 24)
    return floor


def place(canvas: Image.Image, shot: Image.Image):
    """Fill the frame's width, and crop off whatever will not fit.

    Fitting by *height* was the obvious call and the wrong one: a phone screen
    is far taller than the box, so it came out two thirds as wide as the frame
    with dark margins either side — the app looked like a postage stamp on a
    poster. The width is what makes it read as a screen.
    """
    width = CANVAS[0] - MARGIN * 2
    height = round(shot.height * width / shot.width)
    fitted = shot.resize((width, height), Image.LANCZOS)
    box_height = SHOT_BOTTOM - SHOT_TOP
    if height > box_height:
        fitted = fitted.crop((0, 0, width, box_height))
    canvas.paste(fitted, (MARGIN, SHOT_TOP))
    return MARGIN, fitted.size


def compose(raw: Image.Image, headline: str, sub: str) -> Image.Image:
    canvas = Image.new('RGB', CANVAS, GROUND)
    draw = ImageDraw.Draw(canvas)

    display = ImageFont.truetype(str(FONTS / 'BricolageGrotesque-Bold.ttf'), 60)
    body = ImageFont.truetype(str(FONTS / 'IBMPlexSans-Regular.ttf'), 31)

    dither_band(draw, 0, BAND, peak=0.34)

    if draw.textlength(headline, font=display) > CANVAS[0] - MARGIN * 2:
        raise SystemExit(f'headline too wide: {headline!r}')
    if draw.textlength(sub, font=body) > CANVAS[0] - MARGIN * 2:
        raise SystemExit(f'caption too wide: {sub!r}')

    draw.text((MARGIN, HEADLINE_Y), headline, font=display, fill=INK)
    draw.text((MARGIN + 2, CAPTION_Y), sub, font=body, fill=MUTED)

    shot = raw.crop((0, STATUS_BAR, raw.width, content_height(raw)))
    left, size = place(canvas, shot)

    # A hairline along the top edge of the screen, so it stands on the ground
    # rather than floating over it.
    draw.rectangle([left, SHOT_TOP, left + size[0], SHOT_TOP + 3], fill=GOLD)

    # Below the screen, not across it. Drawn last, a band that reaches into
    # the capture puts dots over the app's own content.
    dither_band(draw, CANVAS[1] - 130, 130, peak=0.18, falling=False)
    return canvas


def main() -> int:
    raw_dir = pathlib.Path(sys.argv[1])
    out = (pathlib.Path(sys.argv[2]) if len(sys.argv) > 2
           else ROOT / 'build/store/shots')
    out.mkdir(parents=True, exist_ok=True)

    made = 0
    for index, (name, headline, sub) in enumerate(SHOTS, start=1):
        source = raw_dir / f'{name}.png'
        if not source.exists():
            print(f'skipped {name}: no capture at {source}')
            continue
        canvas = compose(Image.open(source).convert('RGB'), headline, sub)
        target = out / f'{index}-{name}.png'
        canvas.save(target)
        print(f'{target}  {canvas.size[0]}x{canvas.size[1]}')
        made += 1
    return 0 if made else 1


if __name__ == '__main__':
    raise SystemExit(main())
