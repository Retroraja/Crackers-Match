#!/usr/bin/env python3
"""25 Nov: Area 4 pictures for the phone from the renders of a4_render.sh (RENDER_DIR):
 1. the home picture + build stickers (make_pics.py area 4, from hub0..hub9)
 2. the delivery pieces: the grey van sticker and the empty kerb behind it (hubnv), the order board panel with
    0..5 ticks (same drawing as the approved preview), each place picture without the van, the van there and the
    5 parcels as stickers
 3. build window icons art/web/task-a4-N.webp
usage: python3 tools/pic/a4_pics.py RENDER_DIR   (run from godot/)"""
import json, os, subprocess, sys
import numpy as np
from PIL import Image, ImageDraw, ImageFont, ImageFilter

R = sys.argv[1].rstrip("/")
G = "."
OUT = "street/pics"
W, H = 1080, 2338
os.makedirs(R + "/a4p0", exist_ok=True)
for n in range(10):
    d = R + "/a4p0/s%d.png" % n
    if not os.path.exists(d):
        os.symlink(R + "/hub%d.png" % n, d)
subprocess.run([sys.executable, "tools/pic/make_pics.py", R, G, "4"], check=True)


def L(n):
    return Image.open("%s/%s.png" % (R, n)).convert("RGB").resize((W, H), Image.LANCZOS)


def mask(a, b, thr=12):
    d = np.abs(np.asarray(a).astype(np.int16) - np.asarray(b).astype(np.int16)).max(axis=2)
    m = Image.fromarray(((d > thr) * 255).astype(np.uint8))
    m = m.filter(ImageFilter.MinFilter(3)).filter(ImageFilter.MaxFilter(3))
    m = m.filter(ImageFilter.MaxFilter(5)).filter(ImageFilter.GaussianBlur(1.6))
    return np.asarray(m)


def main_blob(m):
    from scipy import ndimage
    lab, n = ndimage.label(m > 128)
    if n == 0:
        return m
    sz = ndimage.sum(m > 128, lab, range(1, n + 1))
    k = int(np.argmax(sz)) + 1
    keep = ndimage.binary_dilation(lab == k, iterations=12)
    return np.where(keep, m, 0).astype(np.uint8)


def sticker(full, m, name):
    ys, xs = np.nonzero(m > 8)
    x0, x1, y0, y1 = xs.min(), xs.max() + 1, ys.min(), ys.max() + 1
    rgba = np.dstack([np.asarray(full)[y0:y1, x0:x1], m[y0:y1, x0:x1]])
    Image.fromarray(rgba, "RGBA").save(os.path.join(OUT, name), quality=88, method=6)
    return {"img": "res://street/pics/" + name, "r": [int(x0), int(y0), int(x1 - x0), int(y1 - y0)]}


D = json.load(open(OUT + "/a4.json"))
ex = {}
# the grey van at the kerb (after build 1) and the empty kerb behind it
h9, hnv = L("hub9"), L("hubnv")
vm = main_blob(mask(h9, hnv))
ex["van"] = sticker(h9, vm, "a4_van.webp")
r = ex["van"]["r"]
bg = np.asarray(hnv)[r[1]:r[1] + r[3], r[0]:r[0] + r[2]]
Image.fromarray(bg).save(OUT + "/a4_vanbg.webp", quality=86, method=6)
ex["vanbg"] = {"img": "res://street/pics/a4_vanbg.webp", "r": r}
# the delivery places
ex["places"] = {}
for pl in ["temple", "wedding", "school", "apts", "marina"]:
    nv, v0, v5 = L(pl + "_nv"), L(pl + "_v0"), L(pl + "_v5")
    nv.save(OUT + "/a4_%s.webp" % pl, quality=84, method=6)
    van = sticker(v0, main_blob(mask(v0, nv)), "a4_%s_van.webp" % pl)
    bm = mask(v5, v0)
    box = sticker(v5, bm, "a4_%s_box.webp" % pl)
    ex["places"][pl] = {"base": "res://street/pics/a4_%s.webp" % pl, "van": van, "box": box}
# the order board panel (same as the approved preview a4_builds_video.py), 0..5 cards delivered
FONT = "art/LilitaOne.ttf"
def F(n):
    return ImageFont.truetype(FONT, n)
CARDS = [("Temple", "#d8262e"), ("Wedding Hall", "#e08a1e"), ("School", "#2f6fd6"), ("Apartment", "#7a4fc9"), ("Marina Party", "#1f9e9a")]
POS = [(60, 380), (200, 380), (340, 380), (130, 590), (270, 590)]
def stamp(im, i):
    cx, cy = POS[i]
    st = Image.new("RGBA", (220, 220), (0, 0, 0, 0))
    sd = ImageDraw.Draw(st)
    sd.ellipse((40, 40, 180, 180), fill="#2fb34a", outline="white", width=8)
    sd.line([(72, 112), (100, 140), (150, 84)], fill="white", width=16, joint="curve")
    st = st.rotate(-12, resample=Image.BICUBIC).resize((150, 150), Image.LANCZOS)
    im.alpha_composite(st, (int(cx + 65 - 75), int(cy + 120 - 75)))
    dl = Image.new("RGBA", (200, 50), (0, 0, 0, 0))
    ImageDraw.Draw(dl).rounded_rectangle((2, 2, 198, 48), 8, outline="#2e9e44", width=5)
    ImageDraw.Draw(dl).text((100, 25), "DELIVERED", font=F(28), fill="#2e9e44", anchor="mm")
    dl = dl.rotate(14, expand=True, resample=Image.BICUBIC).resize((150, 64), Image.LANCZOS)
    im.alpha_composite(dl, (cx - 12, cy + 140))
def board(done):
    im = Image.new("RGBA", (540, 1170), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    x0, y0, x1, y1 = 40, 330, 500, 800
    d.rounded_rectangle((x0 - 10, y0 - 10, x1 + 10, y1 + 10), 26, fill="#5a3119")
    d.rounded_rectangle((x0, y0, x1, y1), 20, fill="#c9955c", outline="#3a1d0c", width=3)
    for i in range(160):
        rx = x0 + 12 + (i * 97) % (x1 - x0 - 24)
        ry = y0 + 12 + (i * 53) % (y1 - y0 - 24)
        d.ellipse((rx, ry, rx + 3, ry + 3), fill="#a87642")
    d.rounded_rectangle((170, y0 - 34, 370, y0 + 22), 18, fill="#d8262e", outline="#7a1010", width=3)
    d.text((270, y0 - 6), "ORDERS", font=F(34), fill="white", anchor="mm", stroke_width=3, stroke_fill="#3a1a00")
    for i, ((name, col), (cx, cy)) in enumerate(zip(CARDS, POS)):
        d.rounded_rectangle((cx + 3, cy + 5, cx + 133, cy + 185), 10, fill=(0, 0, 0, 70))
        d.rounded_rectangle((cx, cy, cx + 130, cy + 180), 10, fill="#fffaf0", outline="#8a6a4a", width=2)
        d.rounded_rectangle((cx, cy, cx + 130, cy + 34), 10, fill=col)
        d.rectangle((cx, cy + 20, cx + 130, cy + 34), fill=col)
        d.ellipse((cx + 58, cy - 8, cx + 72, cy + 6), fill="#e23b3b", outline="#7a1010")
        d.text((cx + 65, cy + 60), name, font=F(24 if len(name) < 8 else 19), fill="#3a1a00", anchor="mm")
        for j in range(3):
            d.line((cx + 18, cy + 92 + j * 22, cx + 112 - j * 18, cy + 92 + j * 22), fill="#b9a68c", width=4)
    for i in range(done):
        stamp(im, i)
    return im.crop((20, 280, 520, 820))
for k in range(6):
    board(k).save(OUT + "/a4_board%d.webp" % k, quality=90, method=6)
ex["board"] = {"w": 500, "h": 540}
D["a4"] = ex
json.dump(D, open(OUT + "/a4.json", "w"))
# build window icons from the biggest sticker part of each build
for E in D["pics"][0]["st"]:
    big = max(E["parts"], key=lambda q: q["r"][2] * q["r"][3])
    im = Image.open(big["img"].replace("res://", "")).convert("RGBA")
    im.thumbnail((150, 150), Image.LANCZOS)
    ic = Image.new("RGBA", (160, 160), (0, 0, 0, 0))
    ic.alpha_composite(im, ((160 - im.width) // 2, (160 - im.height) // 2))
    ic.save("art/web/task-a4-%d.webp" % (E["i"] + 1), quality=90, method=6)
print("a4 done")
