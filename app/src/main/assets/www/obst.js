// New obstacles (11 Nov 2026). Load after wood.js.
// dpot: clay diya pot, 1 hit. lantern: sky lantern, 1 hit, floats away.
// fbox: firecracker box, 2 hits, pops out 2 specials. gbox: Cracker Gift Box, never breaks;
//       a match next to it (once per move) turns 8-10 nearby crackers into the goal cracker.
// rackc/racks/rackg: 3x3 glass racks with 9 cups / sweets / gifts; each hit takes one item.
(function(){
var G=CrackersGame.prototype,prevDraw=G.drawOver,prevHit=G.hitOb,prevBig=G.hitBig;
function rnd(a,b){return a+Math.random()*(b-a)}
function snd(n,o){if(window.SFX)SFX.play(n,o||{})}
function img(n){var i=new Image();i.src='art/'+n+'.webp';return i}
var SH=img('shelf-glass'),IT={rackc:[0,1,2,3,4,5,6,7,8].map(function(i){return img('cup'+i)}),racks:[0,1,2,0,1,2,0,1,2].map(function(i){return img('sweet'+i)}),rackg:[0,1,2,3,0,1,2,3,0].map(function(i){return img('giftc'+i)})};
['rackc','racks','rackg'].forEach(function(k){G.IC['big-'+k]=img('big-'+k)});
var SLOT=[[27,52],[89,52],[150,52],[27,108],[88,108],[150,108],[27,164],[88,164],[150,164]];
function isRack(B){return B&&(B.t=='rackc'||B.t=='racks'||B.t=='rackg')}
// ---- drawing
G.drawOver=function(c,e,x,y,s){var o=e.ob;if(!o)return prevDraw.call(this,c,e,x,y,s);var t=o.t,I=G.IC,cl=this.clock||0;
 if(t=='big'&&isRack(o.B)){if(!o.anchor)return;var B=o.B,u=this.uu(),W=3*u-(u-s),k=1+(B.sq||0)*.04;B.sq=Math.max(0,(B.sq||0)-.07);c.save();c.translate(x+W/2,y+W/2);c.scale(k,2-k);c.translate(-W/2,-W/2);
  var f=W/234;c.shadowColor='rgba(20,0,40,.4)';c.shadowBlur=10;c.shadowOffsetY=4;if(SH.naturalWidth)c.drawImage(SH,0,0,234*f,233*f);c.shadowColor='transparent';
  var gone=B.max-B.n,L=IT[B.t];for(var i=gone;i<9;i++){var im=L[i];if(!im||!im.naturalWidth)continue;var bw=56,bh=46,sc=Math.min(bw/im.naturalWidth,bh/im.naturalHeight),w=im.naturalWidth*sc,h=im.naturalHeight*sc,p=SLOT[i];c.drawImage(im,(p[0]+(60-w)/2)*f,(p[1]+44-h)*f,w*f,h*f)}
  c.restore();return}
 if(t=='dpot'||t=='lantern'||t=='fbox'||t=='gbox'){var im2=I[OT_F[t]];c.save();var k2=1+(o.sq||0)*.16;if(o.sq)o.sq=Math.max(0,o.sq-.07);
  var bob=t=='lantern'?Math.sin(cl*2.4+x*.05)*2:0,open=t=='gbox'&&o.op>0?o.op:0;if(o.op>0)o.op=Math.max(0,o.op-.03);
  c.translate(x+s/2,y+s/2+bob);c.scale(k2,2-k2);if(open)c.rotate(Math.sin(cl*40)*.08*open);
  if(t=='gbox'){var gl=.5+.5*Math.sin(cl*3+x);c.fillStyle='rgba(255,214,90,'+(.18+.14*gl)+')';c.beginPath();c.arc(0,0,s*.55,0,7);c.fill()}
  if(im2&&im2.naturalWidth){var r=im2.naturalWidth/im2.naturalHeight,h2=s*1.02,w2=h2*r;if(w2>s*1.04){w2=s*1.04;h2=w2/r}c.drawImage(im2,-w2/2,-h2/2+(t=='gbox'?-open*s*.12:0),w2,h2)}
  if(t=='fbox'&&o.hp<2){c.strokeStyle='rgba(20,10,0,.75)';c.lineWidth=2;c.beginPath();c.moveTo(-s*.3,-s*.1);c.lineTo(-s*.05,s*.05);c.lineTo(s*.1,-s*.15);c.lineTo(s*.32,s*.12);c.stroke()}
  c.restore();return}
 return prevDraw.call(this,c,e,x,y,s)};
var OT_F={dpot:'claypot',lantern:'lantern',fbox:'fbox',gbox:'giftbox'};
// blockers stay where they are; crackers fall around them
var FIX={big:1,gbox:1,dpot:1,fbox:1,crate:1,steel:1,stone:1,lantern:1,pot:1};G.fixed=function(e){return !!(e&&e.ob&&FIX[e.ob.t])};
// ---- hits
G.goalCol=function(){if(this.lv.boxK!=null)return this.lv.boxK;var g=this.goal;for(var k in g)if(/^\d+$/.test(k)&&g[k]>0)return +k;return this.lv.colors[0]};
G.hitOb=function(e,p,blast){var o=e.ob;if(!o)return;var t=o.t;
 if(t=='gbox'){if(o.mv===this.moves||(e.safe&&e.safe>this.clock))return;o.mv=this.moves;e.safe=this.clock+.5;o.op=1;o.sq=1;this.openBox(p[0],p[1]);return}
 if(t!='dpot'&&t!='lantern'&&t!='fbox')return prevHit.call(this,e,p,blast);
 if(e.safe&&e.safe>this.clock)return;var x=this.cx(p[1]),y=this.cy(p[0]),u=this.uu(),S=u-4,D=window.DEB,I=G.IC,hp0=o.hp;
 prevHit.call(this,e,p,blast);var dead=!e.ob;
 if(t=='dpot'){if(D)D.chunks(I.claypot,x-S/2,y-S/2,S,3,3,blast?1.3:1);if(D)D.bits(x,y,10,['#D9733A','#A4471C','#FFE08A'],5,1.1);snd('thud',{v:.8,rate:.85});snd('lakshmi',{v:.35,rate:1.3,cut:.35})}
 if(t=='lantern'&&dead){var s=this;snd('swoosh',{v:.5,rate:.8});this.obj(function(c,tt){var f=tt/1.2,yy=y-f*f*(y+80),sc=1-f*.3;c.save();c.globalAlpha=1-f*.5;var gl=c.createRadialGradient(x,yy,2,x,yy,u*.8);gl.addColorStop(0,'rgba(255,200,90,.6)');gl.addColorStop(1,'rgba(255,160,40,0)');c.fillStyle=gl;c.beginPath();c.arc(x,yy,u*.8,0,7);c.fill();var im=I.lantern;if(im.naturalWidth){var h=u*1.05*sc,w=h*im.naturalWidth/im.naturalHeight;c.drawImage(im,x-w/2+Math.sin(tt*5)*4,yy-h/2,w,h)}c.restore();if(Math.random()<.5)s.fx.push({k:'spark',x:x,y:yy+u*.4,z:0,vx:rnd(-20,20),vy:rnd(30,80),vz:0,col:'#FFD24A',a:0,l:.4});return tt<1.2},1.25)}
 if(t=='fbox'){if(!dead){if(D)D.bits(x,y,8,['#3B86F0','#F2B533'],5,.9);snd('paper',{v:.7})}else{if(D)D.chunks(I.fbox,x-S/2,y-S/2,S,3,3,1.2);snd('lakshmi',{v:.8,rate:.9});this.popOut(p[0],p[1])}}};
G.popOut=function(r,c){var s=this,L=this.cellsList(null).filter(function(q){return Math.abs(q[0]-r)+Math.abs(q[1]-c)<=3&&!(q[0]==r&&q[1]==c)});L.sort(function(){return Math.random()-.5});
 L.slice(0,2).forEach(function(q,i){var e=s.at2(q[0],q[1]);if(!e)return;e.k=i?10:15;e.safe=s.clock+.4;e.shakeT=.3;s.ring(s.cx(q[1]),s.cy(q[0]),'#FFD24A',s.uu()*1.3,6);s.spark2(s.cx(q[1]),s.cy(q[0]),10,['#FFD24A','#FFFFFF'],160)})};
G.openBox=function(r,c){var s=this,u=this.uu(),k=this.goalCol(),x0=this.cx(c),y0=this.cy(r),R=this.rows(),C=this.cols();snd('swoosh',{v:.5,rate:1.3});snd('lakshmi',{v:.6,rate:1.1,cut:.5});
 var L=[];for(var a=0;a<R;a++)for(var b=0;b<C;b++){var e=this.at2(a,b);if(e&&!e.dead&&!e.ob&&!e.diya&&e.k>=0&&e.k<6&&e.k!==k&&!(e.fy>0))L.push([a,b])}
 L.sort(function(p,q){return (Math.abs(p[0]-r)+Math.abs(p[1]-c))-(Math.abs(q[0]-r)+Math.abs(q[1]-c))+Math.random()*.8});var n=6+(Math.random()*2|0);
 this.ring(x0,y0,'#FFD24A',u*2,8);this.spark2(x0,y0,18,['#FFD24A','#FF5AA0','#FFFFFF'],260);
 L.slice(0,n).forEach(function(p,i){var e=s.at2(p[0],p[1]);e.k=k;e.safe=s.clock+.35;var x1=s.cx(p[1]),y1=s.cy(p[0]),hx=(x0+x1)/2,hy=Math.min(y0,y1)-u*1.6,d=i*.035;e.hide=s.clock+d+.36;
  s.obj(function(cx,t){var f=Math.min((t-d)/.34,1);if(f<0)return true;var ix=(1-f)*(1-f)*x0+2*(1-f)*f*hx+f*f*x1,iy=(1-f)*(1-f)*y0+2*(1-f)*f*hy+f*f*y1;s.spr(k,ix,iy,u*.8,0);if(f>=1){s.ring(x1,y1,'#FFE58A',u*.9,4);s.spark2(x1,y1,6,['#FFFFFF','#FFD24A'],120);return false}return true},d+.4)})};
// racks: each hit takes one item
G.hitBig=function(B,blast){if(!isRack(B))return prevBig.call(this,B,blast);
 if(B.n<=0||(B.safe&&B.safe>this.clock))return;B.safe=this.clock+(blast?.12:.22);var u=this.uu(),i=B.max-B.n,p=SLOT[i],x=this.cx(B.c)+(p[0]+30)/234*3*u-u/2,y=this.cy(B.r)+(p[1]+22)/233*3*u-u/2;
 B.n--;B.sq=1;this.addScore(60);snd('lakshmi',{v:.35,rate:1.5,cut:.3});snd('paper',{v:.4,rate:1.4});this.spark2(x,y,8,['#FFFFFF','#CDEFFF','#FFD24A'],150);this.count(B.t,B.r+Math.floor(i/3),B.c+i%3);
 if(B.n<=0){var D=window.DEB,I=SH;for(var r=B.r;r<B.r+3;r++)for(var c=B.c;c<B.c+3;c++){if(this.at2(r,c))this.b[r][c]=null}if(D&&I.naturalWidth)D.chunks(I,this.cx(B.c)-u/2,this.cy(B.r)-u/2,3*u,3,3,1.1,{g:1400});snd('thud',{v:1});snd('blast',{off:.2,v:.5,rate:1.2,cut:.3});this.shake=Math.max(this.shake,4);this.ring(this.cx(B.c+1),this.cy(B.r+1),'#CDEFFF',u*2.6,8)}};
})();
