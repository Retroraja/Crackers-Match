// Build 26 specials (11 Nov 2026), as approved in the preview. Load after b26.js.
// - Colour Matchbox: colourful lightning from the box itself, one smooth crackle, one blast
// - Seven Shot: 7 shots up off the screen, then 7 comets come down; 3 aim at goal tiles; each clears a plus
// - combos: the new set of 10
// - gold floor: one carpet with an inner pattern and a soft glow edge
// - Tamil praise words after big moves
(function(){
var G=CrackersGame.prototype;
function rnd(a,b){return a+Math.random()*(b-a)}
function snd(n,o){if(window.SFX)SFX.play(n,o||{})}
function cheer(s,i){if(s.cb&&s.cb.cheer)s.cb.cheer(3+i)}// 0 Mass, 1 Theri, 2 Mersal, 3 Bigil

// ---------- colourful lightning from a point to many cells
function jag(u,x0,y0,x1,y1){var P=[[x0,y0]],d=Math.hypot(x1-x0,y1-y0)||1,n=Math.max(3,Math.round(d/(u*.8)));for(var i=1;i<n;i++){var f=i/n,o=rnd(-1,1)*u*.18;P.push([x0+(x1-x0)*f-(y1-y0)/d*o,y0+(y1-y0)*f+(x1-x0)/d*o])}P.push([x1,y1]);return P}
G.beams=function(x0,y0,L,life){var s=this,u=this.uu();this.obj(function(c,t){var f=t/life,a=f<.12?f/.12:f>.72?(1-f)/.28:1;if(a<0)a=0;c.save();c.lineCap='round';c.lineJoin='round';
 L.forEach(function(b){if(s.clock<b.t)return;if(!b.j||s.clock-b.j>.05){b.j=s.clock;b.P=jag(u,x0,y0,b.x1,b.y1)}var h=(b.h+s.clock*160)%360,P=b.P;
  [[u*.3,'hsla('+h+',100%,50%,'+(.35*a)+')'],[u*.15,'hsla('+h+',100%,58%,'+(.95*a)+')'],[u*.04,'rgba(255,255,255,'+a+')']].forEach(function(w){c.strokeStyle=w[1];c.lineWidth=w[0];c.beginPath();P.forEach(function(q,i){i?c.lineTo(q[0],q[1]):c.moveTo(q[0],q[1])});c.stroke()});
  var p=((s.clock-b.t)*2.2)%1;c.fillStyle='hsla('+((h+60)%360)+',100%,85%,'+a+')';c.beginPath();c.arc(x0+(b.x1-x0)*p,y0+(b.y1-y0)*p,u*.09,0,7);c.fill()});
 var R0=u*(.5+.08*Math.sin(s.clock*50));for(var k=0;k<6;k++){var an=s.clock*6+k*1.047;c.fillStyle='hsla('+((k*60+s.clock*200)%360)+',100%,65%,'+(.6*a)+')';c.beginPath();c.arc(x0+Math.cos(an)*R0*.7,y0+Math.sin(an)*R0*.7,R0*.35,0,7);c.fill()}
 c.fillStyle='rgba(255,255,255,'+(.95*a)+')';c.beginPath();c.arc(x0,y0,R0*.55,0,7);c.fill();c.restore();return t<life},life+.02)};
// lightning to each cell in turn; onHit runs when a bolt lands
G.strike=function(r,c,cells,t0,step,onHit,hold){var s=this,x0=this.cx(c),y0=this.cy(r),L=[],u=this.uu();
 cells.forEach(function(p,i){var h=(i*47)%360,x1=s.cx(p[1]),y1=s.cy(p[0]);L.push({t:s.clock+t0+i*step,h:h,x1:x1,y1:y1});
  s.at(t0+i*step,function(){var col='hsl('+h+',100%,70%)';s.ring(x1,y1,col,u*.8,4);s.spark2(x1,y1,10,['#FFFFFF',col],150);onHit(p)})});
 this.at(t0,function(){snd('sparkler',{off:.3,v:.5,rate:1.15,cut:Math.max(.5,cells.length*step+.3)})});this.beams(x0,y0,L,t0+cells.length*step+(hold||.45))};
function glow(e,s){if(!e)return;e.shakeT=99;e.safe=s.clock+5;e.lit=1}
function unglow(e){if(e){e.shakeT=0;e.safe=0;e.lit=0}}
// order cells by distance from the box so the bolts fan out
function near(L,r,c){return L.sort(function(a,b){return Math.hypot(a[0]-r,a[1]-c)-Math.hypot(b[0]-r,b[1]-c)})}

// ---------- Colour Matchbox
G.boltBox=function(r,c,col){var s=this,u=this.uu(),e=this.b[r][c],x0=this.cx(c),y0=this.cy(r);if(e)e.shakeT=99;snd('swoosh',{v:.45,rate:2.2,cut:.25});
 var L=[],R=this.rows(),C=this.cols();for(var a=0;a<R;a++)for(var b=0;b<C;b++){var f=this.at2(a,b);if(f&&!f.dead&&!f.ob&&f.k===col&&!(a==r&&b==c))L.push([a,b])}near(L,r,c);
 var step=.07,T0=.3+L.length*step+.45;
 this.strike(r,c,L,.3,step,function(p){glow(s.at2(p[0],p[1]),s)},.5);
 this.at(T0,function(){var bx=s.cx((C-1)/2),by=s.cy((R-1)/2);snd('atom',{v:.95});snd('blast',{v:.55,rate:1.1});s.ring(bx,by,'#FFFFFF',u*C*1.1,12);s.ring(bx,by,'#BFE3FF',u*C*.8,8);s.wave(bx,by,18,520);s.shake=7;s.flash=Math.max(s.flash,.45);
  L.forEach(function(p,i){unglow(s.at2(p[0],p[1]));s.hit(p[0],p[1],{d:i*.01,pw:1.3})});var m=s.b[r][c];if(m){m.shakeT=0;s.b[r][c]=null;s.pop(x0,y0,'#FFD24A',1.4)}cheer(s,1)});
 this.finish(T0+.5)};

// ---------- Seven Shot
G.seven=function(r,c){var s=this,u=this.uu(),x=this.cx(c),y=this.cy(r),R=this.rows(),C=this.cols(),ex={};ex[r+','+c]=1;var e=this.b[r][c];if(e)e.firing=true;
 snd('swoosh',{v:.3,rate:1.5});
 this.obj(function(cx,t){var q=Math.min(t/1.6,1);s.spr(18,x+(q<.9?Math.sin(t*60)*1.5:0),y,u*1.25*(1+Math.sin(t*40)*.03*(1-q)));return t<1.6},1.62);
 for(var i=0;i<7;i++)(function(i){s.at(.15+i*.1,function(){var col=['#FFD24A','#7CF0FF','#FF6BD6'][i%3],vx=rnd(-60,60);snd('rocket',{off:.05,v:.35,rate:1.3+i*.04,cut:.25});s.puff(x,y-u*.55,'rgba(255,255,255,.6)',8);
  s.obj(function(c2,t){var px=x+vx*t/.4,py=y-u*.55-(t/.4)*(y+80);s.fx.push({k:'spark',x:px,y:py,z:0,vx:rnd(-20,20),vy:rnd(30,80),vz:0,col:i%2?col:'#FFFFFF',a:0,l:.3});c2.fillStyle=col;c2.beginPath();c2.arc(px,py,u*.14,0,7);c2.fill();return t<.4},.42)})})(i);
 // targets: 3 goal tiles first, then 4 spread-out cells
 var all=this.cCells([[r,c]]),goals=all.slice(0,3),rest=[];all.forEach(function(q){if(goals.indexOf(q)>=0)return;if(rest.length<4&&goals.concat(rest).every(function(z){return Math.hypot(z[0]-q[0],z[1]-q[1])>2.2}))rest.push(q)});
 var T=goals.concat(rest).sort(function(){return Math.random()-.5});
 T.forEach(function(p,i){s.at(1.15+i*.13,function(){var x1=s.cx(p[1]),y1=s.cy(p[0]),x0=x1+rnd(-u*1.5,u*1.5),col=goals.indexOf(p)>=0?'#FFE58A':'#9FE8FF';snd('swoosh',{v:.25,rate:1.2});
  s.obj(function(cc,t){var f=Math.min(t/.55,1),e2=f*f,px=x0+(x1-x0)*e2,py=-40+(y1+40)*e2;var tr=cc.createLinearGradient(px-(x1-x0)*.3,py-u*2.4,px,py);tr.addColorStop(0,'rgba(255,240,180,0)');tr.addColorStop(1,col);cc.strokeStyle=tr;cc.lineWidth=u*.3;cc.lineCap='round';cc.beginPath();cc.moveTo(px-(x1-x0)*.3,py-u*2.4);cc.lineTo(px,py);cc.stroke();
   var gr=cc.createRadialGradient(px,py,0,px,py,u*.45);gr.addColorStop(0,'#FFFFFF');gr.addColorStop(.45,col);gr.addColorStop(1,'rgba(255,255,255,0)');cc.fillStyle=gr;cc.beginPath();cc.arc(px,py,u*.45,0,7);cc.fill();
   if(f>=1){s.ring(x1,y1,col,u*1.4,6);s.spark2(x1,y1,16,[col,'#FFFFFF','#FFD24A'],220);s.shake=Math.max(s.shake,3);snd('lakshmi',{v:.65,rate:1.05+Math.random()*.2,cut:.45});
    [[0,0],[1,0],[-1,0],[0,1],[0,-1]].forEach(function(d){var rr=p[0]+d[0],c3=p[1]+d[1];if(s.at2(rr,c3))s.hit(rr,c3,{d:(d[0]||d[1])?.04:0,pw:1.2})});return false}return true},.6)})});
 this.at(1.6,function(){var m=s.b[r][c];if(m===e&&m){s.b[r][c]=null;s.pop(x,y,'#FFD24A',1.2)}});
 this.finish(1.15+T.length*.13+.8)};

// ---------- combos
var KIND={6:'rocket',15:'rocket',16:'rocket',7:'pot',8:'chakra',9:'sky',10:'bomb',14:'matchbox'};
function hits(s,L,d,pw){L.forEach(function(p){if(s.at2(p[0],p[1]))s.hit(p[0],p[1],{d:d+(p[2]||0),pw:pw||1.3})})}
G.boom=function(r,c,rad,d){var s=this,u=this.uu();this.at(d||0,function(){var x=s.cx(c),y=s.cy(r);snd('atom',{v:.95,rate:rad>1?.85:1});s.ring(x,y,'#FFFFFF',u*(rad+1)*1.1,8);s.ring(x,y,'#FFB43A',u*(rad+.6),6);s.flash=Math.max(s.flash,.3);s.shake=Math.max(s.shake,rad>1?9:6);s.wave(x,y,18,500);
 var L=[];for(var a=-rad;a<=rad;a++)for(var b=-rad;b<=rad;b++)L.push([r+a,c+b,.04*Math.max(Math.abs(a),Math.abs(b))]);hits(s,L,0,1.4)})};
// a Chakra flies to a goal tile carrying another special (or nothing), then lands
G.ride=function(r,c,tr,tc,pay,dur,done){var s=this,u=this.uu(),x0=this.cx(c),y0=this.cy(r),x1=this.cx(tc),y1=this.cy(tr),ang=0,R=this.rows(),C=this.cols();
 var wp=[s.cx(rnd(0,C-1)),s.cy(rnd(0,R-1))],P=[[x0,y0],[x0,y0-u],wp,[x1,y1-u*1.2],[x1,y1]];snd('swoosh',{v:.45,rate:.85});snd('sparkler',{v:.3,rate:.8,cut:dur,off:.3});
 function cr(a,b,c2,d,t){var t2=t*t,t3=t2*t;return .5*((2*b)+(-a+c2)*t+(2*a-5*b+4*c2-d)*t2+(-a+3*b-3*c2+d)*t3)}
 function at(f){var n=P.length-1,q=f*n,k=Math.min(Math.floor(q),n-1),t=q-k,a=P[Math.max(k-1,0)],b=P[k],c2=P[k+1],d=P[Math.min(k+2,n)];return[cr(a[0],b[0],c2[0],d[0],t),cr(a[1],b[1],c2[1],d[1],t)]}
 this.obj(function(c2,t,dt){var f=Math.min(t/dur,1),p=at(f),lift=f<.12?f/.12:f>.85?1-(f-.85)/.15:1,sc=1+.4*lift;ang+=(.3+.2*lift);
  c2.fillStyle='rgba(40,10,70,'+(.2*lift)+')';c2.beginPath();c2.ellipse(p[0],p[1]+u*.85*lift,u*.4*sc,u*.15*sc,0,0,7);c2.fill();
  if(pay!=null)s.spr(pay==15||pay==16?6:pay,p[0],p[1]-u*.7*sc,u*.75*sc,0);s.spr(8,p[0],p[1],u*.95*sc,ang);
  s.fx.push({k:'spark',x:p[0]+rnd(-8,8),y:p[1]+rnd(-8,8),z:0,vx:rnd(-90,90),vy:rnd(-90,90),vz:0,col:Math.random()<.5?'#FFD24A':'#FF5AA0',a:0,l:.3});
  if(f>=1){s.ring(x1,y1,'#FF5AA0',u*1.2,6);s.shake=Math.max(s.shake,4);snd('chakra',{off:1.12,v:.8,cut:.4});done(tr,tc);return false}return true},dur+.05)};
G.goalCells=function(n,r,c){return this.cCells([[r,c]]).slice(0,n)};
G.plus=function(r,c,d){var L=[[0,0],[1,0],[-1,0],[0,1],[0,-1]].map(function(q,i){return[r+q[0],c+q[1],i?.04:0]});hits(this,L,d||0,1.2)};
G.lineFrom=function(r,c){var s=this;['U','D','L','R'].forEach(function(d){s.cFly(r,c,d,{big:1})})};
G.convert=function(r,c,kind){var s=this,R=this.rows(),C=this.cols(),col=this.top(),L=[];for(var a=0;a<R;a++)for(var b=0;b<C;b++){var e=this.at2(a,b);if(e&&!e.dead&&!e.ob&&!e.diya&&e.k===col&&this.rest(e))L.push([a,b])}near(L,r,c);
 var step=.07;this.strike(r,c,L,.2,step,function(p){var e=s.at2(p[0],p[1]);if(!e||e.dead||e.k>=6)return;e.k=kind=='rocket'?[6,15,16][Math.random()*3|0]:kind=='bomb'?10:8;e.safe=s.clock+.3;e.shakeT=.2;e.firing=true});
 var T0=.2+L.length*step+.5,gap=kind=='chakra'?.22:.16,goals=kind=='chakra'?this.goalCells(L.length,r,c):[];
 L.forEach(function(p,i){s.at(T0+i*gap,function(){var e=s.at2(p[0],p[1]);if(!e||e.dead||e.k<6)return;e.firing=false;s.b[p[0]][p[1]]=null;s.pop(s.cx(p[1]),s.cy(p[0]),'#FFC62B',1);
  if(e.k==6){snd('rocket',{v:.5,rate:rnd(.95,1.12)});s.cFly(p[0],p[1],Math.random()<.5?'U':'D',{})}else if(e.k==15||e.k==16){snd('rocket',{v:.5,rate:rnd(.95,1.12)});s.cFly(p[0],p[1],Math.random()<.5?'L':'R',{})}
  else if(e.k==10)s.boom(p[0],p[1],1,0);else{var t=goals[i]||[p[0],p[1]];s.ride(p[0],p[1],t[0],t[1],null,.9,function(tr,tc){s.plus(tr,tc)})}})});
 return T0+L.length*gap+1.3};
var run0=G.comboRun;
G.comboRun=function(ka,kb,r,c){var A=KIND[ka],B=KIND[kb],key=[A,B].sort().join('|'),s=this;
 switch(key){
 case 'rocket|rocket':snd('rocket',{rate:.95});snd('rocket',{rate:1.08,v:.7,at:.05});this.lineFrom(r,c);return 1.15;
 case 'bomb|rocket':snd('rocket',{rate:.92});snd('rocket',{rate:1.06,v:.7,at:.06});snd('atom',{v:.6});for(var d=-1;d<=1;d++){s.cFly(r+d,c,'L',{big:1});s.cFly(r+d,c,'R',{big:1});s.cFly(r,c+d,'U',{big:1});s.cFly(r,c+d,'D',{big:1})}return 1.4;
 case 'chakra|rocket':var t1=this.goalCells(1,r,c)[0]||[r,c];this.ride(r,c,t1[0],t1[1],A=='rocket'?ka:kb,1.2,function(tr,tc){snd('rocket');s.lineFrom(tr,tc)});return 2.4;
 case 'bomb|bomb':this.boom(r,c,2,0);return 1.2;
 case 'bomb|chakra':var t2=this.goalCells(1,r,c)[0]||[r,c];this.ride(r,c,t2[0],t2[1],10,1.2,function(tr,tc){s.boom(tr,tc,1,.1)});return 2.4;
 case 'chakra|chakra':this.goalCells(3,r,c).forEach(function(t3,i){s.at(i*.18,function(){s.ride(r,c,t3[0],t3[1],null,1.1,function(tr,tc){s.plus(tr,tc)})})});return 2.3;
 case 'matchbox|rocket':cheer(this,2);return this.convert(r,c,'rocket');
 case 'bomb|matchbox':cheer(this,2);return this.convert(r,c,'bomb');
 case 'chakra|matchbox':cheer(this,2);return this.convert(r,c,'chakra');
 case 'matchbox|matchbox':return this.finale2(r,c);
 }
 return run0.call(this,ka,kb,r,c)};
// lightning to every tile at once, the whole board lights up, then it all bursts
G.finale2=function(r,c){var s=this,u=this.uu(),R=this.rows(),C=this.cols(),L=[];for(var a=0;a<R;a++)for(var b=0;b<C;b++){var e=this.at2(a,b);if(e&&!e.dead&&!(a==r&&b==c))L.push([a,b])}
 snd('matchbox',{v:.6,cut:.5});this.flash=Math.max(this.flash,.25);
 this.strike(r,c,L,.25,0,function(p){var e=s.at2(p[0],p[1]);if(e&&!e.ob){e.shakeT=99;e.safe=s.clock+3}},.9);this.at(.25,function(){s.flash=Math.max(s.flash,.35);snd('blast',{off:.2,v:.6,rate:1.3,cut:.3})});
 this.at(1.2,function(){var bx=s.cx((C-1)/2),by=s.cy((R-1)/2);snd('finale',{v:.9});snd('atom',{v:1,rate:.85});s.flash=.7;s.shake=10;s.ring(bx,by,'#FFFFFF',u*C*1.2,12);s.ring(bx,by,'#BFE3FF',u*C*.9,9);s.wave(bx,by,22,520);
  L.forEach(function(p){var e=s.at2(p[0],p[1]);if(e){e.shakeT=0;e.safe=0}var d=Math.hypot(p[0]-r,p[1]-c)*.03;if(e&&e.k>=6&&!e.ob){s.at(d,function(){var f=s.at2(p[0],p[1]);if(f===e){s.b[p[0]][p[1]]=null;s.pop(s.cx(p[1]),s.cy(p[0]),'#FFD24A',1)}})}else s.hit(p[0],p[1],{d:d,pw:1.4})});cheer(s,3)});
 return 2.2};

// ---------- gold floor: one carpet, inner pattern, soft glow edge
function goldCarpet(X,isG,OX,OY,U,R,C,t){var r,c,any=0;X.save();X.beginPath();for(r=0;r<R;r++)for(c=0;c<C;c++)if(isG(r,c)){any=1;X.rect(OX+c*U-.5,OY+r*U-.5,U+1,U+1)}if(!any){X.restore();return}
 X.save();X.shadowColor='rgba(255,200,60,.95)';X.shadowBlur=U*.35;X.fillStyle='#F2B533';X.fill();X.restore();X.clip();
 var g=X.createLinearGradient(OX,OY,OX+U*C,OY+U*R);g.addColorStop(0,'#FBD966');g.addColorStop(.35,'#E9A72A');g.addColorStop(.6,'#FFE48A');g.addColorStop(1,'#D18E1C');X.fillStyle=g;X.fillRect(OX,OY,U*C,U*R);
 X.strokeStyle='rgba(160,95,10,.35)';X.lineWidth=1;for(var k=-R*2;k<(C+R)*2;k++){X.beginPath();X.moveTo(OX+k*U/2,OY);X.lineTo(OX+k*U/2+U*R,OY+U*R);X.moveTo(OX+k*U/2+U*R,OY);X.lineTo(OX+k*U/2,OY+U*R);X.stroke()}
 for(r=0;r<R;r++)for(c=0;c<C;c++)if(isG(r,c)){var mx=OX+c*U+U/2,my=OY+r*U+U/2,d=U*.22;X.fillStyle='#FFF1B8';X.beginPath();X.moveTo(mx,my-d);X.lineTo(mx+d,my);X.lineTo(mx,my+d);X.lineTo(mx-d,my);X.closePath();X.fill();X.fillStyle='#E39A1E';X.beginPath();X.moveTo(mx,my-d*.5);X.lineTo(mx+d*.5,my);X.lineTo(mx,my+d*.5);X.lineTo(mx-d*.5,my);X.closePath();X.fill();
  X.fillStyle='rgba(255,250,220,.9)';[[OX+c*U,OY+r*U],[OX+c*U+U,OY+r*U],[OX+c*U,OY+r*U+U],[OX+c*U+U,OY+r*U+U]].forEach(function(p){X.beginPath();X.arc(p[0],p[1],U*.05,0,7);X.fill()})}
 var sx=OX-U*3+((t*90)%(U*C+U*8)),s2=X.createLinearGradient(sx,0,sx+U*2.4,0);s2.addColorStop(0,'rgba(255,255,255,0)');s2.addColorStop(.5,'rgba(255,255,245,.5)');s2.addColorStop(1,'rgba(255,255,255,0)');X.fillStyle=s2;X.fillRect(sx,OY,U*2.4,U*R);
 for(r=0;r<R;r++)for(c=0;c<C;c++)if(isG(r,c)&&((r*7+c*3)%5==0)){var px=OX+c*U+U*.78,py=OY+r*U+U*.22,s=U*.13*(.6+.4*Math.abs(Math.sin(t*3+r+c)));X.fillStyle='#FFFFFF';X.beginPath();X.moveTo(px,py-s);X.quadraticCurveTo(px,py,px+s,py);X.quadraticCurveTo(px,py,px,py+s);X.quadraticCurveTo(px,py,px-s,py);X.quadraticCurveTo(px,py,px,py-s);X.fill()}
 X.restore();X.save();X.strokeStyle='#FFF6CC';X.lineWidth=1.8;X.lineCap='round';X.beginPath();for(r=0;r<R;r++)for(c=0;c<C;c++)if(isG(r,c)){var L=OX+c*U,T=OY+r*U,i=2.5;
  if(!isG(r-1,c)){X.moveTo(L,T+i);X.lineTo(L+U,T+i)}if(!isG(r+1,c)){X.moveTo(L,T+U-i);X.lineTo(L+U,T+U-i)}if(!isG(r,c-1)){X.moveTo(L+i,T);X.lineTo(L+i,T+U)}if(!isG(r,c+1)){X.moveTo(L+U-i,T);X.lineTo(L+U-i,T+U)}}X.stroke();X.restore()}
var GT=null;function goldTile(){if(GT)return GT;var c=document.createElement('canvas');c.width=c.height=64;goldCarpet(c.getContext('2d'),function(r,cc){return r==0&&cc==0},0,0,64,1,1,0);c.naturalWidth=c.naturalHeight=64;return GT=c}
var floor0=G.drawFloor;
G.drawFloor=function(c,u){var fl=this.fl,gold={},any=false;for(var k in fl)if(fl[k].t=='gold'){gold[k]=fl[k];any=true}
 if(!any)return floor0.call(this,c,u);for(k in gold)delete fl[k];try{floor0.call(this,c,u)}finally{for(k in gold)fl[k]=gold[k]}
 var x0=this.cx(0)-u/2,y0=this.cy(0)-u/2;goldCarpet(c,function(r,cc){return !!gold[r+','+cc]},x0,y0,u,this.rows(),this.cols(),this.clock)};
var fl0=G.hitFl;
G.hitFl=function(r,c){var f=this.fl[r+','+c];if(!f||f.t!='gold'||!window.DEB)return fl0.call(this,r,c);var D=DEB,ch=D.chunks;D.chunks=function(img,a,b,S,co,ro,pw,o){ch.call(D,goldTile(),a,b,S,co,ro,pw,o)};try{fl0.call(this,r,c)}finally{D.chunks=ch}};
})();
