// Levels 8-50 in the mass-obstacle style (build 26, 11 Nov 2026). Load after levels.js.
// Only the top 2-3 rows are free; the rest of the board is a big block of obstacles you dig through.
// Each chapter has its own shape: 1 dig down, 2 side columns, 3 centre block / T, 4 staircase, 5 strips.
// Map: . cracker   # no cell   p clay pot   P big pot (2 hits)   c crate   w wooden crate (2 hits)   s stone (3 hits)
//      i ice (on a cracker)   h chain (on a cracker)   g gold floor (under a cracker)   G gift box   L lantern   F firecracker box
//      C / S / T  cup / sweet / gift rack (3x3, top-left corner; the other 8 cells are r)
(function(){
var OBK={p:'dpot',P:'pot',c:'crate',w:'steel',s:'stone',i:'ice',h:'chain',g:'gold',G:'gbox',L:'lantern',F:'fbox'},RK={C:'rackc',S:'racks',T:'rackg'};
var C4=[0,1,2,5],C5=[0,1,2,3,5];
function mk(rows,o){var shape=rows.map(function(r){return r.replace(/[^#]/g,'x').replace(/#/g,'.')}),ob={},big=[];
 rows.forEach(function(row,r){for(var c=0;c<row.length;c++){var ch=row[c];if(OBK[ch])(ob[OBK[ch]]=ob[OBK[ch]]||[]).push([r,c]);if(RK[ch])big.push({t:RK[ch],r:r,c:c,w:3,h:3,n:9})}});
 var L0=o.base||{},lv={name:o.name||L0.name,moves:o.moves,colors:o.colors||L0.colors,shape:shape,ob:ob,big:big,goal:{}};
 ['intro','teach','reward','preSp','preK','boxK'].forEach(function(k){if(L0[k]!=null)lv[k]=L0[k]});if(o.intro)lv.intro=o.intro;if(o.boxK!=null)lv.boxK=o.boxK;
 for(var k in (o.goal||{}))lv.goal[k]=o.goal[k];
 // goals from what is on the board, as levels.js does
 var used={};big.forEach(function(b){lv.goal[b.t]=(lv.goal[b.t]||0)+9});for(k in ob){if(k!='gbox')lv.goal[k]=ob[k].length}
 if(ob.gbox&&lv.boxK==null)lv.boxK=lv.colors[0];
 return lv}
var M={};// index (0-based) -> layout
// ===== Chapter 1: Village, dig down =====
M[7]={name:'Dig Down',moves:42,rows:['........','........','........','cccccccc','ccwwwwcc','cccccccc','........','........','iiiiiiii']};
M[8]={name:'Chain Gate',moves:43,rows:['........','........','cccccccc','cccccccc','cwwccwwc','cccccccc','........','hhhh....','iiiihhhh']};
M[9]={name:'Diwali Gate',moves:38,rows:['........','........','........','cccccccc','ccwwwwcc','ccwwwwcc','cccccccc','gggggggg','gggggggg']};
// ===== Chapter 2: Market, side columns =====
M[10]={name:'Pot Columns',moves:42,rows:['........','........','........','ppp..ppp','ppp..ppp','ppp..ppp','ppp..ppp','........','........']};
M[11]={name:'Pot Square',moves:42,rows:['........','........','pp....pp','pp....pp','ppwwwwpp','ppwwwwpp','pp....pp','pp....pp','pppppppp']};
M[12]={name:'Crate Lanes',moves:42,rows:['........','........','........','cc....cc','cc.pp.cc','cc.pp.cc','cc.pp.cc','........','........']};
M[13]={name:'Gold Pockets',moves:42,rows:['........','........','pp....pp','ppgggg pp'.replace(' ',''),'ppggggpp','ppggggpp','ppggggpp','pp....pp','pppppppp']};
M[14]={name:'Market Gate',moves:45,rows:['........','........','........','www..www','wwwggwww','pwwggwwp','pppggppp','pp.gg.pp','iiiiiiii']};
M[15]={name:'Bijli Bazaar',moves:32,goal:{0:40},rows:['........','........','........','pp....pp','pp....pp','pp....pp','........','........','........']};
M[16]={name:'Gift Box',moves:21,goal:{1:90},boxK:1,rows:['........','........','........','pp.G..pp','pp....pp','pp..G.pp','pp....pp','pp....pp','pppppppp']};
M[17]={name:'Gift and Pots',moves:36,goal:{2:70},boxK:2,rows:['........','........','........','ppp..ppp','ppG..Gpp','ppp..ppp','pppppppp','pppppppp','pppppppp']};
M[18]={name:'Gold and Chains',moves:38,rows:['........','........','cc....cc','cc....cc','ccggggcc','ccggggcc','ccggggcc','cchhhhcc','iiiiiiii']};
M[19]={name:'Diwali Market',moves:25,goal:{0:60},boxK:0,rows:['........','........','........','wwG..Gww','ww....ww','ppggggpp','ppggggpp','pppppppp','pppppppp']};
// ===== Chapter 3: Sweet Shop, centre block and T-shape =====
M[20]={name:'Cup Rack',moves:42,rows:['........','........','pppppppp','pCrrpppp','prrrpppp','prrrpppp','pppppppp','pppppppp','........']};
M[21]={name:'Twin Racks',moves:45,rows:['........','........','pppppppp','pCrrSrrp','prrrrrrp','prrrrrrp','pppppppp','........','iiiiiiii']};
M[22]={name:'Five Crackers',moves:38,goal:{3:30},rows:['........','........','........','cccccccc','cwwccwwc','cccccccc','........','........','........']};
M[23]={name:'Sweet Counter',moves:42,rows:['#......#','#......#','#pppppp#','pppppppp','pCrrTrrp','prrrrrrp','prrrrrrp','........','........']};
M[24]={name:'Sweet Shop Gate',moves:45,rows:['#......#','#......#','#......#','pppppppp','pSrrCrrp','prrrrrrp','prrrrrrp','........','iiiiiiii']};
M[25]={name:'Laddu Lane',moves:22,goal:{0:70},boxK:0,rows:['........','........','........','pp.G..pp','pp....pp','pp..G.pp','pp....pp','pppppppp','........']};
M[26]={name:'Gift Rack',moves:42,rows:['#......#','#......#','pppppppp','ppTrrppp','pprrrppp','pprrrppp','pppppppp','gggggggg','gggggggg']};
M[27]={name:'Rack Row',moves:42,rows:['........','........','........','cccccccc','cCrrSrrc','crrrrrrc','crrrrrrc','........','........']};
M[28]={name:'Gold Shop',moves:42,rows:['#......#','#......#','#......#','wwwwwwww','wggggggw','wggggggw','wggggggw','........','gggggggg']};
M[29]={name:'Grand Sweets',moves:48,rows:['........','........','pppppppp','pCrrTrrp','prrrrrrp','prrrrrrp','pggggggp','.hhhhhh.','iiiiiiii']};
// ===== Chapter 4: Temple Road, staircase =====
M[30]={name:'Temple Steps',moves:48,rows:['........','........','......cc','.....ccc','....cccc','...ccccc','..cccccc','LLcccccc','ppcccccc']};
M[31]={name:'Lantern Climb',moves:42,rows:['........','........','cc......','ccc.....','ccccL...','cccccL..','ccccccL.','........','........']};
M[32]={name:'Lantern Walls',moves:42,rows:['........','........','.......w','......ww','..L..www','....wwww','..L.wwww','........','........']};
M[33]={name:'Firecracker Box',moves:48,goal:{1:30},rows:['........','........','ww......','www.....','wwwwF...','wwwwwp..','wwwwwwp.','........','........']};
M[34]={name:'Temple Climb',moves:48,rows:['........','........','cc......','ccc.....','ccccF...','cccccpp.','cccccppp','ccccccpp','cccccccc']};
M[35]={name:'Bell Street',moves:42,goal:{2:90},boxK:2,rows:['........','........','......cc','..G..ccc','....cccc','...ccccc','.G.ccccc','..cccccc','.ccccccc']};
M[36]={name:'Lantern Garden',moves:42,rows:['........','........','.......c','......cc','gL...ccc','ggL.cccc','gggLcccc','ggggcccc','gggccccc']};
M[37]={name:'Box and Rack',moves:48,rows:['........','........','cc......','ccc.....','cccF....','ccccCrr.','ccccrrr.','ccccrrrp','ccccccpp']};
M[38]={name:'Chain Temple',moves:48,rows:['........','........','......ww','.....www','....wwww','..hhwwww','.hhwwwww','hh......','ii......']};
M[39]={name:'Temple Gate',moves:48,rows:['........','........','ww....ww','wLggggLw','wSrrTrrw','wrrrrrrw','wrrrrrrw','..gggg..','iiiiiiii']};
// ===== Chapter 5: Grand Festival, strips =====
M[40]={name:'Festival Lanes',moves:27,rows:['........','........','........','ggcggcgg','ggcggcgg','ggcggcgg','ggcggcgg','ggcggcgg','ggcggcgg']};
M[41]={name:'Star Lanes',moves:37,rows:['........','........','........','gpggpggp','gpggpggp','gpggpggp','gpggpggp','gpggpggp','gpggpggp']};
M[42]={name:'Split Lanes',moves:42,goal:{1:30},rows:['........','........','........','pp.pp.pp','pp.pp.pp','pp.pp.pp','pp.pp.pp','........','iiiiiiii']};
M[43]={name:'Lantern Sky',moves:42,rows:['........','........','........','cLccLccL','c.cc.cc.','c.cc.cc.','c.cc.cc.','........','........']};
M[44]={name:'Festival Square',moves:42,rows:['........','........','........','cc.cc.cc','cc.cc.cc','CrrSrrTr'.replace('Tr','cc'),'rrrrrrcc','rrrrrrcc','gggggggg']};
M[45]={name:'Sparkle Street',moves:28,goal:{3:90},boxK:3,rows:['........','........','........','.p.G.p..','.p...p.p','.p.p.p.p','.pGp.p.p','.p.p.p.p','.p.p.p.p']};
M[46]={name:'Pot Lanes',moves:42,rows:['........','........','........','pp.pp.pp','pp.pp.pp','pp.pp.pp','pp.pp.pp','........','iiiiiiii']};
M[47]={name:'Firecracker Fair',moves:42,rows:['........','........','........','pFppFppF','p.pp.pp.','p.pp.pp.','p.pp.pp.','........','iiiiiiii']};
M[48]={name:'Golden Night',moves:42,rows:['........','........','........','gwggwggw','gwggwggw','gwggwggw','gwggwggw','gwggwggw','hhhhhhhh']};
M[49]={name:'Grand Finale',moves:25,goal:{0:40},boxK:0,rows:['........','........','........','LG.ww.GL','ggwwwwwg','ggCrrwwg','ggrrrwwg','ggrrrwwg','hhhhhhhh']};
var LV=window.LEVELS;
Object.keys(M).forEach(function(k){var i=+k,m=M[k],base=LV[i],cols=i>=22?C5:C4;
 // keep the first-time intro banners where a new obstacle first appears
 var lv=mk(m.rows,{base:base,name:m.name,moves:m.moves,colors:base&&base.colors&&base.colors.length==cols.length?base.colors:cols,goal:m.goal,boxK:m.boxK});
 lv.mass=1;LV[i]=lv});
// intro banners where each obstacle or special first appears
var IN={7:['atom'],8:['chain'],10:['dpot'],13:['gold'],16:['gbox'],20:['rackc'],21:['racks'],23:['rackg'],30:['lantern'],33:['fbox']};
LV.forEach(function(l,i){if(i<7)return;if(IN[i])l.intro=IN[i];else delete l.intro});
})();

// ===== Build 27 (11 Nov): human-style moves, trimmed heavy boards, bigger cracker goals, lucky refills
(function(){var LV=window.LEVELS;
 var MV={8:24,9:23,10:20,11:26,12:24,13:23,14:25,15:22,16:18,17:25,18:23,19:22,20:19,21:26,22:24,23:24,24:22,25:21,26:17,27:24,28:22,29:22,30:18,31:26,32:24,33:23,34:24,35:21,36:17,37:23,38:22,39:21,40:18,41:25,42:23,43:22,44:22,45:20,46:16,47:22,48:21,49:20,50:17};
 var TRIM={20:1,26:1,36:3,46:1,50:1,24:2,25:1,28:2,30:1,33:2,34:2,39:2,40:1,47:2,15:1,21:1,29:1,31:1,35:1,38:1,48:1,49:1};
 var RELIEF={16:1,26:1,36:1,46:1};
 function type(n){return n%10==0?'sh':n%5==0?'h':RELIEF[n]?'r':'n'}
 var LUCK={r:.5,n:1/3,h:.2,sh:.125};
 var DIG={dpot:1,pot:1,crate:1,steel:1,stone:1};
 LV.forEach(function(l,i){var n=i+1;l.luck=LUCK[type(n)];l.ltype=type(n);if(i<7)return;
  if(MV[n])l.moves=MV[n];
  // trim: clear the lowest rows of the dig block (pots, crates, stone); racks, gift boxes, lanterns, boxes, ice, chain and gold stay
  var t=TRIM[n];if(t&&l.ob){var rows={};Object.keys(DIG).forEach(function(k){(l.ob[k]||[]).forEach(function(p){rows[p[0]]=1})});
   var rs=Object.keys(rows).map(Number).sort(function(a,b){return b-a}).slice(0,t),cut={};rs.forEach(function(r){cut[r]=1});
   Object.keys(DIG).forEach(function(k){if(!l.ob[k])return;l.ob[k]=l.ob[k].filter(function(p){return !cut[p[0]]});if(l.goal[k]!=null)l.goal[k]=l.ob[k].length;if(!l.ob[k].length){delete l.ob[k];delete l.goal[k]}})}
  // cracker goals up about 20% (lucky refills give more specials)
  Object.keys(l.goal).forEach(function(k){if(!/^\d+$/.test(k))return;var g=l.ltype=='r'?l.goal[k]:Math.round(l.goal[k]*1.2),cap=l.moves*(l.ltype=='r'?3:l.boxK!=null?4.5:3);l.goal[k]=Math.min(g,Math.round(cap))})})})();
