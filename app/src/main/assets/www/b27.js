// Build 27 (11 Nov 2026). Load after fx26.js.
// - normal match = "Small pieces": 2 small cracker pieces that drop a short way and fade, 3 specks, soft flash
//   (old style kept: window.FXSTYLE='old'; subtle: window.FXSTYLE='subtle')
// - golden chain look
// - gift box: crackers land on safe tiles and wait for the next swipe; the box shows its stage from goal progress
//   and bursts into paper when its goal is complete
// - help find the last goals: after 3 moves with no progress, the last items glow
(function(){
var G=CrackersGame.prototype,P=window.CrackersFX2.prototype,D=window.DEB;
function rnd(a,b){return a+Math.random()*(b-a)}
function snd(n,o){if(window.SFX)SFX.play(n,o||{})}
var COLS={0:'#E8343B',1:'#2F6FE0',2:'#3DBB4A',3:'#FFD24A',4:'#8B5CF6',5:'#FF8A1A'};

// ---------- small pieces on the debris layer (fade out, do not fall off the screen)
var SM=[];
if(D){var st0=D.step;D.step=function(dt){st0.call(this,dt);var x=this.x;if(!x)return;
 SM=SM.filter(function(p){p.age+=dt;if(p.age>=p.life)return false;p.vy+=p.g*dt;p.x+=p.vx*dt;p.y+=p.vy*dt;p.rot+=p.vr*dt;var f=p.age/p.life;
  x.save();x.globalAlpha=1-f*f;x.translate(p.x,p.y);x.rotate(p.rot);x.beginPath();p.poly.forEach(function(q,i){i?x.lineTo(q[0]*p.S,q[1]*p.S):x.moveTo(q[0]*p.S,q[1]*p.S)});x.closePath();x.clip();
  x.drawImage(p.img,p.sx,p.sy,p.sw,p.sh,-p.S/2,-p.S/2,p.S,p.S);x.restore();return true})};
 D.small=function(img,cx,cy,S){if(!img||!img.naturalWidth)return;var iw=img.naturalWidth,ih=img.naturalHeight;
  [[-1,0],[1,.5]].forEach(function(d,i){var poly=[[-.5,-.45],[.45,-.3],[.4,.5],[-.45,.38]].map(function(q){return[q[0]+rnd(-.06,.06),q[1]+rnd(-.06,.06)]});
   SM.push({img:img,sx:iw*d[1],sy:ih*.1,sw:iw*.5,sh:ih*.8,S:S*.5,poly:poly,x:cx+d[0]*S*.16,y:cy+D.oy,vx:d[0]*rnd(60,110),vy:-rnd(110,160),g:900,rot:0,vr:d[0]*rnd(4,8),age:0,life:.5})})}}
var smash0=P.smash;
P.smash=function(r,c,o){o=o||{};var e=this.b[r][c];if(!e)return;var lite=this.isGame&&!(o.pw>1)&&!o.d2,st=window.FXSTYLE||'small';
 if(!lite||st=='old'||!D)return smash0.call(this,r,c,o);
 var x=this.cx(c),y=this.cy(r),u=this.uu(),col=COLS[e.k]||'#FFB800';
 this.pop(x,y,col,st=='subtle'?.25:.35);
 if(st=='small'&&this.T[e.k])D.small(this.T[e.k],x,y,u);
 this.spark(x,y,st=='subtle'?5:3,[col,'#FFFFFF'],st=='subtle'?160:190);
 this.b[r][c]=null};

// ---------- specials drawn like normal tiles: bare art, no tile frame
var BARE={};P.bare=function(k){var i=BARE[k];if(!i){if(!window.CRK||!CRK.b||!CRK.b[k])return null;i=BARE[k]=new Image();i.src=CRK.b[k]}return i.naturalWidth?i:null};

// ---------- golden chain: one chunky chain running corner to corner across the tile
function link(c,x,y,w,h,ang,face){c.save();c.translate(x,y);c.rotate(ang);
 var g=c.createLinearGradient(-w/2,-h/2,w/2,h/2);g.addColorStop(0,'#FFF2A8');g.addColorStop(.35,'#F5C23C');g.addColorStop(.7,'#C7801A');g.addColorStop(1,'#8A4E08');
 c.lineWidth=face?h*.34:h*.5;c.strokeStyle='#5A3204';c.beginPath();c.ellipse(0,0,w/2,face?h/2:h*.22,0,0,7);c.stroke();
 c.lineWidth=face?h*.24:h*.36;c.strokeStyle=g;c.beginPath();c.ellipse(0,0,w/2,face?h/2:h*.22,0,0,7);c.stroke();
 c.lineWidth=face?h*.07:h*.1;c.strokeStyle='rgba(255,252,220,.85)';c.beginPath();c.ellipse(0,face?-h*.06:-h*.02,w/2*.86,face?h/2*.8:h*.16,0,3.5,5.9);c.stroke();c.restore()}
function chainSprite(){var S=128,cv=document.createElement('canvas');cv.width=cv.height=S;var c=cv.getContext('2d'),n=5,ang=Math.PI/4;
 c.shadowColor='rgba(40,10,0,.45)';c.shadowBlur=6;c.shadowOffsetY=3;
 for(var i=0;i<n;i++){var f=(i+.5)/n,x=S*.06+f*S*.88,y=S*.06+f*S*.88;link(c,x,y,S*.3,S*.2,ang,i%2==0)}
 cv.naturalWidth=cv.naturalHeight=S;return cv}
try{var CH=chainSprite();G.IC.chain=CH;window.CHAIN_ICON=CH.toDataURL()}catch(e){}

// ---------- gift box
var GB=new Image();GB.src='art/giftbox.webp';
// would putting colour k at (r,c) make a row or column of 3?
G.makes3=function(r,c,k){var s=this;function K(a,b){return(a==r&&b==c)?k:s.rawK(a,b)}
 for(var i=-2;i<=0;i++){if(K(r,c+i)==k&&K(r,c+i+1)==k&&K(r,c+i+2)==k)return true;if(K(r+i,c)==k&&K(r+i+1,c)==k&&K(r+i+2,c)==k)return true}return false};
G.openBox=function(r,c){var s=this,u=this.uu(),k=this.goalCol(),x0=this.cx(c),y0=this.cy(r),R=this.rows(),C=this.cols();
 if(this.lv.boxK!=null&&this.goal[this.lv.boxK]!=null&&this.goal[this.lv.boxK]<=0)return;
 var e0=this.at2(r,c);if(e0&&e0.ob){e0.ob.sq=1;e0.ob.op=1}
 snd('swoosh',{v:.5,rate:1.3});snd('paper',{v:.6,rate:.8});
 var L=[];for(var a=0;a<R;a++)for(var b=0;b<C;b++){var e=this.at2(a,b);if(e&&!e.dead&&!e.ob&&!e.diya&&e.k>=0&&e.k<6&&e.k!==k&&this.rest(e))L.push([a,b])}
 L.sort(function(p,q){return (Math.abs(p[0]-r)+Math.abs(p[1]-c))-(Math.abs(q[0]-r)+Math.abs(q[1]-c))+Math.random()*.8});
 // pick up to 8 cells, never forming a row of 3 with the goal colour
 var pick=[],kk={};L.forEach(function(p){if(pick.length>=8)return;var e=s.at2(p[0],p[1]),old=e.k;if(s.makes3(p[0],p[1],k))return;e.k=k;pick.push(p);kk[p]=old});
 pick.forEach(function(p){var e=s.at2(p[0],p[1]);e.k=kk[p]});
 this.ring(x0,y0,'#FFD24A',u*2,8);this.spark2(x0,y0,18,['#FFD24A','#FF5AA0','#FFFFFF'],260);
 pick.forEach(function(p,i){var e=s.at2(p[0],p[1]),x1=s.cx(p[1]),y1=s.cy(p[0]),hx=(x0+x1)/2,hy=Math.min(y0,y1)-u*1.8,d=.12+i*.12,F=.5;
  e.swp=true;e.hold=1;e.safe=s.clock+d+F+.3;
  s.at(d,function(){snd('swoosh',{v:.3,rate:1.6+i*.04})});
  s.obj(function(cx,t){var f=Math.min((t-d)/F,1);if(f<0)return true;var g=f<.5?2*f*f:1-2*(1-f)*(1-f),ix=(1-g)*(1-g)*x0+2*(1-g)*g*hx+g*g*x1,iy=(1-g)*(1-g)*y0+2*(1-g)*g*hy+g*g*y1;
   s.fx.push({k:'spark',x:ix,y:iy,z:0,vx:rnd(-30,30),vy:rnd(-10,40),vz:0,col:i%2?'#FFD24A':'#FFFFFF',a:0,l:.35});s.spr(k,ix,iy,u*.85,0);
   if(f>=1){e.k=k;e.swp=false;e.hold=1;s.ring(x1,y1,'#FFE58A',u*1,5);s.spark2(x1,y1,8,['#FFFFFF','#FFD24A'],140);snd('tick',{v:.4,rate:1.3+i*.05});
    s.obj(function(c2,t2){var q=t2/.28;c2.fillStyle='rgba(255,255,255,'+(.8*(1-q))+')';c2.beginPath();c2.roundRect(x1-u/2+3,y1-u/2+3,u-6,u-6,10);c2.fill();return q<1},.3);return false}return true},d+F+.05)})};
// the box's look follows the goal: ribbon tied, ribbon loose, lid up, shaking
var gift0=G.drawGift;
G.drawGift=function(c,e,x,y,s){var o=e.ob,k=this.lv&&this.lv.boxK;if(o&&k!=null&&this.lv.goal[k]&&this.goal){var f=1-Math.max(0,this.goal[k])/this.lv.goal[k];o.hits=Math.min(3,Math.floor(f*3.4))}return gift0.call(this,c,e,x,y,s)};
G.burstBox=function(r,c){var e=this.b[r][c],u=this.uu(),x=this.cx(c),y=this.cy(r);if(!e)return;this.b[r][c]=null;
 snd('paper',{v:.8,rate:.9});snd('lakshmi',{v:.5,rate:1.2,cut:.4});this.ring(x,y,'#FFD24A',u*1.4,6);this.spark2(x,y,16,['#FFD24A','#FF5AA0','#FFFFFF'],240);
 if(D){if(D.sherds)D.sherds(GB,x,y,u,{n:8,ri:0,pw:1.1,line:'rgba(120,20,30,.45)'});D.bits(x,y,18,['#E8273F','#FFD24A','#2F6FE0','#3DBB4A','#FF5AA0'],7,1.1,{drag:1.2})}};
G.boxCheck=function(){if(this.boxDone||!this.lv)return;var k=this.lv.boxK;if(k==null||this.goal[k]==null||this.goal[k]>0)return;this.boxDone=1;
 var s=this,R=this.rows(),C=this.cols(),L=[];for(var r=0;r<R;r++)for(var c=0;c<C;c++){var e=this.b[r][c];if(e&&e.ob&&e.ob.t=='gbox')L.push([r,c])}
 L.forEach(function(p,i){s.at(.15+i*.18,function(){s.burstBox(p[0],p[1])})})};

// ---------- help find the last goals: after 3 moves with no progress, the remaining items glow
var spend0=G.spend;G.spend=function(){spend0.call(this);this.idleMv=(this.idleMv||0)+1};
function isGoalCell(s,e,r,c,k){if(/^\d+$/.test(k))return e&&!e.ob&&!e.dead&&e.k===+k;if(k=='gold'){var f=s.fl&&s.fl[r+','+c];return f&&f.t=='gold'}
 if(!e||!e.ob)return false;if(e.ob.t==k)return true;return e.ob.t=='big'&&e.ob.anchor&&e.ob.B&&e.ob.B.t==k}
G.helpCheck=function(){var left=this.left();if(this.lastLeft==null||left<this.lastLeft)this.idleMv=0;this.lastLeft=left;
 if(!(this.idleMv>=3)||this.over||this.ended)return;var s=this,u=this.uu(),R=this.rows(),C=this.cols(),c2=this.x,pu=.5+.5*Math.sin(this.clock*5);if(!c2)return;
 Object.keys(this.goal).forEach(function(k){var n=s.goal[k];if(!(n>0&&n<=3))return;
  for(var r=0;r<R;r++)for(var c=0;c<C;c++){var e=s.b[r][c];if(!isGoalCell(s,e,r,c,k))continue;var big=e&&e.ob&&e.ob.t=='big',x=s.cx(c)+(big?u:0),y=s.cy(r)+(big?u:0),rr=u*(big?1.6:.56);
   c2.save();c2.globalAlpha=.35+.45*pu;c2.strokeStyle='#FFF2A8';c2.lineWidth=3+2*pu;c2.shadowColor='#FFD24A';c2.shadowBlur=14;c2.beginPath();c2.arc(x,y,rr*(1+.06*pu),0,7);c2.stroke();c2.restore()}})};

var tick1=G.tick;G.tick=function(n){tick1.call(this,n);if(this.b&&!this.stopped&&!this.lv.bonus){this.boxCheck();this.helpCheck()}};
})();
