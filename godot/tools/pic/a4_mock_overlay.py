import re
from PIL import Image, ImageDraw, ImageFont, ImageFilter
S='/tmp/claude-0/s/'; G='/home/user/crackers-match/godot/'
OUT='/mnt/project-files/crackers/area4-mock/'
F=lambda n: ImageFont.truetype(G+'art/LilitaOne.ttf', n)
diya=Image.open(G+'art/ui-diya.webp').convert('RGBA'); coin=Image.open(G+'art/ui-coin.webp').convert('RGBA')
log=open(S+'map0.log').read()
dots=[(float(x),float(y)) for x,y in re.findall(r'PIC dot \d+ ([\d.]+) ([\d.]+)',log)]
places={n:(float(x),float(y)) for n,x,y in re.findall(r'PIC place (\w+) ([\d.]+) ([\d.]+)',log)}
W,H=1080,2338
def icon(im,ic,x,y,s):
    i=ic.copy(); i.thumbnail((s,s)); im.alpha_composite(i,(int(x),int(y)))
def shadow_text(d,xy,t,f,fill='white',anchor='mm',stroke=6):
    d.text(xy,t,font=f,fill=fill,anchor=anchor,stroke_width=stroke,stroke_fill='#3a1a00')
def pill(im,box,fill,r=40,outline='#7a3a00'):
    sh=Image.new('RGBA',im.size,(0,0,0,0)); ImageDraw.Draw(sh).rounded_rectangle([box[0]+6,box[1]+10,box[2]+6,box[3]+10],r,fill=(0,0,0,90))
    im.alpha_composite(sh.filter(ImageFilter.GaussianBlur(6)))
    d=ImageDraw.Draw(im); d.rounded_rectangle(box,r,fill=fill,outline=outline,width=6)
def topbar(im,title):
    d=ImageDraw.Draw(im)
    pill(im,(30,70,330,160),'#fff4d6',45)
    icon(im,coin,40,78,76); shadow_text(d,(225,115),'12,450',F(52),'#ffd23a')
    pill(im,(750,70,1050,160),'#fff4d6',45)
    icon(im,diya,760,74,82); shadow_text(d,(945,115),'3',F(56),'#ffd23a')
    pill(im,(290,190,790,280),'#d8262e',45)
    shadow_text(d,(540,235),title,F(50))
def levelbtn(im,txt,y=2110):
    pill(im,(240,y,840,y+150),'#2fb34a',70,'#14561f')
    shadow_text(ImageDraw.Draw(im),(540,y+75),txt,F(78),stroke=7)
def buildbtn(im,x,y,label,cost,w=520):
    pill(im,(x,y,x+w,y+120),'#ffb31a',55)
    d=ImageDraw.Draw(im)
    shadow_text(d,(x+30,y+60),label,F(54),anchor='lm')
    icon(im,diya,x+w-170,y+16,90); shadow_text(d,(x+w-55,y+60),str(cost),F(60),'#fff')
def dot(d,x,y,n,state):
    r=34 if state!='now' else 46
    col={'done':'#ffd23a','now':'#ff4a2a','next':'#ffffff'}[state]
    d.ellipse((x-r-5,y-r-5,x+r+5,y+r+5),fill='#3a1a00')
    d.ellipse((x-r,y-r,x+r,y+r),fill=col)
    d.text((x,y+2),str(n),font=F(34 if state!='now' else 44),fill='#3a1a00' if state!='now' else 'white',anchor='mm')
def tag(im,x,y,t,done):
    d=ImageDraw.Draw(im); f=F(38); w=d.textlength(t,font=f)+50
    pill(im,(x-w/2,y-34,x+w/2,y+34),'#ffffff' if not done else '#ffe27a',30,'#7a3a00')
    d=ImageDraw.Draw(im); d.text((x,y+1),t,font=f,fill='#5a2a00',anchor='mm')
def sparkles(im,cx,cy,r,n=14,seed=1):
    import random; random.seed(seed); d=ImageDraw.Draw(im)
    for i in range(n):
        x=cx+random.uniform(-r,r); y=cy+random.uniform(-r*0.6,r*0.6); s=random.uniform(10,24)
        c=random.choice(['#fff6a0','#ffffff','#ffd23a'])
        d.polygon([(x,y-s),(x+s*0.28,y-s*0.28),(x+s,y),(x+s*0.28,y+s*0.28),(x,y+s),(x-s*0.28,y+s*0.28),(x-s,y),(x-s*0.28,y-s*0.28)],fill=c)
NAMES={'temple':'Temple Festival','wedding':'Wedding Hall','school':'School Function','apts':'Apartments','fair':'Village Fair','office':'Office Party','beach':'Marina Beach'}
TAGY=-150
# ---- screen 1: shop + old van
im=Image.open(S+'lane.png').convert('RGBA')
topbar(im,'GHILLI Deliveries')
buildbtn(im,250,1680,'Fix the old van',1,580)
d=ImageDraw.Draw(im)
pill(im,(140,1860,940,1960),'#fff4d6',40)
d=ImageDraw.Draw(im); d.text((540,1910),'Build 1 of 9  ·  tyres, wash, GHILLI paint',font=F(38),fill='#5a2a00',anchor='mm')
levelbtn(im,'Level 81')
im.convert('RGB').save(OUT+'screen1-shop-old-van.png')
# ---- screen 2: road, van at temple, Build button
m=Image.open(S+'map0.png').convert('RGBA'); oy=4680-H
im=m.crop((0,oy,W,4680)); d=ImageDraw.Draw(im)
for i,(x,y) in enumerate(dots):
    if oy<=y<4680: dot(d,x,y-oy,81+i,'done' if i<3 else ('now' if i==3 else 'next'))
for n,(x,y) in places.items():
    if n!='temple' and oy+320<=y+TAGY<4680: tag(im,x if n!='temple' else 230,y-oy+TAGY,NAMES[n],False)
tx,ty=places['temple']; buildbtn(im,500,int(ty-oy)-190,'Build Temple',2,560)
topbar(im,'GHILLI Deliveries')
levelbtn(im,'Level 84')
im.convert('RGB').save(OUT+'screen2-road-van-at-temple.png')
# ---- screen 3: all done (top half) + full map
m7=Image.open(S+'map7.png').convert('RGBA')
def decorate(full):
    d=ImageDraw.Draw(full)
    for i,(x,y) in enumerate(dots): dot(d,x,y,81+i,'done')
    for k,(n,(x,y)) in enumerate(places.items()):
        sparkles(full,x,y,170,16,k)
        tag(full,x if n!='temple' else 230,y+TAGY,NAMES[n],True)
    return full
full=decorate(m7.copy())
im=full.crop((0,0,W,H))
topbar(im,'GHILLI Deliveries')
pill(im,(90,1840,990,2060),'#d8262e',50)
d=ImageDraw.Draw(im); shadow_text(d,(540,1910),'All deliveries done!',F(76)); shadow_text(d,(540,2000),'Madurai is calling...',F(50),'#ffe27a')
levelbtn(im,'NEXT',2120)
im.convert('RGB').save(OUT+'screen3-road-all-done.png')
full.convert('RGB').save(OUT+'full-road-all-done.jpg',quality=88)
# one sheet with all 3
sheet=Image.new('RGB',(3*540+4*30,1169+60),'#fdf3e0')
for i,n in enumerate(['screen1-shop-old-van.png','screen2-road-van-at-temple.png','screen3-road-all-done.png']):
    sheet.paste(Image.open(OUT+n).resize((540,1169)),(30+i*570,30))
sheet.save(OUT+'area4-mock-3-screens.jpg',quality=88)
print('ok')
