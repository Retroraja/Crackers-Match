// Cracker colours: 0 Bijli, 1 Kuruvi, 2 Pencil, 3 Twinkling Star, 4 Snake Tablet, 5 Lakshmi Vedi
function row(r,cols){return cols.map(function(c){return[r,c]})}
function all(){return[].concat.apply([],arguments)}
window.LEVELS=[
{name:'Bijli Street',moves:22,colors:[0,1,2,3,4],goal:{0:10},shape:['xxxxxxx','xxxxxxx','xxxxxxx','xxxxxxx','xxxxxxx','xxxxxxx','xxxxxxx']},
{name:'Kuruvi Corner',moves:16,colors:[1,0,2,3,4],goal:{1:15},teach:'rocket',intro:['rocket'],shape:['.xxxxx.','xxxxxxx','xxxxxxx','xxxxxxx','xxxxxxx','xxxxxxx','.xxxxx.']},
{name:'Crate Junction',moves:18,colors:[2,3,0,1,4,5],goal:{crate:12},intro:['crate'],shape:['xxxxxxxx','xxxxxxxx','xxxxxxxx','..xxxx..','..xxxx..','..xxxx..','..xxxx..','..xxxx..'],ob:{crate:all(row(2,[1,2,3,4,5,6]),row(3,[2,3,4,5]),row(4,[3,4]))}},
{name:'Lakshmi Bazaar',moves:26,colors:[5,0,1,2,3,4],goal:{5:20,gift:8},intro:['gift'],shape:['..xxxx..','..xxxx..','xxxxxxxx','xxxxxxxx','xxxxxxxx','xxxxxxxx','..xxxx..','..xxxx..'],ob:{gift:[[3,0],[3,7],[4,0],[4,7],[2,2],[2,5],[5,2],[5,5]]},reward:{k:'sparkler',n:1}},
{name:'Rangoli Road',moves:22,colors:[4,0,1,2,3,5],goal:{rang:14,pot:4},teach:'square',intro:['flowerpot','rang','pot'],shape:['....x....','...xxx...','..xxxxx..','.xxxxxxx.','xxxxxxxxx','.xxxxxxx.','..xxxxx..','...xxx...','....x....'],ob:{rang:[[1,3],[1,5],[2,2],[2,6],[3,1],[3,7],[4,0],[4,8],[5,1],[5,7],[6,2],[6,6],[7,3],[7,5]],pot:[[4,3],[4,5],[3,4],[5,4]]}},
{name:'Thread Lane',moves:22,colors:[2,0,1,3,4,5],goal:{thread:8,2:15},intro:['thread'],shape:['xxxxxxxx','xxxxxxxx','.xxxxxx.','..xxxx..','...xx...','..xxxx..','.xxxxxx.','xxxxxxxx','xxxxxxxx'],ob:{thread:all(row(1,[1,3,4,6]),row(7,[1,3,4,6]))}},
{name:'Diya Kovil',moves:22,colors:[0,1,2,3,4],goal:{steel:9,stone:4},intro:['steel','stone'],shape:['....x....','...xxx...','...xxx...','xxxxxxxxx','xxxxxxxxx','.xxxxxxx.','..xxxxx..','...xxx...'],ob:{steel:[[3,1],[3,2],[3,6],[3,7],[4,3],[4,4],[4,5],[5,2],[5,6]],stone:[[6,3],[6,5],[4,1],[4,7]]}},
{name:'Temple Ring',moves:28,colors:[0,1,2,3,4],goal:{diya:2,ice:6},intro:['diya','ice','mud'],shape:['xxxxxxxx','xxxxxxxx','xxxxxxxx','xxx..xxx','xxx..xxx','xxx..xxx','xxxxxxxx','xxxxxxxx','xxxxxxxx'],diya:[[0,1],[0,6]],ob:{ice:all(row(6,[1,2,5,6]),row(2,[3,4])),mud:all(row(8,[0,1,2,3,4,5,6,7]))}},
{name:'Rocket Theru',moves:24,colors:[1,0,2,3,5,4],goal:{chain:6,glass:4,launcher:2},intro:['chain','glass','launcher'],shape:['...x...','..xxx..','..xxx..','.xxxxx.','.xxxxx.','.xxxxx.','.xxxxx.','xxxxxxx','xx.x.xx','x..x..x'],ob:{chain:all(row(4,[2,4]),row(6,[2,4]),row(2,[2,4])),glass:all(row(3,[1,5]),row(5,[1,5])),launcher:[[7,3],[1,3]]},reward:{k:'wala',n:1}},
{name:'Star Maidan',moves:30,colors:[3,0,1,2,5,4],goal:{wet:4,3:30},teach:'lshape',intro:['chakra','wet'],shape:['....x....','...xxx...','xxxxxxxxx','.xxxxxxx.','..xxxxx..','.xxxxxxx.','.xxx.xxx.','xx.....xx'],ob:{wet:[[3,4],[4,3],[4,4],[4,5]]},reward:{k:'atom',n:1}}
];
window.MAP=[[440,1470],[535,1360],[470,1180],[320,1080],[470,940],[560,840],[440,720],[330,610],[540,470],[410,356]];
