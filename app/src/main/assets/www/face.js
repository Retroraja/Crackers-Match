// The man in the coat, chest-up like a passport photo. Face actions only: blinks, looks, smiles, surprise, grin, worry, cheer.
(function(){
function Face(cv){var s=this;this.cv=cv;var d=Math.min(window.devicePixelRatio||1,3);this.W=cv.clientWidth||76;this.H=cv.clientHeight||88;cv.width=this.W*d;cv.height=this.H*d;this.x=cv.getContext('2d');this.x.scale(d,d);
 this.t=0;this.m='idle';this.mt=0;this.base='idle';this.bl=0;this.nb=2;this.look=0;this.lt=0;this.lk=0;this.bounce=0;this.v={sm:.3,br:0,ey:1,mo:0,wo:0,wk:0};this.last=performance.now();
 (function f(n){if(s.dead)return;var dt=Math.min((n-s.last)/1000,.05);s.last=n;s.step(dt);s.draw();requestAnimationFrame(f)})(this.last)}
var P=Face.prototype;
// sm smile, br brow raise, ey eye open, mo mouth open, wo worry, wk wink
var M={idle:{sm:.3,br:0,ey:1,mo:0,wo:0,wk:0},smile:{sm:1,br:.2,ey:.95,mo:0,wo:0,wk:0},wow:{sm:.4,br:1,ey:1.35,mo:.7,wo:0,wk:0},grin:{sm:1.6,br:.5,ey:.8,mo:.45,wo:0,wk:1},worried:{sm:-.6,br:.2,ey:1.05,mo:0,wo:1,wk:0},cheer:{sm:1.8,br:.8,ey:.7,mo:.8,wo:0,wk:0}};
P.mood=function(m,hold){if(!M[m])return;if(m=='worried'){this.base='worried'}this.m=m;this.mt=hold||1.4;if(m=='grin'||m=='cheer')this.bounce=1};
P.calm=function(){this.base='idle'};
P.step=function(dt){this.t+=dt;if(this.mt>0){this.mt-=dt;if(this.mt<=0)this.m=this.base}var g=M[this.m],v=this.v,k=Math.min(1,dt*10);for(var i in g)v[i]+=(g[i]-v[i])*k;
 this.nb-=dt;if(this.nb<=0){this.bl=.14;this.nb=2.2+Math.random()*3}if(this.bl>0)this.bl-=dt;
 this.lt-=dt;if(this.lt<=0){this.lt=1.5+Math.random()*2.5;this.lk=this.m=='idle'?[-1,0,1,0][Math.random()*4|0]:0}this.look+=(this.lk-this.look)*Math.min(1,dt*6);if(this.bounce>0)this.bounce=Math.max(0,this.bounce-dt*2.2)};
P.draw=function(){var c=this.x,W=this.W,H=this.H,v=this.v;c.clearRect(0,0,W,H);c.save();var sc=W/150;c.translate(W/2,H+2-Math.sin(this.bounce*Math.PI)*4);c.scale(sc,sc);
 // coat shoulders
 c.fillStyle='#2C2B34';c.beginPath();c.moveTo(-80,0);c.bezierCurveTo(-80,-40,-60,-62,-30,-70);c.lineTo(30,-70);c.bezierCurveTo(60,-62,80,-40,80,0);c.closePath();c.fill();
 c.fillStyle='#F2F3F7';c.beginPath();c.moveTo(-22,-72);c.lineTo(22,-72);c.lineTo(4,0);c.lineTo(-4,0);c.closePath();c.fill();
 c.fillStyle='#3A3944';c.beginPath();c.moveTo(-28,-72);c.lineTo(-46,-30);c.lineTo(-30,-24);c.lineTo(-3,0);c.lineTo(-10,0);c.closePath();c.moveTo(28,-72);c.lineTo(46,-30);c.lineTo(30,-24);c.lineTo(3,0);c.lineTo(10,0);c.closePath();c.fill();
 c.fillStyle='#FF2FA8';c.beginPath();c.moveTo(60,-34);c.lineTo(38,-38);c.lineTo(40,-30);c.lineTo(58,-26);c.closePath();c.fill();
 // neck and head
 c.translate(0,-140);var ng=c.createLinearGradient(0,30,0,80);ng.addColorStop(0,'#A9704A');ng.addColorStop(1,'#C48A60');c.fillStyle=ng;c.beginPath();c.roundRect(-22,30,44,50,12);c.fill();
 var fg=c.createLinearGradient(-50,0,50,0);fg.addColorStop(0,'#D9A27A');fg.addColorStop(.6,'#D19668');fg.addColorStop(1,'#B57B52');c.fillStyle='#BC8359';c.beginPath();c.ellipse(-49,6,7,14,0,0,6.3);c.ellipse(49,6,7,14,0,0,6.3);c.fill();
 c.fillStyle=fg;c.beginPath();c.moveTo(-47,-26);c.bezierCurveTo(-49,14,-44,38,-27,53);c.quadraticCurveTo(-10,66,0,66);c.quadraticCurveTo(10,66,27,53);c.bezierCurveTo(44,38,49,14,47,-26);c.bezierCurveTo(38,-60,-38,-60,-47,-26);c.fill();
 var st=c.createLinearGradient(0,20,0,66);st.addColorStop(0,'rgba(70,60,60,0)');st.addColorStop(1,'rgba(70,62,66,.42)');c.fillStyle=st;c.beginPath();c.moveTo(-44,16);c.bezierCurveTo(-42,36,-27,53,-27,53);c.quadraticCurveTo(-10,66,0,66);c.quadraticCurveTo(10,66,27,53);c.bezierCurveTo(40,38,44,16,44,16);c.quadraticCurveTo(0,44,-44,16);c.fill();
 var hg=c.createLinearGradient(-46,-8,34,-96);hg.addColorStop(0,'#17161B');hg.addColorStop(.5,'#34333B');hg.addColorStop(.82,'#83858F');hg.addColorStop(1,'#BDBFC8');c.fillStyle=hg;c.beginPath();c.moveTo(-50,10);c.quadraticCurveTo(-66,-14,-54,-34);c.quadraticCurveTo(-74,-56,-46,-66);c.quadraticCurveTo(-52,-92,-20,-84);c.quadraticCurveTo(-12,-110,14,-92);c.quadraticCurveTo(38,-106,44,-80);c.quadraticCurveTo(70,-78,60,-52);c.quadraticCurveTo(76,-34,56,-20);c.quadraticCurveTo(60,-6,52,8);c.quadraticCurveTo(50,-12,40,-26);c.quadraticCurveTo(30,-16,22,-36);c.quadraticCurveTo(10,-18,2,-38);c.quadraticCurveTo(-8,-16,-16,-40);c.quadraticCurveTo(-28,-22,-34,-40);c.quadraticCurveTo(-44,-20,-50,10);c.fill();
 c.translate(-4,0);var br=v.br*6,wo=v.wo;
 // brows: raised for surprise, tilted up in the middle when worried
 c.strokeStyle='#2A282D';c.lineWidth=4.2;c.lineCap='round';c.beginPath();c.moveTo(-36,-14-br+wo*3);c.quadraticCurveTo(-23,-21-br-v.sm,-10,-14-br-wo*6);c.moveTo(10,-14-br-wo*6);c.quadraticCurveTo(23,-21-br-v.sm,36,-14-br+wo*3);c.stroke();
 // eyes
 var bl=this.bl>0,lx=this.look*3.5;[-23,23].forEach(function(ex,i){var shut=bl||(i==1&&v.wk>.5),o=v.ey;if(shut){c.strokeStyle='#2A282D';c.lineWidth=2.6;c.beginPath();c.moveTo(ex-9,1);c.quadraticCurveTo(ex,(i==1&&v.wk>.5&&!bl)?-4:4,ex+9,1);c.stroke();return}
  c.save();c.beginPath();c.moveTo(ex-11,1);c.quadraticCurveTo(ex,-7*o,ex+11,1);c.quadraticCurveTo(ex,5*o,ex-11,1);c.clip();c.fillStyle='#F4EEE8';c.fillRect(ex-12,-10,24,18);c.fillStyle='#2A1A12';c.beginPath();c.arc(ex+1+lx,-.5,o>1.2?4.2:5,0,6.3);c.fill();c.fillStyle='#fff';c.beginPath();c.arc(ex+2.5+lx,-2.2,1.3,0,6.3);c.fill();c.restore();
  c.strokeStyle='#2A282D';c.lineWidth=2.2;c.beginPath();c.moveTo(ex-12,1);c.quadraticCurveTo(ex,-8*o,ex+12,1);c.stroke()});
 c.strokeStyle='rgba(130,76,46,.75)';c.lineWidth=2.4;c.beginPath();c.moveTo(3,-4);c.quadraticCurveTo(10,18,6,24);c.quadraticCurveTo(0,28,-6,24);c.stroke();
 // mouth
 var sm=v.sm,mo=v.mo;if(mo>.08){c.fillStyle='#5A1F1A';c.beginPath();c.moveTo(-16-sm*2,36-sm*2);c.quadraticCurveTo(2,40+sm*3+mo*14,18+sm*2,35-sm*3);c.quadraticCurveTo(2,38+sm,-16-sm*2,36-sm*2);c.fill();if(sm>.8){c.fillStyle='#fff';c.beginPath();c.moveTo(-12,37-sm);c.quadraticCurveTo(2,39+sm,14,36-sm*2);c.lineTo(13,39);c.quadraticCurveTo(2,42,-11,40);c.fill()}}
 else{c.strokeStyle='#6E2E26';c.lineWidth=3.2;c.beginPath();c.moveTo(-18,38-sm*2);c.quadraticCurveTo(2,40+sm*5,20,35-sm*3);c.stroke()}
 c.restore()};
window.Face=Face;
})();
