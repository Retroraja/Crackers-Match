# 27 Nov: app icon = a 3x3 cut of our real board: cream checker cells, gold frame, our board pieces,
# special crackers in between (rocket, matchbox) and a row of three reds (the match).
import numpy as np
from PIL import Image, ImageDraw, ImageFilter
S=1024
def pc(i,h):
    a=Image.open('art/crk/b%d.webp'%i).convert('RGBA'); a=a.crop(a.getbbox()); k=h/max(a.size)
    return a.resize((int(a.width*k),int(a.height*k)),Image.LANCZOS)
im=Image.new('RGBA',(S,S),(0,0,0,0)); d=ImageDraw.Draw(im)
# gold frame with a thin navy line inside (as on the board)
d.rounded_rectangle([0,0,S-1,S-1],120,fill=(232,160,40))
d.rounded_rectangle([14,14,S-15,S-15],108,fill=(255,200,80))
d.rounded_rectangle([34,34,S-35,S-35],92,fill=(24,40,90))
m=44; n=3; cs=(S-2*m)/n
cells=Image.new('RGBA',(S,S),(0,0,0,0)); cd=ImageDraw.Draw(cells)
for r in range(n):
    for c in range(n):
        col=(239,227,198) if (r+c)%2 else (248,240,220)
        cd.rectangle([m+c*cs,m+r*cs,m+(c+1)*cs,m+(r+1)*cs],fill=col)
mask=Image.new('L',(S,S),0); ImageDraw.Draw(mask).rounded_rectangle([m,m,S-m-1,S-m-1],84,fill=255)
im.paste(cells,(0,0),Image.composite(cells,Image.new('RGBA',(S,S)),mask).split()[3])
grid=[[1,6,2],[0,0,0],[2,14,1]]   # blue, ROCKET, green / red red red / green, MATCHBOX, blue
glow=Image.new('RGBA',(S,S),(0,0,0,0)); ImageDraw.Draw(glow).rounded_rectangle([m+10,m+cs+18,S-m-10,m+2*cs-18],60,fill=(255,210,90,150))
im.alpha_composite(glow.filter(ImageFilter.GaussianBlur(28)))
for r in range(n):
    for c in range(n):
        k=grid[r][c]; p=pc(k,int(cs*(0.86 if k>=6 else 0.80)))
        x=int(m+c*cs+cs/2-p.width/2); y=int(m+r*cs+cs/2-p.height/2)
        sh=Image.new('RGBA',(S,S),(0,0,0,0)); sh.paste((60,30,10,255),(x+6,y+14),p.split()[3].point(lambda v:int(v*0.35)))
        im.alpha_composite(sh.filter(ImageFilter.GaussianBlur(10))); im.alpha_composite(p,(x,y))
# a few sparkles on the matched row
sp=Image.new('RGBA',(S,S),(0,0,0,0)); sd=ImageDraw.Draw(sp)
for (x,y,rr) in [(0.30,0.36,14),(0.70,0.38,12),(0.52,0.62,11)]:
    x*=S;y*=S; sd.polygon([(x,y-rr*2.4),(x+rr*0.5,y-rr*0.5),(x+rr*2.4,y),(x+rr*0.5,y+rr*0.5),(x,y+rr*2.4),(x-rr*0.5,y+rr*0.5),(x-rr*2.4,y),(x-rr*0.5,y-rr*0.5)],fill=(255,250,220,255))
im.alpha_composite(sp)
out=im.resize((512,512),Image.LANCZOS); out.save('/tmp/icon512.png')
pv=Image.new('RGB',(512+40+200+20+96+20+48,560),(240,240,245)); pv.paste(out,(0,24),out)
for i,(sz,shape) in enumerate([(200,'circle'),(96,'round'),(48,'round')]):
    t=out.resize((sz,sz),Image.LANCZOS); mk=Image.new('L',(sz,sz),0); md=ImageDraw.Draw(mk)
    if shape=='circle': md.ellipse([0,0,sz-1,sz-1],fill=255)
    else: md.rounded_rectangle([0,0,sz-1,sz-1],int(sz*0.22),fill=255)
    mk=Image.composite(mk,Image.new('L',(sz,sz),0),t.split()[3])
    pv.paste(t.convert('RGB'),(552+[0,220,336][i],200),mk)
pv.save('/tmp/icon_preview.png')
