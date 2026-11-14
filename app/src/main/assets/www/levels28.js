// Build 28 (14 Nov 2026): Area 1 "Sivakasi Street" = levels 1-10 only (claude/level-boards-area1-14nov.md).
// Load after levels26.js. Replaces window.LEVELS.
// Map: . cracker  # no cell  c crate  w wooden crate (2 hits)  g gold floor  x crate on gold  X wooden crate on gold
//      o hidden hole (empty until the crates around it break)  K sweet-shop cabinet 2x2 (top-left; k = its other cells)
//      1 Rocket  2 Bomb  3 Colour Matchbox  4 Ground Chakra (placed at the start)
(function(){
var C3=[0,1,2],C4=[0,1,2,5],SPK={1:6,2:10,3:14,4:8};
function mk(o){var rows=o.rows,shape=rows.map(function(r){return r.replace(/[^#]/g,'x').replace(/#/g,'.')}),ob={},big=[],hide=[],pre=[];
 function add(t,r,c){(ob[t]=ob[t]||[]).push([r,c])}
 rows.forEach(function(row,r){for(var c=0;c<row.length;c++){var ch=row[c];
  if(ch=='c')add('crate',r,c);else if(ch=='w')add('steel',r,c);else if(ch=='g')add('gold',r,c);
  else if(ch=='x'){add('crate',r,c);add('gold',r,c)}else if(ch=='X'){add('steel',r,c);add('gold',r,c)}
  else if(ch=='o')hide.push([r,c]);else if(ch=='K')big.push({t:'cab',r:r,c:c,w:2,h:2,n:6});
  else if(SPK[ch])pre.push([r,c,SPK[ch]])}});
 var lv={name:o.name,moves:o.moves,colors:o.colors,shape:shape,ob:ob,big:big,goal:{},hide:hide,pre:pre,ltype:o.ltype||'n',luck:o.luck,
  intro:o.intro||[],teach:o.teach,mass:true,reward:o.reward,combo:o.combo,diyas:o.ltype=='h'?2:o.ltype=='s'?3:1};
 big.forEach(function(b){lv.goal[b.t]=(lv.goal[b.t]||0)+b.n});
 for(var k in ob)lv.goal[k]=ob[k].length;
 for(k in (o.goal||{}))lv.goal[k]=o.goal[k];
 return lv}
window.LEVELS=[
 mk({name:'Crate Start',moves:18,colors:C3,luck:.5,intro:['crate'],rows:['##....##','#......#','........','........','........','........','cccccccc','cccccccc','#cccccc#']}),
 mk({name:'Rocket Lesson',moves:18,colors:C3,luck:.5,teach:'rocket',intro:['rocket'],rows:['........','........','........','........','........','cccccccc','cccccccc','cccccccc','########']}),
 mk({name:'Hidden Hole',moves:20,colors:C3,luck:.5,teach:'line5',intro:['matchbox','hole'],rows:['........','........','........','cccccccc','ccoooocc','ccoooocc','ccoooocc','cccccccc','########']}),
 mk({name:'Gold Floor',moves:20,colors:C3,luck:.5,intro:['gold'],rows:['........','........','..1.....','gggggggg','gggggggg','gggggggg','#gggggg#','##gggg##','###gg###']}),
 mk({name:'Chakra Lesson',moves:18,colors:C3,luck:.5,teach:'square',intro:['chakra'],rows:['........','........','........','........','cc....cc','cc....cc','cccccccc','cccccccc','########']}),
 mk({name:'Gold Under Crates',moves:20,colors:C3,luck:.5,rows:['........','........','.....2..','gggxxggg','ggxxxxgg','gxxxxxxg','xxxxxxxx','gggggggg','gggggggg']}),
 mk({name:'Dig Down',moves:26,colors:C3,luck:.5,intro:['wood'],rows:['........','........','..1.....','........','........','xxxxxxxx','xxxxxxxx','xxxxxxxx','XxxXXxxX']}),
 mk({name:'Plus Board',moves:25,colors:C3,luck:.5,teach:'lshape',intro:['atom','helper'],rows:['........','........','........','cccccc2c','c2cccccc','cccccccc','##cccc##','##c2cc##','##cccc##']}),
 mk({name:'First Cabinets',moves:26,colors:C3,luck:.5,intro:['cab'],rows:['........','........','....1...','........','cccccccc','xxKkKkxx','xxkkkkxx','xxxxxxxx','cccccccc']}),
 mk({name:'Opening Blast',moves:30,colors:C4,luck:.34,ltype:'h',combo:{r:1,c:3,dr:0,dc:1},rows:['........','...31...','cccccccc','xKkxxKkx','xkkxxkkx','cccccccc','XxxxxxxX','XxxxxxxX','xxXXXXxx']})
];
})();
