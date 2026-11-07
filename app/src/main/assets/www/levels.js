// Cracker colours: 0 Bijli, 1 Kuruvi, 2 Pencil, 3 Twinkling Star, 4 Snake Tablet, 5 Lakshmi Vedi
function row(r,cols){return cols.map(function(c){return[r,c]})}
function all(){return[].concat.apply([],arguments)}
window.LEVELS=[
{name:'Bijli Street',moves:15,colors:[0,1,2,3,4],goal:{0:12},shape:['xxxxxxxx','xxxxxxxx','xxxxxxxx','xxxxxxxx','xxxxxxxx','xxxxxxxx','xxxxxxxx','xxxxxxxx']},
{name:'Kuruvi Corner',moves:13,colors:[1,0,2,3,4],goal:{1:18},teach:'rocket',intro:['rocket'],shape:['.xxxxxx.','xxxxxxxx','xxxxxxxx','xxxxxxxx','xxxxxxxx','xxxxxxxx','xxxxxxxx','xxxxxxxx','.xxxxxx.']},
{name:'Crate Junction',moves:14,colors:[2,3,0,1,4],goal:{crate:14},intro:['crate'],shape:['..xxxx..','.xxxxxx.','xxxxxxxx','xxxxxxxx','xxxxxxxx','xxxxxxxx','xxxxxxxx','.xxxxxx.','..xxxx..'],ob:{crate:all(row(3,[1,2,3,4,5,6]),row(4,[1,2,3,4,5,6]),row(5,[3,4]))}},
{name:'Lakshmi Bazaar',moves:16,colors:[5,0,1,2,3],goal:{5:20,gift:8},intro:['gift'],shape:['.xxxxxxx.','xxxxxxxxx','xxxxxxxxx','xxxxxxxxx','xxxxxxxxx','xxxxxxxxx','xxxxxxxxx','xxxxxxxxx','.xxxxxxx.'],ob:{gift:[[2,2],[2,6],[6,2],[6,6],[4,0],[4,8],[0,4],[8,4]]},reward:{k:'sparkler',n:1}},
{name:'Rangoli Road',moves:16,colors:[4,0,1,2,3],goal:{rang:16,pot:4},teach:'square',intro:['flowerpot','rang','pot'],shape:['xxxxxxxxx','xxxxxxxxx','xxxxxxxxx','xxxxxxxxx','xxxx.xxxx','xxxxxxxxx','xxxxxxxxx','xxxxxxxxx','xxxxxxxxx'],ob:{rang:all(row(1,[1,2,6,7]),row(2,[1,7]),row(6,[1,7]),row(7,[1,2,6,7]),row(4,[0,8])),pot:[[3,4],[5,4],[4,3],[4,5]]}},
{name:'Thread Lane',moves:14,colors:[2,0,1,3,4],goal:{thread:10,2:15},intro:['thread'],shape:['.xxxxxx.','xxxxxxxx','xxxxxxxx','xxxxxxxx','xxxxxxxx','xxxxxxxx','xxxxxxxx','xxxxxxxx','.xxxxxx.'],ob:{thread:all(row(2,[1,2,5,6]),row(6,[1,2,5,6]),row(4,[3,4]))}},
{name:'Diya Kovil',moves:18,colors:[0,1,2,3,4],goal:{steel:10,stone:4},intro:['steel','stone'],shape:['..xxxxx..','.xxxxxxx.','xxxxxxxxx','xxxxxxxxx','xxxxxxxxx','xxxxxxxxx','xxxxxxxxx','.xxxxxxx.','..xxxxx..'],ob:{steel:all(row(3,[1,2,3,5,6,7]),row(5,[2,3,5,6])),stone:[[4,1],[4,7],[6,4],[2,4]]}},
{name:'Temple Ring',moves:26,colors:[0,1,2,3,4],goal:{diya:2,ice:6},intro:['diya','ice','mud'],shape:['xxxxxxxxx','xxxxxxxxx','xxxxxxxxx','xxxxxxxxx','xxxx.xxxx','xxxxxxxxx','xxxxxxxxx','xxxxxxxxx','xxxxxxxxx'],diya:[[0,1],[0,7]],ob:{ice:all(row(6,[1,2,6,7]),row(2,[3,5])),mud:all(row(8,[0,1,2,3,4,5,6,7,8]))}},
{name:'Rocket Theru',moves:14,colors:[1,0,2,3,4],goal:{chain:6,glass:4,launcher:2},intro:['chain','glass','launcher'],shape:['.xxxxxx.','xxxxxxxx','xxxxxxxx','xxxxxxxx','xxxxxxxx','xxxxxxxx','xxxxxxxx','xxxxxxxx','.xxxxxx.'],ob:{chain:all(row(2,[2,5]),row(4,[2,5]),row(6,[2,5])),glass:all(row(3,[0,7]),row(5,[0,7])),launcher:[[7,3],[1,4]]},reward:{k:'wala',n:1}},
{name:'Star Maidan',moves:14,colors:[3,0,1,2,4],goal:{wet:4,3:20},teach:'lshape',intro:['chakra','wet'],shape:['.xxxxxxx.','xxxxxxxxx','xxxxxxxxx','xxxxxxxxx','xxxxxxxxx','xxxxxxxxx','xxxxxxxxx','xxxxxxxxx','.xxxxxxx.'],ob:{wet:[[4,4],[4,3],[4,5],[3,4]]},reward:{k:'atom',n:1}}
];
window.MAP=[[440,1470],[535,1360],[470,1180],[320,1080],[470,940],[560,840],[440,720],[330,610],[540,470],[410,356]];
