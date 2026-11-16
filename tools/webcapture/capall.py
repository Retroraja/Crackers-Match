# capture every web screen layout into godot/ui/<name>.json (run with the web game served on :8765)
import asyncio,json,sys,subprocess,os
from playwright.async_api import async_playwright
D=os.path.dirname(os.path.abspath(__file__))+'/'
OUT='/home/claude/crackers-match/godot/ui'
S={"lv":9,"coins":250,"diyas":6,"best":{"0":1,"1":1,"2":1,"3":1,"4":1},"inv":{"rocket":2,"chakra":2},"seen":{},"pend":{},"agreed":1,"sbGift":{"rocket":1,"matchbox":1,"chakra":1,"atom":1}}
NOBAN="()=>{const b=document.getElementById('ban');if(b)b.classList.remove('on');const h=document.getElementById('hand');if(h)h.style.display='none'}"
DUMP=open(D+'dump2.js').read()
SHOTS={
 'card':("window.__cm.openCard(4)",'lc',1.5),
 'card_hard':("window.__cm.openCard(9)",'lc',1.5),
 'ban':("window.__cm.start(5);",'ban',1.5),
 'gset':("window.__cm.start(5);setTimeout(()=>{document.getElementById('ban').classList.remove('on');document.getElementById('gGear').click()},800)",'gSet',2.0),
 'lose':("window.__cm.start(5);setTimeout(()=>{document.getElementById('ban').classList.remove('on');window.__cm.lost()},800)",'lose',2.5),
 'lose_failed':("window.__cm.start(5);setTimeout(()=>{document.getElementById('ban').classList.remove('on');window.__cm.lost();setTimeout(()=>document.getElementById('bGive').click(),900)},800)",'lose',3.0),
 'win':("window.__cm.start(5);setTimeout(()=>{document.getElementById('ban').classList.remove('on');window.__cm.levelDone(8)},800)",'win',16.0),
 'cm':("window.__cm.start(5);setTimeout(()=>{document.getElementById('ban').classList.remove('on');window.__cm.levelDone(8)},800)",'cm',2.5),
 'bonusEnd':("startBonus(1);setTimeout(()=>{document.getElementById('ban').click()},600);setTimeout(()=>{window.__cm.game().stopped=true;window.__cm.levelDone(0)},2500)",'bonusEnd',5.5),
 'bc30':("document.querySelector('.bc30').id='bc30';document.querySelector('.bc30').classList.add('on')",'bc30',1.2),
 'got28':("document.querySelector('.got28').id='got28';document.getElementById('gotT').textContent='You got';document.getElementById('gotL').innerHTML='<div class=\"gr\"><img src=\"art/ui-coin.webp\" alt=\"\"><div><b>+500 coins</b><span>You have 750</span></div></div>';document.querySelector('.got28').classList.add('on')",'got28',1.2),
 't28':("toast28('3 free Lakshmi Vedi Hammers! Drag one onto the board.')",'t28',0.8),
 'buy':("window.__cm.openCard(4);setTimeout(()=>document.querySelector('#lBoost .bo[data-k=\"atom\"]')&&0,100)",'buy',1.0),
 'cheer':("window.__cm.start(5);setTimeout(()=>{document.getElementById('ban').classList.remove('on');var e=document.getElementById('cheer');e.textContent='Mersal!';e.classList.add('go')},800)",'cheer',1.2),
 'shuf':("window.__cm.start(5);setTimeout(()=>{document.getElementById('ban').classList.remove('on');document.getElementById('shuf').classList.add('go')},800)",'shuf',1.2),
 'skip':("window.__cm.start(5);setTimeout(()=>{document.getElementById('ban').classList.remove('on');document.getElementById('skip').classList.add('on')},800)",'skip',1.2),
 'hand':("window.__cm.start(5);setTimeout(()=>{document.getElementById('ban').classList.remove('on');var h=document.getElementById('hand');h.style.display='block';h.style.left='100px';h.style.top='300px'},800)",'hand',1.2),
 'endDim':("window.__cm.start(5);setTimeout(()=>{document.getElementById('ban').classList.remove('on');document.getElementById('endDim').classList.add('on')},800)",'endDim',1.5),
 'buy':("window.__cm.start(5);setTimeout(()=>{document.getElementById('ban').classList.remove('on');var sl=document.querySelector('#slots .slot');sl.dispatchEvent(new PointerEvent('pointerdown',{bubbles:true}))},900)",'buy',1.6),
 'mrew':("window.__cm.start(5);setTimeout(()=>{document.getElementById('ban').classList.remove('on');document.getElementById('mRew').classList.add('on');document.getElementById('mFill').style.width='100%'},800)",'meter',1.2),
 'agree':("document.getElementById('agree').classList.add('on')",'agree',1.0),
}
async def main(names):
    async with async_playwright() as p:
        b=await p.chromium.launch()
        for nm in names:
            js,root,wait=SHOTS[nm]
            ctx=await b.new_context(viewport={'width':390,'height':844},device_scale_factor=2)
            await ctx.add_init_script("localStorage.setItem('cm_save',%r)"%json.dumps(S))
            pg=await ctx.new_page();await pg.goto('http://localhost:8765/index.html');await pg.wait_for_timeout(2500)
            await pg.evaluate("()=>{"+js+"}");await pg.wait_for_timeout(int(wait*1000))
            await pg.screenshot(path=D+'ref_'+nm+'.png')
            try:
                d=await pg.evaluate(DUMP,root)
                json.dump(d,open(D+'raw_'+nm+'.json','w'))
                subprocess.run(['python3',D+'conv.py',D+'raw_'+nm+'.json',OUT,nm])
            except Exception as e: print(nm,'ERR',str(e)[:200])
            await ctx.close()
        await b.close()
asyncio.run(main(sys.argv[1:] or list(SHOTS)))
