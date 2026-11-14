// Build 28 (14 Nov 2026). Load after sound.js and cabinet.js, before app.js.
// Board rules for the 10 Area 1 levels, the "smooth and generous" feel, new sounds and 3D obstacle breaks.
(function(){
var G=CrackersGame.prototype,P=window.CrackersFX2.prototype;
function rnd(a,b){return a+Math.random()*(b-a)}
window.SPGLOW=true;          // item 2: original special art with the yellow frame and pulse
G.helpCheck=function(){};     // item 11: no round hint circles

// ================= sounds (own audio context, so filters and noise are possible) =================
var A=window.A28=(function(){var X=null,N=null,buf={},ready=false,bed=null;
 function on(){try{return localStorage.getItem('cm_sound')!=='0'&&localStorage.getItem('cm_fx')!=='0'}catch(e){return true}}
 function b2a(b){var s=atob(b),u=new Uint8Array(s.length);for(var i=0;i<s.length;i++)u[i]=s.charCodeAt(i);return u.buffer}
 function ctx(){if(!X){var C=window.AudioContext||window.webkitAudioContext;if(!C)return null;X=new C();var b=X.createBuffer(1,X.sampleRate,X.sampleRate),d=b.getChannelData(0);for(var i=0;i<d.length;i++)d[i]=Math.random()*2-1;N=b;
   ['cap','sparkler','wala','pop','thud','swoosh','paper','lakshmi','win','fanfare'].forEach(function(k){if(!window.SND||!SND[k])return;try{X.decodeAudioData(b2a(SND[k]),function(d){buf[k]=d})}catch(e){}})}
  if(X.state=='suspended')X.resume();return X}
 function out(){return X.destination}
 function S(n,o){o=o||{};if(!on()||!ctx()||!buf[n])return null;var s=X.createBufferSource(),g=X.createGain(),node=s;s.buffer=buf[n];s.playbackRate.value=o.rate||1;
  if(o.lp){var f=X.createBiquadFilter();f.type='lowpass';f.frequency.value=o.lp;node.connect(f);node=f}
  if(o.hp){var h=X.createBiquadFilter();h.type='highpass';h.frequency.value=o.hp;node.connect(h);node=h}
  node.connect(g);g.connect(out());var t=X.currentTime+.005+(o.at||0),v=o.v==null?1:o.v;g.gain.setValueAtTime(v,t);
  if(o.cut){g.gain.setValueAtTime(v,t+o.cut*.6);g.gain.exponentialRampToValueAtTime(.001,t+o.cut);s.start(t,o.off||0,o.cut+.02)}else s.start(t,o.off||0);return s}
 function NZ(o){if(!on()||!ctx())return;var s=X.createBufferSource(),f=X.createBiquadFilter(),g=X.createGain(),t=X.currentTime+.005+(o.at||0);s.buffer=N;f.type=o.type||'bandpass';f.Q.value=o.q||1;
  f.frequency.setValueAtTime(o.f0,t);f.frequency.exponentialRampToValueAtTime(o.f1||o.f0,t+o.d);g.gain.setValueAtTime(.0001,t);g.gain.exponentialRampToValueAtTime(o.v,t+(o.a||.002));g.gain.exponentialRampToValueAtTime(.0005,t+o.d);
  s.connect(f);f.connect(g);g.connect(out());s.start(t,Math.random()*.5,o.d+.05)}
 var lastPop=0;
 return{ctx:ctx,S:S,NZ:NZ,
  // FINAL normal match sound: party popper (one per match moment), match 4/5 a little fuller
  popper:function(big,rate){if(!ctx())return;var now=X.currentTime;if(now-lastPop<.045)return;lastPop=now;var r=rate||1;
   S('cap',{rate:rnd(.97,1.03)*r*1.05,v:big?.55:.38,lp:5000});NZ({f0:4000,f1:2500,q:.5,d:.3,v:.12*(big?1.35:1),a:.02,type:'highpass',at:.03});S('sparkler',{off:.32,cut:.18,rate:1.3*r,v:.08*(big?1.4:1),hp:3500,at:.06});if(big)S('thud',{rate:.8*r,v:.28,lp:500})},
  made:function(){S('sparkler',{off:.35,cut:.22,rate:1.6,v:.16,hp:3000});NZ({f0:3000,f1:6000,q:.8,d:.2,v:.08,type:'highpass'})},
  swipe:function(){NZ({type:'lowpass',f0:700,f1:3200,d:.13,v:.32,a:.05});S('swoosh',{rate:2.2,cut:.14,v:.12,hp:900})},
  wrong:function(){this.swipe();S('thud',{rate:1.9,v:.14,lp:900,at:.16})},
  // chain: a soft sparkler fizz bed that keeps rising under the cascades
  bedOn:function(step){if(!on()||!ctx()||!buf.sparkler)return;var t=X.currentTime;
   if(!bed){var s=X.createBufferSource(),f=X.createBiquadFilter(),g=X.createGain();s.buffer=buf.sparkler;s.loop=true;s.loopStart=.3;s.loopEnd=.9;f.type='highpass';f.frequency.value=2500;g.gain.setValueAtTime(.0001,t);s.connect(f);f.connect(g);g.connect(out());s.start(t,.3);bed={s:s,f:f,g:g}}
   var v=Math.min(.05+step*.025,.18);bed.g.gain.cancelScheduledValues(t);bed.g.gain.setValueAtTime(Math.max(bed.g.gain.value,.0001),t);bed.g.gain.exponentialRampToValueAtTime(v,t+.12);bed.f.frequency.linearRampToValueAtTime(Math.min(2500+step*500,5000),t+.2);bed.s.playbackRate.linearRampToValueAtTime(Math.min(1.1+step*.07,1.5),t+.2);
   if(step>=2)S('sparkler',{off:.35,cut:.12,rate:1.4+step*.05,v:.08+step*.02,hp:3500,at:.04});if(step>=3)S('swoosh',{rate:1.6+step*.1,v:.12+step*.03,hp:800,cut:.25});if(step>=4)S('wala',{off:[1.17,1.315,1.455][Math.random()*3|0],cut:.05,rate:1.3,v:.18,hp:2500,at:.08})},
  bedOff:function(){if(!bed||!X)return;var b=bed,t=X.currentTime;bed=null;b.g.gain.cancelScheduledValues(t);b.g.gain.setValueAtTime(Math.max(b.g.gain.value,.0001),t);b.g.gain.exponentialRampToValueAtTime(.0005,t+.3);try{b.s.stop(t+.35)}catch(e){}S('sparkler',{off:.4,cut:.4,rate:1.7,v:.12,hp:4500})},
  // obstacle sounds
  goldShine:function(){S('sparkler',{off:.5,cut:.16,rate:2,v:.1,hp:5000});NZ({f0:5000,f1:8000,q:2,d:.12,v:.05,type:'bandpass'})},
  victory:function(){if(buf.win)S('win',{v:.75});else S('fanfare',{v:.8})},
  soft:function(){S('swoosh',{rate:1.4,v:.18,hp:600,cut:.3});S('sparkler',{off:.4,cut:.18,rate:1.8,v:.1,hp:4000,at:.05})}}})();
addEventListener('pointerdown',function(){A.ctx()},{once:true});
if(window.SFX){
 SFX.cracker=function(k,c,n){A.popper((n||3)>=4,1+Math.min(c||0,6)*.07);return .1};
 SFX.swap=function(){A.swipe()};SFX.nope=function(){A.wrong()};
 var make0=SFX.make;SFX.make=function(){A.made()}}

// ================= hidden hole: empty, dark slot until a neighbour opens =================
if(window.OBT)OBT.hole={hp:999,k:'b',f:'crate'};
var fixed0=G.fixed;G.fixed=function(e){return !!(e&&e.ob&&e.ob.t=='hole')||fixed0.call(this,e)};
var hitOb0=G.hitOb;G.hitOb=function(e,p,blast){if(e&&e.ob&&e.ob.t=='hole')return;var t=e&&e.ob&&e.ob.t,hp=e&&e.ob&&e.ob.hp,x=this.cx(p[1]),y=this.cy(p[0]),u=this.uu(),safe=e&&e.safe&&e.safe>this.clock;
 hitOb0.call(this,e,p,blast);if(!safe&&t&&(t=='crate'||t=='steel'))breakFx(this,t,x,y,u,hp<=1,hp)};
var draw0=G.drawOver;G.drawOver=function(c,e,x,y,s){var o=e.ob;if(o&&o.t=='hole'){c.save();var g=c.createLinearGradient(x,y,x,y+s);g.addColorStop(0,'#1B0B33');g.addColorStop(1,'#3A1C66');c.fillStyle=g;c.beginPath();c.roundRect(x+1,y+1,s-2,s-2,8);c.fill();c.strokeStyle='rgba(255,210,90,.25)';c.lineWidth=1.5;c.stroke();c.restore();return}return draw0.call(this,c,e,x,y,s)};
G.openHoles=function(){var L=this.lv.hide;if(!L||!L.length||this.holesDone)return;var s=this,R=this.rows(),C=this.cols(),open=[];
 function isHole(r,c){var e=s.at2(r,c);return e&&e.ob&&e.ob.t=='hole'}
 L.forEach(function(p){if(!isHole(p[0],p[1]))return;[[1,0],[-1,0],[0,1],[0,-1]].forEach(function(d){var r=p[0]+d[0],c=p[1]+d[1];if(r<0||c<0||r>=R||c>=C||s.hole(r,c))return;var e=s.b[r][c];if(!isHole(r,c)&&(!e||!e.ob))open.push(p)})});
 if(!open.length)return;var seen={},q=open.slice();while(q.length){var p=q.pop(),k=p+'';if(seen[k]||!isHole(p[0],p[1]))continue;seen[k]=1;this.b[p[0]][p[1]]=null;var x=this.cx(p[1]),y=this.cy(p[0]);this.spark(x,y,6,['#FFD24A','#FFFFFF'],140);
  [[1,0],[-1,0],[0,1],[0,-1]].forEach(function(d){q.push([p[0]+d[0],p[1]+d[1]])})}
 if(!L.some(function(p){return isHole(p[0],p[1])}))this.holesDone=true;A.soft()};

// ================= level start: holes, placed specials, lesson patterns =================
var fresh0=G.fresh;G.fresh=function(){fresh0.call(this);var s=this,L=this.lv;
 (L.hide||[]).forEach(function(p){var e=s.at2(p[0],p[1]);if(e){e.ob={t:'hole',hp:999,sq:0,fl:0};e.k=-3}});
 (L.pre||[]).forEach(function(p){var e=s.at2(p[0],p[1]);if(e&&!e.ob)e.k=p[2]});
 this.makeMove()};
// lesson patterns in the free top rows (rows 0-2): 4 in a line, 5 in a line, square, L shape
G.stamp=function(){var t=this.lv.teach;if(!t)return;var a=this.lv.colors[0],b=this.lv.colors[1],s=this;
 var M={rocket:{put:[[0,1],[0,2],[0,4],[1,3]],not:[0,3],mv:[1,3,-1,0]},line5:{put:[[0,1],[0,2],[0,4],[0,5],[1,3]],not:[0,3],mv:[1,3,-1,0]},
  square:{put:[[0,1],[0,2],[1,1],[1,3]],not:[1,2],mv:[1,3,0,-1]},lshape:{put:[[0,1],[0,3],[0,4],[1,2],[2,2]],not:[0,2],mv:[1,2,-1,0]}}[t];if(!M)return;
 if(M.put.concat([M.not]).some(function(p){var e=s.at2(p[0],p[1]);return !e||e.ob||e.k>=6}))return;
 var keep={};M.put.forEach(function(p){s.b[p[0]][p[1]].k=a;keep[p]=1});s.b[M.not[0]][M.not[1]].k=b;keep[M.not]=1;var g=0,f;
 while((f=this.find()).length&&g++<300)f.forEach(function(q){q.cells.forEach(function(p){if(!keep[p]){var e=s.b[p[0]][p[1]];if(e&&!e.ob&&e.k<6)e.k=s.rk()}})});this.teach=M.mv};
// the hand: combo opening (level 10) first, then lessons, then specials
var hint0=G.hintMove;G.hintMove=function(){var L=this.lv;if(L.combo&&this.moves==L.moves){var e=this.at2(L.combo.r,L.combo.c);if(e&&e.k>=6)return L.combo}return hint0.call(this)};

// ================= no shuffling: if no move is left, quietly recolour one tile to make one =================
G.makeMove=function(){if(this.hasMove())return true;var L=[],R=this.rows(),C=this.cols(),s=this;for(var r=0;r<R;r++)for(var c=0;c<C;c++){var e=this.b[r][c];if(e&&!e.ob&&!e.diya&&e.k>=0&&e.k<6)L.push(e)}
 L.sort(function(){return Math.random()-.5});for(var i=0;i<L.length;i++){var e=L[i],k0=e.k;for(var j=0;j<this.lv.colors.length;j++){var k=this.lv.colors[j];if(k==k0)continue;e.k=k;if(!this.find().length&&this.hasMove()){e.shakeT=.3;return true}}e.k=k0}return false};
var onDone0=G.onDone;G.onDone=function(){if(!this.over&&this.b&&!this.hasMove())this.makeMove();return onDone0.apply(this,arguments)};

// ================= chain feel (item 27): rising fizz, x3/x4 counter, small shake from the 3rd blast =================
var blast0=G.blast;G.blast=function(g,sw){var r=blast0.apply(this,arguments);if(sw==null&&this.isGame&&!this.ended){var n=this.casc||1;if(n>=2){A.bedOn(n);this.inChain=true}
  if(n>=3){this.shake=Math.max(this.shake||0,2+Math.min(n,6));this.flash=Math.max(this.flash||0,.08+n*.03);var q=g&&g[0]&&g[0].cells&&g[0].cells[0];if(q)this.chainTag(this.cx(q[1]),this.cy(q[0]),n)}}
 else if(sw){this.inChain=false}return r};
G.chainTag=function(x,y,n){var s=this;this.obj(function(c,t){var f=Math.min(t/.7,1);c.save();c.globalAlpha=1-f*f;c.font='26px Lilita,Titan,sans-serif';c.textAlign='center';c.lineWidth=6;c.strokeStyle='#5A1A00';var sc=1+Math.sin(Math.min(t/.15,1)*Math.PI)*.3;c.translate(x,y-20-f*30);c.scale(sc,sc);c.strokeText('x'+n,0,0);c.fillStyle='#FFE27A';c.fillText('x'+n,0,0);c.restore();return f<1},.75)};
var tick28=G.tick;G.tick=function(n){if(this.b&&!this.stopped)this.openHoles();tick28.call(this,n);if(this.b&&this.wasRest&&this.inChain){this.inChain=false;A.bedOff()}};

// ================= 3D obstacle breaks (item 32): crate and wooden crate =================
var PC={};function pieces(img,cols,rows){var k=img.src+cols+rows;if(PC[k])return PC[k];if(!img.naturalWidth)return null;var L=[],w=img.naturalWidth/cols,h=img.naturalHeight/rows;
 for(var i=0;i<cols;i++)for(var j=0;j<rows;j++){var c=document.createElement('canvas');c.width=Math.ceil(w);c.height=Math.ceil(h);var x=c.getContext('2d');x.beginPath();for(var q=0;q<6;q++){var a=q/6*6.283+rnd(0,.5);x.lineTo(w/2+Math.cos(a)*w*rnd(.5,.72),h/2+Math.sin(a)*h*rnd(.5,.72))}x.closePath();x.clip();x.drawImage(img,i*w,j*h,w,h,0,0,w,h);
  L.push({c:c,dk:window.CAB3D?CAB3D.dark(c):null,dx:(i+.5)/cols-.5,dy:(j+.5)/rows-.5})}return PC[k]=L}
function breakFx(g,t,x,y,u,dead,hp){var F=window.CAB3D;if(!F)return;var I=G.IC[t=='steel'&&hp>1?'crate2':'crate'];
 F.impact(x,y,u*.55,dead);if(F.AU&&F.AU.wood)F.AU.wood(dead,dead?1:.7);
 var P=pieces(I,dead?3:2,dead?3:2);if(P){(dead?P:P.slice(0,2)).forEach(function(p){F.fly(p.c,x+p.dx*u,y+p.dy*u,u/(dead?3:2)*1.05,u/(dead?3:2)*1.05,{dk:p.dk,vx:p.dx*rnd(300,520)+rnd(-60,60),vy:-rnd(380,620)+p.dy*120,vz:rnd(1,1.9),zmax:rnd(.9,1.6),wx:rnd(-12,12),wy:rnd(-12,12),vr:rnd(-8,8),g:1500})})}
 F.spray(x,y,['#C98A45','#A0652B','#E2B47A','#7A4A1E'],dead?14:7,'s',{v0:150,v1:420,s0:5,s1:11});F.spray(x,y,['rgba(230,205,170,1)','#B9772F'],dead?10:5,'c',{v0:80,v1:260,s0:3,s1:6})}
// gold floor: a gold shine and glitter when it clears
var hitFl0=G.hitFl;if(hitFl0)G.hitFl=function(r,c){var k=r+','+c,f=this.fl&&this.fl[k],was=f&&f.t=='gold';var res=hitFl0.apply(this,arguments);if(was&&!this.fl[k]){var x=this.cx(c),y=this.cy(r),F=window.CAB3D;A.goldShine();if(F)F.spray(x,y,['#FFE27A','#FFD23F','#FFF6C2','#F2B533'],8,'c',{v0:60,v1:220,s0:3,s1:6,up:1.2});this.ring(x,y,'#FFE27A',this.uu()*.9,4)}return res};
})();
// victory: after the end tune the leftover-move crackers play soft whooshes instead of full blasts (window.ENDSOFT is set by app.js)
(function(){var KEEP={fanfare:1,chime:1,coin:1,wala:1,tick:1,pop:1},last=0,p0=SFX.play,c0=SFX.cracker;
function soft(){var n=performance.now();if(n-last<110)return;last=n;p0.call(SFX,'swoosh',{v:.22,rate:1.3+Math.random()*.4})}
SFX.play=function(n,o){if(window.ENDSOFT&&!KEEP[n]){soft();return}return p0.apply(SFX,arguments)};
SFX.cracker=function(){if(window.ENDSOFT){soft();return}return c0.apply(SFX,arguments)}})();
// sparkler fix (item 20): flow.js G.shape (match finder) hid the sparkler's own shape(), so runShape crashed and the count never went down
(function(){var G=CrackersGame.prototype,o=G,sp=null;while(o){if(Object.prototype.hasOwnProperty.call(o,'shape')&&/fork/.test(String(o.shape))){sp=o.shape;break}o=Object.getPrototypeOf(o)}
if(sp){var rs0=G.runShape;G.runShape=function(dr,dc){this.shape=sp;try{return rs0.call(this,dr,dc)}finally{delete this.shape}}}})();
