// Cracker colours: 0 Bijli, 1 Kuruvi, 2 Pencil, 3 Twinkling Star, 4 Snake Tablet, 5 Lakshmi Vedi
function band(w,rows,cols){var a=[];rows.forEach(function(r){cols.forEach(function(c){a.push([r,c])})});return a}
window.LEVELS=[
{w:7,h:7,moves:28,colors:[0,1,2,3],goal:{0:10},tip:'Swap two side-by-side crackers to line up 3 of a kind. Collect the Bijli.'},
{w:7,h:7,moves:28,colors:[1,0,2,3],goal:{1:15},teach:'rocket',tip:'Match 4 in a line to make a Rocket.'},
{w:7,h:8,moves:30,colors:[2,3,0,1],goal:{2:15,3:15},tip:'Tap a Rocket to fire it. Drag it first to fire from the next tile.'},
{w:7,h:8,moves:30,colors:[5,0,1,2],goal:{5:20},tip:'Every special cracker costs 1 move, so pick your moment.',reward:{k:'sparkler',n:1}},
{w:7,h:8,moves:32,colors:[4,0,1,2],goal:{4:15,0:15},teach:'square',tip:'Match a 2×2 square to make a Flowerpot.'},
{w:8,h:8,moves:32,colors:[0,1,2,3],goal:{wrap:12},wrap:band(8,[3,4],[1,2,3,4,5,6]),tip:'New: crates. Make a match next to a crate, or blast it, to clear it.'},
{w:8,h:8,moves:32,colors:[0,1,2,3,4],goal:{wrap:18},wrap:band(8,[2,3,4],[1,2,3,4,5,6]),tip:'Specials clear lots of crates at once.',reward:{k:'rail',n:1}},
{w:8,h:9,moves:30,colors:[0,1,2,3,4],goal:{wrap:24},wrap:band(8,[3,4,5,6],[1,2,3,4,5,6]),tip:'Your first hard level. Plan your moves.'},
{w:8,h:8,moves:32,colors:[1,0,2,3,5],goal:{1:25},tip:'Enjoy the big chains.',reward:{k:'wala',n:1}},
{w:8,h:9,moves:32,colors:[3,0,1,2,5],goal:{3:30},teach:'lshape',tip:'Match an L or T shape to make a Ground Chakra.',reward:{k:'atom',n:1}}
];
