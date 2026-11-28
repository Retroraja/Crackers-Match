# Area 4 preview: temple delivery build, about 5 s.
# home -> zoom to order board, Temple card ticked -> pan to van, van slides off
# -> temple street, van rolls in, parcels unloaded -> back to the home view.
# Renders come from a4_mock.gd (see /tmp/claude-0/s/rend.sh); this only composes them.
import os, subprocess, sys
import numpy as np
from PIL import Image, ImageDraw, ImageFont, ImageFilter

D = sys.argv[1] if len(sys.argv) > 1 else '/tmp/claude-0/s/d/'
OUT = sys.argv[2] if len(sys.argv) > 2 else '/tmp/claude-0/s/a4_temple.mp4'
FONT = os.path.join(os.path.dirname(__file__), '../../art/LilitaOne.ttf')
W, H = 540, 1170
FW, FH = 1080, 2338
FPS = 30


def L(n):
    return Image.open(D + n + '.png').convert('RGB')


hubA, hubB, hubC = L('hubA'), L('hubB'), L('hubC')
tnv = L('tnv')
tb = [L('tb%d' % i) for i in range(6)]


def sticker(full, empty, box):
    a = np.asarray(full).astype(int)
    b = np.asarray(empty).astype(int)
    m = (np.abs(a - b).sum(2) > 36).astype(np.uint8) * 255
    k = np.zeros_like(m)
    x0, y0, x1, y1 = box
    k[y0:y1, x0:x1] = m[y0:y1, x0:x1]
    mask = Image.fromarray(k).filter(ImageFilter.MaxFilter(5)).filter(ImageFilter.MinFilter(3)).filter(ImageFilter.GaussianBlur(1.2))
    s = full.convert('RGBA')
    s.putalpha(mask)
    return s


VBOX = tuple(int(v) for v in os.environ.get('VBOX', '0,1150,560,1520').split(','))
TBOX = tuple(int(v) for v in os.environ.get('TBOX', '200,1050,1000,1500').split(','))
van_home = sticker(hubB, hubC, VBOX)
van_temple = sticker(tb[0], tnv, TBOX)

BOARD = (910, 1240)
VANC = ((VBOX[0] + VBOX[2]) / 2, (VBOX[1] + VBOX[3]) / 2)
TC = tuple(float(v) for v in os.environ.get('TC', '600,1300').split(','))


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


def F(n):
    return ImageFont.truetype(FONT, n)


CARDS = [('Temple', '#d8262e'), ('Wedding Hall', '#e08a1e'), ('School', '#2f6fd6'),
         ('Apartment', '#7a4fc9'), ('Marina Party', '#1f9e9a')]


def board(tick):
    """2D order board panel (540 wide canvas, transparent)."""
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
    pos = [(60, 380), (200, 380), (340, 380), (130, 590), (270, 590)]
    for i, ((name, col), (cx, cy)) in enumerate(zip(CARDS, pos)):
        d.rounded_rectangle((cx + 3, cy + 5, cx + 133, cy + 185), 10, fill=(0, 0, 0, 70))
        d.rounded_rectangle((cx, cy, cx + 130, cy + 180), 10, fill='#fffaf0', outline='#8a6a4a', width=2)
        d.rounded_rectangle((cx, cy, cx + 130, cy + 34), 10, fill=col)
        d.rectangle((cx, cy + 20, cx + 130, cy + 34), fill=col)
        d.ellipse((cx + 58, cy - 8, cx + 72, cy + 6), fill='#e23b3b', outline='#7a1010')  # pin
        f = F(24 if len(name) < 8 else 19)
        d.text((cx + 65, cy + 60), name, font=f, fill='#3a1a00', anchor='mm')
        for j in range(3):
            d.line((cx + 18, cy + 92 + j * 22, cx + 112 - j * 18, cy + 92 + j * 22), fill='#b9a68c', width=4)
    if tick > 0:
        cx, cy = pos[0]
        k = tick
        sc = 1 + 0.6 * (1 - k) if k < 1 else 1
        st = Image.new('RGBA', (220, 220), (0, 0, 0, 0))
        sd = ImageDraw.Draw(st)
        sd.ellipse((40, 40, 180, 180), fill='#2fb34a', outline='white', width=8)
        sd.line([(72, 112), (100, 140), (150, 84)], fill='white', width=16, joint='curve')
        st = st.rotate(-12, resample=Image.BICUBIC)
        sz = int(150 * sc)
        st = st.resize((sz, sz), Image.LANCZOS)
        a = st.getchannel('A').point(lambda v: int(v * min(1, k * 2)))
        st.putalpha(a)
        im.alpha_composite(st, (int(cx + 65 - sz / 2), int(cy + 120 - sz / 2)))
        dl = Image.new('RGBA', (200, 50), (0, 0, 0, 0))
        ImageDraw.Draw(dl).rounded_rectangle((2, 2, 198, 48), 8, outline='#2e9e44', width=5)
        ImageDraw.Draw(dl).text((100, 25), 'DELIVERED', font=F(28), fill='#2e9e44', anchor='mm')
        dl = dl.rotate(14, expand=True, resample=Image.BICUBIC).resize((150, 64), Image.LANCZOS)
        dl.putalpha(dl.getchannel('A').point(lambda v: int(v * min(1, k * 2))))
        im.alpha_composite(dl, (cx - 12, cy + 140))
    return im


def pop(layer, t):
    """scale-in + fade for the panel; t 0..1."""
    if t <= 0:
        return None
    s = 0.85 + 0.15 * t
    lw, lh = int(W * s), int(H * s)
    l = layer.resize((lw, lh), Image.LANCZOS)
    c = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    c.alpha_composite(l, ((W - lw) // 2, (H - lh) // 2))
    c.putalpha(c.getchannel('A').point(lambda v: int(v * t)))
    return c


def dim(img, k):
    return Image.blend(img, Image.new('RGB', img.size, (20, 12, 30)), k)


def with_van(bg, van, dx, dy=0):
    f = bg.convert('RGBA')
    f.alpha_composite(van, (int(dx), int(dy)))
    return f.convert('RGB')


T_END = 5.4
frames = int(T_END * FPS)
os.makedirs('/tmp/claude-0/s/tdf', exist_ok=True)
plain, ticked = board(0), board(1)
for i in range(frames):
    t = i / FPS
    if t < 2.0:
        # 1 zoom into the order board, Temple card ticked
        z = ph(t, 0.3, 1.1)
        s = 1 + 1.6 * z
        cx = FW / 2 + (BOARD[0] - FW / 2) * z
        cy = FH / 2 + (BOARD[1] - FH / 2) * z
        src = hubA if t < 1.5 else hubB
        fr = dim(view(src, cx, cy, s), 0.45 * ph(t, 0.8, 1.15))
        tk = ph(t, 1.3, 1.55) if t >= 1.3 else 0
        lay = board(tk) if 1.3 <= t < 1.6 else (ticked if t >= 1.6 else plain)
        p = pop(lay, ph(t, 0.85, 1.2))
        if p:
            fr = fr.convert('RGBA'); fr.alpha_composite(p); fr = fr.convert('RGB')
    elif t < 3.25:
        # 2 panel closes, pan to the grey van, van slides off screen
        z = ph(t, 2.0, 2.65)
        s = 2.6 - 1.2 * z
        cx = BOARD[0] + (VANC[0] + 120 - BOARD[0]) * z
        cy = BOARD[1] + (VANC[1] - BOARD[1]) * z
        go = ph(t, 2.7, 3.2)
        dx = -1300 * go * go
        bg = hubC if t >= 2.7 else hubB
        full = with_van(hubC, van_home, dx) if t >= 2.7 else hubB
        fr = dim(view(full, cx, cy, s), 0.45 * (1 - ph(t, 2.0, 2.3)))
        p = pop(ticked, 1 - ph(t, 2.0, 2.25))
        if p:
            fr = fr.convert('RGBA'); fr.alpha_composite(p); fr = fr.convert('RGB')
    elif t < 4.85:
        # 3 temple street: van rolls in, parcels unloaded one by one
        roll = ph(t, 3.35, 4.0)
        dx = -1100 * (1 - roll) ** 1.6
        if t < 4.05:
            full = with_van(tnv, van_temple, dx, -6 * abs(np.sin(t * 22)) * (1 - roll))
        else:
            k = (t - 4.05) / 0.14
            n = int(min(5, k))
            fpart = min(1, k - n) if n < 5 else 1
            full = Image.blend(tb[n], tb[min(5, n + 1)], ease(fpart)) if n < 5 else tb[5]
        zz = 1.25 + 0.08 * ph(t, 3.25, 4.85)
        fr = view(full, TC[0], TC[1], zz)
        if t < 3.55:
            prev = view(hubC, VANC[0] + 120, VANC[1], 1.4)
            fr = Image.blend(prev, fr, ph(t, 3.25, 3.55))
    else:
        # 4 fade back to the shop home view (order done)
        a = view(tb[5], TC[0], TC[1], 1.33)
        fr = Image.blend(a, view(hubB, FW / 2, FH / 2, 1.0), ph(t, 4.85, 5.2))
    fr.save('/tmp/claude-0/s/tdf/f%04d.png' % i)
subprocess.run(['ffmpeg', '-y', '-loglevel', 'error', '-framerate', str(FPS), '-i', '/tmp/claude-0/s/tdf/f%04d.png',
                '-c:v', 'libx264', '-pix_fmt', 'yuv420p', '-crf', '18', OUT], check=True)
print('done', OUT, frames)
