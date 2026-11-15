// Build 30 (15 Nov 2026): smooth play first. No board shake or swell ripple, cheap glows, piece limits,
// automatic lighter effects on slow phones, a long lightning crackle for the Colour Matchbox, and build sounds.
// Load after b28.js, before app.js.
(function(){
var G=CrackersGame.prototype,P=window.CrackersFX2&&CrackersFX2.prototype,Z=[0,0,0];
// ---- no board shake, no swell/shrink ripple (bug 14)
[P,G].forEach(function(o){if(o)Object.defineProperty(o,'shake',{get:function(){return 0},set:function(){},configurable:true})});
if(P){P.wave=function(){};P.bump=function(){return Z}}

// ---- cheap glow: one pre-drawn picture instead of live shadow blur (bug 15)
var GL=null;window.GLOW30=function(){if(GL)return GL;GL=document.createElement('canvas');GL.width=GL.height=128;var x=GL.getContext('2d'),g=x.createRadialGradient(64,64,10,64,64,64);
 g.addColorStop(0,'rgba(255,200,60,.95)');g.addColorStop(.42,'rgba(255,170,20,.55)');g.addColorStop(.7,'rgba(255,140,0,.18)');g.addColorStop(1,'rgba(255,120,0,0)');x.fillStyle=g;x.fillRect(0,0,128,128);return GL};
// top half of the 2-hit crate (the red plank layer) for its flying pieces
var TC={};window.TOP30=function(img){if(!img||!img.naturalWidth)return img;var k=img.src;if(TC[k])return TC[k];var c=document.createElement('canvas');c.width=img.naturalWidth;c.height=img.naturalHeight;var x=c.getContext('2d');x.drawImage(img,0,0);x.clearRect(0,c.height*.52,c.width,c.height);return TC[k]=c};

// ---- board canvas: shadow blur switched off (the slowest thing to draw on phones); measure speed for auto-lite
var LITE=0;try{LITE=+localStorage.getItem('cm_lite')||0}catch(e){}window.LITE30=LITE;
var fr={n:0,t:0,on:false};
if(P){var draw0=P.draw;P.draw=function(dt){var c=this.x;if(c&&!c.__nsb){c.__nsb=1;try{Object.defineProperty(c,'shadowBlur',{get:function(){return 0},set:function(){},configurable:true})}catch(e){}}
 if(this.isGame&&!window.LITE30){var now=performance.now();if(fr.last){var d=now-fr.last;if(d<200){fr.n++;fr.t+=d}}fr.last=now;
  if(fr.n>=150){if(fr.t/fr.n>24){window.LITE30=1;try{localStorage.setItem('cm_lite','1')}catch(e){}}fr.n=0;fr.t=0}}
 return draw0.apply(this,arguments)}}
// ---- pieces on screen: about 250 at most, fewer per blast when busy or on a slow phone
function cut(s,n){var L=s.fx?s.fx.length:0;if(L>160)return Math.max(1,Math.ceil(n*.12));if(L>120||window.LITE30)return Math.max(1,Math.ceil(n*.3));return Math.max(1,Math.ceil(n*.5))}
if(P){var sp0=P.spark;if(sp0)P.spark=function(x,y,n){var a=[].slice.call(arguments);a[2]=cut(this,n);return sp0.apply(this,a)};
 var bu0=P.burst;if(bu0)P.burst=function(x,y,cols,n){var a=[].slice.call(arguments);a[3]=cut(this,n);return bu0.apply(this,a)}}
if(window.DEB){var add0=DEB.add;DEB.add=function(o){if(this.P.length>(window.LITE30?90:120))this.P.shift();return add0.call(this,o)};
 var bits0=DEB.bits;DEB.bits=function(x,y,n){var a=[].slice.call(arguments);a[2]=Math.max(1,Math.ceil(n*(window.LITE30||this.P.length>80?.3:.5)));return bits0.apply(this,a)}}

// ================= synth sounds (own audio context: filters and noise) =================
var Z30=window.Z30=(function(){var X=null,N=null,M=null;
 function on(){try{if(window.SFX&&SFX.fxIsOn&&!SFX.fxIsOn())return false}catch(e){}return true}
 function ctx(){if(!X){try{X=new (window.AudioContext||window.webkitAudioContext)();M=X.createGain();M.gain.value=.9;M.connect(X.destination);
   var b=X.createBuffer(1,X.sampleRate*2,X.sampleRate),d=b.getChannelData(0);for(var i=0;i<d.length;i++)d[i]=Math.random()*2-1;N=b}catch(e){X=null}}
  if(X&&X.state=='suspended')X.resume();return X}
 document.addEventListener('visibilitychange',function(){if(!X)return;if(document.hidden)X.suspend();else X.resume()});
 addEventListener('pointerdown',function(){ctx()},{once:true});
 function nz(o){var x=ctx();if(!x||!on())return;var t=x.currentTime+(o.at||0),s=x.createBufferSource();s.buffer=N;s.loop=true;var f=x.createBiquadFilter();f.type=o.type||'bandpass';f.frequency.setValueAtTime(o.f0||1000,t);if(o.f1)f.frequency.exponentialRampToValueAtTime(o.f1,t+o.d);f.Q.value=o.q||1;
  var g=x.createGain();g.gain.setValueAtTime(0,t);g.gain.linearRampToValueAtTime(o.v||.3,t+(o.a||.004));g.gain.exponentialRampToValueAtTime(.0005,t+o.d);s.connect(f);f.connect(g);g.connect(M);s.start(t,Math.random());s.stop(t+o.d+.05)}
 function ton(o){var x=ctx();if(!x||!on())return;var t=x.currentTime+(o.at||0),s=x.createOscillator();s.type=o.w||'sine';s.frequency.setValueAtTime(o.f0,t);if(o.f1)s.frequency.exponentialRampToValueAtTime(o.f1,t+o.d);
  var g=x.createGain();g.gain.setValueAtTime(0,t);g.gain.linearRampToValueAtTime(o.v||.2,t+(o.a||.004));g.gain.exponentialRampToValueAtTime(.0005,t+o.d);s.connect(g);g.connect(M);s.start(t);s.stop(t+o.d+.05)}
 function R(a,b){return a+Math.random()*(b-a)}
 var K={
  // ---- Colour Matchbox: a long electric crackle while the lightning picks crackers, and a zap on each one
  crackle:function(d){var x=ctx();if(!x||!on())return;d=Math.max(.4,Math.min(d,4));nz({type:'bandpass',f0:2600,f1:4200,q:.8,v:.12,a:.08,d:d+.15});nz({type:'lowpass',f0:500,q:1,v:.1,a:.1,d:d+.1});
   ton({w:'sawtooth',f0:95,f1:120,v:.04,a:.1,d:d});for(var t=0;t<d;t+=R(.025,.07))nz({at:t,type:'highpass',f0:R(2500,6000),q:.7,v:R(.05,.16),d:R(.012,.035)})},
  zap:function(){ton({w:'square',f0:R(1500,2100),f1:R(300,450),v:.05,d:.08});nz({type:'highpass',f0:3000,q:.7,v:.14,d:.06})},
  // ---- building sounds, matched to what is built
  stone:function(at){ton({at:at,w:'triangle',f0:R(1700,2600),f1:R(900,1300),v:.12,d:.05});nz({at:at,type:'bandpass',f0:R(1800,3200),q:2.5,v:.25,d:R(.05,.09)});nz({at:at+.01,type:'lowpass',f0:600,v:.12,d:.08})},
  knock:function(at){ton({at:at,w:'sine',f0:R(170,230),f1:110,v:.32,d:.12});nz({at:at,type:'bandpass',f0:R(700,1100),q:3,v:.28,d:.07})},
  saw:function(at,d){for(var i=0;i<4;i++)nz({at:at+i*d/4,type:'bandpass',f0:i%2?1500:2300,f1:i%2?2300:1500,q:4,v:.13,a:.03,d:d/4})},
  plank:function(at){ton({at:at,w:'triangle',f0:R(120,160),f1:80,v:.28,d:.16});nz({at:at,type:'bandpass',f0:R(400,650),q:2,v:.22,d:.12})},
  hum:function(at,d){ton({at:at,w:'sine',f0:110,v:.06,a:.3,d:d});ton({at:at,w:'sine',f0:220,f1:240,v:.05,a:.4,d:d});[1046,1318,1568,2093].forEach(function(f,i){ton({at:at+.25+i*.12,w:'sine',f0:f,v:.07,d:.6})});nz({at:at+.1,type:'bandpass',f0:5000,q:1,v:.05,a:.2,d:d*.8})},
  rustle:function(at,d){nz({at:at,type:'bandpass',f0:2400,f1:3600,q:.8,v:.16,a:.15,d:d});nz({at:at+d*.4,type:'bandpass',f0:3200,f1:2200,q:.8,v:.12,a:.1,d:d*.6})},
  dirt:function(at){nz({at:at,type:'lowpass',f0:R(300,500),q:1,v:.35,d:.12});nz({at:at+.02,type:'bandpass',f0:1500,q:1,v:.08,d:.08})},
  cloth:function(at){nz({at:at,type:'bandpass',f0:1200,f1:3000,q:1,v:.2,a:.02,d:.18})},
  done:function(){[1046.5,1318.5,1568,2093].forEach(function(f,i){ton({at:i*.07,w:'triangle',f0:f,v:.1,d:.5})});nz({type:'highpass',f0:6000,q:.7,v:.06,a:.05,d:.6})}};
 K.build=function(kind,dur){dur=Math.max(.8,Math.min(dur||3,5));var t,n;
  if(kind=='stone'){for(t=.1;t<dur;t+=R(.11,.2))K.stone(t)}
  else if(kind=='lamp'){for(t=.1;t<dur*.5;t+=R(.25,.35))K.knock(t);K.hum(dur*.5,Math.max(1,dur*.5))}
  else if(kind=='tree'){for(t=.1;t<dur*.6;t+=R(.3,.5))K.dirt(t);K.rustle(dur*.3,dur*.7)}
  else if(kind=='farm'){for(t=.1;t<dur;t+=R(.2,.35))K.dirt(t);K.rustle(dur*.5,dur*.5)}
  else if(kind=='bridge'){for(t=.1;t<dur;t+=R(.18,.3))K.plank(t);for(t=.2;t<dur;t+=R(.5,.7))K.knock(t)}
  else if(kind=='stall'){for(t=.1;t<dur*.7;t+=R(.2,.32))K.knock(t);K.saw(dur*.2,.5);K.cloth(dur*.75);K.cloth(dur*.85)}
  else{for(t=.1;t<dur;t+=R(.18,.3))K.knock(t);K.saw(dur*.15,.6);K.saw(dur*.55,.5);for(t=.3;t<dur;t+=R(.6,.9))K.plank(t)}};
 K.ctx=ctx;return K})();

// ---- Colour Matchbox: crackle for the whole strike, zap per cracker (bug 6)
if(G.strike){var st0=G.strike;G.strike=function(r,c,cells,t0,step,onHit,hold){var s=this,n=(cells&&cells.length)||1,last=0;
 this.at(t0||0,function(){Z30.crackle(n*(step||.07)+.35)});
 var cb=function(p){var t=performance.now();if(t-last>45){last=t;Z30.zap()}if(onHit)return onHit.apply(this,arguments)};
 return st0.call(this,r,c,cells,t0,step,cb,hold)}}
})();
