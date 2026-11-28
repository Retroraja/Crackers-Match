import asyncio,json,sys,subprocess
from playwright.async_api import async_playwright
D='/tmp/claude-0/-home-claude/c1abc257-f372-5299-bfd4-1351ef767cd6/scratchpad/conv/'
OUT='/home/claude/crackers-match/godot/ui'
S={"lv":5,"coins":250,"diyas":6,"best":{"0":3,"1":2,"2":3,"3":1,"4":2},"inv":{},"seen":{},"pend":{},"agreed":1}
NOBAN="()=>{const b=document.getElementById('ban');if(b)b.classList.remove('on');const h=document.getElementById('hand');if(h)h.style.display='none'}"
DUMP=open(D+'dump2.js').read()
async def page(b):
    ctx=await b.new_context(viewport={'width':390,'height':844},device_scale_factor=2)
    await ctx.add_init_script("localStorage.setItem('cm_save',%r)"%json.dumps(S))
    pg=await ctx.new_page();await pg.goto('http://localhost:8765/index.html');await pg.wait_for_timeout(2500);return ctx,pg
async def main(what):
    async with async_playwright() as p:
        b=await p.chromium.launch()
        ctx,pg=await page(b)
        if what=='game':
            await pg.evaluate("window.__cm.start(5)");await pg.wait_for_timeout(1200);await pg.evaluate(NOBAN);await pg.wait_for_timeout(400)
            d=await pg.evaluate(DUMP,'game')
        json.dump(d,open(D+'raw_'+what+'.json','w'))
        await b.close()
    subprocess.run(['python3',D+'conv.py',D+'raw_'+what+'.json',OUT,what])
asyncio.run(main(sys.argv[1]))
