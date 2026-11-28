# 25 Nov: Mayil Matchbox = the Colour Matchbox art (art/crk/b14.webp) in peacock colours (his choice 12:00):
# red -> peacock blue, orange -> emerald, yellow -> teal, green -> deep peacock green, blue -> indigo; the gold band
# and the fuse stay as they are.
import colorsys
import numpy as np
from PIL import Image
im = np.array(Image.open("art/crk/b14.webp").convert("RGBA")).astype(float) / 255
H, W = im.shape[:2]
out = im.copy()
def band(y): return 0.42 * H < y < 0.67 * H
for y in range(H):
    for x in range(W):
        r, g, b, a = im[y, x]
        if a <= 0:
            continue
        h, s, v = colorsys.rgb_to_hsv(r, g, b)
        hd = h * 360
        if s < 0.3:
            continue
        if band(y) and 20 <= hd <= 65 and not (x < 0.24 * W and y > 0.58 * H):
            continue   # gold band
        if hd >= 330 or hd < 12:   nh, ks, kv = 200, 1.0, 0.95   # red -> peacock blue
        elif hd < 36:              nh, ks, kv = 152, 0.95, 0.85  # orange -> emerald
        elif hd < 70:              nh, ks, kv = 178, 0.95, 0.85  # yellow -> teal
        elif hd < 180:             nh, ks, kv = 165, 1.0, 0.7    # green -> deep peacock green
        elif hd < 250:             nh, ks, kv = 232, 1.0, 0.85   # blue -> indigo
        else:                      nh, ks, kv = 282, 1.0, 0.9    # purple -> violet
        rr, gg, bb = colorsys.hsv_to_rgb(nh / 360, min(1, s * ks), v * kv)
        out[y, x, :3] = (rr, gg, bb)
Image.fromarray((out * 255).astype(np.uint8)).save("art/toy/mayil.png")
