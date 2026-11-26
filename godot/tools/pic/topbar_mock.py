# 26 Nov: premium top bar mockup (like his Royal Match ref): cream Canva pills, big icons half outside, gear, profile
import sys; sys.path.insert(0,'tools/pic'); import wheel_build as WB
from PIL import Image, ImageDraw, ImageFont, ImageFilter
import numpy as np
S=2; W,H=390*S,844*S
F=lambda n: ImageFont.truetype('art/LilitaOne.ttf',int(n*S))
bg=Image.open('/tmp/home_shot.png').convert('RGBA'); bg=bg.resize((W,int(bg.height*W/bg.width)),Image.LANCZOS).crop((0,0,W,H))
# hide the old bar: copy the trees just below it up over it
patch=bg.crop((0,66*S,W,76*S)).resize((W,70*S),Image.BICUBIC).filter(ImageFilter.GaussianBlur(6*S)); mk=Image.fromarray((np.clip((70*S-np.arange(70*S))/(14*S),0,1)[:,None]*np.ones((1,W))*255).astype(np.uint8)); bg.paste(patch,(0,0),mk)
im=bg
fade=Image.new('RGBA',(W,H),(0,0,0,0)); a=np.zeros((H,W,4),np.uint8); g=np.clip(1-np.arange(H)/(110*S),0,1)**1.4*150; a[...,2]=20; a[...,3]=g[:,None]; im.alpha_composite(Image.fromarray(a))
pill=WB.cut('art/topbar/pill_src.png'); gear=WB.cut('art/topbar/gear_src.png')
def icon(p,sz):
    a=Image.open(p).convert('RGBA'); a=a.crop(a.getbbox()); k=sz/max(a.size); return a.resize((int(a.width*k),int(a.height*k)),Image.LANCZOS)
def shadow(img,dy=3):
    s=Image.new('RGBA',img.size,(0,0,0,0)); s.putalpha(img.getchannel('A').point(lambda v:v*0.45)); return s.filter(ImageFilter.GaussianBlur(2*S))
def put(img,x,y,sh=True):
    if sh: im.alpha_composite(shadow(img),(int(x),int(y+3*S)))
    im.alpha_composite(img,(int(x),int(y)))
Y=40  # bar centre line (pt)
# profile in a gold frame
d=ImageDraw.Draw(im); px,py,ps=10,Y-4-22,48
fr=Image.new('RGBA',(ps*S,ps*S),(0,0,0,0)); fd=ImageDraw.Draw(fr)
fd.rounded_rectangle([0,0,ps*S-1,ps*S-1],10*S,fill=(232,176,48)); fd.rounded_rectangle([3*S,3*S,ps*S-3*S,ps*S-3*S],8*S,fill=(255,226,120))
fd.rounded_rectangle([5*S,5*S,ps*S-5*S,ps*S-5*S],7*S,fill=(70,120,200))
put(fr,px*S,py*S); av=icon('art/crk/b10.webp',34*S); put(av,(px+ps/2)*S-av.width/2,(py+ps/2)*S-av.height/2,False)
def pillbox(x,w,ic,txt,badge=None):
    p=pill.resize((w*S,int(34*S)),Image.LANCZOS); put(p,x*S,(Y+4-17)*S)
    d=ImageDraw.Draw(im); d.text(((x+w/2+12)*S,(Y+4)*S),txt,font=F(19),fill=(28,40,92),anchor='mm')
    i=icon(ic,46*S); put(i,(x-14)*S,(Y+4)*S-i.height/2)
    if badge: d.text(((x+9)*S,(Y+5)*S),badge,font=F(20),fill='white',anchor='mm',stroke_width=3*S,stroke_fill=(120,10,30))
pillbox(84,104,'art/ui-coin.webp','55585')
pillbox(214,104,'art/web/fe-heart.png','Full','5')
# plus on coin
pl=Image.new('RGBA',(18*S,18*S),(0,0,0,0)); pd=ImageDraw.Draw(pl); pd.ellipse([0,0,18*S-1,18*S-1],fill=(255,255,255)); pd.ellipse([2*S,2*S,16*S,16*S],fill=(46,170,60))
pd.text((9*S,8.5*S),'+',font=F(16),fill='white',anchor='mm'); put(pl,(84+10)*S,(Y+14)*S,False)
gr=gear.resize((46*S,46*S),Image.LANCZOS); put(gr,(390-10-46)*S,(Y+4-23)*S)
im.convert('RGB').save('../previews/top-bar.png')
im.crop((0,0,W,260*S)).convert('RGB').save('/tmp/tb.png')
