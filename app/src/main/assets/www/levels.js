// 50 levels in 5 chapters. Cracker colours: 0 Bijli, 1 Kuruvi, 2 Pencil, 3 Twinkling Star, 5 Lakshmi Vedi.
// Big obstacles (big): cups, bottles, fruit, sweets, diyas, gifts. Each holds n items; every match beside it or blast on it breaks one.
(function(){
var C4=[0,1,2,5],C4S=[3,0,1,5],C5=[0,1,2,3,5];
function full(n){var a=[];for(var i=0;i<n;i++)a.push(new Array(n+1).join('x'));return a}
function cut(n){var a=full(n);a[0]='.'+a[0].slice(1,-1)+'.';a[n-1]='.'+a[n-1].slice(1,-1)+'.';return a}
function hole(n){var a=full(n),m=n>>1;a[m]=a[m].slice(0,m)+'.'+a[m].slice(m+1);return a}
function rows(rs,cs){var o=[];rs.forEach(function(r){cs.forEach(function(c){o.push([r,c])})});return o}
function B(t,r,c,w,h,n){return{t:t,r:r,c:c,w:w,h:h,n:n}}
function L(o){var g=o.goal||{};(o.big||[]).forEach(function(b){g[b.t]=(g[b.t]||0)+b.n});for(var k in o.ob||{})g[k]=o.ob[k].length;if(o.diya)g.diya=o.diya.length;o.goal=g;return o}
var RING=[[1,1],[1,7],[7,1],[7,7],[1,4],[7,4],[4,1],[4,7]],CROSS=rows([4],[0,2,6,8]).concat(rows([0,2,6,8],[4])),EDGE=rows([2,6],[0,1,7,8]),MID=rows([6],[1,2,3,5,6,7]),TOP=rows([1],[1,2,3,5,6,7]);
window.LEVELS=[
// Chapter 1: Green Village
L({name:'Bijli Street',moves:18,colors:C4,goal:{0:15},shape:full(8),preSp:0}),
L({name:'Kuruvi Corner',moves:18,colors:[1,0,2,5],goal:{1:20},teach:'rocket',intro:['rocket'],shape:cut(9)}),
L({name:'Pencil Lane',moves:20,colors:[2,0,1,5],goal:{2:16,0:16},shape:full(8)}),
L({name:'Lakshmi Bazaar',moves:18,colors:[5,0,1,2],goal:{5:22},teach:'square',intro:['flowerpot'],shape:hole(9)}),
L({name:'Cup Corner',moves:18,colors:C4,big:[B('cups',3,3,2,2,16)],intro:['cups'],shape:full(8),reward:{k:'sparkler',n:1}}),
L({name:'Tea Time',moves:22,colors:[1,0,2,5],goal:{1:15},big:[B('cups',3,1,2,2,10),B('cups',3,6,2,2,10)],shape:full(9)}),
L({name:'Thread Lane',moves:20,colors:[2,0,1,5],goal:{2:15},ob:{thread:rows([2,6],[1,2,5,6]).concat([[4,3],[4,4]])},intro:['thread'],shape:full(8)}),
L({name:'Star Corner',moves:20,colors:C4S,goal:{3:20},teach:'lshape',intro:['chakra'],shape:cut(9)}),
L({name:'Cups and Thread',moves:22,colors:C4,big:[B('cups',5,3,2,2,12)],ob:{thread:rows([2],[0,1,2,5,6,7]).concat([[1,3],[1,4],[3,0],[3,7]])},shape:full(8)}),
L({name:'Big Shelf',moves:24,colors:C4,goal:{0:20},big:[B('cups',3,3,3,2,24)],shape:full(9)}),
// Chapter 2: Flower Hills
L({name:'Fruit Market',moves:20,colors:C4,big:[B('fruit',3,3,2,2,18)],intro:['fruit'],shape:full(8)}),
L({name:'Sky Shot Hill',moves:20,colors:[1,5,0,2],goal:{1:24,5:24},shape:full(9)}),
L({name:'Fruit and Thread',moves:22,colors:C4,big:[B('fruit',5,3,2,2,14)],ob:{thread:TOP.concat([[3,1],[3,7]])},shape:full(9)}),
L({name:'Rangoli Road',moves:20,colors:C4,ob:{rang:RING.concat(CROSS)},intro:['rang'],shape:full(9)}),
L({name:'Rangoli Cups',moves:22,colors:C4,big:[B('cups',3,3,2,2,12)],ob:{rang:EDGE.concat([[1,1],[1,7],[7,1],[7,7]])},shape:full(9),reward:{k:'rail',n:1}}),
L({name:'Orchard Path',moves:22,colors:C4,big:[B('fruit',3,1,2,2,14)],ob:{rang:rows([1,7],[4,5,6,7]).concat(rows([4],[5,6,7,8]))},shape:full(9)}),
L({name:'Two Colours',moves:22,colors:C4,goal:{0:28,2:28},shape:hole(9)}),
L({name:'Shelf and Basket',moves:24,colors:C4,big:[B('cups',3,1,2,2,12),B('fruit',3,6,2,2,12)],shape:full(9)}),
L({name:'Thread and Rangoli',moves:22,colors:C4,ob:{rang:EDGE,thread:rows([5],[2,3,5,6]).concat([[1,3],[1,5],[3,3],[3,5]])},shape:full(9)}),
L({name:'Market Day',moves:26,colors:C4,goal:{5:20},big:[B('fruit',3,3,3,2,22)],ob:{rang:rows([7],[1,2,3,5,6,7]).concat([[1,1],[1,7],[0,4],[8,4],[4,0],[4,8]])},shape:full(9)}),
// Chapter 3: Sweet Street
L({name:'Sweet Shop',moves:20,colors:C5,big:[B('sweets',3,3,2,2,18)],intro:['sweets'],shape:full(8)}),
L({name:'Ice Lane',moves:22,colors:C5,ob:{ice:rows([2,6],[1,2,3,5,6,7]).concat([[4,1],[4,7]])},intro:['ice'],shape:full(9)}),
L({name:'Sweets on Ice',moves:22,colors:C5,big:[B('sweets',3,3,2,2,14)],ob:{ice:rows([1,7],[1,3,5,7]).concat([[3,0],[5,0],[3,8],[5,8]])},shape:full(9)}),
L({name:'Bottle Crate',moves:20,colors:C5,big:[B('bottles',3,3,2,2,18)],intro:['bottles'],shape:full(8)}),
L({name:'Bottles and Bijli',moves:22,colors:C5,goal:{0:25},big:[B('bottles',3,3,3,2,14)],shape:full(9),reward:{k:'wala',n:1}}),
L({name:'Sweet Rangoli',moves:22,colors:C5,big:[B('sweets',2,3,2,2,14)],ob:{rang:MID.concat(rows([4],[0,1,7,8]))},shape:full(9)}),
L({name:'Cold Thread',moves:22,colors:C5,ob:{ice:EDGE,thread:rows([4],[2,3,5,6]).concat([[1,4],[7,4]])},shape:full(9)}),
L({name:'Pantry',moves:24,colors:C5,big:[B('bottles',3,1,2,2,12),B('sweets',3,6,2,2,12)],shape:full(9)}),
L({name:'Frozen Cups',moves:24,colors:C5,big:[B('cups',3,3,2,2,14)],ob:{ice:RING.concat([[0,0],[0,8]])},shape:full(9)}),
L({name:'Festival Pantry',moves:28,colors:C5,big:[B('sweets',2,3,3,2,20),B('bottles',6,3,2,2,12)],ob:{ice:rows([4],[0,1,7,8]).concat([[2,0],[2,8],[6,0],[6,8]])},shape:full(9)}),
// Chapter 4: Diya Lane
L({name:'Lamp Stand',moves:20,colors:C5,big:[B('diyas',3,3,2,2,18)],intro:['diyas'],shape:full(8)}),
L({name:'Bring the Diyas',moves:24,colors:C5,diya:[[0,2],[0,6]],intro:['diya'],shape:full(9)}),
L({name:'Chain Street',moves:22,colors:C5,ob:{chain:rows([3,5],[1,2,6,7]).concat([[1,4],[7,4],[4,0],[4,8]])},intro:['chain'],shape:full(9)}),
L({name:'Lamps and Chains',moves:24,colors:C5,big:[B('diyas',3,3,2,2,14)],ob:{chain:RING.concat([[0,4],[8,4]])},shape:full(9)}),
L({name:'Mud Lane',moves:22,colors:C5,ob:{mud:rows([7,8],[0,1,2,3,5,6,7,8])},intro:['mud'],shape:full(9),reward:{k:'atom',n:1}}),
L({name:'Lamps and Fruit',moves:24,colors:C5,big:[B('diyas',3,1,2,2,12),B('fruit',3,6,2,2,12)],shape:full(9)}),
L({name:'Muddy Diyas',moves:26,colors:C5,diya:[[0,1],[0,7]],ob:{mud:rows([8],[0,1,2,3,4,5,6,7,8]).concat([[7,0],[7,8],[7,4]])},shape:full(9)}),
L({name:'Chained Bottles',moves:24,colors:C5,big:[B('bottles',2,3,2,2,14)],ob:{chain:MID.concat([[4,0],[4,8],[0,0],[0,8]])},shape:full(9)}),
L({name:'Lamp and Sweets',moves:24,colors:C5,big:[B('diyas',3,1,2,2,12),B('sweets',3,6,2,2,12)],shape:full(9)}),
L({name:'Temple Night',moves:28,colors:C5,diya:[[0,1],[0,7]],big:[B('diyas',3,3,3,2,20)],ob:{chain:rows([6],[0,1,7,8]).concat([[2,0],[2,8],[8,3],[8,5]])},shape:full(9)}),
// Chapter 5: Festival Square
L({name:'Gift Stack',moves:22,colors:C5,big:[B('gifts',3,3,3,3,24)],intro:['gifts'],shape:full(9)}),
L({name:'Wet Crackers',moves:22,colors:C5,ob:{wet:[[4,4],[4,3],[4,5],[3,4],[5,4],[2,4]]},intro:['wet'],shape:full(9)}),
L({name:'Glass Blocks',moves:22,colors:C5,ob:{glass:rows([2,6],[2,6]).concat([[4,0],[4,8],[0,4],[8,4]])},intro:['glass'],shape:full(9)}),
L({name:'Gifts and Wet',moves:24,colors:C5,big:[B('gifts',2,3,2,2,14)],ob:{wet:[[6,2],[6,6],[7,4],[5,4]]},shape:full(9)}),
L({name:'Launch Night',moves:24,colors:C5,goal:{3:24},ob:{launcher:[[7,1],[7,7],[1,4]]},intro:['launcher'],shape:full(9),reward:{k:'matchbox',n:1}}),
L({name:'Gifts and Glass',moves:26,colors:C5,big:[B('gifts',3,3,3,3,18)],ob:{glass:[[1,1],[1,7],[7,1],[7,7],[1,4],[7,4]]},shape:full(9)}),
L({name:'Wet Mud',moves:26,colors:C5,goal:{2:20},ob:{wet:[[3,3],[3,5],[4,4],[2,4]],mud:rows([8],[0,1,2,3,4,5,6,7,8]).concat([[7,0],[7,8],[7,4]])},shape:full(9)}),
L({name:'Grand Hall',moves:26,colors:C5,big:[B('cups',3,1,2,2,12),B('diyas',3,6,2,2,12)],ob:{launcher:[[7,4],[0,4]]},shape:full(9)}),
L({name:'Gifts and Sweets',moves:28,colors:C5,big:[B('gifts',1,3,3,3,18),B('sweets',6,3,2,2,12)],shape:full(9)}),
L({name:'Grand Finale',moves:32,colors:C5,big:[B('gifts',2,1,2,2,12),B('fruit',2,6,2,2,12)],ob:{wet:[[6,4],[5,4],[6,3],[6,5]],glass:[[0,0],[0,8],[8,0],[8,8],[4,0],[4,8]]},shape:full(9)})
];
})();
