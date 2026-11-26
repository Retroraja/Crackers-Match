# 26 Nov: Lucky Wheel page mockup (royal blue theme), premium wheel art from Canva + our prize icons
import math, numpy as np
from PIL import Image, ImageDraw, ImageFont, ImageFilter, ImageEnhance
from scipy import ndimage
S=2; W,H=390*S,844*S
F=lambda n: ImageFont.truetype('art/LilitaOne.ttf',int(n*S))
def vgrad(w,h,stops):
    a=np.zeros((h,w,4),np.float32); ys=np.linspace(0,1,h)
    for c in range(3): a[:,:,c]=np.interp(ys,[s[0] for s in stops],[s[1][c] for s in stops])[:,None]
    a[:,:,3]=255; return Image.fromarray(a.astype(np.uint8))
def shade(c,k): return tuple(max(0,min(255,int(v*k))) for v in c)
def rrm(w,h,r): m=Image.new('L',(w,h),0); ImageDraw.Draw(m).rounded_rectangle([0,0,w-1,h-1],r,fill=255); return m
def btn(im,box,top,bot,label,n=24,sub=None):
    x0,y0,x1,y1=[int(v*S) for v in box]; w,h=x1-x0,y1-y0
    sh=Image.new('RGBA',im.size,(0,0,0,0)); sh.paste((0,0,0,120),(x0,y0+4*S),rrm(w,h,h//2)); im.alpha_composite(sh.filter(ImageFilter.GaussianBlur(3*S)))
    im.paste(vgrad(w,h,[(0,(255,215,90)),(1,(200,130,20))]),(x0,y0),rrm(w,h,h//2))
    T=4*S; im.paste(vgrad(w-2*T,h-2*T,[(0,top),(1,bot)]),(x0+T,y0+T),rrm(w-2*T,h-2*T,(h-2*T)//2))
    gl=Image.new('RGBA',(w-4*T,(h-2*T)//2),(255,255,255,70)); im.paste(gl,(x0+2*T,y0+T+2*S),rrm(gl.width,gl.height,gl.height//2))
    d=ImageDraw.Draw(im); d.text(((x0+x1)/2,(y0+y1)/2 if not sub else y0+h*0.38),label,font=F(n),fill='white',anchor='mm',stroke_width=2*S,stroke_fill=shade(bot,0.5))
    if sub: d.text(((x0+x1)/2,y0+h*0.75),sub,font=F(13),fill='white',anchor='mm',stroke_width=2*S,stroke_fill=shade(bot,0.5))
def ribbon(im,cx,y,w,label,base,n=26):
    h=int(40*S); x0=int(cx*S-w*S/2); y0=int(y*S); ww=int(w*S)
    im.paste(vgrad(ww,h,[(0,shade(base,1.35)),(0.5,base),(1,shade(base,0.75))]),(x0,y0),rrm(ww,h,10*S))
    d=ImageDraw.Draw(im); d.rounded_rectangle([x0,y0,x0+ww,y0+h],10*S,outline=(255,170,40),width=3*S)
    d.text((cx*S,y0+h/2),label,font=F(n),fill=(255,246,220),anchor='mm',stroke_width=2*S,stroke_fill=shade(base,0.45))
def icon(path,sz):
    a=Image.open(path).convert('RGBA'); a=a.crop(a.getbbox()); k=sz/max(a.size); return a.resize((max(1,int(a.width*k)),max(1,int(a.height*k))),Image.LANCZOS)
BASE=(32,78,160)
im=vgrad(W,H,[(0,(52,110,205)),(0.6,(30,72,165)),(1,(20,52,130))])
# soft light rays behind the wheel
rays=Image.new('RGBA',(W,H),(0,0,0,0)); rd=ImageDraw.Draw(rays); cx,cy=195*S,350*S
for k in range(16):
    a=k*math.pi/8; b=a+math.pi/16
    rd.polygon([(cx,cy),(cx+math.cos(a)*900*S,cy+math.sin(a)*900*S),(cx+math.cos(b)*900*S,cy+math.sin(b)*900*S)],fill=(255,255,255,18))
im.alpha_composite(rays)
ribbon(im,195,28,230,'Lucky Wheel',BASE)
d=ImageDraw.Draw(im); d.text((195*S,92*S),'Spin every day for free prizes!',font=F(16),fill=(255,240,200),anchor='mm',stroke_width=2*S,stroke_fill=(20,40,100))
# wheel: cut the Canva art's white background
a=np.array(Image.open('/tmp/v/wheel_src.png').convert('RGB')).astype(float); mn=a.min(2); sat=a.max(2)-mn
light=(mn>238)|((mn>150)&(sat<22)); lab,n=ndimage.label(light)
edge=set(np.unique(np.concatenate([lab[0],lab[-1],lab[:,0],lab[:,-1]])))-{0}
bg=np.isin(lab,list(edge)); fg=ndimage.binary_erosion(ndimage.binary_fill_holes(~bg),iterations=2)
# edge pixels take the colour of the nearest solid inside pixel (no white fringe)
_,ix=ndimage.distance_transform_edt(~ndimage.binary_erosion(fg,iterations=1),return_indices=True); a=a[ix[0],ix[1]]
al=ndimage.gaussian_filter(fg.astype(float),0.7)
wh=Image.fromarray(np.dstack([a,al*255]).astype(np.uint8),'RGBA'); wh=wh.crop(wh.getbbox())
WS=330*S; wh=wh.resize((WS,int(WS*wh.height/wh.width)),Image.LANCZOS); wh=ImageEnhance.Sharpness(wh).enhance(1.3)
glow=Image.new('RGBA',(W,H),(0,0,0,0)); ImageDraw.Draw(glow).ellipse([cx-185*S,cy-185*S,cx+185*S,cy+185*S],fill=(255,220,120,120)); im.alpha_composite(glow.filter(ImageFilter.GaussianBlur(24*S)))
wx,wy=int(cx-WS/2),int(cy-wh.height/2+8*S); im.alpha_composite(wh,(wx,wy))
# prizes on the 8 segments (centre of the wheel = image centre slightly below the pointer)
wcx,wcy=cx,wy+wh.height*0.535
prizes=[('art/ui-coin.webp','100'),('art/crk/b6.webp',''),('art/ui-coin.webp','50'),('art/crk/b17.webp',''),('art/web/fe-heart.png','+1'),('art/ui-coin.webp','200'),('art/crk/b10.webp',''),('art/web/ui-chest.webp','500')]
for i,(p,lab_) in enumerate(prizes):
    ang=-math.pi/2+math.pi/8+i*math.pi/4
    r=WS*0.30; px,py=wcx+math.cos(ang)*r,wcy+math.sin(ang)*r
    ic=icon(p,int(40*S)); sh=Image.new('RGBA',(W,H),(0,0,0,0))
    im.alpha_composite(ic,(int(px-ic.width/2),int(py-ic.height/2-(6*S if lab_ else 0))))
    if lab_: ImageDraw.Draw(im).text((px,py+16*S),lab_,font=F(15),fill='white',anchor='mm',stroke_width=2*S,stroke_fill=(60,20,10))
# buttons and timer
btn(im,[70,556,320,622],(120,220,100),(40,160,50),'SPIN FREE',28)
btn(im,[90,634,300,686],(255,190,60),(225,120,20),'Spin again',20,'Watch a video')
ad=Image.new('RGBA',(W,H),(0,0,0,0)); ImageDraw.Draw(ad).rounded_rectangle([96*S,641*S,132*S,663*S],8*S,fill=(232,18,60)); im.alpha_composite(ad)
ImageDraw.Draw(im).text((114*S,652*S),'AD',font=F(13),fill='white',anchor='mm')
d=ImageDraw.Draw(im); d.text((195*S,704*S),'Next free spin in 14:32:05',font=F(14),fill=(220,230,255),anchor='mm')
# bottom bar (same as home)
def nav(im,sel):
    BH=118*S; top=16*S; bar=Image.new('RGBA',(W,BH),(0,0,0,0)); d=ImageDraw.Draw(bar)
    for y in range(top,BH):
        t=(y-top)/(BH-top); d.line([(0,y),(W,y)],fill=(int(40-14*t),int(96-36*t),int(196-50*t),255))
    d.line([(0,top),(W,top)],fill=(255,170,40),width=3*S)
    for i in range(1,5):
        x=i*78*S; d.line([(x,top+14*S),(x,BH-10*S)],fill=(20,46,110,255),width=2*S); d.line([(x+2*S,top+14*S),(x+2*S,BH-10*S)],fill=(90,140,230,255),width=S)
    L=[('art/web/nav-map.png','Areas'),('art/web/nav-trophy.png','Trophies'),('art/web/ic2-house.png','Home'),('art/web/nav-wheel.png','Lucky Wheel'),('art/crk/b6.webp','Crackers')]
    d.rounded_rectangle([(sel*78+1)*S,0,(sel*78+77)*S,BH],16*S,fill=(80,140,240),outline=(255,215,90),width=3*S)
    for i,(p_,n) in enumerate(L):
        x=i*78
        if i==sel:
            a=icon(p_,int(72*S)); bar.alpha_composite(a,(int((x+39)*S-a.width/2),int(46*S-a.height/2)))
            d.text(((x+39)*S,BH-14*S),n,font=F(13),fill='white',anchor='mm',stroke_width=2*S,stroke_fill=(20,40,100))
        else:
            a=icon(p_,int(66*S)); bar.alpha_composite(a,(int((x+39)*S-a.width/2),int(top+(BH-top)/2-a.height/2)))
    im.alpha_composite(bar,(0,H-BH))
nav(im,3)
im.convert('RGB').save('../previews/lucky-wheel.png')
