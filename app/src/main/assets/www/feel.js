// Feel fixes (11 Nov 2026). Load after specials2.js.
// - snappy swap: fast start, tiny bounce, grabbed tile lifts
// - a special hit by another special fires at once (not after the first one ends)
// - several specials going off together share one refill (the last finish wins)
(function(){
var G=CrackersGame.prototype,prevHit=G.hit,prevFinish=G.finish;
function back(t){var c1=1.4,c3=c1+1;return 1+c3*Math.pow(t-1,3)+c1*Math.pow(t-1,2)}
G.slide=function(r,c,tr,tc,done){var s=this,a=this.b[r][c],n=this.b[tr][tc],dx=tc-c,dy=tr-r;if(!dx&&!dy){done();return}a.top=true;a.lift=0;var D=.13;
 this.obj(function(c2,t){var f=Math.min(t/D,1),e=back(f);a.sx=dx*e;a.sy=dy*e;a.lift=Math.sin(Math.min(f,1)*Math.PI);if(n){n.sx=-dx*e;n.sy=-dy*e}
  if(f>=1){a.sx=a.sy=0;a.top=false;a.lift=0;if(n){n.sx=n.sy=0}s.b[r][c]=n;s.b[tr][tc]=a;done();return false}return true},D+.05)};
G.finish=function(t){var s=this,T=this.clock+t;this.finT=Math.max(this.finT||0,T);this.at(t,function(){if(s.clock+1e-4>=s.finT){s.finT=0;s.refill()}})};
G.hit=function(r,c,o){var e=this.b[r]&&this.b[r][c];
 if(e&&e.k>=6&&!e.firing&&!e.dead&&!e.ob&&this.isGame&&!(e.safe&&e.safe>this.clock)){var s=this,d=(o&&o.d)||0;e.firing=true;e.shakeT=.12;
  this.at(d+.04,function(){var f=s.b[r]&&s.b[r][c];if(f!==e)return;if(window.SFX)SFX.special(e.k);s.busy=true;s.go({r:r,c:c,k:e.k},0,0)});return}
 return prevHit.call(this,r,c,o)};
var prevUse=G.use;G.use=function(r,c,dr,dc){try{if(window.cmVib&&navigator.vibrate)navigator.vibrate(25)}catch(e){}return prevUse.call(this,r,c,dr,dc)};
})();
