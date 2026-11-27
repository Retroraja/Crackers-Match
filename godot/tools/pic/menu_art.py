# 26 Nov: art for the new top bar and bottom menu (pictures only; the phone just shows them)
import sys, numpy as np
sys.path.insert(0,'tools/pic'); import wheel_build as WB
from PIL import Image, ImageDraw, ImageFilter
K=3  # 3x of the 390-wide layout
def save(im,p): im.save(p); print(p, im.size)
# cream pill with gold rim (Canva), kept near its own size so it stays sharp
import pill_build; save(pill_build.pill(72,32),'art/topbar/pill.png')   # full size (the Canva pill was too soft)
gear=WB.cut('art/topbar/gear_src.png'); save(gear.resize((42*K,int(42*K*gear.height/gear.width)),Image.LANCZOS),'art/topbar/gear.png')
# small gold profile frame (as in the approved preview)
ps=44*K; fr=Image.new('RGBA',(ps,ps),(0,0,0,0)); fd=ImageDraw.Draw(fr)
fd.rounded_rectangle([0,0,ps-1,ps-1],10*K,fill=(232,176,48)); fd.rounded_rectangle([3*K,3*K,ps-3*K,ps-3*K],8*K,fill=(255,226,120))
fd.rounded_rectangle([5*K,5*K,ps-5*K,ps-5*K],7*K,fill=(70,120,200)); save(fr,'art/topbar/frame.png')
# green plus on the coin pill
pl=Image.new('RGBA',(18*K,18*K),(0,0,0,0)); pd=ImageDraw.Draw(pl); pd.ellipse([0,0,18*K-1,18*K-1],fill=(255,255,255)); pd.ellipse([2*K,2*K,16*K,16*K],fill=(46,170,60))
pd.rectangle([8*K,5*K,10*K,13*K],fill='white'); pd.rectangle([5*K,8*K,13*K,10*K],fill='white'); save(pl,'art/topbar/plus.png')
# soft dark fade behind the bar (stretched by the phone)
h=110; a=np.zeros((h,4,4),np.uint8); a[...,2]=20; a[...,3]=(np.clip(1-np.arange(h)/h,0,1)**1.4*150)[:,None]; save(Image.fromarray(a),'art/topbar/fade.png')

# ---------------------------------------------------------------- bottom menu + pages (26 Nov)
import math
from PIL import ImageFont
F=lambda n: ImageFont.truetype('art/LilitaOne.ttf',int(n*K))
def vgrad(w,h,stops):
    a=np.zeros((h,w,4),np.float32); ys=np.linspace(0,1,h)
    for c in range(3): a[:,:,c]=np.interp(ys,[s[0] for s in stops],[s[1][c] for s in stops])[:,None]
    a[:,:,3]=255; return Image.fromarray(a.astype(np.uint8))
def shade(c,k): return tuple(max(0,min(255,int(v*k))) for v in c)
def rrm(w,h,r): m=Image.new('L',(w,h),0); ImageDraw.Draw(m).rounded_rectangle([0,0,w-1,h-1],r,fill=255); return m
def icon(path,sz):
    a=Image.open(path).convert('RGBA'); a=a.crop(a.getbbox()); k=sz/max(a.size); return a.resize((max(1,int(a.width*k)),max(1,int(a.height*k))),Image.LANCZOS)
# nav bar: blue, gold top line, thin dark/light divider pairs every 78 pt (102 pt tall)
BH=102; nb=Image.new('RGBA',(390*K,BH*K),(0,0,0,0)); d=ImageDraw.Draw(nb)
for y in range(BH*K):
    t=y/(BH*K); d.line([(0,y),(390*K,y)],fill=(int(40-14*t),int(96-36*t),int(196-50*t),255))
d.rectangle([0,0,390*K,3*K],fill=(255,170,40))
for i in range(1,5):
    x=i*78*K; d.line([(x,14*K),(x,(BH-10)*K)],fill=(20,46,110,255),width=2*K); d.line([(x+2*K,14*K),(x+2*K,(BH-10)*K)],fill=(90,140,230,255),width=K)
save(nb,'art/menu/navbar.png')
sel=Image.new('RGBA',(76*K,118*K),(0,0,0,0)); ImageDraw.Draw(sel).rounded_rectangle([0,0,76*K-1,118*K+40],16*K,fill=(80,140,240),outline=(255,215,90),width=3*K)
save(sel,'art/menu/navsel.png')
for k,p in [('areas','art/web/nav-map.png'),('trophy','art/web/nav-trophy.png'),('home','art/web/ic2-house.png'),('wheel','art/web/nav-wheel.png'),('crackers','art/crk/b6.webp')]:
    save(icon(p,72*K),'art/menu/nav_%s.png'%k)
# page background (blue, soft light rays from the middle) and title ribbons
W,H=390*2,844*2
bg=vgrad(W,H,[(0,(52,110,205)),(0.6,(30,72,165)),(1,(20,52,130))])
rays=Image.new('RGBA',(W,H),(0,0,0,0)); rd=ImageDraw.Draw(rays); cx,cy=195*2,350*2
for k_ in range(16):
    a=k_*math.pi/8; b=a+math.pi/16
    rd.polygon([(cx,cy),(cx+math.cos(a)*1800,cy+math.sin(a)*1800),(cx+math.cos(b)*1800,cy+math.sin(b)*1800)],fill=(255,255,255,14))
bg.alpha_composite(rays); bg.convert('RGB').save('art/menu/page_bg.webp',quality=88); print('art/menu/page_bg.webp')
BASE=(32,78,160)
def ribbon(label,w,n=26):
    h=40*K; ww=w*K; im=Image.new('RGBA',(ww+6*K,h+8*K),(0,0,0,0))
    sh=Image.new('RGBA',im.size,(0,0,0,0)); sh.paste((0,0,30,120),(3*K,6*K),rrm(ww,h,10*K)); im.alpha_composite(sh.filter(ImageFilter.GaussianBlur(3*K)))
    im.paste(vgrad(ww,h,[(0,shade(BASE,1.35)),(0.5,BASE),(1,shade(BASE,0.75))]),(3*K,2*K),rrm(ww,h,10*K))
    d=ImageDraw.Draw(im); d.rounded_rectangle([3*K,2*K,3*K+ww,2*K+h],10*K,outline=(255,170,40),width=3*K)
    d.text((3*K+ww/2,2*K+h/2),label,font=F(n),fill=(255,246,220),anchor='mm',stroke_width=2*K,stroke_fill=shade(BASE,0.45))
    return im
for k_,t_ in [('areas','Areas'),('trophy','Trophy Room'),('wheel','Lucky Wheel'),('profile','Profile')]:
    save(ribbon(t_,230),'art/menu/rib_%s.png'%k_)
# cream card (nine-patch, 20 pt corners) and pill buttons (nine-patch)
def card(w,h,r,fill,edge,t=4):
    im=Image.new('RGBA',(w*K,h*K),(0,0,0,0))
    im.paste(vgrad(w*K,h*K,[(0,shade(edge,1.3)),(1,shade(edge,0.75))]),(0,0),rrm(w*K,h*K,r*K))
    T=t*K; im.paste(vgrad(w*K-2*T,h*K-2*T,fill),(T,T),rrm(w*K-2*T,h*K-2*T,(r-t)*K)); return im
save(card(60,60,16,[(0,(255,250,228)),(1,(244,232,196))],shade(BASE,0.85)),'art/menu/card.png')
def pbtn(w,h,top,bot):
    im=Image.new('RGBA',(w*K,h*K),(0,0,0,0))
    im.paste(vgrad(w*K,h*K,[(0,(255,215,90)),(1,(200,130,20))]),(0,0),rrm(w*K,h*K,h*K//2))
    T=3*K; im.paste(vgrad(w*K-2*T,h*K-2*T,[(0,top),(1,bot)]),(T,T),rrm(w*K-2*T,h*K-2*T,(h*K-2*T)//2))
    gl=Image.new('RGBA',(w*K-4*T,(h*K-2*T)//2),(255,255,255,70)); im.alpha_composite(Image.composite(gl,Image.new('RGBA',gl.size,(0,0,0,0)),rrm(gl.width,gl.height,gl.height//2)),(2*T,T+2*K))
    return im
save(pbtn(60,44,(120,220,100),(40,160,50)),'art/menu/btn_green.png')
save(pbtn(60,44,(255,190,60),(225,120,20)),'art/menu/btn_gold.png')
save(pbtn(60,44,(150,160,180),(100,110,130)),'art/menu/btn_grey.png')
# progress bar back and fill (nine-patch)
bb=Image.new('RGBA',(40*K,16*K),(0,0,0,0)); bb.paste(shade(BASE,0.4)+(255,),(0,0),rrm(40*K,16*K,8*K)); save(bb,'art/menu/bar_back.png')
bf=Image.new('RGBA',(40*K,16*K),(0,0,0,0)); bf.paste(vgrad(40*K,16*K,[(0,(150,230,110)),(1,(50,170,60))]),(0,0),rrm(40*K,16*K,8*K)); save(bf,'art/menu/bar_fill.png')
# icon circle for trophy rows
ci=Image.new('RGBA',(60*K,60*K),(0,0,0,0)); ImageDraw.Draw(ci).ellipse([0,0,60*K-1,60*K-1],fill=shade(BASE,1.1),outline=(255,170,40),width=3*K); save(ci,'art/menu/circle.png')
# trophies in bronze / silver / gold / grey (from the gold trophy picture)
tr=Image.open('art/web/fe-trophy.png').convert('RGBA'); tr=tr.crop(tr.getbbox())
for col,tint in {'bronze':(205,127,50),'silver':(200,205,215),'gold':(255,200,50),'none':(90,90,110)}.items():
    arr=np.array(tr).astype(float); lum=arr[...,:3].mean(2,keepdims=True)/255
    arr[...,:3]=np.clip(lum*np.array(tint)*1.35,0,255)
    if col=='none': arr[...,3]*=0.45
    t_=Image.fromarray(arr.astype(np.uint8)); t_=t_.resize((int(46*K*t_.width/t_.height),46*K),Image.LANCZOS); save(t_,'art/menu/tro_%s.png'%col)
# lucky wheel: segments + rim at full size, prize icons on it; lit bulbs as a separate layer (blink = show/hide)
WSZ=330; WS=WSZ*K
wh=WB.wheel(WS)
prizes=[('art/ui-coin.webp','100'),('art/crk/b6.webp',''),('art/ui-coin.webp','50'),('art/crk/b17.webp',''),('art/web/fe-heart.png','+1'),('art/ui-coin.webp','200'),('art/crk/b10.webp',''),('art/web/shop_chest.png','500')]
dw=ImageDraw.Draw(wh)
for i,(p_,lab) in enumerate(prizes):
    ang=-math.pi/2+math.pi/8+i*math.pi/4; r=WS*0.30; px,py=WS/2+math.cos(ang)*r,WS/2+math.sin(ang)*r
    ic=icon(p_,int(40*K*(1.15 if not lab else 1))); wh.alpha_composite(ic,(int(px-ic.width/2),int(py-ic.height/2-(6*K if lab else 0))))
    if lab: dw.text((px,py+16*K),lab,font=F(15),fill='white',anchor='mm',stroke_width=2*K,stroke_fill=(60,20,10))
save(wh,'art/menu/wheel.png'); save(WB.bulbs_lit(WS),'art/menu/wheel_lit.png')
save(WB.hub(WS),'art/menu/wheel_hub.png'); save(WB.pointer(WS),'art/menu/wheel_ptr.png')
# soft gold glow behind the wheel
gl=Image.new('RGBA',(400*K//2,400*K//2),(0,0,0,0)); g=gl.width; ImageDraw.Draw(gl).ellipse([g*0.04,g*0.04,g*0.96,g*0.96],fill=(255,220,120,120)); save(gl.filter(ImageFilter.GaussianBlur(g*0.05)),'art/menu/wheel_glow.png')
# area picture cards for the Areas page (358 x 150 pt): picture, dark fade at the bottom, gold frame, area name
AR=[('art/web/title_aft.webp',0.52,'Area 1','Sivakasi Street'),('street/pics/a2_p0.webp',0.60,'Area 2','GHILLI Crackers'),
    ('street/pics/a3_p0.webp',0.42,'Area 3','Busy Days at GHILLI'),('street/pics/a4_p0.webp',0.45,'Area 4','GHILLI Delivery Hub'),
    ('art/story4/s1.jpg',0.30,'Area 5','Madurai')]
CW,CH=358,150; Q=2
for i,(p_,fy,a_,n_) in enumerate(AR):
    src=Image.open(p_).convert('RGB'); w=src.width; h=int(w*CH/CW); y0=int(src.height*fy-h/2)
    pic_=src.crop((0,y0,w,y0+h)).resize((CW*Q,CH*Q),Image.LANCZOS).convert('RGBA')
    if i==4: pic_=Image.blend(pic_,Image.new('RGBA',pic_.size,(10,20,50,255)),0.45)
    a=np.zeros((CH*Q,CW*Q,4),np.uint8); a[...,3]=(np.clip((np.arange(CH*Q)/(CH*Q)-0.45)/0.55,0,1)**1.3*200)[:,None]; pic_.alpha_composite(Image.fromarray(a))
    out=Image.new('RGBA',(CW*Q,CH*Q),(0,0,0,0)); out.paste(pic_,(0,0),rrm(CW*Q,CH*Q,16*Q))
    d=ImageDraw.Draw(out); d.rounded_rectangle([0,0,CW*Q-1,CH*Q-1],16*Q,outline=(255,190,60),width=4*Q)
    f1=ImageFont.truetype('art/LilitaOne.ttf',14*Q); f2=ImageFont.truetype('art/LilitaOne.ttf',24*Q)
    d.text((16*Q,(CH-50)*Q),a_,font=f1,fill=(255,215,110),stroke_width=2*Q,stroke_fill=(30,20,10))
    d.text((16*Q,(CH-34)*Q),n_,font=f2,fill='white',stroke_width=2*Q,stroke_fill=(30,20,10))
    out.save('art/menu/area_%d.webp'%(i+1),quality=88); print('art/menu/area_%d.webp'%(i+1))
