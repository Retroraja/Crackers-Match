#!/usr/bin/env python3
"""Picture-based areas (20 Nov): turns the rendered build states (tools/pic/pic_tool.gd, sN.png = the picture after
N builds) into what the phone needs: one base picture per view (no builds) and one cut-out sticker per build that
changes the view (the pixels that differ from the state before it, shadows included).

usage: make_pics.py RENDER_DIR GODOT_DIR
  RENDER_DIR/a1p0/s0.png .. s10.png, a1p1, a1p2, a2p0, a2p1, title/s10.png, a1end/s10.png
"""
import json, os, sys
import numpy as np
from PIL import Image, ImageFilter

R, G = sys.argv[1], sys.argv[2]
OUT = os.path.join(G, "street/pics")
os.makedirs(OUT, exist_ok=True)
W, H = 1080, 2338
SKY = Image.open(os.path.join(G, "street/art/sky.png")).convert("RGBA")

AREAS = {
    1: {"n": 10, "pics": [("a1p0", [0, 1, 2]), ("a1p1", [3, 4, 5, 6]), ("a1p2", [7, 8, 9])], "sky": True},
    2: {"n": 12, "pics": [("a2p0", [0, 1, 2, 3, 4, 5]), ("a2p1", [6, 7, 8, 9, 10, 11])], "sky": False},
}


def load(path, sky, night=0.0):
    im = Image.open(path).convert("RGBA")
    if sky:
        b = SKY.resize(im.size, Image.BICUBIC)
        if night > 0:
            a = np.asarray(b).astype(np.float32)
            k = np.array([1 + (0.22 - 1) * night, 1 + (0.24 - 1) * night, 1 + (0.48 - 1) * night, 1.0], np.float32)
            b = Image.fromarray(np.clip(a * k, 0, 255).astype(np.uint8))
        b.alpha_composite(im)
        im = b
    return im.resize((W, H), Image.LANCZOS).convert("RGB")


def mask_of(a, b):
    d = np.abs(a.astype(np.int16) - b.astype(np.int16)).max(axis=2)
    m = Image.fromarray(((d > 12) * 255).astype(np.uint8))
    m = m.filter(ImageFilter.MinFilter(3)).filter(ImageFilter.MaxFilter(3))   # drop single-pixel noise
    m = m.filter(ImageFilter.MaxFilter(5)).filter(ImageFilter.GaussianBlur(1.6))
    return np.asarray(m)


def split(m, max_parts=14):
    """one build = several objects (lamps, trees, stalls): each pops on its own from its own base"""
    from scipy import ndimage
    lab, n = ndimage.label(ndimage.binary_dilation(m > 8, iterations=6), structure=np.ones((3, 3)))
    core = (m > 128)
    cnt = ndimage.sum(core, lab, range(1, n + 1)) if n else []
    cm = ndimage.center_of_mass(core, lab, range(1, n + 1)) if n else []
    groups = [[k + 1] for k in range(n)]
    inf = [[float(cnt[k]), (cm[k][1], cm[k][0]) if cnt[k] > 0 else (0.0, 0.0)] for k in range(n)]
    # tiny bits and too many pieces: join the smallest to its nearest neighbour
    while len(groups) > 1:
        k = min(range(len(groups)), key=lambda q: inf[q][0])
        if inf[k][0] >= 900 and len(groups) <= max_parts:
            break
        c = inf[k][1]
        o = min((q for q in range(len(groups)) if q != k), key=lambda q: (inf[q][1][0] - c[0]) ** 2 + (inf[q][1][1] - c[1]) ** 2)
        a, b = inf[o][0], inf[k][0]
        if a + b > 0:
            inf[o][1] = ((inf[o][1][0] * a + c[0] * b) / (a + b), (inf[o][1][1] * a + c[1] * b) / (a + b))
        inf[o][0] = a + b
        groups[o] += groups[k]
        del groups[k]
        del inf[k]
    out = []
    for g in groups:
        pm = np.where(np.isin(lab, g), m, 0).astype(np.uint8)
        if (pm > 8).sum() > 0:
            out.append(pm)
    return out


def main():
    for A, cfg in AREAS.items():
        data = {"w": W, "h": H, "pics": []}
        for p, (d, builds) in enumerate(cfg["pics"]):
            st = [np.asarray(load(os.path.join(R, d, "s%d.png" % k), cfg["sky"])) for k in range(cfg["n"] + 1)]
            base = "a%d_p%d.webp" % (A, p)
            Image.fromarray(st[0]).save(os.path.join(OUT, base), quality=86, method=6)
            P = {"base": "res://street/pics/" + base, "builds": builds, "st": []}
            for i in range(cfg["n"]):
                m = mask_of(st[i + 1], st[i])
                core = m > 128
                if core.sum() < 120:
                    continue
                parts = split(m)
                cy, cx = np.nonzero(core)
                site = [float(cx.mean()), float(cy.mean())]
                E = {"i": i, "site": site, "parts": []}
                for j, pm in enumerate(parts):
                    ys, xs = np.nonzero(pm > 8)
                    x0, x1, y0, y1 = xs.min(), xs.max() + 1, ys.min(), ys.max() + 1
                    rgba = np.dstack([st[i + 1][y0:y1, x0:x1], pm[y0:y1, x0:x1]])
                    name = "a%d_p%d_b%d_%d.webp" % (A, p, i, j)
                    Image.fromarray(rgba, "RGBA").save(os.path.join(OUT, name), quality=88, method=6)
                    E["parts"].append({"img": "res://street/pics/" + name, "r": [int(x0), int(y0), int(x1 - x0), int(y1 - y0)],
                                       "piv": [float((x0 + x1) / 2), float(y1)], "big": bool((pm > 128).sum() > W * H * 0.12)})
                E["parts"].sort(key=lambda q: -q["piv"][1])
                P["st"].append(E)
                print("a%d p%d build %d: %d parts" % (A, p, i, len(parts)))
            data["pics"].append(P)
        with open(os.path.join(OUT, "a%d.json" % A), "w") as f:
            json.dump(data, f)
    # title picture and the Area 1 dusk picture
    t = os.path.join(R, "title/s10.png")
    if os.path.exists(t):
        load(t, True).save(os.path.join(G, "art/web/title_base.webp"), quality=88, method=6)
    e = os.path.join(R, "a1end/s10.png")
    if os.path.exists(e):
        load(e, True, 0.75).save(os.path.join(OUT, "a1_dusk.webp"), quality=86, method=6)


main()
