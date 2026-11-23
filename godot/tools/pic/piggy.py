# The piggy bank (23 Nov): an Indian clay money pot (undiyal), made once from the clay pot breakable (art/brk/pot_1.png):
# the mouth is closed with a clay dome, a coin slot cut in it, a gold coin half in. Output art/web/piggy.png
from PIL import Image, ImageDraw, ImageFilter
im = Image.open('art/brk/pot_1.png').convert('RGBA')
S = 4
big = im.resize((im.width * S, im.height * S), Image.LANCZOS)
d = ImageDraw.Draw(big)
def b(x0, y0, x1, y1): return (x0 * S, y0 * S, x1 * S, y1 * S)
# clay dome over the mouth
d.ellipse(b(92, 52, 222, 112), fill=(120, 40, 12, 255))
d.ellipse(b(96, 54, 218, 108), fill=(214, 98, 38, 255))
d.ellipse(b(108, 58, 190, 84), fill=(236, 140, 70, 255))
# the coin slot and a gold coin going in
d.rounded_rectangle(b(132, 70, 184, 80), radius=4 * S, fill=(50, 20, 6, 255))
d.ellipse(b(140, 40, 176, 76), fill=(150, 95, 10, 255))
d.ellipse(b(142, 42, 174, 74), fill=(255, 200, 50, 255))
d.ellipse(b(149, 49, 167, 67), outline=(205, 140, 20, 255), width=3 * S)
d.rounded_rectangle(b(132, 74, 184, 80), radius=3 * S, fill=(50, 20, 6, 255))
big.resize((160, 160), Image.LANCZOS).save('art/web/piggy.png')
print('ok')
