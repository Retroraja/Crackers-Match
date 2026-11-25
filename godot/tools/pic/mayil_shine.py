# 25 Nov (his ask 12:02): Mayil Matchbox must shine and look legendary. Baked into the one picture (no live effects):
# a soft teal/gold aura behind, brighter highlights on the sticks, a peacock-feather eye on the gold band,
# small 4-point sparkles. Run after mayil_recolor.py.
import math
import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageEnhance
S = 300
im = Image.open("art/toy/mayil.png").convert("RGBA")
a = np.array(im).astype(float)
# 1 brighter shine: lift the highlights (bright pixels get brighter), a little more contrast and colour
lum = a[..., :3].mean(2, keepdims=True) / 255
a[..., :3] = np.clip(a[..., :3] * (1 + 0.35 * lum ** 2) + 40 * np.clip(lum - 0.7, 0, 1) / 0.3, 0, 255)
im = Image.fromarray(a.astype(np.uint8))
im = ImageEnhance.Contrast(im).enhance(1.12)
im = ImageEnhance.Color(im).enhance(1.15)
# 2 aura: the shape's own outline, blurred, teal inside -> gold outside
al = im.getchannel("A")
aura = Image.new("RGBA", (S, S), (0, 0, 0, 0))
for col, grow, blur in [((255, 210, 90, 60), 6, 8), ((60, 220, 210, 70), 3, 4)]:
    m = al.filter(ImageFilter.MaxFilter(grow * 2 + 1)).filter(ImageFilter.GaussianBlur(blur))
    l = Image.new("RGBA", (S, S), col)
    l.putalpha(m.point(lambda v, k=col[3]: int(v * k / 255)))
    aura.alpha_composite(l)
# keep the picture inside 300 x 300: shrink the box a little so the aura fits
box = im.resize((262, 262), Image.LANCZOS)
aura = aura.resize((262, 262), Image.LANCZOS)
out = Image.new("RGBA", (S, S), (0, 0, 0, 0))
big = Image.new("RGBA", (S, S), (0, 0, 0, 0))
big.alpha_composite(aura, (19, 26))
big = big.filter(ImageFilter.GaussianBlur(2))
out.alpha_composite(big)
out.alpha_composite(box, (19, 26))
# 3 peacock-feather eye on the front of the gold band
K = 4
fe = Image.new("RGBA", (60 * K, 60 * K), (0, 0, 0, 0)); d = ImageDraw.Draw(fe)
c = 30 * K
for rx, ry, col in [(20, 26, (255, 215, 90)), (16, 22, (30, 170, 110)), (12, 17, (20, 165, 190)), (8, 12, (215, 175, 70)), (6, 9, (25, 60, 170)), (3, 5, (10, 20, 80))]:
    d.ellipse([c - rx * K, c - ry * K, c + rx * K, c + ry * K], fill=col + (255,))
d.ellipse([c - 3 * K, c - 8 * K, c, c - 4 * K], fill=(170, 210, 255, 255))
fe = fe.resize((40, 40), Image.LANCZOS)
out.alpha_composite(fe, (S // 2 - 20 + 2, 26 + int(262 * 0.53) - 20))
# 4 sparkles (4-point stars, white with a gold glow)
def spark(img, x, y, r):
    L = Image.new("RGBA", (S, S), (0, 0, 0, 0)); g = ImageDraw.Draw(L)
    g.ellipse([x - r * 0.9, y - r * 0.9, x + r * 0.9, y + r * 0.9], fill=(255, 220, 120, 120))
    L = L.filter(ImageFilter.GaussianBlur(r * 0.5))
    g = ImageDraw.Draw(L)
    for ang in (0, math.pi / 2):
        pts = []
        for k in range(4):
            t = ang + k * math.pi / 2
            rr = r if k % 2 == 0 else r * 0.14
            pts.append((x + math.cos(t) * rr, y + math.sin(t) * rr))
        g.polygon([pts[0], (x + r * 0.14, y + r * 0.14), pts[2], (x - r * 0.14, y - r * 0.14)] if ang == 0 else [pts[0], (x - r * 0.14, y + r * 0.14), pts[2], (x + r * 0.14, y - r * 0.14)], fill=(255, 255, 240, 255))
    img.alpha_composite(L)
for x, y, r in [(70, 62, 16), (238, 92, 12), (222, 238, 14), (84, 230, 9), (182, 36, 8)]:
    spark(out, x, y, r)
out.save("art/toy/mayil.png")
