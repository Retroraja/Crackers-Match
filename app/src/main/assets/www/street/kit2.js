// Loads the packed kits (Medieval Village, Fantasy Props, Stylized Nature, Halloween Bits) (art/models.json + art/models.bin) into three.js
const KIT={geo:{},mat:{},ready:null};
(function(){
 const TL=new THREE.TextureLoader();
 function tex(n,srgb){const t=TL.load('art/'+n+'.webp');t.flipY=false;t.wrapS=t.wrapT=THREE.RepeatWrapping;t.anisotropy=8;if(srgb)t.encoding=THREE.sRGBEncoding;return t}
 function std(base,normal,o){return new THREE.MeshStandardMaterial(Object.assign({map:tex(base,1),normalMap:normal?tex(normal):null,roughness:.85,metalness:0,side:THREE.DoubleSide},o||{}))}
 KIT.vc={};
 KIT.mat={
  MI_Plaster:std('T_Plaster_BaseColor','T_Plaster_Normal'),MI_WoodTrim:std('T_WoodTrim_BaseColor','T_WoodTrim_Normal',{roughness:.75}),
  MI_UnevenBrick:std('T_UnevenBrick_BaseColor','T_UnevenBrick_Normal'),MI_RoundTiles:std('T_RoundTiles_BaseColor','T_RoundTiles_Normal',{roughness:.7}),
  MI_RockTrim:std('T_RockTrim_BaseColor','T_RockTrim_Normal'),MI_Brick:std('T_Brick_BaseColor','T_Brick_Normal'),MI_RedBrick:std('T_RedBrick_BaseColor','T_Brick_Normal'),
  MI_WindowGlass:new THREE.MeshStandardMaterial({color:0xbfe0ff,transparent:true,opacity:.35,roughness:.1,metalness:.2,side:THREE.DoubleSide}),
  MI_MetalOrnaments:new THREE.MeshStandardMaterial({color:0x2a2a30,roughness:.45,metalness:.8,side:THREE.DoubleSide}),
  MI_Vine:new THREE.MeshStandardMaterial({map:tex('T_VineLeaf',1),color:0x7fbf4a,alphaTest:.5,side:THREE.DoubleSide,roughness:.8})};
 KIT.mat.MI_WoodTrim_Wear=KIT.mat.MI_WoodTrim;
 const cl=std('T_Trim_Cloth_BaseColor','T_Trim_Cloth_Normal'),fu=std('T_Trim_Furniture_BaseColor','T_Trim_Furniture_Normal',{roughness:.75}),me=std('T_Trim_Metal_BaseColor','T_Trim_Metal_Normal',{roughness:.5,metalness:.5}),pr=std('T_Trim_Props_BaseColor','T_Trim_Props_Normal',{roughness:.7});
 Object.assign(KIT.mat,{MI_Banner:cl,MI_Trim_Cloth:cl,MI_Trim_Furniture:fu,MI_Trim_Metal:me,MI_Trim_Metal_Vertex:me,MI_Trim_Props:pr,MI_Trim_Props_Vertex:pr,MI_Page_Empty:std('T_Page_Noise'),
  Bark_DeadTree:std('Bark_DeadTree','Bark_DeadTree_Normal'),Bark_NormalTree:std('Bark_NormalTree','Bark_NormalTree_Normal'),Bark_TwistedTree:std('Bark_TwistedTree','Bark_TwistedTree_Normal'),
  Flowers:std('Flowers',null,{alphaTest:.5}),Grass:std('Grass',null,{alphaTest:.5}),Leaves:std('Leaves',null,{alphaTest:.5}),Leaves_NormalTree:std('Leaves_NormalTree_C',null,{alphaTest:.5}),Leaves_Pine:std('Leaf_Pine_C',null,{alphaTest:.5}),
  Leaves_TwistedTree:std('Leaves_TwistedTree_C',null,{alphaTest:.5}),Mushrooms:std('Mushrooms'),PathRocks:std('PathRocks_Diffuse'),Rocks:std('Rocks_Diffuse'),HalloweenBits:std('halloweenbits_texture',null,{roughness:.6})});
 KIT.matFor=(name,vc)=>{const m=KIT.mat[name]||KIT.mat.MI_Plaster;if(!vc)return m;if(!KIT.vc[name]){const c=m.clone();c.vertexColors=true;KIT.vc[name]=c}return KIT.vc[name]};
 KIT.ready=new Promise((ok,bad)=>{const a=new XMLHttpRequest();a.open('GET','art/models.json');a.onload=()=>{const J=JSON.parse(a.responseText);const b=new XMLHttpRequest();b.open('GET','art/models.wasm');b.responseType='arraybuffer';
  b.onload=()=>{const B=b.response;for(const n in J){KIT.geo[n]=J[n].map(p=>{const g=new THREE.BufferGeometry(),o=p.o;g.setAttribute('position',new THREE.BufferAttribute(new Float32Array(B,o,p.n*3),3));g.setAttribute('normal',new THREE.BufferAttribute(new Float32Array(B,o+p.n*12,p.n*3),3));
    g.setAttribute('uv',new THREE.BufferAttribute(new Float32Array(B,o+p.n*24,p.n*2),2));if(p.c)g.setAttribute('color',new THREE.BufferAttribute(new Float32Array(B,o+p.n*32,p.n*3),3));const io=o+p.n*(p.c?44:32);g.setIndex(new THREE.BufferAttribute(p.b?new Uint32Array(B,io,p.i):new Uint16Array(B,io,p.i),1));return{g,m:p.m,c:p.c}})}ok()};b.onerror=bad;b.send()};a.onerror=bad;a.send()})})();
KIT.piece=function(n){const grp=new THREE.Group();(KIT.geo[n]||[]).forEach(p=>{const m=new THREE.Mesh(p.g,KIT.matFor(p.m,p.c));m.castShadow=p.m!='MI_WindowGlass';m.receiveShadow=true;grp.add(m)});grp.name=n;return grp};
// House builder: returns {group, steps:[[pieces...],...]} so the build can animate in stages
KIT.house=function(o){// o:{w:cells along x, d:cells along z, floors, style:'Plaster'|'UnevenBrick', front:[[...per floor...]], roof:'4x4'}
 const G=new THREE.Group(),W=o.w,D=o.d,H=3.12,steps=[],st=o.style||'Plaster';
 const put=(n,x,y,z,ry,arr)=>{const p=KIT.piece(n);p.position.set(x,y,z);p.rotation.y=ry||0;G.add(p);arr.push(p);return p};
 const base=[];for(let i=0;i<W;i++)for(let j=0;j<D;j++)put('Floor_WoodDark',-W+1+2*i,0.02,-D+1+2*j,0,base);steps.push(base);
 for(let f=0;f<(o.floors||1);f++){const y=f*H,wl=[],dec=[],fr=(o.front&&o.front[f])||[];const wallN=k=>'Wall_'+st+(k=='door'?'_Door_Round':k=='win'?'_Window_Wide_Round':k=='thin'?'_Window_Thin_Round':'_Straight');
  for(let i=0;i<W;i++){const k=fr[i]||'win',x=-W+1+2*i;put(wallN(k),x,y,D,0,wl);if(k=='win'){put('Window_Wide_Round1',x,y,D,0,dec);if(o.shutters)put('WindowShutters_Wide_Round_Open',x,y,D,0,dec)}if(k=='thin')put('Window_Thin_Round1',x,y,D,0,dec);if(k=='door'){put('Door_1_Round',x-.53,y,D-.05,0,dec)}
   put(wallN(i%2?'win':'plain'),x,y,-D,Math.PI,wl);if(i%2)put('Window_Wide_Round1',x,y,-D,Math.PI,dec)}
  for(let j=0;j<D;j++){const z=-D+1+2*j;put(wallN(j%2?'win':'plain'),W,y,z,Math.PI/2,wl);put(wallN(j%2?'win':'plain'),-W,y,z,-Math.PI/2,wl);if(j%2){put('Window_Wide_Round1',W,y,z,Math.PI/2,dec);put('Window_Wide_Round1',-W,y,z,-Math.PI/2,dec)}}
  [[W,D,0],[-W,D,-Math.PI/2],[W,-D,Math.PI/2],[-W,-D,Math.PI]].forEach(c=>put('Corner_Exterior_'+(st=='Plaster'?'Wood':'Brick'),c[0],y,c[1],c[2],wl));
  if(f>0&&o.balcony){put('Balcony_Cross_Straight',-W+1,y,D-0.9,0,dec)}
  steps.push(wl);steps.push(dec)}
 const rt=(o.floors||1)*H,roof=[];put('Roof_RoundTiles_'+(o.roof||(2*W)+'x'+(2*D)),0,rt,0,0,roof);put('Roof_Front_Brick'+(2*W),0,rt,D,0,roof);put('Roof_Front_Brick'+(2*W),0,rt,-D,Math.PI,roof);
 if(o.chimney)put('Prop_Chimney',W*.5,rt+.4,-D*.4,0,roof);steps.push(roof);
 return{group:G,steps}};
