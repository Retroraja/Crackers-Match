# Area 2 street (option A): makes the textured .glb pieces for the GHILLI CRACKERS street view.
# Textures: Poly Haven (CC0) in /home/claude/dl/ph. Text and goods pictures painted with PIL (LilitaOne font).
# Units: meters. x along the street, y up, z towards the camera. Shop fronts at z=0, road z 3.4..16.
import math, os, sys, random
import numpy as np, trimesh
from PIL import Image, ImageDraw, ImageFont, ImageFilter, ImageEnhance

PH = "/home/claude/dl/ph"
OUT = sys.argv[1] if len(sys.argv) > 1 else "/home/claude/repo/godot/art/a2/gen"
FONT = "/home/claude/repo/godot/art/LilitaOne.ttf"
os.makedirs(OUT, exist_ok=True)
random.seed(4)
TEXCACHE = {}

def ph(name, kind="diff", size=512):
    k = (name, kind, size)
    if k not in TEXCACHE:
        TEXCACHE[k] = Image.open(f"{PH}/{name}_{kind}_1k.jpg").convert("RGB").resize((size // 2 if kind != "diff" else size,) * 2, Image.LANCZOS)
    return TEXCACHE[k]

def flat(c):
    return Image.new("RGB", (8, 8), c)

class Mat:
    def __init__(self, img, nor=None, tint=(1, 1, 1), tile=2.0, rough=0.9, metal=0.0, emit=None, rot=False, alpha=False):
        self.img, self.nor, self.tint, self.tile, self.rough, self.metal, self.emit, self.rot, self.alpha = img, nor, tint, tile, rough, metal, emit, rot, alpha

class Builder:
    def __init__(self):
        self.parts = {}   # Mat -> [verts, faces, uvs, normals]

    def quad(self, m, p0, u, v, uv0=None, uv1=None):
        p0, u, v = np.array(p0, float), np.array(u, float), np.array(v, float)
        P = [p0, p0 + u, p0 + u + v, p0 + v]
        if uv0 is None:
            lu, lv = np.linalg.norm(u) / m.tile, np.linalg.norm(v) / m.tile
            uvs = [(0, 0), (lu, 0), (lu, lv), (0, lv)]
        else:
            (a, b), (c, d) = uv0, uv1
            uvs = [(a, b), (c, b), (c, d), (a, d)]
        if m.rot:
            uvs = [(t, s) for s, t in uvs]
        n = np.cross(u, v); n = n / (np.linalg.norm(n) + 1e-9)
        L = self.parts.setdefault(m, [[], [], [], []])
        i = len(L[0])
        L[0] += P; L[2] += uvs; L[3] += [n] * 4
        L[1] += [(i, i + 1, i + 2), (i, i + 2, i + 3)]

    def tri(self, m, a, b, c, ua, ub, uc):
        a, b, c = np.array(a, float), np.array(b, float), np.array(c, float)
        n = np.cross(b - a, c - a); n = n / (np.linalg.norm(n) + 1e-9)
        L = self.parts.setdefault(m, [[], [], [], []])
        i = len(L[0])
        L[0] += [a, b, c]; L[2] += [ua, ub, uc]; L[3] += [n] * 3
        L[1] += [(i, i + 1, i + 2)]

    def box(self, m, c, s, faces="nsewtb"):
        cx, cy, cz = c; sx, sy, sz = s
        x0, x1, y0, y1, z0, z1 = cx - sx / 2, cx + sx / 2, cy - sy / 2, cy + sy / 2, cz - sz / 2, cz + sz / 2
        if "s" in faces: self.quad(m, (x0, y0, z1), (sx, 0, 0), (0, sy, 0))       # front (+z)
        if "n" in faces: self.quad(m, (x1, y0, z0), (-sx, 0, 0), (0, sy, 0))      # back
        if "e" in faces: self.quad(m, (x1, y0, z1), (0, 0, -sz), (0, sy, 0))      # +x
        if "w" in faces: self.quad(m, (x0, y0, z0), (0, 0, sz), (0, sy, 0))       # -x
        if "t" in faces: self.quad(m, (x0, y1, z1), (sx, 0, 0), (0, 0, -sz))      # top
        if "b" in faces: self.quad(m, (x0, y0, z0), (sx, 0, 0), (0, 0, sz))       # bottom

    def cyl(self, m, a, b, r, seg=10):
        a, b = np.array(a, float), np.array(b, float)
        d = b - a; L = np.linalg.norm(d); d /= L
        t = np.cross(d, [0, 1, 0] if abs(d[1]) < 0.9 else [1, 0, 0]); t /= np.linalg.norm(t)
        w = np.cross(d, t)
        for i in range(seg):
            a0, a1 = 2 * math.pi * i / seg, 2 * math.pi * (i + 1) / seg
            o0 = (math.cos(a0) * t + math.sin(a0) * w) * r
            o1 = (math.cos(a1) * t + math.sin(a1) * w) * r
            self.quad(m, a + o0, o1 - o0, b - a, (i / seg, 0), ((i + 1) / seg, L / m.tile))

    def save(self, name):
        sc = trimesh.Scene()
        for k, (m, (V, F, UV, N)) in enumerate(self.parts.items()):
            img = m.img
            for im in (m.img, m.nor):
                if im is not None and im.size[0] > 8:
                    im.format = "JPEG"   # embed as JPEG: a tenth of the PNG size
            tint = list(m.tint) + [1.0]
            kw = dict(baseColorTexture=img, baseColorFactor=tint, roughnessFactor=m.rough, metallicFactor=m.metal, doubleSided=m.img.size[0] <= 8)
            if m.nor is not None: kw["normalTexture"] = m.nor
            if m.emit is not None:
                kw["emissiveTexture"] = img; kw["emissiveFactor"] = m.emit
            if m.alpha: kw["alphaMode"] = "BLEND"
            mat = trimesh.visual.material.PBRMaterial(**kw)
            vis = trimesh.visual.TextureVisuals(uv=np.array(UV, float), material=mat)
            mesh = trimesh.Trimesh(vertices=np.array(V), faces=np.array(F), vertex_normals=np.array(N), visual=vis, process=False)
            sc.add_geometry(mesh, node_name=f"{name}_{k}", geom_name=f"{name}_{k}")
        sc.export(f"{OUT}/{name}.glb")
        print("wrote", name, sum(len(p[1]) for p in self.parts.values()), "tris")

# ---------------------------------------------------------------- painted pictures
def font(sz):
    return ImageFont.truetype(FONT, sz)

def sign_img(text, bg, fg, sub="", w=1024, h=160, border=(245, 197, 66), old=0.0):
    im = Image.new("RGB", (w, h), bg)
    d = ImageDraw.Draw(im)
    d.rectangle([0, 0, w - 1, h - 1], outline=border, width=10)
    if text:
        fs = int(h * (0.52 if sub else 0.66))
        f = font(fs)
        while d.textlength(text, font=f) > w * 0.9:
            fs -= 4; f = font(fs)
        ty = h * (0.42 if sub else 0.5)
        d.text((w / 2 + 4, ty + 4), text, font=f, fill=(0, 0, 0), anchor="mm")
        d.text((w / 2, ty), text, font=f, fill=fg, anchor="mm")
        if sub:
            d.text((w / 2, h * 0.82), sub, font=font(int(h * 0.2)), fill=fg, anchor="mm")
    # weathering: plaster grain on top
    g = ph("painted_plaster_wall", size=w).crop((0, 0, w, h)).convert("L")
    im = Image.blend(im, Image.merge("RGB", [g] * 3), 0.10 + old)
    if old:
        im = ImageEnhance.Color(im).enhance(0.5)
    return im

def goods_img(kind, w=512, h=256):
    """the back of an open shop: shelves full of things, warm light"""
    im = Image.new("RGB", (w, h), (70, 52, 40))
    d = ImageDraw.Draw(im)
    pal = {
        "sarees": [(214, 40, 70), (250, 196, 60), (46, 134, 222), (123, 63, 191), (46, 173, 91), (255, 122, 26), (232, 74, 95)],
        "vessels": [(205, 210, 216), (176, 182, 190), (222, 170, 90), (190, 140, 70), (230, 232, 236)],
        "kaapi": [(120, 70, 40), (230, 220, 200), (200, 60, 50), (60, 120, 70), (240, 200, 90)],
        "sweets": [(250, 196, 60), (255, 140, 40), (240, 230, 200), (220, 80, 110), (140, 80, 40)],
    }[kind]
    rows = 4
    for r in range(rows):
        y0 = 12 + r * (h - 20) // rows
        y1 = y0 + (h - 20) // rows - 14
        d.rectangle([0, y1, w, y1 + 8], fill=(150, 105, 60))
        x = 8
        while x < w - 10:
            bw = random.randint(16, 34) if kind != "vessels" else random.randint(26, 40)
            c = random.choice(pal)
            if kind == "vessels":
                d.ellipse([x, y0 + 10, x + bw, y1], fill=c, outline=(120, 120, 130))
                d.ellipse([x + 4, y0 + 12, x + bw - 10, y0 + 22], fill=(255, 255, 255))
            elif kind == "sarees":
                d.rectangle([x, y0 + 6, x + bw, y1], fill=c)
                d.rectangle([x, y0 + 6 + (y1 - y0) // 2, x + bw, y0 + 10 + (y1 - y0) // 2], fill=(245, 200, 80))
            else:
                hh = random.randint(14, y1 - y0 - 6)
                d.rectangle([x, y1 - hh, x + bw, y1], fill=c)
                d.rectangle([x + 3, y1 - hh + 4, x + bw - 3, y1 - hh + 9], fill=(255, 240, 200))
            x += bw + 3
    d.rectangle([0, 0, w, 8], fill=(255, 250, 230))   # tube light glow
    return im.filter(ImageFilter.GaussianBlur(0.8))

def stripes(c1, c2, n=8, w=256, h=64):
    im = Image.new("RGB", (w, h), c1)
    d = ImageDraw.Draw(im)
    for i in range(n):
        if i % 2:
            d.rectangle([i * w // n, 0, (i + 1) * w // n, h], fill=c2)
    g = ph("painted_plaster_wall", size=w).crop((0, 0, w, h)).convert("L")
    return Image.blend(im, Image.merge("RGB", [g] * 3), 0.12)

def dark_glass():
    im = Image.new("RGB", (64, 64), (40, 52, 62))
    d = ImageDraw.Draw(im)
    for i in range(64):
        d.line([(i, 0), (0, i)], fill=(48 + i // 4, 62 + i // 4, 76 + i // 4))
    return im

# ---------------------------------------------------------------- shared materials
M = {}
def mat(key, *a, **k):
    if key not in M: M[key] = Mat(*a, **k)
    return M[key]

def plaster(name, tint):
    return mat(("pl", name, tint), ph(name), ph(name, "nor_gl"), tint=tint, tile=3.0)

CONC = lambda: mat("conc", ph("concrete_wall_006"), ph("concrete_wall_006", "nor_gl"), tint=(1.05, 1.02, 0.98), tile=3.0)
SLAB = lambda: mat("slab", ph("concrete_pavement"), ph("concrete_pavement", "nor_gl"), tint=(1.1, 1.08, 1.04), tile=2.0)
FRAME = lambda: mat("frame", flat((235, 230, 220)), rough=0.6)
METAL = lambda: mat("metal", flat((40, 42, 46)), rough=0.5, metal=0.6)
GLASS = lambda: mat("glass", dark_glass(), rough=0.15, metal=0.3, tile=1.5)
DARK = lambda: mat("dark", flat((52, 42, 36)), rough=0.95)
WIRE = lambda: mat("wire", flat((25, 25, 28)), rough=0.6)

# ---------------------------------------------------------------- a shop building
def building(B, x0, x1, floors, wall, sign=None, shop=None, balcony=False, tank=False, shutter=False, awning=None, ac=0, pillar=None, room=None, step=True):
    w = x1 - x0; cx = (x0 + x1) / 2
    GF, FH, D = 4.3, 3.2, 10.0
    H = GF + FH * (floors - 1)
    ow = w - 1.2            # shop opening
    oh = 3.3
    # front wall pieces around the opening, then the upper floors
    B.box(wall, (x0 + 0.3, oh / 2, -D / 2), (0.6, oh, D), "sewt")
    B.box(wall, (x1 - 0.3, oh / 2, -D / 2), (0.6, oh, D), "sewt")
    B.box(wall, (cx, (oh + GF) / 2, -D / 2), (w, GF - oh, D), "sewb")
    # pillars: a little proud of the wall
    for px in (x0 + 0.3, x1 - 0.3):
        B.box(pillar or CONC(), (px, oh / 2, 0.08), (0.62, oh, 0.16), "sewt")
    # step in front
    if step:
        B.box(SLAB(), (cx, 0.28, 0.35), (w - 0.2, 0.2, 0.7))
    # interior
    if shop == "empty":   # our dusty empty room behind the shutter
        cw = mat("emptywall", ph("concrete_wall_006"), ph("concrete_wall_006", "nor_gl"), tint=(0.9, 0.82, 0.72), tile=2.5)
        bw, sw = (cw, cw) if room is None else room
        B.quad(bw, (x0 + 0.6, 0.18, -4.0), (ow, 0, 0), (0, oh - 0.18, 0))
        B.quad(sw, (x0 + 0.6, 0.18, 0), (0, 0, -4.0), (0, oh, 0))
        B.quad(sw, (x1 - 0.6, 0.18, -4.0), (0, 0, 4.0), (0, oh, 0))
        B.quad(mat("emptyfloor", ph("concrete_pavement"), ph("concrete_pavement", "nor_gl"), tint=(0.8, 0.74, 0.66), tile=2.0), (x0 + 0.6, 0.19, 0), (ow, 0, 0), (0, 0, -4.0))
        B.quad(mat("ceil", flat((230, 222, 205))), (x0 + 0.6, oh, -4.0), (ow, 0, 0), (0, 0, 4.0))
    elif shop:
        gi = mat(("goods", shop), goods_img(shop), emit=(0.55, 0.5, 0.42), tile=1.0)
        B.quad(gi, (x0 + 0.6, 0.18, -3.6), (ow, 0, 0), (0, oh - 0.2, 0), (0, 0), (1, 1))
        B.quad(DARK(), (x0 + 0.6, 0.18, 0), (0, 0, -3.6), (0, oh, 0))
        B.quad(DARK(), (x1 - 0.6, 0.18, -3.6), (0, 0, 3.6), (0, oh, 0))
        fl = mat("shopfloor", ph("checkered_pavement_tiles"), ph("checkered_pavement_tiles", "nor_gl"), tile=1.2, tint=(1.1, 1.05, 1.0))
        B.quad(fl, (x0 + 0.6, 0.19, 0), (ow, 0, 0), (0, 0, -3.6))
        B.quad(mat("ceil", flat((230, 222, 205))), (x0 + 0.6, oh, -3.6), (ow, 0, 0), (0, 0, 3.6))
        # counter at the front
        B.box(mat("counter", ph("concrete_wall_006"), tint=(0.8, 0.55, 0.38), tile=1.5), (cx, 0.65, -0.9), (ow * 0.7, 0.95, 0.7))
    if shutter == "box":
        B.box(METAL(), (cx, oh - 0.12, -0.05), (ow, 0.25, 0.25))   # the shutter box (the shutter itself is shutter.glb)
    elif shutter:
        sh = mat("shutter", ph("corrugated_iron_02"), ph("corrugated_iron_02", "nor_gl"), tint=(0.95, 0.75, 0.62), tile=1.6, rough=0.75, metal=0.3, rot=True)
        B.quad(sh, (x0 + 0.6, 0.18, -0.12), (ow, 0, 0), (0, oh - 0.18, 0))
        B.box(METAL(), (cx, oh - 0.12, -0.05), (ow, 0.25, 0.25))   # the shutter box
        B.box(METAL(), (cx, 0.3, -0.06), (ow, 0.08, 0.06))           # bottom bar + lock
        B.box(mat("lock", flat((200, 160, 60)), metal=0.8, rough=0.3), (cx, 0.32, 0.0), (0.16, 0.2, 0.08))
    # sign board under the chajja
    if sign:
        sm = mat(("sign", sign[0]), sign_img(*sign), rough=0.6, tile=1.0)
        B.quad(sm, (x0 + 0.5, oh + 0.12, 0.13), (w - 1.0, 0, 0), (0, GF - oh - 0.2, 0), (0, 0), (1, 1))
        B.box(METAL(), (cx, oh + 0.05, 0.08), (w - 0.9, 0.08, 0.12))
    # chajja (concrete sunshade) over the ground floor
    B.box(SLAB(), (cx, GF + 0.08, 0.45), (w + 0.1, 0.16, 0.9))
    if awning:
        am = mat(("awn", awning), stripes(*awning), rough=0.9, tile=1.0)
        ax0, ax1 = x0 + 0.5, x1 - 0.5
        B.quad(am, (ax0, oh + 0.0, 1.5), (ax1 - ax0, 0, 0), (0, 0.45 - 0.0, -1.4), (0, 0), (w / 1.4, 1))
        B.quad(am, (ax1, oh + 0.0, 1.5), (ax0 - ax1, 0, 0), (0, 0.45, -1.4), (0, 0), (w / 1.4, 1))
        B.quad(am, (ax0, oh - 0.3, 1.5), (ax1 - ax0, 0, 0), (0, 0.3, 0), (0, 0), (w / 1.4, 0.4))
    # upper floors: wall with windows
    for f in range(1, floors):
        y0 = GF + FH * (f - 1)
        nw = max(1, int(w // 2.6))
        ww, wh = 1.3, 1.5
        gaps = (w - nw * ww) / (nw + 1)
        xs = [x0 + gaps + i * (ww + gaps) for i in range(nw)]
        # wall around windows (front face only; sides/back as one box)
        B.box(wall, (cx, y0 + FH / 2, -D / 2 - 0.01), (w, FH, D - 0.02), "newt")
        wy = y0 + 0.95
        cur = x0
        for wx in xs:
            B.quad(wall, (cur, y0, 0), (wx - cur, 0, 0), (0, FH, 0))
            cur = wx + ww
        B.quad(wall, (cur, y0, 0), (x1 - cur, 0, 0), (0, FH, 0))
        for wx in xs:
            B.quad(wall, (wx, y0, 0), (ww, 0, 0), (0, wy - y0, 0))
            B.quad(wall, (wx, wy + wh, 0), (ww, 0, 0), (0, y0 + FH - wy - wh, 0))
            B.quad(GLASS(), (wx, wy, -0.15), (ww, 0, 0), (0, wh, 0), (0, 0), (1, 1))
            B.quad(DARK(), (wx, wy, 0), (0, 0, -0.15), (0, wh, 0))
            B.quad(DARK(), (wx + ww, wy, -0.15), (0, 0, 0.15), (0, wh, 0))
            B.quad(DARK(), (wx, wy, -0.15), (ww, 0, 0), (0, 0, 0.15))
            B.quad(DARK(), (wx, wy + wh, 0), (ww, 0, 0), (0, 0, -0.15))
            # frame + middle bar + grille + little sunshade
            for (a, b, s) in [((wx + ww / 2, wy - 0.04, 0.03), None, (ww + 0.16, 0.08, 0.1)), ((wx + ww / 2, wy + wh + 0.04, 0.03), None, (ww + 0.16, 0.08, 0.1)),
                              ((wx - 0.04, wy + wh / 2, 0.03), None, (0.08, wh, 0.1)), ((wx + ww + 0.04, wy + wh / 2, 0.03), None, (0.08, wh, 0.1)),
                              ((wx + ww / 2, wy + wh / 2, -0.08), None, (0.05, wh, 0.05))]:
                B.box(FRAME(), a, s)
            for gx in range(1, 5):
                B.box(METAL(), (wx + ww * gx / 5, wy + wh / 2, 0.0), (0.025, wh, 0.025), "sewt")
            B.box(SLAB(), (wx + ww / 2, wy + wh + 0.3, 0.25), (ww + 0.5, 0.08, 0.5))
        if balcony and f == 1:
            B.box(SLAB(), (cx, y0 + 0.08, 0.6), (w - 1.6, 0.16, 1.2))
            for i in range(int((w - 1.6) / 0.16)):
                bx = x0 + 0.8 + i * 0.16
                B.box(METAL(), (bx, y0 + 0.6, 1.17), (0.03, 0.9, 0.03), "sewt")
            B.box(METAL(), (cx, y0 + 1.05, 1.17), (w - 1.6, 0.06, 0.06))
            # a clothes line + clothes on the balcony
            B.cyl(WIRE(), (x0 + 1.0, y0 + 2.2, 0.9), (x1 - 1.0, y0 + 2.2, 0.9), 0.012, 4)
            for i, c in enumerate([(232, 74, 95), (46, 134, 222), (246, 196, 83), (240, 240, 240)]):
                B.box(mat(("cloth", c), flat(c), rough=1.0), (x0 + 1.6 + i * (w - 3.2) / 3, y0 + 1.75, 0.9), (0.6, 0.85, 0.02))
    # parapet + coping + roof
    B.box(wall, (cx, H + 0.45, -0.1), (w, 0.9, 0.2))
    B.box(SLAB(), (cx, H + 0.93, -0.1), (w + 0.08, 0.08, 0.3))
    B.box(SLAB(), (cx, H + 0.02, -D / 2), (w - 0.1, 0.06, D - 0.4), "t")
    if tank:
        B.cyl(mat("tank", flat((22, 22, 24)), rough=0.5), (cx + w * 0.2, H, -4), (cx + w * 0.2, H + 1.4, -4), 0.65, 12)
        B.box(mat("tank", flat((22, 22, 24)), rough=0.5), (cx + w * 0.2, H + 1.42, -4), (1.1, 0.06, 1.1), "t")
    for i in range(ac):
        ax = x0 + 1.0 + i * 3.1
        B.box(mat("ac", flat((228, 228, 222)), rough=0.5), (ax, GF + FH + 0.5, 0.25), (0.8, 0.55, 0.5))
        B.box(DARK(), (ax, GF + FH + 0.5, 0.505), (0.45, 0.42, 0.01), "s")

# ---------------------------------------------------------------- GHILLI build parts
BOXART = [("SPARKLERS", (214, 38, 61), (255, 214, 64)), ("FLOWER POTS", (46, 134, 222), (255, 240, 200)), ("CHAKKARS", (123, 63, 191), (255, 214, 64)),
          ("ROCKETS", (46, 173, 91), (255, 255, 255)), ("1000 WALA", (255, 122, 26), (120, 20, 20)), ("BIJILI", (240, 200, 40), (180, 20, 30)), ("SKY SHOTS", (20, 40, 110), (255, 200, 60))]
def box_img(i):
    name, bg, fg = BOXART[i % len(BOXART)]
    im = Image.new("RGB", (256, 128), bg)
    d = ImageDraw.Draw(im)
    for k in range(0, 256, 32):
        d.polygon([(k, 128), (k + 16, 100), (k + 32, 128)], fill=fg)
    d.ellipse([10, 14, 70, 74], fill=fg)
    d.text((40, 44), "★", font=font(40), fill=bg, anchor="mm") if False else d.regular_polygon((40, 44, 22), 5, fill=bg)
    f = font(30)
    while d.textlength(name, font=f) > 170: f = font(f.size - 2)
    d.text((166, 40), name, font=f, fill=fg, anchor="mm")
    d.text((166, 74), "GHILLI · SIVAKASI", font=font(14), fill=fg, anchor="mm")
    d.rectangle([0, 0, 255, 127], outline=(255, 255, 255), width=3)
    return im

def crackerbox(B, c, s, i):
    m = mat(("cbox", i % len(BOXART)), box_img(i), rough=0.6, tile=1.0)
    x, y, z = c; sx, sy, sz = s
    B.quad(m, (x - sx / 2, y - sy / 2, z + sz / 2), (sx, 0, 0), (0, sy, 0), (0, 0), (1, 1))
    side = mat(("cside", i % len(BOXART)), flat(BOXART[i % len(BOXART)][1]), rough=0.6)
    B.box(side, c, (sx, sy, sz * 0.999), "newtb")

WOOD = lambda: mat("wood2", ph("concrete_wall_006", size=256), tint=(0.78, 0.5, 0.3), tile=1.2, rough=0.7)

def shop_parts():
    B = Builder(); B.box(mat("oldstep", ph("concrete_pavement"), ph("concrete_pavement", "nor_gl"), tint=(0.78, 0.74, 0.68), tile=1.0), (0, 0.28, 0.35), (7.8, 0.2, 0.7)); B.save("oldstep")
    tl = mat("tilesN", ph("checkered_pavement_tiles"), ph("checkered_pavement_tiles", "nor_gl"), tint=(1.35, 1.0, 0.85), tile=1.2, rough=0.4)
    B = Builder(); B.box(tl, (0, 0.29, 0.35), (7.8, 0.22, 0.7)); B.box(mat("edge", flat((150, 40, 30)), rough=0.5), (0, 0.29, 0.71), (7.8, 0.22, 0.03), "s"); B.save("newstep")
    B = Builder(); B.box(tl, (0, 0.0, 0.0), (0.86, 0.04, 0.9), "st"); B.save("tile")
    # signboards (origin at the board centre)
    B = Builder(); B.quad(mat(("sign", "old"), sign_img("", (110, 84, 64), (0, 0, 0), "", 1024, 160, (150, 120, 80), 0.25), tile=1.0), (-3.5, -0.34, 0), (7.0, 0, 0), (0, 0.68, 0), (0, 0), (1, 1)); B.save("oldboard")
    B = Builder()
    B.quad(mat(("sign", "ghilli"), sign_img("GHILLI CRACKERS", (192, 22, 31), (255, 226, 122), "SIVAKASI CRACKERS · WHOLESALE & RETAIL"), rough=0.5, tile=1.0), (-3.6, -0.38, 0.06), (7.2, 0, 0), (0, 0.76, 0), (0, 0), (1, 1))
    B.box(mat("gold", flat((245, 197, 66)), rough=0.3, metal=0.6), (0, 0, 0.0), (7.4, 0.92, 0.1))
    for k in range(18):
        B.box(mat("bulbY", flat((255, 236, 150)), emit=(1.0, 0.85, 0.4)), (-3.6 + k * 7.2 / 17, 0.44, 0.08), (0.08, 0.08, 0.08))
    B.save("sign")
    # an old bare bulb on a wire (build 1)
    B = Builder(); B.cyl(WIRE(), (0, 0, 0), (0, -0.6, 0), 0.01, 4); B.box(mat("bulb", flat((255, 225, 160)), emit=(1, 0.8, 0.45)), (0, -0.66, 0), (0.1, 0.13, 0.1)); B.save("bulb")
    # shelves full of cracker boxes on the back wall (4 units of 1.6 m)
    B = Builder()
    for k in range(5):
        B.box(WOOD(), (0, 0.15 + k * 0.62, -0.2), (1.6, 0.05, 0.42))
    for x in (-0.78, 0.78): B.box(WOOD(), (x, 1.4, -0.2), (0.05, 2.8, 0.42))
    B.box(WOOD(), (0, 1.4, -0.41), (1.6, 2.8, 0.02), "s")
    i = 0
    for k in range(4):
        x = -0.68
        while x < 0.62:
            w = random.choice([0.24, 0.3, 0.36]); h = random.choice([0.32, 0.4, 0.46])
            crackerbox(B, (x + w / 2, 0.18 + k * 0.62 + h / 2, -0.2), (w, h, 0.3), i); x += w + 0.04; i += 1
    B.save("shelf")
    # counter with glass top showing boxes, and a green steel cash box
    B = Builder()
    B.box(WOOD(), (0, 0.5, 0), (4.2, 0.9, 0.7))
    B.box(mat("cpanel", flat((200, 40, 40)), rough=0.5), (0, 0.5, 0.351), (4.0, 0.25, 0.01), "s")
    B.box(GLASS(), (0, 1.0, 0), (4.2, 0.08, 0.72), "t")
    for k in range(9): crackerbox(B, (-1.8 + k * 0.45, 0.82, 0), (0.36, 0.2, 0.4), k + 3)
    B.save("counter")
    B = Builder(); B.box(mat("cash", flat((40, 110, 70)), rough=0.4, metal=0.5), (0, 0.13, 0), (0.5, 0.26, 0.35)); B.box(mat("gold", flat((245, 197, 66)), rough=0.3, metal=0.6), (0, 0.2, 0.18), (0.08, 0.06, 0.02)); B.save("cashbox")
    # stepped display rack for the pavement
    B = Builder()
    for k in range(3):
        B.box(WOOD(), (0, 0.25 + k * 0.32, -k * 0.32), (1.9, 0.5 + k * 0.64 - k * 0.32 * 2 + k * 0.32 * 2, 0.32) if False else (1.9, 0.5 + k * 0.64, 0.32))
        for j in range(5): crackerbox(B, (-0.76 + j * 0.38, 0.5 + k * 0.64 + 0.12, -k * 0.32), (0.32, 0.24, 0.26), j + k * 5)
    B.save("rack")
    # striped awning: hinge at the wall (origin), slopes out 1.7 m, scalloped front (scale.z unrolls it)
    am = mat(("awn", "ghilli"), stripes((215, 38, 61), (255, 241, 214), 8, 256, 64), rough=0.9, tile=1.0)
    B = Builder()
    B.quad(am, (-3.6, -0.45, 1.7), (7.2, 0, 0), (0, 0.45, -1.7), (0, 0), (5, 1))
    B.quad(am, (3.6, -0.45, 1.7), (-7.2, 0, 0), (0, 0.45, -1.7), (0, 0), (5, 1))
    for k in range(16):
        x = -3.6 + k * 0.45
        B.tri(am, (x, -0.45, 1.71), (x + 0.45, -0.45, 1.71), (x + 0.225, -0.75, 1.71), (0, 1), (0.3, 1), (0.15, 0))
        B.tri(am, (x + 0.45, -0.45, 1.70), (x, -0.45, 1.70), (x + 0.225, -0.75, 1.70), (0.3, 1), (0, 1), (0.15, 0))
    B.save("awning")
    # marigold garlands: a swag across the top and two side strands
    def garland(name, pts):
        B = Builder()
        for k, p in enumerate(pts):
            c = (255, 140, 0) if k % 3 else (255, 210, 50)
            B.box(mat(("mg", c), flat(c), rough=0.9), p, (0.15, 0.15, 0.15))
            if k % 6 == 0: B.box(mat("leaf", flat((70, 140, 50)), rough=0.9), (p[0], p[1] - 0.12, p[2]), (0.08, 0.14, 0.05))
        B.save(name)
    garland("gar_top", [(-3.5 + 7.0 * t, 3.3 - math.sin(t * math.pi) * 0.45, 0.32) for t in np.linspace(0, 1, 44)])
    garland("gar_side", [(0, -k * 0.14, 0) for k in range(22)])
    # paper star lantern (akash kandil), glowing
    B = Builder(); B.cyl(WIRE(), (0, 0, 0), (0, -0.5, 0), 0.01, 4)
    lm = mat("lant", flat((255, 120, 30)), emit=(1.0, 0.45, 0.1), rough=0.8)
    B.box(lm, (0, -0.8, 0), (0.42, 0.42, 0.42)); B.box(mat("lant2", flat((255, 210, 60)), emit=(1.0, 0.8, 0.2)), (0, -0.8, 0), (0.6, 0.12, 0.12)); B.box(mat("lant2", flat((255, 210, 60)), emit=(1.0, 0.8, 0.2)), (0, -0.8, 0), (0.12, 0.12, 0.6))
    for k in range(5): B.box(mat(("tas", k), flat((255, 200, 60)), rough=0.9), (-0.16 + k * 0.08, -1.15, 0), (0.025, 0.3, 0.025))
    B.save("lantern")
    # Grandpa's photo with a frame and a small garland
    g = Image.open("/home/claude/repo/godot/art/shop/grandpa.png").convert("RGB")
    B = Builder()
    B.box(mat("pframe", flat((120, 70, 30)), rough=0.5), (0, 0, 0), (0.78, 0.96, 0.05))
    B.quad(mat("gpa", g, rough=0.5, tile=1.0), (-0.32, -0.4, 0.026), (0.64, 0, 0), (0, 0.8, 0), (0, 0), (1, 1))
    for k, t in enumerate(np.linspace(0, 1, 16)):
        c = (255, 140, 0) if k % 2 else (255, 210, 50)
        B.box(mat(("mg", c), flat(c), rough=0.9), (-0.4 + 0.8 * t, 0.42 - math.sin(t * math.pi) * 0.5, 0.06), (0.09, 0.09, 0.09))
    B.save("photo")
    # ribbon for the grand opening: two halves (origin at the middle) and a bow
    rm = mat("ribbon", flat((220, 20, 40)), rough=0.35)
    B = Builder(); B.box(rm, (-1.75, 0, 0), (3.5, 0.18, 0.02)); B.save("ribbon_l")
    B = Builder(); B.box(rm, (1.75, 0, 0), (3.5, 0.18, 0.02)); B.save("ribbon_r")
    B = Builder(); B.box(rm, (-0.22, 0, 0), (0.4, 0.3, 0.05)); B.box(rm, (0.22, 0, 0), (0.4, 0.3, 0.05)); B.box(mat("gold", flat((245, 197, 66)), rough=0.3, metal=0.6), (0, 0, 0.02), (0.14, 0.16, 0.06)); B.save("bow")

def lorry():
    """an Indian lorry (Tata style, ~7.5 m, faces +x): orange cab with painted bands, wooden body loaded with cracker boxes under a tarp"""
    B = Builder()
    cab = mat("lcab", ph("painted_plaster_wall", size=256), tint=(1.25, 0.6, 0.15), rough=0.4, tile=3)
    band = mat(("awn", "lorry"), stripes((30, 120, 200), (255, 220, 60), 12, 256, 32), tile=1.0)
    T = mat("tyre", flat((30, 30, 30)), rough=0.9); C = mat("chrome", flat((210, 210, 210)), rough=0.2, metal=0.9)
    B.box(mat("chassis", flat((40, 40, 45)), rough=0.6), (0, 0.75, 0), (7.4, 0.3, 1.9))
    B.box(cab, (2.75, 1.85, 0), (1.9, 2.0, 2.3))
    B.box(cab, (3.55, 2.95, 0), (0.6, 0.35, 2.3))
    for z in (-1.151, 1.151):
        B.quad(band, (1.8 if z > 0 else 3.7, 1.25, z), (1.9 if z > 0 else -1.9, 0, 0), (0, 0.3, 0), (0, 0), (3, 1))
        B.quad(GLASS(), (2.6 if z > 0 else 3.5, 2.0, z), (0.9 if z > 0 else -0.9, 0, 0), (0, 0.65, 0), (0, 0), (1, 1))
    B.quad(GLASS(), (3.71, 2.05, 1.05), (0, 0, -2.1), (0, 0.75, 0), (0, 0), (1, 1))
    B.box(C, (3.75, 1.2, 0), (0.12, 0.4, 2.2))
    B.box(mat("lamp", flat((255, 245, 200)), emit=(1, 1, 0.8)), (3.8, 1.5, 0.8), (0.06, 0.2, 0.3)); B.box(mat("lamp", flat((255, 245, 200)), emit=(1, 1, 0.8)), (3.8, 1.5, -0.8), (0.06, 0.2, 0.3))
    # wooden body with painted panel
    B.box(WOOD(), (-1.0, 1.55, 0), (5.2, 1.3, 2.4))
    for z in (-1.201, 1.201):
        B.quad(band, (-3.6 if z > 0 else 1.6, 2.1, z), (5.2 if z > 0 else -5.2, 0, 0), (0, 0.18, 0), (0, 0), (8, 1))
    B.quad(mat(("sign", "lorry"), sign_img("GHILLI CRACKERS · SIVAKASI", (192, 22, 31), (255, 226, 122), "", 1024, 140), tile=1.0), (-3.4, 1.15, 1.205), (4.8, 0, 0), (0, 0.7, 0), (0, 0), (1, 1))
    B.quad(mat(("sign", "lorry"), sign_img("GHILLI CRACKERS · SIVAKASI", (192, 22, 31), (255, 226, 122), "", 1024, 140), tile=1.0), (1.4, 1.15, -1.205), (-4.8, 0, 0), (0, 0.7, 0), (0, 0), (1, 1))
    # load: boxes + a blue tarp hump
    i = 0
    for x in np.arange(-3.3, 1.4, 0.55):
        for z in (-0.6, 0.0, 0.6):
            crackerbox(B, (x + 0.25, 2.45, z), (0.5, 0.5, 0.5), i); i += 1
    B.box(mat("tarp", ph("painted_plaster_wall", size=256), tint=(0.35, 0.55, 1.2), rough=0.8, tile=2), (-1.0, 2.75, 0), (4.6, 0.2, 2.0), "nsewt")
    for (x, z) in ((2.7, -1.0), (2.7, 1.0), (-2.2, -1.0), (-2.2, 1.0), (-3.2, -1.0), (-3.2, 1.0)):
        B.cyl(T, (x, 0.5, z - 0.16), (x, 0.5, z + 0.16), 0.5, 14)
        B.cyl(C, (x, 0.5, z - 0.17 if z < 0 else z + 0.17), (x, 0.5, z - 0.17 if z < 0 else z + 0.17), 0.2, 8) if False else None
    B.save("lorry")

# ---------------------------------------------------------------- the street
def street():
    B = Builder()
    asph = mat("asph", ph("asphalt_02"), ph("asphalt_02", "nor_gl"), tint=(1.08, 1.06, 1.04), tile=5.0, rough=0.95)
    pave = mat("pave", ph("brick_pavement_02"), ph("brick_pavement_02", "nor_gl"), tint=(1.25, 1.18, 1.1), tile=2.5)
    curb = mat("curb", ph("concrete_wall_006"), tint=(1.2, 1.18, 1.12), tile=1.5)
    paint = mat("paint", flat((236, 232, 216)), rough=0.8)
    yel = mat("paintY", flat((236, 196, 60)), rough=0.8)
    X0, X1 = -70, 70
    B.quad(asph, (X0, 0, 16.0), (X1 - X0, 0, 0), (0, 0, -12.6))
    B.box(pave, (0, 0.09, 1.6), (X1 - X0, 0.18, 3.2), "st")
    B.box(curb, (0, 0.1, 3.3), (X1 - X0, 0.2, 0.2), "st")
    for i in range(int((X1 - X0) / 2)):   # painted kerb, black and yellow
        B.quad(yel if i % 2 else mat("paintK", flat((40, 40, 40))), (X0 + i * 2, 0.0, 3.401), (2, 0, 0), (0, 0.2, 0))
    B.box(pave, (0, 0.09, 17.6), (X1 - X0, 0.18, 3.2), "st")
    B.box(curb, (0, 0.1, 15.9), (X1 - X0, 0.2, 0.2), "sn")
    B.quad(pave, (X0, 0.18, 40), (X1 - X0, 0, 0), (0, 0, -20.8))
    for x in np.arange(X0, X1, 6.0):
        B.quad(paint, (x, 0.012, 9.8), (3.0, 0, 0), (0, 0, -0.16))
    B.quad(paint, (X0, 0.012, 4.0), (X1 - X0, 0, 0), (0, 0, -0.12))
    B.quad(paint, (X0, 0.012, 15.5), (X1 - X0, 0, 0), (0, 0, -0.12))
    # a zebra crossing on the right
    for i in range(9):
        B.quad(paint, (14 + i * 0.9, 0.013, 15.3), (0.5, 0, 0), (0, 0, -11.2))
    B.save("road")

def shops():
    B = Builder()
    building(B, -4.0, 4.0, 2, plaster("beige_wall_001", (1.3, 1.24, 1.12)), shutter="box", shop="empty", tank=True, step=False)
    B.save("ghilli")
    # the same shop freshly painted (build 5): cream walls, red pillars, turquoise and yellow room
    B = Builder()
    building(B, -4.0, 4.0, 2, plaster("painted_plaster_wall", (1.3, 1.22, 1.0)), shutter="box", shop="empty", tank=True, step=False,
             pillar=plaster("painted_plaster_wall", (1.15, 0.28, 0.25)),
             room=(plaster("painted_plaster_wall", (0.55, 1.15, 1.08)), plaster("painted_plaster_wall", (1.3, 1.1, 0.45))))
    B.save("ghilli_new")
    B = Builder()
    building(B, -12.6, -4.0, 3, plaster("painted_plaster_wall", (1.25, 0.82, 0.88)), sign=("LAKSHMI TEXTILES", (179, 23, 30), (255, 233, 168)), shop="sarees", balcony=True, awning=((232, 93, 59), (255, 241, 214)), ac=2)
    building(B, -20.6, -12.6, 2, plaster("blue_plaster_weathered", (1.0, 1.05, 1.0)), sign=("KAAPI BAR", (46, 125, 79), (255, 243, 196), "FILTER COFFEE · TIFFIN"), shop="kaapi", tank=True)
    building(B, -29.6, -20.6, 4, plaster("painted_plaster_wall", (1.15, 1.08, 0.75)), sign=("SRI VINAYAGA MEDICALS", (31, 79, 158), (255, 255, 255)), shop="sweets", balcony=True, ac=1)
    building(B, -38.6, -29.6, 3, plaster("clay_plaster", (1.1, 1.0, 0.95)), sign=("RAJA PHOTO STUDIO", (60, 60, 70), (255, 220, 120)), shop="kaapi")
    building(B, 4.0, 12.6, 3, plaster("painted_plaster_wall", (0.82, 1.02, 1.22)), sign=("MURUGAN STORES", (31, 79, 158), (255, 241, 196), "STEEL · BRASS · VESSELS"), shop="vessels", balcony=True, ac=2)
    building(B, 12.6, 20.0, 2, plaster("yellow_plaster", (1.1, 1.05, 0.95)), sign=("SRI GANESH SWEETS", (211, 84, 0), (255, 243, 196)), shop="sweets", awning=((46, 125, 79), (255, 241, 214)), tank=True)
    building(B, 20.0, 29.0, 4, plaster("painted_plaster_wall", (0.85, 1.15, 0.95)), sign=("ANNAI MOBILES", (200, 30, 120), (255, 255, 255)), shop="vessels", balcony=True, ac=2)
    building(B, 29.0, 38.0, 3, plaster("beige_wall_001", (1.0, 0.95, 0.9)), sign=("BUNDER STREET", (120, 40, 40), (255, 230, 160)), shop="sarees")
    B.save("row")

def wires():
    """sagging black cables between the poles and from the poles to the buildings"""
    B = Builder()
    W = WIRE()
    def sag(a, b, s, r=0.018, n=14):
        a, b = np.array(a, float), np.array(b, float)
        pts = [a + (b - a) * t - np.array([0, math.sin(t * math.pi) * s, 0]) for t in np.linspace(0, 1, n + 1)]
        for p, q in zip(pts, pts[1:]):
            B.cyl(W, p, q, r, 5)
    poles = [-26, -6, 14, 34]
    for p, q in zip(poles, poles[1:]):
        for k, (dy, dz) in enumerate([(0, -1.2), (0, 0), (0, 1.2), (-0.6, -0.5), (-0.6, 0.5)]):
            sag((p, 7.2 + dy, 3.0 + dz), (q, 7.2 + dy, 3.0 + dz), 0.9 + k * 0.12)
    for p in poles:
        for t in (-3.5, 3.0):
            sag((p, 6.6, 3.0), (p + t, 7.6 + abs(t) * 0.3, 0.15), 0.35, 0.012, 8)
    # across the road
    # a festival string of little flags over the road
    for i, (a, b) in enumerate([((-26, 6.8, 3.0), (-22, 6.6, 17)), ((34, 6.8, 3.0), (30, 6.6, 17))]):
        sag(a, b, 0.8, 0.008, 10)
    B.save("wires")

def poles():
    B = Builder()
    pm = mat("pole", ph("concrete_wall_006"), tint=(1.1, 1.08, 1.0), tile=2.0)
    B.box(pm, (0, 4.0, 0), (0.26, 8.0, 0.26))
    B.box(METAL(), (0, 7.2, 0), (0.12, 0.12, 2.8))
    B.box(METAL(), (0, 6.6, 0), (0.1, 0.1, 1.6))
    for z in (-1.2, 0, 1.2):
        B.box(mat("ins", flat((210, 205, 190)), rough=0.4), (0, 7.32, z), (0.1, 0.14, 0.1))
    B.box(mat("box", flat((120, 124, 112)), rough=0.6), (0, 2.6, 0.2), (0.45, 0.6, 0.25))
    B.save("pole")

def auto():
    """a Chennai auto rickshaw: yellow and black body, black canvas hood, 3 wheels (~2.6 m long)"""
    B = Builder()
    Y = mat("autoY", ph("painted_plaster_wall", size=256), tint=(1.25, 1.0, 0.25), rough=0.45, tile=3)
    G = mat("autoG", ph("painted_plaster_wall", size=256), tint=(0.25, 0.25, 0.25), rough=0.4, tile=3)
    K = mat("autoK", flat((25, 25, 25)), rough=0.9)
    T = mat("tyre", flat((30, 30, 30)), rough=0.9)
    C = mat("chrome", flat((210, 210, 210)), rough=0.2, metal=0.9)
    # floor + lower body (z: front = +z)
    B.box(G, (0, 0.45, -0.2), (1.3, 0.3, 1.7))
    B.box(Y, (0, 0.85, -0.6), (1.3, 0.5, 0.9))            # seat back body
    B.box(K, (0, 0.82, -0.2), (1.1, 0.12, 0.6))            # seat
    B.box(Y, (0, 0.85, 0.85), (0.8, 0.9, 0.35))            # front nose
    B.box(G, (0, 0.55, 0.98), (0.3, 0.4, 0.3))             # front wheel fork cover
    B.quad(GLASS(), (-0.45, 1.3, 0.95), (0.9, 0, 0), (0, 0.55, -0.25), (0, 0), (1, 1))
    B.box(C, (0, 1.32, 0.98), (0.9, 0.04, 0.06))
    # hood: posts + roof
    for x in (-0.6, 0.6):
        B.box(K, (x, 1.5, 0.7), (0.05, 1.0, 0.05))
        B.box(K, (x, 1.5, -1.0), (0.05, 1.0, 0.05))
    B.box(K, (0, 2.02, -0.15), (1.35, 0.08, 2.0))
    B.box(K, (0, 1.6, -1.05), (1.35, 0.85, 0.05))
    B.box(Y, (0, 1.9, -1.08), (1.36, 0.12, 0.03), "s")
    # wheels
    for (x, z) in ((-0.6, -0.6), (0.6, -0.6), (0, 1.0)):
        B.cyl(T, (x - 0.08, 0.27, z), (x + 0.08, 0.27, z), 0.27, 12)
        B.cyl(C, (x - 0.09, 0.27, z), (x + 0.09, 0.27, z), 0.12, 8)
    B.box(mat("lamp", flat((255, 245, 200)), emit=(1, 1, 0.8)), (0, 1.15, 1.04), (0.18, 0.12, 0.04))
    B.save("auto")

def bike():
    """a scooter / motorbike (~1.9 m)"""
    B = Builder()
    R = mat("bikeR", ph("painted_plaster_wall", size=256), tint=(1.1, 0.25, 0.25), rough=0.35, tile=3)
    K = mat("autoK", flat((25, 25, 25)), rough=0.9)
    T = mat("tyre", flat((30, 30, 30)), rough=0.9)
    C = mat("chrome", flat((210, 210, 210)), rough=0.2, metal=0.9)
    for z in (-0.65, 0.65):
        B.cyl(T, (-0.05, 0.3, z), (0.05, 0.3, z), 0.3, 14)
        B.cyl(C, (-0.06, 0.3, z), (0.06, 0.3, z), 0.12, 8)
    B.box(R, (0, 0.62, -0.25), (0.34, 0.35, 0.9))
    B.box(K, (0, 0.85, -0.3), (0.3, 0.1, 0.7))
    B.box(R, (0, 0.65, 0.45), (0.3, 0.6, 0.18))
    B.cyl(C, (0, 0.3, 0.65), (0, 1.05, 0.5), 0.03, 6)
    B.cyl(C, (-0.35, 1.05, 0.5), (0.35, 1.05, 0.5), 0.025, 6)
    B.box(mat("lamp", flat((255, 245, 200)), emit=(1, 1, 0.8)), (0, 0.98, 0.58), (0.14, 0.12, 0.04))
    B.save("bike")

def stall():
    """a pavement flower / fruit cart with a big umbrella"""
    B = Builder()
    wd = mat("wood", ph("concrete_wall_006", size=256), tint=(0.85, 0.6, 0.4), tile=1.0)
    B.box(wd, (0, 0.8, 0), (1.8, 0.12, 0.9))
    for x in (-0.8, 0.8):
        for z in (-0.35, 0.35):
            B.box(wd, (x, 0.4, z), (0.06, 0.8, 0.06))
    rng = random.Random(3)
    for i in range(40):
        c = rng.choice([(255, 140, 30), (250, 210, 60), (230, 50, 60), (90, 170, 60), (255, 255, 240)])
        B.box(mat(("fr", c), flat(c), rough=0.7), (rng.uniform(-0.8, 0.8), 0.92, rng.uniform(-0.38, 0.38)), (0.14, 0.14, 0.14))
    B.cyl(mat("chrome", flat((210, 210, 210)), rough=0.2, metal=0.9), (0, 0.8, 0), (0, 2.4, 0), 0.025, 6)
    um = mat(("umb",), stripes((214, 40, 60), (255, 241, 214), 8, 256, 32), rough=0.9, tile=1.0)
    n = 8
    for i in range(n):
        a0, a1 = 2 * math.pi * i / n, 2 * math.pi * (i + 1) / n
        p0 = (math.cos(a0) * 1.3, 2.05, math.sin(a0) * 1.3)
        p1 = (math.cos(a1) * 1.3, 2.05, math.sin(a1) * 1.3)
        top = np.array((0, 2.55, 0))
        # one triangle as a degenerate quad (both winding sides)
        B.tri(um, p1, p0, top, ((i + 1) / n, 0), (i / n, 0), ((i + .5) / n, 1))
        B.tri(um, p0, p1, top, (i / n, 0), ((i + 1) / n, 0), ((i + .5) / n, 1))
    B.save("stall")

def shutter():
    """the rusty rolling shutter of our shop: origin at its top edge, so scale.y rolls it up"""
    B = Builder()
    ow, oh = 6.8, 3.3
    sh = mat("shutter", ph("corrugated_iron_02"), ph("corrugated_iron_02", "nor_gl"), tint=(0.95, 0.75, 0.62), tile=1.6, rough=0.75, metal=0.3, rot=True)
    B.quad(sh, (-ow / 2, -(oh - 0.18), 0), (ow, 0, 0), (0, oh - 0.18, 0))
    B.box(METAL(), (0, -(oh - 0.18) + 0.12, 0.03), (ow, 0.08, 0.06))
    B.box(mat("lock", flat((200, 160, 60)), metal=0.8, rough=0.3), (0, -(oh - 0.18) + 0.14, 0.08), (0.16, 0.2, 0.08))
    B.save("shutter")
    B = Builder()
    B.box(mat("tube", flat((255, 250, 235)), emit=(1.0, 0.97, 0.9), rough=0.3), (0, 0, 0), (1.8, 0.07, 0.07))
    B.box(mat("frame", flat((235, 230, 220)), rough=0.6), (0, 0.06, 0), (1.9, 0.05, 0.12))
    B.save("tube")

shutter(); street(); shops(); shop_parts(); lorry(); wires(); poles(); auto(); bike(); stall()
