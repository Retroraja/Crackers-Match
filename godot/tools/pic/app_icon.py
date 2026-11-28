# 27 Nov: app icon = a 3x3 cut of our real board: cream checker cells, gold frame, our board pieces,
# special crackers in between (rocket, matchbox) and a row of three reds (the match).
import numpy as np
from PIL import Image, ImageDraw, ImageFilter
S=1024
def pc(i,h):
    # specials use their game tile (shiny gold frame + glow), as on the board
    a=Image.open(('art/crk/t%d.webp' if i>=6 else 'art/crk/b%d.webp')%i).convert('RGBA'); a=a.crop(a.getbbox()); k=h/max(a.size)
    return a.resize((int(a.width*k),int(a.height*k)),Image.LANCZOS)
im=Image.new('RGBA',(S,S),(0,0,0,0)); d=ImageDraw.Draw(im)
# gold frame with a thin navy line inside (as on the board)
d.rounded_rectangle([0,0,S-1,S-1],230,fill=(232,160,40))
d.rounded_rectangle([14,14,S-15,S-15],216,fill=(255,200,80))
d.rounded_rectangle([34,34,S-35,S-35],198,fill=(24,40,90))
m=44; n=3; cs=(S-2*m)/n
cells=Image.new('RGBA',(S,S),(0,0,0,0)); cd=ImageDraw.Draw(cells)
for r in range(n):
    for c in range(n):
        col=(239,227,198) if (r+c)%2 else (248,240,220)
        cd.rectangle([m+c*cs,m+r*cs,m+(c+1)*cs,m+(r+1)*cs],fill=col)
mask=Image.new('L',(S,S),0); ImageDraw.Draw(mask).rounded_rectangle([m,m,S-m-1,S-m-1],188,fill=255)
im.paste(cells,(0,0),Image.composite(cells,Image.new('RGBA',(S,S)),mask).split()[3])
import sys
sys.path.insert(0,'tools/pic')
NAME='--name' in sys.argv
grid=[[1,6,2],[0,0,0],[2,14,1]] if not NAME else [[None,None,None],[0,0,0],[6,14,1]]   # blue, ROCKET, green / red red red / green, MATCHBOX, blue
glow=Image.new('RGBA',(S,S),(0,0,0,0)); ImageDraw.Draw(glow).rounded_rectangle([m+10,m+cs+18,S-m-10,m+2*cs-18],60,fill=(255,255,255,110))
im.alpha_composite(glow.filter(ImageFilter.GaussianBlur(30)))
for r in range(n):
    for c in range(n):
        k=grid[r][c]
        if k is None: continue
        p=pc(k,int(cs*(0.96 if k>=6 else 0.72)))
        x=int(m+c*cs+cs/2-p.width/2); y=int(m+r*cs+cs/2-p.height/2)
        sh=Image.new('RGBA',(S,S),(0,0,0,0)); sh.paste((60,30,10,255),(x+6,y+14),p.split()[3].point(lambda v:int(v*0.35)))
        im.alpha_composite(sh.filter(ImageFilter.GaussianBlur(10))); im.alpha_composite(p,(x,y))
        if r==1 and c==1 and not NAME:
            # 27 Nov: the middle cracker is lit: a bright spark on its fuse and a few gold sparks
            pa=np.array(p.split()[3]); ys,xs=np.nonzero(pa>40); top=ys.min(); fx_=x+int(xs[ys<top+6].mean()); fy_=y+top
            fl=Image.open('art/fx/flash_gold.png').convert('RGBA').resize((190,190),Image.LANCZOS); im.alpha_composite(fl,(fx_-95,fy_-95))
            sd2=ImageDraw.Draw(im)
            for a_,l_ in [(-150,60),(-110,75),(-70,70),(-30,58),(-125,40),(-55,44)]:
                import math as _m; ex=fx_+_m.cos(_m.radians(a_))*l_; ey=fy_+_m.sin(_m.radians(a_))*l_
                sd2.line([(fx_+(ex-fx_)*0.45,fy_+(ey-fy_)*0.45),(ex,ey)],fill=(255,225,120),width=7); sd2.ellipse([ex-6,ey-6,ex+6,ey+6],fill=(255,250,220))
            sd2.ellipse([fx_-14,fy_-14,fx_+14,fy_+14],fill=(255,255,235))
# a few sparkles on the matched row
sp=Image.new('RGBA',(S,S),(0,0,0,0)); sd=ImageDraw.Draw(sp)
for (x,y,rr) in [(0.30,0.36,14),(0.70,0.38,12),(0.52,0.62,11)]:
    x*=S;y*=S; sd.polygon([(x,y-rr*2.4),(x+rr*0.5,y-rr*0.5),(x+rr*2.4,y),(x+rr*0.5,y+rr*0.5),(x,y+rr*2.4),(x-rr*0.5,y+rr*0.5),(x-rr*2.4,y),(x-rr*0.5,y-rr*0.5)],fill=(255,250,220,255))
im.alpha_composite(sp)
if NAME:
    from PIL import ImageFont
    def word(t,fs,cy):
        f=ImageFont.truetype('art/LilitaOne.ttf',fs); L=Image.new('RGBA',(S,S),(0,0,0,0)); ld=ImageDraw.Draw(L)
        ld.text((S/2,cy+10),t,font=f,anchor='mm',fill=(70,10,20,200),stroke_width=26,stroke_fill=(70,10,20,200))
        L=L.filter(ImageFilter.GaussianBlur(6)); im.alpha_composite(L)
        ld=ImageDraw.Draw(im); ld.text((S/2,cy),t,font=f,anchor='mm',fill=(255,255,255),stroke_width=22,stroke_fill=(150,20,40))
        G=Image.new('L',(S,S),0); ImageDraw.Draw(G).text((S/2,cy),t,font=f,anchor='mm',fill=255)
        gr=Image.new('RGBA',(S,S)); ga=np.zeros((S,S,4),np.uint8); yy=np.arange(S)[:,None]; t0=(yy-(cy-fs*0.45))/(fs*0.9)
        ga[...,0]=255; ga[...,1]=np.clip(235-120*t0,110,235).astype(np.uint8).repeat(S,1); ga[...,2]=np.clip(90-80*t0,0,90).astype(np.uint8).repeat(S,1); ga[...,3]=255
        im.paste(Image.fromarray(ga),(0,0),G)
        H=Image.new('L',(S,S),0); ImageDraw.Draw(H).text((S/2,cy-fs*0.05),t,font=f,anchor='mm',fill=90)
        hi=Image.new('RGBA',(S,S),(255,255,255,0)); hi.putalpha(Image.composite(H,Image.new('L',(S,S),0),Image.new('L',(S,S),0).point(lambda v:0)).point(lambda v:v))
        band=Image.new('L',(S,S),0); ImageDraw.Draw(band).rectangle([0,0,S,cy-fs*0.08],fill=255)
        hi.putalpha(Image.composite(H,Image.new('L',(S,S),0),band)); im.alpha_composite(hi)
    word('CRACKERS',150,m+cs*0.36)
    word('MATCH',150,m+cs*0.84)
if not NAME:
    # 27 Nov: gold Indian corner ornaments (Canva) on the frame corners
    import wheel_build as WB
    co=WB.cut('art/topbar/icon_corner_src.png'); k=230/max(co.size); co=co.resize((int(co.width*k),int(co.height*k)),Image.LANCZOS)
    for fl_ in range(4):
        t=co
        if fl_ in (1,3): t=t.transpose(Image.FLIP_LEFT_RIGHT)
        if fl_ in (2,3): t=t.transpose(Image.FLIP_TOP_BOTTOM)
        x=30 if fl_ in (0,2) else S-30-t.width; y=30 if fl_ in (0,1) else S-30-t.height
        sh=Image.new('RGBA',(S,S),(0,0,0,0)); sh.paste((40,20,0,255),(x+4,y+8),t.split()[3].point(lambda v:int(v*0.4))); im.alpha_composite(sh.filter(ImageFilter.GaussianBlur(6)))
        im.alpha_composite(t,(x,y))
out=im.resize((512,512),Image.LANCZOS); out.save('/tmp/icon512%s.png'%('_name' if NAME else ''))
pv=Image.new('RGB',(512+40+200+20+96+20+48,560),(240,240,245)); pv.paste(out,(0,24),out)
for i,(sz,shape) in enumerate([(200,'circle'),(96,'round'),(48,'round')]):
    t=out.resize((sz,sz),Image.LANCZOS); mk=Image.new('L',(sz,sz),0); md=ImageDraw.Draw(mk)
    if shape=='circle': md.ellipse([0,0,sz-1,sz-1],fill=255)
    else: md.rounded_rectangle([0,0,sz-1,sz-1],int(sz*0.22),fill=255)
    mk=Image.composite(mk,Image.new('L',(sz,sz),0),t.split()[3])
    pv.paste(t.convert('RGB'),(552+[0,220,336][i],200),mk)
pv.save('/tmp/icon_preview%s.png'%('_name' if NAME else ''))
