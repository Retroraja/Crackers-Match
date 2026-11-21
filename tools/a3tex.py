# Area 3 (back store room of GHILLI): small painted textures (PIL). Run: python3 tools/a3tex.py godot/art/a3
import sys, os, random, math
from PIL import Image, ImageDraw, ImageFilter
OUT = sys.argv[1] if len(sys.argv) > 1 else "godot/art/a3"
os.makedirs(OUT, exist_ok=True)
random.seed(3)

def noise(w, h, base, var, blur=1.2):
    im = Image.new("RGB", (w, h), base)
    px = im.load()
    for y in range(h):
        for x in range(w):
            n = random.randint(-var, var)
            px[x, y] = tuple(max(0, min(255, c + n)) for c in base)
    return im.filter(ImageFilter.GaussianBlur(blur))

# burlap sack: woven grid
im = noise(256, 256, (176, 146, 100), 18, 0.6)
d = ImageDraw.Draw(im)
for i in range(0, 256, 4):
    d.line([(i, 0), (i, 256)], fill=(150, 122, 82), width=1)
    d.line([(0, i + 2), (256, i + 2)], fill=(196, 168, 120), width=1)
im.filter(ImageFilter.GaussianBlur(0.5)).save(f"{OUT}/burlap.jpg", quality=88)

# newspaper bundle side: grey paper with printed lines
im = noise(256, 256, (214, 208, 192), 8, 0.8)
d = ImageDraw.Draw(im)
for y in range(6, 256, 7):
    d.line([(0, y), (256, y)], fill=(150, 146, 136), width=2)
im.save(f"{OUT}/paper.jpg", quality=88)

# cobweb (alpha)
S = 256
im = Image.new("RGBA", (S, S), (0, 0, 0, 0))
d = ImageDraw.Draw(im)
c = (235, 235, 235, 150)
rays = [i * math.pi / 2 / 7 for i in range(8)]
for a in rays:
    d.line([(0, 0), (math.cos(a) * S * 1.4, math.sin(a) * S * 1.4)], fill=c, width=2)
for r in range(20, S + 60, 24):
    pts = []
    for a in rays:
        rr = r * (1 + 0.08 * math.sin(a * 9 + r))
        pts.append((math.cos(a) * rr, math.sin(a) * rr))
    for p, q in zip(pts, pts[1:]):
        m = ((p[0] + q[0]) / 2 * 0.93, (p[1] + q[1]) / 2 * 0.93)
        d.line([p, m, q], fill=c, width=1)
im.filter(ImageFilter.GaussianBlur(0.4)).save(f"{OUT}/cobweb.png")

# dirt / dust patch (alpha)
im = Image.new("RGBA", (256, 256), (0, 0, 0, 0))
d = ImageDraw.Draw(im)
for _ in range(90):
    x, y, r = random.randint(30, 226), random.randint(30, 226), random.randint(6, 34)
    d.ellipse([x - r, y - r, x + r, y + r], fill=(70, 56, 40, random.randint(14, 34)))
im.filter(ImageFilter.GaussianBlur(10)).save(f"{OUT}/dirt.png")

# light shaft (alpha gradient, soft edges)
im = Image.new("RGBA", (64, 256), (0, 0, 0, 0))
px = im.load()
for y in range(256):
    for x in range(64):
        e = math.sin(math.pi * x / 63) ** 1.5
        a = int(120 * e * (1 - y / 255) ** 1.3)
        px[x, y] = (255, 228, 170, a)
im.save(f"{OUT}/shaft.png")
print("ok")
