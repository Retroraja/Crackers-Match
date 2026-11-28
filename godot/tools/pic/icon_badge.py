# 25 Nov: round glowing badge behind the Daily and Piggy icons on home (one picture, drawn once)
from PIL import Image, ImageDraw, ImageFilter
S = 4; W = 128 * S
im = Image.new("RGBA", (W, W), (0, 0, 0, 0))
g = Image.new("RGBA", (W, W), (0, 0, 0, 0)); d = ImageDraw.Draw(g)
c = W // 2
d.ellipse([c - 52 * S, c - 52 * S, c + 52 * S, c + 52 * S], fill=(255, 196, 60, 200))
g = g.filter(ImageFilter.GaussianBlur(10 * S))
im.alpha_composite(g)
d = ImageDraw.Draw(im)
R = 42 * S
d.ellipse([c - R - 4 * S, c - R - 4 * S, c + R + 4 * S, c + R + 4 * S], fill=(120, 60, 0, 255))
d.ellipse([c - R - 2.5 * S, c - R - 2.5 * S, c + R + 2.5 * S, c + R + 2.5 * S], fill=(255, 210, 63, 255))
for i in range(R, 0, -S):
    t = i / R
    col = (int(70 + 60 * (1 - t)), int(20 + 22 * (1 - t)), int(96 + 40 * (1 - t)), 255)
    d.ellipse([c - i, c - i - 0 * S, c + i, c + i], fill=col)
# soft top shine
sh = Image.new("RGBA", (W, W), (0, 0, 0, 0)); d2 = ImageDraw.Draw(sh)
d2.ellipse([c - 30 * S, c - 38 * S, c + 30 * S, c - 8 * S], fill=(255, 255, 255, 46))
sh = sh.filter(ImageFilter.GaussianBlur(4 * S))
im.alpha_composite(sh)
im.resize((128, 128), Image.LANCZOS).save("art/web/ic_badge.png")
