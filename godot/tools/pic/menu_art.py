# 26 Nov: art for the new top bar and bottom menu (pictures only; the phone just shows them)
import sys, numpy as np
sys.path.insert(0,'tools/pic'); import wheel_build as WB
from PIL import Image, ImageDraw, ImageFilter
K=3  # 3x of the 390-wide layout
def save(im,p): im.save(p); print(p, im.size)
# cream pill with gold rim (Canva), kept near its own size so it stays sharp
pill=WB.cut('art/topbar/pill_src.png'); save(pill,'art/topbar/pill.png')
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
