import math, random, subprocess, os
import numpy as np
from PIL import Image, ImageDraw, ImageFilter
exec(open('/tmp/claude-0/s/comp.py').read().split('# ---- screen 1')[0])
D='/tmp/claude-0/s/vid/'
W,H=540,1169
def L(n): return Image.open(D+n+'.png').convert('RGBA').resize((W,H),Image.LANCZOS)
van_full=L('t_van'); plain=L('t_plain'); fest=L('t_fest'); hall=L('h_plain')
a=np.asarray(van_full).astype(int); b=np.asarray(plain).astype(int)
m=(np.abs(a-b).sum(2)>30).astype(np.uint8)*255
m[:int(0.47*H),:]=0; m[int(0.8*H):,:]=0; m[:,:int(0.38*W)]=0
mask=Image.fromarray(m).filter(ImageFilter.MaxFilter(3)).filter(ImageFilter.GaussianBlur(0.8))
bbox=mask.getbbox()
van=van_full.copy(); van.putalpha(mask); van=van.crop(bbox)
vx,vy=bbox[0],bbox[1]; vw,vh=van.size
VP=(0.64*W,0.44*H)
os.makedirs(D+'fr',exist_ok=True)
for f in os.listdir(D+'fr'): os.remove(D+'fr/'+f)
F=30; T=12.5
random.seed(2)
spark=[(random.uniform(40,250),random.uniform(170,420),random.uniform(0,6.28),random.uniform(5,11)) for _ in range(26)]
def ui(im,build_glow=0,tap=None,cap=None):
    # scaled-down UI (comp.py draws at 1080 wide) -> draw on 2x canvas then shrink would be slow; draw simple at half size
    d=ImageDraw.Draw(im)
    def pill2(box,fill,r=22,ol='#7a3a00'):
        d.rounded_rectangle(box,r,fill=fill,outline=ol,width=3)
    pill2((15,35,165,80),'#fff4d6'); icon(im,coin,20,39,38); d.text((112,58),'12,450',font=F_(26),fill='#ffd23a',anchor='mm',stroke_width=3,stroke_fill='#3a1a00')
    pill2((375,35,525,80),'#fff4d6'); icon(im,diya,380,37,40); d.text((472,58),'3',font=F_(28),fill='#ffd23a',anchor='mm',stroke_width=3,stroke_fill='#3a1a00')
    pill2((145,95,395,140),'#d8262e'); d.text((270,118),'GHILLI Deliveries',font=F_(25),fill='white',anchor='mm',stroke_width=3,stroke_fill='#3a1a00')
    pill2((150,1050,390,1125),'#2fb34a',36,'#14561f'); d.text((270,1088),'Level 85',font=F_(38),fill='white',anchor='mm',stroke_width=4,stroke_fill='#3a1a00')
    g='#ffd75a' if build_glow else '#ffb31a'
    pill2((410,1055,525,1120),g,30); d.text((467,1088),'Build',font=F_(26),fill='white',anchor='mm',stroke_width=3,stroke_fill='#3a1a00')
    if tap:
        x,y,k=tap; r=int(18+30*k)
        d.ellipse((x-r,y-r,x+r,y+r),outline=(255,255,255,int(255*(1-k))),width=5)
        d.ellipse((x-14,y-14,x+14,y+14),fill=(255,255,255,200))
    if cap:
        f=F_(26); w=d.textlength(cap,font=f)+40
        d.rounded_rectangle(((W-w)/2,960,(W+w)/2,1010),22,fill=(30,20,10,190))
        d.text((W/2,986),cap,font=f,fill='white',anchor='mm')
def F_(n): return ImageFont.truetype(G+'art/LilitaOne.ttf',n)
def ease(t): return t*t*(3-2*t)
for i in range(int(F*T)):
    t=i/F
    cap=None; tap=None; glow=0
    # background
    if t<3.6: bg=plain.copy()
    elif t<4.6: bg=Image.blend(plain,fest,ease((t-3.6)/1.0))
    elif t<8.6: bg=fest.copy()
    elif t<9.2: bg=Image.blend(fest,hall,ease((t-8.6)/0.6))
    else: bg=hall.copy()
    im=bg
    # van
    bob=math.sin(t*5.0)*2.0
    if t<6.4 or t>=9.2:
        s=1.0; cx,cy=vx+vw/2, vy+vh/2+bob
        if t>=9.2:
            k=ease(min(1,(t-9.2)/1.0)); cy=vy+vh/2+(1-k)*500+bob; s=1.0+0.15*(1-k)
    elif t<8.6:
        k=ease((t-6.4)/2.2)
        s=1-0.9*k; cx=(vx+vw/2)*(1-k)+VP[0]*k; cy=(vy+vh/2)*(1-k)+VP[1]*k
    else:
        s=None
    if s:
        vv=van.resize((max(1,int(vw*s)),max(1,int(vh*s))),Image.LANCZOS)
        im.alpha_composite(vv,(int(cx-vv.width/2),int(cy-vv.height/2)))
        if 6.4<=t<7.6:
            d=ImageDraw.Draw(im); k=(t-6.4)/1.2
            for j in range(5):
                rr=int(6+16*k)+j*2; x=vx+vw/2+(j-2)*28; y=vy+vh+5-j*3
                d.ellipse((x-rr,y-rr*0.6,x+rr,y+rr*0.6),fill=(200,190,170,int(90*(1-k))))
    # sparkles on temple
    if 3.9<t<8.8:
        d=ImageDraw.Draw(im)
        for (x,y,ph,sz) in spark:
            a_=max(0,math.sin(t*6+ph)); s2=sz*a_
            if s2>1: d.polygon([(x,y-s2),(x+s2*.3,y-s2*.3),(x+s2,y),(x+s2*.3,y+s2*.3),(x,y+s2),(x-s2*.3,y+s2*.3),(x-s2,y),(x-s2*.3,y-s2*.3)],fill=(255,246,170,int(255*a_)))
    if t<3.0: cap='Play levels. The van waits here.'
    if 2.9<t<3.6: tap=(467,1088,(t-2.9)/0.7); glow=1
    if 3.6<=t<6.4: cap='Build: Temple Festival!'
    if 6.4<=t<9.2: cap='Off to the next stop...'
    if t>=9.6: cap='Next stop: Wedding Hall'
    ui(im,glow,tap,cap)
    im.convert('RGB').save(D+'fr/%04d.jpg'%i,quality=92)
print('frames',i)
