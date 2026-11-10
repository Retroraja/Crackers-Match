// 50 levels in 5 chapters (plan v2, 9 Nov 2026).
// Cracker colours: 0 Bijli, 1 Kuruvi, 2 Hydrogen Bomb, 3 Twinkling Star, 5 Bullet Bomb.
// Every level has its own title and board shape, and from chapter 2 on mixes 2 or 3 goal types.
// Big shelves (big) are 2x2 and break piece by piece: cups 9, bottles 9, fruit 10, sweets 9, diyas 6, gifts 9.
(function(){
var C4=[0,1,2,5],C4S=[3,0,1,5],C5=[0,1,2,3,5];
var CAP={cups:9,bottles:9,fruit:10,sweets:9,diyas:6,gifts:9};
// ---------- board shapes: rows of x (cell) and . (no cell) ----------
function grid(w,h,f){var a=[];for(var r=0;r<h;r++){var s='';for(var c=0;c<w;c++)s+=f(r,c)?'x':'.';a.push(s)}return a}
function sq(w,h){return grid(w,h||w,function(){return 1})}
function cut(w,h){h=h||w;return grid(w,h,function(r,c){return !((r==0||r==h-1)&&(c==0||c==w-1))})}
function cut2(w,h){h=h||w;return grid(w,h,function(r,c){var a=Math.min(r,h-1-r),b=Math.min(c,w-1-c);return a+b>=2})}
function plus(w,h){h=h||w;var k=w>=9?2:2;return grid(w,h,function(r,c){var a=Math.min(r,h-1-r),b=Math.min(c,w-1-c);return !(a<k&&b<k)})}
function diamond(w,h){h=h||w;var cr=(h-1)/2,cc=(w-1)/2,R=Math.max(w,h)*.62;return grid(w,h,function(r,c){return Math.abs(r-cr)+Math.abs(c-cc)<=R})}
function circle(w,h){h=h||w;var cr=(h-1)/2,cc=(w-1)/2,R=Math.max(w,h)/2+.1;return grid(w,h,function(r,c){var dr=r-cr,dc=c-cc;return dr*dr+dc*dc<=R*R})}
function heart(){return['.xxx.xxx.','xxxxxxxxx','xxxxxxxxx','xxxxxxxxx','xxxxxxxxx','.xxxxxxx.','..xxxxx..','...xxx...']}
function split(w,h){h=h||w;var m=(w-1)/2;return grid(w,h,function(r,c){return c!=m})}
function hole(w,h){h=h||w;var mr=h>>1,mc=w>>1;return grid(w,h,function(r,c){return !(r==mr&&c==mc)})}
function holes4(w,h){h=h||w;return grid(w,h,function(r,c){return !((r==2||r==h-3)&&(c==2||c==w-3))})}
function stairs(){return['xxxxx....','xxxxxx...','xxxxxxx..','xxxxxxxx.','xxxxxxxxx','.xxxxxxxx','..xxxxxxx','...xxxxxx','....xxxxx']}
function star(){return['....x....','...xxx...','xxxxxxxxx','.xxxxxxx.','..xxxxx..','.xxxxxxx.','xxxxxxxxx','...xxx...','....x....']}
function diyaB(){return['....x....','...xxx...','..xxxxx..','xxxxxxxxx','xxxxxxxxx','xxxxxxxxx','.xxxxxxx.','..xxxxx..','...xxx...']}
function hourglass(){return['xxxxxxxx','xxxxxxxx','.xxxxxx.','..xxxx..','..xxxx..','.xxxxxx.','xxxxxxxx','xxxxxxxx']}
// ---------- helpers ----------
function stairs8(){return['xxxxx...','xxxxxx..','xxxxxxx.','xxxxxxxx','xxxxxxxx','.xxxxxxx','..xxxxxx','...xxxxx','...xxxxx']}
function temple8(){return['...xx...','..xxxx..','.xxxxxx.','xxxxxxxx','xxxxxxxx','xxxxxxxx','xxxxxxxx','xxx..xxx','xxx..xxx']}
function diya8(){return['...xx...','..xxxx..','...xx...','xxxxxxxx','xxxxxxxx','xxxxxxxx','.xxxxxx.','..xxxx..','...xx...']}
function star8(){return['...xx...','...xx...','xxxxxxxx','.xxxxxx.','..xxxx..','.xxxxxx.','xxxxxxxx','...xx...','...xx...']}
function split8(){return['xxx..xxx','xxx..xxx','xxx..xxx','xxx..xxx','xxx..xxx','xxx..xxx','xxxxxxxx','xxxxxxxx','xxxxxxxx']}
function rows(rs,cs){var o=[];rs.forEach(function(r){cs.forEach(function(c){o.push([r,c])})});return o}
function B(t,r,c){return{t:t,r:r,c:c,w:2,h:2,n:CAP[t]}}
function WALL(r,c,w){return{t:'wall',r:r,c:c||0,w:w||8,h:1,n:3}}
function WOOD(r,c){return{t:'wood',r:r,c:c,w:2,h:2,n:4}}
function RACK(t,r,c){return{t:t,r:r,c:c,w:3,h:3,n:9}}
function ok(sh,r,c){return r>=0&&r<sh.length&&c>=0&&c<sh[0].length&&sh[r][c]=='x'}
function L(o){var sh=o.shape,g=o.goal||{},used={};
 (o.big||[]).forEach(function(b){for(var r=b.r;r<b.r+b.h;r++)for(var c=b.c;c<b.c+b.w;c++){if(!ok(sh,r,c))throw new Error(o.name+': shelf on a hole');used[r+','+c]=1}if(b.t=='wall')g.diya=(g.diya||0)+2;else g[b.t]=(g[b.t]||0)+b.n});
 var ob={};for(var k in o.ob||{}){ob[k]=o.ob[k].filter(function(p){var key=p[0]+','+p[1];if(!ok(sh,p[0],p[1])||used[key])return false;used[key]=1;return true});if(ob[k].length&&k!='gbox')g[k]=ob[k].length}o.ob=ob;
 if(o.diya){o.diya=o.diya.filter(function(p){return ok(sh,p[0],p[1])});g.diya=o.diya.length}o.goal=g;return o}
var EDGE9=rows([2,6],[0,1,7,8]),RING9=[[1,1],[1,7],[7,1],[7,7],[1,4],[7,4],[4,1],[4,7]];
window.LEVELS=[
// ===== Chapter 1: Green Village (learn the basics, 4 colours) =====
L({name:'Bijli Street',moves:15,colors:C4,goal:{0:16},shape:sq(8,8),preSp:0}),
L({name:'First Rocket',moves:16,colors:[1,0,2,5],goal:{1:18},teach:'rocket',intro:['rocket'],shape:cut(8,9),preSp:0}),
L({name:'Colour Matchbox',moves:16,colors:[2,0,1,5],goal:{2:24},preSp:1,preK:[14],intro:['matchbox'],shape:plus(8,9)}),
L({name:'Crate Wall',moves:18,colors:[5,0,1,2],goal:{5:14},big:[WALL(8)],intro:['wall'],shape:sq(8,9),preSp:0}),
L({name:'Ground Chakra',moves:20,colors:C4,goal:{0:12},teach:'square',intro:['chakra','wood'],big:[WOOD(7,0),WOOD(7,6)],shape:sq(8,9),preSp:0,reward:{k:'hammer',n:3}}),
L({name:'Golden Yard',moves:22,colors:[1,0,2,5],big:[WALL(7),WALL(8)],ob:{gold:rows([3,4,5],[2,3,4,5])},intro:['gold'],shape:sq(8,9)}),
L({name:'Ice Lane',moves:24,colors:[2,0,1,5],goal:{1:14},ob:{ice:[[8,1],[8,2],[8,3],[8,4],[8,5],[8,6]]},intro:['ice'],shape:sq(8,9)}),
L({name:'First Bomb',moves:24,colors:[5,0,1,2],goal:{2:14},teach:'lshape',intro:['atom'],big:[WOOD(4,0),WOOD(4,3),WOOD(4,6)],shape:sq(8,9),preSp:0}),
L({name:'Chain Gate',moves:24,colors:C4,big:[WALL(4)],ob:{chain:[[8,2],[8,3],[8,4],[8,5]],ice:[[8,0],[8,1],[8,6],[8,7]]},intro:['chain'],shape:sq(8,9)}),
L({name:'Diwali Gate',moves:26,colors:[1,0,2,5],big:[WOOD(0,0),WOOD(0,6),WALL(8)],ob:{gold:rows([3,4,5],[2,3,4,5])},shape:sq(8,9),reward:{k:'sparkler',n:3}}),
// ===== Chapter 2: Market =====
L({name:"Pot Lane",moves:24,colors:C4,ob:{dpot:[[7, 0], [7, 1], [7, 2], [7, 5], [7, 6], [7, 7], [8, 0], [8, 1], [8, 2], [8, 5], [8, 6], [8, 7]]},intro:['dpot'],shape:sq(8,9)}),
L({name:"Pot Square",moves:26,colors:C4,big:[WOOD(3,3)],ob:{dpot:[[2, 2], [2, 3], [2, 4], [2, 5], [3, 2], [3, 5], [4, 2], [4, 5], [5, 2], [5, 3], [5, 4], [5, 5], [7, 2], [7, 3], [7, 4], [7, 5], [8, 2], [8, 3], [8, 4], [8, 5]]},shape:sq(8,9)}),
L({name:"Twin Walls",moves:24,colors:C4,big:[WALL(7),WALL(8)],ob:{dpot:[[3, 0], [3, 1], [3, 2], [3, 5], [3, 6], [3, 7], [4, 0], [4, 1], [4, 2], [4, 5], [4, 6], [4, 7]]},shape:sq(8,9)}),
L({name:"Gold Floor",moves:24,colors:C4,ob:{gold:[[5, 0], [5, 1], [5, 2], [5, 3], [5, 4], [5, 5], [5, 6], [5, 7], [6, 0], [6, 1], [6, 2], [6, 3], [6, 4], [6, 5], [6, 6], [6, 7], [7, 0], [7, 1], [7, 2], [7, 3], [7, 4], [7, 5], [7, 6], [7, 7], [8, 0], [8, 1], [8, 2], [8, 3], [8, 4], [8, 5], [8, 6], [8, 7]]},intro:['gold'],shape:sq(8,9)}),
L({name:"Market Gate",moves:28,colors:C4,big:[WOOD(0,0),WOOD(0,6),WOOD(3,3)],ob:{gold:[[5, 0], [5, 1], [5, 2], [5, 3], [5, 4], [5, 5], [5, 6], [5, 7], [6, 0], [6, 1], [6, 2], [6, 3], [6, 4], [6, 5], [6, 6], [6, 7], [7, 0], [7, 1], [7, 2], [7, 3], [7, 4], [7, 5], [7, 6], [7, 7]],ice:[[8, 0], [8, 1], [8, 2], [8, 3], [8, 4], [8, 5], [8, 6], [8, 7]]},shape:sq(8,9)}),
L({name:"Bijli Bazaar",moves:22,colors:C4,goal:{0: 40},ob:{dpot:[[0, 0], [0, 1], [0, 6], [0, 7], [1, 0], [1, 1], [1, 6], [1, 7]]},shape:sq(8,9)}),
L({name:"Gift Box",moves:22,colors:C4,goal:{1: 100},ob:{gbox:[[4, 1], [4, 4], [6, 6]]},intro:['gbox'],boxK:1,shape:sq(8,9)}),
L({name:"Gift and Pots",moves:25,colors:C4,goal:{2: 80},ob:{gbox:[[3, 2], [3, 5]],dpot:[[7, 0], [7, 1], [7, 2], [7, 3], [7, 4], [7, 5], [7, 6], [7, 7], [8, 0], [8, 1], [8, 2], [8, 3], [8, 4], [8, 5], [8, 6], [8, 7]]},boxK:2,shape:sq(8,9)}),
L({name:"Gold and Chains",moves:27,colors:C4,ob:{gold:[[4, 0], [4, 1], [4, 2], [4, 3], [4, 4], [4, 5], [4, 6], [4, 7], [5, 0], [5, 1], [5, 2], [5, 3], [5, 4], [5, 5], [5, 6], [5, 7], [6, 0], [6, 1], [6, 2], [6, 3], [6, 4], [6, 5], [6, 6], [6, 7]],chain:[[8, 2], [8, 3], [8, 4], [8, 5]],ice:[[8, 0], [8, 1], [8, 6], [8, 7]]},shape:sq(8,9)}),
L({name:"Diwali Market",moves:28,colors:C4,goal:{0: 90},big:[WALL(7),WALL(8)],ob:{gbox:[[2, 1], [2, 6]],dpot:[[5, 0], [5, 1], [5, 2], [5, 5], [5, 6], [5, 7], [6, 0], [6, 1], [6, 2], [6, 5], [6, 6], [6, 7]],gold:[[3, 2], [3, 3], [3, 4], [3, 5], [4, 2], [4, 3], [4, 4], [4, 5]]},boxK:0,shape:sq(8,9)}),
// ===== Chapter 3: Sweet Shop =====
L({name:"Cup Rack",moves:25,colors:C4,big:[RACK('rackc',2,2)],ob:{dpot:[[7, 0], [7, 1], [7, 2], [7, 3], [7, 4], [7, 5], [7, 6], [7, 7], [8, 0], [8, 1], [8, 2], [8, 3], [8, 4], [8, 5], [8, 6], [8, 7]]},intro:['rackc'],shape:sq(8,9)}),
L({name:"Rack and Gold",moves:24,colors:C4,big:[RACK('rackc',0,0)],ob:{gold:[[6, 0], [6, 1], [6, 2], [6, 3], [6, 4], [6, 5], [6, 6], [6, 7], [7, 0], [7, 1], [7, 2], [7, 3], [7, 4], [7, 5], [7, 6], [7, 7], [8, 0], [8, 1], [8, 2], [8, 3], [8, 4], [8, 5], [8, 6], [8, 7]]},shape:sq(8,9)}),
L({name:"Five Crackers",moves:25,colors:C5,goal:{3: 30},big:[WOOD(7,1),WOOD(7,5)],shape:sq(8,9)}),
L({name:"Sweet Rack",moves:26,colors:C5,big:[RACK('racks',3,0),RACK('rackc',3,5)],intro:['racks'],shape:sq(8,9)}),
L({name:"Sweet Counter",moves:31,colors:C5,big:[RACK('racks',1,0),RACK('rackg',1,5),WALL(7)],intro:['rackg'],shape:sq(8,9)}),
L({name:"Laddu Lane",moves:20,colors:C5,goal:{0: 80},ob:{gbox:[[3, 2], [5, 5]]},boxK:0,shape:sq(8,9)}),
L({name:"Gift Rack",moves:26,colors:C5,big:[RACK('rackg',2,3)],ob:{dpot:[[2, 0], [2, 1], [3, 0], [3, 1], [4, 0], [4, 1], [5, 0], [5, 1], [6, 0], [6, 1], [6, 6], [6, 7], [7, 6], [7, 7], [8, 6], [8, 7]]},shape:sq(8,9)}),
L({name:"Rack Trio",moves:26,colors:C5,big:[RACK('rackc',0,0),RACK('racks',0,5),RACK('rackg',5,2)],shape:sq(8,9)}),
L({name:"Gold Shop",moves:26,colors:C5,big:[WOOD(0,0),WOOD(0,6)],ob:{gold:[[3, 0], [3, 1], [3, 2], [3, 3], [3, 4], [3, 5], [3, 6], [3, 7], [4, 0], [4, 1], [4, 2], [4, 3], [4, 4], [4, 5], [4, 6], [4, 7], [5, 0], [5, 1], [5, 2], [5, 3], [5, 4], [5, 5], [5, 6], [5, 7], [6, 0], [6, 1], [6, 2], [6, 3], [6, 4], [6, 5], [6, 6], [6, 7], [7, 0], [7, 1], [7, 2], [7, 3], [7, 4], [7, 5], [7, 6], [7, 7]]},shape:sq(8,9)}),
L({name:"Grand Sweets",moves:31,colors:C5,big:[RACK('racks',0,0),RACK('rackg',0,5)],ob:{gold:[[4, 0], [4, 1], [4, 2], [4, 3], [4, 4], [4, 5], [4, 6], [4, 7], [5, 0], [5, 1], [5, 2], [5, 3], [5, 4], [5, 5], [5, 6], [5, 7], [6, 0], [6, 1], [6, 2], [6, 3], [6, 4], [6, 5], [6, 6], [6, 7]],chain:[[8, 2], [8, 3], [8, 4], [8, 5]],ice:[[8, 0], [8, 1], [8, 6], [8, 7]]},shape:sq(8,9)}),
// ===== Chapter 4: Temple Road =====
L({name:"Sky Lanterns",moves:24,colors:C5,ob:{lantern:[[6, 1], [6, 3], [6, 5], [7, 2], [7, 4], [7, 6]]},intro:['lantern'],shape:sq(8,9)}),
L({name:"Lanterns and Pots",moves:24,colors:C5,ob:{lantern:[[6, 1], [6, 3], [6, 5], [7, 2], [7, 4], [7, 6]],dpot:[[2, 0], [2, 1], [2, 2], [2, 3], [2, 4], [2, 5], [2, 6], [2, 7], [3, 0], [3, 1], [3, 2], [3, 3], [3, 4], [3, 5], [3, 6], [3, 7]]},shape:sq(8,9)}),
L({name:"Lantern Walls",moves:26,colors:C5,big:[WALL(7),WALL(8)],ob:{lantern:[[6, 1], [6, 3], [6, 4], [6, 6]]},shape:sq(8,9)}),
L({name:"Firecracker Box",moves:24,colors:C5,goal:{1: 30},ob:{fbox:[[3, 1], [3, 6], [6, 3]]},intro:['fbox'],shape:sq(8,9)}),
L({name:"Temple Steps",moves:30,colors:C5,ob:{dpot:[[4, 0], [4, 1], [4, 2], [4, 3], [4, 4], [4, 5], [4, 6], [4, 7], [5, 0], [5, 1], [5, 2], [5, 3], [5, 4], [5, 5], [5, 6], [5, 7], [6, 0], [6, 1], [6, 2], [6, 3], [6, 4], [6, 5], [6, 6], [6, 7]],fbox:[[2, 1], [2, 4]],ice:[[8, 3], [8, 4], [8, 5], [8, 6], [8, 7]]},shape:stairs8()}),
L({name:"Bell Street",moves:22,colors:C5,goal:{2: 100},ob:{gbox:[[3, 1], [3, 6], [6, 3]]},boxK:2,shape:sq(8,9)}),
L({name:"Lantern Garden",moves:26,colors:C5,ob:{gold:[[3, 0], [3, 1], [3, 2], [3, 3], [3, 4], [3, 5], [3, 6], [3, 7], [4, 0], [4, 1], [4, 2], [4, 3], [4, 4], [4, 5], [4, 6], [4, 7], [5, 0], [5, 1], [5, 2], [5, 3], [5, 4], [5, 5], [5, 6], [5, 7], [6, 0], [6, 1], [6, 2], [6, 3], [6, 4], [6, 5], [6, 6], [6, 7]],lantern:[[7, 1], [7, 2], [7, 3], [7, 4], [7, 5], [7, 6]]},shape:sq(8,9)}),
L({name:"Box and Rack",moves:29,colors:C5,big:[RACK('rackc',1,2),WOOD(7,0),WOOD(7,6)],ob:{fbox:[[6, 1], [6, 6]]},shape:sq(8,9)}),
L({name:"Chain Temple",moves:31,colors:C5,big:[WALL(5),WALL(6),WALL(7)],ob:{chain:[[8, 2], [8, 3], [8, 4], [8, 5]],ice:[[8, 0], [8, 1], [8, 6], [8, 7]]},shape:sq(8,9)}),
L({name:"Temple Gate",moves:31,colors:C5,big:[RACK('racks',4,0),RACK('rackg',4,5)],ob:{lantern:[[3, 1], [3, 2], [3, 3], [3, 4], [3, 5], [3, 6]],gold:[[7, 0], [7, 1], [7, 2], [7, 5], [7, 6], [7, 7], [8, 0], [8, 1], [8, 2], [8, 5], [8, 6], [8, 7], [2, 1], [2, 2], [2, 3], [2, 4], [2, 5], [2, 6], [1, 3], [1, 4]]},shape:temple8()}),
// ===== Chapter 5: Grand Festival =====
L({name:"Diya Board",moves:25,colors:C5,goal:{0: 80},ob:{gbox:[[3, 1], [3, 6]],dpot:[[5, 0], [5, 1], [5, 2], [5, 3], [5, 4], [5, 5], [5, 6], [5, 7], [6, 0], [6, 1], [6, 2], [6, 3], [6, 4], [6, 5], [6, 6], [6, 7], [7, 0], [7, 1], [7, 2], [7, 3], [7, 4], [7, 5], [7, 6], [7, 7], [8, 0], [8, 1], [8, 2], [8, 3], [8, 4], [8, 5], [8, 6], [8, 7], [4, 0], [4, 7]]},boxK:0,shape:diya8()}),
L({name:"Star Board",moves:26,colors:C5,ob:{gold:[[2, 0], [2, 1], [2, 2], [2, 3], [2, 4], [2, 5], [2, 6], [2, 7], [3, 0], [3, 1], [3, 2], [3, 3], [3, 4], [3, 5], [3, 6], [3, 7], [4, 0], [4, 1], [4, 2], [4, 3], [4, 4], [4, 5], [4, 6], [4, 7], [5, 0], [5, 1], [5, 2], [5, 3], [5, 4], [5, 5], [5, 6], [5, 7], [6, 0], [6, 1], [6, 2], [6, 3], [6, 4], [6, 5], [6, 6], [6, 7]]},shape:star8()}),
L({name:"Split Board",moves:28,colors:C5,goal:{1: 30},big:[WALL(5,0,3),WALL(5,5,3)],shape:split8()}),
L({name:"Lantern Sky",moves:28,colors:C5,big:[WOOD(2,0),WOOD(2,6),WOOD(7,2),WOOD(7,4)],ob:{lantern:[[5, 1], [5, 2], [5, 5], [5, 6], [6, 1], [6, 2], [6, 5], [6, 6]]},shape:sq(8,9)}),
L({name:"Festival Square",moves:30,colors:C5,big:[RACK('rackc',0,0),RACK('racks',0,5),RACK('rackg',3,2)],ob:{gold:[[7, 0], [7, 1], [7, 2], [7, 3], [7, 4], [7, 5], [7, 6], [7, 7], [8, 0], [8, 1], [8, 2], [8, 3], [8, 4], [8, 5], [8, 6], [8, 7]]},shape:sq(8,9)}),
L({name:"Sparkle Street",moves:22,colors:C5,goal:{3: 110},ob:{gbox:[[3, 1], [3, 6], [6, 3]]},boxK:3,shape:sq(8,9)}),
L({name:"Dig Through",moves:30,colors:C4,big:[WOOD(3,2),WOOD(3,4)],ob:{dpot:[[6, 0], [6, 1], [6, 2], [6, 3], [6, 4], [6, 5], [6, 6], [6, 7], [7, 0], [7, 1], [7, 2], [7, 3], [7, 4], [7, 5], [7, 6], [7, 7], [8, 0], [8, 1], [8, 2], [8, 3], [8, 4], [8, 5], [8, 6], [8, 7]]},shape:sq(8,9)}),
L({name:"Firecracker Fair",moves:31,colors:C5,ob:{fbox:[[2, 1], [2, 6], [4, 3], [4, 4]],dpot:[[6, 0], [6, 1], [6, 2], [6, 3], [6, 4], [6, 5], [6, 6], [6, 7], [7, 0], [7, 1], [7, 2], [7, 3], [7, 4], [7, 5], [7, 6], [7, 7], [4, 0], [4, 7]],ice:[[8, 1], [8, 2], [8, 3], [8, 4], [8, 5], [8, 6]]},shape:sq(8,9)}),
L({name:"Golden Night",moves:30,colors:C5,ob:{gold:[[0, 0], [0, 1], [0, 2], [0, 3], [0, 4], [0, 5], [0, 6], [0, 7], [1, 0], [1, 1], [1, 2], [1, 3], [1, 4], [1, 5], [1, 6], [1, 7], [2, 0], [2, 1], [2, 2], [2, 3], [2, 4], [2, 5], [2, 6], [2, 7], [3, 0], [3, 1], [3, 2], [3, 3], [3, 4], [3, 5], [3, 6], [3, 7], [4, 0], [4, 1], [4, 2], [4, 3], [4, 4], [4, 5], [4, 6], [4, 7], [5, 0], [5, 1], [5, 2], [5, 3], [5, 4], [5, 5], [5, 6], [5, 7], [6, 0], [6, 1], [6, 2], [6, 3], [6, 4], [6, 5], [6, 6], [6, 7], [7, 0], [7, 1], [7, 2], [7, 3], [7, 4], [7, 5], [7, 6], [7, 7]],chain:[[8, 2], [8, 3], [8, 4], [8, 5]]},shape:sq(8,9)}),
L({name:"Grand Finale",moves:32,colors:C5,goal:{0: 60},big:[WALL(8),RACK('rackc',0,0),RACK('rackg',0,5)],ob:{lantern:[[4, 1], [4, 3], [4, 4], [4, 6]],gbox:[[6, 1], [6, 6]],gold:[[5, 2], [5, 3], [5, 4], [5, 5], [6, 2], [6, 3], [6, 4], [6, 5], [7, 2], [7, 3], [7, 4], [7, 5]]},boxK:0,shape:sq(8,9)})
];
})();

// Tuning from bot play (9 Nov 2026): moves per level, and collect goals sized so each level lasts a while.
(function(){var MV=[15, 16, 16, 18, 23, 22, 24, 26, 26, 28, 26, 29, 24, 27, 30, 26, 22, 29, 27, 25, 30, 27, 29, 30, 30, 20, 30, 26, 26, 31, 24, 24, 28, 26, 31, 22, 31, 31, 37, 37, 28, 28, 28, 32, 31, 22, 36, 36, 32, 32],GL={};
window.LEVELS.forEach(function(l,i){l.moves=MV[i];var g=GL[i]||{};for(var k in g)l.goal[k]=g[k]})})();

// booster unlock rewards (10 Nov): 3 free when each unlocks
(function(L){[[4,"hammer"],[9,"sparkler"],[14,"seven"],[19,"flowerpot"],[24,"snake"],[29,"wala"],[34,"rail"],[39,"skyshot"]].forEach(function(p){if(L[p[0]])L[p[0]].reward={k:p[1],n:3}});if(L[44])delete L[44].reward})(window.LEVELS);
