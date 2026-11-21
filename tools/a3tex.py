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

# ---- builds (21 Nov)
# cork board with a wooden frame
im = noise(512, 352, (176, 122, 72), 22, 0.9)
d = ImageDraw.Draw(im)
for _ in range(900):
    x, y = random.randint(0, 511), random.randint(0, 351)
    d.point((x, y), fill=(120, 80, 45))
d.rectangle([0, 0, 511, 351], outline=(92, 58, 34), width=18)
im.save(f"{OUT}/cork.jpg", quality=88)

# order slip: white paper, red heading line, a few written lines
from PIL import ImageFont
def slip(i):
    im = Image.new("RGB", (128, 160), (250, 246, 232))
    d = ImageDraw.Draw(im)
    d.rectangle([0, 0, 127, 22], fill=[(214, 40, 70), (46, 134, 222), (46, 173, 91), (255, 122, 26)][i % 4])
    for k in range(6):
        w = random.randint(50, 110)
        d.line([(10, 36 + k * 18), (10 + w, 36 + k * 18)], fill=(60, 60, 90), width=3)
    d.ellipse([56, 4, 72, 18], fill=(230, 200, 60))
    return im
for i in range(4):
    slip(i).save(f"{OUT}/slip{i}.jpg", quality=90)

# gift wrap papers: stripes and dots
cols = [((214, 40, 70), (250, 196, 60)), ((46, 134, 222), (250, 250, 250)), ((123, 63, 191), (250, 196, 60)), ((46, 173, 91), (255, 230, 120))]
for i, (a, b) in enumerate(cols):
    im = Image.new("RGB", (128, 128), a)
    d = ImageDraw.Draw(im)
    if i % 2 == 0:
        for k in range(0, 256, 32):
            d.polygon([(k, 0), (k + 14, 0), (k + 14 - 128, 128), (k - 128, 128)], fill=b)
    else:
        for y in range(8, 128, 24):
            for x in range(8 + (y // 24 % 2) * 12, 128, 24):
                d.ellipse([x - 5, y - 5, x + 5, y + 5], fill=b)
    im.save(f"{OUT}/wrap{i}.jpg", quality=90)

# cracker carton face: bright label with a burst
def carton(i):
    bg = [(214, 40, 70), (250, 160, 30), (46, 134, 222), (46, 173, 91), (123, 63, 191), (240, 200, 60)][i]
    im = Image.new("RGB", (128, 96), (196, 160, 112))
    d = ImageDraw.Draw(im)
    d.rectangle([10, 14, 118, 82], fill=bg)
    cx, cy = 40, 48
    for k in range(10):
        a = k * math.pi / 5
        d.line([(cx, cy), (cx + math.cos(a) * 22, cy + math.sin(a) * 22)], fill=(255, 245, 200), width=3)
    for k in range(3):
        d.rectangle([72, 30 + k * 14, 110, 36 + k * 14], fill=(255, 250, 235))
    return im
for i in range(6):
    carton(i).save(f"{OUT}/carton{i}.jpg", quality=90)
print("builds ok")

# ---- bright order room (21 Nov): light cream and red floor tiles (2 x 2 tiles per picture, grout lines)
im = Image.new("RGB", (256, 256), (240, 228, 205))
d = ImageDraw.Draw(im)
for ty in range(2):
    for tx in range(2):
        c = (240, 230, 208) if (tx + ty) % 2 == 0 else (212, 112, 90)
        d.rectangle([tx * 128 + 3, ty * 128 + 3, tx * 128 + 124, ty * 128 + 124], fill=c)
n = noise(256, 256, (128, 128, 128), 10, 1.0).convert("L")
im = Image.blend(im, Image.merge("RGB", [n] * 3), 0.08)
im.save(f"{OUT}/floor_bright.jpg", quality=90)
print("floor ok")

# ---- parcel tags for other towns
F = ImageFont.truetype(os.path.join(os.path.dirname(os.path.abspath(__file__)), "../godot/fonts/LilitaOne.ttf"), 30)
for i, (town, col) in enumerate([("KANCHIPURAM", (214, 40, 70)), ("VELLORE", (46, 134, 222)), ("MADURAI", (46, 173, 91)), ("SALEM", (255, 122, 26))]):
    im = Image.new("RGB", (256, 96), (250, 246, 232))
    d = ImageDraw.Draw(im)
    d.rectangle([0, 0, 255, 95], outline=col, width=8)
    fs = 30
    f = F
    while d.textlength(town, font=f) > 228:
        fs -= 2; f = f.font_variant(size=fs)
    d.text((128, 50), town, font=f, fill=col, anchor="mm")
    im.save(f"{OUT}/tag{i}.jpg", quality=90)
# fire sign
im = Image.new("RGB", (256, 128), (200, 30, 40))
d = ImageDraw.Draw(im)
d.rectangle([0, 0, 255, 127], outline=(255, 255, 255), width=8)
d.text((128, 64), "FIRE SAFETY", font=F.font_variant(size=34), fill=(255, 255, 255), anchor="mm")
im.save(f"{OUT}/firesign.jpg", quality=90)
print("tags ok")
