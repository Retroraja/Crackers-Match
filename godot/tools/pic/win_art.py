# Win screen pictures (23 Nov), made once on the computer (fps-rules: no live drawing):
#   art/win/star.png, star_off.png  gold star / empty slot     art/win/rays.png  soft gold rays (rotated in the game)
# Run from godot/: python3 tools/pic/win_art.py
import math
from PIL import Image, ImageDraw, ImageFilter
def star_pts(cx, cy, r, k=0.48):
    return [(cx + math.cos(-math.pi / 2 + i * math.pi / 5) * (r if i % 2 == 0 else r * k),
             cy + math.sin(-math.pi / 2 + i * math.pi / 5) * (r if i % 2 == 0 else r * k)) for i in range(10)]
S = 4
def star(fill_top, fill_bot, edge, shine=True):
    W = 160 * S
    im = Image.new('RGBA', (W, W), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    c = W / 2
    d.polygon(star_pts(c, c + 6 * S, 74 * S), fill=edge)
    # vertical gold gradient inside
    g = Image.new('RGBA', (W, W))
    gd = ImageDraw.Draw(g)
    for y in range(W):
        t = y / W
        col = tuple(int(fill_top[i] + (fill_bot[i] - fill_top[i]) * t) for i in range(3)) + (255,)
        gd.line([(0, y), (W, y)], fill=col)
    m = Image.new('L', (W, W), 0)
    ImageDraw.Draw(m).polygon(star_pts(c, c + 4 * S, 62 * S), fill=255)
    im.paste(g, (0, 0), m)
    if shine:
        sh = Image.new('L', (W, W), 0)
        ImageDraw.Draw(sh).polygon(star_pts(c - 6 * S, c - 6 * S, 34 * S, 0.5), fill=110)
        sh = sh.filter(ImageFilter.GaussianBlur(6 * S))
        im.paste((255, 255, 240, 255), (0, 0), Image.composite(sh, Image.new('L', (W, W), 0), m))
    return im.resize((160, 160), Image.LANCZOS)
star((255, 240, 140), (240, 150, 20), (120, 50, 10, 255)).save('art/win/star.png')
star((90, 60, 120), (60, 35, 90), (40, 20, 60, 230), False).save('art/win/star_off.png')
# rays: 16 soft wedges fading out from the centre
W = 720
r = Image.new('L', (W, W), 0)
d = ImageDraw.Draw(r)
for i in range(16):
    a = i * math.tau / 16
    w = 0.09
    d.polygon([(W / 2, W / 2), (W / 2 + math.cos(a - w) * W, W / 2 + math.sin(a - w) * W), (W / 2 + math.cos(a + w) * W, W / 2 + math.sin(a + w) * W)], fill=255)
r = r.filter(ImageFilter.GaussianBlur(10))
fade = Image.new('L', (W, W), 0)
fd = ImageDraw.Draw(fade)
for k in range(180, 0, -1):
    v = int(255 * (1 - k / 180) ** 1.4)
    fd.ellipse((W / 2 - k * 2, W / 2 - k * 2, W / 2 + k * 2, W / 2 + k * 2), fill=v)
a = Image.composite(r, Image.new('L', (W, W), 0), fade).point(lambda v: int(v * 0.55))
Image.merge('RGBA', (Image.new('L', (W, W), 255), Image.new('L', (W, W), 214), Image.new('L', (W, W), 120), a)).save('art/win/rays.png')
print('ok')
