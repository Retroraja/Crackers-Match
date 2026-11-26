import numpy as np
from PIL import Image, ImageDraw, ImageFont, ImageFilter, ImageChops
S=3; W,H=390*S,250*S
F=lambda n: ImageFont.truetype('art/LilitaOne.ttf',int(n*S))
now=Image.open('/tmp/s/lv16.png').convert('RGBA').crop((0,0,390,250)).resize((W,H),Image.LANCZOS)
def vgrad(w,h,stops):
    a=np.zeros((h,w,4),np.float32); ys=np.linspace(0,1,h)
    for c in range(3): a[:,:,c]=np.interp(ys,[s[0] for s in stops],[s[1][c] for s in stops])[:,None]
    a[:,:,3]=255; return Image.fromarray(a.astype(np.uint8))
def shade(c,k): return tuple(max(0,min(255,int(v*k))) for v in c)
def rrm(w,h,r): m=Image.new('L',(w,h),0); ImageDraw.Draw(m).rounded_rectangle([0,0,w-1,h-1],r,fill=255); return m
def archm(w,h,r): 
    m=Image.new('L',(w,h),0); d=ImageDraw.Draw(m); d.ellipse([0,0,w-1,w-1],fill=255); d.rounded_rectangle([0,w//2,w-1,h-1],r,fill=255); return m
def bevel(im,x0,y0,w,h,mfun,r,outer,inner_fill,t):
    # thick soft 3D rim (outer gradient) and inner fill
    sh=Image.new('RGBA',im.size,(0,0,0,0)); sh.paste((0,0,0,120),(x0,y0+int(3*S)),mfun(w,h,r)); im.alpha_composite(sh.filter(ImageFilter.GaussianBlur(3*S)))
    rim=vgrad(w,h,[(0,shade(outer,1.35)),(0.5,outer),(1,shade(outer,0.7))]); im.paste(rim,(x0,y0),mfun(w,h,r))
    T=int(t*S); iw,ih=w-2*T,h-2*T
    inn=vgrad(iw,ih,inner_fill); im.paste(inn,(x0+T,y0+T),mfun(iw,ih,max(1,r-T)))
    # inner shadow on top
    s2=Image.new('RGBA',(iw,ih),(0,0,0,0)); ImageDraw.Draw(s2).rectangle([0,0,iw,int(6*S)],fill=(0,0,0,60))
    s2=s2.filter(ImageFilter.GaussianBlur(3*S)); m=mfun(iw,ih,max(1,r-T)); tmp=Image.new('RGBA',(iw,ih),(0,0,0,0)); tmp.paste(s2,(0,0),m); im.alpha_composite(tmp,(x0+T,y0+T))
def ribbon(im,cx,y,w,label,base):
    h=int(28*S); x0=int(cx*S-w*S/2); y0=int(y*S); ww=int(w*S)
    body=vgrad(ww,h,[(0,shade(base,1.3)),(0.5,base),(1,shade(base,0.75))])
    im.paste(body,(x0,y0),rrm(ww,h,int(8*S)))
    d=ImageDraw.Draw(im); d.rounded_rectangle([x0,y0,x0+ww,y0+h],int(8*S),outline=(255,170,40),width=int(2.5*S))
    d.text((cx*S,y0+h/2),label,font=F(18),fill=(255,246,220),anchor='mm',stroke_width=int(2*S),stroke_fill=shade(base,0.45))
def bar(base,name):
    im=now.copy(); d=ImageDraw.Draw(im)
    top=Image.new('RGBA',(W,int(150*S)),base+(255,)); im.paste(top,(0,0))
    d=ImageDraw.Draw(im); d.rectangle([0,int(150*S),W,int(154*S)],fill=(255,170,40))
    CREAM=[(0,(255,250,228)),(1,(244,232,196))]
    for cx,lab in [(66,'Target'),(324,'Moves')]:
        bevel(im,int((cx-56)*S),int(46*S),int(112*S),int(96*S),rrm,int(14*S),shade(base,0.85),CREAM,5)
        ribbon(im,cx,34,96,lab,shade(base,1.05))
    d=ImageDraw.Draw(im)
    a=Image.open('art/web/crate.webp').convert('RGBA'); a.thumbnail((int(48*S),int(48*S))); im.alpha_composite(a,(int(42*S),int(66*S)))
    d.text((86*S,120*S),'16',font=F(22),fill=(255,250,230),anchor='mm',stroke_width=int(3*S),stroke_fill=shade(base,0.4))
    d.text((324*S,96*S),'23',font=F(44),fill=(255,250,230),anchor='mm',stroke_width=int(4*S),stroke_fill=shade(base,0.4))
    # arch portrait with thick gold-orange bevel
    bevel(im,int(133*S),int(8*S),int(124*S),int(136*S),archm,int(16*S),(255,165,40),[(0,shade(base,1.25)),(1,shade(base,0.8))],6)
    manc=now.crop((144*S,16*S,246*S,128*S)); mk=archm(manc.width,manc.height,int(10*S))
    im.paste(manc,(144*S,int(22*S)),mk)
    # cracker meter in the area's colour, under the gold line with a gap (no overlap)
    bgs=now.crop((0,int(154*S),W,int(204*S))).filter(ImageFilter.GaussianBlur(40*S)); im.paste(bgs,(0,int(154*S)))
    mx0,my0,mw,mh=int(56*S),int(164*S),int(250*S),int(34*S)
    bevel(im,mx0,my0,mw,mh,rrm,int(17*S),(255,170,40),[(0,shade(base,1.2)),(1,shade(base,0.85))],3)
    d=ImageDraw.Draw(im); d.text((112*S,181*S),'Cracker meter',font=F(15),fill=(255,246,220),anchor='mm',stroke_width=int(2*S),stroke_fill=shade(base,0.45))
    d.rounded_rectangle([172*S,173*S,292*S,189*S],8*S,fill=shade(base,0.45))
    fl=vgrad(int(76*S),int(16*S),[(0,(255,225,120)),(1,(255,140,30))]); im.paste(fl,(172*S,173*S),rrm(int(76*S),int(16*S),int(8*S)))
    bevel(im,int(290*S),int(158*S),int(46*S),int(46*S),lambda w,h,r: (lambda m:(ImageDraw.Draw(m).ellipse([0,0,w-1,h-1],fill=255),m)[1])(Image.new('L',(w,h),0)),0,(255,170,40),[(0,shade(base,1.25)),(1,shade(base,0.8))],4)
    a=Image.open('art/web/ui-rocket-l.webp').convert('RGBA'); a.thumbnail((int(30*S),int(34*S))); im.alpha_composite(a,(int(313*S-a.width/2),int(181*S-a.height/2)))
    d=ImageDraw.Draw(im)
    return im

import numpy as np
full=np.array(Image.open('/tmp/s/lv16f.png').convert('RGB')).astype(np.int32)
def board(base):
    a=full.copy()
    m1=np.abs(a-[206,198,236]).sum(2)<30; m2=np.abs(a-[220,214,242]).sum(2)<30
    a[m1]=[240,228,200]; a[m2]=[250,242,222]
    r,g,bb=a[...,0],a[...,1],a[...,2]
    dark=(bb>r+15)&(bb>g+30)&(bb<140)&(r+g+bb<330)
    a[dark]=(np.array(shade(base,0.55))[None,:]*( (r[dark]+g[dark]+bb[dark])[:,None]/150.0)).clip(0,255)
    img=Image.fromarray(a.astype(np.uint8)).resize((W,844*S),Image.LANCZOS).convert('RGBA')
    return img
def screen(base,name):
    top=bar(base,name)
    b=board(base)
    b.paste(top.crop((0,0,W,int(204*S))),(0,0))
    ImageDraw.Draw(b).text((12*S,810*S),name,font=F(22),fill='white',stroke_width=int(3*S),stroke_fill=(0,0,0))
    return b

V=[((32,78,160),'1 Royal blue'),((112,18,36),'2 Deep maroon'),((16,96,120),'3 Peacock teal'),((18,30,72),'4 Midnight navy'),((160,16,40),'5 Ruby red'),((70,20,100),'6 Imperial purple'),((20,60,150),'7 Sapphire blue'),((14,70,44),'8 Bottle green'),((90,14,40),'9 Burgundy wine'),((36,30,110),'10 Deep indigo')]
import json
ims=[]
for c,n in V:
    im=screen(c,n).convert('RGB'); ims.append(im)
    im.resize((390*2,844*2),Image.LANCZOS).save('../previews/themes/theme-%02d-%s.png'%(int(n.split()[0]),'-'.join(n.split()[1:]).lower()))
WW=390*S
for k in range(2):
    out=Image.new('RGB',(5*WW+4*16*S,844*S),(15,8,25))
    for i,im in enumerate(ims[k*5:k*5+5]): out.paste(im,(i*(WW+16*S),0))
    out.resize((out.width//4,out.height//4),Image.LANCZOS).save('/tmp/s/themes-%d.png'%(k+1))
json.dump([{"n":n,"rgb":c} for c,n in V],open('../previews/themes/themes.json','w'),indent=1)
