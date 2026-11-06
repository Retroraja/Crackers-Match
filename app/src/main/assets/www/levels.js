// Cracker colours: 0 Bijli, 1 Kuruvi, 2 Pencil, 3 Twinkling Star, 4 Snake Tablet, 5 Lakshmi Vedi
function row(r,cols){return cols.map(function(c){return[r,c]})}
function all(){return[].concat.apply([],arguments)}
window.LEVELS=[
{name:'Bijli Street',moves:22,colors:[0,1,2,3,4],goal:{0:10},shape:['xxxxxxx','xxxxxxx','xxxxxxx','xxxxxxx','xxxxxxx','xxxxxxx','xxxxxxx']},
{name:'Kuruvi Corner',moves:16,colors:[1,0,2,3,4],goal:{1:15},teach:'rocket',intro:['rocket'],shape:['.xxxxx.','xxxxxxx','xxxxxxx','xxxxxxx','xxxxxxx','xxxxxxx','.xxxxx.']},
{name:'Crate Junction',moves:18,colors:[2,3,0,1,4,5],goal:{wrap:12},intro:['wrap'],shape:['xxxxxxxx','xxxxxxxx','xxxxxxxx','..xxxx..','..xxxx..','..xxxx..','..xxxx..','..xxxx..'],wrap:all(row(2,[1,2,3,4,5,6]),row(3,[2,3,4,5]),row(4,[3,4]))},
{name:'Lakshmi Bazaar',moves:24,colors:[5,0,1,2,3,4],goal:{5:20,wrap:8},shape:['..xxxx..','..xxxx..','xxxxxxxx','xxxxxxxx','xxxxxxxx','xxxxxxxx','..xxxx..','..xxxx..'],wrap:[[3,0],[3,7],[4,0],[4,7],[2,2],[2,5],[5,2],[5,5]],reward:{k:'sparkler',n:1}},
{name:'Rangoli Road',moves:22,colors:[4,0,1,2,3,5],goal:{rang:14},teach:'square',intro:['flowerpot','rang'],shape:['....x....','...xxx...','..xxxxx..','.xxxxxxx.','xxxxxxxxx','.xxxxxxx.','..xxxxx..','...xxx...','....x....'],rang:[[1,3],[1,5],[2,2],[2,6],[3,1],[3,7],[4,0],[4,8],[5,1],[5,7],[6,2],[6,6],[7,3],[7,5]]},
{name:'Thread Lane',moves:22,colors:[2,0,1,3,4,5],goal:{tie:8,2:15},intro:['tie'],shape:['xxxxxxxx','xxxxxxxx','.xxxxxx.','..xxxx..','...xx...','..xxxx..','.xxxxxx.','xxxxxxxx','xxxxxxxx'],tie:all(row(1,[1,3,4,6]),row(7,[1,3,4,6]))},
{name:'Diya Kovil',moves:20,colors:[0,1,2,3,4,5],goal:{wrap:13},intro:['wrap2'],shape:['....x....','...xxx...','...xxx...','xxxxxxxxx','xxxxxxxxx','.xxxxxxx.','..xxxxx..','...xxx...'],wrap2:[[3,1],[3,2],[3,6],[3,7],[4,3],[4,4],[4,5],[5,2],[5,6]],wrap:[[6,3],[6,5],[4,1],[4,7]]},
{name:'Temple Ring',moves:28,colors:[0,1,2,3,4],goal:{diya:2},intro:['diya'],shape:['xxxxxxxx','xxxxxxxx','xxxxxxxx','xxx..xxx','xxx..xxx','xxx..xxx','xxxxxxxx','xxxxxxxx','xxxxxxxx'],diya:[[0,1],[0,6]]},
{name:'Rocket Theru',moves:24,colors:[1,0,2,3,5,4],goal:{rang:12,tie:6},shape:['...x...','..xxx..','..xxx..','.xxxxx.','.xxxxx.','.xxxxx.','.xxxxx.','xxxxxxx','xx.x.xx','x..x..x'],rang:all(row(3,[1,5]),row(4,[1,5]),row(5,[1,5]),row(6,[1,5]),row(7,[0,6]),row(8,[0,6])),tie:all(row(4,[2,4]),row(6,[2,4]),row(2,[2,4])),reward:{k:'wala',n:1}},
{name:'Star Maidan',moves:30,colors:[3,0,1,2,5,4],goal:{wet:4,3:30},teach:'lshape',intro:['chakra','wet'],shape:['....x....','...xxx...','xxxxxxxxx','.xxxxxxx.','..xxxxx..','.xxxxxxx.','.xxx.xxx.','xx.....xx'],wet:[[3,4],[4,3],[4,4],[4,5]],reward:{k:'atom',n:1}}
];
window.MAP=[[382,1590],[635,1375],[340,1215],[590,1070],[393,875],[629,725],[450,590],[589,465],[380,360],[500,250]];
