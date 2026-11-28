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
 else{bits(this,x,y,8+k*4,u*(B.w-2));this.ring(x,y,'#E2A066',u*1.4,5);snd(B.n>0?'paper':'thud',{rate:.75,v:.9})}
 if(B.n<=0){var D=window.DEB,I=G.IC['big-'+B.t];for(var r=B.r;r<B.r+B.h;r++)for(var c=B.c;c<B.c+B.w;c++){if(this.at2(r,c))this.b[r][c]=null}
  if(D&&I&&I.naturalWidth){if(B.t=='wall'){var n6=B.w-2,iw=I.naturalWidth,ih=I.naturalHeight;for(var i=0;i<n6;i++)D.part(I,iw*i/n6,0,iw/n6,ih,this.cx(B.c+1+i),y,u,u*.85,(i-(n6-1)/2)*90+rnd(-40,40),rnd(-560,-380))}else D.chunks(I,x-u,y-u,2*u,3,3,1.1,{g:1400})}
  this.burst(x,y,['#FFD24A','#FFFFFF','#C27A3C'],22,300);this.shake=Math.max(this.shake,B.t=='wall'?6:4);snd('thud',{v:1});
  if(B.t=='wall'){this.ring(this.cx(B.c),y,'#FFC62B',u*1.3,6);this.ring(this.cx(B.c+B.w-1),y,'#FFC62B',u*1.3,6);this.count('diya',B.r,B.c);this.count('diya',B.r,B.c+B.w-1);if(window.SFX)SFX.tick()}}};
G.drawOver=function(c,e,x,y,s){var o=e.ob;if(!(o&&o.t=='big'&&mine(o.B)))return prevDraw.call(this,c,e,x,y,s);if(!o.anchor)return;
 var B=o.B,u=this.cx(1)-this.cx(0),W=B.w*u-(u-s),H=B.h*u-(u-s),k=1+B.sq*.05;B.sq=Math.max(0,B.sq-.07);c.save();c.translate(x+W/2,y+H/2);c.scale(k,2-k);c.translate(-W/2,-H/2);
 if(B.t=='wall'){
  [0,B.w-1].forEach(function(i){var fx=i*u+1,g=c.createRadialGradient(fx+s/2,H/2,2,fx+s/2,H/2,s*.7);g.addColorStop(0,'#FFF1C2');g.addColorStop(.65,'#F6C64A');g.addColorStop(1,'#C9861C');c.fillStyle=g;c.beginPath();c.roundRect(fx,1,s-2,H-2,11);c.fill();c.fillStyle='rgba(160,100,14,.9)';c.fillRect(fx+6,H-4,s-14,2);if(DY.naturalWidth)c.drawImage(DY,fx+s*.1,s*.08,s*.8,s*.8)});
  var I=IM.plank,pw=(B.w-2)*u-2,ph=H-4,px=u+1-(u-s)/2,fx2=pw/272,fy=ph/40,st=B.max-B.n;
  if(!B.ch){B.ch=[];for(var q=0;q<7;q++)B.ch.push({x:rnd(.06,.94),top:Math.random()<.5,w:rnd(.04,.08),d:rnd(.25,.45)})}
  function plank(x0,w0){c.save();c.beginPath();c.rect(x0,0,w0,H);c.clip();if(I.naturalWidth)c.drawImage(I,px-2*fx2,2-3*fy,276*fx2,46*fy);c.restore()}
  c.save();c.fillStyle='rgba(30,10,0,.35)';c.beginPath();c.roundRect(px+3,6,pw,ph,8);c.fill();c.restore();
  if(st<2){plank(px-4,pw+8)}else{var mid=px+pw*.5;c.save();c.translate(px,H/2);c.rotate(.07);c.translate(-px,-H/2);plank(px-4,mid-px-3);c.restore();c.save();c.translate(px+pw,H/2);c.rotate(-.07);c.translate(-px-pw,-H/2);plank(mid+3,px+pw-mid+4);c.restore();
   c.fillStyle='#2A1004';c.beginPath();c.moveTo(mid-5,2);c.lineTo(mid+5,2);c.lineTo(mid+2,H*.5);c.lineTo(mid+6,H-2);c.lineTo(mid-6,H-2);c.lineTo(mid-2,H*.5);c.closePath();c.fill();
   c.strokeStyle='#E2A066';c.lineWidth=2;[[-6,8],[-4,H*.4],[5,H*.6],[6,H-8]].forEach(function(v){c.beginPath();c.moveTo(mid+v[0]*.5,v[1]);c.lineTo(mid+v[0]*1.8,v[1]+3);c.stroke()})}
  if(st>0){var n=st==1?4:7;for(var q=0;q<n;q++){var h=B.ch[q],cx0=px+h.x*pw,w=pw*h.w,d=ph*h.d,yy=h.top?2:2+ph;c.fillStyle='#3E1C08';c.beginPath();c.moveTo(cx0-w,yy);c.lineTo(cx0-w*.3,yy+(h.top?d:-d));c.lineTo(cx0+w*.5,yy+(h.top?d*.7:-d*.7));c.lineTo(cx0+w,yy);c.closePath();c.fill();
    c.strokeStyle='rgba(226,160,102,.85)';c.lineWidth=1.5;c.beginPath();c.moveTo(cx0-w*.3,yy+(h.top?d:-d));c.lineTo(cx0+w*.5,yy+(h.top?d*.7:-d*.7));c.stroke()}
   c.fillStyle='rgba(40,15,0,.22)';c.beginPath();c.ellipse(px+pw*.3,H/2,pw*.07,ph*.2,0,0,7);c.ellipse(px+pw*.72,H/2+2,pw*.06,ph*.18,0,0,7);c.fill()}
 }else{
  var J=IM.wood,f=W/88;if(J.naturalWidth)c.drawImage(J,-2*f,-4*f,92*f,95*f);
  var P=[[7,7],[47,7],[7,47],[47,47]],ord=[0,3,1,2],gone=B.max-B.n;
  for(var q=0;q<gone&&q<4;q++){var p=P[ord[q]],hx=p[0]*f,hy=p[1]*f,hs=34*f;c.fillStyle='#3E1C08';c.beginPath();c.roundRect(hx,hy,hs,hs,5);c.fill();var g2=c.createLinearGradient(0,hy,0,hy+hs);g2.addColorStop(0,'rgba(0,0,0,.55)');g2.addColorStop(.4,'rgba(0,0,0,0)');c.fillStyle=g2;c.fill();c.strokeStyle='rgba(255,210,150,.25)';c.lineWidth=1;c.beginPath();c.moveTo(hx+3,hy+hs-1);c.lineTo(hx+hs-3,hy+hs-1);c.stroke()}
 }
 c.restore()};
})();
