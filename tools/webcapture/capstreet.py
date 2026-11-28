# capture the street page screens (home UI, build panel, tutorial, title, intro...) and the menu sheets into godot/ui
import asyncio,json,sys,subprocess,os
from playwright.async_api import async_playwright
D=os.path.dirname(os.path.abspath(__file__))+'/'
OUT='/home/claude/crackers-match/godot/ui'
DUMP=open(D+'dump2.js').read()
ST="http://localhost:8765/street/index.html"
HOME="(async()=>{while(!window.READY&&!document.querySelector('#load')===null)await new Promise(r=>setTimeout(r,100))})()"
SHOTS={
 'st_home':(ST+'?home=1',"",'home',3.0),
 'st_build':(ST+'?home=1',"CM.S().diyas=3;STREET.back();setTimeout(()=>document.getElementById('hBuild').click(),300)",'oBuild',1.5),
 'st_build2':(ST+'?home=1',"CM.S().diyas=0;CM.S().step=3;STREET.back();setTimeout(()=>document.getElementById('hBuild').click(),300)",'oBuild',1.5),
 'st_tip':(ST+'?home=1',"CM.S().diyas=1;STREET.back()",'tip',2.0),
 'st_tdim':(ST+'?home=1',"CM.S().diyas=1;STREET.back()",'tdim',2.0),
 'st_notif':(ST+'?home=1',"ov('oNotif',true)",'oNotif',1.0),
 'st_agree':(ST+'?home=1',"ov('oAgree',true)",'oAgree',1.0),
 'st_toast':(ST+'?home=1',"toast('Events comes soon')",'toast',0.6),
 'st_hint':(ST+'?home=1',"document.getElementById('hint').classList.add('on');document.getElementById('hint').textContent='Building 1/3 · Tap to speed up'",'hint',0.6),
 'st_skip':(ST+'?home=1',"document.getElementById('bSkip').classList.add('on')",'bSkip',0.6),
 'st_ban':(ST+'?home=1',"document.getElementById('ban').classList.add('on')",'ban',1.0),
 'st_intro':(ST,"",'sIntro',0.8),
 'st_title':(ST,"setTimeout(()=>document.getElementById('bAgree').click(),2800)",'sTitle',8.5),
}
MAIN={
 'sh_shop':"CM28.sheet('shop')",'sh_daily':"CM28.sheet('daily')",'sh_bag':"CM28.sheet('bag')",'sh_set':"CM28.sheet('set')",
}
S={"lv":2,"coins":1250,"diyas":3,"best":{"0":1,"1":1},"inv":{"rocket":2,"chakra":2,"hammer":1},"seen":{},"pend":{},"agreed":1,"sbGift":{"rocket":1,"matchbox":1}}
async def main(names):
    async with async_playwright() as p:
        b=await p.chromium.launch(args=['--use-gl=swiftshader','--enable-webgl','--ignore-gpu-blocklist'])
        for nm in names:
            ctx=await b.new_context(viewport={'width':390,'height':844},device_scale_factor=1 if nm.startswith('st_') else 2)
            pg=await ctx.new_page()
            if nm in SHOTS:
                url,js,root,wait=SHOTS[nm]
                await pg.goto(url)
                if 'home=1' in url:
                    await pg.wait_for_function('window.READY===true||!document.getElementById("load")',timeout=90000)
                    await pg.wait_for_timeout(1500)
            else:
                await ctx.add_init_script("localStorage.setItem('cm_save',%r)"%json.dumps(S))
                await pg.goto('http://localhost:8765/index.html');await pg.wait_for_timeout(2500)
                js,root,wait=MAIN[nm],'sheet',1.2
            if js: await pg.evaluate("()=>{"+js+"}")
            await pg.wait_for_timeout(int(wait*1000))
            await pg.screenshot(path=D+'ref_'+nm+'.png',timeout=120000)
            try:
                d=await pg.evaluate(DUMP,root)
                json.dump(d,open(D+'raw_'+nm+'.json','w'))
                subprocess.run(['python3',D+'conv.py',D+'raw_'+nm+'.json',OUT,nm])
            except Exception as e: print(nm,'ERR',str(e)[:300])
            await ctx.close()
        await b.close()
asyncio.run(main(sys.argv[1:] or list(SHOTS)+list(MAIN)))
