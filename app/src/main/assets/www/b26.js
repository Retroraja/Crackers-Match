// Build 26 fixes (11 Nov 2026). Load after flow.js.
// - Lakshmi Vedi Hammer: real bang, clears a plus (tile + 4 around it), works on obstacles
// - clay pots crack, then break into curved clay pieces with a dust puff
// - ice cracks on the first hit, then shatters into glass-like shards
// - glass racks: each hit breaks one item into pieces that fall off the screen; the rack cracks more each time
// - gift box: ribbon loosens, lid lifts, box shakes; 6 crackers fly out one by one, each target flashes
(function(){
var G=CrackersGame.prototype,D=window.DEB;
function rnd(a,b){return a+Math.random()*(b-a)}
function snd(n,o){if(window.SFX)SFX.play(n,o||{})}
function img(n){var i=new Image();i.src='art/'+n+'.webp';return i}

// ---------- curved clay pieces and glass shards on the debris layer
var SH=[];
if(D){var step0=D.step;D.step=function(dt){step0.call(this,dt);var x=this.x;if(!x)return;
 SH=SH.filter(function(p){p.age+=dt;p.vy+=p.g*dt;p.x+=p.vx*dt;p.y+=p.vy*dt;p.rot+=p.vr*dt;if(p.y>920||p.age>3)return false;
  x.save();x.translate(p.x,p.y);x.rotate(p.rot);x.translate(-p.ox,-p.oy);x.beginPath();
  if(p.ri>0){x.arc(0,0,p.ro,p.a0,p.a1);x.arc(0,0,p.ri,p.a1,p.a0,true)}else{x.moveTo(0,0);p.edge.forEach(function(q){x.lineTo(q[0],q[1])})}
  x.closePath();x.save();x.clip();if(p.img&&p.img.naturalWidth)x.drawImage(p.img,-p.S/2,-p.S/2,p.S,p.S);x.restore();
  x.strokeStyle=p.line;x.lineWidth=1.2;x.stroke();x.restore();return true})};
 // n pieces cut from the image around its centre: ri>0 gives curved bands (clay), ri=0 gives sharp wedges (glass)
 D.sherds=function(im,cx,cy,S,o){o=o||{};var n=o.n||7,ri=(o.ri||0)*S,ro=S*.52,pw=o.pw||1,a=rnd(0,6.28);
  for(var i=0;i<n;i++){var a0=a+i/n*6.283,a1=a+(i+1)/n*6.283+.02,am=(a0+a1)/2,rm=ri>0?(ri+ro)/2:ro*.5,edge=[];
   if(!(ri>0)){for(var k=0;k<=4;k++){var aa=a0+(a1-a0)*k/4,rr=ro*(k%2?rnd(.75,.95):1);edge.push([Math.cos(aa)*rr,Math.sin(aa)*rr])}}
   SH.push({img:im,S:S,ri:ri,ro:ro,a0:a0,a1:a1,edge:edge,ox:Math.cos(am)*rm,oy:Math.sin(am)*rm,x:cx+Math.cos(am)*rm,y:cy+this.oy+Math.sin(am)*rm,
    vx:Math.cos(am)*rnd(150,300)*pw+rnd(-40,40),vy:-rnd(240,420)*pw+Math.sin(am)*110,rot:0,vr:rnd(-9,9),g:o.g||1500,age:0,line:o.line||'rgba(80,30,10,.55)'})}}}

// ---------- pots and ice
var I=G.IC,hit0=G.hitOb;
G.hitOb=function(e,p,blast){var o=e&&e.ob,t=o&&o.t;if(!D||(t!='pot'&&t!='dpot'&&t!='ice'))return hit0.call(this,e,p,blast);
 var hp0=o.hp,ch=D.chunks;D.chunks=function(){};try{hit0.call(this,e,p,blast)}finally{D.chunks=ch}
 if(e.ob===o&&o.hp===hp0)return;var dead=e.ob!==o,x=this.cx(p[1]),y=this.cy(p[0]),u=this.uu(),S=u-4,s=this;
 if(!dead)return;
 if(t=='ice'){D.sherds(I.ice,x,y,S,{n:9,ri:0,pw:1.1,g:1700,line:'rgba(255,255,255,.85)'});this.spark(x,y,12,['#FFFFFF','#CDEFFF','#9FDDF7'],220);snd('tick',{v:.5,rate:1.7});return}
 var im=t=='pot'?I.pot:I.claypot;
 // a quick crack, then the pot breaks into curved pieces with a dust puff
 var cr=[];for(var k=0;k<5;k++){var a=k*1.26+rnd(0,.5),L=[[0,0]],rr=0,aa=a;while(rr<.48){rr+=rnd(.08,.14);aa+=rnd(-.5,.5);L.push([Math.cos(aa)*rr,Math.sin(aa)*rr])}cr.push(L)}
 this.obj(function(c,tt){if(im&&im.naturalWidth){var h=S,w=h*im.naturalWidth/im.naturalHeight;c.drawImage(im,x-w/2,y-h/2,w,h)}c.strokeStyle='rgba(60,20,5,.9)';c.lineWidth=1.8;cr.forEach(function(L){c.beginPath();L.forEach(function(q,i){var X=x+q[0]*S,Y=y+q[1]*S;i?c.lineTo(X,Y):c.moveTo(X,Y)});c.stroke()});return tt<.1},.12);
 this.at(.1,function(){D.sherds(im,x,y,S,{n:7,ri:.2,pw:blast?1.25:1});for(var i=0;i<7;i++)s.puff(x+rnd(-u*.35,u*.35),y+rnd(-u*.2,u*.3),i%2?'rgba(205,170,130,.75)':'rgba(170,130,95,.65)',rnd(9,16))})};

// ---------- glass racks: item pieces fall off the screen, the rack cracks more with every hit
var IT={rackc:[0,1,2,3,4,5,6,7,8].map(function(i){return img('cup'+i)}),racks:[0,1,2,0,1,2,0,1,2].map(function(i){return img('sweet'+i)}),rackg:[0,1,2,3,0,1,2,3,0].map(function(i){return img('giftc'+i)})};
var SLOT=[[27,52],[89,52],[150,52],[27,108],[88,108],[150,108],[27,164],[88,164],[150,164]];
function isRack(B){return B&&IT[B.t]}
function rackCrack(B){var e=[[12,30],[222,40],[10,120],[224,130],[30,226],[200,224],[117,6],[60,10],[176,12],[8,200],[226,190]][(B.crk.length)%11],px=e[0],py=e[1],a=Math.atan2(118-py,117-px)+rnd(-.5,.5),L=[[px,py]];
 for(var i=0;i<6;i++){a+=rnd(-.5,.5);px+=Math.cos(a)*rnd(7,12);py+=Math.sin(a)*rnd(7,12);L.push([px,py])}var br=L[3],b2=[br,[br[0]+Math.cos(a+1.2)*14,br[1]+Math.sin(a+1.2)*14]];B.crk.push(L);B.crk.push(b2)}
var big0=G.hitBig;
G.hitBig=function(B,blast){if(!isRack(B))return big0.call(this,B,blast);var n0=B.n,i=B.max-B.n;big0.call(this,B,blast);if(B.n>=n0)return;
 B.crk=B.crk||[];rackCrack(B);if(B.max-B.n>4)rackCrack(B);
 var u=this.uu(),p=SLOT[i],x=this.cx(B.c)+(p[0]+30)/234*3*u-u/2,y=this.cy(B.r)+(p[1]+22)/233*3*u-u/2,im=IT[B.t][i],S=u*.82;
 if(D&&im&&im.naturalWidth){D.chunks(im,x-S/2,y-S/2,S,2,2,.9,{g:1500});D.bits(x,y,8,['#FFFFFF','#CDEFFF','#FFE7A8'],5,1,{shape:'tri'})}
 if(B.n<=0&&D){var cx=this.cx(B.c+1),cy=this.cy(B.r+1);D.sherds(G.IC['shelf-glass']||img('shelf-glass'),cx,cy,3*u,{n:10,ri:0,pw:1.2,line:'rgba(255,255,255,.8)'});D.bits(cx,cy,18,['#FFFFFF','#CDEFFF','#9FDDF7'],7,1.3,{shape:'tri'})}};
var draw0=G.drawOver;
G.drawOver=function(c,e,x,y,s){var o=e.ob;
 if(o&&o.t=='gbox')return this.drawGift(c,e,x,y,s);
 draw0.call(this,c,e,x,y,s);
 if(o&&o.t=='big'&&o.anchor&&isRack(o.B)&&o.B.crk&&o.B.crk.length){var B=o.B,u=this.uu(),W=3*u-(u-s),f=W/234;c.save();c.translate(x,y);c.lineJoin='round';c.lineCap='round';
  [[2.6,'rgba(255,255,255,.75)',.8],[1.3,'rgba(20,50,110,.85)',0]].forEach(function(w){c.strokeStyle=w[1];c.lineWidth=w[0];B.crk.forEach(function(L){c.beginPath();L.forEach(function(q,i){var X=(q[0]+w[2])*f,Y=(q[1]+w[2])*f;i?c.lineTo(X,Y):c.moveTo(X,Y)});c.stroke()})});c.restore()}};

// ---------- gift box: changes as it is hit
var GB=img('giftbox');
G.drawGift=function(c,e,x,y,s){var o=e.ob,cl=this.clock||0,st=Math.min(o.hits||0,3),im=GB;if(o.sq)o.sq=Math.max(0,o.sq-.07);var open=o.op>0?o.op:0;if(o.op>0)o.op=Math.max(0,o.op-.03);
 c.save();c.translate(x+s/2,y+s/2);var k2=1+(o.sq||0)*.16;c.scale(k2,2-k2);
 var shake=open*.08*Math.sin(cl*40)+(st>=3?.035*Math.sin(cl*22):0);c.rotate(shake);
 var gl=.5+.5*Math.sin(cl*3+x);c.fillStyle='rgba(255,214,90,'+(.18+.14*gl+st*.05)+')';c.beginPath();c.arc(0,0,s*.55,0,7);c.fill();
 if(im.naturalWidth){var r=im.naturalWidth/im.naturalHeight,h=s*1.02,w=h*r;if(w>s*1.04){w=s*1.04;h=w/r}var iw=im.naturalWidth,ih=im.naturalHeight,cut=.4;
  // body
  c.drawImage(im,0,ih*cut,iw,ih*(1-cut),-w/2,-h/2+h*cut,w,h*(1-cut));
  // light escaping once the lid lifts
  if(st>=2){var lg=c.createRadialGradient(0,-h/2+h*cut,1,0,-h/2+h*cut,w*.5);lg.addColorStop(0,'rgba(255,240,170,'+(.75+.25*Math.sin(cl*6))+')');lg.addColorStop(1,'rgba(255,200,80,0)');c.fillStyle=lg;c.fillRect(-w/2,-h/2+h*cut-w*.4,w,w*.6)}
  // lid: lifts and tilts more with each stage
  var lift=(st>=2?h*.12:0)+(st>=3?h*.05:0)+open*h*.1,tilt=st>=2?-.12-(st>=3?.08:0):0;c.save();c.translate(0,-h/2+h*cut-lift);c.rotate(tilt);c.drawImage(im,0,0,iw,ih*cut,-w/2,-h*cut,w,h*cut);c.restore();
  // loose ribbon tails
  if(st>=1){c.strokeStyle='#E8273F';c.lineWidth=Math.max(2,s*.06);c.lineCap='round';var sw=Math.sin(cl*3)*s*.04;c.beginPath();c.moveTo(w*.05,-h/2+h*cut-lift);c.quadraticCurveTo(w*.42,-h*.05,w*.36+sw,h*.28);c.stroke();
   c.beginPath();c.moveTo(-w*.05,-h/2+h*cut-lift);c.quadraticCurveTo(-w*.4,0,-w*.3-sw,h*.32);c.stroke()}}
 c.restore()};
var open0=G.openBox;
G.openBox=function(r,c){var s=this,u=this.uu(),k=this.goalCol(),x0=this.cx(c),y0=this.cy(r),R=this.rows(),C=this.cols(),e0=this.at2(r,c);if(e0&&e0.ob)e0.ob.hits=(e0.ob.hits||0)+1;
 snd('swoosh',{v:.5,rate:1.3});snd('paper',{v:.6,rate:.8});
 var L=[];for(var a=0;a<R;a++)for(var b=0;b<C;b++){var e=this.at2(a,b);if(e&&!e.dead&&!e.ob&&!e.diya&&e.k>=0&&e.k<6&&e.k!==k&&this.rest(e))L.push([a,b])}
 L.sort(function(p,q){return (Math.abs(p[0]-r)+Math.abs(p[1]-c))-(Math.abs(q[0]-r)+Math.abs(q[1]-c))+Math.random()*.8});
 this.ring(x0,y0,'#FFD24A',u*2,8);this.spark2(x0,y0,18,['#FFD24A','#FF5AA0','#FFFFFF'],260);
 L.slice(0,6).forEach(function(p,i){var e=s.at2(p[0],p[1]),x1=s.cx(p[1]),y1=s.cy(p[0]),hx=(x0+x1)/2,hy=Math.min(y0,y1)-u*1.8,d=.15+i*.17,F=.5;
  e.swp=true;e.safe=s.clock+d+F+.3;
  s.at(d,function(){snd('swoosh',{v:.3,rate:1.6+i*.05})});
  s.obj(function(cx,t){var f=Math.min((t-d)/F,1);if(f<0)return true;var g=f<.5?2*f*f:1-2*(1-f)*(1-f),ix=(1-g)*(1-g)*x0+2*(1-g)*g*hx+g*g*x1,iy=(1-g)*(1-g)*y0+2*(1-g)*g*hy+g*g*y1;
   s.fx.push({k:'spark',x:ix,y:iy,z:0,vx:rnd(-30,30),vy:rnd(-10,40),vz:0,col:i%2?'#FFD24A':'#FFFFFF',a:0,l:.35});s.spr(k,ix,iy,u*.85,0);
   if(f>=1){e.k=k;e.swp=false;s.ring(x1,y1,'#FFE58A',u*1,5);s.spark2(x1,y1,8,['#FFFFFF','#FFD24A'],140);snd('tick',{v:.4,rate:1.3+i*.06});
    s.obj(function(c2,t2){var q=t2/.28;c2.fillStyle='rgba(255,255,255,'+(.8*(1-q))+')';c2.beginPath();c2.roundRect(x1-u/2+3,y1-u/2+3,u-6,u-6,10);c2.fill();return q<1},.3);return false}return true},d+F+.05)})};

// ---------- Lakshmi Vedi Hammer: drops on any tile, even an obstacle, and clears a plus
var place0=G.place;
G.place=function(k,r,c){if(k!='hammer')return place0.call(this,k,r,c);var e=this.at2(r,c);if(!e||e.diya||this.busy||this.over||this.moves<=0)return false;this.spend();this.hammer2(r,c);return true};
G.hammer2=function(r,c){var s=this,u=this.uu(),x=this.cx(c),y=this.cy(r);snd('swoosh',{v:.5,rate:1.3});var e=this.at2(r,c);if(e)e.firing=true;
 this.obj(function(cx,t){var f=Math.min(t/.24,1);s.spr(17,x,y-(1-f*f)*u*3.2,u*1.25,(1-f)*-.7);if(f>=1){if(e)e.firing=false;
   snd('thud',{v:1,rate:.6});snd('lakshmi',{v:1,rate:.88,at:.02});snd('atom',{v:.45,rate:1.3,cut:.35});
   s.pop(x,y,'#FFD24A',1.4);s.ring(x,y,'#FFFFFF',u*1.8,8);s.ring(x,y,'#FFD24A',u*2.4,6);s.flash=Math.max(s.flash,.3);s.shake=Math.max(s.shake,6);s.wave(x,y,16,480);
   [[0,0],[1,0],[-1,0],[0,1],[0,-1]].forEach(function(d,i){var rr=r+d[0],cc=c+d[1];if(!s.at2(rr,cc))return;s.hit(rr,cc,{d:i?.05:0,pw:1.3})});return false}return true},.3)};
// ---------- teaching pattern: on mass-obstacle levels it sits in the free top rows
var stamp0=G.stamp;
G.stamp=function(){var t=this.lv.teach;if(!t||!this.lv.mass)return stamp0.call(this);var chk=this,a=this.lv.colors[0],b=this.lv.colors[1],dr=-2;
 var M={rocket:{put:[[2,1],[2,2],[2,4],[3,3]],not:[2,3],mv:[3,3,-1,0]},square:{put:[[2,1],[2,2],[3,1],[3,3]],not:[3,2],mv:[3,3,0,-1]},lshape:{put:[[2,1],[2,3],[2,4],[3,2],[4,2]],not:[2,2],mv:[2,1,0,1]}}[t];if(!M)return;
 var sh=function(p){return[p[0]+dr,p[1]]},put=M.put.map(sh),not=sh(M.not),keep={},s=this;
 if(put.concat([not]).some(function(p){var e=chk.at2(p[0],p[1]);return !e||e.ob||e.k>=6}))return;
 put.forEach(function(p){s.b[p[0]][p[1]].k=a;keep[p]=1});s.b[not[0]][not[1]].k=b;keep[not]=1;var g=0,f;while((f=this.find()).length&&g++<300)f.forEach(function(q){q.cells.forEach(function(p){if(!keep[p])s.b[p[0]][p[1]].k=s.rk()})});this.teach=[M.mv[0]+dr,M.mv[1],M.mv[2],M.mv[3]]};
})();