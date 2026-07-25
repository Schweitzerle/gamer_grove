"""Contact sheet for icon review: true launcher sizes + a magnified 48dp row.

The magnified row is nearest-neighbour on purpose — it shows the actual pixels
Android will draw, which is where hairline artwork falls apart.
"""

import sys
from PIL import Image, ImageDraw

SRC = sys.argv[1]
DST = sys.argv[2]
CONCEPTS = [
    ("a_canopy", "A — Canopy"),
    ("b_heartwood", "B — Heartwood"),
    ("c_standing_three", "C — Standing Three"),
]
SIZES = [192, 96, 72, 48]
CELL, PAD, LABEL_W, MAG = 210, 26, 200, 5

rows = len(CONCEPTS)
top_w = LABEL_W + len(SIZES) * (CELL + PAD) + PAD
mag_w = 48 * MAG + PAD
width = top_w + mag_w
height = PAD + rows * (CELL + PAD) + 40

sheet = Image.new("RGB", (width, height), (34, 36, 38))
draw = ImageDraw.Draw(sheet)

for col, size in enumerate(SIZES):
    x = LABEL_W + col * (CELL + PAD) + CELL // 2
    draw.text((x - 18, 10), f"{size}px", fill=(200, 204, 208))
draw.text((top_w + 8, 10), "48px @5x", fill=(255, 190, 120))

for row, (key, title) in enumerate(CONCEPTS):
    y0 = 40 + row * (CELL + PAD)
    draw.text((PAD, y0 + CELL // 2), title, fill=(235, 238, 240))
    for col, size in enumerate(SIZES):
        img = Image.open(f"{SRC}/{key}_{size}.png").convert("RGBA")
        x = LABEL_W + col * (CELL + PAD) + (CELL - size) // 2
        sheet.paste(img, (x, y0 + (CELL - size) // 2), img)
    mag = Image.open(f"{SRC}/{key}_48.png").convert("RGBA")
    mag = mag.resize((48 * MAG, 48 * MAG), Image.NEAREST)
    sheet.paste(mag, (top_w + PAD // 2, y0 + (CELL - 48 * MAG) // 2), mag)

sheet.save(DST)
print("wrote", DST)
