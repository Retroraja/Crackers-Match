// RetroRaja Games studio intro, carried over from Wordnoid, then the Crackers Match title.
window.runIntro=function(done){
var box=document.getElementById('intro'),fin=false;function end(){if(fin)return;fin=true;box.style.display='none';done()}box.addEventListener('pointerdown',function(){SFX.unlock();end()});
function title(){var t=document.getElementById('ttl'),c=document.getElementById('tcr');document.getElementById('tcrI').src=CRK.b[5];SFX.play('swoosh');SFX.music();setTimeout(function(){SFX.play('thud')},650);setTimeout(function(){SFX.play('sparkler',{cut:.7,v:.7})},1300);setTimeout(function(){c.classList.add('bang');t.classList.add('fl');for(var i=0;i<4;i++)SFX.play('lakshmi',{at:i*.1,rate:.9+i*.05});SFX.play('fanfare',{at:.3})},1950);setTimeout(end,3400)}
var E={outCubic:function(t){return 1-Math.pow(1-t,3)},outBack:function(t){var c=1.7;t-=1;return t*t*((c+1)*t+c)+1}},clamp=function(v,a,b){return Math.min(b,Math.max(a,v))},rnd=function(x){return(Math.random()*2-1)*x},T=0;
function flat(){box.classList.add('flat');SFX.play('brand');setTimeout(function(){box.classList.remove('flat');box.classList.add('titled');title()},2600)}
function go(){try{var cv=document.getElementById('introGL'),w=innerWidth,h=innerHeight,r=new THREE.WebGLRenderer({canvas:cv,antialias:true,alpha:true});r.setPixelRatio(Math.min(devicePixelRatio||1,2));r.setSize(w,h,false);
 var scene=new THREE.Scene(),cam=new THREE.PerspectiveCamera(38,w/h,.1,300);scene.add(new THREE.HemisphereLight(0xffffff,0x1a2a7a,1.5));var sun=new THREE.DirectionalLight(0xffffff,1.1);sun.position.set(3,6,10);scene.add(sun);
  const sweep=new THREE.PointLight(0xffffff,0,26,1);sweep.position.set(-14,1,4);scene.add(sweep);
  const N=600,arr=new Float32Array(N*3);for(let i=0;i<N;i++){arr[i*3]=rnd(140);arr[i*3+1]=rnd(80);arr[i*3+2]=-15-Math.random()*70}
  const sg=new THREE.BufferGeometry();sg.setAttribute('position',new THREE.BufferAttribute(arr,3));
  const stars=new THREE.Points(sg,new THREE.PointsMaterial({color:0xcfe0ff,size:.35,transparent:true,opacity:.85}));scene.add(stars);
  const logo=new THREE.Group();scene.add(logo);const S=.22,vox=[];
  const c=document.createElement('canvas');c.width=48;c.height=20;const x=c.getContext('2d');x.fillStyle='#fff';x.font='8px PS2P,monospace';x.textBaseline='top';
  x.fillText('RETRO',2,1);x.fillText('RAJA',6,11);const data=x.getImageData(0,0,48,20).data;
  const isL=(i,j)=>i>=0&&j>=0&&i<48&&j<20&&data[(j*48+i)*4+3]>110;const bx0=-1,bx1=44,by0=-2,by1=20;
  const tail=(i,j)=>(j===by1+1&&i>=4&&i<=9)||(j===by1+2&&i>=4&&i<=7)||(j===by1+3&&i>=4&&i<=5);
  const inB=(i,j)=>{if(i<bx0||i>bx1||j<by0||j>by1)return tail(i,j);const cx=Math.min(i-bx0,bx1-i),cy=Math.min(j-by0,by1-j);return !(cx<3&&cy<3&&cx+cy<3)};
  for(let j=by0;j<=by1+3;j++)for(let i=bx0;i<=bx1;i++){if(!inB(i,j))continue;const edge=!inB(i-1,j)||!inB(i+1,j)||!inB(i,j-1)||!inB(i,j+1);
    const X=(i-21.5)*S,Y=-(j-9)*S+1.7;vox.push({X,Y,z:0,col:edge?'#9a1c1c':'#e33b3b'});vox.push({X,Y,z:-1,col:'#9a1c1c'});if(isL(i,j))vox.push({X,Y,z:1,col:'#ffffff'})}
  const ctrl=["...BBBBBBBBBBBBBBBB...",".BBBBBBBBBBBBBBBBBBBB.","BBBBDBBBBBBBBBBBBYBBBB","BBBDDDBBBBLLBBBBRBYBBB","BBBBDBBBBBBBBBBBBRBBBB","BBBBBBBBBBBBBBBBBBBBBB","BBBBBBB........BBBBBBB",".BBBBB..........BBBBB."];
  const CC={B:'#2f6fe0',D:'#16295e',Y:'#ffc93c',R:'#e5533d',L:'#9cc8ff'};
  ctrl.forEach((row,j)=>[...row].forEach((ch,i)=>{if(ch==='.')return;const X=(i-10.5)*S+1.4,Y=-2.15-j*S;vox.push({X,Y,z:0,col:CC[ch]});vox.push({X,Y,z:-1,col:ch==='B'?'#1d4fb0':CC[ch]});if('DYRL'.includes(ch))vox.push({X,Y,z:1,col:CC[ch]})}));
  const mat=new THREE.MeshStandardMaterial({roughness:.35,metalness:.08,transparent:true,opacity:1});
  const im=new THREE.InstancedMesh(new THREE.BoxGeometry(S*.93,S*.93,S*.93),mat,vox.length);const col=new THREE.Color();
  vox.forEach((v,k)=>{col.set(v.col);im.setColorAt(k,col);v.t=new THREE.Vector3(v.X,v.Y,v.z*S);v.s=new THREE.Vector3(rnd(1),rnd(1),Math.random()*.8-.2).normalize().multiplyScalar(14+Math.random()*16);
    v.r=[Math.random()*7,Math.random()*7,Math.random()*7];v.d=.15+((v.X+5.5)/11)*.9+Math.random()*.25});
  im.instanceColor.needsUpdate=true;logo.add(im);const dummy=new THREE.Object3D();let settled=false;
  function place(t){if(settled)return;let all=true;vox.forEach((v,k)=>{const k1=clamp((t-v.d)/1.05,0,1);if(k1<1)all=false;const e=E.outCubic(k1);
    dummy.position.lerpVectors(v.s,v.t,e);const r=1-e;dummy.rotation.set(v.r[0]*r,v.r[1]*r,v.r[2]*r);dummy.scale.setScalar(.25+.75*e);dummy.updateMatrix();im.setMatrixAt(k,dummy.matrix)});
    im.instanceMatrix.needsUpdate=true;if(all)settled=true}
  const sparkMat=new THREE.MeshStandardMaterial({color:'#ffd84a',emissive:'#8a6200',roughness:.3,transparent:true});
  const sparks=[[-6.2,3.4],[6.0,4.3],[6.6,-1.6],[-5.6,-2.4],[-2.0,5.0]].map(([sx,sy],i)=>{const g=new THREE.Group();
    [[0,0],[1,0],[-1,0],[0,1],[0,-1],[2,0],[-2,0],[0,2],[0,-2]].forEach(([a,b],n)=>{if(n>4&&i%2)return;const m=new THREE.Mesh(new THREE.BoxGeometry(S*.93,S*.93,S*.93),sparkMat);m.position.set(a*S,b*S,0);g.add(m)});
    g.position.set(sx,sy,.5);g.scale.setScalar(.001);logo.add(g);return g});
 var tn=Math.tan(19*Math.PI/180),fit=Math.max(14/(2*tn*(w/h))/.94,9.5/(2*tn)/.74),cx=6,cy=-3,cz=fit*.5,start=performance.now(),seq={},spin=0,gone=false;SFX.play('brand');
 box.classList.add('live');(function f(){if(fin)return;var q=(performance.now()-start)/1000;place(q);stars.rotation.z+=.0003;var e=Math.min(q/3,1);e=e*e*(3-2*e);cam.position.set(6*(1-e)+Math.sin(q*.5)*.25,-3*(1-e)+.2*e,fit*(.5+.5*e));cam.lookAt(0,.4,0);
  if(q>2.2&&q<3.3){var k=(q-2.2)/1.1;sweep.position.x=-14+28*k;sweep.intensity=Math.sin(k*Math.PI)*90}else sweep.intensity=0;
  sparks.forEach(function(g,i){var u=clamp((q-2.35-i*.13)/.45,0,1);g.scale.setScalar(Math.max(.001,E.outBack(u)));g.rotation.z=q*(i%2?1.5:-1.5)});
  if(settled&&q<4.4){logo.rotation.y=Math.sin(q*1.1)*.12;logo.position.y=Math.sin(q*1.6)*.08}
  if(q>2.6&&!seq.a){seq.a=1;box.classList.add('named')}
  if(q>4.4){var f2=clamp((q-4.4)/.75,0,1);if(!seq.b){seq.b=1;box.classList.remove('named');SFX.play('swoosh')}logo.position.z=f2*f2*12;logo.rotation.y=f2*1.1;mat.opacity=1-f2;sparkMat.opacity=1-f2;if(f2>=1&&!seq.c){seq.c=1;logo.visible=false;box.classList.add('titled');title()}}
  r.render(scene,cam);requestAnimationFrame(f)})();
}catch(err){console.log(err);flat()}}
var ready=window.SFX?SFX.ready():Promise.resolve();Promise.all([ready,document.fonts?document.fonts.load('8px "PS2P"').catch(function(){}):0]).then(go)};
