# 25 Nov: cut the 3D toy renders (toy3d.gd) into 300x300 tile pictures like the crackers (art/crk/t*.webp):
# same height and base line (cracker body ~278 px tall, bottom at y=293).
import sys
from PIL import Image, ImageDraw, ImageFilter
def tile(src, out, h, bottom, shadow=False, wmax=300):
    im = Image.open(src).convert("RGBA")
    im = im.crop(im.getbbox())
    k = h / im.height
    if im.width * k > wmax:
        k = wmax / im.width
    im = im.resize((round(im.width * k), round(im.height * k)), Image.LANCZOS)
    t = Image.new("RGBA", (300, 300), (0, 0, 0, 0))
    if shadow:
        sh = Image.new("RGBA", (300, 300), (0, 0, 0, 0))
        ImageDraw.Draw(sh).ellipse([150 - im.width * 0.4, bottom - 12, 150 + im.width * 0.4, bottom + 6], fill=(40, 10, 30, 110))
        t.alpha_composite(sh.filter(ImageFilter.GaussianBlur(5)))
    t.alpha_composite(im, (150 - im.width // 2, bottom - im.height))
    t.save(out)
tile("/tmp/s/potli.png", "art/toy/bag.png", 246, 290, True, 236)
tile("/tmp/s/top.png", "art/toy/top.png", 272, 298)
tile("/tmp/s/mayil.png", "art/toy/mayil.png", 284, 292)
