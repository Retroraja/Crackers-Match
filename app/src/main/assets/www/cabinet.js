// Sweet-shop cabinet (2x2): closed glass doors, then 6 sweet plates.
// 1st hit BREAKS the doors (glass shatters, frames fly off). Every hit after blasts one plate out.
// Empty: the cabinet bursts into planks. Pieces fly out of the screen in 3D (FX3D layer on top of everything).
// Load after bigbreak.js.
(function(){
var G=CrackersGame.prototype,prevDraw=G.drawOver,prevHit=G.hitBig;
function rnd(a,b){return a+Math.random()*(b-a)}
function snd(n,o){if(window.SFX)SFX.play(n,o||{})}
var R=[[22,65,56,56],[79,69,56,52],[136,65,56,56],[22,152,56,52],[79,148,56,56],[136,148,56,56]];
var IX=22,IY=38,IW=170,IH=166,FX=6,FY=22,FW=202,FH=210,SZ=240,OY=112;
var BITS=['#FF9E2A','#FFD27A','#FFFFFF','#F2C23A'];

// sweet type per plate slot (0 laddu, 1 jalebi, 2 katli) and crumb colours
var SWK=[0,1,2,1,2,0],SWC=[['#FF9E2A','#FFC25A','#E07B12','#FFE3A0'],['#FF8A00','#FFB43A','#D85E00','#FFD06A'],['#F7F1E0','#E8DFC6','#FFFFFF','#C9CCD8']];
// ---------- object sounds (synth): glass crash, wood break, sweet crunch ----------
var AU=(function(){var X,N;function ctx(){if(!X){var A=window.AudioContext||window.webkitAudioContext;if(!A)return null;X=new A();var b=X.createBuffer(1,X.sampleRate,X.sampleRate),d=b.getChannelData(0);for(var i=0;i<d.length;i++)d[i]=Math.random()*2-1;N=b}if(X.state=='suspended')X.resume();return X}
 function on(){try{return localStorage.getItem('cm_sound')!=='0'&&localStorage.getItem('cm_fx')!=='0'}catch(e){return true}}
 function noise(t,dur,type,f,Q,v,dec){var s=X.createBufferSource(),fl=X.createBiquadFilter(),g=X.createGain();s.buffer=N;fl.type=type;fl.frequency.value=f;fl.Q.value=Q;g.gain.setValueAtTime(v,t);g.gain.exponentialRampToValueAtTime(.001,t+dec);s.connect(fl);fl.connect(g);g.connect(X.destination);s.start(t,Math.random()*.5,dur)}
 function tone(t,f0,f1,type,v,dec){var o=X.createOscillator(),g=X.createGain();o.type=type;o.frequency.setValueAtTime(f0,t);o.frequency.exponentialRampToValueAtTime(f1,t+dec);g.gain.setValueAtTime(v,t);g.gain.exponentialRampToValueAtTime(.001,t+dec);o.connect(g);g.connect(X.destination);o.start(t);o.stop(t+dec+.02)}
 return{
  glass:function(){if(!on()||!ctx())return;var t=X.currentTime+.01;noise(t,.35,'highpass',2600,.7,.55,.3);noise(t+.02,.2,'bandpass',5200,2,.35,.18);
   for(var i=0;i<16;i++){var f=rnd(2200,6800);tone(t+rnd(.02,.32),f,f*rnd(.97,1.02),'sine',rnd(.04,.09),rnd(.06,.16))}},
  wood:function(big,v){if(!on()||!ctx())return;v=v||1;var t=X.currentTime+.01;tone(t,big?120:rnd(140,170),big?42:60,'sine',(big?1:.8)*v,big?.38:.24);noise(t,.12,'bandpass',big?900:rnd(1100,1500),1.2,(big?.9:.7)*v,.11);noise(t+.035,.09,'bandpass',big?600:rnd(750,950),1.5,.5*v,.09);
   if(big){noise(t+.02,.5,'lowpass',380,.7,.7,.45);for(var i=0;i<4;i++)noise(t+rnd(.08,.3),.06,'bandpass',rnd(700,1400),2,.35,.06)}},
  steel:function(r){if(!on()||!ctx())return;var t=X.currentTime+.01;for(var i=0;i<6;i++)noise(t+rnd(0,.16),.05,'bandpass',rnd(2800,5200)*r,6,rnd(.18,.32),rnd(.04,.09));noise(t,.12,'lowpass',500,.7,.35,.1)},
  soda:function(r){if(!on()||!ctx())return;var t=X.currentTime+.01;noise(t,.2,'highpass',2600,.7,.4,.18);for(var i=0;i<8;i++){var f=rnd(2500,6000);tone(t+rnd(.02,.2),f,f,'sine',rnd(.03,.06),rnd(.05,.1))}noise(t+.05,.5,'highpass',5000,.5,.12,.45)},
  glassb:function(r){if(!on()||!ctx())return;var t=X.currentTime+.01;noise(t,.25,'highpass',2200,.7,.5,.22);for(var i=0;i<10;i++){var f=rnd(2200,6200);tone(t+rnd(.02,.25),f,f,'sine',rnd(.03,.07),rnd(.05,.12))}},
  ceramic:function(r){if(!on()||!ctx())return;var t=X.currentTime+.01;noise(t,.06,'bandpass',2400*r,3,.6,.06);noise(t+.02,.18,'bandpass',3600,2,.3,.16);for(var i=0;i<5;i++)noise(t+rnd(.05,.2),.03,'bandpass',rnd(3000,5000),5,.2,.03)},
  squish:function(r){if(!on()||!ctx())return;var t=X.currentTime+.01;noise(t,.16,'lowpass',900*r,1,.6,.15);tone(t,180,70,'sine',.3,.12);noise(t+.04,.1,'bandpass',1500,1.5,.2,.08)},
  clay:function(r){if(!on()||!ctx())return;var t=X.currentTime+.01;// clay diya: like the cup crack but lower and duller, crumbly bits, small body knock, flame puff
   noise(t,.07,'bandpass',1500*r,2.5,.7,.07);noise(t+.015,.16,'bandpass',2300*r,2,.32,.15);noise(t,.08,'lowpass',600,.7,.35,.07);
   for(var i=0;i<7;i++)noise(t+rnd(.04,.22),.035,'bandpass',rnd(1200,2700),4,rnd(.16,.28),.035);noise(t+.05,.3,'bandpass',450,.7,.18,.28)},
  paper:function(r){if(window.SFX)SFX.play('paper',{rate:r*1.1,v:.8});if(!on()||!ctx())return;var t=X.currentTime+.01;noise(t,.18,'bandpass',3000,.8,.25,.16)},
  metal:function(){if(!on()||!ctx())return;var t=X.currentTime+.01;for(var i=0;i<8;i++)noise(t+rnd(0,.2),.05,'bandpass',rnd(2500,5000),6,rnd(.2,.35),rnd(.04,.1));noise(t,.15,'lowpass',400,.7,.6,.14)},
  crunch:function(r){if(!ctx()||!on())return;var t=X.currentTime+.01;tone(t,240*r,120*r,'sine',.35,.09);
   for(var i=0;i<7;i++)noise(t+rnd(0,.13),.04,'bandpass',rnd(1600,3800)*r,2.2,rnd(.25,.45),rnd(.03,.06));noise(t+.01,.15,'highpass',5000,.7,.12,.12)}}})();
var TY={cab:{art:'cab',w:2,h:2,g:{"W": 240, "H": 240, "d": 16, "FX": 6, "FY": 22, "FW": 202, "FH": 210, "IX": 22, "IY": 38, "IW": 170, "IH": 166, "nr": 2, "nc": 3},R:R,K:SWK,C:SWC,snd:'crunch',cov:'doors',glass:1,plate:1,body:['#D89050','#B46A2C','#8A4818'],fx:'',idle:'',end:'',wood:1},
 cab_kaapi:{art:'cab-kaapi',w:2,h:2,g:{"W": 240, "H": 240, "d": 16, "FX": 6, "FY": 22, "FW": 202, "FH": 210, "IX": 22, "IY": 38, "IW": 170, "IH": 166, "nr": 2, "nc": 3},R:[[23, 61, 54, 58], [80, 61, 54, 58], [137, 61, 54, 58], [23, 144, 54, 58], [80, 144, 54, 58], [137, 144, 54, 58]],K:[0, 1, 2, 1, 2, 0],C:[['#E4E7F0','#9A9EB0','#6B3B1A','#FFFFFF'],['#FFE7A0','#D6A640','#6B3B1A','#FFFFFF'],['#E4E7F0','#9A9EB0','#C08A5A','#FFFFFF']],snd:'steel',cov:'strips',glass:0,body:['#F0F2F8','#C4C8D6','#7D8296'],fx:'coffee',idle:'steam',end:'rods',wood:0},
 cab_soda:{art:'cab-soda',w:3,h:2,g:{"W": 360, "H": 240, "d": 16, "FX": 6, "FY": 22, "FW": 322, "FH": 210, "IX": 22, "IY": 38, "IW": 290, "IH": 166, "nr": 2, "nc": 4},R:[[31, 61, 54, 58], [104, 61, 54, 58], [176, 61, 54, 58], [249, 61, 54, 58], [31, 144, 54, 58], [104, 144, 54, 58], [176, 144, 54, 58], [249, 144, 54, 58]],K:[0, 1, 2, 0, 1, 2, 0, 1],C:[['#B8F0C0','#5EC27A','#FFFFFF','#2A7A46'],['#C0E4FF','#6AAEE8','#FFFFFF','#2A5A9A'],['#FFD6E8','#F28AB0','#FFFFFF','#A83A6A']],snd:'soda',cov:'lid',glass:0,body:['#3A8ED8','#2466B0','#173F78'],fx:'fountain',idle:'bubbles',end:'ice',wood:1},
 cab_cups:{art:'cab-cups',w:2,h:2,g:{"W": 240, "H": 240, "d": 16, "FX": 6, "FY": 36, "FW": 202, "FH": 196, "IX": 22, "IY": 52, "IW": 170, "IH": 152, "nr": 2, "nc": 3},R:[[23, 84, 54, 42], [80, 84, 54, 42], [137, 84, 54, 42], [23, 160, 54, 42], [80, 160, 54, 42], [137, 160, 54, 42]],K:[0, 1, 2, 1, 2, 0],C:[['#FFF8EC','#F0DCC0','#E8A0B0','#C9A87A'],['#FFF8EC','#F0DCC0','#A0C0E8','#C9A87A'],['#FFF8EC','#F0DCC0','#F2C14E','#C9A87A']],snd:'ceramic',cov:'doors',glass:1,body:['#FFF6E6','#F0DCC0','#C9A87A'],fx:'spin',idle:'',end:'',wood:1},
 cab_bottles:{art:'cab-bottles',w:2,h:2,g:{"W": 240, "H": 240, "d": 16, "FX": 6, "FY": 34, "FW": 202, "FH": 198, "IX": 22, "IY": 50, "IW": 170, "IH": 154, "nr": 2, "nc": 3},R:[[23, 63, 54, 62], [80, 63, 54, 62], [137, 63, 54, 62], [23, 140, 54, 62], [80, 140, 54, 62], [137, 140, 54, 62]],K:[0, 1, 2, 1, 2, 0],C:[['#A8F0B0','#3AA85A','#FFFFFF','#B9824A'],['#FFD08A','#E08A1A','#FFFFFF','#B9824A'],['#E0B0FF','#9A4AD8','#FFFFFF','#B9824A']],snd:'glassb',cov:'doors',glass:1,body:['#8A4A2A','#5E2E16','#3A1A08'],fx:'liquid',idle:'',end:'',wood:1},
 cab_fruit:{art:'cab-fruit',w:3,h:2,g:{"W": 360, "H": 240, "d": 16, "FX": 6, "FY": 52, "FW": 322, "FH": 166, "IX": 22, "IY": 68, "IW": 290, "IH": 122, "nr": 2, "nc": 4},R:[[31, 77, 54, 50], [104, 77, 54, 50], [176, 77, 54, 50], [249, 77, 54, 50], [31, 138, 54, 50], [104, 138, 54, 50], [176, 138, 54, 50], [249, 138, 54, 50]],K:[0, 1, 2, 0, 1, 2, 0, 1],C:[['#FFB020','#FFD84A','#E2561A','#FFF3A0'],['#E8273F','#FFB0A0','#8A0F1F','#FFFFFF'],['#FFF27A','#E8B81A','#FFF8C0','#9A7A10']],snd:'squish',cov:'tear',glass:0,body:['#E8C27A','#C99A4A','#8A6A2A'],fx:'juice',idle:'sway',end:'wheels',wood:1},
 cab_diyas:{art:'cab-diyas',w:2,h:2,g:{"W": 240, "H": 240, "d": 16, "FX": 6, "FY": 50, "FW": 202, "FH": 182, "IX": 22, "IY": 66, "IW": 170, "IH": 138, "nr": 2, "nc": 3},R:[[23, 81, 54, 52], [80, 81, 54, 52], [137, 81, 54, 52], [23, 150, 54, 52], [80, 150, 54, 52], [137, 150, 54, 52]],K:[0, 1, 2, 1, 2, 0],C:[['#C98A2E','#A8682C','#FFD24A','#FF8A1A'],['#C98A2E','#A8682C','#FFD24A','#FF8A1A'],['#C98A2E','#A8682C','#FFD24A','#FF8A1A']],snd:'clay',cov:'doors',glass:0,body:['#B8283A','#8A1424','#5A0A14'],fx:'flame',idle:'flame',end:'light',wood:1},
 cab_gifts:{art:'cab-gifts',w:2,h:3,g:{"W": 240, "H": 360, "d": 16, "FX": 6, "FY": 30, "FW": 202, "FH": 322, "IX": 22, "IY": 46, "IW": 170, "IH": 278, "nr": 3, "nc": 3},R:[[23, 85, 54, 52], [80, 85, 54, 52], [137, 85, 54, 52], [23, 177, 54, 52], [80, 177, 54, 52], [137, 177, 54, 52], [23, 270, 54, 52], [80, 270, 54, 52], [137, 270, 54, 52]],K:[0, 1, 2, 1, 2, 0, 2, 0, 1],C:[['#E8273F','#FFD24A','#FFFFFF','#B01A2A'],['#2F6BD8','#FFD24A','#FFFFFF','#1A3A8A'],['#2FB84A','#FFD24A','#FFFFFF','#1A7A2A']],snd:'paper',cov:'bow',glass:0,body:['#FF8AC0','#E04A8A','#9A1A5A'],fx:'confetti',idle:'',end:'confetti',wood:0}};
window.CAB_TYPES=TY;var CT=TY.cab;
var IMG={};Object.keys(TY).forEach(function(t){var o=IMG[t]={};['base','items','door'].forEach(function(n){var i=new Image();i.src='art/'+TY[t].art+'-'+n+'.webp';o[n]=i});
 o.items.onload=function(){var r=TY[t].R[0],c=document.createElement('canvas');c.width=r[2]*2;c.height=r[3]*2;c.getContext('2d').drawImage(o.items,r[0],r[1],r[2],r[3],0,0,r[2]*2,r[3]*2);BIG_ICON[t]=c.toDataURL()}});
window.BIG_ICON=window.BIG_ICON||{};
function cv(img,T){var c=document.createElement('canvas');c.width=T.g.W*2;c.height=T.g.H*2;var x=c.getContext('2d');x.scale(2,2);if(img)x.drawImage(img,0,0,T.g.W,T.g.H);c.x=x;return c}
function blob(cx,cy,rx,ry,j){var p=[];for(var i=0;i<16;i++){var a=i/16*6.283,k=1+rnd(-j,j);p.push([cx+Math.cos(a)*rx*k,cy+Math.sin(a)*ry*k])}return p}
function path(x,P){x.beginPath();P.forEach(function(q,i){i?x.lineTo(q[0],q[1]):x.moveTo(q[0],q[1])});x.closePath()}
// cut polygon P (image px) out of src (a 2x canvas or 240 image); returns canvas + its box in image px
function crop(src,P,T){T=T||CT;var a=1e9,b=1e9,A=-1e9,B2=-1e9;P.forEach(function(p){a=Math.min(a,p[0]);b=Math.min(b,p[1]);A=Math.max(A,p[0]);B2=Math.max(B2,p[1])});
 var w=A-a,h=B2-b,c=document.createElement('canvas');c.width=Math.ceil(w*2)+2;c.height=Math.ceil(h*2)+2;var x=c.getContext('2d');x.scale(2,2);x.translate(-a,-b);path(x,P);x.clip();x.drawImage(src,0,0,T.g.W,T.g.H);
 return{c:c,x:a,y:b,w:w,h:h}}
function erase(x,P){x.save();x.globalCompositeOperation='destination-out';path(x,P);x.fill();x.restore()}

// ---------------- FX3D: pieces that fly toward the player, tumble in 3D and fall off the screen ----------------
var F=window.__F={P:[],E:[],dim:0,cv:null,x:null};
function fxInit(){if(F.cv)return;var c=F.cv=document.createElement('canvas');c.style.cssText='position:fixed;pointer-events:none;z-index:60';document.body.appendChild(c);F.x=c.getContext('2d');
 var last=0;(function loop(t){var dt=Math.min((t-last)/1000||0,.04);last=t;fxStep(dt);requestAnimationFrame(loop)})(0)}
function fxStep(dt){var d=document.getElementById('deb'),c=F.cv,x=F.x;if(!d)return;var r=d.getBoundingClientRect(),dpr=Math.min(window.devicePixelRatio||1,2);
 if(c.style.width!=r.width+'px'||c.style.left!=r.left+'px'){c.style.left=r.left+'px';c.style.top=r.top+'px';c.style.width=r.width+'px';c.style.height=r.height+'px';c.width=390*dpr;c.height=844*dpr}
 x.setTransform(c.width/390,0,0,c.height/844,0,0);x.clearRect(0,0,390,844);
 if(F.dim>0){F.dim=Math.max(0,F.dim-dt*1.6);x.fillStyle='rgba(10,0,25,'+Math.min(.35,F.dim)+')';x.fillRect(0,0,390,844)}
 // impact effects: ring, burst lines, dust
 for(var i=F.E.length-1;i>=0;i--){var e=F.E[i];e.t+=dt;var p=e.t/e.d;if(p>=1){F.E.splice(i,1);continue}x.save();
  if(e.k=='ring'){x.globalAlpha=(1-p)*.9;x.strokeStyle='#FFF7D6';x.lineWidth=8*(1-p)+1;x.beginPath();x.arc(e.x,e.y,e.r*(.3+p*1.2),0,7);x.stroke()}
  else if(e.k=='lines'){x.globalAlpha=1-p;x.strokeStyle='#FFFFFF';x.lineCap='round';for(var j=0;j<e.a.length;j++){var a=e.a[j],r0=e.r*(.2+p*.9),r1=r0+e.r*(.55*(1-p)+.1);x.lineWidth=3*(1-p)+.5;x.beginPath();x.moveTo(e.x+Math.cos(a)*r0,e.y+Math.sin(a)*r0);x.lineTo(e.x+Math.cos(a)*r1,e.y+Math.sin(a)*r1);x.stroke()}}
  else if(e.k=='dust'){x.globalAlpha=(1-p)*.55;x.fillStyle=e.col;x.beginPath();x.arc(e.x+e.vx*e.t,e.y+e.vy*e.t,e.r*(.5+p*1.3),0,7);x.fill()}
  else if(e.k=='flash'){x.globalAlpha=(1-p)*.7;var g=x.createRadialGradient(e.x,e.y,0,e.x,e.y,e.r);g.addColorStop(0,'#FFFFFF');g.addColorStop(.4,'rgba(255,240,190,.6)');g.addColorStop(1,'rgba(255,220,150,0)');x.fillStyle=g;x.beginPath();x.arc(e.x,e.y,e.r,0,7);x.fill()}
  x.restore()}
 // flying pieces, drawn small-to-big so the closest is on top
 if(F.P.length>150)F.P.splice(0,F.P.length-150);F.P.sort(function(a,b){return a.s0*(1+a.z)-b.s0*(1+b.z)});
 for(i=F.P.length-1;i>=0;i--){var o=F.P[i];o.t+=dt;o.vy+=o.g*dt;o.x+=o.vx*dt;o.y+=o.vy*dt;o.z=Math.min(o.zmax,o.z+o.vz*dt);o.vz*=Math.pow(.25,dt);o.ax+=o.wx*dt;o.ay+=o.wy*dt;o.rot+=o.vr*dt;
  if(o.y-o.h*(1+o.z)>870||o.t>o.life){F.P.splice(i,1);continue}
  var s=o.s0*(1+o.z),fx=Math.cos(o.ay),fy=Math.cos(o.ax),back=fx*fy<0;x.save();x.translate(o.x,o.y);x.rotate(o.rot);x.scale(s*Math.max(.06,Math.abs(fx)),s*Math.max(.06,Math.abs(fy)));
  x.drawImage(back&&o.dk?o.dk:o.img,-o.w/2,-o.h/2,o.w,o.h);x.restore()}}
function fly(img,cx,cy,w,h,o){fxInit();o=o||{};F.P.push({img:img,dk:o.dk,nb:o.nb,s0:o.s0||1,x:cx,y:cy+OY,w:w,h:h,t:0,life:o.life||3,vx:o.vx||0,vy:o.vy||-300,g:o.g||1300,z:0,vz:o.vz==null?1.4:o.vz,zmax:o.zmax||1.6,ax:0,ay:0,wx:o.wx||0,wy:o.wy||0,rot:o.rot||0,vr:o.vr||0})}

// small 3D crumb / splinter sprites (cached), flown with fly() for extra particles
var CR={};function crumb(col,kind){var k=col+kind+(Math.random()*4|0);if(CR[k])return CR[k];var c=document.createElement('canvas'),S=24;c.width=c.height=S;var x=c.getContext('2d');
 if(kind=='s'){x.fillStyle=col;x.beginPath();x.moveTo(2,10);x.lineTo(22,7);x.lineTo(23,13);x.lineTo(3,16);x.closePath();x.fill();x.fillStyle='rgba(255,240,210,.6)';x.fillRect(4,9,16,2)}
 else{x.fillStyle=col;x.beginPath();for(var i=0;i<7;i++){var a=i/7*6.283,r=rnd(6,10);x.lineTo(12+Math.cos(a)*r,12+Math.sin(a)*r)}x.closePath();x.fill();x.fillStyle='rgba(255,255,255,.45)';x.beginPath();x.arc(9,9,3,0,7);x.fill();x.fillStyle='rgba(0,0,0,.18)';x.beginPath();x.arc(15,15,4,0,7);x.fill()}
 return CR[k]=c}
function spray(px,py,cols,n,kind,o){o=o||{};for(var i=0;i<n;i++){var a=o.up?(-Math.PI/2+rnd(-o.up,o.up)):rnd(0,6.28),v=rnd(o.v0||120,o.v1||380),sz=rnd(o.s0||4,o.s1||9);
 fly(crumb(cols[i%cols.length],kind),px+rnd(-8,8),py+rnd(-8,8),sz,sz*(kind=='s'?1:1),{s0:1,vx:Math.cos(a)*v,vy:Math.sin(a)*v-(o.up?0:rnd(150,300)),vz:rnd(.6,1.8),zmax:rnd(.6,1.6),wx:rnd(-14,14),wy:rnd(-14,14),vr:rnd(-10,10),g:o.g||1200,life:2.5,nb:1})}}
function impact(cx,cy,r,big){fxInit();var y=cy+OY,a=[],n=big?14:10;for(var i=0;i<n;i++)a.push(i/n*6.283+rnd(-.15,.15));
 F.E.push({k:'flash',x:cx,y:y,r:r*1.3,t:0,d:.22});F.E.push({k:'ring',x:cx,y:y,r:r,t:0,d:.35});F.E.push({k:'lines',x:cx,y:y,r:r*1.3,a:a,t:0,d:.3});
 for(i=0;i<(big?10:6);i++){var b=rnd(0,6.28),v=rnd(30,90);F.E.push({k:'dust',x:cx+rnd(-r*.4,r*.4),y:y+rnd(-r*.3,r*.4),vx:Math.cos(b)*v,vy:Math.sin(b)*v-20,r:rnd(8,16)*(big?1.5:1),col:i%2?'rgba(230,205,170,1)':'rgba(255,245,225,1)',t:0,d:rnd(.45,.7)})}}

function dark(c){var d=document.createElement('canvas');d.width=c.width;d.height=c.height;var x=d.getContext('2d');x.filter='brightness(.55) saturate(.8)';x.drawImage(c,0,0);return d}

function rect(x,y,w,h){return[[x,y],[x+w,y],[x+w,y+h],[x,y+h]]}
function pre(B){var T=TY[B.t],I=IMG[B.t],g=T.g;B.T=T;
 B.pre=T.R.map(function(r){var sx=r[0]+4,sw=r[2]-8,sy=r[1],sh=r[3]-(T.plate?16:4),pl=r[1]+r[3]-17,bits=[],n=4,m=4;
  for(var a=0;a<n;a++)for(var b=0;b<m;b++){var x0=sx+sw*a/n,y0=sy+sh*b/m,w=sw/n,h=sh/m,P=[];for(var q=0;q<6;q++){var t=q/6*6.283+rnd(0,.5);P.push([x0+w/2+Math.cos(t)*w*rnd(.45,.75),y0+h/2+Math.sin(t)*h*rnd(.45,.75)])}var cp=crop(B.it,P,T);cp.dk=dark(cp.c);cp.dx=a-1.5;cp.dy=b-1.5;bits.push(cp)}
  var whole=crop(B.it,rect(r[0],r[1],r[2],r[3]),T);whole.dk=dark(whole.c);
  var plate=T.plate?crop(B.it,rect(r[0]-2,pl,r[2]+4,20),T):null;if(plate)plate.dk=dark(plate.c);return{bits:bits,plate:plate,whole:whole}});
 // cover pieces, by cover type
 var x0=g.IX-3,y0=g.IY-3,cw=g.IW+6,ch=g.IH+6,P=[];
 function add(poly,o){var c=crop(I.door,poly,T);c.dk=dark(c.c);c.o=o||{};P.push(c)}
 if(T.cov=='doors'){add(rect(x0,y0,cw/2,ch),{dir:-1,big:1});add(rect(x0+cw/2,y0,cw/2,ch),{dir:1,big:1});
  if(T.glass)for(var i=0;i<14;i++){var gx=x0+9+rnd(0,cw-40),gy=y0+9+rnd(0,ch-40),sz=rnd(24,40);add([[gx,gy],[gx+sz*rnd(.7,1.1),gy+rnd(-4,6)],[gx+rnd(0,sz*.6),gy+sz*rnd(.9,1.4)]],{dir:gx<x0+cw/2?-1:1,shard:1})}}
 if(T.cov=='strips'){for(var i=0;i<6;i++)add(rect(x0,y0+ch*i/6,cw,ch/6),{strip:i})}
 if(T.cov=='lid')add(rect(x0,y0,cw,ch),{lid:1});
 if(T.cov=='tear'){var L=[[x0,y0],[x0+cw/2,y0]],Rr=[[x0+cw/2,y0],[x0+cw,y0],[x0+cw,y0+ch]],j;for(j=1;j<=8;j++){var yy=y0+ch*j/8,xx=x0+cw/2+rnd(-8,8);L.push([xx,yy]);Rr.push([xx,yy])}L.push([x0,y0+ch]);Rr.reverse();add(L,{dir:-1,cloth:1});add(Rr.reverse(),{dir:1,cloth:1})}
 if(T.cov=='bow'){var bx=x0+cw/2,by=y0+ch*.4;add(rect(bx-46,by-24,92,40),{bow:1});for(var i=0;i<4;i++)add(rect(x0+cw*(i%2)/2,y0+ch*(i>>1)/2,cw/2,ch/2),{dir:i%2?1:-1,paper:1})}
 B.cp=P}
function ini(B){var I=IMG[B.t],T=TY[B.t];if(B.door==null){B.door=1;B.done={};B.hits=0}if(!B.bs&&I.base.naturalWidth&&I.items.naturalWidth&&I.door.naturalWidth){B.bs=cv(I.base,T);B.it=cv(I.items,T);pre(B)}return !!(B.bs&&B.cp)}
function crack(B){var T=TY[B.t],g=T.g,x=B.bs.x,side=Math.random()*4|0,px,py;
 if(side==0){px=rnd(g.FX+10,g.FX+g.FW-10);py=rnd(g.FY+3,g.IY-4)}else if(side==1){px=rnd(g.FX+2,g.IX-3);py=rnd(g.IY,g.IY+g.IH)}else if(side==2){px=rnd(g.IX+g.IW+3,g.FX+g.FW-2);py=rnd(g.IY,g.IY+g.IH)}else{px=rnd(g.FX+10,g.FX+g.FW-10);py=rnd(g.IY+g.IH+2,g.FY+g.FH-4)}
 if(T.cov=='strips')return;var a=rnd(0,6.28),pts=[[px,py]];for(var i=0;i<5;i++){a+=rnd(-.8,.8);px+=Math.cos(a)*rnd(4,8);py+=Math.sin(a)*rnd(3,6);pts.push([px,py])}
 x.save();x.lineJoin='round';x.lineCap='round';x.strokeStyle='rgba(255,236,200,.55)';x.lineWidth=2;x.beginPath();pts.forEach(function(q,i){i?x.lineTo(q[0]+.8,q[1]+.8):x.moveTo(q[0]+.8,q[1]+.8)});x.stroke();
 x.strokeStyle='rgba(50,18,2,.85)';x.lineWidth=1.4;x.beginPath();pts.forEach(function(q,i){i?x.lineTo(q[0],q[1]):x.moveTo(q[0],q[1])});x.stroke();x.restore()}
function P2S(B,px,py){var g=B.geo;return[g.cx+g.ox+px*g.sc,g.cy+g.oy+py*g.sc]}
function idle(c,B,T,ox,oy,sc,t){if(!T.idle||B.door)return;c.save();
 T.R.forEach(function(r,j){if(B.done[j])return;var cx=ox+(r[0]+r[2]/2)*sc,top=oy+r[1]*sc,bot=oy+(r[1]+r[3])*sc;
  if(T.idle=='steam'){c.strokeStyle='rgba(255,255,255,.55)';c.lineWidth=1.5*sc*2;for(var k=0;k<2;k++){var ph=t*2+j+k*1.7,yy=top+6*sc-((ph*8)%14)*sc;c.globalAlpha=.6-((ph*8)%14)/24;c.beginPath();c.moveTo(cx-3*sc+k*6*sc,yy+10*sc);c.quadraticCurveTo(cx-8*sc+k*6*sc+Math.sin(ph*3)*3*sc,yy+4*sc,cx-3*sc+k*6*sc,yy-2*sc);c.stroke()}}
  if(T.idle=='bubbles'){c.fillStyle='rgba(255,255,255,.75)';for(var k=0;k<3;k++){var p=((t*.9+j*.37+k*.33)%1),yy=bot-6*sc-p*(r[3]-14)*sc;c.globalAlpha=1-p;c.beginPath();c.arc(cx+Math.sin(p*9+k)*3*sc,yy,1.3*sc*2,0,7);c.fill()}}
  if(T.idle=='flame'){var f=1+Math.sin(t*14+j*2)*.15+Math.sin(t*23+j)*.08,gg=c.createRadialGradient(cx,top+12*sc,0,cx,top+12*sc,12*sc*f);gg.addColorStop(0,'rgba(255,240,160,.85)');gg.addColorStop(.5,'rgba(255,170,40,.35)');gg.addColorStop(1,'rgba(255,120,0,0)');c.fillStyle=gg;c.beginPath();c.arc(cx,top+12*sc,12*sc*f,0,7);c.fill()}
  if(T.idle=='sway'){}});c.restore()}

G.drawOver=function(c,e,x,y,s){var o=e.ob;if(!(o&&o.t=='big'&&TY[o.B.t]))return prevDraw.call(this,c,e,x,y,s);if(!o.anchor)return;
 var B=o.B,T=TY[B.t],g=T.g;if(!ini(B))return;var U=this.uu(),W=B.w*U-(U-s),H=B.h*U-(U-s),k=1+B.sq*.035;B.sq=Math.max(0,B.sq-.06);
 c.save();c.translate(x+W/2,y+H/2+H*.45);c.rotate(Math.sin(B.sq*22)*B.sq*.035);c.scale(k,k);c.translate(0,-H*.45);
 var dw=W*1.06,dh=dw*g.H/g.W;if(dh>H*1.08){dh=H*1.08;dw=dh*g.W/g.H}var sc=dw/g.W,ox=-dw/2,oy=-dh/2-2;B.geo={cx:x+W/2,cy:y+H/2,ox:ox,oy:oy,sc:sc};
 c.drawImage(B.bs,ox,oy,dw,dh);
 if(T.idle=='sway'){var t0=this.clock||0;T.R.forEach(function(r,j){if(B.done[j])return;var a=Math.sin(t0*2.2+j)*.05;c.save();c.translate(ox+(r[0]+r[2]/2)*sc,oy+(r[1]+r[3])*sc);c.rotate(a);c.drawImage(B.it,r[0]*2,r[1]*2,r[2]*2,r[3]*2,-r[2]/2*sc,-r[3]*sc,r[2]*sc,r[3]*sc);c.restore()})}
 else c.drawImage(B.it,ox,oy,dw,dh);
 idle(c,B,T,ox,oy,sc,this.clock||0);
 if(B.door&&IMG[B.t].door.naturalWidth)c.drawImage(IMG[B.t].door,ox,oy,dw,dh);
 c.restore()};

G.hitBig=function(B,blast){if(!TY[B.t])return prevHit.call(this,B,blast);
 if(!ini(B)||!B.geo||B.n<=0||B.safe>this.clock)return;B.safe=this.clock+(blast?.3:.25);B.sq=1;var s=this,n=blast?2:1;
 if(B.door){B.door=0;n--;this.breakCover(B);crack(B);crack(B)}
 for(var i=0;i<n&&B.n>0;i++){this.breakPlate(B,i*.1);B.n--;B.hits++;this.addScore(60);crack(B);if(B.hits%2)crack(B)}
 if(B.n<=0)this.at(.3,function(){s.cabDown(B)})};

G.breakCover=function(B){var T=TY[B.t],g=B.geo,sc=g.sc;
 if(T.cov=='doors'){AU.wood(false,1);if(T.glass)AU.glass();else AU.metal()}else if(T.cov=='strips')AU.metal();else if(T.cov=='lid'){AU.wood(false,.9);AU.soda(1.2)}else AU.paper(.8);
 B.cp.forEach(function(c,i){var o=c.o,q=P2S(B,c.x+c.w/2,c.y+c.h/2),w=c.w*sc,h=c.h*sc;
  if(o.big)fly(c.c,q[0],q[1],w,h,{dk:c.dk,s0:1.1,vx:o.dir*rnd(140,200),vy:-rnd(380,460),vz:1.5,zmax:1.3,wy:o.dir*rnd(5,7),wx:rnd(-2,2),vr:o.dir*rnd(1.5,3)});
  else if(o.shard)fly(c.c,q[0],q[1],w,h,{dk:c.dk,s0:1.4,vx:o.dir*rnd(40,260),vy:-rnd(260,520),vz:rnd(1.2,2),zmax:rnd(1,1.8),wx:rnd(-9,9),wy:rnd(-9,9),vr:rnd(-6,6),g:1500});
  else if(o.strip!=null)setTimeout(function(){fly(c.c,q[0],q[1],w,h,{dk:c.dk,s0:1.05,vx:rnd(-160,160),vy:-rnd(80,220),vz:rnd(.6,1.1),zmax:1,wx:rnd(-6,6),vr:rnd(-2,2),g:1500})},(5-o.strip)*45);
  else if(o.lid)fly(c.c,q[0],q[1],w,h,{dk:c.dk,s0:1.1,vx:rnd(-60,60),vy:-720,vz:1.3,zmax:1.4,wx:rnd(5,8),vr:rnd(-2,2),g:1300});
  else if(o.cloth)fly(c.c,q[0],q[1],w,h,{dk:c.dk,s0:1.05,vx:o.dir*rnd(60,110),vy:-rnd(60,140),vz:.5,zmax:.8,wy:o.dir*rnd(1,2),vr:o.dir*rnd(.5,1.2),g:700});
  else if(o.bow)fly(c.c,q[0],q[1],w,h,{dk:c.dk,s0:1.3,vx:rnd(-40,40),vy:-620,vz:1.6,zmax:1.6,wy:rnd(4,7),vr:rnd(-4,4),g:1200});
  else if(o.paper)fly(c.c,q[0],q[1],w,h,{dk:c.dk,s0:1.05,vx:o.dir*rnd(120,220),vy:-rnd(200,360),vz:1,zmax:1.1,wx:rnd(-5,5),wy:rnd(-5,5),vr:o.dir*rnd(1,3),g:1100})});
 impact(g.cx,g.cy,70,true);
 requestAnimationFrame(function(){spray(g.cx,g.cy,T.body,16,'s',{s0:8,s1:16});var gc=T.glass?['#DDF3FF','#FFFFFF','#BFE3F7']:T.cov=='tear'?['#FF9A2A','#E2561A','#FFD84A']:T.cov=='lid'?['#8AC4F4','#FFFFFF','#DFF6FF']:T.cov=='bow'?['#F6C445','#FFC0DC','#FFFFFF']:['#F2C14E','#D9DCE8','#FFFFFF'];spray(g.cx,g.cy,gc,16,'c',{s0:3,s1:6,v0:200,v1:480});DEB.bits(g.cx,g.cy,16,T.body.concat(gc),5,1.1,{shape:'tri'})})};

G.breakPlate=function(B,d){var s=this,T=TY[B.t],left=[];T.R.forEach(function(r,j){if(!B.done[j])left.push(j)});if(!left.length)return;
 var j=left[Math.random()*left.length|0],r=T.R[j],kind=T.K[j],pc=B.pre[j],SC=T.C;B.done[j]=1;
 erase(B.it.x,blob(r[0]+r[2]/2,r[1]+r[3]/2,r[2]*.56,r[3]*.56,.04));
 this.at(d,function(){var g=B.geo;if(!g)return;var c=P2S(B,r[0]+r[2]/2,r[1]+r[3]/2),px=c[0],py=c[1],side=px<g.cx?-1:1,top=P2S(B,0,r[1])[1];
  if(T.fx=='spin'){var w=pc.whole;fly(w.c,px,py,w.w*g.sc,w.h*g.sc,{dk:w.dk,s0:1.5,vx:side*rnd(120,200),vy:-rnd(480,560),vz:1.4,zmax:1.4,wy:side*rnd(6,9),vr:side*rnd(4,7),g:1500});pc.bits.slice(0,6).forEach(function(o){var q=P2S(B,o.x+o.w/2,o.y+o.h/2);fly(o.c,q[0],q[1],o.w*g.sc,o.h*g.sc,{dk:o.dk,s0:1.8,vx:o.dx*rnd(90,170),vy:-rnd(260,420),vz:rnd(.7,1.2),zmax:1,wx:rnd(-8,8),wy:rnd(-8,8),vr:rnd(-6,6),g:1200})})}
  else{pc.bits.forEach(function(o){var q=P2S(B,o.x+o.w/2,o.y+o.h/2);fly(o.c,q[0],q[1],o.w*g.sc,o.h*g.sc,{dk:o.dk,s0:2.1,vx:o.dx*rnd(80,170)+side*rnd(10,60)+rnd(-30,30),vy:-rnd(260,430)+o.dy*50,vz:rnd(.7,1.3),zmax:rnd(.6,1.1),wx:rnd(-8,8),wy:rnd(-8,8),vr:rnd(-6,6),g:1150})})}
  var p2=pc.plate;if(p2){var q=P2S(B,p2.x+p2.w/2,p2.y+p2.h/2);fly(p2.c,q[0],q[1],p2.w*g.sc,p2.h*g.sc,{dk:p2.dk,s0:1.6,vx:side*rnd(60,140),vy:-rnd(220,320),vz:1,zmax:.9,wx:side*rnd(5,8),vr:side*rnd(1,2.5),g:1600})}
  impact(px,py,34,false);if(T.wood)AU.wood(false,.5);AU[T.snd](.85+B.hits*.03);
  requestAnimationFrame(function(){spray(px,py,SC[kind],24,'c',{s0:5,s1:11,v0:80,v1:300,g:1000});spray(px,py,SC[kind],8,'c',{s0:9,s1:14,v0:60,v1:200,g:1100});spray(px,py,['#FFFFFF','#FFF4C8'],8,'c',{s0:3,s1:5,v0:150,v1:380});
   spray(px,py,T.body,6,'s',{s0:7,s1:12,v0:120,v1:300});DEB.bits(px,py,16,SC[kind],4,1.3,{shape:'tri'});
   if(T.fx=='coffee'){spray(px,top,['#6B3B1A','#8A5226','#C08A5A'],22,'c',{s0:3,s1:7,v0:180,v1:380,up:.9,g:1400});F.E.push({k:'dust',x:px,y:top+OY,vx:0,vy:-40,r:14,col:'rgba(255,255,255,1)',t:0,d:.8})}
   if(T.fx=='fountain'){spray(px,top,['#FFFFFF','#DFF6FF',SC[kind][0]],30,'c',{s0:2,s1:5,v0:420,v1:700,up:.18,g:1300});spray(px,top,['#E8FBFF'],1,'c',{s0:9,s1:10,v0:300,v1:360,up:.6,g:1500})}
   if(T.fx=='liquid'){spray(px,py,[SC[kind][1],SC[kind][0]],22,'c',{s0:3,s1:7,v0:150,v1:360,g:1500})}
   if(T.fx=='juice'){spray(px,py,[SC[kind][0],SC[kind][1],SC[kind][2]],24,'c',{s0:3,s1:7,v0:100,v1:300,g:1600})}
   if(T.fx=='flame'){spray(px,top,['#FFF0A0','#FFB020','#FF6A00'],22,'c',{s0:2,s1:4,v0:160,v1:380,up:.8,g:300});for(var i=0;i<4;i++)F.E.push({k:'dust',x:px+rnd(-6,6),y:top+OY,vx:rnd(-15,15),vy:-rnd(40,80),r:rnd(8,14),col:'rgba(120,110,110,1)',t:0,d:rnd(.7,1)})}
   if(T.fx=='confetti'){spray(px,py,['#E8273F','#2F6BD8','#2FB84A','#F6C445','#FF8AC0','#FFFFFF'],34,'s',{s0:5,s1:9,v0:200,v1:460,up:1.1,g:700})}});
  if(s.goal[B.t]>0){s.goal[B.t]--;window.FLY_SRC=BIG_ICON[B.t];if(s.cb.fly)s.cb.fly(B.t,px,py);window.FLY_SRC=null;if(s.cb.goal)s.cb.goal(s.goal)}})};

function wheel(){var c=document.createElement('canvas');c.width=c.height=40;var x=c.getContext('2d');x.fillStyle='#5A3A10';x.beginPath();x.arc(20,20,18,0,7);x.fill();x.strokeStyle='#C99A4A';x.lineWidth=3;for(var a=0;a<6;a++){x.beginPath();x.moveTo(20,20);x.lineTo(20+Math.cos(a)*15,20+Math.sin(a)*15);x.stroke()}x.fillStyle='#E9C27A';x.beginPath();x.arc(20,20,4,0,7);x.fill();return c}
G.cabDown=function(B){var T=TY[B.t],g=B.geo,sc=g.sc,G2=T.g;
 for(var r=B.r;r<B.r+B.h;r++)for(var c=B.c;c<B.c+B.w;c++){if(this.at2(r,c))this.b[r][c]=null}
 var cols=B.w*2,rows=B.h*2;for(var i=0;i<cols;i++)for(var j=0;j<rows;j++){var x0=G2.FX+G2.FW*i/cols,y0=G2.FY-16+(G2.FH+16)*j/rows,w=G2.FW/cols+(i==cols-1?16:0),h=(G2.FH+16)/rows,
   P=[[x0+rnd(-3,3),y0+rnd(-3,3)],[x0+w+rnd(-3,3),y0+rnd(-3,3)],[x0+w+rnd(-3,3),y0+h+rnd(-3,3)],[x0+rnd(-3,3),y0+h+rnd(-3,3)]],pc=crop(B.bs,P,T),q=P2S(B,pc.x+pc.w/2,pc.y+pc.h/2),dx=(i-(cols-1)/2),dy=(j-(rows-1)/2);
  fly(pc.c,q[0],q[1],pc.w*sc,pc.h*sc,{s0:1.1,vx:dx*rnd(110,200)+rnd(-40,40),vy:-rnd(360,560)+dy*60,vz:rnd(1.2,1.7),zmax:rnd(1.1,1.6),wx:rnd(-6,6),wy:rnd(-6,6),vr:rnd(-4,4)})}
 impact(g.cx,g.cy,110,true);F.dim=.6;
 var sp=function(){spray(g.cx,g.cy,T.body,28,'s',{s0:10,s1:22,v0:180,v1:520});
  if(T.end=='wheels'){var wh=wheel();[-1,1].forEach(function(dd){fly(wh,g.cx+dd*40,g.cy+30,26,26,{s0:1.2,vx:dd*rnd(260,340),vy:-180,vz:.6,zmax:.8,vr:dd*12,g:900,nb:1})})}
  if(T.end=='ice')spray(g.cx,g.cy,['#E8FBFF','#BFE9FF','#FFFFFF'],30,'c',{s0:6,s1:12,v0:150,v1:420});
  if(T.end=='light'){F.E.push({k:'flash',x:g.cx,y:g.cy+OY,r:260,t:0,d:.6});spray(g.cx,g.cy,['#FFF0A0','#FFD24A','#FFFFFF'],40,'c',{s0:2,s1:5,v0:200,v1:560,g:200})}
  if(T.end=='confetti')spray(g.cx,g.cy,['#E8273F','#2F6BD8','#2FB84A','#F6C445','#FF8AC0','#FFFFFF'],70,'s',{s0:5,s1:10,v0:250,v1:600,g:500});
  if(T.end=='rods')spray(g.cx,g.cy,['#E4E7F0','#B8BDCC','#7D8296'],16,'s',{s0:16,s1:28,v0:150,v1:380,g:1500})};
 requestAnimationFrame(sp);DEB.bits(g.cx,g.cy,24,T.body,6,1.5,{shape:'tri'});
 this.shake=Math.max(this.shake,3);this.flash=Math.max(this.flash,.35);this.burst(g.cx,g.cy,['#FFD24A','#FFFFFF','#FF7A1A'],30,340);if(T.end=='rods')AU.metal();else AU.wood(true);snd('blast',{v:.35})};
window.CAB3D={fly:fly,spray:spray,impact:impact,crumb:crumb,AU:AU,dark:dark,F:F};
})();
