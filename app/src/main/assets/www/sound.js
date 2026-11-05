(function(){var X=null,on=true,master,mus,buf={},pr=null;try{on=localStorage.getItem('cm_sound')!=='0'}catch(e){}
var NM=['bijli','kuruvi','pencil','star','tablet','lakshmi'],SP={6:'rocket',15:'rocket',16:'rocket',7:'flowerpot',8:'chakra',9:'skyshot',10:'atom',11:'sparkler',12:'wala',13:'rail',14:'matchbox'};
function ctx(){if(!X){var A=window.AudioContext||window.webkitAudioContext;if(!A)return null;X=new A();master=X.createGain();master.gain.value=1;master.connect(X.destination)}if(X.state=='suspended')X.resume();return X}
function b2a(b){var s=atob(b),u=new Uint8Array(s.length);for(var i=0;i<s.length;i++)u[i]=s.charCodeAt(i);return u.buffer}
var S={ready:function(){if(pr)return pr;if(!ctx())return pr=Promise.resolve();pr=Promise.all(Object.keys(SND).map(function(k){return new Promise(function(ok){try{X.decodeAudioData(b2a(SND[k]),function(d){buf[k]=d;ok()},function(){ok()})}catch(e){ok()}})}));return pr},
unlock:function(){ctx();S.ready();S.music()},
play:function(n,o){o=o||{};if(!on||!X||!buf[n])return;var s=X.createBufferSource(),g=X.createGain();s.buffer=buf[n];s.playbackRate.value=o.rate||1;g.gain.value=o.v==null?1:o.v;s.connect(g);g.connect(master);s.start(X.currentTime+(o.at||0))},
cracker:function(k,c){S.play(NM[k]||'bijli',{rate:1+Math.min(c||0,6)*.06})},special:function(k){S.play(SP[k]||'rocket')},
make:function(){S.play('tick',{v:.8})},swap:function(){S.play('swap',{v:.55})},nope:function(){S.play('nope',{v:.6})},paper:function(){S.play('paper',{v:.8})},tick:function(){S.play('tick')},blastWord:function(){S.play('blast')},crack:function(){},cascade:function(){},
win:function(){S.play('win')},lose:function(){S.play('lose')},
music:function(){if(mus||!X)return;var scale=[261.6,293.7,329.6,392,440,523.3,587.3,659.3],bass=[130.8,130.8,174.6,196],mel=[0,2,4,5,4,2,3,1,0,2,5,7,6,5,3,4],i=0,g=X.createGain();g.gain.value=.06;g.connect(master);function T(f,d,v){var t=X.currentTime,s=X.createOscillator(),e=X.createGain();s.type='triangle';s.frequency.value=f;e.gain.setValueAtTime(.0001,t);e.gain.exponentialRampToValueAtTime(v,t+.01);e.gain.exponentialRampToValueAtTime(.001,t+d);s.connect(e);e.connect(g);s.start(t);s.stop(t+d+.02)}
 mus=setInterval(function(){if(!on)return;if(i%4==0)T(bass[(i/4|0)%4],.42,.8);if(i%2==0)T(scale[mel[(i/2|0)%16]],.3,.55);i++},215)},
toggle:function(){on=!on;try{localStorage.setItem('cm_sound',on?'1':'0')}catch(e){}return on},isOn:function(){return on}};
window.SFX=S})();
