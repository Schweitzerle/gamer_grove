# Store assets

The Play listing is drawn from the same materials as the app: the dark ground,
the brand gold, and the ordered dither the icon is authored with. No device
frames and no gradients — a listing that looks like every other listing is a
listing that says nothing about the product behind it.

Output goes to `build/store/`, which is not tracked. Nothing here uploads
anything; the listing is live in production and is changed by hand after review.

## `feature_graphic.py`

The 1024×500 banner at the head of the listing. Run it with no arguments.

```
python3 tool/store/feature_graphic.py
```

> **Why the lit cells are blended rather than gold:** ordered dithering has
> sixteen levels, so opaque cells put a visible terrace wherever the density
> crosses one. At phone scale the app hides that behind a low alpha; a banner
> viewed at full size does not get to skip it.

## `frame_shots.py`

Wraps raw phone captures in the same ground.

```
python3 tool/store/frame_shots.py <raw-dir> build/store/shots
```

Expects `grove.png`, `detail.png`, `collections.png`, `search.png` and
`profile.png` in the raw directory. The canvas is a fixed 1080×1920: phones
shoot 9:20 and Play only accepts down to 9:16, so the frame decides the aspect
and the capture is fitted into it.

## The store icon

512×512, taken from `assets/icon/app_icon.png` at exactly half size with
nearest-neighbour resampling — the mark is authored on a 32-cell grid, so each
cell is 32 px at 1024 and 16 px at 512. Any smooth resampling blurs edges that
were drawn hard on purpose.

```
python3 -c "from PIL import Image; \
Image.open('assets/icon/app_icon.png').convert('RGB') \
     .resize((512, 512), Image.NEAREST).save('build/store/store_icon_512.png')"
```
