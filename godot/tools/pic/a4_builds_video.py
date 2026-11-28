# Area 4 preview (24 Nov): all 9 builds back to back, same style as the approved temple delivery video.
# Builds 1-4 at the shop: zoom to the spot, the new piece pops in with a sparkle, back to the home view.
# Builds 5-9 deliveries: order board tick + DELIVERED -> van slides off -> the place, van rolls in,
# parcels unloaded -> back home, the queue grows.
# Renders from a4_mock.gd (see the render list at the bottom of docs/area4.md); this only composes them.
# usage: python3 a4_builds_video.py <render dir> <out.mp4>
import math, os, subprocess, sys
import numpy as np
from PIL import Image, ImageDraw, ImageFont, ImageFilter

D = sys.argv[1].rstrip('/') + '/'
OUT = sys.argv[2]
FR = '/tmp/a4_frames/'
FONT = os.path.join(os.path.dirname(__file__), '../../art/LilitaOne.ttf')
W, H = 540, 1170
FW, FH = 1080, 2338
FPS = 30
os.makedirs(FR, exist_ok=True)
for f in os.listdir(FR):
    os.remove(FR + f)


def L(n):
    return Image.open(D + n + '.png').convert('RGB')


def F(n):
    return ImageFont.truetype(FONT, n)


def ease(t):
    t = max(0.0, min(1.0, t))
    return t * t * (3 - 2 * t)


def ph(t, a, b):
    return ease((t - a) / (b - a))


def view(img, cx, cy, s):
    w, h = FW / s, FH / s
    x0 = min(max(cx - w / 2, 0), FW - w)
    y0 = min(max(cy - h / 2, 0), FH - h)
    return img.resize((W, H), Image.LANCZOS, box=(x0, y0, x0 + w, y0 + h))


def diff_mask(full, empty, thr=36):
    a = np.asarray(full).astype(int)
    b = np.asarray(empty).astype(int)
    return (np.abs(a - b).sum(2) > thr)


def bbox(m, pad=20, minpix=40):
    # largest blob-ish box: rows/cols with enough changed pixels
    ys = np.where(m.sum(1) > minpix // 8)[0]
    xs = np.where(m.sum(0) > minpix // 8)[0]
    if len(xs) == 0:
        return (0, 0, FW, FH)
    return (max(0, xs[0] - pad), max(0, ys[0] - pad), min(FW, xs[-1] + pad), min(FH, ys[-1] + pad))


def main_blob(m):
    """keep only the big changed pieces (drops tiny flickers like a person's idle pose)."""
    import scipy.ndimage as nd
    lab, n = nd.label(nd.binary_dilation(m, iterations=4))
    if n == 0:
        return m
    sz = nd.sum(m, lab, range(1, n + 1))
    keep = [i + 1 for i, v in enumerate(sz) if v >= 0.2 * sz.max()]
    return m & np.isin(lab, keep)


def sticker(full, empty, box):
    m = main_blob(diff_mask(full, empty)).astype(np.uint8) * 255
    k = np.zeros_like(m)
    x0, y0, x1, y1 = box
    k[y0:y1, x0:x1] = m[y0:y1, x0:x1]
    mask = Image.fromarray(k).filter(ImageFilter.MaxFilter(5)).filter(ImageFilter.MinFilter(3)).filter(ImageFilter.GaussianBlur(1.2))
    s = full.convert('RGBA')
    s.putalpha(mask)
    return s


def dim(img, k):
    return Image.blend(img, Image.new('RGB', img.size, (20, 12, 30)), k)


def over(fr, lay):
    if lay is None:
        return fr
    fr = fr.convert('RGBA')
    fr.alpha_composite(lay)
    return fr.convert('RGB')


def with_van(bg, van, dx, dy=0):
    f = bg.convert('RGBA')
    f.alpha_composite(van, (int(dx), int(dy)))
    return f.convert('RGB')


def caption(n, name):
    """small build label at the top (preview only)."""
    im = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    txt = 'Build %d  ·  %s' % (n, name)
    f = F(30)
    tw = d.textlength(txt, font=f)
    d.rounded_rectangle((W / 2 - tw / 2 - 22, 70, W / 2 + tw / 2 + 22, 122), 26, fill=(40, 20, 10, 200), outline='#ffd86a', width=3)
    d.text((W / 2, 96), txt, font=f, fill='white', anchor='mm')
    return im


# ---------------------------------------------------------------- sparkle (pop-in)
def sparkle(cx, cy, k, r0=60):
    """ring of 8 gold stars flying out + soft glow; k 0..1."""
    im = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    if k <= 0 or k >= 1:
        return im
    d = ImageDraw.Draw(im)
    a = int(255 * (1 - k))
    g = int(r0 * (0.6 + 1.6 * k))
    d.ellipse((cx - g, cy - g, cx + g, cy + g), outline=(255, 230, 140, a // 2), width=6)
    for i in range(8):
        ang = i * math.pi / 4 + 0.3
        rr = r0 * (0.4 + 1.8 * ease(k))
        x, y = cx + math.cos(ang) * rr, cy + math.sin(ang) * rr
        s = 14 * (1 - k * 0.6)
        pts = []
        for j in range(8):
            q = j * math.pi / 4
            rad = s if j % 2 == 0 else s * 0.38
            pts.append((x + math.cos(q) * rad, y + math.sin(q) * rad))
        d.polygon(pts, fill=(255, 220, 90, a))
    return im.filter(ImageFilter.GaussianBlur(0.6))


def pop_build(n, name, before, after, t_len=2.4):
    """builds 1-4: zoom in on the new piece, it pops in, sparkle, zoom back out."""
    m = main_blob(diff_mask(after, before))
    bx = bbox(m)
    cx, cy = (bx[0] + bx[2]) / 2, (bx[1] + bx[3]) / 2
    zs = min(2.2, max(1.3, 0.55 * FW / max(80, bx[2] - bx[0])))
    st = sticker(after, before, bx)
    cap = caption(n, name)
    out = []
    for i in range(int(t_len * FPS)):
        t = i / FPS
        z = 0.0  # no zoom (he found the zoom on every build funny)
        s = 1 + (zs - 1) * z
        vx = FW / 2 + (cx - FW / 2) * z
        vy = FH / 2 + (cy - FH / 2) * z
        k = ph(t, 0.9, 1.25)  # pop scale-in
        if t < 0.9:
            full = before
        elif t < 1.45:
            sc = 0.55 + 0.45 * k + 0.12 * math.sin(min(1, (t - 0.9) / 0.55) * math.pi)  # little overshoot
            b = before.convert('RGBA')
            w2, h2 = int(FW * sc), int(FH * sc)
            sm = st.resize((w2, h2), Image.LANCZOS)
            gl = Image.new('RGBA', sm.size, (255, 214, 90, 0))
            gl.putalpha(sm.getchannel('A').filter(ImageFilter.MaxFilter(15)).filter(ImageFilter.GaussianBlur(14)).point(lambda v: int(v * 0.9 * (1 - ph(t, 1.2, 1.45)))))
            b.alpha_composite(gl, (int(cx - cx * sc), int(cy - cy * sc)))
            sm.putalpha(sm.getchannel('A').point(lambda v: int(v * min(1, k * 1.6))))
            ox, oy = int(cx - cx * sc), int(cy - cy * sc)
            b.alpha_composite(sm, (ox, oy))
            full = b.convert('RGB')
        else:
            full = after
        fr = view(full, vx, vy, s)
        # sparkle in screen space
        w, h = FW / s, FH / s
        x0 = min(max(vx - w / 2, 0), FW - w)
        y0 = min(max(vy - h / 2, 0), FH - h)
        sx, sy = (cx - x0) * W / w, (cy - y0) * H / h
        fr = over(fr, sparkle(sx, sy, (t - 1.05) / 0.8, 45))
        fr = over(fr, cap)
        out.append(fr)
    return out


# ---------------------------------------------------------------- order board panel (same as the temple video)
CARDS = [('Temple', '#d8262e'), ('Wedding Hall', '#e08a1e'), ('School', '#2f6fd6'),
         ('Apartment', '#7a4fc9'), ('Marina Party', '#1f9e9a')]
POS = [(60, 380), (200, 380), (340, 380), (130, 590), (270, 590)]


def tick_stamp(im, i, k):
    cx, cy = POS[i]
    sc = 1 + 0.6 * (1 - k) if k < 1 else 1
    st = Image.new('RGBA', (220, 220), (0, 0, 0, 0))
    sd = ImageDraw.Draw(st)
    sd.ellipse((40, 40, 180, 180), fill='#2fb34a', outline='white', width=8)
    sd.line([(72, 112), (100, 140), (150, 84)], fill='white', width=16, joint='curve')
    st = st.rotate(-12, resample=Image.BICUBIC)
    sz = int(150 * sc)
    st = st.resize((sz, sz), Image.LANCZOS)
    st.putalpha(st.getchannel('A').point(lambda v: int(v * min(1, k * 2))))
    im.alpha_composite(st, (int(cx + 65 - sz / 2), int(cy + 120 - sz / 2)))
    dl = Image.new('RGBA', (200, 50), (0, 0, 0, 0))
    ImageDraw.Draw(dl).rounded_rectangle((2, 2, 198, 48), 8, outline='#2e9e44', width=5)
    ImageDraw.Draw(dl).text((100, 25), 'DELIVERED', font=F(28), fill='#2e9e44', anchor='mm')
    dl = dl.rotate(14, expand=True, resample=Image.BICUBIC).resize((150, 64), Image.LANCZOS)
    dl.putalpha(dl.getchannel('A').point(lambda v: int(v * min(1, k * 2))))
    im.alpha_composite(dl, (cx - 12, cy + 140))


def board(done, cur, tick):
    """done = cards already delivered (ticked), cur = this delivery's card, tick 0..1."""
    im = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    x0, y0, x1, y1 = 40, 330, 500, 800
    d.rounded_rectangle((x0 - 10, y0 - 10, x1 + 10, y1 + 10), 26, fill='#5a3119')
    d.rounded_rectangle((x0, y0, x1, y1), 20, fill='#c9955c', outline='#3a1d0c', width=3)
    for i in range(160):  # cork speckle
        rx = x0 + 12 + (i * 97) % (x1 - x0 - 24)
        ry = y0 + 12 + (i * 53) % (y1 - y0 - 24)
        d.ellipse((rx, ry, rx + 3, ry + 3), fill='#a87642')
    d.rounded_rectangle((170, y0 - 34, 370, y0 + 22), 18, fill='#d8262e', outline='#7a1010', width=3)
    d.text((270, y0 - 6), 'ORDERS', font=F(34), fill='white', anchor='mm', stroke_width=3, stroke_fill='#3a1a00')
    for i, ((name, col), (cx, cy)) in enumerate(zip(CARDS, POS)):
        d.rounded_rectangle((cx + 3, cy + 5, cx + 133, cy + 185), 10, fill=(0, 0, 0, 70))
        d.rounded_rectangle((cx, cy, cx + 130, cy + 180), 10, fill='#fffaf0', outline='#8a6a4a', width=2)
        d.rounded_rectangle((cx, cy, cx + 130, cy + 34), 10, fill=col)
        d.rectangle((cx, cy + 20, cx + 130, cy + 34), fill=col)
        d.ellipse((cx + 58, cy - 8, cx + 72, cy + 6), fill='#e23b3b', outline='#7a1010')  # pin
        f = F(24 if len(name) < 8 else 19)
        d.text((cx + 65, cy + 60), name, font=f, fill='#3a1a00', anchor='mm')
        for j in range(3):
            d.line((cx + 18, cy + 92 + j * 22, cx + 112 - j * 18, cy + 92 + j * 22), fill='#b9a68c', width=4)
    for i in range(done):
        tick_stamp(im, i, 1)
    if tick > 0:
        tick_stamp(im, cur, tick)
    return im


def pop(layer, t):
    if t <= 0:
        return None
    s = 0.85 + 0.15 * t
    lw, lh = int(W * s), int(H * s)
    l = layer.resize((lw, lh), Image.LANCZOS)
    c = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    c.alpha_composite(l, ((W - lw) // 2, (H - lh) // 2))
    c.putalpha(c.getchannel('A').point(lambda v: int(v * t)))
    return c


def delivery(n, idx, name, place, hubA, hubB, hubC, TC, TZ, board_c):
    """the temple video's timing, for any place. idx = card index 0..4."""
    nv = L(place + '_nv')
    tb = [L('%s_b%d' % (place, i)) for i in range(6)]
    vbx = bbox(main_blob(diff_mask(hubA, hubC)))
    van_home = sticker(hubA, hubC, vbx)
    tbx = bbox(main_blob(diff_mask(tb[0], nv)))
    van_place = sticker(tb[0], nv, tbx)
    VANC = ((vbx[0] + vbx[2]) / 2, (vbx[1] + vbx[3]) / 2)
    BOARD = board_c
    plain, ticked = board(idx, idx, 0), board(idx, idx, 1)
    cap = caption(n, name)
    out = []
    T_END = 5.4
    for i in range(int(T_END * FPS)):
        t = i / FPS
        if t < 2.0:
            z = ph(t, 0.3, 1.1)
            s = 1 + 1.6 * z
            cx = FW / 2 + (BOARD[0] - FW / 2) * z
            cy = FH / 2 + (BOARD[1] - FH / 2) * z
            fr = dim(view(hubA, cx, cy, s), 0.45 * ph(t, 0.8, 1.15))
            tk = ph(t, 1.3, 1.55) if t >= 1.3 else 0
            lay = board(idx, idx, tk) if 1.3 <= t < 1.6 else (ticked if t >= 1.6 else plain)
            fr = over(fr, pop(lay, ph(t, 0.85, 1.2)))
        elif t < 3.25:
            z = ph(t, 2.0, 2.65)
            s = 2.6 - 1.2 * z
            cx = BOARD[0] + (VANC[0] + 120 - BOARD[0]) * z
            cy = BOARD[1] + (VANC[1] - BOARD[1]) * z
            go = ph(t, 2.7, 3.2)
            full = with_van(hubC, van_home, -1300 * go * go) if t >= 2.7 else hubA
            fr = dim(view(full, cx, cy, s), 0.45 * (1 - ph(t, 2.0, 2.3)))
            fr = over(fr, pop(ticked, 1 - ph(t, 2.0, 2.25)))
        elif t < 4.85:
            roll = ph(t, 3.35, 4.0)
            dx = -1100 * (1 - roll) ** 1.6
            if t < 4.05:
                full = with_van(nv, van_place, dx, -6 * abs(np.sin(t * 22)) * (1 - roll))
            else:
                k = (t - 4.05) / 0.14
                m = int(min(5, k))
                fpart = min(1, k - m) if m < 5 else 1
                full = Image.blend(tb[m], tb[min(5, m + 1)], ease(fpart)) if m < 5 else tb[5]
            zz = TZ + 0.08 * ph(t, 3.25, 4.85)
            fr = view(full, TC[0], TC[1], zz)
            if t < 3.55:
                prev = view(hubC, VANC[0] + 120, VANC[1], 1.4)
                fr = Image.blend(prev, fr, ph(t, 3.25, 3.55))
        else:
            a = view(tb[5], TC[0], TC[1], TZ + 0.08)
            fr = Image.blend(a, view(hubB, FW / 2, FH / 2, 1.0), ph(t, 4.85, 5.2))
        out.append(over(fr, cap))
    return out


def hold(img, sec, cap=None):
    fr = view(img, FW / 2, FH / 2, 1.0)
    if cap is not None:
        fr = over(fr, cap)
    return [fr] * int(sec * FPS)


hub = [L('hub%d' % i) for i in range(10)]
hubnv = {i: L('hubnv%d' % i) for i in range(4, 9)}
# order board position in the home picture = where build 2 appeared
bb = bbox(main_blob(diff_mask(hub[2], hub[1])))
BOARD_C = ((bb[0] + bb[2]) / 2, (bb[1] + bb[3]) / 2)

frames = []
frames += hold(hub[0], 0.8)
frames += pop_build(1, 'Fix the Van', hub[0], hub[1])
frames += hold(hub[1], 0.4)
frames += pop_build(2, 'Order Board', hub[1], hub[2])
frames += hold(hub[2], 0.4)
frames += pop_build(3, 'Packing Table', hub[2], hub[3])
frames += hold(hub[3], 0.4)
frames += pop_build(4, 'Delivery Bikes', hub[3], hub[4])
frames += hold(hub[4], 0.4)
places = [('temple', 'Temple Delivery', (600, 1300), 1.25),
          ('wedding', 'Wedding Hall Delivery', (430, 1150), 1.45),
          ('school', 'School Delivery', (430, 1150), 1.45),
          ('apts', 'Apartment Delivery', (430, 1150), 1.45),
          ('marina', 'Marina Party Delivery', (430, 1150), 1.45)]
for j, (pl, name, tc, tz) in enumerate(places):
    k = 5 + j
    frames += delivery(k, j, name, pl, hub[k - 1], hub[k], hubnv[k - 1], tc, tz, BOARD_C)
    frames += hold(hub[k], 0.4)
frames += hold(hub[9], 1.2)

for i, fr in enumerate(frames):
    fr.save(FR + 'f%05d.png' % i)
subprocess.run(['ffmpeg', '-y', '-loglevel', 'error', '-framerate', str(FPS), '-i', FR + 'f%05d.png',
                '-c:v', 'libx264', '-pix_fmt', 'yuv420p', '-crf', '20', '-movflags', '+faststart', OUT], check=True)
print('done', OUT, len(frames), 'frames', len(frames) / FPS, 's')
