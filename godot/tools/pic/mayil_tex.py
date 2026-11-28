# 25 Nov: textures for the Mayil Matchbox 3D render (toy3d.gd --toy=mayil): front label with a peacock feather,
# side colour. Peacock blue -> purple, silver and gold frame lines.
import math
from PIL import Image, ImageDraw, ImageFilter
OUT = "tools/pic/tex/"
W, H = 512, 720
def grad(w, h, top, bot):
    im = Image.new("RGBA", (w, h))
    d = ImageDraw.Draw(im)
    for y in range(h):
        t = y / (h - 1)
        d.line([(0, y), (w, y)], fill=tuple(int(top[i] + (bot[i] - top[i]) * t) for i in range(3)) + (255,))
    return im
lab = grad(W, H, (6, 62, 140), (70, 18, 120))
d = ImageDraw.Draw(lab)
# frame: silver outer, gold inner
d.rounded_rectangle([18, 18, W - 18, H - 18], 26, outline=(225, 230, 240), width=10)
d.rounded_rectangle([40, 40, W - 40, H - 40], 18, outline=(255, 205, 70), width=7)
# feather (teardrop of fine barbs around a small eye, long shaft), drawn 3x and shrunk so the lines are smooth
K = 3
fe = Image.new("RGBA", (W * K, H * K), (0, 0, 0, 0)); f = ImageDraw.Draw(fe)
cx, ey = W * K // 2, 250 * K
top, bot = 100 * K, 560 * K
for i in range(260):
    t = i / 259                       # 0 at the top of the feather, 1 at the bottom of the vane
    y = top + t * (bot - top)
    # teardrop half-width: widest around the eye, narrowing to the shaft
    wdt = (150 * math.sin(math.pi * min(1.0, t * 1.15)) ** 0.8) * K
    for s_ in (-1, 1):
        x2 = cx + s_ * wdt
        y2 = y - 34 * K * (0.4 + t)
        g = 0.5 + 0.5 * math.sin(t * 9)
        col = (int(40 + 70 * g), int(150 + 60 * (1 - t)), int(90 + 40 * g), 230)
        f.line([(cx, y), (cx + s_ * wdt * 0.55, y - 14 * K), (x2, y2)], fill=col, width=2 * K)
f.line([(cx, 650 * K), (cx, ey + 60 * K)], fill=(245, 222, 160, 255), width=6 * K)
for (rx, ry, col) in [(78, 104, (205, 165, 60)), (66, 90, (46, 170, 100)), (54, 74, (25, 160, 175)), (40, 56, (212, 175, 70)), (32, 46, (25, 70, 170)), (18, 28, (12, 22, 90))]:
    f.ellipse([cx - rx * K, ey - ry * K + 10 * K, cx + rx * K, ey + ry * K + 10 * K], fill=col + (255,))
f.ellipse([cx - 9 * K, ey - 14 * K, cx + 3 * K, ey], fill=(130, 180, 255, 255))
fe = fe.resize((W, H), Image.LANCZOS)
glow = fe.copy().filter(ImageFilter.GaussianBlur(10))
lab.alpha_composite(glow)
lab.alpha_composite(fe)
d = ImageDraw.Draw(lab)
# gold stars at the corners
for (x, y) in [(80, 80), (W - 80, 80), (80, H - 80), (W - 80, H - 80)]:
    pts = []
    for k in range(10):
        a = -math.pi / 2 + k * math.pi / 5
        r = 16 if k % 2 == 0 else 7
        pts.append((x + math.cos(a) * r, y + math.sin(a) * r))
    d.polygon(pts, fill=(255, 215, 90, 255))
lab.save(OUT + "mayil_front.png")
side = grad(256, 720, (20, 80, 160), (70, 28, 130))
ImageDraw.Draw(side).rectangle([0, 0, 255, 719], outline=(255, 205, 70), width=8)
side.save(OUT + "mayil_side.png")
# striker: silver with dark grit
st = Image.new("RGBA", (256, 720), (190, 195, 205, 255)); s2 = ImageDraw.Draw(st)
import random
random.seed(3)
for i in range(5000):
    x, y = random.randrange(256), random.randrange(720)
    s2.point((x, y), fill=(90, 70, 60, 255))
st.save(OUT + "mayil_strike.png")
