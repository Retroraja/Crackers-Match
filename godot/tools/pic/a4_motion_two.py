import math, random, os, subprocess, sys
import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont
G='/home/user/crackers-match/godot/'
diya=Image.open(G+'art/ui-diya.webp').convert('RGBA'); coin=Image.open(G+'art/ui-coin.webp').convert('RGBA')
def icon(im,ic,x,y,s):
    i=ic.copy(); i.thumbnail((s,s)); im.alpha_composite(i,(int(x),int(y)))
def F_(n): return ImageFont.truetype(G+'art/LilitaOne.ttf',n)
V='/tmp/claude-0/s/vid/'; D='/tmp/claude-0/s/v2/'
W,H=540,1170
def L(p): return Image.open(p).convert('RGBA').resize((W,H),Image.LANCZOS)
plain=L(V+'t_plain.png'); vanbg=L(V+'t_van.png'); hall=L(V+'h_plain.png')
st=[plain]+[L(D+'f%d.png'%k) for k in (1,2,3,4)]
drv=[D+'drv/d%04d.png'%i for i in range(75)]
# van sticker
a=np.asarray(vanbg).astype(int); b=np.asarray(plain).astype(int)
m=(np.abs(a-b).sum(2)>30).astype(np.uint8)*255
m[:int(0.47*H),:]=0; m[int(0.8*H):,:]=0; m[:,:int(0.38*W)]=0
mask=Image.fromarray(m).filter(ImageFilter.MaxFilter(3)).filter(ImageFilter.GaussianBlur(0.8))
bb=mask.getbbox(); van=vanbg.copy(); van.putalpha(mask); van=van.crop(bb); VX,VY=bb[0],bb[1]
# pop layers
layers=[]
for k in range(1,5):
    a=np.asarray(st[k]).astype(int); b=np.asarray(st[k-1]).astype(int)
    mm=(np.abs(a-b).sum(2)>36).astype(np.uint8)*255
    mk=Image.fromarray(mm).filter(ImageFilter.MaxFilter(3))
    lb=mk.getbbox(); ly=st[k].copy(); ly.putalpha(mk); layers.append((ly.crop(lb),lb))
TC=(115,330)  # temple centre on screen
def ui(im,glow=0,tap=None,cap=None,lv='Level 85'):
    d=ImageDraw.Draw(im)
    def pill(box,fill,r=22,ol='#7a3a00'): d.rounded_rectangle(box,r,fill=fill,outline=ol,width=3)
    pill((15,35,165,80),'#fff4d6'); icon(im,coin,20,39,38); d.text((112,58),'12,450',font=F_(26),fill='#ffd23a',anchor='mm',stroke_width=3,stroke_fill='#3a1a00')
    pill((375,35,525,80),'#fff4d6'); icon(im,diya,380,37,40); d.text((472,58),'3',font=F_(28),fill='#ffd23a',anchor='mm',stroke_width=3,stroke_fill='#3a1a00')
    pill((145,95,395,140),'#d8262e'); d.text((270,118),'GHILLI Deliveries',font=F_(25),fill='white',anchor='mm',stroke_width=3,stroke_fill='#3a1a00')
    pill((150,1050,390,1125),'#2fb34a',36,'#14561f'); d.text((270,1088),lv,font=F_(38),fill='white',anchor='mm',stroke_width=4,stroke_fill='#3a1a00')
    pill((410,1055,525,1120),'#ffd75a' if glow else '#ffb31a',30); d.text((467,1088),'Build',font=F_(26),fill='white',anchor='mm',stroke_width=3,stroke_fill='#3a1a00')
    if tap:
        x,y,k=tap; r=int(18+30*k)
        d.ellipse((x-r,y-r,x+r,y+r),outline=(255,255,255,int(255*(1-k))),width=5)
        d.ellipse((x-14,y-14,x+14,y+14),fill=(255,255,255,200))
    if cap:
        f=F_(26); w=d.textlength(cap,font=f)+40
        d.rounded_rectangle(((W-w)/2,960,(W+w)/2,1010),22,fill=(30,20,10,190)); d.text((W/2,986),cap,font=f,fill='white',anchor='mm')
def star(d,x,y,s,a):
    d.polygon([(x,y-s),(x+s*.3,y-s*.3),(x+s,y),(x+s*.3,y+s*.3),(x,y+s),(x-s*.3,y+s*.3),(x-s,y),(x-s*.3,y-s*.3)],fill=(255,240,150,int(255*a)))
def ease(t): t=max(0,min(1,t)); return t*t*(3-2*t)
def back(t):  # overshoot 0->1
    t=max(0,min(1,t)); c=1.9; return 1+(c+1)*(t-1)**3+c*(t-1)**2
random.seed(4)
fw=[(random.uniform(0,6.28),random.uniform(60,160),random.choice(['#ffd23a','#ff5a3a','#7fe0ff','#ffffff','#ff8ad8'])) for _ in range(40)]
def build_part(im,t,t0):
    # 4 pops, 0.55s apart, then firework at t0+2.4
    base=st[0]
    for k in range(4):
        tk=t-(t0+k*0.55)
        if tk<0: break
        ly,lb=layers[k]; s=0.4+0.6*back(tk/0.4)
        w,h=ly.size; cx=(lb[0]+lb[2])/2; cy=lb[3]
        lv=ly.resize((max(1,int(w*s)),max(1,int(h*s))),Image.LANCZOS)
        if tk<0.25: lv.putalpha(lv.getchannel('A').point(lambda v:int(v*tk/0.25)))
        im.alpha_composite(lv,(int(cx-lv.width/2),int(cy-lv.height)))
        if tk<0.5:
            d=ImageDraw.Draw(im)
            for j in range(8):
                ang=j*0.785; r=20+90*tk
                star(d,cx+math.cos(ang)*r*0.8,(lb[1]+lb[3])/2+math.sin(ang)*r*0.6,9*(1-tk*2),1-tk*2)
    tf=t-(t0+2.4)
    if 0<tf<1.3:
        d=ImageDraw.Draw(im)
        for (ang,v,c) in fw:
            r=v*ease(tf/0.8); x=TC[0]+math.cos(ang)*r; y=TC[1]-40+math.sin(ang)*r+30*tf*tf
            al=max(0,1-tf/1.3); col=tuple(int(c[i:i+2],16) for i in (1,3,5))+(int(255*al),)
            d.ellipse((x-4,y-4,x+4,y+4),fill=col)
def twinkle(im,t):
    d=ImageDraw.Draw(im); random.seed(9)
    for _ in range(18):
        x=random.uniform(40,230); y=random.uniform(160,420); ph=random.uniform(0,6.3)
        a_=max(0,math.sin(t*5+ph)); 
        if a_>0.2: star(d,x,y,8*a_,a_)
def put_van(im,dx=0,dy=0,s=1.0):
    vw,vh=van.size; vv=van if s==1 else van.resize((int(vw*s),int(vh*s)),Image.LANCZOS)
    im.alpha_composite(vv,(int(VX+vw/2-vv.width/2+dx),int(VY+vh/2-vv.height/2+dy)))
def frames(name,T,fn):
    out=D+'fr_'+name; os.makedirs(out,exist_ok=True)
    for f in os.listdir(out): os.remove(out+'/'+f)
    for i in range(int(T*30)):
        im=fn(i/30.0); im.convert('RGB').save(out+'/%04d.jpg'%i,quality=92)
    subprocess.run(['ffmpeg','-v','error','-y','-framerate','30','-i',out+'/%04d.jpg','-c:v','libx264','-pix_fmt','yuv420p','-crf','20','-movflags','+faststart','/mnt/project-files/crackers/area4-preview/area4-%s.mp4'%name],check=True)
# ---------------- SIMPLE: still pictures, pop-in only, fade to next stop
def simple(t):
    if t<6.6:
        im=st[0].copy()
        if t>=3.0: build_part(im,t,3.0)
        if t>=5.0: twinkle(im,t)
        put_van(im)
    elif t<7.4:
        a=st[4].copy(); put_van(a); twinkle(a,t)
        b=hall.copy(); put_van(b)
        im=Image.blend(a,b,ease((t-6.6)/0.8))
    else:
        im=hall.copy(); put_van(im)
    cap=None; tap=None; glow=0
    if t<2.4: cap='SIMPLE: play levels, van waits'
    if 2.3<t<3.0: tap=(467,1088,(t-2.3)/0.7); glow=1
    if 3.0<=t<6.6: cap='Build: Temple Festival!'
    if t>=7.6: cap='Next stop: Wedding Hall'
    ui(im,glow,tap,cap); return im
# ---------------- PRO: engine shake, pop-in, 3D drive clip, arrival
def shake(t): return (math.sin(t*61)*0.8, math.sin(t*4.5)*1.6+math.sin(t*47)*0.7)
def pro(t):
    if t<6.6:
        im=st[0].copy()
        if t>=3.0: build_part(im,t,3.0)
        if t>=5.0: twinkle(im,t)
        dx,dy=shake(t); put_van(im,dx,dy)
    elif t<6.6+2.5:
        i=min(74,int((t-6.6)*30)); im=Image.open(drv[i]).convert('RGBA')
        if i<3: twinkle(im,t)
    elif t<9.1+0.5:
        a=Image.open(drv[74]).convert('RGBA'); b=hall.copy()
        im=Image.blend(a,b,ease((t-9.1)/0.5))
    else:
        im=hall.copy(); k=ease((t-9.6)/1.1); dx,dy=shake(t)
        put_van(im,dx,(1-k)*520+dy,1.0+0.18*(1-k))
    cap=None; tap=None; glow=0
    if t<2.4: cap='PRO: van engine running, waits'
    if 2.3<t<3.0: tap=(467,1088,(t-2.3)/0.7); glow=1
    if 3.0<=t<6.6: cap='Build: Temple Festival!'
    if 6.6<=t<9.6: cap='Off to the next stop...'
    if t>=10.0: cap='Next stop: Wedding Hall'
    ui(im,glow,tap,cap); return im
which=sys.argv[1]
if which=='simple': frames('motion-simple',10.0,simple)
else: frames('motion-pro',13.0,pro)
print('done',which)
