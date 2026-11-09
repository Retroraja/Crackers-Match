// Glass cup rack that visibly breaks on every hit. Load after combos.js.
// Each hit: one cup flies to the goal and often leaves a broken half-cup behind,
// a new crack runs through the glass, and one piece of the frame chips off and falls.
(function(){
var G=CrackersGame.prototype,prevDraw=G.drawOver,prevHit=G.hitBig;
var CUPS=window.CUP_IMGS,IW=234,IH=233;
var GL=new Image();GL.src='art/shelf-glass.webp';
function rnd(a,b){return a+Math.random()*(b-a)}
function snd(n,o){if(window.SFX)SFX.play(n,o||{})}
// frame pieces that chip off, in image space, in the order they break
var CHIPS=[
 [[12,44],[30,24],[44,34],[30,46],[20,60]],
 [[222,44],[204,22],[192,34],[206,46],[214,60]],
 [[8,112],[24,104],[30,120],[18,134],[8,130]],
 [[226,146],[210,136],[204,154],[216,166],[226,162]],
 [[98,10],[118,2],[136,10],[126,24],[106,24]],
 [[12,206],[34,202],[38,220],[16,230]],
 [[222,206],[200,202],[196,220],[218,230]],
 [[52,14],[76,6],[82,22],[62,30]],
 [[156,8],[180,14],[174,28],[152,22]]
];
// crack start points along the frame, image space
var STARTS=[[24,70],[210,90],[117,30],[20,170],[214,190],[70,224],[160,226],[60,40],[176,40],[118,120]];
function mkDmg(B){var c=document.createElement('canvas');c.width=IW*2;c.height=IH*2;c.naturalWidth=IW*2;c.naturalHeight=IH*2;var x=c.getContext('2d');x.scale(2,2);if(GL.naturalWidth)x.drawImage(GL,0,0,IW,IH);B.dmg=c;B.dx=x;B.half={};B.hits=0;B.tilt=0}
function crack(B){var x=B.dx,p=STARTS[B.hits%STARTS.length],px=p[0],py=p[1],cx=117,cy=118,ang=Math.atan2(cy-py,cx-px)+rnd(-.5,.5),len=rnd(36,62),pts=[[px,py]];
 for(var i=0;i<6;i++){ang+=rnd(-.6,.6);px+=Math.cos(ang)*len/6;py+=Math.sin(ang)*len/6;pts.push([px,py])}
 var line=function(P,w,col){x.strokeStyle=col;x.lineWidth=w;x.beginPath();P.forEach(function(q,i){i?x.lineTo(q[0],q[1]):x.moveTo(q[0],q[1])});x.stroke()};
 x.save();x.lineJoin='round';x.lineCap='round';
 x.globalCompositeOperation='source-atop';
 line(pts.map(function(q){return[q[0]+.8,q[1]+.8]}),2.4,'rgba(255,255,255,.9)');line(pts,1.4,'rgba(22,52,120,.85)');
 for(var b=0;b<2;b++){var k=2+((Math.random()*3)|0),q=pts[k],a2=ang+(b?1:-1)*rnd(.7,1.3),L=rnd(10,20),br=[q,[q[0]+Math.cos(a2)*L*.5+rnd(-2,2),q[1]+Math.sin(a2)*L*.5+rnd(-2,2)],[q[0]+Math.cos(a2)*L,q[1]+Math.sin(a2)*L]];line(br,1.1,'rgba(22,52,120,.7)')}
 // small star burst where the crack starts
 for(var j=0;j<5;j++){var a3=j*1.26+rnd(0,.5);line([pts[0],[pts[0][0]+Math.cos(a3)*rnd(4,8),pts[0][1]+Math.sin(a3)*rnd(4,8)]],1,'rgba(22,52,120,.6)')}
 x.restore()}
function chip(s,B){var poly=CHIPS[(B.hits-1)%CHIPS.length];if(B.hits>CHIPS.length)return;var g=B.geo;if(!g)return;
 // copy the piece out before erasing it
 var minx=1e9,miny=1e9,maxx=-1e9,maxy=-1e9;poly.forEach(function(p){minx=Math.min(minx,p[0]);miny=Math.min(miny,p[1]);maxx=Math.max(maxx,p[0]);maxy=Math.max(maxy,p[1])});
 var S=Math.max(maxx-minx,maxy-miny)+4,pc=document.createElement('canvas');pc.width=pc.height=Math.ceil(S*2);pc.naturalWidth=pc.naturalHeight=pc.width;var px=pc.getContext('2d');px.scale(2,2);px.translate(-minx+2,-miny+2);
 px.beginPath();poly.forEach(function(p,i){i?px.lineTo(p[0],p[1]):px.moveTo(p[0],p[1])});px.closePath();px.clip();px.drawImage(B.dmg,0,0,IW,IH);
 var x=B.dx;x.save();x.globalCompositeOperation='destination-out';x.beginPath();poly.forEach(function(p,i){i?x.lineTo(p[0],p[1]):x.moveTo(p[0],p[1])});x.closePath();x.fill();x.restore();
 // bright broken edge
 x.save();x.globalCompositeOperation='source-atop';x.strokeStyle='rgba(255,255,255,.95)';x.lineWidth=2.2;x.beginPath();poly.forEach(function(p,i){i?x.lineTo(p[0],p[1]):x.moveTo(p[0],p[1])});x.closePath();x.stroke();x.restore();
 var wx=g.cx+g.ox+(minx-2)*g.sc,wy=g.cy+g.oy+(miny-2)*g.sc,ws=S*g.sc;
 DEB.chunks(pc,wx,wy,ws,2,2,.8,{g:1600});
 DEB.bits(wx+ws/2,wy+ws/2,8,['#FFFFFF','#CFE6FF','#8FBFF0'],4,.9,{shape:'tri'})}
G.drawOver=function(c,e,x,y,s){var o=e.ob;if(!(o&&o.t=='big'&&o.B.t=='cups'&&!window.OLD))return prevDraw.call(this,c,e,x,y,s);if(!o.anchor)return;
 var B=o.B,U=this.uu(),W=B.w*U-(U-s),H=B.h*U-(U-s),k=1+B.sq*.07;B.sq=Math.max(0,B.sq-.06);if(!B.cups)B.cups=CUPS.map(function(){return true});if(!B.dmg&&GL.naturalWidth)mkDmg(B);
 var jx=B.sq>.3?(Math.random()-.5)*B.sq*4:0;
 c.save();c.translate(x+W/2+jx,y+H/2);c.scale(k,2-k);
 var dw=W*1.04,dh=dw/(IW/IH);if(dh>H*1.06){dh=H*1.06;dw=dh*(IW/IH)}var sc=dw/IW,ox=-dw/2,oy=-dh/2-2;
 if(B.dmg)c.drawImage(B.dmg,ox,oy,dw,dh);
 CUPS.forEach(function(cp,i){if(!cp.img.naturalWidth)return;var X=ox+cp.x*sc,Y=oy+cp.y*sc,w=cp.w*sc,h=cp.h*sc;
  if(B.cups[i]){c.drawImage(cp.img,X,Y,w,h);return}
  var hf=B.half&&B.half[i];if(!hf)return;
  // broken half cup: lower part with a jagged top edge, slightly tilted
  c.save();c.translate(X+w/2,Y+h);c.rotate(hf.r);c.beginPath();c.moveTo(-w/2,0);var top=-h*hf.h;c.lineTo(-w/2,top+hf.j[0]*h);for(var q=1;q<hf.j.length;q++)c.lineTo(-w/2+w*q/(hf.j.length-1),top+hf.j[q]*h);c.lineTo(w/2,0);c.closePath();c.clip();
  c.drawImage(cp.img,-w/2,-h,w,h);c.globalCompositeOperation='source-atop';c.fillStyle='rgba(20,40,90,.12)';c.fillRect(-w/2,-h,w,h);c.restore();
  c.save();c.translate(X+w/2,Y+h);c.rotate(hf.r);c.strokeStyle='rgba(255,255,255,.9)';c.lineWidth=1.4;c.beginPath();for(q=0;q<hf.j.length;q++){var px=-w/2+w*q/(hf.j.length-1),py=top+hf.j[q]*h;q?c.lineTo(px,py):c.moveTo(px,py)}c.stroke();c.restore()});
 B.geo={cx:x+W/2,cy:y+H/2,ox:ox,oy:oy,sc:sc};
 var tx=String(B.n);c.font='15px Titan,sans-serif';var bw=Math.max(26,c.measureText(tx).width+14);c.fillStyle='#1F1B3A';c.beginPath();c.roundRect(W/2-bw-2,H/2-24,bw,22,11);c.fill();c.fillStyle='#fff';c.textAlign='center';c.textBaseline='middle';c.fillText(tx,W/2-bw/2-2,H/2-12.5);
 c.restore()};
G.hitBig=function(B,blast){if(B.t!='cups'||window.OLD)return prevHit.call(this,B,blast);
 if(B.n<=0||B.safe>this.clock)return;if(!B.cups)B.cups=CUPS.map(function(){return true});if(!B.dmg)mkDmg(B);B.safe=this.clock+(blast?.3:.25);B.sq=1;
 var s=this,n=blast?2:1;this.shake=Math.max(this.shake,3+B.hits*.4);
 for(var i=0;i<n&&B.n>0;i++){var alive=[];B.cups.forEach(function(a,j){if(a)alive.push(j)});if(!alive.length)break;var j=alive[Math.random()*alive.length|0];B.cups[j]=false;B.n--;B.hits++;this.addScore(60);
  if(B.hits%3!=2)B.half[j]={h:rnd(.38,.55),r:rnd(-.12,.12),j:[rnd(-.1,.1),rnd(-.25,-.05),rnd(.05,.2),rnd(-.2,0),rnd(.02,.18),rnd(-.15,.05)]};
  crack(B);if(B.hits%2==1||B.hits>6)crack(B);chip(this,B);
  snd('paper',{rate:1.6+B.hits*.04,v:.4});this.breakCup(B,j,i*.08)}
 if(B.n<=0)this.shelfDown(B)};
var down0=G.shelfDown;G.shelfDown=function(B){if(window.OLD)return down0.call(this,B);var U=this.uu(),x=this.cx(B.c)+(B.w-1)*U/2,y=this.cy(B.r)+(B.h-1)*U/2,S=Math.max(B.w,B.h)*U;
 for(var r=B.r;r<B.r+B.h;r++)for(var c=B.c;c<B.c+B.w;c++){if(this.at2(r,c))this.b[r][c]=null}
 if(B.dmg)DEB.chunks(B.dmg,x-S/2,y-S/2,S,4,4,1.3,{g:1500});DEB.bits(x,y,22,['#FFFFFF','#CFE6FF','#8FBFF0'],6,1.4,{shape:'tri'});
 this.shake=Math.max(this.shake,10);this.flash=Math.max(this.flash,.35);this.burst(x,y,['#CFE6FF','#FFFFFF','#FFD24A'],30,320);snd('thud',{v:1});snd('blast',{v:.7})};
})();
