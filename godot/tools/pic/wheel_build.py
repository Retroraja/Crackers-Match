# builds a sharp wheel at any size: rim/segments drawn at full size, hub/pointer/bulbs from Canva pieces
import math, numpy as np
from PIL import Image, ImageDraw, ImageFilter
from scipy import ndimage
def cut(path):
    a=np.array(Image.open(path).convert('RGB')).astype(float); mn=a.min(2); sat=a.max(2)-mn
    light=(mn>232)|((mn>150)&(sat<22)); lab,n=ndimage.label(light)
    edge=set(np.unique(np.concatenate([lab[0],lab[-1],lab[:,0],lab[:,-1]])))-{0}
    fg=ndimage.binary_fill_holes(~np.isin(lab,list(edge))); fg=ndimage.binary_erosion(fg,iterations=1)
    _,ix=ndimage.distance_transform_edt(~ndimage.binary_erosion(fg,iterations=1),return_indices=True); a=a[ix[0],ix[1]]
    al=ndimage.gaussian_filter(fg.astype(float),0.6)
    im=Image.fromarray(np.dstack([a,al*255]).astype(np.uint8),'RGBA'); return im.crop(im.getbbox())
def fit(im,w): return im.resize((int(w),int(im.height*w/im.width)),Image.LANCZOS)
COLS=[(236,40,140),(30,180,240),(255,196,20),(80,200,40),(140,60,230),(255,120,20),(30,100,235),(235,30,40)]
def wheel(WS,parts='art/wheel'):
    K=2; N=WS*K; R=N/2; yy,xx=np.mgrid[0:N,0:N]+0.5; dx=xx-R; dy=yy-R; r=np.hypot(dx,dy)
    ang=(np.degrees(np.arctan2(dy,dx))+90)%360; seg=(ang//45).astype(int)%8
    Rin=R*0.80; img=np.zeros((N,N,4),float)
    # segments with soft shading (brighter toward the rim, light from top-left)
    col=np.array(COLS,float)[seg]; t=np.clip(r/Rin,0,1)
    k=0.78+0.32*t-0.10*((dx+dy)/(2*R)); col=np.clip(col*k[...,None],0,255)
    img[...,:3]=col; img[...,3]=(r<Rin+2)*255
    # gold divider lines
    da=np.minimum(ang%45,45-ang%45)*np.pi/180*r; ln=(da<N*0.006)&(r<Rin)
    img[ln,:3]=(255,215,90); edgeln=(da>=N*0.006)&(da<N*0.009)&(r<Rin); img[edgeln,:3]=img[edgeln,:3]*0.75
    # inner shadow next to the rim
    sh=np.clip(1-(Rin-r)/(N*0.03),0,1)*(r<Rin); img[...,:3]*= (1-0.35*sh)[...,None]
    # gold rim: rounded bevel lit from top-left
    rim=(r>=Rin)&(r<=R); tt=np.clip((r-Rin)/(R-Rin),0,1); h=np.sin(np.pi*tt)
    nx=np.cos(np.pi*tt)*dx/np.maximum(r,1); ny=np.cos(np.pi*tt)*dy/np.maximum(r,1)
    lit=np.clip(0.55+0.55*(-nx*0.6-ny*0.8)*-1*-1,0,1)
    lit=np.clip(0.5+0.5*(-(nx*-0.6+ny*-0.8)),0,1)*0.6+0.4*h
    g0=np.array([150,92,18.]); g1=np.array([240,175,40.]); g2=np.array([255,240,160.])
    gc=np.where(lit[...,None]<0.6, g0+(g1-g0)*(lit/0.6)[...,None], g1+(g2-g1)*((lit-0.6)/0.4)[...,None])
    spec=np.clip((lit-0.85)/0.15,0,1)**2; gc=gc+(255-gc)*spec[...,None]*0.6
    img[rim,:3]=gc[rim]; img[rim,3]=255
    # thin dark outline on both edges of the rim
    for rr_ in (Rin,R-1.5*K):
        o=np.abs(r-rr_)<1.2*K; img[o,:3]=img[o,:3]*0.55
    a=np.clip(R-r+0.5,0,1); img[...,3]=np.minimum(img[...,3],a*255)
    W_=Image.fromarray(img.astype(np.uint8),'RGBA').resize((WS,WS),Image.LANCZOS)
    # bulbs on the rim
    b=fit(cut(parts+'/bulb.png'),WS*0.062); rb=WS/2*0.90
    for i in range(16):
        q=math.radians(i*22.5-90+11.25); W_.alpha_composite(b,(int(WS/2+math.cos(q)*rb-b.width/2),int(WS/2+math.sin(q)*rb-b.height/2)))
    return W_
def hub(WS,parts='art/wheel'): return fit(cut(parts+'/hub.png'),WS*0.24)
def pointer(WS,parts='art/wheel'): return fit(cut(parts+'/ptr.png'),WS*0.13)
