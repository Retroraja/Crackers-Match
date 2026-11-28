# 27 Nov: 1000 Wala string built at full size (Canva only gives a 200 px preview, too soft):
# our own sharp red board cracker (b0), small, tied in pairs on a twisted fuse, alternating tilt, like a real wala.
import numpy as np, math
from PIL import Image, ImageDraw, ImageFilter
def string(n=16, w=1440, h=150):
    im=Image.new('RGBA',(w,h),(0,0,0,0)); d=ImageDraw.Draw(im)
    cy=h*0.5
    for x in range(0,w,6):   # twisted fuse cord (part of the picture)
        y=cy+math.sin(x*0.25)*2
        d.ellipse([x-4,y-4,x+4,y+4],fill=(150,98,48) if (x//6)%2 else (196,140,70))
    pc=Image.open('art/crk/b0.webp').convert('RGBA'); pc=pc.crop(pc.getbbox())
    ch=int(h*0.46); pc=pc.resize((int(pc.width*ch/pc.height),ch),Image.LANCZOS)
    step=w/n
    for i in range(n):
        x=step*(i+0.5)
        for side,rot in ((-1,28),(1,-28)):
            p=pc.rotate(rot*(1 if i%2 else -1)*0.7+ (180 if side>0 else 0),Image.BICUBIC,expand=True)
            px=int(x-p.width/2+side*4); py=int(cy-p.height+8) if side<0 else int(cy-8)
            sh=Image.new('RGBA',im.size,(0,0,0,0)); sh.paste((40,10,0,255),(px+3,py+5),p.split()[3].point(lambda v:int(v*0.35)))
            im.alpha_composite(sh.filter(ImageFilter.GaussianBlur(3))); im.alpha_composite(p,(px,py))
    return im
if __name__=='__main__':
    s=string(); s.save('art/fx/wala_string.png'); print(s.size)
