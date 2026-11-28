import base64,json,os,sys
H=os.path.dirname(os.path.abspath(__file__));R='/home/claude/repo'
def b64(p):return base64.b64encode(open(p,'rb').read()).decode()
A={'pot':'data:image/webp;base64,'+b64(R+'/app/src/main/assets/www/art/pot.webp'),
   'rocket':'data:image/webp;base64,'+b64(H+'/crk_15.webp'),'bomb':'data:image/webp;base64,'+b64(H+'/crk_10.webp')}
S={f[:-4]:b64(H+'/sfx/'+f) for f in os.listdir(H+'/sfx') if f.endswith('.wav')}
for k in ('rocket','atom','blast'):S[k]=b64(R+'/godot/sfx/'+k+'.mp3')
t=open(H+'/breakables.tpl.html').read().replace('__ASSETS__',json.dumps(A)).replace('__SFX__',json.dumps(S))
open(H+'/breakables.html','w').write(t);print(len(t)//1024,'KB')
