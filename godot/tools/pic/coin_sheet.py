#!/usr/bin/env python3
"""Coin Blast tile sheet (20 Nov): the coin tile drawn once on the computer, crisp and with clean edges.
Frame 0 = plain tile, frames 1..48 = the shine stripe at each step (same maths as cm_game.gd _coin_draw, s = 46).
8 columns; each frame is (s + 4) board units at 4 px per unit."""
import sys
from PIL import Image, ImageDraw
import numpy as np

G = sys.argv[1]
S = 46.0
N = 48
K = 4            # px per board unit in the sheet
SS = 4           # supersampling
P = int((S + 4) * K)
cols, rows = 8, (N + 1 + 7) // 8
icon = Image.open(G + "/art/web/ui-coin.webp").convert("RGBA")


def rr_mask(scale, x, y, w, h, r):
    m = Image.new("L", (int(P * scale / K * K), int(P * scale / K * K)), 0)
    return m


def frame(sg):
    Z = K * SS
    W = int((S + 4) * Z)
    ox = oy = 2.0   # the tile starts 2 units into the frame (dest rect is x-2, y-2, s+4, s+4)
    def U(v):
        return v * Z
    # rounded rect (board units: x+1, y+1, s-2, s-2, radius 10)
    mask = Image.new("L", (W, W), 0)
    d = ImageDraw.Draw(mask)
    d.rounded_rectangle([U(ox + 1), U(oy + 1), U(ox + S - 1), U(oy + S - 1)], radius=U(10), fill=255)
    # vertical gradient #FFE58A -> #E9A21C over the cell height
    yy = (np.arange(W) / Z - oy) / S
    t = np.clip(yy, 0, 1)[:, None]
    c0 = np.array([0xFF, 0xE5, 0x8A], float)
    c1 = np.array([0xE9, 0xA2, 0x1C], float)
    col = c0 + (c1 - c0) * t[..., None]
    rgb = np.broadcast_to(col, (W, W, 3)).copy()
    img = Image.fromarray(np.dstack([rgb.astype(np.uint8), np.asarray(mask)]), "RGBA")
    # coin icon, 60% of the cell
    cs = S * 0.6
    ic = icon.resize((int(U(cs)), int(U(cs * 0.96))), Image.LANCZOS)
    img.alpha_composite(ic, (int(U(ox + (S - cs) / 2)), int(U(oy + (S - cs) / 2))))
    # shine band, cut by the rounded rect
    if S * sg > -7.0 and S * sg - S * 0.4 < S:
        band = Image.new("L", (W, W), 0)
        bd = ImageDraw.Draw(band)
        pts = [(ox + S * sg, oy), (ox + S * sg + 7, oy), (ox + S * sg - S * 0.4 + 7, oy + S), (ox + S * sg - S * 0.4, oy + S)]
        bd.polygon([(U(a), U(b)) for a, b in pts], fill=int(255 * 0.45))
        band = Image.fromarray((np.asarray(band).astype(float) * np.asarray(mask) / 255).astype(np.uint8))
        white = Image.new("RGBA", (W, W), (255, 255, 255, 0))
        white.putalpha(band)
        img.alpha_composite(white)
    # outline #FFF4C4, 2 units wide on the edge
    ol = Image.new("L", (W, W), 0)
    od = ImageDraw.Draw(ol)
    od.rounded_rectangle([U(ox + 1), U(oy + 1), U(ox + S - 1), U(oy + S - 1)], radius=U(10), outline=255, width=int(U(1.0)))
    od2 = Image.new("L", (W, W), 0)
    ImageDraw.Draw(od2).rounded_rectangle([U(ox + 0), U(oy + 0), U(ox + S), U(oy + S)], radius=U(11), outline=255, width=int(U(1.0)))
    ring = np.maximum(np.asarray(ol), np.asarray(od2))
    cream = Image.new("RGBA", (W, W), (0xFF, 0xF4, 0xC4, 0))
    cream.putalpha(Image.fromarray(ring))
    img.alpha_composite(cream)
    return img.resize((P, P), Image.LANCZOS)


a = -7.0 / S
sheet = Image.new("RGBA", (P * cols, P * rows), (0, 0, 0, 0))
for f in range(N + 1):
    sg = -9.0 if f == 0 else a + (1.4 - a) * (f - 1 + 0.5) / N
    sheet.paste(frame(sg), ((f % cols) * P, (f // cols) * P))
sheet.save(G + "/art/coin_sheet.png", optimize=True)
print("sheet", sheet.size, "frame", P)
