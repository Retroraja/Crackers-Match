# New obstacle looks (23 Nov, "one bold object per tile with a sharp dark outline, like the clay pot"):
#   art/brk/diyab.png, diyab_c.png   one big clay diya, and cracked
#   art/brk/giftr.png                gift box with gold ribbon and bow (hit 1 unties the ribbon)
#   art/brk/gifto.png                the same box, ribbon gone (hit 2: lid pops, sides fall open, confetti)
#   art/brk/gift_lid.png, gift_l.png, gift_r.png   lid and the two halves of the box, for the burst
# 312 px pictures, object ~240 px in the middle, outline baked in. Run from godot/: python3 tools/pic/brk_new.py
import math, random
from PIL import Image, ImageDraw, ImageFilter
S = 4
W = 312 * S
OUT = (34, 12, 4, 255)
def P(*xy): return [(x * S, y * S) for x, y in zip(xy[::2], xy[1::2])]
def B(x0, y0, x1, y1): return (x0 * S, y0 * S, x1 * S, y1 * S)
def grad(box, top, bot):
    g = Image.new('RGBA', (W, W))
    d = ImageDraw.Draw(g)
    y0, y1 = box[1], box[3]
    for y in range(W):
        t = min(1, max(0, (y - y0) / max(1, y1 - y0)))
        d.line([(0, y), (W, y)], fill=tuple(int(top[i] + (bot[i] - top[i]) * t) for i in range(3)) + (255,))
    return g
def fin(im, name):
    im.resize((312, 312), Image.LANCZOS).save('art/brk/%s.png' % name)
def outline_of(mask, w):
    return mask.filter(ImageFilter.MaxFilter(w * 2 + 1))
def paint(base, mask, fill_img):
    base.paste(fill_img, (0, 0), mask)
# ---------------------------------------------------------------- diya
def diya(cracked):
    im = Image.new('RGBA', (W, W), (0, 0, 0, 0))
    # body mask: bowl + spout + foot
    m = Image.new('L', (W, W), 0)
    d = ImageDraw.Draw(m)
    d.chord(B(34, 70, 254, 250), 0, 180, fill=255)               # bowl (lower half)
    d.ellipse(B(34, 132, 254, 188), fill=255)                      # rim
    d.polygon(P(200, 140, 292, 118, 286, 132, 226, 196), fill=255)  # spout to the right, sharp tip
    d.ellipse(B(104, 226, 184, 256), fill=255)                     # foot
    # outline
    o = outline_of(m, 9 * S // 2)
    im.paste(OUT, (0, 0), o)
    paint(im, m, grad(B(0, 130, 0, 250), (236, 132, 64), (128, 50, 16)))
    d2 = ImageDraw.Draw(im)
    # edge shading on the right of the bowl
    sh = Image.new('L', (W, W), 0)
    ImageDraw.Draw(sh).ellipse(B(150, 140, 300, 300), fill=90)
    sh = sh.filter(ImageFilter.GaussianBlur(14 * S))
    im.paste((70, 20, 4, 255), (0, 0), Image.composite(sh, Image.new('L', (W, W), 0), m))
    # the opening: dark oil with a rim light
    d2.ellipse(B(46, 138, 242, 182), fill=(232, 130, 70, 255))
    d2.ellipse(B(54, 142, 236, 178), fill=(70, 24, 6, 255))
    d2.ellipse(B(70, 146, 180, 166), fill=(120, 52, 14, 255))
    d2.polygon(P(214, 146, 284, 125, 228, 162), fill=(70, 24, 6, 255))
    # white dot band
    for i in range(11):
        t = i / 10
        x = 62 + t * 164
        y = 205 - math.sin(t * math.pi) * 6 + 0
        d2.ellipse(B(x - 4, y - 4, x + 4, y + 4), fill=(255, 236, 200, 255))
    d2.arc(B(56, 120, 232, 222), 20, 160, fill=(255, 220, 170, 255), width=3 * S)
    # shine
    hl = Image.new('L', (W, W), 0)
    ImageDraw.Draw(hl).ellipse(B(70, 186, 120, 214), fill=150)
    hl = hl.filter(ImageFilter.GaussianBlur(5 * S))
    im.paste((255, 235, 200, 255), (0, 0), Image.composite(hl, Image.new('L', (W, W), 0), m))
    if cracked:
        random.seed(5)
        for (x, y, a) in [(110, 182, 1.9), (176, 186, 1.2), (148, 206, 1.4)]:
            pts = [(x, y)]
            for k in range(5):
                a += random.uniform(-0.6, 0.6)
                x += math.cos(a) * 11
                y += math.sin(a) * 11 if k < 4 else 6
                pts.append((x, y))
            d2.line([(px * S, py * S) for px, py in pts], fill=OUT, width=4 * S, joint='curve')
    up = Image.new('RGBA', (W, W), (0, 0, 0, 0))
    up.paste(im, (0, -26 * S))   # centre the lamp in its tile
    fin(up, 'diyab_c' if cracked else 'diyab')
diya(False)
diya(True)
# ---------------------------------------------------------------- gift box
TEAL_T, TEAL_B = (52, 214, 200), (12, 128, 120)
GOLD = (255, 212, 80, 255)
GOLD_D = (190, 130, 20, 255)
def box_masks():
    lid = Image.new('L', (W, W), 0)
    ImageDraw.Draw(lid).rounded_rectangle(B(42, 96, 270, 140), 8 * S, fill=255)
    body = Image.new('L', (W, W), 0)
    ImageDraw.Draw(body).rounded_rectangle(B(56, 132, 256, 270), 6 * S, fill=255)
    return lid, body
def draw_box(ribbon, parts=('lid', 'body'), half=None):
    im = Image.new('RGBA', (W, W), (0, 0, 0, 0))
    lid, body = box_masks()
    m = Image.new('L', (W, W), 0)
    if 'body' in parts: m.paste(255, (0, 0), body)
    if 'lid' in parts: m.paste(255, (0, 0), lid)
    if half:
        cut = Image.new('L', (W, W), 0)
        ImageDraw.Draw(cut).rectangle(B(0, 0, 156, 312) if half == 'l' else B(156, 0, 312, 312), fill=255)
        m = Image.composite(m, Image.new('L', (W, W), 0), cut)
    bow = Image.new('L', (W, W), 0)
    if ribbon:
        bd = ImageDraw.Draw(bow)
        bd.ellipse(B(104, 52, 158, 100), fill=255)
        bd.ellipse(B(154, 52, 208, 100), fill=255)
        bd.ellipse(B(140, 78, 172, 104), fill=255)
    allm = Image.composite(Image.new('L', (W, W), 255), m, bow)
    im.paste(OUT, (0, 0), outline_of(allm, 8 * S // 2))
    paint(im, m, grad(B(0, 96, 0, 270), TEAL_T, TEAL_B))
    d = ImageDraw.Draw(im)
    # gold dots on the paper, lid shadow line
    for yy in range(150, 262, 22):
        for xx in range(70, 250, 24):
            ox = 12 if (yy // 22) % 2 else 0
            px = xx + ox
            if m.getpixel((px * S, yy * S)) > 0:
                d.ellipse(B(px - 3, yy - 3, px + 3, yy + 3), fill=(255, 222, 120, 255))
    if 'lid' in parts and 'body' in parts:
        d.rectangle(B(56, 140, 256, 146), fill=(8, 90, 84, 255))
    if ribbon:
        rb = Image.new('L', (W, W), 0)
        rd = ImageDraw.Draw(rb)
        rd.rectangle(B(140, 96, 172, 270), fill=255)
        rd.rectangle(B(56, 186, 256, 212), fill=255)
        rb = Image.composite(rb, Image.new('L', (W, W), 0), m)
        im.paste(OUT, (0, 0), outline_of(rb, 2 * S))
        paint(im, rb, grad(B(0, 96, 0, 270), (255, 230, 120), (220, 150, 30)))
        # bow
        bw = Image.new('L', (W, W), 0)
        bd = ImageDraw.Draw(bw)
        bd.ellipse(B(108, 56, 154, 96), fill=255)
        bd.ellipse(B(158, 56, 204, 96), fill=255)
        im.paste(OUT, (0, 0), outline_of(bw, 3 * S))
        paint(im, bw, grad(B(0, 56, 0, 96), (255, 236, 140), (215, 145, 25)))
        d.ellipse(B(120, 66, 146, 88), fill=(150, 92, 10, 255))
        d.ellipse(B(166, 66, 192, 88), fill=(150, 92, 10, 255))
        d.ellipse(B(142, 76, 170, 102), fill=OUT)
        d.ellipse(B(145, 79, 167, 99), fill=GOLD)
    # shine on the lid
    hl = Image.new('L', (W, W), 0)
    ImageDraw.Draw(hl).rounded_rectangle(B(52, 100, 130, 112), 4 * S, fill=120)
    im.paste((255, 255, 255, 255), (0, 0), Image.composite(hl.filter(ImageFilter.GaussianBlur(2 * S)), Image.new('L', (W, W), 0), m))
    return im
fin(draw_box(True), 'giftr')
fin(draw_box(False), 'gifto')
fin(draw_box(False, ('lid',)), 'gift_lid')
fin(draw_box(False, ('body',), 'l'), 'gift_l')
fin(draw_box(False, ('body',), 'r'), 'gift_r')
print('ok')
