# 25 Nov: portal mouth (glowing purple-blue ring seen from the side), drawn once into the baked board floor
from PIL import Image, ImageDraw, ImageFilter
S = 4; W, H = 160 * S, 64 * S
im = Image.new("RGBA", (W, H), (0, 0, 0, 0))
g = Image.new("RGBA", (W, H), (0, 0, 0, 0)); d = ImageDraw.Draw(g)
d.ellipse([6 * S, 10 * S, W - 6 * S, H - 10 * S], fill=(150, 90, 255, 220))
g = g.filter(ImageFilter.GaussianBlur(7 * S))
im.alpha_composite(g)
d = ImageDraw.Draw(im)
d.ellipse([18 * S, 18 * S, W - 18 * S, H - 18 * S], fill=(40, 10, 90, 255), outline=(140, 220, 255, 255), width=4 * S)
d.ellipse([30 * S, 24 * S, W - 30 * S, H - 24 * S], fill=(12, 2, 40, 255))
im.resize((160, 64), Image.LANCZOS).save("art/toy/portal.png")
