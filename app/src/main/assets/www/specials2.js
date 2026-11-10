// New special crackers (10 Nov 2026). Load after combos.js.
// Match specials: 4 in a line Rocket (6/15/16, engine), 5 in a line Colour Matchbox (14),
// 2x2 Ground Chakra flyer (8), L or T Bomb (10, 3x3).
// Bar boosters: 17 Lakshmi Vedi Hammer, 18 Seven Shot, 19 Snake Tablet (the rest use the engine's own).
(function(){
var G=CrackersGame.prototype,prevGo=G.go,prevPlace=G.place;
var KID={rocket:6,flowerpot:7,chakra:8,skyshot:9,atom:10,bomb:10,sparkler:11,wala:12,rail:13,matchbox:14,hammer:17,seven:18,snake:19};
function rnd(a,b){return a+Math.random()*(b-a)}
function snd(n,o){if(window.SFX)SFX.play(n,o||{})}
function shuffle(a){for(var i=a.length-1;i>0;i--){var j=Math.random()*(i+1)|0,t=a[i];a[i]=a[j];a[j]=t}return a}
function dist(a,b){return Math.hypot(a[0]-b[0],a[1]-b[1])}
G.isGoalCell=function(r,c){var e=this.at2(r,c);if(!e||e.dead||e.diya)return false;if(e.ob)return true;return e.k>=0&&e.k<6&&this.goal[e.k]>0};
G.cellsList=function(ex,goalOnly){var L=[],R=this.rows(),C=this.cols();for(var r=0;r<R;r++)for(var c=0;c<C;c++){if(ex&&ex[r+','+c])continue;var e=this.at2(r,c);if(!e||e.dead||e.diya||e.k>=6)continue;if(goalOnly&&!this.isGoalCell(r,c))continue;L.push([r,c])}return L};
G.spark2=function(x,y,n,cols,sp,life){for(var i=0;i<n;i++){var a=Math.random()*6.283,v=rnd(.3,1)*sp;this.fx.push({k:'spark',x:x,y:y,z:0,vx:Math.cos(a)*v,vy:Math.sin(a)*v,vz:0,col:cols[i%cols.length],a:0,l:life||rnd(.3,.5)})}};
G.place=function(k,r,c){var e=this.at2(r,c);if(!e||e.ob||e.diya||this.busy||this.over||this.moves<=0)return false;if(KID[k]==null)return prevPlace.call(this,k,r,c);e.k=KID[k];this.use(r,c,0,0);return true};
G.go=function(a,dr,dc){var k=a.k;if([8,10,14,17,18,19].indexOf(k)<0)return prevGo.call(this,a,dr,dc);
 var e=this.b[a.r][a.c];if(e)e.firing=true;this.busy=true;var s=this,t=this.nextOf(a.r,a.c,dr,dc),tr=t[0],tc=t[1],n=this.b[tr][tc],tap=!dr&&!dc,col=(n&&n.k<6&&!tap)?n.k:this.top();
 var e2=this.b[a.r][a.c];if(e2){e2.shakeT=.15;this.spark2(this.cx(a.c),this.cy(a.r),10,['#FFFFFF','#FFD24A'],160,.3)}
 this.slide(a.r,a.c,tr,tc,function(){({8:s.flyChakra,10:s.bomb3,14:s.boltBox,17:s.hammer,18:s.seven,19:s.snake})[k].call(s,tr,tc,col)})};

// ---- Bomb: short fuse, then a 3x3 boom
G.bomb3=function(r,c){var s=this,x=this.cx(c),y=this.cy(r),u=this.uu(),e=this.b[r][c];if(e)e.shakeT=.4;snd('paper',{v:.5,rate:.6});
 this.obj(function(c2,t){if(t<.32)for(var i=0;i<2;i++)s.fx.push({k:'spark',x:x+rnd(-3,3),y:y-u*.5,z:0,vx:rnd(-70,70),vy:rnd(-160,-50),vz:0,col:i?'#FFF2B0':'#FF8A1A',a:0,l:.22});return t<.34},.36);
 this.at(.34,function(){s.b[r][c]=null;snd('atom',{v:.95});s.pop(x,y,'#FF8A1A',1.6);s.ring(x,y,'#FFFFFF',u*3.6,10);s.ring(x,y,'#FFB43A',u*2.8,7);s.wave(x,y,16,460);s.shake=6;s.flash=Math.max(s.flash,.3);
  var R=s.rows(),C=s.cols();for(var a=-1;a<=1;a++)for(var b=-1;b<=1;b++){var rr=r+a,cc=c+b;if(rr>=0&&rr<R&&cc>=0&&cc<C&&(a||b))s.hit(rr,cc,{d:.02+.02*(Math.abs(a)+Math.abs(b)),pw:1.3})}});
 this.finish(.95)};

// ---- Colour Matchbox: lightning strikes every cracker of one colour, slowly, one by one, then all blast together
G.bolt=function(x0,y0,x1,y1){var u=this.uu(),P=[[x0,y0]],n=8;for(var i=1;i<n;i++){var f=i/n;P.push([x0+(x1-x0)*f+rnd(-1,1)*u*.35,y0+(y1-y0)*f+rnd(-1,1)*u*.12])}P.push([x1,y1]);
 this.obj(function(c,t){var f=t/.26;if(f>.5&&Math.random()<.5)return t<.26;c.save();c.lineJoin='round';c.shadowColor='#9FD4FF';c.shadowBlur=18;[[7,'rgba(140,190,255,'+(.55*(1-f))+')'],[2.6,'rgba(255,255,255,'+(1-f*.6)+')']].forEach(function(w){c.strokeStyle=w[1];c.lineWidth=w[0];c.beginPath();P.forEach(function(q,i){i?c.lineTo(q[0],q[1]):c.moveTo(q[0],q[1])});c.stroke()});c.restore();return t<.26},.3)};
G.boltBox=function(r,c,col){var s=this,u=this.uu(),e=this.b[r][c];if(e)e.shakeT=99;snd('swoosh',{v:.45,rate:2.2,cut:.25});
 var L=[],R=this.rows(),C=this.cols();for(var a=0;a<R;a++)for(var b=0;b<C;b++){var f=this.at2(a,b);if(f&&!f.dead&&!f.ob&&f.k===col)L.push([a,b])}
 var cur=[r,c],ord=[];while(L.length){L.sort(function(p,q){return dist(p,cur)-dist(q,cur)});cur=L.shift();ord.push(cur)}
 var step=ord.length>14?.11:.15;
 ord.forEach(function(p,i){s.at(.3+i*step,function(){var f=s.at2(p[0],p[1]);if(!f||f.dead)return;var x1=s.cx(p[1]),y1=s.cy(p[0]);s.bolt(x1+rnd(-u,u),-6,x1,y1);f.shakeT=99;f.safe=s.clock+5;s.ring(x1,y1,'#BFE3FF',u*.9,4);s.spark2(x1,y1,10,['#FFFFFF','#BFE3FF','#7FB8FF'],150);snd('blast',{off:.2,v:.45,rate:1.6+Math.random()*.2,cut:.16});snd('thud',{v:.5,rate:1.8})})});
 var T0=.3+ord.length*step+.35;
 this.at(T0,function(){var bx=s.cx((C-1)/2),by=s.cy((R-1)/2);snd('atom',{v:.95});snd('blast',{v:.55,rate:1.1});s.ring(bx,by,'#FFFFFF',u*C*1.1,12);s.ring(bx,by,'#9FD4FF',u*C*.8,8);s.wave(bx,by,18,520);s.shake=7;s.flash=Math.max(s.flash,.45);
  ord.forEach(function(p,i){var f=s.at2(p[0],p[1]);if(f){f.safe=0;f.shakeT=0}s.hit(p[0],p[1],{d:i*.012,pw:1.3})});var m=s.b[r][c];if(m){m.shakeT=0;s.b[r][c]=null;s.pop(s.cx(c),s.cy(r),'#FFD24A',1.4)}});
 this.finish(T0+.5)};

// ---- Ground Chakra: spins, clears 2x2, takes off, flies around the board, dives on the nearest goal tile
G.flyChakra=function(r,c){var s=this,u=this.uu(),R=this.rows(),C=this.cols(),x0=this.cx(c),y0=this.cy(r),rot=0,rr=Math.min(r,R-2),c2=Math.min(c,C-2),ex={};
 snd('swoosh',{v:.4,rate:1.1});snd('sparkler',{off:.3,v:.35,rate:.85,cut:.6});this.b[r][c]=null;
 [[rr,c2],[rr,c2+1],[rr+1,c2],[rr+1,c2+1]].forEach(function(p){ex[p[0]+','+p[1]]=1});
 var g=this.cellsList(ex,true);g.sort(function(a,b){return dist(a,[r,c])-dist(b,[r,c])});var tg=g[0]||this.cellsList(ex).sort(function(a,b){return dist(a,[r,c])-dist(b,[r,c])})[0];
 var S1=.55,L=1.45,bx0=this.cx(1),bx1=this.cx(C-2),by0=this.cy(1),by1=this.cy(R-2);function wp(){return[rnd(bx0,bx1),rnd(by0,by1)]}
 var x1=tg?this.cx(tg[1]):x0,y1=tg?this.cy(tg[0]):y0,P=[[x0,y0],[x0,y0-u*.9],wp(),wp(),[x1,y1-u*1.3],[x1,y1]];
 function cr(a,b,c3,d,t){var t2=t*t,t3=t2*t;return .5*((2*b)+(-a+c3)*t+(2*a-5*b+4*c3-d)*t2+(-a+3*b-3*c3+d)*t3)}
 function ptAt(q){var n=P.length-1,f=q*n,k=Math.min(Math.floor(f),n-1),t=f-k,a=P[Math.max(k-1,0)],b=P[k],c3=P[k+1],d=P[Math.min(k+2,n)];return[cr(a[0],b[0],c3[0],d[0],t),cr(a[1],b[1],c3[1],d[1],t)]}
 var hitDone=false,swooshed=false;
 this.obj(function(cx,t,dt){var x,y,sc;if(t<S1){var sp=Math.min(t/S1,1);rot+=(4+sp*26)*dt;x=x0;y=y0;sc=1+sp*.15;
   if(t>S1-.05&&!hitDone){hitDone=true;snd('lakshmi',{v:.5,rate:1.2,cut:.4});s.ring(s.cx(c2)+u/2,s.cy(rr)+u/2,'#FF2FA8',u*1.8,7);s.shake=3;[[rr,c2],[rr,c2+1],[rr+1,c2],[rr+1,c2+1]].forEach(function(p){if(p[0]!=r||p[1]!=c)s.hit(p[0],p[1],{d:rnd(0,.04),pw:1.15})})}}
  else{var f=Math.min((t-S1)/L,1);if(!swooshed){swooshed=true;snd('swoosh',{v:.45,rate:.85});snd('sparkler',{v:.35,rate:.8,cut:1.3,off:.3})}
   var q=f<.85?f/.85*.8:.8+(f-.85)/.15*.2,p=ptAt(Math.min(q,1)),lift=f<.12?f/.12:f>.85?1-(f-.85)/.15:1;x=p[0];y=p[1];sc=1.15+.45*lift;rot+=(22+8*lift)*dt;
   cx.fillStyle='rgba(40,10,70,'+(.22*lift)+')';cx.beginPath();cx.ellipse(x,y+u*.9*lift,u*.42*sc,u*.16*sc,0,0,7);cx.fill();
   if(f>=1){if(tg){s.ring(x1,y1,'#FFD24A',u*2.2,8);s.ring(x1,y1,'#FF2FA8',u*1.6,6);s.pop(x1,y1,'#FF2FA8',1.4);s.shake=4;snd('chakra',{off:1.12,v:.95,cut:.45});s.hit(tg[0],tg[1],{d:0,pw:1.4})}return false}}
  s.spr(8,x,y,u*1.05*sc,rot);for(var k=0;k<3;k++){var a=rot+k*2.09;s.fx.push({k:'spark',x:x+Math.cos(a)*u*.45*sc,y:y+Math.sin(a)*u*.45*sc,z:0,vx:-Math.sin(a)*rnd(90,220),vy:Math.cos(a)*rnd(90,220),vz:0,col:k==1?'#FF2FA8':'#FFC62B',a:0,l:rnd(.2,.35)})}return true},S1+L+.1);
 this.finish(S1+L+.45)};

// ---- Lakshmi Vedi Hammer: drops on one tile
G.hammer=function(r,c){var s=this,u=this.uu(),x=this.cx(c),y=this.cy(r);this.b[r][c]=null;snd('swoosh',{v:.4,rate:1.4});
 this.obj(function(cx,t){var f=Math.min(t/.2,1);s.spr(17,x,y-(1-f*f)*u*3,u*1.2,(1-f)*-.6);if(f>=1){snd('lakshmi',{v:.9,cut:.6});s.pop(x,y,'#FFD24A',1.2);s.ring(x,y,'#FFD24A',u*1.5,6);s.shake=2;var R=s.rows(),C=s.cols();return false}return true},.3);
 this.finish(.6)};

// ---- Seven Shot: 7 big shots, 3 aimed at goal tiles
G.seven=function(r,c){var s=this,u=this.uu(),x=this.cx(c),y=this.cy(r),ex={};ex[r+','+c]=1;snd('swoosh',{v:.3,rate:1.5});
 var g=this.cellsList(ex,true).sort(function(a,b){return dist(a,[r,c])-dist(b,[r,c])}).slice(0,3);g.forEach(function(p){ex[p[0]+','+p[1]]=1});var o=shuffle(this.cellsList(ex).filter(function(p){return dist(p,[r,c])<=3.5})).slice(0,7-g.length),T7=shuffle(g.concat(o));
 this.b[r][c].shakeT=1.3;
 T7.forEach(function(p,i){s.at(.15+i*.14,function(){var colr=['#FFD24A','#7CF0FF','#FF6BD6'][i%3],x1=s.cx(p[1]),y1=s.cy(p[0]),hx=(x+x1)/2+rnd(-u,u),hy=Math.min(y,y1)-u*rnd(2.6,3.6);snd('swoosh',{v:.35,rate:1.3+i*.04});s.ring(x,y-u*.55,'#FFFFFF',u*.8,3);
  s.obj(function(cx,t){var e=Math.min(t/.62,1),ix=(1-e)*(1-e)*x+2*(1-e)*e*hx+e*e*x1,iy=(1-e)*(1-e)*(y-u*.55)+2*(1-e)*e*hy+e*e*y1;for(var k=0;k<2;k++)s.fx.push({k:'spark',x:ix+rnd(-2,2),y:iy+rnd(-2,2),z:0,vx:rnd(-25,25),vy:rnd(-10,40),vz:0,col:k?colr:'#FFFFFF',a:0,l:.4});
   var gr=cx.createRadialGradient(ix,iy,0,ix,iy,u*.3);gr.addColorStop(0,'#FFFFFF');gr.addColorStop(.4,colr);gr.addColorStop(1,'rgba(255,255,255,0)');cx.fillStyle=gr;cx.beginPath();cx.arc(ix,iy,u*.3,0,7);cx.fill();
   if(e>=1){s.ring(x1,y1,colr,u*1.6,6);s.spark2(x1,y1,16,[colr,'#FFFFFF','#FFD24A'],220,.5);snd('lakshmi',{v:.6,rate:1.15+Math.random()*.2,cut:.45});s.hit(p[0],p[1],{d:0,pw:1.2});return false}return true},.7)})});
 this.at(1.3,function(){s.hit(r,c,{d:0,pw:1.2})});this.finish(1.75)};

// ---- Snake Tablet: the ash snake grows and coils around the drop tile, eating 10 tiles
G.snake=function(r,c){var s=this,u=this.uu(),R=this.rows(),C=this.cols(),path=[[r,c]],cr=r,cc=c,D=[[0,1],[1,0],[0,-1],[-1,0]],di=0,len=1,guard=0;snd('paper',{v:.5,rate:.7});
 while(path.length<11&&guard++<60){for(var rep=0;rep<2&&path.length<11;rep++){for(var k=0;k<len&&path.length<11;k++){cr+=D[di][0];cc+=D[di][1];if(cr>=0&&cr<R&&cc>=0&&cc<C)path.push([cr,cc])}di=(di+1)%4}len++}
 var spd=6,dur=(path.length-1)/spd,pts=path.map(function(p){return[s.cx(p[1]),s.cy(p[0])]});this.b[r][c]=null;
 path.forEach(function(p,i){if(i)s.at(.15+i/spd,function(){s.hit(p[0],p[1],{d:0,pw:.9});snd('lakshmi',{v:.35,rate:1.3+Math.random()*.2,cut:.35})})});
 this.obj(function(cx,t){var tt=t-.15;if(tt<0){s.spr(19,pts[0][0],pts[0][1],u*1.0,0);return true}var head=Math.min(tt*spd,pts.length-1),fade=tt>dur?Math.min((tt-dur)/.55,1):0,P=[];
  for(var i=0;i<=head;i+=.08){var a=Math.floor(i),b=Math.min(a+1,pts.length-1),q=i-a,wob=Math.sin(i*6.28)*u*.06,dx=pts[b][0]-pts[a][0],dy=pts[b][1]-pts[a][1],L=Math.hypot(dx,dy)||1;P.push([pts[a][0]+dx*q-dy/L*wob,pts[a][1]+dy*q+dx/L*wob])}
  if(P.length>1){cx.save();cx.lineCap='round';cx.lineJoin='round';cx.globalAlpha=1-fade;[[u*.36,'#1B1720'],[u*.26,'#3A3440'],[u*.08,'#6E6676']].forEach(function(w,j){cx.strokeStyle=w[1];cx.lineWidth=w[0];if(j==2)cx.setLineDash([3,7]);cx.beginPath();cx.moveTo(P[0][0],P[0][1]);for(var k=1;k<P.length;k++)cx.lineTo(P[k][0],P[k][1]);cx.stroke();cx.setLineDash([])});
   var hp=P[P.length-1];cx.fillStyle='#1B1720';cx.beginPath();cx.arc(hp[0],hp[1],u*.22,0,7);cx.fill();cx.fillStyle='#FF8A1A';cx.beginPath();cx.arc(hp[0],hp[1],u*.08,0,7);cx.fill();cx.restore();
   if(Math.random()<.4){var z=P[Math.random()*P.length|0];s.fx.push({k:'spark',x:z[0],y:z[1],z:0,vx:rnd(-20,20),vy:rnd(-60,-20),vz:0,col:'#8A8494',a:0,l:.5})}}
  return tt<dur+.55},.15+dur+.6);
 this.finish(.15+dur+.75)};

// ---- cracker meter: count matched crackers
G.smash0=G.smash;G.smash=function(r,c,o){var e=this.b[r]&&this.b[r][c];if(e&&!e.ob&&!e.diya&&e.k>=0&&e.k<6&&!this.ended&&this.cb&&this.cb.meter){this.mN=(this.mN||0)+1;this.cb.meter(this.mN)}return G.smash0.call(this,r,c,o)};
// ---- Cracker meter pops (free, dragged from the meter): bijli 3 sideways, kuruvi 3 up-down, lakshmi 2x2
G.meterPop=function(kind,r,c){if(this.busy||this.over)return false;var e=this.at2(r,c);if(!e)return false;var s=this,R=this.rows(),C=this.cols(),L=kind=='bijli'?[[r,c-1],[r,c],[r,c+1]]:kind=='kuruvi'?[[r-1,c],[r,c],[r+1,c]]:[[r,c],[r,c+1],[r+1,c],[r+1,c+1]];
 this.busy=true;snd('thud',{v:.9,rate:.7});snd('lakshmi',{v:.7,rate:1,at:.02,cut:.55});var u=this.uu();
 L.forEach(function(p,i){if(p[0]<0||p[0]>=R||p[1]<0||p[1]>=C)return;var x=s.cx(p[1]),y=s.cy(p[0]);s.at(i*.05,function(){s.ring(x,y,'#FFD24A',u*1.1,5);s.hit(p[0],p[1],{d:0,pw:1.15})})});this.finish(.5);return true};
})();
