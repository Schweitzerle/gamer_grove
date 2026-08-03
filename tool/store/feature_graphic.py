"""The 1024x500 banner at the head of the store page.

Same ground as the screenshots and the app: dark green, gold light falling
away through the ordered dither the icon is drawn with. The mark stands in the
light on the left, the name and one line beside it.

Play crops this differently in different placements, so nothing that has to be
read sits near an edge.
"""
import pathlib

from PIL import Image, ImageDraw, ImageFont

SIZE = (1024, 500)
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


def mix(a, b, t):
    return tuple(round(x + (y - x) * t) for x, y in zip(a, b))


def dither_band(draw, top, height, peak, cell=2):
    """Gold thinning out downward, through the app's own threshold table.

    The lit cells are gold *blended into the ground*, not gold. Ordered
    dithering only has sixteen levels, so drawing them opaque puts a visible
    terrace wherever the density crosses one — at phone scale the app hides
    that behind a low alpha, and a banner viewed at full size does not get to
    skip it.
    """
    lit = mix(GROUND, GOLD, 0.62)
    rows = height // cell
    for row in range(rows):
        density = ((1 - row / rows) ** 2.6) * peak
        if density <= 0:
            continue
        for col in range(SIZE[0] // cell + 1):
            if density > (BAYER[row & 3][col & 3] + 0.5) / 16:
                x, y = col * cell, top + row * cell
                draw.rectangle([x, y, x + cell - 1, y + cell - 1], fill=lit)


def main() -> None:
    canvas = Image.new('RGB', SIZE, GROUND)
    draw = ImageDraw.Draw(canvas)
    # Across the whole height, not a third of it. A band that stops leaves a
    # line where the pattern ends, and at this scale the Bayer table's sixteen
    # steps are wide enough to read as stripes — the falloff has to have room
    # to get to nothing.
    dither_band(draw, 0, SIZE[1], peak=0.34)

    # The splash layer, not the app icon: that one carries its own dark ground
    # and pasted onto the banner it reads as a rectangle sitting on the
    # texture rather than as a mark standing in it.
    mark = Image.open(ROOT / 'assets/splash/splash_logo.png').convert('RGBA')
    # Whole-number scale from 1024: the mark is on a 32-cell grid and 320 keeps
    # every cell at exactly 10 px. Nearest neighbour, or the hard edges blur.
    mark = mark.resize((320, 320), Image.NEAREST)
    canvas.paste(mark, (78, 90), mark)

    display = ImageFont.truetype(str(FONTS / 'BricolageGrotesque-Bold.ttf'), 76)
    body = ImageFont.truetype(str(FONTS / 'IBMPlexSans-Regular.ttf'), 27)

    left, right = 432, SIZE[0] - 64
    draw.text((left, 186), 'GamerGrove', font=display, fill=INK)
    tagline = 'Your games, in a place that feels like yours.'
    draw.text((left + 3, 284), tagline, font=body, fill=MUTED)

    # Nothing that has to be read may reach the edge — Play crops this banner
    # differently in different placements.
    width = draw.textlength(tagline, font=body)
    if left + 3 + width > right:
        raise SystemExit(
            f'tagline runs to {left + 3 + width:.0f}, past the safe edge {right}'
        )

    target = ROOT / 'build/store/feature_graphic_1024x500.png'
    target.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(target)
    print(target, canvas.size)


if __name__ == '__main__':
    main()
