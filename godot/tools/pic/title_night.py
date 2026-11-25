# 25 Nov: new title picture (no bakery): night over Grandpa's street, the Crackers Factory with warm lit windows,
# a display of our crackers in front (the game's own 3D cracker pictures). Fireworks + logo are added live by title.gd.
# render: pic_tool.tscn -- --area=1 --step=10 --w=1080 --h=2338 --night=0.8 --p=4,5,-30 --l=-1,6,-57 --fov=55 --msaa=1
# (render at 1620x3507 without MSAA, shrink to 1080x2338 first)
# usage: python3 tools/pic/title_night.py /tmp/s/title_r2.png
import sys
import numpy as np
from PIL import Image, ImageFilter, ImageEnhance
W, H = 1080, 2338
im = Image.open(sys.argv[1]).convert("RGBA")
sky = Image.open("street/art/sky.png").convert("RGBA").resize(im.size)
a = np.asarray(sky).astype(np.float32)
k = np.array([0.16, 0.18, 0.42, 1.0], np.float32)       # deep night sky
sky = Image.fromarray(np.clip(a * k, 0, 255).astype(np.uint8))
sky.alpha_composite(im)
pic = sky.convert("RGB")
# warm glow in the factory windows (light-blue glass in the facade area only)
p = np.asarray(pic).astype(np.float32)
x0, x1, y0, y1 = int(W * 0.33), int(W * 0.8), int(H * 0.38), int(H * 0.69)
reg = p[y0:y1, x0:x1]
r, g, b = reg[..., 0], reg[..., 1], reg[..., 2]
win = (b > r + 18) & (b > 70) & (b < 200) & (g > 55)
m = np.zeros((H, W), np.uint8)
m[y0:y1, x0:x1][win] = 255
mi = Image.fromarray(m).filter(ImageFilter.MaxFilter(3))
warm = Image.new("RGB", (W, H), (255, 196, 90))
pic = Image.composite(warm, pic, mi.filter(ImageFilter.GaussianBlur(1)))
glow = Image.new("RGBA", (W, H), (255, 170, 60, 0))
glow.putalpha(mi.filter(ImageFilter.GaussianBlur(24)).point(lambda v: int(v * 0.8)))
pic = pic.convert("RGBA")
pic.alpha_composite(glow)
pic = ImageEnhance.Brightness(pic.convert("RGB")).enhance(1.08).convert("RGBA")
# our crackers on display in front (rocket, flowerpot, bomb, chakra, sky shot, matchbox, and plain crackers)
def crk(n, s, x, y):
    c = Image.open("art/crk/%s.webp" % n).convert("RGBA")
    c = c.resize((int(300 * s), int(300 * s)), Image.LANCZOS)
    sh = Image.new("RGBA", pic.size, (0, 0, 0, 0))
    e = Image.new("RGBA", (int(220 * s), int(50 * s)), (0, 0, 0, 0))
    from PIL import ImageDraw
    ImageDraw.Draw(e).ellipse([0, 0, e.width - 1, e.height - 1], fill=(0, 0, 0, 150))
    e = e.filter(ImageFilter.GaussianBlur(8 * s))
    pic.alpha_composite(e, (int(x - e.width / 2), int(y - e.height / 2)))
    pic.alpha_composite(c, (int(x - c.width / 2), int(y - c.height * 0.97)))
row_back = [("b9", 0.62, 190, 1700), ("t3", 0.55, 345, 1690), ("b14", 0.62, 540, 1685), ("t1", 0.55, 735, 1690), ("b7", 0.62, 890, 1700)]
row_front = [("t0", 0.68, 120, 1840), ("b10", 0.72, 315, 1855), ("b6", 0.78, 540, 1865), ("b8", 0.72, 765, 1855), ("t2", 0.68, 960, 1840)]
for q in row_back + row_front:
    crk(*q)
pic.convert("RGB").save("art/web/title_base.webp", quality=88, method=6)
pic.convert("RGB").resize((390, 844)).save("/tmp/s/title_prev.png")
