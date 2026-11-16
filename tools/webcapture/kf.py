# CSS @keyframes -> ui/anims.json : {name: [[offset, {tx,ty,sx,sy,rot,op}], ...]}
import re,json
css=open('/tmp/claude-0/-home-claude/c1abc257-f372-5299-bfd4-1351ef767cd6/scratchpad/allcss.css').read()
NUM=r'-?\d*\.?\d+'
def tfp(s):
    o={}
    if s.strip()=='none': return {'tx':0,'ty':0,'sx':1,'sy':1,'rot':0}
    for f,a in re.findall(r'(\w+)\(([^)]*)\)',s):
        v=[x.strip() for x in a.split(',')]
        def px(x):
            if x.endswith('vh'): return float(x[:-2])*8.44
            if x.endswith('%'): return ('%',float(x[:-1]))
            try: return float(x.replace('px',''))
            except: return 0
        if f=='translate': o['tx']=px(v[0]);o['ty']=px(v[1]) if len(v)>1 else 0
        elif f=='translateX': o['tx']=px(v[0])
        elif f=='translateY': o['ty']=px(v[0])
        elif f=='scale': o['sx']=float(v[0]);o['sy']=float(v[1]) if len(v)>1 else float(v[0])
        elif f=='rotate': o['rot']=float(v[0].replace('deg',''))
    return o
out={}
for name,body in re.findall(r'@keyframes\s+([\w-]+)\s*\{((?:[^{}]*\{[^{}]*\})*)\s*\}',css):
    frames=[]
    for sel,decl in re.findall(r'([^{}]+)\{([^{}]*)\}',body):
        props={}
        for k,v in re.findall(r'([\w-]+)\s*:\s*([^;]+)',decl):
            k=k.strip();v=v.strip()
            if k=='transform': props.update(tfp(v))
            elif k=='opacity': props['op']=float(v)
            elif k=='scale': p=v.split();props['sx']=float(p[0]);props['sy']=float(p[1]) if len(p)>1 else float(p[0])
            elif k=='translate':
                p=v.split()
                if p and not p[0].startswith('var'):
                    props['tx']=float(p[0].replace('px',''));props['ty']=float(p[1].replace('px','')) if len(p)>1 else 0
                else: props['tvar']=1
            elif k=='rotate':
                if v.startswith('var'): props['rvar']=1
                else: props['rot']=float(v.replace('deg',''))
            elif k=='left': props['left']=v
            elif k=='box-shadow': props['glow']=v
            elif k=='filter': props['filter']=v
        for s in sel.split(','):
            s=s.strip()
            off=0.0 if s=='from' else 1.0 if s=='to' else float(s.replace('%',''))/100
            frames.append([off,props])
    frames.sort(key=lambda x:x[0])
    out[name]=frames
json.dump(out,open('/home/claude/crackers-match/godot/ui/anims.json','w'),indent=0)
print(len(out))
