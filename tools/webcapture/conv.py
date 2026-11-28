# web DOM dump -> clean layout JSON for the Godot builder (weblayout.gd)
import json,re,sys,os,hashlib,base64
NUM=r'-?\d*\.?\d+'
def col(s):
    s=s.strip()
    m=re.match(r'rgba?\(([^)]*)\)',s)
    if not m:
        if s.startswith('#'):
            h=s[1:]
            if len(h)==3:h=''.join(c*2 for c in h)
            return [int(h[0:2],16)/255,int(h[2:4],16)/255,int(h[4:6],16)/255,1 if len(h)<8 else int(h[6:8],16)/255]
        return None
    p=[float(x) for x in re.split(r'[ ,/]+',m.group(1).strip()) if x]
    return [p[0]/255,p[1]/255,p[2]/255,p[3] if len(p)>3 else 1.0]
def split_top(s):
    out=[];d=0;cur=''
    for ch in s:
        if ch=='(':d+=1
        if ch==')':d-=1
        if ch==',' and d==0:out.append(cur.strip());cur=''
        else:cur+=ch
    if cur.strip():out.append(cur.strip())
    return out
COLRE=r'(rgba?\([^)]*\)|#[0-9a-fA-F]{3,8}|transparent)'
def stops(parts):
    st=[]
    for p in parts:
        m=re.match(COLRE+r'\s*(.*)',p.strip())
        if not m: continue
        c=[0,0,0,0] if m.group(1)=='transparent' else col(m.group(1))
        rest=m.group(2).split()
        pos=[float(x[:-1])/100 if x.endswith('%') else None for x in rest] or [None]
        for q in pos: st.append([q,c])
    n=len(st)
    if n==0: return []
    if st[0][0] is None: st[0][0]=0
    if st[-1][0] is None: st[-1][0]=1
    i=0
    while i<n:
        if st[i][0] is None:
            j=i
            while st[j][0] is None:j+=1
            a=st[i-1][0];b=st[j][0]
            for k in range(i,j): st[k][0]=a+(b-a)*(k-i+1)/(j-i+1)
            i=j
        i+=1
    return st
def grad(g):
    g=g.strip()
    m=re.match(r'(repeating-)?(linear|radial|conic)-gradient\((.*)\)$',g)
    if not m: return None
    kind=m.group(2);parts=split_top(m.group(3))
    if kind=='conic':
        cen=[0.5,0.5]
        if not re.match(COLRE,parts[0]):
            a=parts.pop(0);mm=re.search(r'at\s+('+NUM+r')%\s+('+NUM+r')%',a)
            if mm: cen=[float(mm.group(1))/100,float(mm.group(2))/100]
        st=[];last=0
        for p in parts:
            mm=re.match(COLRE+r'\s*(.*)',p.strip());c=col(mm.group(1)) if mm.group(1)!='transparent' else [0,0,0,0]
            for q in mm.group(2).split():
                v=float(q.replace('deg',''));st.append([v,c]);last=max(last,v)
        per=last if m.group(1) else 360.0
        return {'t':'con','cen':cen,'per':per,'st':[[v/per if per else 0,c] for v,c in st]}
    if kind=='linear':
        ang=180.0
        if not re.match(COLRE,parts[0]):
            a=parts.pop(0)
            if 'deg' in a: ang=float(a.replace('deg',''))
            elif a.startswith('to '):
                ang={'to top':0,'to right':90,'to bottom':180,'to left':270,'to bottom right':135,'to right bottom':135,'to top right':45,'to bottom left':225}.get(a,180)
        return {'t':'lin','ang':ang,'st':stops(parts)}
    else:
        shape=[0.7071,0.7071];cen=[0.5,0.5];circle=False
        if not re.match(COLRE,parts[0]):
            a=parts.pop(0)
            mm=re.search(r'at\s+('+NUM+r')%\s+('+NUM+r')%',a)
            if mm: cen=[float(mm.group(1))/100,float(mm.group(2))/100]
            if 'circle' in a: circle=True
            ss=re.findall(r'('+NUM+r')%',a.split(' at ')[0])
            if len(ss)>=2: shape=[float(ss[0])/100,float(ss[1])/100]
            elif len(ss)==1: shape=[float(ss[0])/100]*2
            px=re.findall(r'('+NUM+r')px',a.split(' at ')[0])
            if px: shape=['px',float(px[0]),float(px[-1])]
            if 'closest-side' in a: shape=[0.5,0.5]
        return {'t':'rad','cen':cen,'shape':shape,'circle':circle,'st':stops(parts)}
def shadows(s):
    if not s or s=='none': return []
    out=[]
    for p in split_top(s):
        c=re.search(COLRE,p);cc=col(c.group(1)) if c and c.group(1)!='transparent' else [0,0,0,0]
        rest=re.sub(COLRE,'',p)
        inset='inset' in rest;rest=rest.replace('inset','')
        nums=[float(x) for x in re.findall(NUM,rest)]
        while len(nums)<4: nums.append(0)
        out.append({'x':nums[0],'y':nums[1],'b':nums[2],'s':nums[3],'c':cc,'in':inset})
    return out
def tshadows(s):
    if not s or s=='none': return []
    out=[]
    for p in split_top(s):
        c=re.search(COLRE,p);cc=col(c.group(1)) if c else [0,0,0,1]
        nums=[float(x) for x in re.findall(NUM,re.sub(COLRE,'',p))]
        while len(nums)<3: nums.append(0)
        out.append({'x':nums[0],'y':nums[1],'b':nums[2],'c':cc})
    return out
def px(s):
    try: return float(str(s).replace('px','').split()[0])
    except: return 0.0
FONT={'Titan':'TitanOne','Sora':'Sora','PS2P':'PressStart2P','Lilita One':'LilitaOne','LilitaOne':'LilitaOne'}
def font(ff,fw):
    f=FONT.get(ff,'Sora')
    if f=='Sora':
        w=int(fw) if str(fw).isdigit() else 500
        f='Sora-800' if w>=800 else ('Sora-700' if w>=600 else 'Sora-500')
    return f
def matrix(tf):
    if not tf or tf=='none': return None
    m=re.match(r'matrix\(([^)]*)\)',tf)
    if m: return [float(x) for x in m.group(1).split(',')]
    return None
def convert(dump,outdir,name):
    os.makedirs(outdir+'/svg',exist_ok=True)
    L=[]
    for e in dump:
        n={'i':e['i'],'p':e['p'],'tag':e['tag'],'id':e['id'],'cls':e['cls'],'r':[round(e['x'],2),round(e['y'],2),round(e['w'],2),round(e['h'],2)],'op':e['op'],'z':e['z']}
        bg=[]
        bgi=e['bgi']
        text_grad=None
        if bgi and bgi!='none':
            for g in split_top(bgi):
                gg=grad(g)
                if gg: bg.append(gg)
                elif g.startswith('url('):
                    u=re.match(r'url\("?([^")]*)"?\)',g).group(1)
                    if u.startswith('data:'):
                        m=re.match(r'data:image/(\w+)(?:\+xml)?;base64,(.*)',u)
                        if m:
                            data=base64.b64decode(m.group(2));h=hashlib.md5(data).hexdigest()[:12]
                            os.makedirs(outdir+'/img',exist_ok=True);fn='img/%s.%s'%(h,m.group(1));open(outdir+'/'+fn,'wb').write(data);u='ui:'+fn
                    else: u=u.split('/art/')[-1] if '/art/' in u else u
                    bg.append({'t':'img','src':u,'size':e.get('bgsz',''),'pos':e.get('bgpos','')})
        bc=col(e['bgc'])
        if 'text' in str(e.get('bgclip','')):
            text_grad=bg[0] if bg else None;bg=[];bc=None
        box={}
        if bc and bc[3]>0: box['bgc']=bc
        if bg: box['bg']=bg
        bw=[px(x) for x in e['bw']]
        if e['bstyle']!='none' and max(bw)>0: box['bw']=bw;box['bcol']=col(e['bcol'])
        rad=[]
        for r in e['rad']:
            v=r.split()[0]
            rad.append(min(e['w'],e['h'])*float(v[:-1])/100 if v.endswith('%') else px(v))
        if max(rad)>0: box['rad']=rad
        sh=shadows(e['bs'])
        if sh: box['sh']=sh
        if box: n['box']=box
        txt=e['text']
        if e.get('tt')=='uppercase': txt=txt.upper()
        elif e.get('tt')=='lowercase': txt=txt.lower()
        e['text']=txt
        if e['text']:
            fcol=col(e['tfill']) if e.get('tfill') and col(e['tfill']) else col(e['col'])
            n['txt']={'s':e['text'],'font':font(e['ff'],e['fw']),'fs':e['fs'],'col':fcol,'ta':e['ta'],'ls':px(e['ls']) if e['ls']!='normal' else 0,
                'ts':tshadows(e['ts']),'stroke':[px(e['stroke'].split()[0]),col(' '.join(e['stroke'].split()[1:]) or 'rgba(0,0,0,0)')],'grad':text_grad}
        if e['tag']=='img':
            src=e['src']
            if src.startswith('data:'):
                m=re.match(r'data:image/(\w+)(?:\+xml)?;base64,(.*)',src)
                if m:
                    data=base64.b64decode(m.group(2));h=hashlib.md5(data).hexdigest()[:12]
                    os.makedirs(outdir+'/img',exist_ok=True)
                    fn='img/%s.%s'%(h,'svg' if m.group(1)=='svg' else m.group(1))
                    open(outdir+'/'+fn,'wb').write(data);src='ui:'+fn
            n['img']={'src':src,'fit':e['fit']}
        if e.get('canvas'): n['canvas']=1
        if e['tag']=='svg':
            h=hashlib.md5(e['svg'].encode()).hexdigest()[:10]
            fn='svg/%s.svg'%h
            svg=e['svg']
            if 'xmlns' not in svg: svg=svg.replace('<svg','<svg xmlns="http://www.w3.org/2000/svg"',1)
            open(outdir+'/'+fn,'w').write(svg)
            n['svg']=fn
        m=matrix(e['tf'])
        if m: n['tf']=m;n['tfo']=[px(x) for x in e['tfo'].split()[:2]]
        if e['filt'] and e['filt']!='none':
            n['filt']=e['filt'][:120]
            mb=re.search(r'blur\(('+NUM+r')px\)',e['filt'])
            imgs=[g for g in (box.get('bg') or []) if g.get('t')=='img']
            if mb and imgs:
                from PIL import Image,ImageFilter
                src=imgs[0]['src'];fn=src.split('/')[-1]
                path='/home/claude/crackers-match/app/src/main/assets/www/art/'+fn
                if os.path.exists(path):
                    im=Image.open(path).convert('RGBA');k=max(e['w']/im.width,e['h']/im.height)
                    os.makedirs(outdir+'/img',exist_ok=True)
                    out='img/blur%d_%s'%(int(float(mb.group(1))),fn)
                    im.filter(ImageFilter.GaussianBlur(float(mb.group(1))/k)).save(outdir+'/'+out)
                    n['blurimg']='ui:'+out
        if e.get('anim') and e['anim']!='none': n['anim']=e['anim']
        if e['ov']!='visible': n['clip']=1
        L.append(n)
    json.dump(L,open(outdir+'/'+name+'.json','w'))
    return L
if __name__=='__main__':
    d=json.load(open(sys.argv[1]))
    L=convert(d,sys.argv[2],sys.argv[3])
    print(len(L),'nodes')
