(function(){
var COL=['#E8123C','#1E5BFF','#0DB865','#2B3FBF','#8A2BE2','#FF6A00'];
var ID={rocket:6,flowerpot:7,chakra:8,skyshot:9,atom:10,sparkler:11,wala:12,rail:13,matchbox:14};
var C=7,R=7,U=52,OX=13,OY=56;
function rnd(a,b){return a+Math.random()*(b-a)}
var TH={glass:{tray:'rgba(255,255,255,.42)',slot:'rgba(70,90,140,.17)'},studio:{tray:'#FFF4E3',slot:'#E8CFB2'},foil:{tray:'#14243F',slot:'#0B1730'}};
function FX(cv,theme){var s=this;this.th=TH[theme||'glass'];var tt=CRK.t.slice();if(CRK.themes[theme])CRK.themes[theme].forEach(function(u,i){tt[i]=u});this.cv=cv;var d=Math.min(window.devicePixelRatio||1,3);this.W=390;this.H=cv.clientHeight||450;cv.width=this.W*d;cv.height=this.H*d;
 this.x=cv.getContext('2d');this.x.scale(d,d);this.T=[];this.B=[];var n=0,N=tt.length+CRK.b.length;
 function ld(u,a,i){var m=new Image();m.onload=function(){if(++n==N)s.boot()};m.src=u;a[i]=m}
 tt.forEach(function(u,i){ld(u,s.T,i)});CRK.b.forEach(function(u,i){ld(u,s.B,i)});
 this.fx=[];this.ev=[];this.waves=[];this.clock=0;this.stop=0;this.shake=0;this.dim=0;this.flash=0;this.busy=false;
 this.polys=[];for(var i=0;i<10;i++){var a=i/10*6.283,b=(i+1)/10*6.283,m=(a+b)/2;this.polys.push([[.5+rnd(-.08,.08),.5+rnd(-.08,.08)],[.5+Math.cos(a)*.8,.5+Math.sin(a)*.8],[.5+Math.cos(m)*.86,.5+Math.sin(m)*.86],[.5+Math.cos(b)*.8,.5+Math.sin(b)*.8]])}}
var P=FX.prototype;
P.boot=function(){this.bind();this.fresh();if(!this.isGame)this.b[3][3].k=ID.sparkler;this.last=performance.now();var s=this;requestAnimationFrame(function f(t){if(s.stopped)return;s.tick(t);requestAnimationFrame(f)});if(this.pending){var p=this.pending;this.pending=null;this.play(p)}};
P.fresh=function(){this.b=[];for(var r=0;r<R;r++){this.b[r]=[];for(var c=0;c<C;c++){var k;do{k=Math.random()*6|0}while((c>1&&this.b[r][c-1].k==k&&this.b[r][c-2].k==k)||(r>1&&this.b[r-1][c].k==k&&this.b[r-2][c].k==k));this.b[r][c]=this.tile(k)}}};
P.tile=function(k){return{k:k,fy:0,v:0,p:0}};
P.cx=function(c){return OX+c*U+U/2};P.cy=function(r){return OY+r*U+U/2};
P.at=function(t,f){this.ev.push({t:this.clock+t,f:f})};
P.ring=function(x,y,col,size,w){this.fx.push({k:'ring',x:x,y:y,a:0,col:col,sz:size||70,w:w||8,l:.32})};
P.spark=function(x,y,n,col,sp,up){for(var i=0;i<n;i++){var a=Math.random()*6.283,v=rnd(.3,1)*(sp||330);this.fx.push({k:'spark',x:x,y:y,z:0,vx:Math.cos(a)*v,vy:Math.sin(a)*v-(up||60),vz:rnd(0,200),col:typeof col=='string'?col:col[i%col.length],a:0,l:rnd(.3,.65)})}};
P.puff=function(x,y,col,r){this.fx.push({k:'puff',x:x,y:y,r:r||10,col:col||'#FFFFFF',a:0,l:.45,vy:-rnd(8,28),vx:rnd(-14,14)})};
P.wave=function(x,y,amp,sp){this.waves.push({x:x,y:y,t:this.clock,amp:amp||12,sp:sp||520})};
P.hit=function(r,c,o){o=o||{};var e=this.b[r]&&this.b[r][c];if(!e||e.dead)return;e.dead=true;e.p=1;var s=this;this.at(o.d||.05,function(){s.smash(r,c,o)})};
P.smash=function(r,c,o){var e=this.b[r][c];if(!e)return;var x=this.cx(c),y=this.cy(r),u=U,col=COL[e.k]||'#FFB800',pw=(o.pw||1)*1.25,fxc=this;this.pop(x,y,col,pw);this.shake=Math.max(this.shake,2.5*pw);
 this.polys.forEach(function(po){var mx=(po[1][0]+po[3][0])/2-.5,my=(po[1][1]+po[3][1])/2-.5,v=rnd(190,360)*pw;
  this.fx.push({k:'shard',po:po,im:this.T[e.k],x:x,y:y,z:0,vx:mx*v*1.5+(o.dx||0),vy:my*v*1.5-90+(o.dy||0),vz:rnd(160,420)*pw,r:0,vr:rnd(-14,14),f:rnd(0,6),vf:rnd(7,16),a:0})},this);
 this.spark(x,y,20,[col,'#FFFFFF','#FFD24A','#FF7A1A'],360*pw);this.ring(x,y,'#FFC62B',u*.8,4);this.wave(x,y,6*pw,420);this.b[r][c]=null};
P.pop=function(x,y,col,pw){this.fx.push({k:'obj',a:0,l:.2,fn:function(c,t){var q=Math.min(t/.2,1),r=(14+30*pw*Math.sqrt(q));c.globalAlpha=1-q;c.fillStyle='#FF7A1A';c.beginPath();c.arc(x,y,r,0,6.3);c.fill();c.fillStyle=col;c.beginPath();c.arc(x,y,r*.74,0,6.3);c.fill();c.fillStyle='#FFE16B';c.beginPath();c.arc(x,y,r*.48,0,6.3);c.fill();c.fillStyle='#FFFFFF';c.beginPath();c.arc(x,y,r*.24,0,6.3);c.fill();c.globalAlpha=1;return q<1}})};
P.setSpecial=function(k,r,c){this.b[r][c]=this.tile(ID[k]);return this.b[r][c]};
P.obj=function(fn,l){this.fx.push({k:'obj',fn:fn,a:0,l:l})};
P.spr=function(i,x,y,sz,rot,sy){var c=this.x;c.save();c.translate(x,y);if(rot)c.rotate(rot);c.scale(1,sy||1);c.drawImage(this.B[i],-sz/2,-sz/2,sz,sz);c.restore()};
P.finish=function(t){var s=this;this.at(t,function(){s.refill()})};
P.refill=function(){for(var c=0;c<C;c++){var w=R-1;for(var r=R-1;r>=0;r--){var e=this.b[r][c];if(e){if(w!=r){this.b[w][c]=e;this.b[r][c]=null;e.fy=(w-r)*U;e.v=0;e.dl=c*.02}w--}}
 var miss=w+1;for(r=w;r>=0;r--){var t=this.tile(this.rk?this.rk():Math.random()*6|0);t.fy=(miss+1)*U;t.dl=c*.02+r*.0;t.v=0;this.b[r][c]=t}}if(!this.isGame)this.b[3][3].k=ID.sparkler;this.dropping=true};
P.play=function(n){if(!this.b){this.pending=n;return}if(this.busy)return;this.busy=true;this[n]()};
// --- specials
P.rocketGo=function(dir){var s=this,D={up:[-1,0,6,5,3],right:[0,1,15,3,1],left:[0,-1,16,3,5]}[dir],dr=D[0],dc=D[1],i=D[2],r=D[3],c=D[4];var e=this.tile(i);this.b[r][c]=e;e.shakeT=.34;var x=this.cx(c),y=this.cy(r);
 this.at(.36,function(){s.b[r][c]=null;s.pop(x,y,'#FF2FA8',1.3);s.ring(x,y,'#FFB800',90,9);s.wave(x,y,18);s.shake=6;var sp=640;
  s.obj(function(c2,t,dt){x+=dc*sp*dt;y+=dr*sp*dt;s.spr(i,x,y,U*1.55);for(var k=0;k<4;k++)s.fx.push({k:'spark',x:x-dc*24+rnd(-7,7),y:y-dr*24+rnd(-7,7),z:0,vx:-dc*rnd(60,260)+rnd(-60,60),vy:-dr*rnd(60,260)+rnd(-60,60),vz:0,col:k%2?'#FF7A1A':'#FFD24A',a:0,l:rnd(.2,.42)});s.puff(x-dc*34,y-dr*34,'#F3F1FF',rnd(9,17));
   var rr=Math.round((y-OY-U/2)/U),cc=Math.round((x-OX-U/2)/U);if(rr>=0&&rr<R&&cc>=0&&cc<C&&s.b[rr][cc]&&!s.b[rr][cc].dead)s.hit(rr,cc,{d:0,dx:dc*220,dy:dr*220});return x>-70&&x<460&&y>-70&&y<s.H+70},1)});
 this.finish(1.25)};
P.rocketUp=function(){this.rocketGo('up')};P.rocketLeft=function(){this.rocketGo('left')};P.rocketRight=function(){this.rocketGo('right')};
P.flowerpot=function(){var s=this,r=4,c=3,e=this.setSpecial('flowerpot',r,c),x=this.cx(c),y=this.cy(r);e.shakeT=.2;
 var T=[],A=[];for(var a=0;a<R;a++)for(var b=0;b<C;b++)if(a!=r||b!=c)A.push([a,b]);A.sort(function(){return Math.random()-.5});T=A.slice(0,7);
 this.obj(function(c2,t){if(t<1.2){for(var i=0;i<6;i++)s.fx.push({k:'spark',x:x+rnd(-5,5),y:y-U*.42,z:0,vx:rnd(-85,85),vy:rnd(-640,-340),vz:rnd(0,120),col:i%3?'#FFC62B':'#FFFFFF',a:0,l:rnd(.5,.85),g:900})}return t<1.25},1.3);
 T.forEach(function(q,i){var tx=s.cx(q[1]),ty=s.cy(q[0]);s.at(.5+i*.1,function(){var sx=x,sy=y-U*.5;s.obj(function(c2,t,dt){var u=Math.min(t/.42,1),h=Math.sin(u*3.14),px=sx+(tx-sx)*u,py=sy+(ty-sy)*u-h*150,rad=8+h*11;
   c2.fillStyle='#FFB800';c2.beginPath();c2.arc(px,py,rad,0,6.3);c2.fill();c2.fillStyle='#FFFFFF';c2.beginPath();c2.arc(px,py,rad*.5,0,6.3);c2.fill();s.fx.push({k:'spark',x:px,y:py,z:0,vx:rnd(-40,40),vy:rnd(-20,60),vz:0,col:'#FFD24A',a:0,l:.3});
   if(u>=1){s.hit(q[0],q[1],{d:0,pw:1.2});return false}return true},.5)})});
 this.at(1.45,function(){s.hit(r,c,{d:0,pw:1.2});});this.finish(1.75)};
P.chakra=function(){var s=this,r=3,c=1,e=this.setSpecial('chakra',r,c),i=ID.chakra,xs=this.cx(c),y=this.cy(r),rot=0,done={},first=false;
 this.at(.03,function(){s.b[r][c]=null;s.obj(function(c2,t,dt){var spin=Math.min(t/.55,1),w=2+spin*34;rot+=w*dt;var mv=t<.8?0:Math.min((t-.8)/.8,1),x=xs+mv*4*U,z=spin*10,sz=U*(1.05+spin*.35);s.spr(i,x,y-z,sz,rot);
   for(var k=0;k<3;k++){var a=rot+k*2.09;s.fx.push({k:'spark',x:x+Math.cos(a)*sz*.45,y:y-z+Math.sin(a)*sz*.45,z:0,vx:-Math.sin(a)*rnd(120,300),vy:Math.cos(a)*rnd(120,300),vz:0,col:k==1?'#FF2FA8':'#FFC62B',a:0,l:rnd(.2,.4)})}
   if(t>.55&&!first){first=true;s.shake=7;s.wave(xs,y,18,430);s.ring(xs,y,'#FF2FA8',U*2,8);for(var a2=-1;a2<=1;a2++)for(var b2=-1;b2<=1;b2++)if(c+b2>=0&&(a2||b2))s.hit(r+a2,c+b2,{d:rnd(0,.05),pw:1.15})}
   var cell=Math.round((x-OX-U/2)/U);if(mv>0&&cell>=c+2&&cell<=c+4&&!done[cell]){done[cell]=1;s.hit(r,cell,{d:0,dx:150})}return t<1.65},1.7)});
 this.finish(1.95)};
P.top=function(){var n={};for(var r=0;r<R;r++)for(var c=0;c<C;c++){var e=this.b[r][c];if(e&&e.k<6)n[e.k]=(n[e.k]||0)+1}var b=0,m=-1;for(var k in n)if(n[k]>m){m=n[k];b=+k}return b};
P.burst=function(x,y,cols,n,sp){for(var i=0;i<n;i++){var a=i/n*6.283,v=(sp||300)*rnd(.72,1);this.fx.push({k:'spark',x:x,y:y,z:0,vx:Math.cos(a)*v,vy:Math.sin(a)*v,vz:0,col:cols[i%cols.length],a:0,l:rnd(.5,.8),g:320,w:3.4})}this.ring(x,y,cols[0],130,9)};
P.skyshot=function(o){o=o||{};var s=this,r=o.r==null?5:o.r,c=o.c==null?3:o.c,e=o.r==null?this.setSpecial('skyshot',r,c):this.b[r][c],x=this.cx(c),y=this.cy(r),i=ID.skyshot,col=o.col==null?this.top():o.col;e.shakeT=.2;var by=30;
 this.at(.22,function(){s.b[r][c]=null;s.ring(x,y,'#FFFFFF',80,8);s.wave(x,y,16);
  s.obj(function(c2,t){var u=Math.min(t/.48,1),ee=u*u,py=y+(by-y)*ee,sz=U*(1.5-.55*ee);s.spr(i,x,py,sz);s.puff(x+rnd(-5,5),py+22,'#FFFFFF',rnd(7,13));for(var k=0;k<3;k++)s.fx.push({k:'spark',x:x+rnd(-5,5),y:py+24,z:0,vx:rnd(-45,45),vy:rnd(40,200),vz:0,col:k?'#FF9A1F':'#FFE16B',a:0,l:.3});return u<1},.52)});
 this.at(.72,function(){s.burst(x,by,[COL[col],'#FFFFFF','#FFC62B'],36,330);s.flash=.28;
  var L=[];for(var rr=0;rr<R;rr++)for(var cc=0;cc<C;cc++){var q=s.b[rr][cc];if(q&&!q.dead&&(!o.rain?q.k==col:((rr!=r||cc!=c)&&((o.dr||0)==0&&(o.dc||0)==0||(rr-r)*(o.dr||0)+(cc-c)*(o.dc||0)>=0))))L.push([rr,cc])}if(o.rain){if(s.gpick)L=s.gpick(L);else L.sort(function(){return Math.random()-.5});L=L.slice(0,12)}
  L.forEach(function(p,n){var tx=s.cx(p[1]),ty=s.cy(p[0]),d=.1+n*.055,sx=x+rnd(-34,34);s.at(d,function(){s.obj(function(c2,t){var u=Math.min(t/.36,1),px=sx+(tx-sx)*u,py=by+(ty-by)*u*u;var sz=12;c2.fillStyle=COL[col];s.star(c2,px,py,sz);c2.fillStyle='#FFFFFF';s.star(c2,px,py,sz*.5);s.fx.push({k:'spark',x:px,y:py,z:0,vx:rnd(-20,20),vy:-rnd(20,70),vz:0,col:COL[col],a:0,l:.22});if(u>=1){s.hit(p[0],p[1],{d:0,pw:1.1});return false}return true},.4)})});
  s.finish(.1+L.length*.055+.75)})};
P.star=function(c,x,y,r){c.beginPath();for(var i=0;i<10;i++){var a=-1.57+i*.628,q=i%2?r*.45:r;c[i?'lineTo':'moveTo'](x+Math.cos(a)*q,y+Math.sin(a)*q)}c.closePath();c.fill()};
P.atom=function(o){o=o||{};var s=this,r=o.r==null?3:o.r,c=o.c==null?3:o.c,r0=o.r0==null?2:o.r0,c0=o.c0==null?2:o.c0,e=o.r==null?this.setSpecial('atom',r,c):this.b[r][c],x=this.cx(c),y=this.cy(r),i=ID.atom,bx=this.cx(c0)+U*1.5,by=this.cy(r0)+U*1.5;
 var F=.24;e.shakeT=F;this.obj(function(c2,t){for(var k=0;k<3;k++)s.fx.push({k:'spark',x:x+7,y:y-U*.44,z:0,vx:rnd(-110,110),vy:rnd(-190,-30),vz:0,col:k?'#FFC62B':'#FFFFFF',a:0,l:.22});return t<F},F+.01);
 this.at(F+.02,function(){s.stop=.06;s.flash=.5;s.shake=16;s.dim=0;s.wave(bx,by,30,430);s.wave(bx,by,12,300);
  s.obj(function(c2,t){var u=Math.min(t/.34,1),rad=30+U*1.7*Math.sqrt(u);c2.globalAlpha=1-u;c2.fillStyle='#FF7A1A';c2.beginPath();c2.arc(bx,by,rad,0,6.3);c2.fill();c2.fillStyle='#FFD24A';c2.beginPath();c2.arc(bx,by,rad*.68,0,6.3);c2.fill();c2.fillStyle='#FFFFFF';c2.beginPath();c2.arc(bx,by,rad*.36,0,6.3);c2.fill();c2.globalAlpha=1;return u<1},.36);
  s.ring(bx,by,'#FF7A1A',U*3.2,12);for(var a=0;a<4;a++)for(var b=0;b<4;b++){var rr=r0+a,cc=c0+b,dd=Math.max(Math.abs(a-1.5),Math.abs(b-1.5));s.hit(rr,cc,{d:.02+dd*.08,pw:1.4,dx:(b-1.5)*48,dy:(a-1.5)*48})}s.spark(bx,by,60,['#FF7A1A','#FFC62B','#FFFFFF'],640)});
 this.finish(F+1)};
P.sparkler=function(){var d=[[0,1],[0,-1],[-1,0],[1,0]][Math.random()*4|0];this.fire(d[0],d[1])};
P.zig=function(r,c,dr,dc){var side=(dr!=0)?(c<C-1?1:-1):(r<R-1?1:-1),p=[[r,c]],seq=[[dr,dc],[dc?side:0,dr?side:0],[dr,dc],[dc?-side:0,dr?-side:0],[dr,dc]];seq.forEach(function(d){var l=p[p.length-1],n=[l[0]+d[0],l[1]+d[1]];if(n[0]>=0&&n[0]<R&&n[1]>=0&&n[1]<C)p.push(n)});return p};
P.fire=function(dr,dc){this.busy=true;this.armed=false;if(this.mode)this.runShape(dr,dc);else this.runSpark(this.zig(3,3,dr,dc))};
P.shape=function(dr,dc){var L=[],sx=dr?1:0,sy=dc?1:0,m=this.mode,or=this.or==null?3:this.or,oc=this.oc==null?3:this.oc;function add(d,w){L.push([or+dr*d+sy*w,oc+dc*d+sx*w,d])}
 if(m=='fan'){add(1,0);[-1,0,1].forEach(function(w){add(2,w)});[-2,-1,0,1,2].forEach(function(w){add(3,w)})}
 if(m=='fork'){add(1,0);add(2,0);add(3,0);add(3,-1);add(3,1)}
 if(m=='cross'){[[0,1],[0,-1],[1,0],[-1,0]].forEach(function(q){[1,2].forEach(function(d){L.push([3+q[0]*d,3+q[1]*d,d])})})}
 return L.filter(function(p){return p[0]>=0&&p[0]<R&&p[1]>=0&&p[1]<C})};
P.runShape=function(dr,dc){var s=this,L=this.shape(dr,dc),or=this.or==null?3:this.or,oc=this.oc==null?3:this.oc,x=this.cx(oc),y=this.cy(or),m=this.mode,i=ID.sparkler,all=m=='cross';this.b[or][oc]=null;this.pop(x,y,'#FFC62B',1.3);this.ring(x,y,'#FFC62B',70,7);
 this.obj(function(c2,t){var u=Math.min(t/.14,1);s.spr(i,x+dc*10*u,y+dr*10*u-10,U*1.35,all?t*9:Math.atan2(dc,-dr));for(var k=0;k<8;k++){var a=all?Math.random()*6.283:Math.atan2(dr,dc)+rnd(-.75,.75)*(m=='fan'?1:.3),v=rnd(150,430);s.fx.push({k:'spark',x:x,y:y,z:0,vx:Math.cos(a)*v,vy:Math.sin(a)*v,vz:0,col:k%2?'#FFFFFF':'#FFD24A',a:0,l:rnd(.2,.45),g:260})}return t<.55},.6);
 L.forEach(function(p){var tx=s.cx(p[1]),ty=s.cy(p[0]),d=.08+p[2]*.11;s.at(d,function(){s.obj(function(c2,t){var u=Math.min(t/.1,1),X=x+(tx-x)*u,Y=y+(ty-y)*u;c2.strokeStyle='#FFC62B';c2.lineWidth=4;c2.lineCap='round';c2.beginPath();c2.moveTo(X-(tx-x)*.12,Y-(ty-y)*.12);c2.lineTo(X,Y);c2.stroke();if(u>=1){s.hit(p[0],p[1],{d:0,pw:1.15,dx:dc*120,dy:dr*120});return false}return true},.14)})});
 this.finish(1.05)};
P.cell=function(ev){var b=this.cv.getBoundingClientRect(),k=this.W/b.width;var c=Math.floor(((ev.clientX-b.left)*k-OX)/U),r=Math.floor(((ev.clientY-b.top)*k-OY)/U);return[r,c]};
P.bind=function(){var s=this,cv=this.cv;cv.style.touchAction='none';var sx=0,sy=0;
 cv.addEventListener('pointerdown',function(ev){if(s.busy)return;var q=s.cell(ev),e=s.b[3][3];if(q[0]==3&&q[1]==3&&e&&e.k==ID.sparkler){s.armed=true;sx=ev.clientX;sy=ev.clientY;try{cv.setPointerCapture(ev.pointerId)}catch(e2){}}});
 cv.addEventListener('pointermove',function(ev){if(!s.armed||s.busy)return;var b=cv.getBoundingClientRect(),k=s.W/b.width,dx=(ev.clientX-sx)*k,dy=(ev.clientY-sy)*k;if(Math.abs(dx)<18&&Math.abs(dy)<18)return;if(Math.abs(dx)>Math.abs(dy))s.fire(0,dx>0?1:-1);else s.fire(dy>0?1:-1,0)});
 cv.addEventListener('pointerup',function(){s.armed=false})};
P.runSpark=function(ord){var s=this,i=ID.sparkler,N=ord.length-1,last=0,dur=N*.2;this.b[ord[0][0]][ord[0][1]]=null;this.pop(this.cx(ord[0][1]),this.cy(ord[0][0]),'#FFC62B',1.2);
 this.obj(function(c2,t){var u=Math.min(t/dur,.9999)*N,n=Math.floor(u),f=u-n,a=ord[n],b=ord[n+1],x=s.cx(a[1])+(s.cx(b[1])-s.cx(a[1]))*f,y=s.cy(a[0])+(s.cy(b[0])-s.cy(a[0]))*f;s.spr(i,x+6,y-12,U*1.25,.28);
  for(var k=0;k<7;k++){var aa=Math.random()*6.283,v=rnd(80,300);s.fx.push({k:'spark',x:x+18,y:y-34,z:0,vx:Math.cos(aa)*v,vy:Math.sin(aa)*v,vz:0,col:k%2?'#FFFFFF':'#FFD24A',a:0,l:rnd(.2,.45),g:420})}
  if(f>.55&&n+1>last){last=n+1;s.hit(ord[last][0],ord[last][1],{d:0,pw:1.15})}return t<dur+.02},dur+.05);
 this.finish(dur+.55)};
P.wala=function(o){o=o||{};var s=this,r=o.r==null?0:o.r,c=o.c==null?3:o.c,e=o.r==null?this.setSpecial('wala',r,c):this.b[r][c],x=this.cx(c),y=this.cy(r),L=[];e.shakeT=.2;
 for(var a=0;a<R;a++)for(var b=0;b<C;b++)if(!(a==r&&b==c)&&(o.r==null||(a-r)*o.dr+(b-c)*o.dc>=0))L.push([a,b]);L.sort(function(){return Math.random()-.5});L=L.slice(0,15);
 this.at(.22,function(){s.b[r][c]=null;s.ring(x,y,'#E8123C',70,7);var px=x,py=y;
  L.forEach(function(p,n){s.at(n*.085,function(){var sx=px,sy=py,tx=s.cx(p[1]),ty=s.cy(p[0]);px=tx;py=ty;s.obj(function(c2,t){var u=Math.min(t/.1,1),X=sx+(tx-sx)*u,Y=sy+(ty-sy)*u-Math.sin(u*3.14)*38;c2.strokeStyle='#E8123C';c2.lineWidth=7;c2.lineCap='round';c2.beginPath();c2.moveTo(X-6,Y-3);c2.lineTo(X+6,Y+3);c2.stroke();c2.strokeStyle='#FFC62B';c2.lineWidth=2;c2.beginPath();c2.moveTo(sx,sy);c2.lineTo(X,Y);c2.stroke();if(u>=1){s.hit(p[0],p[1],{d:0});s.shake=Math.max(s.shake,3);return false}return true},.13)})})});
 this.finish(.22+15*.085+.7)};
P.rail=function(){var s=this,r=2,e=this.setSpecial('rail',r,0),i=ID.rail;e.shakeT=.16;var y1=this.cy(r),y2=this.cy(r+1);
 this.obj(function(c2,t){var u=Math.min(t/.15,1);c2.strokeStyle='#8A7A5A';c2.lineWidth=2.4;c2.globalAlpha=1;c2.beginPath();c2.moveTo(0,y1-22);c2.lineTo(390*u,y1-22);c2.stroke();c2.beginPath();c2.moveTo(390,y2-22);c2.lineTo(390-390*u,y2-22);c2.stroke();return t<1.6},1.65);
 this.at(.18,function(){s.b[r][0]=null;var d1=[],d2=[];s.obj(function(c2,t){var L=390-OX*2-U,x,y,u=t/.56,dir=1;if(u<1){x=OX+U/2+L*u;y=y1;}else if(u<1.25){var w=(u-1)*4;x=OX+U/2+L;y=y1+(y2-y1)*w;dir=0}else{var v=Math.min((u-1.25)/1,1);x=OX+U/2+L*(1-v);y=y2;dir=-1}
   s.spr(i,x,y-6,U*1.3);if(dir){for(var k=0;k<4;k++)s.fx.push({k:'spark',x:x-dir*30,y:y+rnd(-8,6),z:0,vx:-dir*rnd(120,380),vy:rnd(-90,90),vz:0,col:k%2?'#FFC62B':'#E8123C',a:0,l:.3});s.puff(x-dir*36,y,'#FFFFFF',rnd(6,11))}
   var cc=Math.round((x-OX-U/2)/U);if(dir>0&&!d1[cc]){d1[cc]=1;s.hit(r,cc,{d:0,dx:190});s.shake=Math.max(s.shake,2)}if(dir<0&&!d2[cc]){d2[cc]=1;s.hit(r+1,cc,{d:0,dx:-190});s.shake=Math.max(s.shake,2)}return u<2.27},1.32)});
 this.finish(1.9)};
P.matchbox=function(o){o=o||{};var s=this,r=o.r==null?3:o.r,c=o.c==null?3:o.c,e=o.r==null?this.setSpecial('matchbox',r,c):this.b[r][c],x=this.cx(c),y=this.cy(r),col=o.col==null?this.top():o.col,i=ID.matchbox,G=['#E8123C','#1E5BFF','#0DB865','#FFC62B','#8A2BE2','#FF6A00'];e.shakeT=.2;
 this.at(.15,function(){s.b[r][c]=null;s.obj(function(c2,t){var u=Math.min(t/.5,1);s.spr(i,x,y-u*16,U*(1+u*.35));for(var k=0;k<6;k++){var a=k*1.047+t*7,rad=20+u*62;c2.fillStyle=G[k];c2.beginPath();c2.arc(x+Math.cos(a)*rad,y-16+Math.sin(a)*rad,8.5,0,6.3);c2.fill();c2.fillStyle='rgba(255,255,255,.8)';c2.beginPath();c2.arc(x+Math.cos(a)*rad-2.5,y-16+Math.sin(a)*rad-2.5,2.6,0,6.3);c2.fill()}return t<.72},.74)});
 this.at(.86,function(){s.ring(x,y,COL[col],120,9);s.burst(x,y-16,[COL[col],'#FFFFFF'],22,260);s.wave(x,y,16);var L=[];for(var rr=0;rr<R;rr++)for(var cc=0;cc<C;cc++){var q=s.b[rr][cc];if(q&&q.k==col)L.push([rr,cc])}
  L.forEach(function(p,n){var tx=s.cx(p[1]),ty=s.cy(p[0]);s.at(n*.04,function(){s.obj(function(c2,t){var u=Math.min(t/.26,1),X=x+(tx-x)*u,Y=y-16+(ty-y+16)*u;c2.strokeStyle=COL[col];c2.lineWidth=5*(1-u)+1.5;c2.beginPath();c2.moveTo(X-(tx-x)*.3,Y-(ty-y)*.3);c2.lineTo(X,Y);c2.stroke();c2.fillStyle='#FFFFFF';c2.beginPath();c2.arc(X,Y,6,0,6.3);c2.fill();if(u>=1){s.hit(p[0],p[1],{d:0,pw:1.15});return false}return true},.3)})});
  s.finish(L.length*.04+.8)})};
P.finale=function(){var s=this;var xs=[this.cx(1),this.cx(5)];this.shake=4;
 xs.forEach(function(x,n){s.obj(function(c2,t){var u=Math.min(t/.45,1),py=OY+U*6.5+(24-(OY+U*6.5))*u*u;s.spr(ID.skyshot,x,py,U*(1.4-.5*u));s.puff(x,py+22,'#FFFFFF',rnd(6,12));return u<1},.48)});
 var cols=[['#FF2FA8','#FFFFFF','#FFC62B'],['#1E5BFF','#FFFFFF','#0DB865'],['#FF6A00','#FFFFFF','#FFC62B'],['#8A2BE2','#FFFFFF','#E8123C']];
 this.at(.5,function(){s.stop=.05;s.flash=.45;s.burst(xs[0],24,cols[0],30,300);s.burst(xs[1],24,cols[1],30,300)});
 for(var r=0;r<R;r++)(function(r){s.at(.65+r*.24,function(){s.shake=Math.max(s.shake,7);s.wave(195,s.cy(r),18,600);s.burst(rnd(50,340),rnd(10,40),cols[r%4],24,240);for(var c=0;c<C;c++)s.hit(r,c,{d:Math.abs(c-3)*.035,pw:1.25})})})(r);
 this.at(.75,function(){s.obj(function(c2,t){var u=Math.min(t/.16,1),sc=u<1?.4+u*.9:1.3-.3*Math.min((t-.16)/.14,1),a=t>1.1?Math.max(0,1-(t-1.1)/.25):1,X=195+Math.sin(t*50)*(t<.4?3:0),Y=OY+U*3.7;c2.save();c2.translate(X,Y);c2.rotate(-.05);c2.scale(sc,sc);c2.globalAlpha=a;c2.font='800 66px Sora, sans-serif';c2.textAlign='center';c2.textBaseline='middle';for(var d=9;d>0;d--){c2.fillStyle=d>4?'#7A1FB8':'#E8123C';c2.fillText('BLAST!',d*.7,d)}c2.lineWidth=9;c2.lineJoin='round';c2.strokeStyle='#FFFFFF';c2.strokeText('BLAST!',0,0);var g=c2.createLinearGradient(0,-34,0,34);g.addColorStop(0,'#FFF06A');g.addColorStop(1,'#FF8A1F');c2.fillStyle=g;c2.fillText('BLAST!',0,0);c2.restore();return t<1.36},1.4)});
 this.finish(.65+R*.24+.75)};
// --- frame
P.tick=function(n){var dt=Math.min((n-this.last)/1000,.04);this.last=n;var s=this;
 if(this.stop>0){this.stop-=dt;dt*=.06}
 this.clock+=dt;var due=this.ev.filter(function(e){return e.t<=s.clock});this.ev=this.ev.filter(function(e){return e.t>s.clock});due.forEach(function(e){e.f()});
 this.waves=this.waves.filter(function(w){return s.clock-w.t<.8});this.shake*=.88;this.flash*=.84;
 if(this.dropping){var done=true;for(var r=0;r<R;r++)for(var c=0;c<C;c++){var e=this.b[r][c];if(!e)continue;if(e.fy>0||e.bo){e.tt=(e.tt||0)+dt;if(e.tt<(e.dl||0)){done=false;continue}if(e.fy>0){e.v+=4200*dt;e.fy-=e.v*dt;if(e.fy<=0){e.fy=0;e.bo=.1}done=false}else{e.bo-=dt;if(e.bo<=0){e.bo=0;e.v=0;e.tt=0}done=false}}}
  if(done){this.dropping=false;this.busy=false;if(this.onDone)this.onDone()}}
 this.draw(dt)};
P.bump=function(x,y){var z=0,ox=0,oy=0;for(var i=0;i<this.waves.length;i++){var w=this.waves[i],t=this.clock-w.t,dx=x-w.x,dy=y-w.y,d=Math.sqrt(dx*dx+dy*dy)+.01,ph=d-w.sp*t,g=Math.exp(-ph*ph/1500)*w.amp*Math.max(0,1-t/.7);z+=g;ox+=dx/d*g*.45;oy+=dy/d*g*.45}return[z,ox,oy]};
P.draw=function(dt){var c=this.x,s=this,u=U;c.clearRect(0,0,this.W,this.H);c.save();if(this.shake>.3)c.translate(rnd(-1,1)*this.shake,rnd(-1,1)*this.shake);
 if(this.drawFloor)this.drawFloor(c,u);else{c.fillStyle=this.th.tray;c.beginPath();c.roundRect(OX-9,OY-9,u*C+18,u*R+18,22);c.fill();for(var r0=0;r0<R;r0++)for(var k0=0;k0<C;k0++){c.fillStyle=this.th.slot;c.beginPath();c.roundRect(OX+k0*u+3,OY+r0*u+3,u-6,u-6,11);c.fill()}}
 var r,k;
 for(var pass=0;pass<2;pass++)for(r=R-1;r>=0;r--)for(k=0;k<C;k++){var e=this.b[r][k];if(!e||(pass==0)==!!e.top)continue;var x=OX+k*u+(e.sx||0)*u,y=OY+r*u-(e.fy||0)+(e.sy||0)*u;if(e.bo>0)y-=Math.sin(e.bo/.1*3.14)*5;var b=this.bump(x+u/2,y+u/2),z=b[0],sz=u*(1+z/70);
  if(e.shakeT>0){e.shakeT-=dt;x+=rnd(-2.5,2.5);y+=rnd(-2.5,2.5);sz*=1.05}
  var px=x+b[1]+(u-sz)/2,py=y+b[2]+(u-sz)/2-z*.55;if(y+u<OY-14)continue;if(e.diya)c.drawImage(this.IC.diya,px+.5,py+.5,sz-1,sz-1);else if(this.isGame&&e.k>=6){var pu=.5+.5*Math.sin(this.clock*5+r+k),s2=sz*(1.08+.05*pu),ox2=px+(sz-s2)/2,oy2=py+(sz-s2)/2-3;c.save();c.fillStyle='rgba(60,30,90,.28)';c.beginPath();c.ellipse(px+sz/2,py+sz*.96,sz*.42,sz*.1,0,0,6.3);c.fill();c.shadowColor='#FFB400';c.shadowBlur=14+14*pu;c.drawImage(this.T[e.k],ox2,oy2,s2,s2);c.shadowBlur=0;c.strokeStyle='#FFC62B';c.lineWidth=3;c.beginPath();c.roundRect(ox2+1,oy2+1,s2-2,s2-2,11);c.stroke();c.beginPath();c.roundRect(ox2+1,oy2+1,s2-2,s2-2,11);c.clip();var sw=((this.clock*.55+(r+k)*.13)%1)*s2*2.4-s2*.7;c.fillStyle='rgba(255,255,255,.55)';c.beginPath();c.moveTo(ox2+sw,oy2);c.lineTo(ox2+sw+12,oy2);c.lineTo(ox2+sw-s2*.4+12,oy2+s2);c.lineTo(ox2+sw-s2*.4,oy2+s2);c.fill();c.restore()}else c.drawImage(this.T[e.k],px+.5,py+.5,sz-1,sz-1);if(this.drawOver)this.drawOver(c,e,px,py,sz);
  if(e.mark){c.strokeStyle='#FFC62B';c.lineWidth=3;c.beginPath();c.roundRect(px+3,py+3,sz-6,sz-6,10);c.stroke()}
  if(e.dead){c.fillStyle='rgba(255,255,255,.62)';c.beginPath();c.roundRect(px+3,py+3,sz-6,sz-6,11);c.fill()}}
 if(this.drawRg)this.drawRg(c,u);
 if(this.dim>.01){c.fillStyle='rgba(30,20,70,'+this.dim+')';c.beginPath();c.roundRect(OX-9,OY-9,u*C+18,u*R+18,22);c.fill()}
 var cur=this.fx;this.fx=[];var keep=cur.filter(function(f){f.a+=dt;
  if(f.k=='ring'){var q=f.a/f.l;if(q>1)return false;c.strokeStyle=f.col;c.globalAlpha=1-q;c.lineWidth=f.w*(1-q)+1;c.beginPath();c.arc(f.x,f.y,u*.25+f.sz*q,0,6.3);c.stroke();c.globalAlpha=1;return true}
  if(f.k=='spark'){f.vy+=(f.g||720)*dt;f.vx*=.985;var ox=f.x,oy=f.y;f.x+=f.vx*dt;f.y+=f.vy*dt;if(f.a>f.l)return false;c.strokeStyle=f.col;c.globalAlpha=Math.min(1,(f.l-f.a)*6);c.lineWidth=f.w||2.6;c.lineCap='round';c.beginPath();c.moveTo(f.x,f.y);c.lineTo(ox-f.vx*.016,oy-f.vy*.016);c.stroke();c.globalAlpha=1;return true}
  if(f.k=='puff'){f.x+=f.vx*dt;f.y+=f.vy*dt;var q2=f.a/f.l;if(q2>1)return false;c.fillStyle=f.col;c.globalAlpha=.75*(1-q2);c.beginPath();c.arc(f.x,f.y,f.r*(1+q2*1.5),0,6.3);c.fill();c.globalAlpha=1;return true}
  if(f.k=='obj'){return f.fn(c,f.a,dt)!==false&&f.a<=Math.max(f.l,.01)}
  f.vy+=900*dt;f.vz-=880*dt;f.x+=f.vx*dt;f.y+=f.vy*dt;f.z+=f.vz*dt;f.r+=f.vr*dt;f.f+=f.vf*dt;if(f.a>.95)return false;var sc=Math.max(.35,1+f.z/190);
  c.save();c.translate(f.x,f.y-f.z*.3);c.rotate(f.r);c.scale(sc,sc*(Math.abs(Math.cos(f.f))*.85+.15));c.globalAlpha=Math.min(1,(.95-f.a)*5);c.translate(-u/2,-u/2);c.beginPath();f.po.forEach(function(p,i){i?c.lineTo(p[0]*u,p[1]*u):c.moveTo(p[0]*u,p[1]*u)});c.closePath();c.clip();c.drawImage(f.im,0,0,u,u);c.restore();return true});
 this.fx=keep.concat(this.fx);if(this.fx.length>900)this.fx=this.fx.slice(-900);
 c.restore();if(this.flash>.02){c.fillStyle='rgba(255,255,255,'+this.flash*.75+')';c.fillRect(0,0,this.W,this.H)}};

// --- live drag board
var HOME=[['rocket',1,1],['atom',1,3],['flowerpot',1,5],['matchbox',3,1],['sparkler',3,3],['rail',3,5],['skyshot',5,0],['skyshot',5,1],['chakra',5,3],['wala',5,5]];
function Board(cv){this.mode='fork';FX.call(this,cv)}Board.prototype=Object.create(P);var B=Board.prototype;B.constructor=Board;
B.park=function(){HOME.forEach(function(h){var e=this.b[h[1]][h[2]];if(e){e.k=h[0]=='rocket'?[6,15,16][Math.random()*3|0]:ID[h[0]];e.dead=false;e.mark=0}},this)};
B.fresh=function(){P.fresh.call(this);this.park()};
B.refill=function(){P.refill.call(this);this.park()};
B.bind=function(){var s=this,cv=this.cv;cv.style.touchAction='none';
 function xy(ev){var b=cv.getBoundingClientRect(),k=s.W/b.width;return[(ev.clientX-b.left)*k,(ev.clientY-b.top)*k]}
 cv.addEventListener('pointerdown',function(ev){if(s.busy)return;var q=s.cell(ev),e=q[0]>=0&&q[0]<R&&q[1]>=0&&q[1]<C?s.b[q[0]][q[1]]:null;if(!e||e.k<6)return;var p=xy(ev);s.arm={r:q[0],c:q[1],k:e.k,x:p[0],y:p[1],px:p[0],py:p[1],place:false};try{cv.setPointerCapture(ev.pointerId)}catch(e2){}});
 cv.addEventListener('pointermove',function(ev){var a=s.arm;if(!a)return;var p=xy(ev);a.px=p[0];a.py=p[1];if(a.place)return;var dx=p[0]-a.x,dy=p[1]-a.y;if(Math.abs(dx)<16&&Math.abs(dy)<16)return;s.arm=null;if(Math.abs(dx)>Math.abs(dy))s.go(a,0,dx>0?1:-1);else s.go(a,dy>0?1:-1,0)});
 cv.addEventListener('pointerup',function(ev){var a=s.arm;s.arm=null;if(!a)return;if(!a.place){s.go(a,0,0);return}var q=s.cell(ev);if(q[0]<0||q[0]>=R||q[1]<0||q[1]>=C||(q[0]==a.r&&q[1]==a.c))return;s.drop(a,q)})};
B.go=function(a,dr,dc){this.busy=true;var s=this,k=a.k,r=a.r,c=a.c,t=this.nextOf(r,c,dr,dc),tr=t[0],tc=t[1],n=this.b[tr][tc],tap=!dr&&!dc,col=(n&&n.k<6&&!tap)?n.k:this.top();
 if(k==ID.skyshot&&n&&n.k==ID.skyshot&&!tap){this.slide(r,c,tr,tc,function(){s.b[r][c]=null;s.b[tr][tc]=null;s.finale()});return}
 this.slide(r,c,tr,tc,function(){
  if(k==6){s.dRocket(tr,tc,-1,0,6);s.dRocket(tr,tc,1,0,6)}else if(k==15||k==16){s.dRocket(tr,tc,0,1,15);s.dRocket(tr,tc,0,-1,16)}
  else if(k==ID.flowerpot)s.dPot(tr,tc,dr,dc);else if(k==ID.chakra)s.spinBlast(tr,tc);
  else if(k==ID.atom)s.atom({r:tr,c:tc,r0:Math.max(0,Math.min(R-4,tr-1)),c0:Math.max(0,Math.min(C-4,tc-1)),fast:1});
  else if(k==ID.rail)s.dRail(tr,tc,tap?0:dr,tap?1:dc);else if(k==ID.wala)s.wala({r:tr,c:tc,dr:dr,dc:dc});
  else if(k==ID.sparkler){s.or=tr;s.oc=tc;s.runShape(tap?-1:dr,tap?0:dc)}
  else if(k==ID.skyshot)s.skyshot({r:tr,c:tc,col:col,rain:1,dr:dr,dc:dc});else if(k==ID.matchbox)s.matchbox({r:tr,c:tc,col:col})})};
B.dRocket=function(r,c,dr,dc,i){var s=this,e=this.b[r][c];if(e)e.shakeT=.12;var x=this.cx(c),y=this.cy(r),rot=dr>0?Math.PI:0;
 this.at(.14,function(){s.b[r][c]=null;s.pop(x,y,'#FF2FA8',1.3);s.ring(x,y,'#FFB800',90,9);s.wave(x,y,18);s.shake=6;var sp=640;s.obj(function(c2,t,dt){x+=dc*sp*dt;y+=dr*sp*dt;s.spr(i,x,y,U*1.55,rot);for(var k=0;k<4;k++)s.fx.push({k:'spark',x:x-dc*24+rnd(-7,7),y:y-dr*24+rnd(-7,7),z:0,vx:-dc*rnd(60,260)+rnd(-60,60),vy:-dr*rnd(60,260)+rnd(-60,60),vz:0,col:k%2?'#FF7A1A':'#FFD24A',a:0,l:rnd(.2,.42)});s.puff(x-dc*34,y-dr*34,'#F3F1FF',rnd(9,17));var rr=Math.round((y-OY-U/2)/U),cc=Math.round((x-OX-U/2)/U);if(rr>=0&&rr<R&&cc>=0&&cc<C&&s.b[rr][cc]&&!s.b[rr][cc].dead)s.hit(rr,cc,{d:0,dx:dc*220,dy:dr*220});return x>-70&&x<460&&y>-70&&y<s.H+70},1)});
 this.finish(1.2)};
B.dPot=function(r,c,dr,dc){var s=this,x=this.cx(c),y=this.cy(r),e=this.b[r][c],A=[];e.shakeT=.2;for(var a=0;a<R;a++)for(var b=0;b<C;b++)if((a!=r||b!=c)&&(a-r)*dr+(b-c)*dc>=0)A.push([a,b]);A.sort(function(){return Math.random()-.5});if(s.gpick)A=s.gpick(A);var T=A.slice(0,7);
 this.obj(function(c2,t){if(t<1.2){for(var i=0;i<6;i++)s.fx.push({k:'spark',x:x+rnd(-5,5),y:y-U*.42,z:0,vx:rnd(-85,85)+dc*170,vy:rnd(-640,-340)+dr*170,vz:rnd(0,120),col:i%3?'#FFC62B':'#FFFFFF',a:0,l:rnd(.5,.85),g:900})}return t<1.25},1.3);
 T.forEach(function(q,i){var tx=s.cx(q[1]),ty=s.cy(q[0]);s.at(.5+i*.1,function(){var sx=x,sy=y-U*.5;s.obj(function(c2,t){var u=Math.min(t/.42,1),h=Math.sin(u*3.14),px=sx+(tx-sx)*u,py=sy+(ty-sy)*u-h*120,rad=8+h*10;c2.fillStyle='#FFB800';c2.beginPath();c2.arc(px,py,rad,0,6.3);c2.fill();c2.fillStyle='#FFFFFF';c2.beginPath();c2.arc(px,py,rad*.5,0,6.3);c2.fill();s.fx.push({k:'spark',x:px,y:py,z:0,vx:rnd(-40,40),vy:rnd(-20,60),vz:0,col:'#FFD24A',a:0,l:.3});if(u>=1){s.hit(q[0],q[1],{d:0,pw:1.2});return false}return true},.5)})});
 this.at(1.45,function(){s.hit(r,c,{d:0,pw:1.2})});this.finish(1.75)};
B.nextOf=function(r,c,dr,dc){var t=[r+dr,c+dc];return t[0]>=0&&t[0]<R&&t[1]>=0&&t[1]<C?t:[r,c]};
B.slide=function(r,c,tr,tc,done){var s=this,a=this.b[r][c],n=this.b[tr][tc],dx=tc-c,dy=tr-r;if(!dx&&!dy){done();return}a.top=true;
 this.obj(function(c2,t){var f=Math.min(t/.15,1),e=f<.5?2*f*f:1-2*(1-f)*(1-f);a.sx=dx*e;a.sy=dy*e;if(n){n.sx=-dx*e;n.sy=-dy*e}if(f>=1){a.sx=a.sy=0;a.top=false;if(n){n.sx=n.sy=0}s.b[r][c]=n;s.b[tr][tc]=a;done();return false}return true},.2)};
B.spinBlast=function(r,c){var s=this,i=ID.chakra,x=this.cx(c),y=this.cy(r),rot=0,blown=false,S=.42;this.b[r][c]=null;
 this.obj(function(c2,q,dt){var spin=Math.min(q/S,1);rot+=(2+spin*34)*dt;var sz=U*(1.05+spin*.35),z=spin*10;s.spr(i,x,y-z,sz,rot);for(var k=0;k<3;k++){var a2=rot+k*2.09;s.fx.push({k:'spark',x:x+Math.cos(a2)*sz*.45,y:y-z+Math.sin(a2)*sz*.45,z:0,vx:-Math.sin(a2)*rnd(120,300),vy:Math.cos(a2)*rnd(120,300),vz:0,col:k==1?'#FF2FA8':'#FFC62B',a:0,l:rnd(.2,.4)})}
  if(q>=S&&!blown){blown=true;s.shake=7;s.wave(x,y,18,430);s.ring(x,y,'#FF2FA8',U*2,8);for(var a3=-1;a3<=1;a3++)for(var b3=-1;b3<=1;b3++)if(r+a3>=0&&r+a3<R&&c+b3>=0&&c+b3<C)s.hit(r+a3,c+b3,{d:rnd(0,.05),pw:1.15})}return q<S+.5},S+.55);
 this.finish(S+.9)};
B.dRail=function(r,c,dr,dc){var s=this,i=ID.rail,e=this.b[r][c],sd=dc?(r<R-1?1:-1):(c<C-1?1:-1),pr=dc?sd:0,pc=dr?sd:0;e.shakeT=.16;
 var er=dr>0?R-1:dr<0?0:r,ec=dc>0?C-1:dc<0?0:c,fr=dr>0?0:dr<0?R-1:r+pr,fc=dc>0?0:dc<0?C-1:c+pc,PT=[[r,c],[er,ec],[er+pr,ec+pc],[fr,fc]].map(function(q){return[s.cx(q[1]),s.cy(q[0])]}),L=[],tot=0;
 for(var n=0;n<3;n++){var d=Math.abs(PT[n+1][0]-PT[n][0])+Math.abs(PT[n+1][1]-PT[n][1]);L.push(d);tot+=d}var sp=520,dur=tot/sp,rot=dr?1.5708:0;
 this.at(.18,function(){s.b[r][c]=null;s.obj(function(c2,t){var w=Math.min(t*sp,tot-.01),n=0;while(w>L[n]&&n<2){w-=L[n];n++}var u=L[n]?w/L[n]:1,x=PT[n][0]+(PT[n+1][0]-PT[n][0])*u,y=PT[n][1]+(PT[n+1][1]-PT[n][1])*u,vx=Math.sign(PT[n+1][0]-PT[n][0]),vy=Math.sign(PT[n+1][1]-PT[n][1]);s.spr(i,x,y-6,U*1.3,rot);for(var k=0;k<4;k++)s.fx.push({k:'spark',x:x-vx*30,y:y-vy*30,z:0,vx:-vx*rnd(120,380)+rnd(-60,60),vy:-vy*rnd(120,380)+rnd(-60,60),vz:0,col:k%2?'#FFC62B':'#E8123C',a:0,l:.3});s.puff(x-vx*36,y-vy*36,'#FFFFFF',rnd(6,11));var rr=Math.round((y-OY-U/2)/U),cc=Math.round((x-OX-U/2)/U);if(rr>=0&&rr<R&&cc>=0&&cc<C&&s.b[rr][cc]&&!s.b[rr][cc].dead)s.hit(rr,cc,{d:0,dx:vx*190,dy:vy*190});return t<dur+.02},dur+.05)});
 this.finish(dur+.8)};
B.draw=function(dt){P.draw.call(this,dt);var a=this.arm;if(a&&a.place&&(Math.abs(a.px-a.x)>6||Math.abs(a.py-a.y)>6))this.spr(a.k,a.px,a.py-20,U*1.3)};
window.CrackersBoard=Board;

function Game(cv,lv,cb){this.lv=lv;this.cb=cb;this.isGame=true;this.fl={};this.mode='fork';if(lv.shape){R=lv.shape.length;C=lv.shape[0].length}else{C=lv.w;R=lv.h}this.IC=G.IC;this.rg={};var hh=cv.clientHeight||530;U=Math.floor(Math.min(372/C,(hh-24)/R));OX=(390-U*C)/2;OY=(hh-U*R)/2;this.moves=lv.moves;this.casc=0;this.goal={};for(var k in lv.goal)this.goal[k]=lv.goal[k];this.over=false;FX.call(this,cv)}
Game.prototype=Object.create(B);var G=Game.prototype;G.constructor=Game;
G.rk=function(){var a=this.lv.colors;return a[Math.random()*a.length|0]};
G.gpick=function(L){var s=this;var g=function(p){var e=s.b[p[0]][p[1]];return e&&(e.ob||s.fl[p[0]+','+p[1]]||s.goal[e.k]>0)?0:1};return L.sort(function(a,b){return g(a)-g(b)||Math.random()-.5})};
var OT={crate:{hp:1,k:'b',f:'crate'},steel:{hp:2,k:'b',f:'crate2'},gift:{hp:2,k:'b',f:'gift'},pot:{hp:2,k:'b',f:'pot'},stone:{hp:3,k:'b',f:'stone'},glass:{hp:1,k:'b',f:'glass'},launcher:{hp:2,k:'b',f:'launcher'},thread:{hp:1,k:'o',f:'thread'},chain:{hp:2,k:'o',f:'chain'},ice:{hp:2,k:'o',f:'ice'},wet:{hp:1,k:'o',f:'wet'},rang:{hp:1,k:'f',f:'rangoli'},mud:{hp:2,k:'f',f:'mud'}};window.OBT=OT;
G.IC={diya:new Image()};G.IC.diya.src='art/ui-diya.webp';['crate','crate2','gift','pot','stone','glass','launcher','thread','chain','ice','wet','rangoli','mud'].forEach(function(n){G.IC[n]=new Image();G.IC[n].src='art/'+n+'.webp'});
// falling debris on a full-screen canvas above the board
var DEB={P:[],oy:112,init:function(cv){this.cv=cv;this.x=cv.getContext('2d');var d=Math.min(window.devicePixelRatio||1,2);cv.width=390*d;cv.height=844*d;this.x.setTransform(d,0,0,d,0,0);var s=this,last=0;(function f(n){var dt=Math.min((n-last)/1000||0,.04);last=n;s.step(dt);requestAnimationFrame(f)})(0)},
 add:function(o){if(this.P.length>240)this.P.shift();o.rot=o.rot||0;o.vr=o.vr==null?(Math.random()-.5)*12:o.vr;o.g=o.g||1500;this.P.push(o)},
 chunks:function(img,L,T,S,cols,rows,pw,o){o=o||{};if(!img||!img.naturalWidth)return;var iw=img.naturalWidth,ih=img.naturalHeight;for(var i=0;i<cols;i++)for(var j=0;j<rows;j++){var q=[];for(var n=0;n<5;n++){var a=n/5*6.283+Math.random()*.6;q.push([Math.cos(a)*(.42+Math.random()*.2),Math.sin(a)*(.42+Math.random()*.2)])}var dx=(i+.5)/cols-.5,dy=(j+.5)/rows-.5;
  this.add({img:img,sx:iw*i/cols,sy:ih*j/rows,sw:iw/cols,sh:ih/rows,w:S/cols,h:S/rows,x:L+S*(i+.5)/cols,y:T+this.oy+S*(j+.5)/rows,vx:dx*pw*520+(Math.random()-.5)*120,vy:-260*pw-Math.random()*240+dy*200,poly:o.poly===false?null:q,g:o.g,drag:o.drag})}},
 part:function(img,sx,sy,sw,sh,x,y,w,h,vx,vy){if(!img||!img.naturalWidth)return;this.add({img:img,sx:sx,sy:sy,sw:sw,sh:sh,w:w,h:h,x:x,y:y+this.oy,vx:vx,vy:vy})},
 bits:function(x,y,n,cols,sz,pw,o){o=o||{};for(var i=0;i<n;i++){var a=Math.random()*6.283,v=(.3+Math.random())*pw;this.add({col:cols[i%cols.length],x:x,y:y+this.oy,w:sz*(.6+Math.random()*.8),h:sz*(.4+Math.random()*.6),vx:Math.cos(a)*v*260,vy:Math.sin(a)*v*200-220*pw,g:o.g||1300,drag:o.drag,shape:o.shape})}},
 step:function(dt){var x=this.x;if(!x)return;x.clearRect(0,0,390,844);var t=performance.now()/1000;this.P=this.P.filter(function(p){p.vy+=p.g*dt;if(p.drag){p.vx*=1-p.drag*dt;p.vy=Math.min(p.vy,140);p.x+=Math.sin(t*4+p.w)*20*dt}p.x+=p.vx*dt;p.y+=p.vy*dt;p.rot+=p.vr*dt;if(p.y>904)return false;
  x.save();x.translate(p.x,p.y);x.rotate(p.rot);if(p.img){if(p.poly){x.beginPath();p.poly.forEach(function(q,i){var a=q[0]*p.w*1.6,b=q[1]*p.h*1.6;i?x.lineTo(a,b):x.moveTo(a,b)});x.closePath();x.clip()}x.drawImage(p.img,p.sx,p.sy,p.sw,p.sh,-p.w/2,-p.h/2,p.w,p.h)}else{x.fillStyle=p.col;if(p.shape=='blob'){x.beginPath();x.ellipse(0,0,p.w/2,p.h/2,0,0,6.3);x.fill()}else if(p.shape=='drop'){x.beginPath();x.moveTo(0,-8);x.bezierCurveTo(6,-1,5,5,0,5);x.bezierCurveTo(-5,5,-6,-1,0,-8);x.fill()}else if(p.shape=='tri'){x.beginPath();x.moveTo(0,-p.h/2);x.lineTo(p.w/2,p.h/2);x.lineTo(-p.w/2,p.h/3);x.closePath();x.fill()}else x.fillRect(-p.w/2,-p.h/2,p.w,p.h)}x.restore();return true})}};window.DEB=DEB;
G.hole=function(r,c){var s=this.lv.shape;return !!(s&&s[r][c]=='.')};
G.fresh=function(){var t=0,r,c;do{P.fresh.call(this);for(r=0;r<R;r++)for(c=0;c<C;c++){if(this.hole(r,c))this.b[r][c]=null;else this.b[r][c].k=this.rk()}var fix,g=0;while((fix=this.find()).length&&g++<400)fix[0].cells.forEach(function(p){this.b[p[0]][p[1]].k=this.rk()},this)}while((this.find().length||!this.hasMove())&&t++<60);this.stamp();
 var L=this.lv,s=this,on=function(a,f){(a||[]).forEach(function(p){var e=s.at2(p[0],p[1]);if(e)f(e,p)})};
 on(L.diya,function(e){e.diya=1;e.k=-1});Object.keys(L.ob||{}).forEach(function(t){on(L.ob[t],function(e,p){if(OT[t].k=='f')s.fl[p[0]+','+p[1]]={t:t,hp:OT[t].hp};else e.ob={t:t,hp:OT[t].hp,sq:0,fl:0}})});
 var q=0;while(!this.hasMove()&&q++<30)this.shuffle()};
G.refill=function(){for(var c=0;c<C;c++){var cells=[],i,r;for(r=R-1;r>=0;r--)if(!this.hole(r,c))cells.push(r);var w=0;for(i=0;i<cells.length;i++){r=cells[i];var e=this.b[r][c];if(e){var to=cells[w];if(to!=r){this.b[to][c]=e;this.b[r][c]=null;e.fy=(to-r)*U;e.v=0;e.dl=c*.02}w++}}
 var miss=cells.length-w;for(i=w;i<cells.length;i++){r=cells[i];var n=this.tile(this.rk());n.fy=(miss+1)*U;n.dl=c*.02;n.v=0;this.b[r][c]=n}}this.dropping=true};
G.floorC=null;G.drawFloor=function(c,u){if(!this.floorC){var d=2,o=document.createElement('canvas');o.width=this.W*d;o.height=this.H*d;var x=o.getContext('2d');x.scale(d,d);var ea=function(f){for(var r=0;r<R;r++)for(var k=0;k<C;k++)if(!G.hole.call(this,r,k))f(r,k)}.bind(this);
  x.shadowColor='rgba(80,60,140,.35)';x.shadowBlur=16;x.shadowOffsetY=6;x.fillStyle='#FFFFFF';ea(function(r,k){x.beginPath();x.roundRect(OX+k*u-8,OY+r*u-8,u+16,u+16,16);x.fill()});x.shadowColor='transparent';x.fillStyle='#F2F4FC';ea(function(r,k){x.beginPath();x.roundRect(OX+k*u-5,OY+r*u-5,u+10,u+10,13);x.fill()});
  ea(function(r,k){x.fillStyle=(r+k)%2?'#DDE2F4':'#E8EBF9';x.beginPath();x.roundRect(OX+k*u+2,OY+r*u+2,u-4,u-4,10);x.fill()});this.floorC=o}c.drawImage(this.floorC,0,0,this.W,this.H);
 var cl=this.clock;for(var key in this.fl){var f=this.fl[key],a=key.split(','),fx=OX+a[1]*u+2,fy=OY+a[0]*u+2,s2=u-4;c.save();c.beginPath();c.roundRect(fx,fy,s2,s2,9);c.clip();if(f.t=='rang'){c.drawImage(G.IC.rangoli,fx-1,fy-1,s2+2,s2+2);var g=((cl*.5+ +a[1]*.12)%1.6)-.3;c.fillStyle='rgba(255,255,255,.45)';c.beginPath();c.moveTo(fx+s2*g,fy);c.lineTo(fx+s2*g+9,fy);c.lineTo(fx+s2*g-s2*.4+9,fy+s2);c.lineTo(fx+s2*g-s2*.4,fy+s2);c.fill()}else{c.globalAlpha=f.hp>1?1:.55;c.drawImage(G.IC.mud,fx,fy,s2,s2)}c.restore()}};
G.drawRg=function(c,u){if(this.hl){var q=.5+.5*Math.sin(this.clock*7);c.save();c.strokeStyle='#FFFFFF';c.shadowColor='#FF2E7E';c.shadowBlur=16;c.lineWidth=3+3*q;this.hl.forEach(function(p){c.beginPath();c.roundRect(OX+p[1]*u+2-q*2,OY+p[0]*u+2-q*2,u-4+q*4,u-4+q*4,11);c.stroke()});c.restore()}};
G.drawOver=function(c,e,x,y,s){var o=e.ob;if(!o)return;var t=o.t,I=G.IC,cl=this.clock||0;c.save();var k=1+(o.sq||0)*.18;if(o.sq){o.sq=Math.max(0,o.sq-.07);c.translate(x+s/2+Math.sin(cl*60)*o.sq*3,y+s/2);c.scale(k,2-k);c.translate(-x-s/2,-y-s/2)}
 if(t=='crate'||t=='steel')c.drawImage(t=='steel'&&o.hp>1?I.crate2:I.crate,x-2,y-2,s+4,s+4);
 else if(t=='gift'){if(o.hp>1)c.drawImage(I.gift,x,y,s,s);else{var iw=I.gift.naturalWidth,ih=I.gift.naturalHeight;c.drawImage(I.gift,0,ih*.42,iw,ih*.58,x,y+s*.42,s,s*.58);c.fillStyle='#6B0F3E';c.beginPath();c.roundRect(x+3,y+s*.34,s-6,s*.14,4);c.fill()}}
 else if(t=='pot'||t=='stone'){c.drawImage(I[t],x,y,s,s);if(t=='stone'&&o.hp<3){c.fillStyle='rgba(30,35,45,'+(.13*(3-o.hp))+')';c.beginPath();c.roundRect(x,y,s,s,8);c.fill()}}
 else if(t=='glass'){c.fillStyle='rgba(190,235,255,.55)';c.beginPath();c.roundRect(x+4,y+4,s-8,s-8,8);c.fill();c.drawImage(I.glass,x-2,y-2,s+4,s+4);var gs=((cl*.4+x*.003)%1.5)-.3;c.beginPath();c.roundRect(x,y,s,s,9);c.clip();c.fillStyle='rgba(255,255,255,.6)';c.beginPath();c.moveTo(x+s*gs,y);c.lineTo(x+s*gs+9,y);c.lineTo(x+s*gs-s*.4+9,y+s);c.lineTo(x+s*gs-s*.4,y+s);c.fill()}
 else if(t=='launcher'){c.drawImage(I.launcher,x,y,s,s);var n=(OT.launcher.hp-o.hp)*2;[.28,.43,.58,.73].forEach(function(p,i){if(i<n){c.save();c.fillStyle='#FFE04A';c.shadowColor='#FFB400';c.shadowBlur=8;c.beginPath();c.arc(x+s*p,y+s*.665,s*.055,0,6.3);c.fill();c.restore()}})}
 else if(t=='thread'){c.shadowColor='rgba(90,50,0,.5)';c.shadowBlur=2;c.drawImage(I.thread,x-3,y-3,s+6,s+6)}
 else if(t=='chain'){if(o.hp>1)c.drawImage(I.chain,x-2,y-2,s+4,s+4);else{var cw=I.chain.naturalWidth,ch=I.chain.naturalHeight;c.drawImage(I.chain,0,ch*.45,cw,ch*.55,x-2,y-2+(s+4)*.45,s+4,(s+4)*.55)}}
 else if(t=='ice'){c.globalAlpha=.88;c.drawImage(I.ice,x-3,y-3,s+6,s+6);c.globalAlpha=1}
 else if(t=='wet'){c.globalAlpha=.86;var wb=1+Math.sin(cl*3+x)*.03;c.drawImage(I.wet,x-3,y-3-s*.04,(s+6)*wb,(s+6)/wb);c.globalAlpha=1}
 if(o.cr){c.strokeStyle=t=='pot'?'#5A2410':t=='ice'?'#3E8FC4':'#2B3038';c.lineWidth=2;c.lineJoin='round';o.cr.forEach(function(p){c.beginPath();p.forEach(function(q,i){var a=x+s/2+q[0]*s,b=y+s/2+q[1]*s;i?c.lineTo(a,b):c.moveTo(a,b)});c.stroke()})}
 if(o.fl>0){c.fillStyle='rgba(255,255,255,'+o.fl*.8+')';c.beginPath();c.roundRect(x,y,s,s,9);c.fill();o.fl=Math.max(0,o.fl-.12)}c.restore()};
G.at2=function(r,c){return r>=0&&r<R&&c>=0&&c<C?this.b[r][c]:null};
G.kind=function(r,c){var e=this.at2(r,c);return e&&!e.dead&&!(e.ob&&(OT[e.ob.t].k=='b'||e.ob.t=='wet'))&&e.k<6?e.k:-1};
G.find=function(){var M={},H={},V={},r,c,k,n,i;for(r=0;r<R;r++){c=0;while(c<C){k=this.kind(r,c);n=1;while(k>=0&&this.kind(r,c+n)==k)n++;if(k>=0&&n>=3)for(i=0;i<n;i++){M[r+','+(c+i)]=k;H[r+','+(c+i)]=n}c+=n}}
 for(c=0;c<C;c++){r=0;while(r<R){k=this.kind(r,c);n=1;while(k>=0&&this.kind(r+n,c)==k)n++;if(k>=0&&n>=3)for(i=0;i<n;i++){M[(r+i)+','+c]=k;V[(r+i)+','+c]=n}r+=n}}
 var Sq={};for(r=0;r<R-1;r++)for(c=0;c<C-1;c++){k=this.kind(r,c);if(k>=0&&this.kind(r,c+1)==k&&this.kind(r+1,c)==k&&this.kind(r+1,c+1)==k){[[r,c],[r,c+1],[r+1,c],[r+1,c+1]].forEach(function(p){M[p[0]+','+p[1]]=k;Sq[p[0]+','+p[1]]=1})}}
 var seen={},out=[],keys=Object.keys(M);keys.forEach(function(s0){if(seen[s0])return;var st=[s0],cells=[],h=0,v=0,sq=false,kk=M[s0];seen[s0]=1;while(st.length){var q=st.pop(),a=q.split(','),rr=+a[0],cc=+a[1];cells.push([rr,cc]);h=Math.max(h,H[q]||0);v=Math.max(v,V[q]||0);sq=sq||!!Sq[q];[[1,0],[-1,0],[0,1],[0,-1]].forEach(function(d){var z=(rr+d[0])+','+(cc+d[1]);if(M[z]===kk&&!seen[z]){seen[z]=1;st.push(z)}})}out.push({cells:cells,h:h,v:v,sq:sq,k:kk})});return out};
G.stuck=function(e){return !!e.ob};
G.hasMove=function(){for(var r=0;r<R;r++)for(var c=0;c<C;c++){var e=this.b[r][c];if(!e)continue;if(e.k>=6)return true;var o=[[r,c+1],[r+1,c]];for(var i=0;i<2;i++){var a=o[i][0],b=o[i][1],f=this.at2(a,b);if(!f||this.stuck(e)||this.stuck(f))continue;var t=e.k;e.k=f.k;f.k=t;var ok=this.find().length>0;f.k=e.k;e.k=t;if(ok)return true}}return false};
G.shuffle=function(){var L=[],r,c,g=0;for(r=0;r<R;r++)for(c=0;c<C;c++){var e=this.b[r][c];if(e&&e.k<6&&e.k>=0&&!e.ob)L.push(e)}do{var ks=L.map(function(e){return e.k}).sort(function(){return Math.random()-.5});L.forEach(function(e,i){e.k=ks[i]})}while((this.find().length||!this.hasMove())&&g++<80)};
G.go=function(a,dr,dc){var e=this.b[a.r][a.c];if(e)e.firing=true;B.go.call(this,a,dr,dc)};
G.stamp=function(){var t=this.lv.teach;if(!t)return;var chk=this;var a=this.lv.colors[0],b=this.lv.colors[1],M={rocket:{put:[[2,1],[2,2],[2,4],[3,3]],not:[2,3],mv:[3,3,-1,0]},square:{put:[[2,1],[2,2],[3,1],[3,3]],not:[3,2],mv:[3,3,0,-1]},lshape:{put:[[2,1],[2,3],[2,4],[3,2],[4,2]],not:[2,2],mv:[2,1,0,1]}}[t],keep={},s=this;if(M.put.concat([M.not]).some(function(p){return !chk.at2(p[0],p[1])}))return;M.put.forEach(function(p){s.b[p[0]][p[1]].k=a;keep[p]=1});s.b[M.not[0]][M.not[1]].k=b;keep[M.not]=1;var g=0,f;while((f=this.find()).length&&g++<300)f.forEach(function(q){q.cells.forEach(function(p){if(!keep[p])s.b[p[0]][p[1]].k=s.rk()})});this.teach=M.mv};
G.hintMove=function(){var R0=[],r,c;for(r=0;r<R;r++)for(c=0;c<C;c++){var e=this.b[r][c];if(e&&e.k>=6)return{r:r,c:c,tap:1}}if(this.teach){var q=this.teach;return{r:q[0],c:q[1],dr:q[2],dc:q[3]}}var best=null,bs=0;for(r=0;r<R;r++)for(c=0;c<C;c++)[[0,1],[1,0]].forEach(function(d){var e=this.at2(r,c),f=this.at2(r+d[0],c+d[1]);if(!e||!f||this.stuck(e)||this.stuck(f))return;var t=e.k;e.k=f.k;f.k=t;var m=this.find(),sc=0;m.forEach(function(q){sc+=q.cells.length*(this.goal[q.k]>0?2:1);q.cells.forEach(function(p){[[1,0],[-1,0],[0,1],[0,-1]].forEach(function(z){var y=this.at2(p[0]+z[0],p[1]+z[1]);if(y&&y.ob)sc+=3;if(this.fl[(p[0]+z[0])+','+(p[1]+z[1])])sc+=2},this)},this)},this);f.k=e.k;e.k=t;if(sc>bs){bs=sc;best={r:r,c:c,dr:d[0],dc:d[1]}}},this);return best};
G.specials=function(){var a=[];for(var r=0;r<R;r++)for(var c=0;c<C;c++){var e=this.b[r][c];if(e&&e.k>=6)a.push({k:e.k,r:r,c:c})}return a};
G.bind=function(){var s=this,cv=this.cv;cv.style.touchAction='none';function P2(ev){var b=cv.getBoundingClientRect(),k=s.W/b.width;return[(ev.clientX-b.left)*k,(ev.clientY-b.top)*k]}
 cv.addEventListener('pointerdown',function(ev){if(s.busy||s.over)return;var q=s.cell(ev);if(!s.at2(q[0],q[1]))return;var p=P2(ev);s.arm={r:q[0],c:q[1],x:p[0],y:p[1]};try{cv.setPointerCapture(ev.pointerId)}catch(e){}});
 cv.addEventListener('pointermove',function(ev){var a=s.arm;if(!a)return;var p=P2(ev),dx=p[0]-a.x,dy=p[1]-a.y;if(Math.abs(dx)<U*.32&&Math.abs(dy)<U*.32)return;s.arm=null;if(Math.abs(dx)>Math.abs(dy))s.act(a.r,a.c,0,dx>0?1:-1);else s.act(a.r,a.c,dy>0?1:-1,0)});
 cv.addEventListener('pointerup',function(){var a=s.arm;s.arm=null;if(a){var e=s.at2(a.r,a.c);if(e&&e.k>=6&&!s.busy&&!s.over)s.use(a.r,a.c,0,0)}})};
G.spend=function(){this.moved=true;this.hl=null;this.moves--;this.casc=0;this.teach=null;if(this.cb.moves)this.cb.moves(this.moves)};
G.use=function(r,c,dr,dc){var e=this.b[r][c];this.spend();if(this.cb.big&&[8,9,10,12,14].indexOf(e.k)>=0)this.cb.big();if(window.SFX)SFX.special(e.k);this.go({r:r,c:c,k:e.k},dr,dc)};
G.act=function(r,c,dr,dc){if(this.busy||this.over||this.moves<=0)return;var e=this.at2(r,c),t=this.at2(r+dr,c+dc);if(!e)return;if(this.stuck(e)){if(window.SFX)SFX.nope();return}if(!t){if(e.k>=6)this.use(r,c,0,0);return}if(this.stuck(t)){if(e.k>=6)this.use(r,c,0,0);else if(window.SFX)SFX.nope();return}if(e.k>=6){if(t.k>=6&&!(e.k==9&&t.k==9)){t.queued=true;if(this.cb.cheer)this.cb.cheer(9)}this.use(r,c,dr,dc);return}if(t.k>=6){this.use(r+dr,c+dc,-dr,-dc);return}
 var s=this;this.busy=true;if(window.SFX)SFX.swap();this.slide(r,c,r+dr,c+dc,function(){var g=s.find();if(!g.length){if(window.SFX)SFX.nope();s.slide(r+dr,c+dc,r,c,function(){s.busy=false});return}s.spend();s.blast(g,[[r+dr,c+dc],[r,c]])})};
G.blast=function(g,pref){var s=this,mk=false,seen={};g.forEach(function(q){q.cells.forEach(function(p){[[1,0],[-1,0],[0,1],[0,-1]].forEach(function(d){var a=p[0]+d[0],b=p[1]+d[1],e=s.at2(a,b),id=a+','+b;if(e&&e.ob&&!seen[id]){seen[id]=1;s.hitOb(e,[a,b],false)}if(e&&!seen['f'+id]){seen['f'+id]=1;s.hitFl(a,b)}})})});if(g.some(function(q){return q.cells.length>=4}))this.shake=Math.max(this.shake,5);g.forEach(function(q){var type=null;if(s.ending){}else if(Math.max(q.h,q.v)>=5)type='skyshot';else if(q.h>=3&&q.v>=3)type='chakra';else if(q.h==4||q.v==4)type='rocket';else if(q.sq)type='flowerpot';
  var sp=null;if(type){(pref||[]).forEach(function(p){if(!sp&&q.cells.some(function(z){return z[0]==p[0]&&z[1]==p[1]}))sp=p});sp=sp||q.cells[q.cells.length>>1]}
  q.cells.forEach(function(p,i){var e=s.b[p[0]][p[1]];if(!e)return;if(e.ob){s.hitOb(e,p,false);return}if(sp&&p[0]==sp[0]&&p[1]==sp[1]){s.hitFl(p[0],p[1]);s.count(q.k,p[0],p[1]);e.k=type=='rocket'?(q.h==4?15:q.v==4?6:15):ID[type];e.safe=s.clock+.5;s.ring(s.cx(p[1]),s.cy(p[0]),'#FFC62B',U*1.6,9);s.burst(s.cx(p[1]),s.cy(p[0]),['#FFD24A','#FFFFFF','#FF7A1A'],18,260);s.flash=Math.max(s.flash,.25);mk=true}else s.hit(p[0],p[1],{d:.02+i*.016})})});
 if(window.SFX){var at=0;g.slice(0,4).forEach(function(q){at+=SFX.cracker(q.k,s.casc,q.cells.length,at)});if(mk)SFX.make()}this.finish(.24)};
G.count=function(k,r,c){if(this.goal[k]>0){this.goal[k]--;if(r!=null&&this.cb.fly)this.cb.fly(k,this.cx(c),this.cy(r));if(this.cb.goal)this.cb.goal(this.goal)}};
G.crack=function(n){var L=[];for(var i=0;i<n;i++){var a=Math.random()*6.283,p=[[0,0]],r=0;while(r<.5){r+=.12+Math.random()*.12;a+=(Math.random()-.5)*.9;p.push([Math.cos(a)*r,Math.sin(a)*r])}L.push(p)}return L};
G.hitOb=function(e,p,blast){var o=e.ob;if(!o||(e.safe&&e.safe>this.clock))return;var t=o.t,x=this.cx(p[1]),y=this.cy(p[0]),S=U-4,L=x-S/2,T=y-S/2,I=G.IC,D=DEB,pw=blast?1.3:1;
 if(t=='glass'&&!blast){o.sq=.5;this.spark(x,y,6,['#D8F3FF','#FFFFFF'],140);if(window.SFX)SFX.play('tick',{rate:2,v:.4});return}
 e.safe=this.clock+.3;o.hp--;o.sq=1;o.fl=1;var dead=o.hp<=0,lvl=OT[t].hp-o.hp;this.shake=Math.max(this.shake,2+OT[t].hp*1.5*(dead?1.3:.7));this.ring(x,y,'#FFFFFF',S*.9,5);
 if(window.SFX){SFX.play(dead?'thud':'paper',{rate:dead?1-OT[t].hp*.06:1.1,v:dead?1:.7})}
 if(t=='crate'||(t=='steel'&&dead)){D.chunks(I.crate,L,T,S,1,4,pw,{poly:false});D.bits(x,y,10,['#B9772F','#8A5520','#E8123C'],6,pw)}
 else if(t=='steel'){[.24,.76].forEach(function(q,i){D.bits(x,T+S*q,6,['#C9D3E0','#7E8A99'],5,1)});D.chunks(I.crate2,L,T,S,1,2,1.1,{poly:false})}
 else if(t=='gift'){if(!dead){D.part(I.gift,0,0,I.gift.naturalWidth,I.gift.naturalHeight*.42,x,T+S*.21,S,S*.42,(Math.random()-.5)*160,-520);D.bits(x,T,14,['#FFD23F','#FF2E8B','#FFFFFF'],5,1.1,{drag:1.2,g:700})}else{D.chunks(I.gift,L,T,S,3,2,pw);D.bits(x,y,24,['#FFD23F','#FF2E8B','#3FD8FF','#FFFFFF'],6,1.3,{drag:1.4,g:600})}}
 else if(t=='pot'){if(!dead){o.cr=this.crack(5);D.bits(x,y,6,['#C9612A','#E07A3E'],4,.8)}else{D.chunks(I.pot,L,T,S,3,3,pw);D.bits(x,y,10,['#C9612A','#8A3D17'],4,1.2)}}
 else if(t=='stone'){if(!dead){o.cr=(o.cr||[]).concat(this.crack(lvl==1?4:6));D.bits(x,y,lvl*5,['#8F99A6','#6B7480','#C3CAD3'],5,.9)}else{D.chunks(I.stone,L,T,S,3,3,1.15*pw,{g:2000});D.bits(x,y,16,['#8F99A6','#6B7480'],6,1.4,{g:2000});this.shake=13}}
 else if(t=='glass'){D.chunks(I.glass,L,T,S,3,3,1.3,{g:1700});D.bits(x,y,14,['#CDEFFF','#FFFFFF'],9,1.2,{shape:'tri'})}
 else if(t=='launcher'){if(dead){D.chunks(I.launcher,L,T,S,3,3,1.2);D.bits(x,y,10,['#2E5FC9','#C9A24B','#7A5230'],5,1.2);this.fireCol(p)}else if(window.SFX)SFX.play('tick',{rate:1.3,v:.6})}
 else if(t=='thread')D.chunks(I.thread,L,T,S,2,2,1.1*pw);
 else if(t=='chain'){if(!dead){var cw=I.chain.naturalWidth,ch=I.chain.naturalHeight;for(var i=0;i<3;i++)D.part(I.chain,cw*i/3,0,cw/3,ch*.45,L+S*(i+.5)/3,T+S*.22,S/3,S*.45,(i-1)*220,-330-Math.random()*100)}else D.chunks(I.chain,L,T+S*.45,S,3,1,1.2)}
 else if(t=='ice'){if(!dead){o.cr=this.crack(6);D.bits(x,y,8,['#E8FAFF','#9FDDF7'],4,.8)}else{D.chunks(I.ice,L,T,S,3,3,1.2*pw);D.bits(x,y,8,['#E8FAFF','#BDEBFF'],10,1,{shape:'tri'})}}
 else if(t=='wet'){D.chunks(I.wet,L,T,S,3,3,.9,{g:1600});D.bits(x,y,12,['#3FA9F5','#7FD4FF'],7,1,{shape:'drop'});this.dried=true}
 if(dead){e.ob=null;if(this.cb.fly&&this.goal[t]!==undefined)this.cb.fly(t,x,y);this.sync()}};
G.hitFl=function(r,c){var key=r+','+c,f=this.fl[key];if(!f||(f.safe&&f.safe>this.clock))return;f.safe=this.clock+.3;f.hp--;var x=this.cx(c),y=this.cy(r),S=U-4,D=DEB;
 if(f.t=='rang'){D.chunks(G.IC.rangoli,x-S/2,y-S/2,S,2,2,.8,{g:900});this.spark(x,y,22,['#FF2E7E','#FFB400','#00B8C4','#7A3CFF'],260)}else D.bits(x,y+S*.2,f.hp?9:13,['#6B4423','#8A5A2E','#4E2F14'],8,1,{shape:'blob'});
 if(window.SFX)SFX.play('paper',{v:.6});if(f.hp<=0){delete this.fl[key];if(f.t=='mud')D.chunks(G.IC.mud,x-S/2,y-S/2,S,3,3,.8,{g:1400});if(this.cb.fly&&this.goal[f.t]!==undefined)this.cb.fly(f.t,x,y);this.sync()}};
G.fireCol=function(p){var s=this,c=p[1],x=this.cx(c);if(window.SFX)SFX.play('rocket',{rate:1.2,v:.8});this.obj(function(c2,t){var y=s.cy(p[0])-(t/.5)*(s.cy(p[0])-OY+40);c2.save();c2.fillStyle='#FFD24A';c2.shadowColor='#FF8A1F';c2.shadowBlur=18;c2.beginPath();c2.ellipse(x,y,7,16,0,0,6.3);c2.fill();c2.restore();s.spark(x,y+14,2,['#FFD24A','#FF7A1A'],100);return t<.5},.5);this.busy=true;for(var r=0;r<R;r++)if(r!=p[0])(function(r){s.at(Math.abs(p[0]-r)*.05+.05,function(){s.hit(r,c,{d:0,pw:1})})})(r);this.finish(.05*R+.35)};
G.sync=function(){var n={},s=this,ch=false;Object.keys(OT).forEach(function(t){n[t]=0});for(var r=0;r<R;r++)for(var c=0;c<C;c++){var e=this.b[r][c];if(e&&e.ob)n[e.ob.t]++}for(var k in this.fl)n[this.fl[k].t]++;Object.keys(OT).forEach(function(t){if(s.goal[t]!==undefined&&s.goal[t]!=n[t]){s.goal[t]=n[t];ch=true}});if(ch&&this.cb.goal)this.cb.goal(this.goal)};G.syncWrap=G.sync;
G.hit=function(r,c,o){var e=this.b[r]&&this.b[r][c];if(!e||e.dead||e.diya||(e.safe&&e.safe>this.clock))return;if(e.ob){this.hitOb(e,[r,c],true);return}if(e.k>=6&&!e.firing){e.queued=true;return}P.hit.call(this,r,c,o)};
G.smash=function(r,c,o){var e=this.b[r][c];if(this.ended){if(e&&e.diya)e.k=0;if(e&&e.ob){var ot=e.ob.t,I2=G.IC[OT[ot].f];e.ob=null;DEB.chunks(I2,this.cx(c)-U/2,this.cy(r)-U/2,U,2,2,1)}P.smash.call(this,r,c,o);return}if(e&&e.ob){this.hitOb(e,[r,c],true);return}if(e&&e.k<6&&e.k>=0)this.count(e.k,r,c);this.hitFl(r,c);P.smash.call(this,r,c,o)};
G.fireNext=function(){for(var r=0;r<R;r++)for(var c=0;c<C;c++){var e=this.b[r][c];if(e&&e.queued){e.queued=false;this.busy=true;if(window.SFX)SFX.special(e.k);this.go({r:r,c:c,k:e.k},0,0);return true}}return false};
G.left=function(){var n=0;for(var k in this.goal)n+=Math.max(0,this.goal[k]);return n};
G.collect=function(){var hit=false;for(var c=0;c<C;c++){var r=R-1;while(r>=0&&this.hole(r,c))r--;var e=r>=0&&this.b[r][c];if(e&&e.diya&&!(e.fy>0)){this.b[r][c]=null;var x=this.cx(c),y=this.cy(r);this.ring(x,y,'#FFC62B',U*1.4,6);this.spark(x,y,24,['#FFD24A','#FFFFFF','#FF7A1A'],320);this.count('diya',r,c);if(window.SFX)SFX.tick();hit=true}}return hit};
G.spread=function(){var L=[],s=this,D=[[1,0],[-1,0],[0,1],[0,-1]];for(var r=0;r<R;r++)for(var c=0;c<C;c++){var e=this.b[r][c];if(e&&e.ob&&e.ob.t=='wet')D.forEach(function(d){var f=s.at2(r+d[0],c+d[1]);if(f&&!f.ob&&!f.diya&&f.k<6&&f.k>=0)L.push(f)})}if(L.length){var f=L[Math.random()*L.length|0];f.ob={t:'wet',hp:1,sq:1,fl:1};this.sync()}};
G.onDone=function(){this.syncWrap();if(this.over)return;if(this.collect()){this.busy=true;this.at(.25,this.refill.bind(this));return}
 if(!this.left()){this.over=true;this.busy=true;this.cb.done(this.moves);return}
 if(this.fireNext())return;var g=this.find();if(g.length){this.casc++;this.busy=true;if(this.cb.cheer)this.cb.cheer(this.casc);this.blast(g,null);return}
 if(this.moved){this.moved=false;if(this.goal.wet!==undefined&&!this.dried)this.spread();this.dried=false;if(!this.left()){this.over=true;this.busy=true;this.cb.done(this.moves);return}}
 if(this.moves<=0){this.over=true;this.busy=true;this.cb.lose();return}if(!this.hasMove()){var s=this;this.busy=true;if(this.cb.shuffling)this.cb.shuffling();for(var r=0;r<R;r++)for(var c=0;c<C;c++)if(this.b[r][c])this.b[r][c].shakeT=.7;this.at(.75,function(){s.shuffle();s.flash=.5;s.busy=false});return}if(this.cb.idle)this.cb.idle()};
G.showHint=function(){if(this.hl||this.busy||this.over)return;var h=this.hintMove();if(!h)return;if(h.tap){this.hl=[[h.r,h.c]];return}var e=this.at2(h.r,h.c),f=this.at2(h.r+h.dr,h.c+h.dc);if(!e||!f)return;this.hl=[[h.r,h.c],[h.r+h.dr,h.c+h.dc]]};
G.more=function(n){this.moves+=n;this.over=false;this.busy=false;this.hl=null;if(this.cb.moves)this.cb.moves(this.moves)};
G.boardBlast=function(m,done){var s=this,h=function(r,c,d,pw){s.at(d,function(){if(s.b[r][c])s.smash(r,c,{pw:pw||.75})})},ea=function(f){for(var r=0;r<R;r++)for(var c=0;c<C;c++)if(s.b[r][c])f(r,c)};this.ended=true;this.ev=[];
 if(m==0){var cols=[1,C>>1,C-2];if(window.SFX){SFX.play('rocket');SFX.play('wala',{at:.5,cut:1.6})}cols.forEach(function(c,i){s.at(i*.1,function(){var x=s.cx(c),y0=s.cy(R)+U,y1=s.cy(0)-U*1.4;s.obj(function(cx,t){var y=y0+(y1-y0)*Math.min(t/.65,1);s.spr(6,x,y,U*1.5,0);if(Math.random()<.6)s.spark(x,y+U*.6,2,['#FFD24A','#FF7A1A'],120)},.65);s.at(.62,function(){s.burst(x,y1+U,['#FFD24A','#E8123C','#FFFFFF'],26,300);s.shake=8})});for(var r=R-1;r>=0;r--)if(s.b[r][c])h(r,c,i*.1+(R-1-r)*.075+.05)});ea(function(r,c){if(cols.indexOf(c)<0)h(r,c,.75+(R-1-r)*.17)});this.at(.75,function(){s.flash=.4})}
 else if(m==1){var ry=(R-1)/2,rx=(C-1)/2,M=Math.sqrt(ry*ry+rx*rx);if(window.SFX)SFX.play('wala',{cut:2});this.flash=.7;this.shake=10;this.ring(this.cx(rx),this.cy(ry),'#FFC62B',U*7,12);ea(function(r,c){var a=r-ry,b=c-rx;h(r,c,.05+Math.sqrt(a*a+b*b)/M*1.4)})}
 else{if(window.SFX)SFX.play('skyshot',{cut:2.2});for(var i=0;i<34;i++)(function(i){var x=30+Math.random()*330,col=['#FFD24A','#FF5FB2','#3FD8FF','#FFFFFF'][i%4],sz=7+Math.random()*7;s.at(i*.04,function(){s.obj(function(c,t){c.save();c.fillStyle=col;s.star(c,x+t/.8*18,-20+t/.8*(s.H+40),sz);c.fill();c.restore()},.8)})})(i);ea(function(r,c){h(r,c,.25+r*(1.6/R)+Math.random()*.08)})}
 this.at(2.2,done)};
G.place=function(k,r,c){var e=this.at2(r,c);if(!e||e.ob||e.diya||this.busy||this.over||this.moves<=0)return false;e.k=ID[k];this.use(r,c,0,0);return true};
G.drawWrap=function(c,x,y,s){c.save();c.fillStyle='#CEA670';c.beginPath();c.roundRect(x+3,y+3,s-6,s-6,9);c.fill();c.strokeStyle='rgba(120,78,36,.55)';c.lineWidth=1.3;c.beginPath();c.moveTo(x+6,y+s*.3);c.lineTo(x+s-6,y+s*.22);c.moveTo(x+8,y+s*.72);c.lineTo(x+s-8,y+s*.8);c.stroke();c.fillStyle='#E8123C';c.fillRect(x+s/2-3,y+3,6,s-6);c.fillRect(x+3,y+s/2-3,s-6,6);c.fillStyle='#FFC62B';c.beginPath();c.arc(x+s/2,y+s/2,6,0,6.3);c.fill();c.restore()};
window.CrackersGame=Game;
window.CrackersFX2=FX;
})();
