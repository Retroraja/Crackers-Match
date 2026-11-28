// in-page: dump an element tree with the computed CSS the Godot builder needs
(root)=>{
 const CRKmap=new Map();try{CRK.b.forEach((u,i)=>{if(u)CRKmap.set(u,'crk:b'+i)});CRK.t.forEach((u,i)=>{if(u)CRKmap.set(u,'crk:t'+i)})}catch(e){}
 const out=[];let n=0;
 const R=typeof root=='string'?document.getElementById(root):root;
 const sel='#'+R.id+',#'+R.id+' *,#'+R.id+' *::before,#'+R.id+' *::after,#'+R.id+'::before,#'+R.id+'::after';
 const st1=document.createElement('style');st1.textContent=sel.split(',').map(s=>s).join(',')+'{animation:none!important;transition:none!important}';document.head.appendChild(st1);
 const all=[R,...R.querySelectorAll('*')];const TF=new Map();
 all.forEach(e=>{const c=getComputedStyle(e);TF.set(e,[c.transform,c.transformOrigin,c.opacity]);
   for(const ps of ['::before','::after']){const p=getComputedStyle(e,ps);TF.set(e.tagName+ps+(e.id||'')+all.indexOf(e),[p.transform,p.transformOrigin,p.opacity])}});
 const anims=new Map();
 st1.remove();all.forEach(e=>anims.set(e,getComputedStyle(e).animationName));document.head.appendChild(st1);
 const st2=document.createElement('style');st2.textContent=sel+'{transform:none!important}';document.head.appendChild(st2);
 const css=(o,cs,e)=>Object.assign(o,{ff:cs.fontFamily.split(',')[0].replace(/"/g,''),fw:cs.fontWeight,fs:parseFloat(cs.fontSize),lh:cs.lineHeight,ls:cs.letterSpacing,ta:cs.textAlign,tt:cs.textTransform,
   col:cs.color,bgc:cs.backgroundColor,bgi:cs.backgroundImage,bgsz:cs.backgroundSize,bgpos:cs.backgroundPosition,bgclip:cs.webkitBackgroundClip||cs.backgroundClip,
   rad:[cs.borderTopLeftRadius,cs.borderTopRightRadius,cs.borderBottomRightRadius,cs.borderBottomLeftRadius],
   bw:[cs.borderTopWidth,cs.borderRightWidth,cs.borderBottomWidth,cs.borderLeftWidth],bcol:cs.borderTopColor,bstyle:cs.borderTopStyle,
   bs:cs.boxShadow,ts:cs.textShadow,stroke:cs.webkitTextStrokeWidth+' '+cs.webkitTextStrokeColor,tfill:cs.webkitTextFillColor,
   filt:cs.filter,z:cs.zIndex,ov:cs.overflow,pos:cs.position,fit:cs.objectFit,ws:cs.whiteSpace});
 const walk=(e,par)=>{
  const cs=getComputedStyle(e);const tfv=TF.get(e)||['none','',cs.opacity];
  if(cs.display=='none'||cs.visibility=='hidden')return;
  const r=e.getBoundingClientRect();
  const tag=e.tagName.toLowerCase();
  const id=n++;
  const t=[...e.childNodes].filter(x=>x.nodeType==3).map(x=>x.textContent).join('').replace(/\s+/g,' ').trim();
  const o={i:id,p:par,tag,id:e.id||'',cls:(typeof e.className=='string'?e.className:''),x:r.x,y:r.y,w:r.width,h:r.height,text:t,op:(e===R?1:+tfv[2]),tf:tfv[0],tfo:tfv[1],anim:anims.get(e)};
  css(o,cs,e);
  if(tag=='img'){const s=e.getAttribute('src')||'';o.src=s.startsWith('data:')?(CRKmap.get(s)||s):s;o.nw=e.naturalWidth;o.nh=e.naturalHeight}
  if(tag=='canvas'){o.canvas=1}
  if(tag=='svg'){o.svg=e.outerHTML;out.push(o);return}
  out.push(o);
  const pseudo=(ps)=>{const p=getComputedStyle(e,ps);if(!p.content||p.content=='none'||p.display=='none')return;
    let x=r.x,y=r.y,w=r.width,h=r.height;
    if(p.position=='absolute'||p.position=='fixed'){const L=parseFloat(p.left),T=parseFloat(p.top),W=parseFloat(p.width),H=parseFloat(p.height),Rr=parseFloat(p.right),B=parseFloat(p.bottom);
      const bl=parseFloat(cs.borderLeftWidth)||0,bt=parseFloat(cs.borderTopWidth)||0;
      w=isNaN(W)?r.width-bl*2-(L||0)-(Rr||0):W;h=isNaN(H)?r.height-bt*2-(T||0)-(B||0):H;
      x=r.x+bl+(isNaN(L)?(r.width-bl*2-w-(Rr||0)):L);y=r.y+bt+(isNaN(T)?(r.height-bt*2-h-(B||0)):T)}
    const pid=n++;const pt=(p.content||'').replace(/^"|"$/g,'');
    const tf2=TF.get(e.tagName+ps+(e.id||'')+all.indexOf(e))||['none','',p.opacity];
    const q={i:pid,p:id,tag:ps,id:'',cls:'',x,y,w,h,text:(pt&&pt!='""'&&!pt.startsWith('url'))?pt:'',op:+tf2[2],tf:tf2[0],tfo:tf2[1],anim:p.animationName};css(q,p,e);out.push(q)};
  pseudo('::before');
  for(const c of e.children)walk(c,id);
  pseudo('::after');
 };
 walk(R,-1);st1.remove();st2.remove();return out}
