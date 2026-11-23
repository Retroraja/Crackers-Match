# Grandpa's dream (23 Nov): the Crackers Factory as a glowing gold blueprint, made once from the factory's own
# build sticker (street/pics/a1_p2_b9_0.webp) so the dream matches what the player builds at the end of Area 1.
# Output: art/story/factory_dream.png (straight alpha). Run from godot/: python3 tools/pic/factory_blueprint.py
from PIL import Image, ImageFilter, ImageChops, ImageDraw, ImageFont
S = 2.2
src = Image.open('street/pics/a1_p2_b9_0.webp').convert('RGBA')
src = src.resize((int(src.width * S), int(src.height * S)), Image.LANCZOS)
a = src.getchannel('A').point(lambda v: 255 if v > 110 else 0)
# the cart and trees on the right of the building, below the roof, go
ImageDraw.Draw(a).rectangle((int(a.width * 0.635), int(a.height * 0.40), a.width, a.height), fill=0)
# keep the building only: the biggest piece of the sticker after cutting thin links (no cart, no trees)
import numpy as np
from scipy import ndimage
m = np.array(a.filter(ImageFilter.MinFilter(25))) > 0
lab, n = ndimage.label(m)
big = np.argmax(ndimage.sum(m, lab, range(1, n + 1))) + 1
keep = ndimage.binary_dilation(lab == big, iterations=14) & (np.array(a) > 0)
a = Image.fromarray((keep * 255).astype('uint8'))
src.putalpha(a)
bb = a.getbbox()
src, a = src.crop(bb), a.crop(bb)
lum = src.convert('L').filter(ImageFilter.MedianFilter(7)).filter(ImageFilter.GaussianBlur(1.5))
# inner edges (windows, doors, roof lines) + the outline
e1 = lum.filter(ImageFilter.FIND_EDGES).point(lambda v: 255 if v > 14 else 0)
e1 = ImageChops.multiply(e1, a.filter(ImageFilter.MinFilter(5)))
e2 = ImageChops.subtract(a.filter(ImageFilter.MaxFilter(5)), a.filter(ImageFilter.MinFilter(3)))
lines = ImageChops.lighter(e1, e2).filter(ImageFilter.MaxFilter(3))
pad = 60
W, H = src.width + pad * 2, src.height + pad * 2 + 120
out = Image.new('RGBA', (W, H), (0, 0, 0, 0))
def layer(mask, col, alpha):
    m = Image.new('L', (W, H), 0)
    m.paste(mask, (pad, pad))
    m = m.point(lambda v: int(v * alpha))
    out.alpha_composite(Image.merge('RGBA', (Image.new('L', (W, H), col[0]), Image.new('L', (W, H), col[1]), Image.new('L', (W, H), col[2]), m)))
# faint gold fill, a wide soft glow, then crisp lines
layer(a, (255, 200, 70), 0.16)
layer(lines.filter(ImageFilter.GaussianBlur(9)), (255, 170, 40), 0.9)
layer(lines.filter(ImageFilter.GaussianBlur(2)), (255, 215, 90), 1.0)
layer(lines, (255, 248, 210), 1.0)
# a gold sign under it: CRACKERS FACTORY
d = ImageDraw.Draw(out)
try:
    f = ImageFont.truetype('art/LilitaOne.ttf', 64)
except Exception:
    f = ImageFont.load_default()
t = 'CRACKERS FACTORY'
tw = d.textlength(t, font=f)
y = H - 110
sign = Image.new('RGBA', (W, H), (0, 0, 0, 0))
ds = ImageDraw.Draw(sign)
ds.rounded_rectangle(((W - tw) / 2 - 26, y - 10, (W + tw) / 2 + 26, y + 80), 18, outline=(255, 215, 90, 255), width=5, fill=(255, 190, 60, 40))
ds.text(((W - tw) / 2, y), t, font=f, fill=(255, 236, 170, 255))
glow = sign.filter(ImageFilter.GaussianBlur(8))
out.alpha_composite(glow)
out.alpha_composite(sign)
out.save('art/story/factory_dream.png')
print(out.size)
