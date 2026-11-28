// Painted village scene with gentle life: clouds, birds, smoke, petals, water glints, butterflies, windmill, sun rays.
// Image coordinates are in the 840x1050 painting.
(function(){
var SC={1:{src:'art/scene1.webp',px:.7,chim:[682,206],win:[[563,372],[483,402],[707,507],[545,505]],tree:[[330,330],[470,450]],petal:['#FF9EC4','#FFC4DA','#FFFFFF'],water:[[195,515,130,25],[190,630,60,120],[195,770,100,40]],fly:[[230,520],[640,640]],bf:[['#FFB020','#FF7A00'],['#7FC8FF','#3D7BFF']]},
        2:{src:'art/scene2.webp',px:.5,chim:[627,250],win:[[538,377],[682,387],[497,502],[692,512]],tree:[[200,420],[460,560]],petal:['#FF7FB0','#B98CFF','#FFD84A','#FFFFFF'],water:[[200,520,80,30],[200,665,190,120]],wm:[202,252],fly:[[230,430],[640,640]],bf:[['#FFE04A','#FFA800'],['#FF8FC8','#C04FD9']]}};
var IMG=[1,2,1,2,1];window.SCENE_IMG=function(ch){return IMG[(ch-1)%IMG.length]};window.SCENE_SRC=function(ch){return SC[SCENE_IMG(ch)].src};
function rnd(a,b){return a+Math.random()*(b-a)}
window.Scene=function(root,o){o=o||{};var me=this;root.classList.add('scn');
 root.innerHTML='<div class="sc a"></div><div class="sc b"></div><canvas class="sfx" aria-hidden="true"></canvas><img class="cloud c1" alt="" src="art/cloud.webp"><img class="cloud c2" alt="" src="art/cloud.webp">';
 var L=[root.querySelector('.sc.a'),root.querySelector('.sc.b')],cv=root.querySelector('canvas'),fc=cv.getContext('2d'),front=0,img=0,pan=0,run=false,raf=0;
 var W=0,H=0,K=1,OX=0,OY=0,dpr=Math.min(devicePixelRatio||1,2),smoke=[],petals=[],glints=[],birds=[],BF=[{ph:0},{ph:2.7}],wmA=0,tS=0,tP=0,tG=0,tB=1.2,fade=1,lastT=0,shown=0;
 function size(){W=root.clientWidth||390;H=root.clientHeight||844;cv.width=W*dpr;cv.height=H*dpr;var c=SC[shown||1];K=Math.max(W/840,H/1050);OX=(W-840*K)*c.px;OY=(H-1050*K)*.3}
 function P(x,y){return[OX+x*K,OY+y*K]}
 function tf(){var t='scale(1.14) translateX('+pan+'%)';L[0].style.transform=L[1].style.transform=cv.style.transform=t}
 me.set=function(ch,instant){var n=SCENE_IMG(ch);if(n==img)return;img=n;var c=SC[n],nx=instant?front:1-front;L[nx].style.backgroundImage='url('+c.src+')';L[nx].style.backgroundPosition=(c.px*100)+'% 30%';if(instant){L[nx].style.opacity=1;L[1-nx].style.opacity=0;shown=n;size()}else{L[nx].style.opacity=1;L[1-nx].style.opacity=0;front=nx}};
 me.pan=function(p){pan=p;tf()};
 me.start=function(){if(run)return;run=true;size();lastT=0;raf=requestAnimationFrame(step)};
 me.stop=function(){run=false;cancelAnimationFrame(raf)};
 addEventListener('resize',function(){if(run)size()});
 function step(t){if(!run)return;var dt=Math.min((t-lastT)/1000||0,.05);lastT=t;
  if(shown!=img){fade-=dt*2.5;if(fade<=0){shown=img;size();smoke=[];petals=[];glints=[];fade=0}}else if(fade<1)fade=Math.min(1,fade+dt*1.5);
  var c=SC[shown||img];if(!c){raf=requestAnimationFrame(step);return}
  tS-=dt;if(c.chim&&tS<=0){tS=rnd(.55,.8);smoke.push({x:c.chim[0]+rnd(-3,3),y:c.chim[1],r:rnd(6,9),life:0,max:rnd(4.5,6)})}
  tP-=dt;if(tP<=0){tP=rnd(.7,1.2);if(petals.length<10){var b=c.tree;petals.push({x:rnd(b[0][0],b[1][0]),y:rnd(b[0][1],b[1][1]),vx:rnd(6,16),vy:rnd(10,18),rot:rnd(0,6),vr:rnd(-2,2),ph:rnd(0,6),col:c.petal[Math.random()*c.petal.length|0],life:0,max:rnd(7,10),s:rnd(8,11)})}}
  tG-=dt;if(tG<=0){tG=rnd(.18,.4);var w=c.water[Math.random()*c.water.length|0];glints.push({x:w[0]+rnd(0,w[2]),y:w[1]+rnd(0,w[3]),life:0,max:rnd(.7,1.1),s:rnd(8,12)})}
  tB-=dt;if(tB<=0){tB=rnd(9,14);var dir=Math.random()<.5?1:-1,n=2+(Math.random()*2|0),y0=rnd(230,360),v=rnd(55,70);for(var i=0;i<n;i++)birds.push({x:dir>0?120-i*rnd(22,34):720+i*rnd(22,34),y:y0+i*rnd(-12,14),v:v*dir,ph:rnd(0,6),s:rnd(13,16)})}
  fc.setTransform(dpr,0,0,dpr,0,0);fc.clearRect(0,0,W,H);fc.globalAlpha=1;
  var sx=W*.96,sy=-H*.04;fc.save();fc.globalCompositeOperation='lighter';
  var gl=fc.createRadialGradient(sx,sy,0,sx,sy,W*.55),ga=.32+.08*Math.sin(t/1700);gl.addColorStop(0,'rgba(255,240,190,'+ga+')');gl.addColorStop(1,'rgba(255,240,190,0)');fc.fillStyle=gl;fc.fillRect(0,0,W,H);
  for(var i=0;i<4;i++){var an=2.05+i*.17+Math.sin(t/4200+i*1.7)*.03,len=H*.85,wd=.05+.015*Math.sin(t/3100+i),a=.16+.07*Math.sin(t/2300+i*2.1),gr=fc.createLinearGradient(sx,sy,sx+Math.cos(an)*len,sy+Math.sin(an)*len);gr.addColorStop(0,'rgba(255,248,215,'+a+')');gr.addColorStop(1,'rgba(255,248,215,0)');fc.fillStyle=gr;fc.beginPath();fc.moveTo(sx,sy);fc.lineTo(sx+Math.cos(an-wd)*len,sy+Math.sin(an-wd)*len);fc.lineTo(sx+Math.cos(an+wd)*len,sy+Math.sin(an+wd)*len);fc.closePath();fc.fill()}
  c.win.forEach(function(w,i){var q=P(w[0],w[1]),r=26*K,a=(.28+.08*Math.sin(t/430+i*1.9)+.05*Math.sin(t/170+i))*fade,g=fc.createRadialGradient(q[0],q[1],0,q[0],q[1],r);g.addColorStop(0,'rgba(255,200,90,'+a+')');g.addColorStop(1,'rgba(255,160,40,0)');fc.fillStyle=g;fc.beginPath();fc.arc(q[0],q[1],r,0,6.3);fc.fill()});fc.restore();
  if(c.wm){wmA+=dt*.45;var h=P(c.wm[0],c.wm[1]);fc.save();fc.globalAlpha=fade;fc.translate(h[0],h[1]);fc.scale(K,K);fc.rotate(wmA);
   for(i=0;i<4;i++){fc.save();fc.rotate(i*Math.PI/2);fc.strokeStyle='#8A4A1E';fc.lineWidth=5;fc.beginPath();fc.moveTo(0,0);fc.lineTo(0,-102);fc.stroke();fc.fillStyle='rgba(255,255,255,.18)';fc.fillRect(3,-100,30,82);fc.strokeStyle='#C77A38';fc.lineWidth=4;fc.strokeRect(3,-100,30,82);fc.lineWidth=2.4;fc.beginPath();fc.moveTo(18,-100);fc.lineTo(18,-18);for(var k=1;k<4;k++){var yk=-100+k*20.5;fc.moveTo(3,yk);fc.lineTo(33,yk)}fc.stroke();fc.restore()}
   fc.fillStyle='#8A4A1E';fc.beginPath();fc.arc(0,0,10,0,6.3);fc.fill();fc.fillStyle='#D9934F';fc.beginPath();fc.arc(0,0,5.5,0,6.3);fc.fill();fc.restore()}
  BF.forEach(function(b,i){var f=c.fly,cx=(f[0][0]+f[1][0])/2,cy=(f[0][1]+f[1][1])/2,rx=(f[1][0]-f[0][0])/2,ry=(f[1][1]-f[0][1])/2,tt=t/1000*.22+b.ph,x=cx+Math.sin(tt*1.3)*rx*.9+Math.sin(tt*3.1)*12,y=cy+Math.sin(tt*2.1+1)*ry*.8+Math.sin(tt*5)*6,q=P(x,y),dx=Math.cos(tt*1.3)*1.3+Math.cos(tt*3.1)*.3,fl=.35+.65*Math.abs(Math.sin(t/70+i*2)),s=15*K,col=c.bf[i];
   fc.save();fc.globalAlpha=fade;fc.translate(q[0],q[1]);if(dx<0)fc.scale(-1,1);fc.rotate(-.25);fc.fillStyle=col[0];fc.beginPath();fc.ellipse(-s*.55*fl,-s*.35,s*.62*fl,s*.5,-.5,0,6.3);fc.fill();fc.beginPath();fc.ellipse(s*.55*fl,-s*.35,s*.62*fl,s*.5,.5,0,6.3);fc.fill();fc.fillStyle=col[1];fc.beginPath();fc.ellipse(-s*.4*fl,s*.25,s*.42*fl,s*.34,.4,0,6.3);fc.fill();fc.beginPath();fc.ellipse(s*.4*fl,s*.25,s*.42*fl,s*.34,-.4,0,6.3);fc.fill();fc.fillStyle='#3A2A20';fc.fillRect(-s*.07,-s*.55,s*.14,s*1.05);fc.restore()});
  smoke=smoke.filter(function(p){p.life+=dt;return p.life<p.max});
  smoke.forEach(function(p){var k=p.life/p.max,q=P(p.x-k*34+Math.sin(p.life*1.3)*3,p.y+6-k*85),r=(p.r+6+k*36)*K,a=Math.min(1,p.life*4)*Math.pow(1-k,1.3)*.85*fade,g=fc.createRadialGradient(q[0]-r*.25,q[1]-r*.3,0,q[0],q[1],r);g.addColorStop(0,'rgba(236,238,244,'+a+')');g.addColorStop(.55,'rgba(188,193,208,'+a*.9+')');g.addColorStop(1,'rgba(170,176,192,0)');fc.fillStyle=g;fc.beginPath();fc.arc(q[0],q[1],r,0,6.3);fc.fill()});
  petals=petals.filter(function(p){p.life+=dt;return p.life<p.max});
  petals.forEach(function(p){p.x+=(p.vx+Math.sin(p.life*1.6+p.ph)*10)*dt;p.y+=p.vy*dt;p.rot+=p.vr*dt;var k=p.life/p.max,a=Math.min(1,p.life*2)*Math.min(1,(1-k)*3)*fade,q=P(p.x,p.y);fc.save();fc.translate(q[0],q[1]);fc.rotate(p.rot);fc.scale(1,Math.abs(Math.cos(p.life*2+p.ph))*.6+.4);fc.globalAlpha=a*.95;fc.fillStyle=p.col;fc.beginPath();fc.ellipse(0,0,p.s*K,p.s*.6*K,0,0,6.3);fc.fill();fc.restore()});
  glints=glints.filter(function(p){p.life+=dt;return p.life<p.max});
  glints.forEach(function(p){var k=p.life/p.max,a=Math.sin(k*Math.PI)*.9*fade,q=P(p.x,p.y),r=p.s*K*(.6+k*.6);fc.globalAlpha=a;fc.fillStyle='#fff';fc.beginPath();fc.moveTo(q[0]-r*1.4,q[1]);fc.quadraticCurveTo(q[0],q[1],q[0],q[1]-r);fc.quadraticCurveTo(q[0],q[1],q[0]+r*1.4,q[1]);fc.quadraticCurveTo(q[0],q[1],q[0],q[1]+r);fc.quadraticCurveTo(q[0],q[1],q[0]-r*1.4,q[1]);fc.fill()});
  fc.globalAlpha=.75;fc.strokeStyle='#2B3550';fc.lineCap='round';fc.lineJoin='round';
  birds=birds.filter(function(b){b.x+=b.v*dt;b.y+=Math.sin(t/900+b.ph)*.06;return b.x>60&&b.x<780});
  birds.forEach(function(b){var q=P(b.x,b.y),w=b.s*K,f=Math.sin(t/160+b.ph)*.7;fc.lineWidth=Math.max(1.2,K*1.4);fc.beginPath();fc.moveTo(q[0]-w,q[1]-w*f*.6);fc.quadraticCurveTo(q[0]-w*.4,q[1]-w*.25,q[0],q[1]);fc.quadraticCurveTo(q[0]+w*.4,q[1]-w*.25,q[0]+w,q[1]-w*f*.6);fc.stroke()});
  fc.globalAlpha=1;raf=requestAnimationFrame(step)}
 me.set(o.ch||1,true);tf();
};
})();
