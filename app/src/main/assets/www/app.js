(function(){
var $=function(i){return document.getElementById(i)},q=function(s){return document.querySelector(s)};
var NAMES=['Bijli','Kuruvi','Hydrogen Bomb','Twinkling Star','Snake Tablet','Bullet Bomb'],IDX={matchbox:14,rocket:6,flowerpot:7,chakra:8,skyshot:9,sparkler:11,rail:13,wala:12,atom:10},SL=['sparkler','rail','wala','atom'],LBL={matchbox:'Colour Matchbox',rocket:'Rocket',flowerpot:'Flowerpot',chakra:'Ground Chakra',skyshot:'Sky Shot',sparkler:'Sparkler',rail:'Rail Cracker',wala:'1000-Wala',atom:'Atom Bomb'},ONB={rocket:1,flowerpot:1,chakra:1,skyshot:1},PRICE={matchbox:600,rocket:100,flowerpot:150,sparkler:150,chakra:200,rail:250,skyshot:300,wala:350,atom:500};
var SPD={1:1.2,2:1.65,3:2.2};function spd(){var v=1;try{v=+localStorage.getItem('cm_speed')||1}catch(e){}return SPD[v]?v:1}window.GSPEED=SPD[spd()];
var S={lv:0,coins:0,diyas:0,best:{},inv:{},seen:{},pend:{}};function load(){try{var j=localStorage.getItem('cm_save');if(j)S=JSON.parse(j);S.seen=S.seen||{};S.pend=S.pend||{}}catch(e){}}function save(){try{localStorage.setItem('cm_save',JSON.stringify(S))}catch(e){}}load();
function fit(){var k=Math.min(innerWidth/390,innerHeight/844);$('stage').style.transform='scale('+k+')'}addEventListener('resize',fit);fit();
function show(id){['home','game','win','lose','done','bonusEnd'].forEach(function(x){$(x).classList.toggle('on',x==id)})}
// tile icons for goals and banners
var ICN={};function icon(k){if(window.BIGT&&BIGT[k])return'art/big-'+k+'.webp';if(typeof k=='number'||/^\d+$/.test(k))return CRK.b[k];if(k=='diya')return'art/ui-diya.webp';if(window.OBT&&OBT[k])return'art/'+OBT[k].f+'.webp';return CRK.b[0]}
function goalName(k){if(window.BIGT&&BIGT[k])return BIGT[k];return{wood:'Wooden crates',crate:'Crates',steel:'Steel crates',gift:'Gift boxes',pot:'Clay pots',stone:'Stone blocks',glass:'Glass blocks',launcher:'Launchers',thread:'Thread',chain:'Chains',ice:'Ice',wet:'Wet crackers',diya:'Diyas',rang:'Rangoli',mud:'Mud'}[k]||NAMES[k]}
function goalsHTML(g){return Object.keys(g).map(function(k){return'<div class="gi"><img src="'+icon(k)+'" alt="'+goalName(k)+'"><b>'+g[k]+'</b></div>'}).join('')}
// HOME: painted scene with a swipeable level row
var CHN=['Green Village','Flower Hills','Sweet Street','Diya Lane','Festival Square'],hs=null,tiles=[],selT=null,curCh=0,strip=$('strip');
function chOf(i){return Math.floor(i/10)+1}
function starsTotal(){var n=0;for(var k in S.best)n+=S.best[k];return n}
function htoast(m){var e=$('htoast');e.textContent=m;e.style.opacity=1;clearTimeout(e._t);e._t=setTimeout(function(){e.style.opacity=0},1400)}
var LK='<span class="lk"><svg width="14" height="16" viewBox="0 0 14 16"><rect x="1" y="7" width="12" height="9" rx="2" fill="#fff"/><path d="M4 7V5a3 3 0 0 1 6 0v2" stroke="#fff" stroke-width="2" fill="none"/></svg></span>';
function buildStrip(){strip.innerHTML='<div id="track"></div>';tiles=[];var n=LEVELS.length;
 for(var i=0;i<n;i++){if(i&&i%10==0)addT({ch:chOf(i)});addT({i:i,ch:chOf(i)});if((i+1)%5==0)addT({bonus:(i+1)/5,after:i+1,ch:chOf(i)})}
 var f=strip.children[1],l=strip.lastElementChild;$('track').style.left=(f.offsetLeft+46)+'px';$('track').style.width=(l.offsetLeft-f.offsetLeft)+'px'}
function addT(o){var b=document.createElement('button');b.type='button';b.className='t';var h='';
 if(o.ch&&o.i==null&&!o.bonus){b.className+=' ch';b.tabIndex=-1;b.setAttribute('aria-hidden','true');h='<div class="b">Chapter<br>'+o.ch+'</div>'}
 else if(o.bonus){var open=S.lv>=o.after;b.className+=' bonus';var bd=(S.bdone||{})[o.bonus];h='<div class="b"><img src="art/ui-coin.webp" alt=""><small>'+(bd?'DONE':'BONUS')+'</small></div>'+(open?'':LK);b.setAttribute('aria-label','Coin Blast bonus level')}
 else{var st=o.i<S.lv?'done':o.i==S.lv?'cur':'lock';b.className+=' '+st;var n=S.best[o.i]||0;h='<div class="b">'+(st=='done'?'<span class="tst">'+[0,1,2].map(function(k){return'<i'+(k<n?'':' class="o"')+'>&#9733;</i>'}).join('')+'</span>':'')+'<span>'+(o.i+1)+'</span></div>'+(st=='lock'?LK:'');b.setAttribute('aria-label','Level '+(o.i+1))}
 b.innerHTML=h;b._o=o;strip.appendChild(b);if(!b.classList.contains('ch'))tiles.push(b);
 b.addEventListener('click',function(){if(b.classList.contains('ch'))return;if(b!==selT){center(b,true);return}tapT(o)})}
function tapT(o){SFX.unlock();if(o.bonus){if(S.lv<o.after)htoast('Finish level '+o.after+' to unlock');else if((S.bdone||{})[o.bonus])htoast('You already collected this bonus');else startBonus(o.bonus);return}if(o.i>S.lv){htoast('Level '+(o.i+1)+' is locked');SFX.nope();return}openCard(o.i)}
function center(b,smooth){strip.scrollTo({left:b.offsetLeft+b.offsetWidth/2-strip.clientWidth/2,behavior:smooth?'smooth':'auto'})}
function upd(){var mid=strip.scrollLeft+strip.clientWidth/2,best=null,bd=1e9;tiles.forEach(function(t){var d=Math.abs(t.offsetLeft+t.offsetWidth/2-mid);if(d<bd){bd=d;best=t}});if(!best)return;
 if(best!==selT){if(selT)selT.classList.remove('sel');selT=best;best.classList.add('sel');var ch=best._o.ch;if(ch!=curCh){var first=!curCh;curCh=ch;hs.set(ch,first);var c=$('chap');c.style.opacity=0;setTimeout(function(){c.textContent='Chapter '+ch+' · '+CHN[(ch-1)%CHN.length];c.style.opacity=1},first?0:220)}}
 var max=strip.scrollWidth-strip.clientWidth||1;hs.pan((strip.scrollLeft/max-.5)*-12)}
var rq=0;strip.addEventListener('scroll',function(){if(!rq)rq=requestAnimationFrame(function(){rq=0;upd()})},{passive:true});
(function(){var md=false,mx=0,ms=0;strip.addEventListener('pointerdown',function(e){if(e.pointerType!='mouse')return;md=true;mx=e.clientX;ms=strip.scrollLeft;strip.style.scrollSnapType='none'});addEventListener('pointermove',function(e){if(md)strip.scrollLeft=ms-(e.clientX-mx)});addEventListener('pointerup',function(){if(!md)return;md=false;strip.style.scrollSnapType='';upd();if(selT)center(selT,true)})})();
function tileOf(i){for(var k=0;k<tiles.length;k++)if(tiles[k]._o.i===i)return tiles[k];return tiles[tiles.length-1]}
function home(prev){DEB.clear();if(!hs){hs=new Scene($('hScn'),{ch:chOf(Math.min(S.lv,LEVELS.length-1))})}$('hCoins').textContent=S.coins;$('hStars').textContent=starsTotal();dailyDot();show('home');hs.start();curCh=0;selT=null;buildStrip();
 var i=Math.min(S.lv,LEVELS.length-1),t=tileOf(i);if(prev!=null&&prev<i){center(tileOf(prev),false);upd();setTimeout(function(){center(t,true);setTimeout(function(){t.classList.add('pop');SFX.play('tick',{v:.6,rate:1.2})},650)},450)}else{center(t,false);upd()}}
// MENU SHEETS: shop, daily reward, my crackers, settings
var SHOPK=['sparkler','rail','wala','atom'],DAYS=[50,75,100,150,200,250,{k:'atom',n:1}];
function today(){var d=new Date();return d.getFullYear()+'-'+(d.getMonth()+1)+'-'+d.getDate()}
function dailyCan(){return(S.daily||{}).last!=today()}function dailyDot(){$('dDot').classList.toggle('on',dailyCan())}
function sheet(t,h){$('sTitle').textContent=t;$('sBody').innerHTML=h;$('sheet').classList.add('on');SFX.play('swoosh',{v:.5})}
function closeSheet(){$('sheet').classList.remove('on');[].forEach.call(document.querySelectorAll('.nav button'),function(b){b.classList.toggle('on',b.dataset.p=='home')})}
$('sClose').onclick=closeSheet;$('sheet').addEventListener('click',function(e){if(e.target===this)closeSheet()});
var DESC={sparkler:'Drag onto a tile. Burns a cross of tiles.',rail:'Races along a whole row and back.',wala:'Pops 15 tiles all over the board.',atom:'The biggest blast. Clears a wide area.',matchbox:'Clears one whole colour.'};
function shopH(){return'<p class="sp">You have <b>'+S.coins+'</b> coins. Reward crackers go to your bar in every level.</p>'+SHOPK.map(function(k){var can=S.coins>=PRICE[k];return'<div class="srow"><img src="'+CRK.b[IDX[k]]+'" alt=""><div><b>'+LBL[k]+'</b><small>'+DESC[k]+' You have '+(S.inv[k]||0)+'.</small></div><button class="sbtn'+(can?'':' off')+'" data-buy="'+k+'"><img src="art/ui-coin.webp" alt="">'+PRICE[k]+'</button></div>'}).join('')}
function dailyH(){var d=S.daily||{n:0},can=dailyCan(),n=can?d.n%7:(d.n-1)%7;return'<div class="days">'+DAYS.map(function(r,i){var got=i<n||(!can&&i==n),obj=typeof r=='object';return'<div class="day'+(got?' got':'')+(can&&i==n?' today':'')+(i==6?' d7':'')+'">Day '+(i+1)+'<img src="'+(obj?CRK.b[IDX[r.k]]:'art/ui-coin.webp')+'" alt=""><b>'+(obj?LBL[r.k]:r)+'</b></div>'}).join('')+'</div><button class="bigbtn'+(can?'':' off')+'" id="dClaim">'+(can?'Claim':'Come back tomorrow')+'</button>'}
function bagH(){var ks=SHOPK.concat(['matchbox']);return ks.map(function(k){var n=S.inv[k]||0;return'<div class="srow"><img src="'+CRK.b[IDX[k]||14]+'" alt=""><div><b>'+LBL[k]+' × '+n+'</b><small>'+DESC[k]+'</small></div></div>'}).join('')+'<p class="sp">Rocket, Flowerpot, Ground Chakra and Sky Shot are made by matching on the board.</p>'}
function setH(){var on=SFX.isOn();return'<div class="srow"><div><b>Sound and music</b><small>'+(on?'On':'Off')+'</small></div><button class="sbtn'+(on?'':' off')+'" id="tSnd">'+(on?'On':'Off')+'</button></div><div class="srow"><div><b>Game speed</b><small>Faster moves and blasts</small></div><div class="spdb">'+[1,2,3].map(function(v){return'<button class="sbtn'+(spd()==v?'':' off')+'" data-spd="'+v+'">'+v+'x</button>'}).join('')+'</div></div><div class="srow"><div><b>Start over</b><small>Clears levels, stars, coins and crackers.</small></div><button class="sbtn red" id="tRst">Reset</button></div><p class="sp">Crackers Match by RetroRaja Games</p>'}
document.querySelector('.nav').addEventListener('click',function(e){var b=e.target.closest('button');if(!b)return;SFX.unlock();[].forEach.call(this.children,function(x){x.classList.toggle('on',x===b)});var p=b.dataset.p;if(p=='home'){closeSheet();return}
 if(p=='shop')sheet('Shop',shopH());if(p=='daily')sheet('Daily reward',dailyH());if(p=='bag')sheet('My crackers',bagH());if(p=='set')sheet('Settings',setH())});
$('sBody').addEventListener('click',function(e){var t=e.target.closest('button');if(!t)return;
 if(t.dataset.buy){if(buy(t.dataset.buy)){$('sBody').innerHTML=shopH();$('hCoins').textContent=S.coins;SFX.play('fanfare',{v:.4})}else SFX.nope()}
 if(t.id=='dClaim'&&dailyCan()){var d=S.daily||{n:0},r=DAYS[d.n%7];if(typeof r=='object')S.inv[r.k]=(S.inv[r.k]||0)+r.n;else S.coins+=r;S.daily={n:d.n+1,last:today()};save();$('sBody').innerHTML=dailyH();$('hCoins').textContent=S.coins;dailyDot();SFX.play('win',{v:.6})}
 if(t.id=='tSnd'){SFX.toggle();$('sBody').innerHTML=setH()}
 if(t.dataset.spd){try{localStorage.setItem('cm_speed',t.dataset.spd)}catch(e){}window.GSPEED=SPD[+t.dataset.spd];SFX.play('tick',{v:.5});$('sBody').innerHTML=setH()}
 if(t.id=='tRst'){if(t.dataset.a){S={lv:0,coins:0,diyas:0,best:{},inv:{},seen:{},pend:{}};save();closeSheet();home()}else{t.dataset.a=1;t.textContent='Sure?'}}});
// LEVEL CARD
var pick={},card_i=0;
function boosters(){$('lCoins').textContent=S.coins;$('lBoost').innerHTML=SL.map(function(k){var n=S.inv[k]||0,can=S.coins>=PRICE[k];return'<button class="bo'+(can?'':' off')+'" data-k="'+k+'" aria-label="Buy '+LBL[k]+'"><img src="'+CRK.b[IDX[k]]+'" alt="">'+(n?'<b>'+n+'</b>':'')+'<em>'+PRICE[k]+'</em></button>'}).join('')}
function buy(k,now){if(S.coins<PRICE[k])return false;S.coins-=PRICE[k];S.inv[k]=(S.inv[k]||0)+1;save();SFX.play('tick',{v:.6});return true}
function openCard(i){card_i=i;pick={};var L=LEVELS[i];$('lNum').textContent='Level '+(i+1);$('lName').textContent=L.name;$('lGoals').innerHTML=goalsHTML(L.goal);$('lMoves').textContent=L.moves+' moves';boosters();$('lc').classList.add('on');var c=q('#lc .hang');c.classList.remove('sw');void c.offsetWidth;c.classList.add('sw');SFX.play('swoosh',{v:.6})}
$('lBoost').addEventListener('click',function(e){var b=e.target.closest('.bo');if(!b)return;if(buy(b.dataset.k))boosters();else SFX.nope()});
$('lClose').onclick=function(){$('lc').classList.remove('on')};
$('lPlay').onclick=function(){SFX.unlock();$('lc').classList.remove('on');var L=LEVELS[card_i],Q=(L.intro||[]).filter(function(k){return !S.seen['b_'+k]});runBanners(Q,function(){start(card_i)})};
// BOOSTER AND LAYER BANNERS: one still picture, a short look, then play
var BAN={rocket:['Rocket','Match 4 in a line. Tap to fire.','art/ui-rocket-l.webp'],flowerpot:['Flowerpot','Match a 2×2 square. Sparks hit 8 tiles.','art/ui-flowerpot-l.webp'],chakra:['Ground Chakra','Match an L or T. Clears all around it.','art/ui-chakra.webp'],skyshot:['Sky Shot','Match 5 in a line. Rains stars on the board.',null,9],atom:['Atom Bomb','The biggest blast. Drag it from the bar.',null,10],sparkler:['Sparkler','Drag it from the bar onto a tile.',null,11],wala:['1000-Wala','Drag it from the bar. It pops 15 tiles.',null,12],rail:['Rail Cracker','Drag it from the bar. It races a row and back.',null,13],matchbox:['Colour Matchbox','Clears one whole colour.',null,14],crate:['Crates','Match next to a crate, or blast it, to break it.','crate'],steel:['Steel Crates','2 hits. The first snaps the steel bands.','steel'],gift:['Gift Boxes','2 hits. The lid flies off, then the box rips open.','gift'],pot:['Clay Pots','2 hits. It cracks, then shatters.','pot'],stone:['Stone Blocks','3 hits. It cracks deeper each time.','stone'],glass:['Glass Blocks','Only a special cracker’s blast breaks glass.','glass'],launcher:['Firework Launcher','2 hits fill it. Then it fires and clears its column.','launcher'],thread:['Thread','The cracker is wrapped and cannot move. Match it or next to it to cut it free.','thread'],chain:['Chains','2 hits. Match with it or next to it.','chain'],ice:['Ice','The cracker is frozen. 2 hits to smash the ice.','ice'],wet:['Wet Crackers','Match beside them to dry them. They spread if you don’t.','wet'],rang:['Rangoli','Match on it or next to it to sweep it away.','rang'],mud:['Mud','2 layers. Match on it or next to it.','mud'],cups:['Glass Cup Rack','Match next to the rack, or blast it. Every hit breaks a cup and cracks the glass.','cups'],bottles:['Bottle Crate','Every match beside the crate breaks a bottle.','bottles'],fruit:['Fruit Basket','Match beside the basket to knock out the fruit.','fruit'],sweets:['Sweet Box','Match beside the box to take the sweets out.','sweets'],diyas:['Diya Stand','Match beside the stand to collect the lamps.','diyas'],gifts:['Gift Stack','Match beside the stack to open the gifts one by one.','gifts'],wall:['Crate Wall','Match next to the wall 3 times. It breaks and both diyas fly to your target.','art/plank.webp'],wood:['Wooden Crates','Each match beside the crate knocks out one panel. 4 panels to break it.','art/woodi.webp'],diya:['Bring the Diya Down','Clear the tiles below it. It must reach the bottom.','diya']};
var banCb=null,banT=0;function banner(k,cb){S.seen['b_'+k]=1;save();var b=BAN[k],src=b[3]!=null?CRK.b[b[3]]:(/^art/.test(b[2])?b[2]:icon(b[2]));$('bImg').src=src;$('bTitle').textContent=b[0];$('bLine').textContent=b[1];banCb=cb;var e=$('ban');e.classList.add('on');var i=e.querySelector('.bin');i.classList.remove('go');void i.offsetWidth;i.classList.add('go');SFX.play('tick',{v:.6})}
function banDone(){if(!banCb)return;$('ban').classList.remove('on');var f=banCb;banCb=null;f()}$('ban').addEventListener('click',banDone);
function runBanners(Q,done){if(!Q.length)return done();banner(Q[0],function(){runBanners(Q.slice(1),done)})}
// GAME
var BL=null;function LV(){return cur==='b'?BL:LEVELS[cur]}
var game=null,cur=0,inflight={},realG={},doneG={};
function slots(){$('slots').innerHTML=SL.map(function(k){var n=S.inv[k]||0;return'<div class="slot'+(n?'':' none')+'" data-k="'+k+'" aria-label="'+LBL[k]+'"><img src="'+CRK.b[IDX[k]]+'" alt="">'+(n?'<b>'+n+'</b>':'<b class="pr">'+PRICE[k]+'</b>')+'</div>'}).join('');$('gCoins').textContent=S.coins}
function drawHud(){if(cur==='b'){var got=(BL.goal.coin-Math.max(0,realG.coin))-(inflight.coin||0);$('gGoals').innerHTML='<div class="gi" data-k="coin"><img src="art/ui-coin.webp" alt="Coins"><b>'+got*BL.val+'</b></div>';return}var h='';Object.keys(LV().goal).forEach(function(k){var v=Math.max(0,realG[k])+(inflight[k]||0);h+='<div class="gi" data-k="'+k+'"><img src="'+icon(k)+'" alt="'+goalName(k)+'">'+(v?'<b>'+v+'</b>':'<b class="ok">&#10003;</b>')+'</div>'});$('gGoals').innerHTML=h}
function hud(g){realG=g;var L=LV();drawHud();Object.keys(L.goal).forEach(function(k){if(g[k]<=0&&!(inflight[k]>0)&&!doneG[k]){doneG[k]=1;SFX.chime(2);if(face)face.mood('cheer',1.5)}})}
var flyN=0,flyLast=0;function fly(k,x,y){var el=q('#gGoals .gi[data-k="'+k+'"]');if(!el)return;var st=$('stage').getBoundingClientRect(),b=el.getBoundingClientRect(),z=390/st.width,tx=(b.left-st.left)*z+b.width*z/2,ty=(b.top-st.top)*z+b.height*z/2-8,sx=x,sy=y+120,im=new Image();im.src=icon(k);im.className='fly';im.style.left=(sx-30)+'px';im.style.top=(sy-30)+'px';$('stage').appendChild(im);var now=performance.now();flyN=now-flyLast>300?0:flyN+1;flyLast=now;var dl=flyN*70,dx=tx-sx,dy=ty-sy;inflight[k]=(inflight[k]||0)+1;drawHud();
 var a=im.animate([{transform:'translate(0,0) scale(.9)',offset:0},{transform:'translate(0,-34px) scale(1.35)',offset:.22},{transform:'translate('+dx*.55+'px,'+(dy*.45-30)+'px) scale(1.15)',offset:.6},{transform:'translate('+dx+'px,'+dy+'px) scale(.62)',offset:1}],{duration:780,delay:dl,easing:'ease-in',fill:'both'});
 var tr=setInterval(function(){var r=im.getBoundingClientRect(),gx=(r.left-st.left)*z+22,gy=(r.top-st.top)*z-120+22;if(game)game.spark(gx,gy,2,['#FFD24A','#FFFFFF'],90)},60);
 a.onfinish=function(){clearInterval(tr);im.remove();inflight[k]--;drawHud();var e=q('#gGoals .gi[data-k="'+k+'"]');if(e)e.animate([{transform:'scale(1)'},{transform:'scale(1.32)'},{transform:'scale(1)'}],{duration:240});if(realG[k]<=0&&!inflight[k]&&!doneG[k]){doneG[k]=1;SFX.tick()}}}
var WORDS=[['Mass!','மாஸ்'],['Theri!','தெறி'],['Mersal!','மெர்சல்'],['Bigil!','பிகில்']],lastW=0;function word(i){var t=performance.now();if(t-lastW<3500)return;lastW=t;var e=$('cheer'),w=WORDS[Math.min(i,3)];e.textContent=w[0];e.classList.remove('go');void e.offsetWidth;e.classList.add('go')}
function cheer(c){if(face){if(c>=3)face.mood('grin',1.6);else if(c>=2)face.mood('wow',1.2)}if(c>=3)word(c-3)}$('cheer').addEventListener('animationend',function(){this.classList.remove('go');this.textContent=''});
function shuffling(){var e=$('shuf');e.classList.remove('go');void e.offsetWidth;e.classList.add('go')}
var face=null,lastScore=0;function sbar(v){var L=LV(),T=L.moves*380,k=Math.min(1,v/T);$('sFill').style.width=(k*100)+'%';[].forEach.call($('sbar').querySelectorAll('i'),function(e,j){var on=k>=[.3,.6,1][j];if(on&&!e.classList.contains('on')){e.classList.add('on');if(v>0){SFX.chime(j);if(face)face.mood('smile')}}if(!on)e.classList.remove('on')})}
function starsOf(){var T=LV().moves*380,v=game?game.score:0;return v>=T?3:v>=T*.6?2:1}
function start(i){cur=i;DEB.clear();var L0=i==='b'?BL:LEVELS[i];L0.idx=i==='b'?0:i;if(!face)face=new Face($('face'));face.calm();face.mood('idle');doneG={};inflight={};tries={ad:0,coin:0};$('cheer').classList.remove('go');$('cheer').textContent='';lastW=performance.now();lastAct=performance.now();hideHand();endOff();var L=L0;if(game)game.stopped=true;$('game').style.setProperty('--gbg','url('+SCENE_SRC(chOf(i==='b'?BL.after-1:i)).replace('.webp','-s.webp')+')');if(hs)hs.stop();show('game');var cv=$('board'),n=cv.cloneNode();cv.parentNode.replaceChild(n,cv);$('gMoves').textContent=L.moves;$('gName').textContent=i==='b'?'Bonus':'Level '+(i+1);$('sbar').style.display=i==='b'?'none':'';realG={};Object.keys(L.goal).forEach(function(k){realG[k]=L.goal[k]});drawHud();slots();SFX.duck(.3);
 sbar(0);game=new CrackersGame(n,L,{score:sbar,bonus:function(){face.mood('grin')},moves:function(m){$('gMoves').textContent=m;if(m<=3&&m>0)face.mood('worried',9);else face.mood('smile',.9)},goal:hud,fly:fly,idle:function(){},cheer:cheer,big:function(){},shuffling:shuffling,done:levelDone,lose:lost});window.__game=game;S.pend={};save()}
function drop(k){var L=[];game.b.forEach(function(row){row.forEach(function(e){if(e&&e.k<6&&e.k>=0&&!e.ob&&!e.diya)L.push(e)})});var e=L[Math.random()*L.length|0];if(e){e.k=IDX[k];e.shakeT=.4;SFX.play('tick',{v:.5})}}
// hand guide: level 1, first three moves only
var hand=$('hand'),hAnim=null,lastAct=0;function hideHand(){hand.style.display='none';if(hAnim){hAnim.cancel();hAnim=null}}
function showHand(h){if(!h||!game)return;var x=game.cx(h.c)-22,y=game.cy(h.r)+120-6;hand.style.display='block';hand.style.left=x+'px';hand.style.top=y+'px';var U=game.cx(1)-game.cx(0),k=h.tap?[{transform:'scale(1)'},{transform:'scale(.82)'},{transform:'scale(1)'}]:[{transform:'translate(0,0)',opacity:1},{transform:'translate('+((h.dc||0)*U)+'px,'+((h.dr||0)*U)+'px)',opacity:1,offset:.7},{transform:'translate('+((h.dc||0)*U)+'px,'+((h.dr||0)*U)+'px)',opacity:0}];hAnim=hand.animate(k,{duration:h.tap?700:1200,iterations:Infinity})}
var GRP={15:6,16:6},SPK={6:'rocket',7:'flowerpot',8:'chakra',9:'skyshot',10:'atom',11:'sparkler',12:'wala',13:'rail',14:'matchbox'};
function newSp(){if(ending)return false;var L=game.specials();for(var i=0;i<L.length;i++){var id=GRP[L[i].k]||L[i].k,k=SPK[id];if(k&&!S.seen['b_'+k]){banner(k,function(){});return true}}return false}
setInterval(function(){if(!game||!game.b||game.stopped||game.busy||game.over||!$('game').classList.contains('on')||$('ban').classList.contains('on'))return;if(newSp()){hideHand();return}var idle=performance.now()-lastAct;if(hand.style.display!='block'&&cur==0&&LEVELS[0].moves-game.moves<3&&idle>900)showHand(game.hintMove());else if(idle>10000)game.showHint()},300);
addEventListener('pointerdown',function(){lastAct=performance.now();hideHand();if(game)game.hl=null},true);
var stuck=0;setInterval(function(){if(!game||game.stopped||game.over||!game.busy||game.dropping||game.ev.length||game.fx.some(function(f){return f.k=='obj'})){stuck=0;return}stuck+=500;if(stuck>=2000){stuck=0;game.refill()}},500);
// END OF LEVEL: goal tick, BLASTU with 1000-Wala pops, board blast, win
var P=[],head=null,sc=$('sp').getContext('2d'),DUR=1.45,endT=[],endMv=0,ending=false;sc.scale(2,2);
function emit(x,y,v,a,sp,life,col,w,g){P.push({x:x,y:y,vx:Math.cos(a)*v*(.4+Math.random()*sp),vy:Math.sin(a)*v*(.4+Math.random()*sp),l:life*(.5+Math.random()*.7),m:life,c:col,w:w,g:g})}
var last=0;(function loop(n){var dt=Math.min((n-last)/1000||0,.04);last=n;if(P.length||head){sc.clearRect(0,0,390,844);if(head){head.t+=dt;head.c=(head.c||0)+dt;var k=Math.min(head.t/DUR,1),x=24+342*k;if(head.c>.05){head.c=0;var px=x+Math.random()*14-7,py=400+Math.random()*80-40;sc.save();sc.globalCompositeOperation='lighter';sc.fillStyle='#fff';sc.shadowColor='#FF9A2A';sc.shadowBlur=30;sc.beginPath();sc.arc(px,py,12+Math.random()*8,0,6.3);sc.fill();sc.restore();for(var j=0;j<14;j++)emit(px,py,270,Math.random()*6.283,1,.32,['#FFE27A','#FFFFFF','#FF8A2A'][j%3],1.6,300);for(j=0;j<4;j++)emit(px,py,180,-1.57+Math.random()*2.4-1.2,1,1,['#E8123C','#D9B36A','#FF4B6E'][j%3],-4.5,430)}if(k>=1)head=null}
 P=P.filter(function(p){p.l-=dt;if(p.l<=0)return false;var ox=p.x,oy=p.y;p.vy+=p.g*dt;p.x+=p.vx*dt;p.y+=p.vy*dt;var a=Math.min(1,p.l/p.m*1.6);sc.globalAlpha=a;if(p.w<0){sc.fillStyle=p.c;sc.save();sc.translate(p.x,p.y);sc.rotate(p.y*.12);sc.fillRect(p.w,p.w*.6,-p.w*2,-p.w*1.2);sc.restore()}else{sc.strokeStyle=p.c;sc.lineWidth=p.w;sc.lineCap='round';sc.beginPath();sc.moveTo(ox-p.vx*.012,oy-p.vy*.012);sc.lineTo(p.x,p.y);sc.stroke()}sc.globalAlpha=1;return true});if(!P.length&&!head)sc.clearRect(0,0,390,844)}requestAnimationFrame(loop)})(0);
function later(f,t){endT.push(setTimeout(f,t*1000))}
function endOff(){endT.forEach(clearTimeout);endT=[];ending=false;P=[];head=null;$('endDim').classList.remove('on');$('bw').style.visibility='hidden';$('bw').getAnimations().forEach(function(a){a.cancel()});$('bw').innerHTML='BLASTU!'.split('').map(function(l){return'<span>'+l+'</span>'}).join('');q('.hud').classList.remove('big')}
function levelDone(mv){if(cur==='b'){game.stopped=true;setTimeout(bonusEnd,600);return}endMv=mv;ending=true;hideHand();if(face){face.calm();face.mood('cheer',4)}later(function(){$('endDim').classList.add('on');q('.hud').classList.add('big');SFX.duck(.12);SFX.tick()},.75);
 later(function(){var ls=[].slice.call($('bw').children),n=ls.length;$('bw').style.visibility='visible';ls.forEach(function(e){e.style.opacity=.14});ls.forEach(function(e,i){later(function(){e.style.opacity=1;e.animate([{transform:'scale(.7)',filter:'brightness(2.2)'},{transform:'scale(1.25)',filter:'brightness(1.8)',offset:.5},{transform:'scale(1)',filter:'brightness(1)'}],{duration:420,easing:'ease-out'})},(i+.6)/n*DUR)});head={t:0};SFX.play('wala',{cut:DUR+.1})},1.75);
 later(function(){$('endDim').classList.remove('on');q('.hud').classList.remove('big');$('bw').animate([{transform:'scale(1)',opacity:1},{transform:'scale(1.9)',opacity:0}],{duration:380,easing:'ease-out',fill:'forwards'});SFX.play('blast');game.flash=.7;game.shake=9},3.4);
 later(function(){game.boardBlast(cur%3,function(){if(ending)won(mv)})},3.55)}
$('game').addEventListener('pointerdown',function(){if(ending&&game.over){endOff();won(endMv)}});
function won(mv){ending=false;endT.forEach(clearTimeout);endT=[];var L=LV(),d=starsOf(),old=S.best[cur]||0,c=100+mv*10,first=cur>=S.lv,prev=cur,rw=first&&L.reward;if(d>old){S.diyas+=d-old;S.best[cur]=d}S.coins+=c;if(rw)S.inv[L.reward.k]=(S.inv[L.reward.k]||0)+L.reward.n;if(first)S.lv=cur+1;save();game.stopped=true;endOff();
 $('win').insertBefore($('wfx'),$('win').children[1]);$('wbg').style.backgroundImage='url('+SCENE_SRC(chOf(cur))+')';$('wLv').textContent='Level '+(cur+1);$('wCoins').textContent='0';$('wStars').innerHTML='<i>&#9733;</i><i>&#9733;</i><i>&#9733;</i>';$('wRew').style.display='none';show('win');SFX.duck(.12);SFX.win();winFx(true);
 var st=[].slice.call($('wStars').children);for(var i=0;i<d;i++)(function(i){later(function(){st[i].classList.add('lit');SFX.chime(i);winBurst(195,330,i==1)},.75+i*.38)})(i);
 later(function(){var t0=performance.now(),dur=900,lastN=0;(function cnt(){var k=Math.min(1,(performance.now()-t0)/dur),v=Math.round(c*k*(2-k));$('wCoins').textContent='+'+v;var n=Math.floor(k*8);if(n>lastN){lastN=n;SFX.coin(n)}if(k<1&&$('win').classList.contains('on'))requestAnimationFrame(cnt)})()},.85+d*.38);
 if(rw)later(function(){$('wRewI').src=CRK.b[IDX[L.reward.k]];$('wRewT').textContent='New: '+LBL[L.reward.k]+'!';$('wRew').style.display='flex';SFX.play('fanfare',{v:.5});S.seen['b_'+L.reward.k]=1;save()},2.0+d*.2);
 later(function(){SFX.duck(.3)},3);$('win').dataset.prev=prev}

// COIN BLAST bonus level: coins everywhere, a strip of crackers down the middle, no losing
function bonusLevel(n){var W=8,H=9,sh=[],coins=[],k=n%3;for(var r=0;r<H;r++){sh.push('xxxxxxxx');for(var c=0;c<W;c++){var strip=k==0?(c==3||c==4):k==1?(c==2||c==5):(r==4||c==3||c==4);if(!strip)coins.push([r,c])}}
 return{name:'Coin Blast',bonus:n,after:n*5,moves:20,colors:[0,1,2,5],goal:{coin:coins.length},val:5,shape:sh,ob:{coin:coins},preSp:2}}
window.startBonus=function(n){SFX.unlock();BL=bonusLevel(n);var c=$('ban');$('bImg').src='art/ui-coin.webp';$('bTitle').textContent='Coin Blast';$('bLine').textContent='Bonus level! Break as many coins as you can in 20 moves. You keep them all.';banCb=function(){start('b')};c.classList.add('on');var i=c.querySelector('.bin');i.classList.remove('go');void i.offsetWidth;i.classList.add('go');SFX.play('fanfare',{v:.5})};
function bonusEnd(){if($('bonusEnd').classList.contains('on'))return;var got=(BL.goal.coin-Math.max(0,game.goal.coin))*BL.val;S.coins+=got;S.bdone=S.bdone||{};S.bdone[BL.bonus]=1;save();game.stopped=true;endOff();
 $('bonusEnd').insertBefore($('wfx'),$('bonusEnd').children[1]);$('beBg').style.backgroundImage='url('+SCENE_SRC(chOf(BL.after-1))+')';$('beN').textContent='0';show('bonusEnd');SFX.duck(.12);SFX.play('fanfare',{v:.7});winFx(true);
 var t0=performance.now(),dur=1400,lastN=0;(function cnt(){var k=Math.min(1,(performance.now()-t0)/dur),v=Math.round(got*k*(2-k));$('beN').textContent=v;var q=Math.floor(k*14);if(q>lastN){lastN=q;SFX.coin(q%8);if(q%4==0)winBurst(80+Math.random()*230,120+Math.random()*120,false)}if(k<1)requestAnimationFrame(cnt);else{winBurst(195,330,true);SFX.play('pop',{v:.6})}})();setTimeout(function(){SFX.duck(.3)},2500)}
$('beNext').onclick=function(){winFx(false);home();openCard(Math.min(S.lv,LEVELS.length-1))};
$('beMap').onclick=function(){winFx(false);home()};
// small fireworks behind the win card
var WP=[],wx=$('wfx').getContext('2d'),wOn=false;wx.scale(2,2);
function winBurst(x,y,big){var cs=['#FFE27A','#FFFFFF','#FFB020','#FF4B6E','#7FD7FF'],n=big?70:44;for(var i=0;i<n;i++){var a=i/n*6.283,v=(big?210:150)*(.55+Math.random()*.5);WP.push({x:x,y:y,vx:Math.cos(a)*v,vy:Math.sin(a)*v,l:.8+Math.random()*.6,m:1.4,c:cs[i%5]})}}
function winFx(on){wOn=on;if(!on)return;var last=0,nx=1.2;(function lp(n){if(!wOn||!$('wfx').parentNode.classList.contains('on')){WP=[];wx.clearRect(0,0,390,844);return}var dt=Math.min((n-last)/1000||0,.04);last=n;nx-=dt;if(nx<=0){nx=1.4+Math.random()*1.4;winBurst(60+Math.random()*270,70+Math.random()*90,false);SFX.play('pop',{v:.18,rate:.9+Math.random()*.2})}
 wx.clearRect(0,0,390,844);wx.globalCompositeOperation='lighter';WP=WP.filter(function(p){p.l-=dt;if(p.l<=0)return false;var ox=p.x,oy=p.y;p.vx*=.985;p.vy=p.vy*.985+80*dt;p.x+=p.vx*dt;p.y+=p.vy*dt;wx.globalAlpha=Math.min(1,p.l/p.m*1.8);wx.strokeStyle=p.c;wx.lineWidth=2;wx.lineCap='round';wx.beginPath();wx.moveTo(ox-p.vx*.03,oy-p.vy*.03);wx.lineTo(p.x,p.y);wx.stroke();return true});wx.globalAlpha=1;requestAnimationFrame(lp)})(0)}
var guy=null,tries={ad:0,coin:0};function lostUI(){$('bAd').disabled=tries.ad>=1;$('bAd').classList.toggle('dis',tries.ad>=1);var no=tries.coin>=2||S.coins<300;$('bCoin').disabled=no;$('bCoin').classList.toggle('dis',no);$('lMsg').textContent=S.coins<300?'You have '+S.coins+' coins':''}
function resume(n){show('game');game.more(n);slots();SFX.duck(.3)}
window.adDone=function(ok){if(ok){tries.ad++;resume(4)}else{$('lMsg').textContent='Watch the full video to get +4 moves.'}};
$('bAd').onclick=function(){$('lMsg').textContent='Loading video...';if(window.AndroidVoice&&AndroidVoice.showAd)AndroidVoice.showAd();else setTimeout(function(){adDone(true)},600)};
$('bCoin').onclick=function(){if(S.coins<300)return;S.coins-=300;save();tries.coin++;resume(5)};
function lost(){if(cur==='b'){bonusEnd();return}SFX.lose();setTimeout(function(){show('lose');lostUI()},700)}
$('bNext').onclick=function(){var prev=+$('win').dataset.prev;winFx(false);home(prev)};
$('bQuit').onclick=function(){if(game)game.stopped=true;endOff();home()};
$('bRetry').onclick=function(){game.stopped=true;openCard(cur)};$('bHome').onclick=function(){game.stopped=true;home()};$('bHome2').onclick=function(){home()};
var drag=null,gh=$('ghost'),buyK=null;function askBuy(k){buyK=k;$('buyI').src=CRK.b[IDX[k]];$('buyT').textContent=LBL[k];var ok=S.coins>=PRICE[k];$('buyP').textContent=ok?PRICE[k]+' coins. You have '+S.coins+'.':'You need '+PRICE[k]+' coins. You have '+S.coins+'.';$('buyY').disabled=!ok;$('buyY').classList.toggle('dis',!ok);$('buy').classList.add('on')}$('buyN').onclick=function(){$('buy').classList.remove('on')};$('buyY').onclick=function(){if(buy(buyK,true)){slots();$('buy').classList.remove('on')}};function pt(ev){var r=$('stage').getBoundingClientRect(),k=390/r.width;return[(ev.clientX-r.left)*k,(ev.clientY-r.top)*k]}
$('slots').addEventListener('pointerdown',function(ev){var t=ev.target.closest('.slot');if(!t||!game||game.busy||game.over)return;var k=t.dataset.k;if(!(S.inv[k]>0)){askBuy(k);return}drag=k;gh.src=CRK.b[IDX[k]];gh.style.display='block';mv(ev);ev.preventDefault()});
function mv(ev){if(!drag)return;var p=pt(ev);gh.style.left=(p[0]-45)+'px';gh.style.top=(p[1]-90)+'px'}addEventListener('pointermove',mv);
addEventListener('pointerup',function(ev){if(!drag)return;var k=drag;drag=null;gh.style.display='none';var c=game.cell(ev);if(game.place(k,c[0],c[1])){S.inv[k]--;save();slots()}});
addEventListener('pointerdown',function(){SFX.unlock()},{once:true});
// ===== new screens (9 Nov 2026) =====

// lights on the top strip
for(var i=0;i<14;i++){var e=document.createElement('i');e.style.left=(4+Math.random()*92)+'%';e.style.top=(10+Math.random()*70)+'%';e.style.animationDelay=(Math.random()*2)+'s';$('strip2').appendChild(e)}

// ---------- goal icons: a single cup for the cup rack, one item for other shelves ----------
var icon0=icon;
icon=function(k){if(window.FLY_SRC)return FLY_SRC;if(k=='cups')return'art/cup1.webp';if(k=='wood')return'art/woodi.webp';if(window.BIG_ICON&&BIG_ICON[k])return BIG_ICON[k];return icon0(k)};
var flyCups=fly;fly=function(k,x,y){return flyCups(k,x,y)};

// ---------- level start card ----------
var openCard0=openCard;
openCard=function(i){openCard0(i);var L=LEVELS[i];$('lNum').innerHTML='<span>Level</span><b>'+(i+1)+'</b>';var nw=(L.intro||[]).some(function(k){return !S.seen['b_'+k]});$('lNew').style.display=nw?'':'none'};

// ---------- character reactions ----------
function pop(){var f=q('#game .face');f.classList.remove('pop');void f.offsetWidth;f.classList.add('pop')}
var start0=start;
start=function(i){start0(i);if(!game)return;var cb=game.cb,mv0=cb.moves,ch0=cb.cheer;
 cb.big=function(){if(face)face.mood('wow',1.3);pop()};
 cb.cheer=function(c){ch0(c);if(c>=2)pop()};
 cb.moves=function(m){mv0(m);$('gMoves').classList.toggle('low',m<=5&&m>0);if(m<=5&&m>0&&face)face.mood('worried',2)};
 $('gMoves').classList.remove('low');REW=null};
var hud0=hud;hud=function(g){var before=JSON.stringify(doneG);hud0(g);if(JSON.stringify(doneG)!=before)pop()};

// ---------- reward counter in the goal pill during the ending ----------
var REW=null,drawHud0=drawHud;
drawHud=function(){if(REW!=null){q('#game .hpill small').textContent='Reward';$('gGoals').innerHTML='<div class="gi" data-k="rew"><img src="art/ui-coin.webp" alt="Coins"><b>'+REW+'</b></div>';return}q('#game .hpill small').textContent=cur==='b'?'Coins':'Target';drawHud0()};

// ---------- CRACKERS MATCH! ----------
function letters(el,txt,d0){el.innerHTML=txt.split('').map(function(ch,i){var sx=((i-txt.length/2)*28+(Math.random()-.5)*40)|0,sy=(-80-Math.random()*120)|0,sr=((Math.random()-.5)*90)|0;return'<span style="animation-delay:'+(d0+i*.045).toFixed(2)+'s;--sx:'+sx+'px;--sy:'+sy+'px;--sr:'+sr+'deg">'+ch+'</span>'}).join('')}
function toStage(el){var st=$('stage').getBoundingClientRect(),b=el.getBoundingClientRect(),z=390/st.width;return{x:(b.left-st.left)*z+b.width*z/2,y:(b.top-st.top)*z+b.height*z/2}}
function flyImg(src,sx,sy,el,done,dur){var t=toStage(el),im=new Image();im.src=src;im.className='fly2';im.style.left=(sx-26)+'px';im.style.top=(sy-26)+'px';$('stage').appendChild(im);var dx=t.x-sx,dy=t.y-sy;
 var a=im.animate([{transform:'translate(0,0) scale(.9)'},{transform:'translate(0,-30px) scale(1.3)',offset:.22},{transform:'translate('+dx*.55+'px,'+(dy*.45-30)+'px) scale(1.1)',offset:.6},{transform:'translate('+dx+'px,'+dy+'px) scale(.6)'}],{duration:dur||700,easing:'ease-in',fill:'both'});
 a.onfinish=function(){im.remove();done&&done()}}
var endOff0=endOff;
endOff=function(){endOff0();$('cm').className='';$('skip').classList.remove('on');[].forEach.call(document.querySelectorAll('.fly2'),function(e){e.remove()})};
var levelDone0=levelDone;
levelDone=function(mv){if(cur==='b')return levelDone0(mv);if(ending)return;endMv=mv;ending=true;hideHand();if(face){face.calm();face.mood('cheer',4)}pop();
 letters($('w1'),'CRACKERS',0);letters($('w2'),'MATCH!',.2);
 later(function(){$('endDim').classList.add('on');SFX.duck(.12);SFX.play('thud',{v:.8})},.5);
 later(function(){$('cm').className='on';SFX.play('swoosh',{v:.7});for(var i=0;i<8;i++)(function(i){later(function(){SFX.play('tick',{v:.45,rate:1+i*.08})},i*.12)})(i);later(function(){SFX.play('finale',{v:.9,cut:1.6})},.9)},.75);
 later(function(){[].forEach.call(document.querySelectorAll('#cm .word span'),function(e,i){e.style.animationDelay=(i*.02).toFixed(2)+'s'});$('cm').classList.add('out');$('endDim').classList.remove('on');$('skip').classList.add('on');REW=0;drawHud();leftover(mv)},2.9)};
function leftover(mv){var g=game,n=Math.min(mv,10),list=[];if(!g||!n){later(function(){won(mv)},.6);return}
 for(var i=0;i<n;i++)(function(i){later(function(){if(!ending)return;var mvEl=$('gMoves');mvEl.textContent=mv-i-1;var cells=g.cCells([]).filter(function(p){var e=g.at2(p[0],p[1]);return e&&e.k>=0&&e.k<6&&!e.ob&&!list.some(function(q2){return q2[0]==p[0]&&q2[1]==p[1]})});var p=cells[0];if(!p)return;list.push(p);
  var from=toStage(mvEl),tx=g.cx(p[1]),ty=g.cy(p[0])+112,im=new Image();im.src=CRK.b[6];im.className='fly2';im.style.left=(from.x-26)+'px';im.style.top=(from.y-26)+'px';$('stage').appendChild(im);
  var a=im.animate([{transform:'translate(0,0) rotate(0) scale(.7)'},{transform:'translate('+(tx-from.x)*.5+'px,'+((ty-from.y)*.5-60)+'px) rotate(-200deg) scale(1)',offset:.5},{transform:'translate('+(tx-from.x)+'px,'+(ty-from.y)+'px) rotate(-360deg) scale(.8)'}],{duration:420,easing:'ease-in-out',fill:'both'});
  SFX.play('swoosh',{v:.35,rate:1.2});a.onfinish=function(){im.remove();var e=g.at2(p[0],p[1]);if(e&&!e.dead){e.k=[15,16,6,8][i%4];e.safe=g.clock+.3;e.shakeT=.25;g.ring(tx,ty-112,'#FFC62B',g.uu()*1.2,6);SFX.play('tick',{v:.4,rate:1.2+i*.05})}}},.22*i)})(i);
 var t0=.22*n+.6;
 later(function(){list.forEach(function(p,i){later(function(){if(!ending)return;var e=g.at2(p[0],p[1]);if(!e||e.dead||e.k<6)return;g.cFire(p[0],p[1],e);coins(g.cx(p[1]),g.cy(p[0])+112,3)},i*.2)})},t0);
 later(function(){if(ending)won(mv)},t0+n*.2+1.6)}
function coins(x,y,n){var el=q('#gGoals .gi');if(!el)return;for(var i=0;i<n;i++)(function(i){setTimeout(function(){if(!ending)return;flyImg('art/ui-coin.webp',x+(Math.random()-.5)*30,y,el,function(){REW+=5;var b=q('#gGoals .gi b');if(b)b.textContent=REW;SFX.coin(i)},620)},i*70)})(i)}

// ---------- win screen: giant ground chakra ----------
var FA=$('fxA').getContext('2d');FA.scale(2,2);var PA=[],rot=0,fxOn=false,lastT=0,wguy=null;
function spoke(c,R){c.beginPath();c.moveTo(-14,-40);c.bezierCurveTo(60,-60,R*.55,-R*.2,R*.98,R*.18);c.lineTo(R*.98,R*.34);c.bezierCurveTo(R*.5,-R*.02,60,-30,14,-40);c.closePath()}
function chakra(c,cx,cy,R,a){var g=c.createRadialGradient(cx,cy,R*.5,cx,cy,R*1.6);g.addColorStop(0,'#FF5FD288');g.addColorStop(1,'#0000');c.fillStyle=g;c.beginPath();c.arc(cx,cy,R*1.6,0,7);c.fill();
 c.save();c.translate(cx,cy);c.rotate(a);g=c.createRadialGradient(0,-R*.3,R*.1,0,0,R);g.addColorStop(0,'#F070D8');g.addColorStop(.6,'#B0249E');g.addColorStop(1,'#5A0A5E');c.fillStyle=g;c.beginPath();c.arc(0,0,R,0,7);c.fill();
 for(var k=0;k<4;k++){c.save();c.rotate(k*Math.PI/2);spoke(c,R);g=c.createLinearGradient(0,-R*.5,R,R*.4);g.addColorStop(0,'#FFF3A6');g.addColorStop(.5,'#F2B533');g.addColorStop(1,'#B5700E');c.fillStyle=g;c.fill();c.strokeStyle='#8A4E08';c.lineWidth=2;c.stroke();c.restore()}c.restore();
 g=c.createLinearGradient(cx-R,cy-R,cx+R,cy+R);g.addColorStop(0,'#FFF6B8');g.addColorStop(.35,'#F5C23C');g.addColorStop(.7,'#C7801A');g.addColorStop(1,'#FFE27A');c.lineWidth=26;c.strokeStyle=g;c.beginPath();c.arc(cx,cy,R+11,0,7);c.stroke();
 c.lineWidth=3;c.strokeStyle='#7A4206';c.beginPath();c.arc(cx,cy,R-2,0,7);c.stroke();c.strokeStyle='#FFFBE0aa';c.lineWidth=3;c.beginPath();c.arc(cx,cy,R+21,3.6,5.2);c.stroke()}
function fxLoop(n){if(!fxOn)return;var dt=Math.min((n-lastT)/1000||0,.04);lastT=n;var c=FA;c.clearRect(0,0,390,844);rot+=dt*.9;chakra(c,195,430,166,rot);
 for(var i=0;i<4;i++){var a=Math.random()*6.283,R=192,sp=200+Math.random()*220;PA.push({x:195+Math.cos(a)*R,y:430+Math.sin(a)*R,vx:-Math.sin(a)*sp+Math.cos(a)*60,vy:Math.cos(a)*sp+Math.sin(a)*60,l:.5+Math.random()*.4,m:.9,c:['#FFE27A','#FFFFFF','#FFB020','#FF7AD8'][i]})}
 c.globalCompositeOperation='lighter';PA=PA.filter(function(p){p.l-=dt;if(p.l<=0)return false;var ox=p.x,oy=p.y;p.vy+=260*dt;p.x+=p.vx*dt;p.y+=p.vy*dt;c.strokeStyle=p.c;c.globalAlpha=Math.min(1,p.l/p.m*1.6);c.lineWidth=2.4;c.beginPath();c.moveTo(ox-p.vx*.02,oy-p.vy*.02);c.lineTo(p.x,p.y);c.stroke();return true});c.globalAlpha=1;c.globalCompositeOperation='source-over';
 requestAnimationFrame(fxLoop)}
var show0=show;show=function(id){if(id!='win'){fxOn=false;if(wguy){wguy.dead=true;wguy=null}}if(id!='game'&&id!='home'&&$('ban').classList.contains('on')){$('ban').classList.remove('on');banCb=null}show0(id)};
won=function(mv){ending=false;endT.forEach(clearTimeout);endT=[];REW=null;var L=LV(),d=starsOf(),old=S.best[cur]||0,c=100+mv*10,first=cur>=S.lv,prev=cur,rw=first&&L.reward;if(d>old){S.diyas+=d-old;S.best[cur]=d}S.coins+=c;if(rw)S.inv[L.reward.k]=(S.inv[L.reward.k]||0)+L.reward.n;if(first)S.lv=cur+1;save();game.stopped=true;endOff();
 $('wLv').textContent='Level '+(cur+1)+' · '+(L.name||'');$('wCoins').textContent='0';$('wRew').style.display='none';
 var ds=[].slice.call(document.querySelectorAll('#wStars img'));ds.forEach(function(e){e.classList.remove('lit')});
 show('win');SFX.duck(.12);SFX.win();
 $('slotA').innerHTML='';var cv=document.createElement('canvas');$('slotA').appendChild(cv);wguy=new WinGuy(cv,{});wguy.hold=true;
 PA=[];if(!fxOn){fxOn=true;lastT=performance.now();requestAnimationFrame(fxLoop)}
 for(var i=0;i<d;i++)(function(i){later(function(){ds[i].classList.add('lit');SFX.chime(i)},1.3+i*.25)})(i);
 later(function(){var t0=performance.now(),dur=900,lastN=0;(function cnt(){var k=Math.min(1,(performance.now()-t0)/dur),v=Math.round(c*k*(2-k));$('wCoins').textContent=v;var n=Math.floor(k*8);if(n>lastN){lastN=n;SFX.coin(n)}if(k<1&&$('win').classList.contains('on'))requestAnimationFrame(cnt)})()},1.05);
 if(rw)later(function(){$('wRewI').src=CRK.b[IDX[L.reward.k]];$('wRewT').textContent='New: '+LBL[L.reward.k]+'!';$('wRew').style.display='flex';SFX.play('fanfare',{v:.5});S.seen['b_'+L.reward.k]=1;save()},2.2);
 later(function(){SFX.duck(.3)},3);$('win').dataset.prev=prev};

// test hook
window.__cm={S:S,openCard:function(i){openCard(i)},levelDone:function(m){levelDone(m)},game:function(){return game},start:function(i){start(i)}};

DEB.init($('deb'));endOff();home();window.runIntro(function(){});
})();
