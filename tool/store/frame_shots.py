"""Compose store screenshots: the app on the ground it is made of.

No device frame and no gradient. The page stands on the same dark green the app
stands on, lit from above by the brand gold through the same ordered dither the
icon, the loading card and every seam in the app are drawn with — so the store
page is made of the product rather than of a template.

Play wants phone screenshots between 16:9 and 9:16. The emulator is 9:20, which
is outside that, so the canvas is a fixed 1080x1920 and the capture is fitted
into it — the frame decides the aspect, not the device.

Usage: frame_shots.py <raw-dir> <out-dir>
"""
import pathlib
import sys

from PIL import Image, ImageDraw, ImageFont

CANVAS = (1080, 1920)

GROUND = (11, 22, 20)
GOLD = (242, 166, 60)
INK = (233, 229, 219)
MUTED = (126, 147, 141)

# The 4x4 ordered matrix the app dithers with — the same threshold table, so
# this is the app's texture and not a picture of it.
BAYER = [
    [0, 8, 2, 10],
    [12, 4, 14, 6],
    [3, 11, 1, 9],
    [15, 7, 13, 5],
]

ROOT = pathlib.Path(__file__).resolve().parents[2]
FONTS = ROOT / 'assets/fonts'

# One line per shot, in the order they appear in the store. Each answers "what
# is this for", in the app's own language — the listing is en-US.
CAPTIONS = [
    ('grove', 'YOUR GROVE', 'The three that matter, and everything after them'),
    ('detail', 'EVERY GAME, IN FULL', 'Ratings, media, and what it is related to'),
    ('collections', 'YOUR OWN SHELVES', 'Name a list, fill it, keep it'),
    ('search', 'FIND ANYTHING', 'Filter by what you actually care about'),
    ('profile', 'A GROVE IS A PLACE', 'Follow people and see what they play'),
]


def dither_band(draw: ImageDraw.ImageDraw, top: int, height: int,
                peak: float, falling: bool, cell: int = 3) -> None:
    """A band of gold that thins out through the Bayer matrix."""
    rows = height // cell
    for row in range(rows):
        ratio = row / rows if falling else 1 - row / rows
        density = ((1 - ratio) ** 2.1) * peak
        if density <= 0:
            continue
        for col in range(CANVAS[0] // cell + 1):
            threshold = (BAYER[row & 3][col & 3] + 0.5) / 16
            if density > threshold:
                x, y = col * cell, top + row * cell
                draw.rectangle([x, y, x + cell - 1, y + cell - 1], fill=GOLD)


def fit(capture: Image.Image, width: int) -> Image.Image:
    """Scale the capture to `width`, keeping its own proportions."""
    height = round(capture.height * width / capture.width)
    return capture.resize((width, height), Image.LANCZOS)


def compose(capture: Image.Image, headline: str, sub: str) -> Image.Image:
    canvas = Image.new('RGB', CANVAS, GROUND)
    draw = ImageDraw.Draw(canvas)

    display = ImageFont.truetype(str(FONTS / 'BricolageGrotesque-Bold.ttf'), 76)
    body = ImageFont.truetype(str(FONTS / 'IBMPlexSans-Regular.ttf'), 34)

    # Light from the top, falling away — the app's one move.
    dither_band(draw, 0, 520, peak=0.42, falling=True)

    draw.text((72, 150), headline, font=display, fill=INK)
    draw.text((72, 252), sub, font=body, fill=MUTED)

    shot = fit(capture, CANVAS[0] - 144)
    top = 360
    # Cropped rather than squeezed: the head of the screen is what carries the
    # point, and a squashed screenshot reads as a mistake.
    visible = min(shot.height, CANVAS[1] - top - 90)
    canvas.paste(shot.crop((0, 0, shot.width, visible)), (72, top))

    # A hairline in the brand colour along the top edge of the screen, so it
    # sits on the ground rather than floating over it.
    draw.rectangle([72, top, CANVAS[0] - 72, top + 2], fill=GOLD)

    dither_band(draw, CANVAS[1] - 180, 180, peak=0.22, falling=False)
    return canvas


def main() -> int:
    raw = pathlib.Path(sys.argv[1])
    out = pathlib.Path(sys.argv[2])
    out.mkdir(parents=True, exist_ok=True)

    made = 0
    for index, (name, headline, sub) in enumerate(CAPTIONS, start=1):
        source = raw / f'{name}.png'
        if not source.exists():
            print(f'skipped {name}: no capture')
            continue
        canvas = compose(Image.open(source).convert('RGB'), headline, sub)
        target = out / f'{index}-{name}.png'
        canvas.save(target)
        print(f'{target}  {canvas.size[0]}x{canvas.size[1]}')
        made += 1
    return 0 if made else 1


if __name__ == '__main__':
    raise SystemExit(main())
