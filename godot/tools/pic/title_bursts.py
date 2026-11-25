# 25 Nov (v2, his note: no perfect circles): firework burst pictures for the title, made to look real: every streak
# has its own length and angle, drooping with gravity, some break into sparkle dots, uneven, a little lopsided.
# Pooled sprites on the title (grown + faded live; no live drawing). 512x512 each, rocket trail 48x256.
import math, random
from PIL import Image, ImageDraw, ImageFilter
S = 2; W = 512 * S; C = W // 2
def burst(name, cols, n, R, droop, seed, palm=False, crackle=0, lopsided=0.12):
    random.seed(seed)
    im = Image.new("RGBA", (W, W), (0, 0, 0, 0)); gl = Image.new("RGBA", (W, W), (0, 0, 0, 0))
    d = ImageDraw.Draw(im); g = ImageDraw.Draw(gl)
    lx, ly = random.uniform(-1, 1), random.uniform(-1, 1)
    for i in range(n):
        a = random.uniform(0, math.tau)
        L = R * S * random.uniform(0.45, 1.0) * (1 + lopsided * (math.cos(a) * lx + math.sin(a) * ly))
        col = random.choice(cols)
        steps = 34
        broken = random.random() < 0.35
        for k in range(steps):
            t = k / (steps - 1)
            if broken and t > 0.55 and k % 3:
                continue
            r = L * (0.12 + 0.88 * t)
            x = C + math.cos(a) * r
            y = C + math.sin(a) * r + droop * S * t * t * (1.6 if palm else 1.0)
            w = ((3.6 if palm else 2.2) * (1 - 0.55 * t) + 0.6) * S
            al = int(255 * min(1.0, 0.35 + t) * (1 - 0.35 * t))
            d.ellipse([x - w, y - w, x + w, y + w], fill=col + (al,))
            if k % 2 == 0:
                g.ellipse([x - w * 3.5, y - w * 3.5, x + w * 3.5, y + w * 3.5], fill=col + (al // 4,))
        if random.random() < 0.5:
            x = C + math.cos(a) * L * 1.04; y = C + math.sin(a) * L * 1.04 + droop * S
            rr = random.uniform(2.5, 4.5) * S
            d.ellipse([x - rr, y - rr, x + rr, y + rr], fill=(255, 250, 225, 255))
    for i in range(crackle):
        a = random.uniform(0, math.tau); r = R * S * random.uniform(0.3, 1.15)
        x = C + math.cos(a) * r; y = C + math.sin(a) * r + droop * S * 0.8
        rr = random.uniform(1.5, 3.5) * S
        d.ellipse([x - rr, y - rr, x + rr, y + rr], fill=(255, 255, 240, random.randint(150, 255)))
    gl = gl.filter(ImageFilter.GaussianBlur(9 * S))
    out = Image.new("RGBA", (W, W), (0, 0, 0, 0)); out.alpha_composite(gl); out.alpha_composite(im)
    out.resize((512, 512), Image.LANCZOS).save("art/fx/fw_%s.png" % name)
burst("gold", [(255, 205, 70), (255, 230, 140), (255, 170, 40)], 90, 205, 30, 2, crackle=40)
burst("red", [(255, 60, 90), (255, 130, 150), (255, 200, 120)], 70, 190, 34, 3, crackle=25)
burst("green", [(70, 230, 140), (170, 255, 200), (255, 220, 110)], 16, 185, 60, 4, palm=True)
burst("willow", [(255, 200, 90), (255, 160, 60)], 70, 170, 110, 5, crackle=10)
burst("blue", [(90, 160, 255), (190, 220, 255), (255, 255, 255)], 80, 195, 28, 6, crackle=60)
T = Image.new("RGBA", (48 * S, 256 * S), (0, 0, 0, 0)); d = ImageDraw.Draw(T)
for k in range(60):
    t = k / 59; y = (20 + t * 220) * S; w = (7 - 5 * t) * S
    x = 24 * S + math.sin(t * 9) * 2 * S * t
    d.ellipse([x - w, y - w, x + w, y + w], fill=(255, 215, 120, int(255 * (1 - t) ** 1.4)))
T = T.filter(ImageFilter.GaussianBlur(2 * S))
ImageDraw.Draw(T).ellipse([18 * S, 14 * S, 30 * S, 26 * S], fill=(255, 255, 240, 255))
T.resize((48, 256), Image.LANCZOS).save("art/fx/fw_trail.png")
