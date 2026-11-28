// Build 28: the suit man (his Viggle clip) replaces the drawn man on the win screen and the drawn face in the level badge
(function(){
var SHEET=new Image();SHEET.src='art/man-video.webp';var HEAD=new Image();HEAD.src='art/head-side.webp';
var CW=456,CH=544,COLS=6,NF=24,FPS=30,MX=5,MY=256,SC=.66,START=.55,D=NF/FPS,OUT=.7,BACK=D*1.4;
function WinGuy(cv,o){var s=this;this.cv=cv;var d=Math.min(window.devicePixelRatio||1,3);this.W=390;this.H=cv.clientHeight||620;cv.width=this.W*d;cv.height=this.H*d;this.x=cv.getContext('2d');this.x.scale(d,d);this.t=0;this.last=performance.now();
 var st=document.getElementById('stage'),a=cv.getBoundingClientRect(),b=st.getBoundingClientRect(),k=b.width/390||1;this.ox=(a.left-b.left)/k;this.oy=(a.top-b.top)/k;this.kx=(a.width/k)/this.W||1;
 requestAnimationFrame(function f(n){if(s.dead)return;var dt=Math.min((n-s.last)/1000,.04);s.last=n;s.t+=dt;s.draw();requestAnimationFrame(f)})}
WinGuy.prototype.draw=function(){var c=this.x,u=this.t-START,f=0;c.clearRect(0,0,this.W,this.H);if(!SHEET.complete||!SHEET.naturalWidth)return;
 if(u>0){if(u<D)f=Math.floor(u*FPS);else if(u<D+OUT)f=NF-1;else if(u<D+OUT+BACK)f=NF-1-Math.floor((u-D-OUT)/BACK*NF);else f=0}f=Math.max(0,Math.min(NF-1,f));
 var p=Math.min(this.t/.5,1),e=1+2.2*Math.pow(p-1,3)+1.2*Math.pow(p-1,2),sc=.8+.2*e,bob=u>D+OUT+BACK?Math.sin((u-D-OUT-BACK)*2.2)*1.2:0,px=212,py=594;
 c.save();c.scale(1/this.kx,1/this.kx);c.translate(-this.ox,-this.oy);c.globalAlpha=Math.min(1,p*1.6);c.translate(px,py+70*(1-e));c.scale(sc,sc);c.translate(-px,-py);c.imageSmoothingQuality='high';
 c.drawImage(SHEET,(f%COLS)*CW,Math.floor(f/COLS)*CH,CW,CH,MX,MY+bob,CW*SC,CH*SC);c.restore()};
WinGuy.prototype.replay=function(){this.t=0};
window.WinGuy=WinGuy;

// level badge: side-facing head, same mood names as the old face
function Face(cv){var s=this;this.cv=cv;var d=Math.min(window.devicePixelRatio||1,3);this.W=cv.clientWidth||76;this.H=cv.clientHeight||88;cv.width=this.W*d;cv.height=this.H*d;this.x=cv.getContext('2d');this.x.scale(d,d);this.m='idle';this.mt=0;this.t=0;this.base='idle';this.last=performance.now();
 requestAnimationFrame(function f(n){var dt=Math.min((n-s.last)/1000,.04);s.last=n;s.t+=dt;if(s.mt>0){s.mt-=dt;s.mT=(s.mT||0)+dt;if(s.mt<=0){s.m=s.base}}s.draw();requestAnimationFrame(f)})}
var M={idle:1,smile:1,wow:1,grin:1,cheer:1,worried:1,calm:1};
Face.prototype.mood=function(m,hold){if(!M[m])return;if(m=='worried')this.base='worried';this.m=m;this.mt=hold||1.4;this.mT=0};
Face.prototype.calm=function(){this.base='idle';if(this.m=='worried')this.m='idle'};
function star(c,x,y,r,a){c.save();c.translate(x,y);c.rotate(a||0);c.beginPath();for(var i=0;i<10;i++){var rr=i%2?r*.45:r,an=i*Math.PI/5-Math.PI/2;c.lineTo(Math.cos(an)*rr,Math.sin(an)*rr)}c.closePath();c.fillStyle='#FFD24A';c.fill();c.strokeStyle='#8A4E08';c.lineWidth=1.5;c.stroke();c.restore()}
Face.prototype.draw=function(){var c=this.x,W=this.W,H=this.H,m=this.m,k=this.mT||0,dx=0,dy=0,rot=0,sc=1;c.clearRect(0,0,W,H);if(!HEAD.complete||!HEAD.naturalWidth)return;
 if(m=='smile'){rot=Math.sin(k*9)*.06*Math.max(0,1-k)}else if(m=='wow'){dy=-Math.abs(Math.sin(k*7))*8*Math.max(0,1-k/1.2);sc=1+.06*Math.max(0,1-k)}else if(m=='grin'){rot=Math.sin(k*16)*.08*Math.max(0,1-k/1.2)}else if(m=='cheer'){dy=-Math.abs(Math.sin(k*6.3))*10*(k<2?1:0)}else if(m=='worried'){dx=Math.sin(this.t*22)*1.6}else{dy=Math.sin(this.t*2)*.8}
 var w=Math.min(W/540*1.05,H/702*1.05)*540,h=w*702/540;c.save();c.translate(W/2+dx,H*.56+dy);c.rotate(rot);c.scale(sc,sc);c.drawImage(HEAD,-w/2,-h/2,w,h);c.restore();
 if(m=='wow'&&k<1.2){c.font='bold 22px Titan,sans-serif';c.fillStyle='#FFD24A';c.strokeStyle='#3A0700';c.lineWidth=4;c.strokeText('!',W*.82,H*.3);c.fillText('!',W*.82,H*.3)}
 if(m=='grin'&&k<1.2)star(c,W*.82,H*.25,8,k*3);
 if(m=='cheer'&&k<2){star(c,W*.18,H*.2-k*4,6,k*2);star(c,W*.5,H*.1-k*4,7,-k*2);star(c,W*.82,H*.2-k*4,6,k*3)}
 if(m=='worried'){c.fillStyle='#7FD1FF';c.beginPath();var sx=W*.8,sy=H*.3+(this.t*20%10);c.moveTo(sx,sy-7);c.quadraticCurveTo(sx+6,sy+2,sx,sy+5);c.quadraticCurveTo(sx-6,sy+2,sx,sy-7);c.fill()}};
window.Face=Face;
})();
