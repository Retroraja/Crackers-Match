# 26 Nov: cream pill with a gold rim, built at full size (the Canva pill is only 41 px tall, too soft on phones).
# Same look as art/topbar/pill_src.png: rounded gold bevel lit from the top, thin dark edges, cream inside with a soft top shine.
import numpy as np
from PIL import Image
def pill(w,h,K=4):
    W,H=w*K,h*K; yy,xx=np.mgrid[0:H,0:W]+0.5
    r=H/2; cx=np.clip(xx,r,W-r); d=np.hypot(xx-cx,yy-r)        # distance from the pill's centre line
    sd=d-r                                                       # <0 inside
    rim=H*0.13; img=np.zeros((H,W,4),float)
    # gold bevel: height profile across the rim, normal from the gradient direction
    t=np.clip((-sd)/rim,0,1); inrim=(sd<=0)&(t<1)
    nx=(xx-cx)/np.maximum(d,1e-3); ny=(yy-r)/np.maximum(d,1e-3)
    bend=np.cos(np.pi*t)                                         # +1 outer edge, -1 inner edge
    lit=np.clip(0.5+0.5*(-(ny*bend))*0.9,0,1)*0.75+0.25*np.sin(np.pi*t)
    g0=np.array([150,92,18.]); g1=np.array([236,170,36.]); g2=np.array([255,238,150.])
    gc=np.where(lit[...,None]<0.6, g0+(g1-g0)*(lit/0.6)[...,None], g1+(g2-g1)*((lit-0.6)/0.4)[...,None])
    spec=np.clip((lit-0.82)/0.18,0,1)**2; gc=gc+(255-gc)*spec[...,None]*0.7
    img[...,:3]=gc
    # cream inside: soft vertical shade + top shine
    inner=sd< -rim; v=yy/H
    cream=np.array([252,247,232.])*(1-0.10*v[...,None])
    shine=np.clip(1-np.abs(v-0.30)/0.16,0,1)*((-sd-rim)>H*0.06)
    cream=cream+(255-cream)*shine[...,None]*0.55
    # inner shadow under the rim
    ish=np.clip(1-((-sd)-rim)/(H*0.08),0,1)*inner; cream=cream*(1-0.12*ish[...,None])
    img[inner,:3]=cream[inner]
    # thin dark lines: outer edge and rim/cream edge
    o=np.abs(sd+0.6*K)<0.6*K; img[o,:3]*=0.6
    o=np.abs(sd+rim)<0.7*K; img[o,:3]=np.array([170,110,25.])
    img[...,3]=np.clip(-sd+0.5,0,1)*255
    return Image.fromarray(img.astype(np.uint8),'RGBA').resize((w*3,h*3),Image.LANCZOS)
if __name__=='__main__':
    im=pill(72,32); im.save('art/topbar/pill.png'); print(im.size)
