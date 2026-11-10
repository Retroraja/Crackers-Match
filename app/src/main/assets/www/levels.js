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
function rows(rs,cs){var o=[];rs.forEach(function(r){cs.forEach(function(c){o.push([r,c])})});return o}
function B(t,r,c){return{t:t,r:r,c:c,w:2,h:2,n:CAP[t]}}
function WALL(r,c,w){return{t:'wall',r:r,c:c||0,w:w||8,h:1,n:3}}
function WOOD(r,c){return{t:'wood',r:r,c:c,w:2,h:2,n:4}}
function ok(sh,r,c){return r>=0&&r<sh.length&&c>=0&&c<sh[0].length&&sh[r][c]=='x'}
function L(o){var sh=o.shape,g=o.goal||{},used={};
 (o.big||[]).forEach(function(b){for(var r=b.r;r<b.r+b.h;r++)for(var c=b.c;c<b.c+b.w;c++){if(!ok(sh,r,c))throw new Error(o.name+': shelf on a hole');used[r+','+c]=1}if(b.t=='wall')g.diya=(g.diya||0)+2;else g[b.t]=(g[b.t]||0)+b.n});
 var ob={};for(var k in o.ob||{}){ob[k]=o.ob[k].filter(function(p){var key=p[0]+','+p[1];if(!ok(sh,p[0],p[1])||used[key])return false;used[key]=1;return true});if(ob[k].length)g[k]=ob[k].length}o.ob=ob;
 if(o.diya){o.diya=o.diya.filter(function(p){return ok(sh,p[0],p[1])});g.diya=o.diya.length}o.goal=g;return o}
var EDGE9=rows([2,6],[0,1,7,8]),RING9=[[1,1],[1,7],[7,1],[7,7],[1,4],[7,4],[4,1],[4,7]];
window.LEVELS=[
// ===== Chapter 1: Green Village (learn the basics, 4 colours) =====
L({name:'Bijli Street',moves:15,colors:C4,goal:{0:16},shape:sq(8,8),preSp:0}),
L({name:'Kuruvi Corner',moves:22,colors:[1,0,2,5],goal:{1:16,2:12},shape:cut(8,9)}),
L({name:'Hydrogen Hill',moves:18,colors:[2,0,1,5],goal:{2:16,5:16},shape:plus(8,9)}),
L({name:'First Rocket',moves:18,colors:[5,0,1,2],goal:{5:20},preSp:1,preK:[6,15],teach:'rocket',intro:['rocket'],shape:hole(8,9)}),
L({name:'Crate Wall',moves:18,colors:C4,goal:{0:16},big:[WALL(8)],intro:['wall'],shape:sq(8,9),reward:{k:'sparkler',n:3}}),
L({name:'Triple Wall',moves:20,colors:[1,0,2,5],goal:{1:14},big:[WALL(6),WALL(7),WALL(8)],shape:sq(8,9)}),
L({name:'Wall in the Middle',moves:22,colors:[2,0,1,5],goal:{1:20},big:[WALL(4)],shape:cut(8,9)}),
L({name:'Flowerpot Fair',moves:20,colors:C4,goal:{0:20,1:20},teach:'square',intro:['flowerpot'],shape:diamond(8,9)}),
L({name:'Crate Corners',moves:22,colors:[1,0,2,5],big:[WOOD(0,0),WOOD(0,6),WOOD(7,0),WOOD(7,6)],intro:['wood'],shape:sq(8,9)}),
L({name:'Crate Row',moves:22,colors:[5,0,1,2],goal:{2:20},big:[WOOD(4,0),WOOD(4,3),WOOD(4,6)],shape:sq(8,9)}),
// ===== Chapter 2: Flower Hills (fruit, rangoli, combos, 5 colours) =====
L({name:'Fruit Market',moves:19,colors:C5,big:[B('fruit',3,3)],intro:['fruit'],shape:sq(8)}),
L({name:'Sky Lane',moves:20,colors:C5,goal:{1:24,5:24},intro:['skyshot'],shape:sq(7,9)}),
L({name:'Basket Row',moves:22,colors:C5,big:[B('fruit',3,1)],ob:{thread:rows([1],[5,6,7]).concat(rows([6],[5,6,7]))},shape:split(9)}),
L({name:'Rangoli Square',moves:20,colors:C5,goal:{2:16},ob:{rang:RING9.concat([[0,4],[8,4],[4,0],[4,8],[2,2],[2,6],[6,2],[6,6]])},intro:['rang'],shape:sq(9)}),
L({name:'Kolam Street',moves:22,colors:C5,big:[B('cups',3,3)],ob:{rang:EDGE9.concat([[1,1],[1,7],[7,1],[7,7]])},shape:plus(9),reward:{k:'rail',n:3}}),
L({name:'Hidden Godown',moves:23,colors:C5,goal:{0:20},ob:{steel:rows([3],[0,1,2,3,4,5,6,7]),crate:rows([4],[0,1,2,3,4,5,6,7])},intro:['steel'],shape:sq(8,9)}),
L({name:'Combo Corner',moves:20,colors:C5,goal:{2:26,3:26},preSp:3,shape:diamond(9)}),
L({name:'Market Day',moves:24,colors:C5,big:[B('cups',2,1),B('fruit',2,6)],ob:{rang:rows([7],[1,2,3,5,6,7])},shape:cut(9)}),
L({name:'Festival Road',moves:22,colors:C5,goal:{5:18},ob:{rang:rows([1],[1,2,6,7]).concat(rows([3],[0,1,7,8])),thread:rows([5],[2,3,5,6])},shape:heart()}),
L({name:'Grand Bazaar',moves:26,colors:C5,big:[B('fruit',4,3)],ob:{rang:[[1,1],[1,7],[7,1],[7,7],[0,4],[8,4]],gift:rows([2],[0,1,7,8]).concat(rows([6],[0,1,7,8]))},shape:cut2(9)}),
// ===== Chapter 3: Sweet Street (sweets, ice, bottles, spreading wet) =====
L({name:'Sweet Shop',moves:19,colors:C5,big:[B('sweets',3,3)],intro:['sweets'],shape:circle(8)}),
L({name:'Frosty Lane',moves:21,colors:C5,goal:{1:16},ob:{ice:rows([2,6],[1,2,3,5,6,7]).concat([[4,1],[4,7]])},intro:['ice'],shape:holes4(9)}),
L({name:'Mithai Gali',moves:22,colors:C5,big:[B('sweets',3,3)],ob:{ice:rows([1,7],[2,4,6]).concat([[3,1],[5,1],[3,7],[5,7]])},shape:circle(9)}),
L({name:'Bottle Bazaar',moves:20,colors:C5,big:[B('bottles',4,2)],intro:['bottles'],shape:sq(7,9)}),
L({name:'Soda Street',moves:22,colors:C5,goal:{5:22},big:[B('bottles',3,0)],shape:split(9),reward:{k:'wala',n:3}}),
L({name:'Laddoo Lane',moves:22,colors:C5,big:[B('sweets',3,3)],ob:{rang:rows([1],[3,4,5]).concat(rows([7],[3,4,5])).concat(rows([4],[0,1,7,8]))},shape:plus(9)}),
L({name:'Rain Alley',moves:22,colors:C5,goal:{0:18},ob:{wet:[[4,4],[3,3],[5,5]]},intro:['wet'],shape:hourglass()}),
L({name:'Twin Shops',moves:24,colors:C5,big:[B('bottles',2,0),B('sweets',2,7)],shape:split(9)}),
L({name:'Cool Corner',moves:24,colors:C5,big:[B('cups',4,3)],ob:{ice:rows([2],[2,3,4,5,6]),crate:rows([1],[0,1,7,8])},shape:diamond(9)}),
L({name:'Mithai Mela',moves:27,colors:C5,big:[B('sweets',1,1),B('bottles',1,6)],ob:{ice:rows([5],[0,1,2,6,7,8]).concat([[7,4],[6,4]])},shape:cut(9)}),
// ===== Chapter 4: Diya Lane (diyas, chains, mud) =====
L({name:'Diya Street',moves:19,colors:C5,big:[B('diyas',3,3)],intro:['diyas'],shape:diyaB()}),
L({name:'Lamp Lane',moves:23,colors:C5,diya:[[0,3]],intro:['diya'],shape:sq(7,8)}),
L({name:'Chain Market',moves:21,colors:C5,goal:{2:14},ob:{chain:rows([3,5],[1,2,6,7]).concat([[1,4],[7,4]])},intro:['chain'],shape:holes4(9)}),
L({name:'Light Road',moves:23,colors:C5,big:[B('diyas',3,3)],ob:{pot:[[1,1],[1,7],[5,2],[5,6],[2,4]]},intro:['pot'],shape:heart()}),
L({name:'Mud Path',moves:22,colors:C5,goal:{3:16},ob:{mud:rows([7,8],[1,2,3,5,6,7])},intro:['mud'],shape:circle(9),reward:{k:'atom',n:3}}),
L({name:'Lantern Gate',moves:24,colors:C5,big:[B('diyas',4,1),B('fruit',4,6)],shape:diyaB()}),
L({name:'Rain Road',moves:25,colors:C5,diya:[[0,2]],ob:{mud:rows([8],[0,1,2,3,5,6,7,8])},shape:split(9)}),
L({name:'Temple Steps',moves:24,colors:C5,big:[B('bottles',3,3)],ob:{chain:[[0,1],[1,2],[2,3],[6,5],[7,6],[8,7]],stone:[[4,0],[4,8]]},intro:['stone'],shape:stairs()}),
L({name:'Deepam Square',moves:25,colors:C5,big:[B('diyas',2,1),B('sweets',2,6)],ob:{chain:rows([6],[1,2,3,5,6,7])},shape:plus(9)}),
L({name:'Festival of Lights',moves:28,colors:C5,diya:[[0,4]],big:[B('diyas',5,1),B('cups',5,6)],ob:{chain:rows([3],[0,1,7,8]),pot:[[2,3],[2,5]]},shape:diyaB()}),
// ===== Chapter 5: Festival Square (gifts, glass, launchers, the finale) =====
L({name:'Gift Lane',moves:21,colors:C5,big:[B('gifts',3,3)],intro:['gifts'],shape:cut(8,9)}),
L({name:'Monsoon Market',moves:22,colors:C5,goal:{1:18},ob:{wet:[[4,4],[3,4],[5,4],[4,3],[4,5],[2,4]]},shape:circle(9)}),
L({name:'Glass House',moves:22,colors:C5,goal:{5:16},ob:{glass:rows([2,6],[2,6]).concat([[4,0],[4,8],[0,4],[8,4]])},intro:['glass'],preSp:3,shape:diamond(9)}),
L({name:'Parcel Point',moves:25,colors:C5,big:[B('gifts',5,3)],ob:{steel:rows([3],[0,1,2,3,4,5,6,7,8]),wet:[[1,1],[1,7]]},shape:sq(9)}),
L({name:'Launch Pad',moves:24,colors:C5,goal:{1:26},ob:{launcher:[[7,1],[7,7],[1,4]]},intro:['launcher'],shape:sq(9),reward:{k:'matchbox',n:3}}),
L({name:'Wrapping Room',moves:25,colors:C5,big:[B('gifts',3,3)],ob:{gift:rows([1],[1,2,6,7]).concat(rows([7],[1,2,6,7])),stone:[[4,0],[4,8]]},shape:plus(9)}),
L({name:'Storm Street',moves:26,colors:C5,goal:{0:16},ob:{wet:[[3,2],[3,6]],mud:rows([8],[0,1,2,6,7,8]),ice:rows([5],[1,3,5,7])},shape:split(9)}),
L({name:'Night Bazaar',moves:27,colors:C5,big:[B('cups',2,1),B('diyas',2,6)],ob:{launcher:[[6,4],[0,4]]},shape:heart()}),
L({name:'Big Gift Day',moves:27,colors:C5,big:[B('gifts',2,1),B('sweets',2,6)],ob:{rang:rows([6],[0,1,2,3,5,6,7,8]).concat(rows([7],[2,3,5,6]))},shape:diamond(9)}),
L({name:'Grand Finale',moves:32,colors:C5,big:[B('gifts',2,2),B('fruit',5,5)],ob:{glass:[[2,0],[2,8],[6,0],[6,8]],wet:[[4,4]],crate:[[1,3],[1,4],[1,5],[7,3],[7,4],[7,5]]},shape:star()})
];
})();

// Tuning from bot play (9 Nov 2026): moves per level, and collect goals sized so each level lasts a while.
(function(){var MV=[15, 16, 16, 16, 18, 20, 20, 20, 22, 24, 18, 18, 18, 18, 19, 19, 19, 19, 20, 21, 19, 20, 19, 19, 20, 20, 24, 20, 21, 22, 19, 24, 19, 19, 20, 20, 24, 20, 21, 25, 20, 24, 20, 22, 21, 21, 22, 21, 22, 23],GL={"0": {}, "1": {}, "2": {}, "3": {}, "4": {}, "5": {}, "6": {}, "7": {}, "8": {}, "9": {}, "10": {"0": 17}, "11": {"1": 27, "5": 27}, "12": {"1": 15}, "13": {"2": 33}, "14": {"2": 18}, "15": {"0": 23}, "16": {"2": 28, "3": 28}, "17": {"1": 15}, "18": {"5": 28}, "19": {"2": 15}, "20": {"0": 23}, "21": {"1": 26}, "22": {"1": 13}, "23": {"5": 14}, "24": {"5": 44}, "25": {"0": 27}, "26": {"0": 23}, "27": {"1": 14}, "28": {"5": 23}, "29": {"2": 23}, "30": {"0": 32}, "31": {"2": 14}, "32": {"2": 28}, "33": {"5": 23}, "34": {"3": 27}, "35": {"0": 17}, "36": {"1": 20}, "37": {}, "38": {"5": 13}, "39": {}, "40": {"0": 24}, "41": {"1": 46}, "42": {"5": 38}, "43": {}, "44": {"1": 48}, "45": {"0": 10}, "46": {}, "47": {"1": 25}, "48": {"5": 29}, "49": {"2": 17}};
window.LEVELS.forEach(function(l,i){l.moves=MV[i];var g=GL[i]||{};for(var k in g)l.goal[k]=g[k]})})();
