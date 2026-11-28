import re, random, json, sys
P='/home/claude/crackers-match/godot/scripts/levels.gd'
s=open(P).read()
ent=list(re.finditer(r'\{"name": "([^"]+)", "moves": (\d+)(.*?)\n\t\t "rows": \[(.*?)\]\}', s, re.S))
assert len(ent)==60, len(ent)
INTRO={11:'pot',18:'soda',23:'coco',34:'match',39:'news',44:'bangle',49:'gift',53:'dstack'}
CH={'pot':'p','soda':'s','coco':'n','match':'m','news':'e','bangle':'b','gift':'f','dstack':'d'}
CNT={'pot':(12,(18,28),32),'soda':(10,(14,20),24),'bangle':(10,(14,20),24),'dstack':(10,(14,20),24),
     'coco':(6,(8,12),14),'news':(6,(8,12),14),'gift':(6,(8,12),14),'match':(4,(6,8),10)}
CAB={'K','B','U','Q'}
rnd=random.Random(18)
out=[];report=[]
others_seq=[];known=[]
rot=0
others_i=0
for n,m in enumerate(ent,1):
    name,moves,mid,rows=m.group(1),int(m.group(2)),m.group(3),m.group(4)
    R=[r.strip().strip('"') for r in rows.split(',')]
    hard='"ltype": "h"' in mid
    cab=any(ch in CAB for r in R for ch in r)
    typ=None
    if n>=11:
        if n in INTRO:
            typ=INTRO[n]; known.append(typ)
        elif cab:
            # one cabinet type per level: the first type that appears
            first=None
            for r in R:
                for ch in r:
                    if ch in CAB and first is None: first=ch
            R=[''.join(first if ch in CAB else ch for ch in r) for r in R]
        else:
            # about 2 of every 3 non-cabinet levels get a breakable; pots are the main one
            if known and (n % 3 != 1 or hard):
                oth=[k for k in known if k!='pot']
                if not oth or rot%2==0: typ='pot'
                else:
                    typ=oth[others_i%len(oth)];others_i+=1
                rot+=1
    else:
        if cab:
            first=None
            for r in R:
                for ch in r:
                    if ch in CAB and first is None: first=ch
            R=[''.join(first if ch in CAB else ch for ch in r) for r in R]
    if typ:
        intro=n in INTRO
        lo,(a,b),hi=CNT[typ]
        want = lo if intro else (hi if hard else rnd.randint(a,b))
        g=[list(r) for r in R]
        crates=[(i,j) for i,r in enumerate(g) for j,ch in enumerate(r) if ch in 'cw']
        # breakables take crate cells from the top down (boards start tight, open up below)
        crates.sort(key=lambda p:(p[0],p[1]))
        if len(crates)<want:
            more=[(i,j) for i,r in enumerate(g) for j,ch in enumerate(r) if ch in 'xX']
            more.sort(key=lambda p:(p[0],p[1]))
            crates+=more
        put=0
        for (i,j) in crates:
            if put>=want: break
            g[i][j]=CH[typ];put+=1
        if put<want:
            # add more: plain cracker cells in the middle rows (from row 3), as a solid band
            free=[(i,j) for i,r in enumerate(g) for j,ch in enumerate(r) if ch=='.' and 3<=i<=len(g)-2]
            free.sort(key=lambda p:(-p[0],abs(p[1]-3.5)))
            for (i,j) in free:
                if put>=want: break
                g[i][j]=CH[typ];put+=1
        R=[''.join(r) for r in g]
        if intro and '"intro"' not in mid:
            mid=mid+', "intro": ["%s"]'%typ
        elif intro:
            mid=re.sub(r'"intro": \[', '"intro": ["%s", '%typ, mid)
        report.append((n,name,typ,put,intro))
    # moves: normal -30%, Hard -15% (levels 4+; lessons 1-3 unchanged)
    nm=moves
    if n>=4:
        nm=round(moves*(0.85 if hard else 0.7))
    out.append((m.span(), '{"name": "%s", "moves": %d%s\n\t\t "rows": [%s]}'%(name,nm,mid,', '.join('"%s"'%r for r in R))))
    if n>=11: report[-1:] = report[-1:]  # keep
res=s
for (a,b),t in reversed(out): res=res[:a]+t+res[b:]
res=res.replace("# Map letters: . cracker   # no cell   c crate   w 2-hit crate   g gold floor",
 "# Map letters: . cracker   # no cell   c crate   w 2-hit crate   g gold floor\n#   breakables (18 Nov): p clay pot  s soda  n coconut  m matchbox stack  e newspaper  b bangles  f gift wrap  d diya stack\n#   (one breakable type per level, one cabinet type per level; moves cut 30% / Hard 15% on 18 Nov)") if '# breakables (18 Nov)' not in res else res
open(P,'w').write(res)
for r in report: print(r)
