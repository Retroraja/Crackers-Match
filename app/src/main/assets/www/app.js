(function(){
var $=function(i){return document.getElementById(i)},NAMES=['Bijli','Kuruvi','Pencil','Twinkling Star','Snake Tablet','Lakshmi Vedi'],IDX={sparkler:11,rail:13,wala:12,atom:10},SL=['sparkler','rail','wala','atom'],LBL={sparkler:'Sparkler',rail:'Rail Cracker',wala:'1000-Wala',atom:'Atom Bomb'};
var S={lv:0,coins:0,diyas:0,best:{},inv:{}};function load(){try{var j=localStorage.getItem('cm_save');if(j)S=JSON.parse(j)}catch(e){}}function save(){try{localStorage.setItem('cm_save',JSON.stringify(S))}catch(e){}}load();
function fit(){var k=Math.min(innerWidth/390,innerHeight/844);$('stage').style.transform='scale('+k+')'}addEventListener('resize',fit);fit();
function show(id){['intro','home','game','win','lose','done'].forEach(function(x){$(x).classList.toggle('on',x==id)})}
function goalHTML(g,cls){var h='';Object.keys(g).forEach(function(k){h+='<div>'+(k=='wrap'?'<svg width="50" height="56" viewBox="0 0 50 56" role="img" aria-label="Paper Wrapping"><rect x="3" y="5" width="44" height="46" rx="9" fill="#CEA670"/><rect x="21" y="5" width="8" height="46" fill="#E8123C"/><rect x="3" y="24" width="44" height="8" fill="#E8123C"/><circle cx="25" cy="28" r="7" fill="#FFC62B"/></svg>':'<img src="'+CRK.b[k]+'" alt="'+NAMES[k]+'">')+'<span>'+g[k]+'</span></div>'});return h}
function home(){var i=Math.min(S.lv,9),L=LEVELS[i],f=S.lv>9;$('hCoins').textContent=S.coins;$('hDiyas').textContent=S.diyas;$('hLevel').textContent=f?'All done':'Level '+(i+1);$('hMoves').textContent=f?'':L.moves+' moves';$('hOf').textContent=f?'Level 10 of 10':'Level '+(i+1)+' of 10';$('hGoalT').textContent=f?'More levels are coming':(L.goal.wrap?'Open the Paper Wrapping':'Collect these crackers');$('hGoals').innerHTML=f?'':goalHTML(L.goal);var h='';for(var n=0;n<10;n++)h+='<i class="'+(n<S.lv?'d':n==S.lv?'n':'')+'"></i>';$('hStrip').innerHTML=h+'<img src="art/ui-chest.webp" alt="Chest">';$('bPlay').textContent=f?'Replay Level 10':'Play';$('bSound').classList.toggle('off',!SFX.isOn());show('home')}
var game=null,guy=null,cur=0;
function slots(){var h='';SL.forEach(function(k){var n=S.inv[k]||0;if(cur>=9||k!='atom'||n)h+='';h+='<div class="slot'+(n?'':' none')+'" data-k="'+k+'" aria-label="'+LBL[k]+'"><img src="'+CRK.b[IDX[k]]+'" alt=""><b>'+n+'</b></div>'});$('slots').innerHTML=h}
function hud(g){var h='',L=LEVELS[cur];Object.keys(L.goal).forEach(function(k){var v=Math.max(0,g[k]);h+='<div>'+(k=='wrap'?'<svg width="56" height="56" viewBox="0 0 50 50" role="img" aria-label="Paper Wrapping"><rect x="3" y="3" width="44" height="44" rx="9" fill="#CEA670"/><rect x="21" y="3" width="8" height="44" fill="#E8123C"/><rect x="3" y="21" width="44" height="8" fill="#E8123C"/></svg>':'<img src="'+CRK.b[k]+'" alt="'+NAMES[k]+'">')+'<b class="'+(v?'':'ok')+'">'+(v||'&#10003;')+'</b></div>'});$('gGoals').innerHTML=h}
function start(i){cur=i;var L=LEVELS[i];if(game)game.stopped=true;show('game');var cv=$('board'),n=cv.cloneNode();cv.parentNode.replaceChild(n,cv);$('gMoves').textContent=L.moves;hud(L.goal);slots();
 game=new CrackersGame(n,L,{moves:function(m){$('gMoves').textContent=m},goal:hud,cheer:function(c){if(c<2)return;var e=$('cheer');e.textContent=['','','Super!','Dhamaka!','Blast!'][Math.min(c,4)];e.classList.remove('go');void e.offsetWidth;e.classList.add('go')},win:won,lose:lost});
 $('tLevel').textContent='Level '+(i+1);$('tText').textContent=L.tip;$('tGoals').innerHTML=goalHTML(L.goal);$('tip').classList.add('on');window.__game=game}
function won(mv){var L=LEVELS[cur],d=mv>=L.moves*.4?3:mv>=L.moves*.2?2:1,old=S.best[cur]||0,msg='+'+(20+mv*5)+' coins';if(d>old){S.diyas+=d-old;S.best[cur]=d}S.coins+=20+mv*5;var first=cur>=S.lv;if(first&&L.reward){S.inv[L.reward.k]=(S.inv[L.reward.k]||0)+L.reward.n;msg+=' and 1 free '+LBL[L.reward.k]}if(first)S.lv=cur+1;save();SFX.win();
 setTimeout(function(){game.stopped=true;show('win');$('wReward').style.display='none';$('wReward').textContent=msg;if(!guy){guy=new WinGuy($('guy'),{diya:'art/ui-diya.webp'});guy.once=true}else guy.replay();guy.nd=d},900)}
function lost(){SFX.lose();setTimeout(function(){game.stopped=true;show('lose')},700)}
$('bGo').onclick=function(){SFX.unlock();$('tip').classList.remove('on')};
$('bPlay').onclick=function(){SFX.unlock();start(Math.min(S.lv,9))};
$('bQuit').onclick=function(){if(game)game.stopped=true;home()};
$('bNext').onclick=function(){if(S.lv>9&&cur>=9)show('done');else start(Math.min(cur+1,9))};
$('bRetry').onclick=function(){start(cur)};$('bHome').onclick=home;$('bHome2').onclick=home;
$('bSound').onclick=function(){SFX.unlock();this.classList.toggle('off',!SFX.toggle())};
$('bReset').onclick=function(){var b=this;if(b.dataset.a){S={lv:0,coins:0,diyas:0,best:{},inv:{}};save();home();delete b.dataset.a}else{b.dataset.a=1;$('hGoalT').textContent='Tap again to restart from level 1';setTimeout(function(){delete b.dataset.a},2500)}};
var drag=null,gh=$('ghost');function pt(ev){var r=$('stage').getBoundingClientRect(),k=390/r.width;return[(ev.clientX-r.left)*k,(ev.clientY-r.top)*k]}
$('slots').addEventListener('pointerdown',function(ev){var t=ev.target.closest('.slot');if(!t||!game||game.busy||game.over)return;var k=t.dataset.k;if(!(S.inv[k]>0))return;drag=k;gh.src=CRK.b[IDX[k]];gh.style.display='block';mv(ev);ev.preventDefault()});
function mv(ev){if(!drag)return;var p=pt(ev);gh.style.left=(p[0]-45)+'px';gh.style.top=(p[1]-90)+'px'}addEventListener('pointermove',mv);
addEventListener('pointerup',function(ev){if(!drag)return;var k=drag;drag=null;gh.style.display='none';var q=game.cell(ev);if(game.place(k,q[0],q[1])){S.inv[k]--;save();slots()}});
addEventListener('pointerdown',function(){SFX.unlock()},{once:true});
setTimeout(home,2300);
})();
