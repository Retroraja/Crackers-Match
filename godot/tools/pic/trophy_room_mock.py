# 26 Nov: Trophy Room page mockup (royal blue theme, clean style)
import numpy as np
from PIL import Image, ImageDraw, ImageFont, ImageFilter
S=3; W,H=390*S,844*S
F=lambda n: ImageFont.truetype('art/LilitaOne.ttf',int(n*S))
def vgrad(w,h,stops):
    a=np.zeros((h,w,4),np.float32); ys=np.linspace(0,1,h)
    for c in range(3): a[:,:,c]=np.interp(ys,[s[0] for s in stops],[s[1][c] for s in stops])[:,None]
    a[:,:,3]=255; return Image.fromarray(a.astype(np.uint8))
def shade(c,k): return tuple(max(0,min(255,int(v*k))) for v in c)
def rrm(w,h,r): m=Image.new('L',(w,h),0); ImageDraw.Draw(m).rounded_rectangle([0,0,w-1,h-1],r,fill=255); return m
def card(im,box,r,fill,edge,t=4,shadow=True):
    x0,y0,x1,y1=[int(v*S) for v in box]; w,h=x1-x0,y1-y0
    if shadow:
        sh=Image.new('RGBA',im.size,(0,0,0,0)); sh.paste((0,0,0,110),(x0,y0+3*S),rrm(w,h,r*S)); im.alpha_composite(sh.filter(ImageFilter.GaussianBlur(3*S)))
    im.paste(vgrad(w,h,[(0,shade(edge,1.3)),(1,shade(edge,0.75))]),(x0,y0),rrm(w,h,r*S))
    T=t*S; im.paste(vgrad(w-2*T,h-2*T,fill),(x0+T,y0+T),rrm(w-2*T,h-2*T,max(1,(r-t)*S)))
def ribbon(im,cx,y,w,label,base,n=18):
    h=int(30*S); x0=int(cx*S-w*S/2); y0=int(y*S); ww=int(w*S)
    im.paste(vgrad(ww,h,[(0,shade(base,1.3)),(0.5,base),(1,shade(base,0.75))]),(x0,y0),rrm(ww,h,8*S))
    d=ImageDraw.Draw(im); d.rounded_rectangle([x0,y0,x0+ww,y0+h],8*S,outline=(255,170,40),width=int(2.5*S))
    d.text((cx*S,y0+h/2),label,font=F(n),fill=(255,246,220),anchor='mm',stroke_width=2*S,stroke_fill=shade(base,0.45))
def icon(im,path,box):
    a=Image.open(path).convert('RGBA'); a.thumbnail((int(box[2]*S),int(box[3]*S)),Image.LANCZOS)
    im.alpha_composite(a,(int(box[0]*S+(box[2]*S-a.width)/2),int(box[1]*S+(box[3]*S-a.height)/2)))
def trophy(im,x,y,sz,col):
    a=Image.open('art/web/fe-trophy.png').convert('RGBA').resize((int(sz*S),int(sz*S)),Image.LANCZOS)
    arr=np.array(a).astype(float); lum=arr[...,:3].mean(2,keepdims=True)/255
    tint={'bronze':(205,127,50),'silver':(200,205,215),'gold':(255,200,50),'none':(90,90,110)}[col]
    arr[...,:3]=np.clip(lum*np.array(tint)*1.35,0,255)
    if col=='none': arr[...,3]*=0.45
    im.alpha_composite(Image.fromarray(arr.astype(np.uint8)),(int(x*S),int(y*S)))
BASE=(32,78,160); CREAM=[(0,(255,250,228)),(1,(244,232,196))]
im=vgrad(W,H,[(0,(44,98,190)),(1,(24,60,140))]); d=ImageDraw.Draw(im)
# header
ribbon(im,195,22,230,'Trophy Room',BASE,26)
# shelf summary
card(im,[16,66,374,170],18,CREAM,shade(BASE,0.85),5)
d=ImageDraw.Draw(im)
d.text((195*S,84*S),'Your trophies',font=F(16),fill=shade(BASE,0.6),anchor='mm')
for i,(c,n) in enumerate([('gold',3),('silver',7),('bronze',12)]):
    x=60+i*110; trophy(im,x-22,96,44,c); d.text(((x+40)*S,120*S),'x%d'%n,font=F(24),fill=shade(BASE,0.55),anchor='mm')
d.text((195*S,158*S),'22 of 45 trophies',font=F(14),fill=(140,110,70),anchor='mm')
rows=[('art/web/ui-rocket-l.webp','Rocket Master','Fire 500 rockets',312,500,'silver','300'),
      ('art/web/fe-star.png','Star Collector','Earn 300 stars',300,300,'claim','500'),
      ('art/web/ui-chakra.webp','Chakra Spinner','Use 100 chakras',41,100,'bronze','100'),
      ('art/crk/b11.webp','Sparkler Fan','Make 50 sparklers',50,50,'gold','done'),
      ('art/web/ui-diya.webp','Builder','Finish Area 2',8,12,'none','500'),
      ('art/web/ui-flowerpot-l.webp','3-Star Hero','3-star 50 levels',31,50,'bronze','300')]
y=186
for ic,name,goal,cur,mx,tro,rew in rows:
    card(im,[16,y,374,y+88],16,CREAM,shade(BASE,0.85),4); d=ImageDraw.Draw(im)
    d.ellipse([28*S,(y+14)*S,88*S,(y+74)*S],fill=shade(BASE,1.1),outline=(255,170,40),width=3*S); icon(im,ic,[34,y+20,48,48])
    d.text((100*S,(y+22)*S),name,font=F(18),fill=shade(BASE,0.5),anchor='lm')
    d.text((100*S,(y+44)*S),goal,font=F(13),fill=(130,100,70),anchor='lm')
    bx0,by0,bw=100,y+58,170
    d.rounded_rectangle([bx0*S,by0*S,(bx0+bw)*S,(by0+16)*S],8*S,fill=shade(BASE,0.4))
    fw=max(16,int(bw*min(1,cur/mx)))
    im.paste(vgrad(fw*S,16*S,[(0,(150,230,110)),(1,(50,170,60))]),(bx0*S,by0*S),rrm(fw*S,16*S,8*S)); d=ImageDraw.Draw(im)
    d.text(((bx0+bw/2)*S,(by0+8)*S),'%d / %d'%(cur,mx),font=F(12),fill='white',anchor='mm',stroke_width=2*S,stroke_fill=(30,60,30))
    if tro=='claim':
        card(im,[282,y+22,364,y+66],22,[(0,(150,230,110)),(1,(50,170,60))],(255,170,40),3,False); d=ImageDraw.Draw(im)
        d.text((323*S,(y+44)*S),'Claim',font=F(18),fill='white',anchor='mm',stroke_width=2*S,stroke_fill=(20,90,20))
    elif rew=='done':
        trophy(im,300,y+10,46,'gold'); d.text((323*S,(y+76)*S),'Complete',font=F(11),fill=(60,140,60),anchor='mm')
    else:
        trophy(im,294,y+8,38,tro if tro!='none' else 'none')
        d.ellipse([334*S,(y+30)*S,348*S,(y+44)*S],fill=(255,200,50)); d.text((341*S,(y+64)*S),rew,font=F(13),fill=(150,100,30),anchor='mm')
        icon(im,'art/web/ui-coin.webp',[322,y+52,14,14]) if False else None
    y+=96
# bottom nav
d.rectangle([0,770*S,W,H],fill=(25,60,160)); d.line([(0,770*S),(W,770*S)],fill=(255,170,40),width=3*S)
for i,p in enumerate(['/tmp/s/areas_icon.png','art/web/fe-trophy.png','art/web/ic2-house.png','art/web/ui-chakra.webp','art/web/ui-rocket-l.webp']):
    x=i*78
    if i==1:
        d.rounded_rectangle([(x+2)*S,752*S,(x+76)*S,H],14*S,fill=(80,140,240),outline=(255,215,90),width=2*S); icon(im,p,[x+12,756,54,54])
        d.text(((x+39)*S,826*S),'Trophies',font=F(12),fill='white',anchor='mm',stroke_width=2*S,stroke_fill=(20,40,100))
    else: icon(im,p,[x+16,780,46,46])
im.convert('RGB').resize((780,1688),Image.LANCZOS).save('../previews/trophy-room.png')
