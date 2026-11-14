// Continuous board (11 Nov 2026). Load after obst.js, before app.js.
// Every tile has its own state, so the board never waits for itself:
// - gravity runs every frame: empty cells fill at once from above, new tiles drop in from the top
// - you can swap any resting tile (normal or special) while other parts of the board blast, fall or refill
// - matches are checked as soon as tiles land; the end-of-turn checks run when the whole board is at rest
(function(){
var G=CrackersGame.prototype,P=window.CrackersFX2.prototype,tick0=P.tick,kind0=G.kind;
var GRAV=3300,SWAP=.13,WAIT=0,STEP=0;// build 28: back to the Build 26 feel, about 15% slower fall, no pause, no one-by-one order
function back(t){var c1=1.4,c3=c1+1;return 1+c3*Math.pow(t-1,3)+c1*Math.pow(t-1,2)}

// a tile can be swapped or matched only when it is resting
G.rest=function(e){return !!e&&!e.dead&&!e.firing&&!e.swp&&!e.top&&!(e.fy>0)};
G.kind=function(r,c){var k=kind0.call(this,r,c);if(k===false||k==null||k<0)return k;var e=this.b[r][c];return this.rest(e)?k:-1};
// crackers dropped by a gift box wait for the player's next swipe before they can match
G.clearHold=function(){var R=this.rows(),C=this.cols(),any=0;for(var r=0;r<R;r++)for(var c=0;c<C;c++){var e=this.b[r][c];if(e&&e.hold){e.hold=0;any=1}}if(any)this.dirty=true};
// a tile can fall when it is not fixed, not busy and not mid-swap
G.mov=function(e){return !e.dead&&!e.firing&&!e.swp&&!e.top&&!this.fixed(e)};

// ---- gravity: compact every column segment, spawn new tiles at the top of open segments
G.gravity=function(){var R=this.rows(),C=this.cols(),U=this.uu(),moved=false,born=[];
 for(var c=0;c<C;c++){var r=R-1,spawn=0,nth=0;
  while(r>=0){
   if(this.hole(r,c)){r--;continue}
   var e=this.b[r][c];
   if(e){r--;continue}
   // empty cell: pull the nearest tile above within this segment
   var q=r-1,src=-1,top=true;
   var bar=-1;// row of a fixed blocker above (new tiles appear from under it)
   while(q>=0){if(this.hole(q,c)){q--;continue}var f=this.b[q][c];if(f){if(this.mov(f))src=q;else if(this.fixed(f))bar=q;else top=false;break}q--}
   if(src>=0){var f2=this.b[src][c];this.b[r][c]=f2;this.b[src][c]=null;if(!(f2.fy>0))f2.wt=WAIT+nth*STEP;nth++;f2.fy=(f2.fy||0)+(r-src)*U;f2.bo=0;moved=true;r--;continue}
   if(top){// nothing above that can fall: a new tile drops in from the top, or from under a fixed blocker
    var n=this.tile(this.rk());n.fy=(bar>=0?(r-bar)*U*.6:(r+1)*U+U*.15)+spawn*U;n.v=0;n.fresh=1;n.wt=WAIT+nth*STEP;nth++;this.b[r][c]=n;born.push([r,c]);spawn++;moved=true;r--;continue}
   r--}}
 if(born.length)this.luck(born);
 return moved};

// ---- lucky refills (build 27): some refills pick a colour so the new crackers complete a special shape
// how often comes from the level: relief 1 in 2, normal 1 in 3, hard 1 in 5, super hard 1 in 8
G.rawK=function(r,c){if(r<0||c<0||r>=this.rows()||c>=this.cols())return -1;var e=this.b[r][c];return e&&!e.dead&&!e.ob&&!e.diya&&e.k>=0&&e.k<6?e.k:-1};
G.shape=function(r,c){var k=this.rawK(r,c),i;if(k<0)return{sc:0};var h=[[r,c]],v=[[r,c]],sq=[];
 for(i=c-1;this.rawK(r,i)==k;i--)h.push([r,i]);for(i=c+1;this.rawK(r,i)==k;i++)h.push([r,i]);
 for(i=r-1;this.rawK(i,c)==k;i--)v.push([i,c]);for(i=r+1;this.rawK(i,c)==k;i++)v.push([i,c]);
 for(var a=-1;a<=0;a++)for(var b=-1;b<=0;b++)if(this.rawK(r+a,c+b)==k&&this.rawK(r+a+1,c+b)==k&&this.rawK(r+a,c+b+1)==k&&this.rawK(r+a+1,c+b+1)==k)sq=[[r+a,c+b],[r+a+1,c+b],[r+a,c+b+1],[r+a+1,c+b+1]];
 var sc=(h.length>=5||v.length>=5)?4:(h.length>=3&&v.length>=3)?3:(h.length==4||v.length==4)?2:sq.length?2:0;
 return{sc:sc,cells:h.concat(v,sq)}};
G.luck=function(born){var p=this.lv&&this.lv.luck||0;if(!p||this.ended||this.over||Math.random()>p)return;
 var s=this,R=this.rows(),C=this.cols(),sp=[],best=null,bs=0,near=Math.random()<.5;
 for(var r=0;r<R;r++)for(var c=0;c<C;c++){var e=this.b[r][c];if(e&&!e.dead&&!e.ob&&e.k>=6)sp.push([r,c])}
 born.forEach(function(q){var n=s.b[q[0]][q[1]];if(!n||n.k>=6)return;var k0=n.k;
  (s.lv.colors||[]).forEach(function(k){n.k=k;var sh=s.shape(q[0],q[1]);if(sh.sc>0){var sc=sh.sc+Math.random();
   if(near&&sp.length){var d=99;sh.cells.forEach(function(a){sp.forEach(function(z){d=Math.min(d,Math.abs(a[0]-z[0])+Math.abs(a[1]-z[1]))})});if(d<=1)sc+=10}
   if(sc>bs){bs=sc;best=[q,k]}}});n.k=k0});
 if(best){var n=this.b[best[0][0]][best[0][1]];n.k=best[1];n.lucky=1;this.lucky=(this.lucky||0)+1}};

// ---- falling and landing
G.fall=function(dt){var R=this.rows(),C=this.cols(),landed=false,any=false;
 for(var r=0;r<R;r++)for(var c=0;c<C;c++){var e=this.b[r][c];if(!e)continue;
  if(e.fy>0){any=true;if(e.wt>0){e.wt-=dt;continue}e.v=(e.v||0)+GRAV*dt;e.fy-=e.v*dt;if(e.fy<=0){e.fy=0;e.v=0;e.bo=.1;landed=true;if(e.fresh){e.fresh=0;this.calm(r,c,e)}}}
  else if(e.bo>0){e.bo-=dt;if(e.bo<0)e.bo=0}}
 return{landed:landed,any:any}};
// new tiles try not to land straight into a match on easy levels (same as the old refill)
G.calm=function(r,c,e){if(e.lucky){e.lucky=0;return}if(this.ended||e.k<0||e.k>=6||!this.calmLv||Math.random()>this.calmLv())return;var kk=e.k;for(var t=0;t<6&&this.makes&&this.makes(r,c);t++)e.k=this.rk();if(this.makes&&this.makes(r,c))e.k=kk};

// ---- the board is at rest when nothing is moving, firing, pending or empty
G.settled=function(){if(this.ev.length)return false;for(var i=0;i<this.fx.length;i++)if(this.fx[i].k=='obj')return false;
 var R=this.rows(),C=this.cols();for(var r=0;r<R;r++)for(var c=0;c<C;c++){var e=this.b[r][c];if(!e){if(!this.hole(r,c))return false;continue}if(e.fy>0||e.dead||e.firing||e.swp||e.top)return false}return true};

// ---- swap: the two tiles change places at once; only the picture slides
G.swap=function(r,c,tr,tc,done){var s=this,a=this.b[r][c],n=this.b[tr][tc],dx=tc-c,dy=tr-r;
 this.b[r][c]=n;this.b[tr][tc]=a;a.swp=true;a.top=true;a.lift=0;if(n){n.swp=true}
 this.obj(function(c2,t){var f=Math.min(t/SWAP,1),e=back(f);a.sx=-dx*(1-e);a.sy=-dy*(1-e);a.lift=Math.sin(f*Math.PI);if(n){n.sx=dx*(1-e);n.sy=dy*(1-e)}
  if(f>=1){a.sx=a.sy=0;a.top=false;a.lift=0;a.swp=false;if(n){n.sx=n.sy=0;n.swp=false}done(s.b[tr][tc]===a,n&&s.b[r][c]===n);return false}return true},SWAP+.05)};

// ---- one swipe
G.act=function(r,c,dr,dc,retry){if(this.over||this.moves<=0||this.stopped||this.paused)return;this.clearHold();
 var e=this.at2(r,c),t=this.at2(r+dr,c+dc);if(!e)return;
 if(this.stuck(e)){if(window.SFX)SFX.nope();return}
 if(!this.rest(e)){if(!retry)this.later(r,c,dr,dc);return}
 if(!t){if(e.k>=6)this.use(r,c,0,0);return}
 if(this.stuck(t)){if(e.k>=6)this.use(r,c,0,0);else if(window.SFX)SFX.nope();return}
 if(!this.rest(t)){if(!retry)this.later(r,c,dr,dc);return}
 if(e.k>=6&&t.k>=6&&!(e.k==9&&t.k==9)&&this.combo&&!window.OLD){this.combo(r,c,r+dr,c+dc);return}
 if(e.k>=6){this.use(r,c,dr,dc);return}
 if(t.k>=6){this.use(r+dr,c+dc,-dr,-dc);return}
 var s=this,r2=r+dr,c2=c+dc;if(window.SFX)SFX.swap();
 this.swap(r,c,r2,c2,function(okA,okB){
  // keep only groups that touch the two swapped cells; anything else is caught by the normal match check
  var g=s.find().filter(function(q){return q.cells.some(function(p){return (p[0]==r&&p[1]==c)||(p[0]==r2&&p[1]==c2)})});
  if(!g.length){if(okA&&okB){if(window.SFX)SFX.nope();s.swap(r2,c2,r,c,function(){})}return}
  s.spend();s.blast(g,[[r2,c2],[r,c]])})};
// a swipe on a tile that is still landing waits a moment, then runs
G.later=function(r,c,dr,dc){this.pq={r:r,c:c,dr:dr,dc:dc,t:this.clock}};
G.tapSp=function(r,c){var e=this.at2(r,c);if(!e||e.k<6||this.over||this.moves<=0)return;if(this.rest(e)&&!e.queued)this.use(r,c,0,0);else this.pq={r:r,c:c,tap:1,t:this.clock}};

// ---- input: never blocked by a busy board
G.bind=function(){var s=this,cv=this.cv;cv.style.touchAction='none';function P2(ev){var b=cv.getBoundingClientRect(),k=s.W/b.width;return[(ev.clientX-b.left)*k,(ev.clientY-b.top)*k]}
 cv.addEventListener('pointerdown',function(ev){if(s.over)return;var q=s.cell(ev);if(!s.at2(q[0],q[1]))return;var p=P2(ev);s.arm={r:q[0],c:q[1],x:p[0],y:p[1]};try{cv.setPointerCapture(ev.pointerId)}catch(e){}});
 cv.addEventListener('pointermove',function(ev){var a=s.arm;if(!a)return;var U=s.uu(),p=P2(ev),dx=p[0]-a.x,dy=p[1]-a.y;if(Math.abs(dx)<U*.24&&Math.abs(dy)<U*.24)return;s.arm=null;var dr=0,dc=0;if(Math.abs(dx)>Math.abs(dy))dc=dx>0?1:-1;else dr=dy>0?1:-1;s.act(a.r,a.c,dr,dc)});
 cv.addEventListener('pointerup',function(){var a=s.arm;s.arm=null;if(a)s.tapSp(a.r,a.c)});
 cv.addEventListener('pointercancel',function(){s.arm=null})};

// the old refill is replaced by gravity; finish() still marks when an effect ends
G.refill=function(){};G.refill0=function(){};
G.guard=function(){};
// specials slide with the same safe swap (both tiles change places at once)
G.slide=function(r,c,tr,tc,done){if(r==tr&&c==tc){done();return}this.swap(r,c,tr,tc,function(){done()})};

// ---- frame
// breaking obstacles do not fly to the goal: the goal count just goes down, and its icon gives a small bump
G.wrapFly=function(){if(this.flyW||!this.cb||!this.cb.fly)return;this.flyW=1;var f=this.cb.fly;
 this.cb.fly=function(k){if(typeof k=='number'||/^[0-9]$/.test(k)||k=='diya')return f.apply(this,arguments);
  try{var el=document.querySelector('#gGoals .gi[data-k="'+k+'"]');if(el){el.classList.remove('bump');void el.offsetWidth;el.classList.add('bump')}}catch(e){}}};
G.tick=function(n){if(!this.b){return tick0.call(this,n)}this.wrapFly();
 var dt=Math.min((n-this.last)/1000,.04)*(window.GSPEED||1);if(this.stop>0)dt*=.06;
 this.dropping=false;
 this.gravity();var f=this.fall(dt);
 if(!this.over&&!this.paused){
  if(f.landed||this.dirty){this.dirty=false;var s0=this,g=this.find().filter(function(q){return !q.cells.some(function(p){var e=s0.b[p[0]][p[1]];return e&&e.hold})});if(g.length){this.casc=(this.casc||0)+1;if(this.cb.cheer)this.cb.cheer(this.casc>=4?this.casc-1:Math.min(this.casc,2));this.blast(g,null)}}
  var q=this.pq;if(q){if(this.clock-q.t>1.2)this.pq=null;else{var e=this.at2(q.r,q.c);if(e&&this.rest(e)){this.pq=null;if(q.tap)this.tapSp(q.r,q.c);else this.act(q.r,q.c,q.dr,q.dc,true)}}}}
 tick0.call(this,n);
 // rest check and end-of-turn
 var st=this.settled();
 if(st){this.stall=0;if(!this.wasRest){this.wasRest=true;this.busy=false;if(!this.over&&!this.stopped){try{this.onDone()}catch(er){if(window.console)console.error(er)}}}}
 else{this.wasRest=false;this.busy=true;this.unstick(dt)}};
// safety net: if something is still marked busy after 4 s with nothing scheduled, release it
G.unstick=function(dt){var calm=!this.ev.length&&!this.fx.some(function(f){return f.k=='obj'});if(!calm){this.stall=0;return}this.stall=(this.stall||0)+dt;if(this.stall<4)return;this.stall=0;
 var R=this.rows(),C=this.cols();for(var r=0;r<R;r++)for(var c=0;c<C;c++){var e=this.b[r][c];if(!e)continue;if(e.dead)this.b[r][c]=null;else{e.firing=false;e.swp=false;e.top=false;e.sx=e.sy=0;if(e.fy<0)e.fy=0}}};
// the old onDone also blasted matches; that is still right at rest, so it stays
})();
