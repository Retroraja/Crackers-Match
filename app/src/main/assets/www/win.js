(function(){
function ease(t){t=Math.max(0,Math.min(1,t));return t<.5?2*t*t:1-2*(1-t)*(1-t)}
function back(t){t=Math.max(0,Math.min(1,t));var c=1.5;t-=1;return t*t*((c+1)*t+c)+1}
function WinGuy(cv,o){o=o||{};var s=this;this.cv=cv;var d=Math.min(window.devicePixelRatio||1,3);this.W=390;this.H=cv.clientHeight||620;cv.width=this.W*d;cv.height=this.H*d;this.x=cv.getContext('2d');this.x.scale(d,d);this.t=0;this.conf=[];this.last=performance.now();this.diya=new Image();if(o.diya)this.diya.src=o.diya;
 requestAnimationFrame(function f(n){if(s.stopped)return;var dt=Math.min((n-s.last)/1000,.04);s.last=n;s.t+=dt;if(s.t>5&&!s.once)s.replay();s.draw(dt);requestAnimationFrame(f)})}
var P=WinGuy.prototype;
P.replay=function(){this.t=0;this.conf=[];this.fired=false};
P.ik=function(S,H,a,b,sign){var dx=H[0]-S[0],dy=H[1]-S[1],d=Math.min(Math.sqrt(dx*dx+dy*dy),a+b-1),base=Math.atan2(dy,dx),c=Math.acos(Math.max(-1,Math.min(1,(a*a+d*d-b*b)/(2*a*d))));var ang=base+sign*c;return[S[0]+Math.cos(ang)*a,S[1]+Math.sin(ang)*a]};
P.limb=function(a,b,w1,w2,col){var c=this.x,an=Math.atan2(b[1]-a[1],b[0]-a[0]),nx=-Math.sin(an),ny=Math.cos(an);c.fillStyle=col;c.beginPath();c.moveTo(a[0]+nx*w1,a[1]+ny*w1);c.lineTo(b[0]+nx*w2,b[1]+ny*w2);c.arc(b[0],b[1],w2,an+1.57,an-1.57,true);c.lineTo(a[0]-nx*w1,a[1]-ny*w1);c.arc(a[0],a[1],w1,an-1.57,an+1.57,true);c.closePath();c.fill()};
P.hand=function(H,an,open){var c=this.x;c.save();c.translate(H[0],H[1]);c.rotate(an);var skin='#C98A5E',dk='#A96C45';c.fillStyle='#FFFFFF';c.beginPath();c.roundRect(-16,-15,13,30,5);c.fill(); c.fillStyle=skin;c.beginPath();c.roundRect(-2,-15,32,30,12);c.fill();[-11,-3.5,4,11].forEach(function(y,i){var L=[30,34,32,26][i];c.strokeStyle=i%2?dk:skin;c.lineWidth=8.2;c.lineCap='round';c.strokeStyle=skin;c.beginPath();c.moveTo(25,y*.9);c.lineTo(25+L*.82,y*(1+open*.25));c.stroke();c.strokeStyle='rgba(120,70,40,.28)';c.lineWidth=1;c.beginPath();c.moveTo(27,y*.9+4);c.lineTo(23+L*.82,y*(1+open*.25)+4);c.stroke()});
 c.strokeStyle=skin;c.lineWidth=9;c.beginPath();c.moveTo(6,12);c.lineTo(24,26);c.stroke();c.restore()};
P.head=function(x,y,tilt,blink,smile){var c=this.x;c.save();c.translate(x,y);c.rotate(tilt);
 var ng=c.createLinearGradient(0,30,0,80);ng.addColorStop(0,'#A9704A');ng.addColorStop(1,'#C48A60');c.fillStyle=ng;c.beginPath();c.roundRect(-22,30,44,50,12);c.fill();
 var fg=c.createLinearGradient(-50,0,50,0);fg.addColorStop(0,'#D9A27A');fg.addColorStop(.6,'#D19668');fg.addColorStop(1,'#B57B52');c.fillStyle='#BC8359';c.beginPath();c.ellipse(-49,6,7,14,0,0,6.3);c.ellipse(49,6,7,14,0,0,6.3);c.fill();
 c.fillStyle=fg;c.beginPath();c.moveTo(-47,-26);c.bezierCurveTo(-49,14,-44,38,-27,53);c.quadraticCurveTo(-10,66,0,66);c.quadraticCurveTo(10,66,27,53);c.bezierCurveTo(44,38,49,14,47,-26);c.bezierCurveTo(38,-60,-38,-60,-47,-26);c.fill();
 // stubble
 var st=c.createLinearGradient(0,20,0,66);st.addColorStop(0,'rgba(70,60,60,0)');st.addColorStop(1,'rgba(70,62,66,.42)');c.fillStyle=st;c.beginPath();c.moveTo(-44,16);c.bezierCurveTo(-42,36,-27,53,-27,53);c.quadraticCurveTo(-10,66,0,66);c.quadraticCurveTo(10,66,27,53);c.bezierCurveTo(40,38,44,16,44,16);c.quadraticCurveTo(0,44,-44,16);c.fill();
 // hair
 var hg=c.createLinearGradient(-46,-8,34,-96);hg.addColorStop(0,'#17161B');hg.addColorStop(.5,'#34333B');hg.addColorStop(.82,'#83858F');hg.addColorStop(1,'#BDBFC8');c.fillStyle=hg;c.beginPath();c.moveTo(-50,10);c.quadraticCurveTo(-66,-14,-54,-34);c.quadraticCurveTo(-74,-56,-46,-66);c.quadraticCurveTo(-52,-92,-20,-84);c.quadraticCurveTo(-12,-110,14,-92);c.quadraticCurveTo(38,-106,44,-80);c.quadraticCurveTo(70,-78,60,-52);c.quadraticCurveTo(76,-34,56,-20);c.quadraticCurveTo(60,-6,52,8);c.quadraticCurveTo(50,-12,40,-26);c.quadraticCurveTo(30,-16,22,-36);c.quadraticCurveTo(10,-18,2,-38);c.quadraticCurveTo(-8,-16,-16,-40);c.quadraticCurveTo(-28,-22,-34,-40);c.quadraticCurveTo(-44,-20,-50,10);c.fill();
 c.lineCap='round';[[-40,-34,-30,-76],[-24,-40,-6,-90],[-6,-42,14,-86],[10,-40,34,-84],[26,-36,52,-62],[-48,-8,-52,-44],[42,-24,60,-34]].forEach(function(l,i){c.strokeStyle='rgba(216,218,226,'+(.5+(i%3)*.15)+')';c.lineWidth=2.1;c.beginPath();c.moveTo(l[0],l[1]);c.quadraticCurveTo((l[0]+l[2])/2+(i%2?10:-10),(l[1]+l[3])/2,l[2],l[3]);c.stroke()});
 c.save();c.translate(-7,0);
 // brows
 c.strokeStyle='#2A282D';c.lineWidth=4.2;c.beginPath();c.moveTo(-36,-14);c.quadraticCurveTo(-23,-21-smile*2,-10,-14);c.moveTo(10,-14);c.quadraticCurveTo(23,-21-smile*2,36,-14);c.stroke();
 // eyes
 if(blink){c.strokeStyle='#2A282D';c.lineWidth=2.6;c.beginPath();c.moveTo(-32,1);c.quadraticCurveTo(-23,4,-14,1);c.moveTo(14,1);c.quadraticCurveTo(23,4,32,1);c.stroke()}else{[-23,23].forEach(function(ex){c.save();c.beginPath();c.moveTo(ex-11,1);c.quadraticCurveTo(ex,-7,ex+11,1);c.quadraticCurveTo(ex,5,ex-11,1);c.clip();c.fillStyle='#F4EEE8';c.fillRect(ex-12,-8,24,14);c.fillStyle='#2A1A12';c.beginPath();c.arc(ex+1,-.5,5,0,6.3);c.fill();c.restore();c.strokeStyle='#2A282D';c.lineWidth=2.2;c.beginPath();c.moveTo(ex-12,1);c.quadraticCurveTo(ex,-8,ex+12,1);c.stroke()})}
 // nose
 c.strokeStyle='rgba(130,76,46,.75)';c.lineWidth=2.4;c.beginPath();c.moveTo(3,-4);c.quadraticCurveTo(10,18,6,24);c.quadraticCurveTo(0,28,-6,24);c.stroke();
 // mouth: confident closed smile
 c.strokeStyle='#6E2E26';c.lineWidth=3.2;c.beginPath();c.moveTo(-18,38-smile*2);c.quadraticCurveTo(2,46+smile*3,20,35-smile*3);c.stroke();
 c.restore();c.restore()};
P.draw=function(dt){var c=this.x,t=this.t,s=this,W=this.W,H=this.H-44;c.clearRect(0,0,W,this.H);
var cx=226,oy=0,swp=back((t-.7)/.36),bob=0,lean=-.1,base=[cx,H+40+oy];
 var sh=[cx-76,H-200+oy+bob],sh2=[cx+90,H-204+oy+bob];var C='#2B2A33',C2='#3A3944',C3='#1E1D24';
 if(t>.94&&!this.fired){this.fired=true;var cols=['#FF2FA8','#FFC62B','#1E5BFF','#0DB865','#FF6A00'];for(var i=0;i<90;i++){var a=-1.57+(Math.random()-.5)*2.8,v=260+Math.random()*420;this.conf.push({x:cx-140+Math.random()*30,y:H-90,vx:Math.cos(a)*v-60,vy:Math.sin(a)*v,r:Math.random()*6,vr:Math.random()*12-6,col:cols[i%5],w:6+Math.random()*7,h:4+Math.random()*5})}}
 this.conf=this.conf.filter(function(f){f.vy+=520*dt;f.vx*=.99;f.x+=f.vx*dt;f.y+=f.vy*dt;f.r+=f.vr*dt;if(f.y>H+20)return false;c.save();c.translate(f.x,f.y);c.rotate(f.r);c.scale(1,Math.abs(Math.cos(f.r*2))+.2);c.fillStyle=f.col;c.fillRect(-f.w/2,-f.h/2,f.w,f.h);c.restore();return true});
 c.save();c.translate(cx,H+70);c.scale(1.2,1.2);c.translate(-cx,-(H+70));c.translate(base[0],base[1]);c.rotate(lean);c.translate(-base[0],-base[1]);
 var Y=function(v){return H+v+oy+bob};
 // fitted coat
 var cg='#2C2B34';c.fillStyle=cg;c.beginPath();c.moveTo(cx-72,H+60+oy);c.lineTo(cx-62,Y(-80));c.bezierCurveTo(cx-64,Y(-120),cx-78,Y(-160),cx-84,Y(-182));c.bezierCurveTo(cx-100,Y(-212),cx-60,Y(-226),cx-34,Y(-236));c.lineTo(cx+34,Y(-236));c.bezierCurveTo(cx+60,Y(-226),cx+86,Y(-218),cx+92,Y(-186));c.bezierCurveTo(cx+84,Y(-140),cx+66,Y(-110),cx+62,Y(-80));c.lineTo(cx+72,H+60+oy);c.closePath();c.fill();
 c.save();c.translate(-7,0);c.fillStyle='#F2F3F7';c.beginPath();c.moveTo(cx-30,Y(-236));c.lineTo(cx+30,Y(-236));c.lineTo(cx+4,Y(-96));c.lineTo(cx-4,Y(-96));c.closePath();c.fill();
 c.fillStyle='#D5D6DF';c.beginPath();c.moveTo(cx-27,Y(-238));c.lineTo(cx-1,Y(-200));c.lineTo(cx-34,Y(-186));c.closePath();c.moveTo(cx+27,Y(-238));c.lineTo(cx+1,Y(-200));c.lineTo(cx+34,Y(-186));c.closePath();c.fill();
 c.fillStyle=C2;c.beginPath();c.moveTo(cx-36,Y(-238));c.lineTo(cx-62,Y(-160));c.lineTo(cx-38,Y(-146));c.lineTo(cx-50,Y(-130));c.lineTo(cx-3,Y(-92));c.closePath();c.moveTo(cx+36,Y(-238));c.lineTo(cx+62,Y(-160));c.lineTo(cx+38,Y(-146));c.lineTo(cx+50,Y(-130));c.lineTo(cx+3,Y(-92));c.closePath();c.fill();
 c.strokeStyle='#17161B';c.lineWidth=2;c.beginPath();c.moveTo(cx,Y(-92));c.lineTo(cx-6,H+60+oy);c.stroke();c.fillStyle='#F4C542';c.beginPath();c.arc(cx-2,Y(-70),4,0,6.3);c.fill();
 c.fillStyle='#FF2FA8';c.beginPath();c.moveTo(cx+72,Y(-146));c.lineTo(cx+40,Y(-152));c.lineTo(cx+42,Y(-140));c.lineTo(cx+70,Y(-134));c.closePath();c.fill();
 c.restore();
 c.fillStyle=cg;c.beginPath();c.moveTo(cx+44,Y(-232));c.bezierCurveTo(cx+92,Y(-228),cx+118,Y(-206),cx+120,Y(-168));c.bezierCurveTo(cx+122,Y(-120),cx+112,Y(-78),cx+104,Y(-34));c.lineTo(cx+72,Y(-32));c.bezierCurveTo(cx+74,Y(-80),cx+72,Y(-120),cx+64,Y(-156));c.closePath();c.fill();
 c.strokeStyle='#17161B';c.lineWidth=2;c.beginPath();c.moveTo(cx+64,Y(-156));c.bezierCurveTo(cx+72,Y(-120),cx+74,Y(-80),cx+72,Y(-32));c.stroke();
 c.save();c.translate(cx+88,Y(-28));c.rotate(1.57);c.fillStyle='#FFFFFF';c.beginPath();c.roundRect(-10,-19,10,38,4);c.fill();c.restore();this.hand([cx+88,Y(-24)],1.57,0);
 this.head(cx-10,H-310+oy+bob,.1,false,1);
 // gesture arm (screen right): top left, across, to bottom right
 var u=Math.max(0,Math.min(1,(t-.7)/.42));u=u<.5?2*u*u:1-2*(1-u)*(1-u);var q=function(p0,p1,p2){var k=2*p1-.5*(p0+p2);return(1-u)*(1-u)*p0+2*u*(1-u)*k+u*u*p2};
 var a1=q(.9,2.6,2.02),a2=q(-1,.25,1.88),L=88,E=[sh[0]+Math.cos(a1)*L,sh[1]+Math.sin(a1)*L],Hh=[E[0]+Math.cos(a2)*L,E[1]+Math.sin(a2)*L];this.limb(sh,E,27,25,cg);this.limb(E,Hh,25,19,cg);c.strokeStyle='#17161B';c.lineWidth=2;c.beginPath();c.moveTo(sh[0]+Math.cos(a1-1.57)*27,sh[1]+Math.sin(a1-1.57)*27);c.lineTo(E[0]+Math.cos(a2-1.57)*24,E[1]+Math.sin(a2-1.57)*24);c.stroke();this.hand(Hh,a2,.5+u*.5);
 c.restore();
 // diyas
 [0,1,2].forEach(function(i){var q=back((t-1.35-i*.22)/.3);if(q<=0)return;var sz=78*q,x=112+i*83;if(s.diya.complete&&s.diya.naturalWidth){c.drawImage(s.diya,x-sz/2,150-sz*.4+(i==1?-14:0),sz,sz*s.diya.naturalHeight/s.diya.naturalWidth)}})};
window.WinGuy=WinGuy;
})();
