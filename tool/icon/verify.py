"""Proof sheet for the generated launcher layers.

Composites the adaptive background and foreground exactly the way Android does,
crops with the masks launchers actually ship (circle, squircle, rounded square),
and renders the result at real launcher sizes. The circle is the strict case:
Pixel uses it, and it is where a motif fitted only by its bounding box loses
the corners.

    python3 verify.py <project_root> <out.png>
"""

import sys
from PIL import Image, ImageDraw

ROOT, DST = sys.argv[1], sys.argv[2]
SIZE = 1024
SIZES = [192, 96, 72, 48]


def load(rel):
    return Image.open(f"{ROOT}/{rel}").convert("RGBA")


def circle_mask():
    m = Image.new("L", (SIZE, SIZE), 0)
    # Android guarantees only the inner 72 of 108dp survives the mask.
    inset = SIZE * (1 - 72 / 108) / 2
    ImageDraw.Draw(m).ellipse([inset, inset, SIZE - inset, SIZE - inset], fill=255)
    return m


def rounded_mask(radius_frac):
    m = Image.new("L", (SIZE, SIZE), 0)
    inset = SIZE * (1 - 72 / 108) / 2
    ImageDraw.Draw(m).rounded_rectangle(
        [inset, inset, SIZE - inset, SIZE - inset], radius=SIZE * radius_frac, fill=255
    )
    return m


adaptive = Image.alpha_composite(
    load("assets/icon/app_icon_background.png"), load("assets/icon/app_icon_foreground.png")
)

# Themed icons: the system tints the monochrome layer and puts it on its own
# background, so check the shape against a flat tint rather than the artwork.
mono = load("assets/icon/app_icon_monochrome.png")
themed = Image.new("RGBA", (SIZE, SIZE), (58, 46, 24, 255))
themed.paste(Image.new("RGBA", (SIZE, SIZE), (255, 222, 170, 255)), (0, 0), mono)

# The rows above check the source artwork. These check what actually shipped
# into the Android resources, which is the only thing the launcher ever reads.
RES = "android/app/src/main/res"


def shipped(rel):
    return Image.open(f"{ROOT}/{RES}/{rel}").convert("RGBA").resize((SIZE, SIZE), Image.LANCZOS)


shipped_adaptive = Image.alpha_composite(
    shipped("drawable-xxxhdpi/ic_launcher_background.png"),
    shipped("drawable-xxxhdpi/ic_launcher_foreground.png"),
)

ROWS = [
    ("Adaptive · Kreis", adaptive, circle_mask()),
    ("Adaptive · Squircle", adaptive, rounded_mask(0.20)),
    ("Adaptive · Rundeck", adaptive, rounded_mask(0.10)),
    ("Voll-Icon", load("assets/icon/app_icon.png"), rounded_mask(0.20)),
    ("Monochrome", themed, circle_mask()),
    ("Ausgeliefert · Kreis", shipped_adaptive, circle_mask()),
    ("Ausgeliefert · Legacy", shipped("mipmap-xxxhdpi/ic_launcher.png"), rounded_mask(0.20)),
]

CELL, PAD, LABEL_W = 210, 26, 210
width = LABEL_W + len(SIZES) * (CELL + PAD) + PAD
height = 40 + len(ROWS) * (CELL + PAD)
sheet = Image.new("RGB", (width, height), (34, 36, 38))
draw = ImageDraw.Draw(sheet)

for col, size in enumerate(SIZES):
    draw.text((LABEL_W + col * (CELL + PAD) + CELL // 2 - 18, 12), f"{size}px", fill=(200, 204, 208))

for row, (title, art, mask) in enumerate(ROWS):
    y0 = 40 + row * (CELL + PAD)
    draw.text((PAD, y0 + CELL // 2), title, fill=(235, 238, 240))
    masked = art.copy()
    masked.putalpha(mask)
    for col, size in enumerate(SIZES):
        img = masked.resize((size, size), Image.LANCZOS)
        x = LABEL_W + col * (CELL + PAD) + (CELL - size) // 2
        sheet.paste(img, (x, y0 + (CELL - size) // 2), img)

sheet.save(DST)
print("wrote", DST)
