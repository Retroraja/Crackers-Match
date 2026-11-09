// Big shelves that break piece by piece: bottles, fruit, sweets, diyas, gifts.
// Load after fx.js (and after glassrack.js; cups stay with glassrack).
// Every hit takes ONE item out of the real art: the item breaks off, shatters into
// pieces of itself, and that piece flies to the goal. The container also cracks
// and chips a little on every hit. The last hit breaks the empty container apart.
(function(){
var G=CrackersGame.prototype,prevDraw=G.drawOver,prevHit=G.hitBig;
function rnd(a,b){return a+Math.random()*(b-a)}
function snd(n,o){if(window.SFX)SFX.play(n,o||{})}
// item areas in each image's own pixels: [x,y,w,h]
var CONF={
 bottles:{R:[[33,9,24,40],[57,27,25,40],[85,6,30,85],[148,24,24,43],[175,12,28,55],[21,39,43,91],[60,39,46,91],[109,36,39,94],[158,39,48,91]],
  half:.45,fill:'#3E1C08',inside:[14,40,200,135],zone:[8,128,212,90],crack:'rgba(60,25,5,.85)',bits:['#FFFFFF','#9FD8FF','#FF8FD8','#7BD07B','#FFB040'],shape:'tri',sound:['tick',1.7]},
 fruit:{R:[[88,15,51,39],[39,27,52,43],[139,6,43,67],[190,33,40,85],[67,45,36,40],[154,64,42,36],[18,64,49,57],[51,82,61,57],[94,57,60,82],[133,85,76,54]],
  zone:[12,120,216,95],crack:'rgba(70,35,8,.85)',bits:['#FF9A1A','#F23B3B','#9BD13B','#7B2C8C','#FFD84A'],fill:'#6A3A12',insideE:[122,120,104,40],sound:['pop',1.1]},
 sweets:{R:[[19,85,64,33],[86,85,63,33],[152,85,67,33],[19,118,64,33],[86,118,63,33],[152,118,67,33],[19,151,64,31],[86,151,63,31],[152,151,67,31]],
  fill:'#B9781E',zone:[10,186,212,36],zone2:[22,10,190,60],crack:'rgba(90,20,40,.8)',bits:['#FF9A1A','#F5E6C8','#D9802A','#FFFFFF'],sound:['pop',1.3]},
 diyas:{R:[[33,64,58,60],[118,64,55,60],[6,109,54,57],[145,109,58,57],[51,136,31,33],[133,136,30,33]],
  zone:[50,170,110,60],crack:'rgba(80,45,5,.85)',bits:['#FFD24A','#C98A2E','#FFF3A6','#FF8A1A'],sound:['tick',1.4]},
 gifts:{R:[[65,0,133,130],[7,100,115,118],[119,106,124,124]],stages:3,bits:['#2F6BD8','#E8273F','#FFD24A','#8A7BC8','#FFFFFF'],shape:'paper',sound:['paper',1.1]}
};
var IMG={},ICON={};window.BIG_ICON=ICON;
Object.keys(CONF).forEach(function(t){var im=new Image();im.onload=function(){var r=CONF[t].R[0],c=document.createElement('canvas');c.width=r[2]*2;c.height=r[3]*2;c.getContext('2d').drawImage(im,r[0],r[1],r[2],r[3],0,0,r[2]*2,r[3]*2);ICON[t]=c.toDataURL()};im.src='art/big-'+t+'.webp';IMG[t]=im});
function tag(cv){cv.naturalWidth=cv.width;cv.naturalHeight=cv.height;return cv}
function jag(x,y,w,h,j){var p=[],n=4;for(var i=0;i<=n;i++)p.push([x+w*i/n,y+rnd(-j,j)]);for(i=1;i<=n;i++)p.push([x+w+rnd(-j,j),y+h*i/n]);for(i=n-1;i>=0;i--)p.push([x+w*i/n,y+h+rnd(-j,j)]);for(i=n-1;i>0;i--)p.push([x+rnd(-j,j),y+h*i/n]);return p}
function blob(cx,cy,rx,ry,j){var p=[];for(var i=0;i<16;i++){var a=i/16*6.283,k=1+rnd(-j,j);p.push([cx+Math.cos(a)*rx*k,cy+Math.sin(a)*ry*k])}return p}
function path(x,P){x.beginPath();P.forEach(function(q,i){i?x.lineTo(q[0],q[1]):x.moveTo(q[0],q[1])});x.closePath()}
function mk(B){var I=IMG[B.t],c=document.createElement('canvas');c.width=I.naturalWidth*2;c.height=I.naturalHeight*2;var x=c.getContext('2d');x.scale(2,2);x.drawImage(I,0,0);B.dmg=tag(c);B.dx=x;B.iw=I.naturalWidth;B.ih=I.naturalHeight;B.hits=0;B.done={};B.stage={}}
function crop(B,P){var minx=1e9,miny=1e9,maxx=-1e9,maxy=-1e9;P.forEach(function(p){minx=Math.min(minx,p[0]);miny=Math.min(miny,p[1]);maxx=Math.max(maxx,p[0]);maxy=Math.max(maxy,p[1])});
 var S=Math.max(maxx-minx,maxy-miny),c=document.createElement('canvas');c.width=c.height=Math.ceil(S*2);var x=c.getContext('2d');x.scale(2,2);x.translate(-minx+(S-(maxx-minx))/2,-miny+(S-(maxy-miny))/2);path(x,P);x.clip();x.drawImage(B.dmg,0,0,B.iw,B.ih);return{c:tag(c),x:minx-(S-(maxx-minx))/2,y:miny-(S-(maxy-miny))/2,S:S}}
function erase(B,P){var x=B.dx;x.save();x.globalCompositeOperation='destination-out';path(x,P);x.fill();x.restore()}
function crack(B,C){var z=Math.random()<.5&&C.zone2?C.zone2:C.zone;if(!z)return;var x=B.dx,px=z[0]+rnd(0,z[2]),py=z[1]+rnd(0,z[3]),a=rnd(0,6.28),pts=[[px,py]];for(var i=0;i<6;i++){a+=rnd(-.7,.7);px+=Math.cos(a)*rnd(4,8);py+=Math.sin(a)*rnd(3,6);pts.push([px,py])}
 x.save();x.globalCompositeOperation='source-atop';x.lineJoin='round';x.lineCap='round';x.strokeStyle='rgba(255,255,255,.45)';x.lineWidth=2;x.beginPath();pts.forEach(function(q,i){i?x.lineTo(q[0]+.7,q[1]+.7):x.moveTo(q[0]+.7,q[1]+.7)});x.stroke();x.strokeStyle=C.crack;x.lineWidth=1.4;x.beginPath();pts.forEach(function(q,i){i?x.lineTo(q[0],q[1]):x.moveTo(q[0],q[1])});x.stroke();x.restore()}
function chip(s,B,C){var z=C.zone;if(!z)return;var d=B.dx.getImageData(0,0,B.iw*2,B.ih*2).data,cx=z[0]+z[2]/2,cy=z[1]+z[3]/2,a=Math.random()<.5?rnd(-.5,.5):rnd(2.6,3.7),px=cx,py=cy;
 for(var i=0;i<300;i++){var nx=px+Math.cos(a),ny=py+Math.sin(a);if(nx<0||ny<0||nx>=B.iw||ny>=B.ih)break;if(d[((ny*2|0)*B.iw*2+(nx*2|0))*4+3]<20)break;px=nx;py=ny}
 var r=rnd(6,11),P=[];for(var k=0;k<6;k++){var b=k/6*6.28+rnd(0,.5);P.push([px+Math.cos(b)*r*rnd(.6,1.2),py+Math.sin(b)*r*rnd(.6,1.2)])}
 var piece=crop(B,P);erase(B,P);var g=B.geo;if(!g)return;DEB.chunks(piece.c,g.cx+g.ox+piece.x*g.sc,g.cy+g.oy+piece.y*g.sc,piece.S*g.sc,1,1,.7,{g:1600})}
G.drawOver=function(c,e,x,y,s){var o=e.ob;if(!(o&&o.t=='big'&&CONF[o.B.t]&&!window.OLD))return prevDraw.call(this,c,e,x,y,s);if(!o.anchor)return;
 var B=o.B,U=this.uu(),W=B.w*U-(U-s),H=B.h*U-(U-s),k=1+B.sq*.07;B.sq=Math.max(0,B.sq-.06);var I=IMG[B.t];if(!I.naturalWidth)return;if(!B.dmg)mk(B);
 var jx=B.sq>.3?(Math.random()-.5)*B.sq*4:0;c.save();c.translate(x+W/2+jx,y+H/2);c.scale(k,2-k);
 var ar=B.iw/B.ih,dw=W*1.04,dh=dw/ar;if(dh>H*1.06){dh=H*1.06;dw=dh*ar}var sc=dw/B.iw,ox=-dw/2,oy=-dh/2-2;
 c.drawImage(B.dmg,ox,oy,dw,dh);B.geo={cx:x+W/2,cy:y+H/2,ox:ox,oy:oy,sc:sc};
 var tx=String(B.n);c.font='15px Titan,sans-serif';var bw=Math.max(26,c.measureText(tx).width+14);c.fillStyle='#1F1B3A';c.beginPath();c.roundRect(W/2-bw-2,H/2-24,bw,22,11);c.fill();c.fillStyle='#fff';c.textAlign='center';c.textBaseline='middle';c.fillText(tx,W/2-bw/2-2,H/2-12.5);
 c.restore()};
G.hitBig=function(B,blast){var C=CONF[B.t];if(!C||window.OLD)return prevHit.call(this,B,blast);
 if(B.n<=0||B.safe>this.clock)return;if(!B.dmg){if(!IMG[B.t].naturalWidth)return;mk(B)}B.safe=this.clock+(blast?.3:.25);B.sq=1;
 var n=blast?2:1;this.shake=Math.max(this.shake,3);
 for(var i=0;i<n&&B.n>0;i++){this.breakItem(B,C,i*.08);B.n--;B.hits++;this.addScore(60);crack(B,C);if(B.hits%2)crack(B,C);if(B.hits>1&&C.zone)chip(this,B,C)}
 if(B.n<=0){var s=this;this.at(.2,function(){s.bigDown(B,C)})}};
G.breakItem=function(B,C,d){var s=this,st=C.stages||1,left=[];C.R.forEach(function(r,j){if(!B.done[j])left.push(j)});if(!left.length)return;
 var j=st>1?left[0]:left[Math.random()*left.length|0],r=C.R[j],stage=(B.stage[j]||0)+1;B.stage[j]=stage;if(stage>=st)B.done[j]=1;
 var P,fill=null;
 if(st>1){ // gifts: bow off, then wrap rips, then the box goes
  if(stage==1)P=blob(r[0]+r[2]/2,r[1]+r[3]*.2,r[2]*.4,r[3]*.21,.12);
  else if(stage==2){P=blob(r[0]+r[2]*.36,r[1]+r[3]*.64,r[2]*.27,r[3]*.22,.3);fill='#C99A62'}
  else P=jag(r[0],r[1],r[2],r[3],5)}
 else if(C.half){P=blob(r[0]+r[2]/2,r[1]+r[3]*.28,r[2]*.46,r[3]*.36,.14)}
 else P=blob(r[0]+r[2]/2,r[1]+r[3]/2,r[2]*.5,r[3]*.5,.1);
 var piece=crop(B,P);
 if(fill){var x=B.dx;x.save();x.globalCompositeOperation='source-atop';path(x,P);x.fillStyle=fill;x.fill();x.strokeStyle='rgba(255,255,255,.7)';x.lineWidth=1.5;x.stroke();x.restore()}
 else{erase(B,P);if(C.fill){var x2=B.dx;x2.save();if(C.inside){x2.beginPath();x2.rect(C.inside[0],C.inside[1],C.inside[2],C.inside[3]);x2.clip()}if(C.insideE){x2.beginPath();x2.ellipse(C.insideE[0],C.insideE[1],C.insideE[2],C.insideE[3],0,0,7);x2.clip()}x2.globalCompositeOperation='destination-over';path(x2,P);x2.fillStyle=C.fill;x2.fill();x2.restore();
   B.dx.save();B.dx.globalCompositeOperation='source-atop';path(B.dx,P);B.dx.fillStyle='rgba(60,30,0,.25)';B.dx.fill();B.dx.restore()}}
 this.at(d,function(){var g=B.geo;if(!g)return;var px=g.cx+g.ox+(piece.x+piece.S/2)*g.sc,py=g.cy+g.oy+(piece.y+piece.S/2)*g.sc,S=piece.S*g.sc;
  DEB.chunks(piece.c,px-S/2,py-S/2,S,2,2,.9,{g:1500});DEB.bits(px,py,10,C.bits,5,1,{shape:C.shape||'tri'});s.spark(px,py,8,['#FFFFFF','#FFE7A8'],170);
  snd(C.sound[0],{rate:C.sound[1]+B.hits*.04,v:.5});
  if(s.goal[B.t]>0){s.goal[B.t]--;window.FLY_SRC=piece.c.toDataURL();if(s.cb.fly)s.cb.fly(B.t,px,py);window.FLY_SRC=null;if(s.cb.goal)s.cb.goal(s.goal)}})};
G.bigDown=function(B,C){var U=this.uu(),x=this.cx(B.c)+(B.w-1)*U/2,y=this.cy(B.r)+(B.h-1)*U/2,S=Math.max(B.w,B.h)*U;
 for(var r=B.r;r<B.r+B.h;r++)for(var c=B.c;c<B.c+B.w;c++){if(this.at2(r,c))this.b[r][c]=null}
 DEB.chunks(B.dmg,x-S/2,y-S/2,S,4,4,1.3,{g:1500});DEB.bits(x,y,20,C.bits,6,1.4,{shape:C.shape||'tri'});
 this.shake=Math.max(this.shake,10);this.flash=Math.max(this.flash,.35);this.burst(x,y,['#FFD24A','#FFFFFF','#FF7A1A'],30,320);snd('thud',{v:1});snd('blast',{v:.6})};
})();
