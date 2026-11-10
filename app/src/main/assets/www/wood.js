// Wooden obstacles (10 Nov 2026). Load after bigbreak.js.
// wall: one row-long crate wall. Gold diya frames at both ends, a wooden plank between.
//       3 hits break it; both diyas fly to the target and the row opens.
// wood: a 2x2 wooden crate block with 4 panels. Each hit knocks one panel out.
(function(){
var G=CrackersGame.prototype,prevDraw=G.drawOver,prevHit=G.hitBig;
var IM={};['plank','wood','woodi'].forEach(function(n){IM[n]=new Image();IM[n].src='art/'+n+'.webp'});
G.IC['big-wall']=IM.plank;G.IC['big-wood']=IM.wood;
var DY=new Image();DY.src='art/ui-diya.webp';
function rnd(a,b){return a+Math.random()*(b-a)}
function snd(n,o){if(window.SFX)SFX.play(n,o||{})}
function mine(B){return B&&(B.t=='wall'||B.t=='wood')}
function cracks(n){var L=[];for(var i=0;i<n;i++){var x=rnd(.08,.92),y=0,p=[[x,y]];while(y<1){y+=rnd(.18,.34);x+=rnd(-.05,.05);p.push([x,Math.min(y,1)])}L.push(p)}return L}
function bits(s,x,y,n,w){var D=window.DEB,I=IM.plank;if(!D||!I.naturalWidth)return;for(var i=0;i<n;i++){var sx=rnd(0,I.naturalWidth*.8),sy=rnd(0,I.naturalHeight*.5);D.part(I,sx,sy,I.naturalWidth*.12,I.naturalHeight*.35,x+rnd(-w/2,w/2),y,rnd(14,26),rnd(8,14),rnd(-260,260),rnd(-520,-300))}}
G.hitBig=function(B,blast){if(!mine(B))return prevHit.call(this,B,blast);
 if(B.n<=0||B.safe>this.clock)return;if(blast){if(B.bm===this.moves)return;B.bm=this.moves}var u=this.cx(1)-this.cx(0),x=this.cx(B.c)+(B.w-1)*u/2,y=this.cy(B.r)+(B.h-1)*u/2;
 B.safe=this.clock+(blast?.12:.25);B.n--;B.sq=1;var k=B.max-B.n;this.shake=Math.max(this.shake,2);this.addScore(60);
 if(B.t=='wood'){var ord=[0,3,1,2],pi=ord[(k-1)%4],px=this.cx(B.c+(pi&1)),py=this.cy(B.r+(pi>>1));bits(this,px,py,6,u*.6);this.count('wood',B.r+(pi>>1),B.c+(pi&1));snd(B.n>0?'paper':'thud',{rate:B.n>0?.8:.9,v:.85})}
 else{bits(this,x,y,5+k*2,u*(B.w-2));snd(B.n>0?'paper':'thud',{rate:.75,v:.9})}
 if(B.n<=0){var D=window.DEB,I=G.IC['big-'+B.t];for(var r=B.r;r<B.r+B.h;r++)for(var c=B.c;c<B.c+B.w;c++){if(this.at2(r,c))this.b[r][c]=null}
  if(D&&I&&I.naturalWidth){if(B.t=='wall'){var n6=B.w-2,iw=I.naturalWidth,ih=I.naturalHeight;for(var i=0;i<n6;i++)D.part(I,iw*i/n6,0,iw/n6,ih,this.cx(B.c+1+i),y,u,u*.85,(i-(n6-1)/2)*90+rnd(-40,40),rnd(-560,-380))}else D.chunks(I,x-u,y-u,2*u,3,3,1.1,{g:1400})}
  this.burst(x,y,['#FFD24A','#FFFFFF','#C27A3C'],22,300);this.shake=Math.max(this.shake,B.t=='wall'?6:4);snd('thud',{v:1});
  if(B.t=='wall'){this.ring(this.cx(B.c),y,'#FFC62B',u*1.3,6);this.ring(this.cx(B.c+B.w-1),y,'#FFC62B',u*1.3,6);this.count('diya',B.r,B.c);this.count('diya',B.r,B.c+B.w-1);if(window.SFX)SFX.tick()}}};
G.drawOver=function(c,e,x,y,s){var o=e.ob;if(!(o&&o.t=='big'&&mine(o.B)))return prevDraw.call(this,c,e,x,y,s);if(!o.anchor)return;
 var B=o.B,u=this.cx(1)-this.cx(0),W=B.w*u-(u-s),H=B.h*u-(u-s),k=1+B.sq*.05;B.sq=Math.max(0,B.sq-.07);c.save();c.translate(x+W/2,y+H/2);c.scale(k,2-k);c.translate(-W/2,-H/2);
 if(B.t=='wall'){
  [0,B.w-1].forEach(function(i){var fx=i*u+1,g=c.createRadialGradient(fx+s/2,H/2,2,fx+s/2,H/2,s*.7);g.addColorStop(0,'#FFF1C2');g.addColorStop(.65,'#F6C64A');g.addColorStop(1,'#C9861C');c.fillStyle=g;c.beginPath();c.roundRect(fx,1,s-2,H-2,11);c.fill();c.fillStyle='rgba(160,100,14,.9)';c.fillRect(fx+6,H-4,s-14,2);if(DY.naturalWidth)c.drawImage(DY,fx+s*.1,s*.08,s*.8,s*.8)});
  var I=IM.plank,pw=(B.w-2)*u-2,ph=H-4,px=u+1-(u-s)/2,fx2=pw/272,fy=ph/40;
  if(I.naturalWidth)c.drawImage(I,px-2*fx2,2-3*fy,276*fx2,46*fy);
  var st=B.max-B.n;if(st>0){if(!B.cr)B.cr=cracks(6);c.save();c.beginPath();c.roundRect(px,2,pw,ph,8);c.clip();c.strokeStyle='rgba(55,22,4,.9)';c.lineWidth=2.2;c.lineJoin='round';B.cr.slice(0,st*3).forEach(function(p){c.beginPath();p.forEach(function(q,j){var X=px+q[0]*pw,Y=2+q[1]*ph;j?c.lineTo(X,Y):c.moveTo(X,Y)});c.stroke()});if(st>1){c.fillStyle='rgba(40,15,0,.18)';c.fillRect(px,2,pw,ph)}c.restore()}
 }else{
  var J=IM.wood,f=W/88;if(J.naturalWidth)c.drawImage(J,-2*f,-4*f,92*f,95*f);
  var P=[[7,7],[47,7],[7,47],[47,47]],ord=[0,3,1,2],gone=B.max-B.n;
  for(var q=0;q<gone&&q<4;q++){var p=P[ord[q]],hx=p[0]*f,hy=p[1]*f,hs=34*f;c.fillStyle='#3E1C08';c.beginPath();c.roundRect(hx,hy,hs,hs,5);c.fill();var g2=c.createLinearGradient(0,hy,0,hy+hs);g2.addColorStop(0,'rgba(0,0,0,.55)');g2.addColorStop(.4,'rgba(0,0,0,0)');c.fillStyle=g2;c.fill();c.strokeStyle='rgba(255,210,150,.25)';c.lineWidth=1;c.beginPath();c.moveTo(hx+3,hy+hs-1);c.lineTo(hx+hs-3,hy+hs-1);c.stroke()}
 }
 c.restore()};
})();
