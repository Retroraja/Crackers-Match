// Crackers Match: special + special combos, and the cup shelf that breaks cup by cup.
// Add-on for fx.js (CrackersGame). Uses the game's own sprites, effects and sounds.
(function(){
var G=CrackersGame.prototype,act0=G.act,hitBig0=G.hitBig,drawOver0=G.drawOver;
function rnd(a,b){return a+Math.random()*(b-a)}
function snd(n,o){if(window.SFX)SFX.play(n,o||{})}
var KIND={6:'rocket',15:'rocket',16:'rocket',7:'pot',8:'chakra',9:'sky',10:'atom',11:'sparkler',12:'wala',13:'rail',14:'matchbox'};
G.uu=function(){return this.cx(1)-this.cx(0)};
G.rows=function(){return this.b.length};G.cols=function(){return this.b[0].length};

// ---------- swap two specials together ----------
G.act=function(r,c,dr,dc){
 if(!window.OLD&&!this.busy&&!this.over&&this.moves>0){var e=this.at2(r,c),t=this.at2(r+dr,c+dc);
  if(e&&t&&e.k>=6&&t.k>=6&&!this.stuck(e)&&!this.stuck(t)&&!(e.k==9&&t.k==9)){this.combo(r,c,r+dr,c+dc);return}}
 return act0.call(this,r,c,dr,dc)};
G.combo=function(r1,c1,r2,c2){var s=this,a=this.b[r1][c1],b=this.b[r2][c2],U=this.uu(),dx=c2-c1,dy=r2-r1;
 this.spend();this.busy=true;a.firing=b.firing=true;a.top=true;
 snd('swoosh',{v:.5,cut:.4});
 this.obj(function(c2_,t){var f=Math.min(t/.2,1),e=f*f;a.sx=dx*e;a.sy=dy*e;b.shakeT=.05;return f<1},.22);
 this.at(.22,function(){a.sx=a.sy=0;a.top=false;s.b[r1][c1]=null;s.b[r2][c2]=null;var x=s.cx(c2),y=s.cy(r2);
  s.stop=.06;s.flash=Math.max(s.flash,.3);s.shake=Math.max(s.shake,7);s.wave(x,y,22,520);
  s.ring(x,y,'#FFFFFF',U*1.5,10);s.ring(x,y,'#FFC62B',U*2.4,7);s.burst(x,y,['#FFD24A','#FFFFFF','#FF7A1A'],26,330);
  snd('thud',{v:1});
  var T=s.comboRun(a.k,b.k,r2,c2);s.finish(T)})};
G.comboRun=function(ka,kb,r,c){var A=KIND[ka],B=KIND[kb],key=[A,B].sort().join('|'),s=this;
 var other=function(n){return A==n?kb:ka};
 switch(key){
 case 'rocket|rocket':snd('rocket',{rate:.95});snd('rocket',{rate:1.08,v:.7,at:.05});['U','D','L','R'].forEach(function(d){s.cFly(r,c,d,{big:1})});return 1.15;
 case 'chakra|rocket':snd('chakra',{cut:1.2});this.cSpin(r,c,0,{S:.38,grow:.5});
  this.at(.38,function(){snd('rocket',{rate:.92});snd('rocket',{rate:1.06,v:.7,at:.06});for(var d=-1;d<=1;d++){s.cFly(r+d,c,'L',{big:1});s.cFly(r+d,c,'R',{big:1});s.cFly(r,c+d,'U',{big:1});s.cFly(r,c+d,'D',{big:1})}});return 1.5;
 case 'pot|rocket':var t1=this.cTarget(r,c);snd('flowerpot',{cut:.9});this.cCarry(r,c,t1[0],t1[1],other('pot'),.7);
  this.at(.72,function(){snd('rocket');['U','D','L','R'].forEach(function(d){s.cFly(t1[0],t1[1],d,{big:1})})});return 1.85;
 case 'pot|pot':snd('flowerpot');snd('flowerpot',{at:.55,rate:1.06,v:.8});this.cFountain(r,c,1.7);
  for(var w=0;w<3;w++)(function(w){s.at(.35+w*.42,function(){s.cPot(r,c,8,{h:150-w*20})})})(w);return 2.35;
 case 'chakra|chakra':snd('chakra',{cut:1.1});snd('atom',{at:.5,v:.9});this.cSpin(r,c,2,{S:.55,grow:1.1});return 1.45;
 case 'chakra|pot':var t2=this.cTarget(r,c);snd('flowerpot');this.cFountain(r,c,.9);this.cPot(r,c,8,{excl:[t2]});
  this.at(.25,function(){s.cCarry(r,c,t2[0],t2[1],8,.65)});this.at(.9,function(){snd('chakra',{cut:.9,rate:1.1});s.cSpin(t2[0],t2[1],1,{S:.28})});return 1.95;
 case 'rocket|sky':case 'chakra|sky':case 'pot|sky':snd('skyshot',{cut:2.6});return this.cConvertSky(r,c,other('sky'));
 }
 if(A=='matchbox'||B=='matchbox')return this.cMatchbox(r,c,A=='matchbox'?kb:ka);
 if(A=='atom'||B=='atom'){snd('atom');return this.cAtom(r,c)}
 // not designed yet: both fire together as a cross and a 3x3
 snd('rocket');snd('chakra',{cut:1});['U','D','L','R'].forEach(function(d){s.cFly(r,c,d,{big:1})});this.cSpin(r,c,1,{S:.3});return 1.3};

// ---------- building blocks ----------
var DIR={U:[-1,0],D:[1,0],L:[0,-1],R:[0,1]};
G.cFly=function(r,c,d,o){o=o||{};var s=this,U=this.uu(),dr=DIR[d][0],dc=DIR[d][1],x=this.cx(c),y=this.cy(r),sp=o.sp||720,sz=U*(o.big?1.75:1.5),
  img=d=='R'?15:d=='L'?16:6,rot=d=='D'?Math.PI:0,seen={},W=this.W,H=this.H,x0=this.cx(0),y0=this.cy(0);
 this.at(o.d||0,function(){s.ring(x,y,'#FFB800',U*1.2,6);s.obj(function(c2,t,dt){x+=dc*sp*dt;y+=dr*sp*dt;
  var L=U*2.4,g=c2.createLinearGradient(x-dc*L,y-dr*L,x,y);g.addColorStop(0,'rgba(255,170,40,0)');g.addColorStop(1,'rgba(255,214,90,.55)');
  c2.save();c2.strokeStyle=g;c2.lineCap='round';c2.lineWidth=U*(o.big?.42:.3);c2.beginPath();c2.moveTo(x-dc*L,y-dr*L);c2.lineTo(x,y);c2.stroke();c2.restore();
  s.spr(img,x,y,sz,rot);
  for(var k=0;k<4;k++)s.fx.push({k:'spark',x:x-dc*24+rnd(-7,7),y:y-dr*24+rnd(-7,7),z:0,vx:-dc*rnd(60,260)+rnd(-60,60),vy:-dr*rnd(60,260)+rnd(-60,60),vz:0,col:k%2?'#FF7A1A':'#FFD24A',a:0,l:rnd(.2,.42)});
  s.puff(x-dc*34,y-dr*34,'#F3F1FF',rnd(9,17));
  var rr=Math.round((y-y0)/U),cc=Math.round((x-x0)/U),key=rr+','+cc;if(!seen[key]&&s.at2(rr,cc)){seen[key]=1;s.hit(rr,cc,{d:0,dx:dc*220,dy:dr*220,pw:o.big?1.25:1})}
  return x>-80&&x<W+80&&y>-80&&y<H+80},3)})};
G.cSpin=function(r,c,rad,o){o=o||{};var s=this,U=this.uu(),x=this.cx(c),y=this.cy(r),rot=0,S=o.S||.42,blown=false,grow=o.grow||0;
 this.at(o.d||0,function(){s.obj(function(c2,q,dt){var spin=Math.min(q/S,1);rot+=(2+spin*34)*dt;var sz=U*(1.05+spin*(.35+grow)),z=spin*10,al=q>S?Math.max(0,1-(q-S)/.18):1;
  c2.globalAlpha=al;s.spr(8,x,y-z,sz,rot);c2.globalAlpha=1;
  if(q<S)for(var k=0;k<3;k++){var a=rot+k*2.09;s.fx.push({k:'spark',x:x+Math.cos(a)*sz*.45,y:y-z+Math.sin(a)*sz*.45,z:0,vx:-Math.sin(a)*rnd(120,300),vy:Math.cos(a)*rnd(120,300),vz:0,col:k==1?'#FF2FA8':'#FFC62B',a:0,l:rnd(.2,.4)})}
  if(q>=S&&!blown){blown=true;s.shake=Math.max(s.shake,6+rad*4);s.wave(x,y,16+rad*7,430);s.ring(x,y,'#FF2FA8',U*(rad+1)*1.2,9);if(rad>=2){s.flash=Math.max(s.flash,.45);s.stop=.05;s.spark(x,y,50,['#FF2FA8','#FFC62B','#FFFFFF'],560)}
   for(var a2=-rad;a2<=rad;a2++)for(var b2=-rad;b2<=rad;b2++){var dd=Math.max(Math.abs(a2),Math.abs(b2));s.hit(r+a2,c+b2,{d:dd*.06+rnd(0,.03),pw:1.15+rad*.12,dx:b2*70,dy:a2*70})}}
  return q<S+.2},S+.25)});return S};
G.cFountain=function(r,c,dur){var s=this,U=this.uu(),x=this.cx(c),y=this.cy(r);
 this.obj(function(c2,t){var sh=t<dur?rnd(-1.5,1.5):0;c2.globalAlpha=t>dur?Math.max(0,1-(t-dur)/.2):1;s.spr(7,x+sh,y,U*1.15);c2.globalAlpha=1;
  if(t<dur)for(var i=0;i<6;i++)s.fx.push({k:'spark',x:x+rnd(-5,5),y:y-U*.42,z:0,vx:rnd(-85,85),vy:rnd(-640,-340),vz:rnd(0,120),col:i%3?'#FFC62B':'#FFFFFF',a:0,l:rnd(.5,.85),g:900});return t<dur+.2},dur+.25)};
G.cCells=function(excl){var L=[],R=this.rows(),C=this.cols();for(var a=0;a<R;a++)for(var b=0;b<C;b++){var e=this.at2(a,b);if(e&&!e.dead&&!(excl||[]).some(function(p){return p[0]==a&&p[1]==b}))L.push([a,b])}return this.gpick(L)};
G.cPot=function(r,c,n,o){o=o||{};var s=this,U=this.uu(),x=this.cx(c),y=this.cy(r),T=this.cCells([[r,c]].concat(o.excl||[])).slice(0,n),h=o.h||140;
 T.forEach(function(q,i){var tx=s.cx(q[1]),ty=s.cy(q[0]);s.at(i*.07,function(){var sx=x,sy=y-U*.5;s.obj(function(c2,t){var u=Math.min(t/.42,1),hh=Math.sin(u*3.14),px=sx+(tx-sx)*u,py=sy+(ty-sy)*u-hh*h,rad=8+hh*10;
  c2.fillStyle='#FFB800';c2.beginPath();c2.arc(px,py,rad,0,6.3);c2.fill();c2.fillStyle='#FFFFFF';c2.beginPath();c2.arc(px,py,rad*.5,0,6.3);c2.fill();
  s.fx.push({k:'spark',x:px,y:py,z:0,vx:rnd(-40,40),vy:rnd(-20,60),vz:0,col:'#FFD24A',a:0,l:.3});
  if(u>=1){s.hit(q[0],q[1],{d:0,pw:1.2});return false}return true},.5)})});return T.length*.07+.45};
G.cTarget=function(r,c){var L=this.cCells([[r,c]]).filter(function(p){return Math.abs(p[0]-r)+Math.abs(p[1]-c)>=3});return L[0]||[r,c]};
G.cCarry=function(r,c,tr,tc,k2,dur){var s=this,U=this.uu(),x0=this.cx(c),y0=this.cy(r),x1=this.cx(tc),y1=this.cy(tr),img2=k2==15||k2==16?6:k2;
 this.obj(function(c2,t){var u=Math.min(t/dur,1),e=u<.5?2*u*u:1-2*(1-u)*(1-u),x=x0+(x1-x0)*e,y=y0+(y1-y0)*e-Math.sin(e*Math.PI)*U*2.2,sc=1+Math.sin(u*Math.PI)*.35;
  for(var k=0;k<3;k++)s.fx.push({k:'spark',x:x+rnd(-6,6),y:y+U*.35,z:0,vx:rnd(-50,50),vy:rnd(60,200),vz:0,col:k?'#FFC62B':'#FFFFFF',a:0,l:rnd(.25,.4)});
  s.spr(img2,x+U*.32*sc,y-U*.1,U*.95*sc,.35);s.spr(7,x-U*.12*sc,y,U*1.2*sc);
  if(u>=1){s.ring(x1,y1,'#FFFFFF',U*1.6,8);s.wave(x1,y1,14,460);s.shake=Math.max(s.shake,5);return false}return true},dur+.05)};
G.cStar=function(x,y,col,sz){var c2=this.x;c2.fillStyle=col;this.star(c2,x,y,sz);c2.fillStyle='#FFFFFF';this.star(c2,x,y,sz*.45)};
G.cConvertSky=function(r,c,k2){var s=this,U=this.uu(),x=this.cx(c),y=this.cy(r),by=-10,L=this.cCells([[r,c]]).filter(function(p){var e=s.at2(p[0],p[1]);return e.k>=0&&e.k<6&&!e.ob}).slice(0,12),kind=KIND[k2];
 this.obj(function(c2,t){var u=Math.min(t/.4,1),ee=u*u,py=y+(by-y)*ee;s.spr(9,x,py,U*(1.4-.5*ee));s.puff(x+rnd(-5,5),py+22,'#FFFFFF',rnd(7,13));return u<1},.42);
 this.at(.42,function(){s.burst(x,40,['#FFD24A','#FFFFFF','#FF5FB2'],30,300);s.flash=Math.max(s.flash,.25)});
 L.forEach(function(p,i){var tx=s.cx(p[1]),ty=s.cy(p[0]),sx=x+rnd(-60,60);s.at(.5+i*.06,function(){s.obj(function(c2,t){var u=Math.min(t/.34,1),px=sx+(tx-sx)*u,py=by+(ty-by)*u*u;
   s.cStar(px,py,'#FFC62B',12);s.fx.push({k:'spark',x:px,y:py,z:0,vx:rnd(-20,20),vy:-rnd(20,70),vz:0,col:'#FFD24A',a:0,l:.22});
   if(u>=1){var e=s.at2(p[0],p[1]);if(e&&!e.dead&&e.k<6){e.k=kind=='rocket'?[6,15,16][Math.random()*3|0]:k2;e.safe=s.clock+.2;e.shakeT=.2;s.ring(tx,ty,'#FFC62B',U*1.1,6);s.spark(tx,ty,10,['#FFD24A','#FFFFFF'],180);snd('tick',{v:.35,rate:1.3+i*.04});p.ok=1}return false}return true},.36)})});
 var t0=.5+L.length*.06+.55;return this.cFireSeq(L,t0,kind=='chakra'?.22:.16)};
G.cFireSeq=function(L,t0,gap){var s=this,n=0;L.forEach(function(p){s.at(t0+n*gap,function(){var e=s.at2(p[0],p[1]);if(!e||e.dead||e.k<6)return;s.cFire(p[0],p[1],e)});n++});return t0+n*gap+(gap>.2?.7:1.05)};
G.cFire=function(r,c,e){var s=this,k=e.k;this.b[r][c]=null;e.queued=false;this.pop(this.cx(c),this.cy(r),'#FFC62B',1);
 if(k==6){snd('rocket',{v:.5,rate:rnd(.95,1.12)});this.cFly(r,c,'U')}else if(k==15){snd('rocket',{v:.5,rate:rnd(.95,1.12)});this.cFly(r,c,'R')}else if(k==16){snd('rocket',{v:.5,rate:rnd(.95,1.12)});this.cFly(r,c,'L')}
 else if(k==8){snd('chakra',{v:.55,cut:.8,rate:rnd(1,1.15)});this.cSpin(r,c,1,{S:.22})}else if(k==7){snd('flowerpot',{v:.5,cut:.8});this.cFountain(r,c,.4);this.cPot(r,c,5,{})}};
G.cMatchbox=function(r,c,k2){var s=this,U=this.uu(),x=this.cx(c),y=this.cy(r),col=this.top(),kind=KIND[k2],L=[];snd('matchbox');
 for(var a=0;a<this.rows();a++)for(var b=0;b<this.cols();b++){var e=this.at2(a,b);if(e&&!e.dead&&!e.ob&&e.k==col)L.push([a,b])}
 L.forEach(function(p,i){var tx=s.cx(p[1]),ty=s.cy(p[0]);s.at(.3+i*.04,function(){s.obj(function(c2,t){var u=Math.min(t/.26,1),X=x+(tx-x)*u,Y=y+(ty-y)*u;c2.strokeStyle='#FFC62B';c2.lineWidth=5*(1-u)+1.5;c2.beginPath();c2.moveTo(X-(tx-x)*.3,Y-(ty-y)*.3);c2.lineTo(X,Y);c2.stroke();
   if(u>=1){var e=s.at2(p[0],p[1]);if(e&&!e.dead&&e.k==col){e.k=kind=='rocket'?[6,15,16][Math.random()*3|0]:(kind=='sky'||kind=='atom'||kind=='matchbox')?8:k2;e.safe=s.clock+.2;e.shakeT=.2;s.ring(tx,ty,'#FFC62B',U,6)}return false}return true},.3)})});
 return this.cFireSeq(L,.3+L.length*.04+.5,.14)};
G.cAtom=function(r,c){var s=this,U=this.uu(),r0=Math.max(0,Math.min(this.rows()-6,r-2)),c0=Math.max(0,Math.min(this.cols()-6,c-2)),bx=this.cx(c0)+U*2.5,by=this.cy(r0)+U*2.5;
 this.obj(function(c2,t){s.spr(10,s.cx(c)+rnd(-2,2),s.cy(r)+rnd(-2,2),U*1.25);for(var k=0;k<3;k++)s.fx.push({k:'spark',x:s.cx(c)+7,y:s.cy(r)-U*.44,z:0,vx:rnd(-110,110),vy:rnd(-190,-30),vz:0,col:k?'#FFC62B':'#FFFFFF',a:0,l:.22});return t<.24},.25);
 this.at(.26,function(){s.stop=.07;s.flash=.55;s.shake=18;s.wave(bx,by,32,430);s.wave(bx,by,14,300);
  s.obj(function(c2,t){var u=Math.min(t/.36,1),rad=30+U*2.3*Math.sqrt(u);c2.globalAlpha=1-u;c2.fillStyle='#FF7A1A';c2.beginPath();c2.arc(bx,by,rad,0,6.3);c2.fill();c2.fillStyle='#FFD24A';c2.beginPath();c2.arc(bx,by,rad*.68,0,6.3);c2.fill();c2.fillStyle='#FFFFFF';c2.beginPath();c2.arc(bx,by,rad*.36,0,6.3);c2.fill();c2.globalAlpha=1;return u<1},.38);
  s.ring(bx,by,'#FF7A1A',U*4,12);for(var a=0;a<6;a++)for(var b=0;b<6;b++){var dd=Math.max(Math.abs(a-2.5),Math.abs(b-2.5));s.hit(r0+a,c0+b,{d:.02+dd*.07,pw:1.45,dx:(b-2.5)*48,dy:(a-2.5)*48})}s.spark(bx,by,70,['#FF7A1A','#FFC62B','#FFFFFF'],680)});
 return 1.3};

// ---------- cup shelf: cups break one by one ----------
var CUPS=[[27,52,63,46],[89,52,63,46],[150,52,64,46],[27,108,63,46],[88,108,64,46],[150,108,64,45],[27,164,62,45],[88,164,63,46],[150,164,63,47]].map(function(b,i){var im=new Image();im.src='art/cup'+i+'.webp';return{x:b[0],y:b[1],w:b[2],h:b[3],img:im}});
var EMPTY=new Image();EMPTY.src='art/cups-empty.webp';window.CUP_IMGS=CUPS;
var SHELF={wood:EMPTY},BITS={wood:['#B66A2E','#8A4A1C','#D9965A'],glass:['#FFFFFF','#CFE6FF','#9CC6F2'],mint:['#7FD9BC','#3FA98C','#D6F7EC'],candy:['#FF5FA8','#D41B7A','#FFC2DF'],white:['#FFFFFF','#E3DFEA','#E8AF37']};
['glass','mint','candy','white'].forEach(function(k){var im=new Image();im.src='art/shelf-'+k+'.webp';SHELF[k]=im});
window.SHELF_STYLE='glass';function EMP(){return SHELF[window.SHELF_STYLE]||EMPTY}function WOOD(){return BITS[window.SHELF_STYLE]||BITS.wood}
// crack lines in shelf image space (234 x 233)
var CR1=[[[14,70],[20,84],[15,95],[22,110],[18,122]],[[96,22],[104,30],[100,38],[110,44]],[[212,150],[218,162],[213,170],[220,182]]],
    CR2=[[[218,64],[212,78],[219,90],[213,104],[220,116]],[[40,104],[58,101],[66,105],[84,102]],[[16,170],[22,184],[15,196],[21,208]],[[150,158],[168,161],[176,157],[196,160]],[[124,10],[132,20],[127,30]]];
G.drawOver=function(c,e,x,y,s){var o=e.ob;if(!(o&&o.t=='big'&&o.B.t=='cups'&&!window.OLD))return drawOver0.call(this,c,e,x,y,s);if(!o.anchor)return;
 var B=o.B,U=this.uu(),W=B.w*U-(U-s),H=B.h*U-(U-s),k=1+B.sq*.06;B.sq=Math.max(0,B.sq-.06);if(!B.cups)B.cups=CUPS.map(function(){return true});
 var left=B.cups.filter(Boolean).length,tilt=left<=3?Math.sin(this.clock*2)*.006:0;
 c.save();c.translate(x+W/2,y+H/2);c.rotate(tilt);c.scale(k,2-k);
 c.fillStyle='rgba(255,248,238,.55)';c.beginPath();c.roundRect(-W/2,-H/2,W,H,14);c.fill();
 var ar=234/233,dw=W*1.04,dh=dw/ar;if(dh>H*1.06){dh=H*1.06;dw=dh*ar}var sc=dw/234,ox=-dw/2,oy=-dh/2-2;
 var EI=EMP();if(EI.naturalWidth)c.drawImage(EI,ox,oy,dw,dh);
 CUPS.forEach(function(cp,i){if(B.cups[i]&&cp.img.naturalWidth)c.drawImage(cp.img,ox+cp.x*sc,oy+cp.y*sc,cp.w*sc,cp.h*sc)});
 var crk=function(L){L.forEach(function(p){c.beginPath();p.forEach(function(q,i){var a=ox+q[0]*sc,b=oy+q[1]*sc;i?c.lineTo(a,b):c.moveTo(a,b)});c.strokeStyle='rgba(255,214,160,.55)';c.lineWidth=2.2;c.stroke();c.strokeStyle='#3A1804';c.lineWidth=1.3;c.stroke()})};
 c.lineJoin='round';c.lineCap='round';if(B.cr1)crk(CR1);if(B.cr2)crk(CR2);
 B.geo={cx:x+W/2,cy:y+H/2,ox:ox,oy:oy,sc:sc};
 var tx=String(B.n);c.font='15px Titan,sans-serif';var bw=Math.max(26,c.measureText(tx).width+14);c.fillStyle='#1F1B3A';c.beginPath();c.roundRect(W/2-bw-2,H/2-24,bw,22,11);c.fill();c.fillStyle='#fff';c.textAlign='center';c.textBaseline='middle';c.fillText(tx,W/2-bw/2-2,H/2-12.5);
 c.restore()};
G.hitBig=function(B,blast){if(B.t!='cups'||window.OLD)return hitBig0.call(this,B,blast);
 if(B.n<=0||B.safe>this.clock)return;if(!B.cups)B.cups=CUPS.map(function(){return true});B.safe=this.clock+(blast?.3:.25);B.sq=1;
 var s=this,n=blast?2:1,D=DEB,U=this.uu();this.shake=Math.max(this.shake,3);
 for(var i=0;i<n&&B.n>0;i++){var alive=[];B.cups.forEach(function(a,j){if(a)alive.push(j)});if(!alive.length)break;var j=alive[Math.random()*alive.length|0];B.cups[j]=false;B.n--;this.addScore(60);this.breakCup(B,j,i*.08)}
 var left=B.n;
 if(left<=6&&!B.cr1){B.cr1=1;this.splinters(B)}if(left<=3&&!B.cr2){B.cr2=1;this.splinters(B)}
 if(B.n<=0)this.shelfDown(B)};
G.cupXY=function(B,j){var g=B.geo,cp=CUPS[j];if(!g){var U=this.uu();g={cx:this.cx(B.c)+(B.w-1)*U/2,cy:this.cy(B.r)+(B.h-1)*U/2,ox:-B.w*U*.52,oy:-B.h*U*.52,sc:B.w*U*1.04/234}}
 return{x:g.cx+g.ox+(cp.x+cp.w/2)*g.sc,y:g.cy+g.oy+(cp.y+cp.h/2)*g.sc,w:cp.w*g.sc,h:cp.h*g.sc}};
G.breakCup=function(B,j,d){var s=this;this.at(d,function(){var p=s.cupXY(B,j),cp=CUPS[j],S=p.w;
 DEB.chunks(cp.img,p.x-S/2,p.y-S/2,S,3,2,.95,{g:1500});DEB.bits(p.x,p.y,10,['#FFF8EE','#F3E9DA','#E3B04B','#8FB2E6'],5,1,{shape:'tri'});
 s.spark(p.x,p.y,10,['#FFFFFF','#FFE7A8'],190);s.ring(p.x,p.y,'#FFFFFF',p.w*.9,4);
 var k=9-B.n;snd('tick',{rate:1.55+k*.06,v:.5});snd('paper',{rate:1.25+k*.03,v:.55});
 if(s.goal.cups>0){s.goal.cups--;if(s.cb.fly)s.cb.fly('cups',p.x,p.y,j);if(s.cb.goal)s.cb.goal(s.goal)}})};
G.splinters=function(B){var g=B.geo||{cx:this.cx(B.c),cy:this.cy(B.r)},U=this.uu();DEB.bits(g.cx-U*.9,g.cy,6,WOOD(),5,.8);DEB.bits(g.cx+U*.9,g.cy,6,WOOD(),5,.8);snd('paper',{rate:.75,v:.7});snd('thud',{v:.5,rate:1.2})};
G.shelfDown=function(B){var U=this.uu(),x=this.cx(B.c)+(B.w-1)*U/2,y=this.cy(B.r)+(B.h-1)*U/2,S=Math.max(B.w,B.h)*U;
 for(var r=B.r;r<B.r+B.h;r++)for(var c=B.c;c<B.c+B.w;c++){if(this.at2(r,c))this.b[r][c]=null}
 var EI=EMP();if(EI.naturalWidth)DEB.chunks(EI,x-S/2,y-S/2,S,3,3,1.25,{g:1500});DEB.bits(x,y,16,WOOD(),7,1.3);
 this.shake=Math.max(this.shake,10);this.flash=Math.max(this.flash,.35);this.burst(x,y,['#FFD24A','#FFFFFF','#FF7A1A'],30,320);snd('thud',{v:1});snd('paper',{rate:.6,v:.8})};
})();
