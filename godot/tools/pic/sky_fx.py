# 25 Nov Sky Shot: ready-made pictures (fps rule: no live drawing): target ring (gold for goal tiles, white),
# a star with a short gold trail (tail points up), a soft gold flash
import math
from PIL import Image, ImageDraw, ImageFilter
S = 4
def ring(col, out):
    W = 96 * S
    im = Image.new("RGBA", (W, W), (0, 0, 0, 0))
    g = Image.new("RGBA", (W, W), (0, 0, 0, 0)); d = ImageDraw.Draw(g)
    d.ellipse([10 * S, 10 * S, W - 10 * S, W - 10 * S], outline=col + (200,), width=10 * S)
    g = g.filter(ImageFilter.GaussianBlur(5 * S)); im.alpha_composite(g)
    d = ImageDraw.Draw(im)
    d.ellipse([14 * S, 14 * S, W - 14 * S, W - 14 * S], outline=col + (255,), width=4 * S)
    d.ellipse([19 * S, 19 * S, W - 19 * S, W - 19 * S], outline=(255, 255, 255, 170), width=1 * S)
    im.resize((96, 96), Image.LANCZOS).save(out)
ring((255, 200, 50), "art/fx/ring_gold.png")
ring((200, 230, 255), "art/fx/ring_white.png")
# star with a trail: 64 x 160, star centre at (32, 128), the trail goes up
W, H = 64 * S, 160 * S
im = Image.new("RGBA", (W, H), (0, 0, 0, 0))
tr = Image.new("RGBA", (W, H), (0, 0, 0, 0)); d = ImageDraw.Draw(tr)
for i in range(40):
    t = i / 39
    y = 128 * S - t * 110 * S
    r = (9 - 7 * t) * S
    d.ellipse([32 * S - r, y - r, 32 * S + r, y + r], fill=(255, 205, 70, int(200 * (1 - t))))
tr = tr.filter(ImageFilter.GaussianBlur(3 * S)); im.alpha_composite(tr)
def star(cx, cy, r1, r2):
    return [(cx + math.cos(-math.pi / 2 + k * math.pi / 5) * (r1 if k % 2 == 0 else r2), cy + math.sin(-math.pi / 2 + k * math.pi / 5) * (r1 if k % 2 == 0 else r2)) for k in range(10)]
gl = Image.new("RGBA", (W, H), (0, 0, 0, 0)); ImageDraw.Draw(gl).ellipse([10 * S, 106 * S, 54 * S, 150 * S], fill=(255, 220, 90, 150))
gl = gl.filter(ImageFilter.GaussianBlur(6 * S)); im.alpha_composite(gl)
d = ImageDraw.Draw(im)
d.polygon(star(32 * S, 128 * S, 18 * S, 8 * S), fill=(255, 200, 40, 255), outline=(170, 100, 0, 255))
d.polygon(star(32 * S, 128 * S, 8 * S, 3.6 * S), fill=(255, 255, 255, 255))
im.resize((64, 160), Image.LANCZOS).save("art/fx/star_trail.png")
# soft gold flash (radial)
W = 128 * S
im = Image.new("RGBA", (W, W), (0, 0, 0, 0)); d = ImageDraw.Draw(im)
for i in range(64, 0, -1):
    t = i / 64
    d.ellipse([W / 2 - t * W / 2, W / 2 - t * W / 2, W / 2 + t * W / 2, W / 2 + t * W / 2], fill=(255, int(210 + 45 * (1 - t)), int(80 + 170 * (1 - t) ** 2), int(255 * (1 - t) ** 1.6)))
im.resize((128, 128), Image.LANCZOS).save("art/fx/flash_gold.png")
