(function(){var X=null,on=true,master,mus;try{on=localStorage.getItem('cm_sound')!=='0'}catch(e){}
function ctx(){if(!X){var A=window.AudioContext||window.webkitAudioContext;if(!A)return null;X=new A();master=X.createGain();master.gain.value=.9;var c=X.createDynamicsCompressor();master.connect(c);c.connect(X.destination)}if(X.state=='suspended')X.resume();return X}
function noise(d){var b=X.createBuffer(1,X.sampleRate*d,X.sampleRate),a=b.getChannelData(0);for(var i=0;i<a.length;i++)a[i]=Math.random()*2-1;var s=X.createBufferSource();s.buffer=b;return s}
function N(o){if(!on||!ctx())return;var t=X.currentTime+(o.at||0),s=noise(o.d),f=X.createBiquadFilter(),g=X.createGain();f.type=o.ft||'bandpass';f.frequency.setValueAtTime(o.f,t);if(o.f2)f.frequency.exponentialRampToValueAtTime(o.f2,t+o.d);f.Q.value=o.q||1;g.gain.setValueAtTime(o.v,t);g.gain.exponentialRampToValueAtTime(.001,t+o.d);s.connect(f);f.connect(g);g.connect(master);s.start(t);s.stop(t+o.d)}
function T(o){if(!on||!ctx())return;var t=X.currentTime+(o.at||0),s=X.createOscillator(),g=X.createGain();s.type=o.w||'sine';s.frequency.setValueAtTime(o.f,t);if(o.f2)s.frequency.exponentialRampToValueAtTime(o.f2,t+o.d);g.gain.setValueAtTime(.0001,t);g.gain.exponentialRampToValueAtTime(o.v,t+.008);g.gain.exponentialRampToValueAtTime(.001,t+o.d);s.connect(g);g.connect(o.out||master);s.start(t);s.stop(t+o.d+.02)}
function crackle(at,n,v){for(var i=0;i<n;i++)N({at:at+i*.035+Math.random()*.03,d:.03,f:1800+Math.random()*3500,q:3,v:v})}
function boom(at,v){T({at:at,f:150,f2:34,d:.75,v:v,w:'sine'});N({at:at,d:.5,f:900,f2:90,ft:'lowpass',v:v});crackle(at+.1,10,.14)}
var last=0,S={unlock:function(){ctx();S.music()},
pop:function(c){var p=1+(c||0)*.13;N({d:.09,f:1500*p,q:.8,v:.55});T({f:640*p,f2:170,d:.1,v:.35,w:'triangle'});crackle(.05,3,.12)},
crack:function(){var n=performance.now();if(n-last<45)return;last=n;N({d:.06,f:2300+Math.random()*1700,q:1.2,v:.28});T({f:1200+Math.random()*700,f2:300,d:.05,v:.1,w:'square'})},
swap:function(){T({f:420,f2:640,d:.1,v:.16})},nope:function(){T({f:210,f2:150,d:.15,v:.2,w:'triangle'})},
make:function(){[660,880,1175].forEach(function(f,i){T({at:i*.06,f:f,d:.17,v:.22,w:'triangle'})});N({d:.3,f:5000,f2:1500,v:.15})},
paper:function(){N({d:.14,f:3600,f2:1400,q:.7,v:.28})},
cascade:function(c){var f=[523,587,659,784,880,1047][Math.min(c,5)];T({f:f,d:.22,v:.22,w:'triangle'});T({at:.05,f:f*1.5,d:.2,v:.15})},
special:function(k){if(k==6||k==15||k==16){N({at:.14,d:.55,f:900,f2:4800,q:.7,v:.42});T({at:.14,f:700,f2:2500,d:.5,v:.13,w:'sawtooth'});N({at:.65,d:.14,f:1800,v:.45})}
 else if(k==7){N({d:1.4,f:3200,f2:5500,q:.5,v:.26});crackle(.5,16,.11)}
 else if(k==8){T({f:180,f2:900,d:.46,v:.18,w:'sawtooth'});crackle(.1,8,.1);boom(.44,.65)}
 else if(k==10){N({d:.28,f:4000,q:.7,v:.2});boom(.28,1)}
 else if(k==9){T({f:180,f2:1700,d:.7,v:.2,w:'triangle'});N({at:.72,d:.32,f:1400,v:.7});for(var i=0;i<9;i++)T({at:.82+i*.09,f:1500-i*80,d:.16,v:.12})}
 else if(k==11){N({d:1,f:6200,q:.6,v:.3});crackle(0,12,.12)}
 else if(k==12){crackle(.2,34,.26)}
 else if(k==13){N({d:1.3,f:1200,f2:3200,q:.8,v:.32});crackle(.2,16,.14)}
 else if(k==14){[523,659,784,1047,1319,1568].forEach(function(f,i){T({at:i*.09,f:f,d:.22,v:.18,w:'triangle'})});boom(.86,.5)}},
win:function(){[523,659,784,1047,784,1047,1319].forEach(function(f,i){T({at:i*.12,f:f,d:.3,v:.24,w:'triangle'});T({at:i*.12,f:f/2,d:.3,v:.12})});for(var i=0;i<6;i++)crackle(.5+i*.25,4,.14)},
lose:function(){[392,349,311,262].forEach(function(f,i){T({at:i*.2,f:f,d:.32,v:.2,w:'triangle'})})},
music:function(){if(mus||!ctx())return;var scale=[261.6,293.7,329.6,392,440,523.3,587.3,659.3],bass=[130.8,130.8,174.6,196],mel=[0,2,4,5,4,2,3,1,0,2,5,7,6,5,3,4],i=0,g=X.createGain();g.gain.value=.11;g.connect(master);
 mus=setInterval(function(){if(!on)return;var b=i%4==0;if(b)T({f:bass[(i/4|0)%4],d:.42,v:.75,w:'triangle',out:g});if(i%2==0)T({f:scale[mel[(i/2|0)%16]],d:.3,v:.55,w:'triangle',out:g});if(i%4==2)N({d:.05,f:7000,q:1,v:.05});i++},215)},
toggle:function(){on=!on;try{localStorage.setItem('cm_sound',on?'1':'0')}catch(e){}return on},isOn:function(){return on}};
window.SFX=S})();
