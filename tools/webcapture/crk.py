import asyncio,base64,re
from playwright.async_api import async_playwright
O='/home/claude/crackers-match/godot/art/crk/'
async def main():
    async with async_playwright() as p:
        b=await p.chromium.launch();pg=await b.new_page()
        await pg.goto('http://localhost:8765/index.html');await pg.wait_for_timeout(2500)
        d=await pg.evaluate("()=>({b:CRK.b.map(x=>typeof x=='string'?x:(x&&x.src)||''),t:CRK.t.map(x=>typeof x=='string'?x:(x&&x.src)||'')})")
        for k in ['b','t']:
            for i,u in enumerate(d[k]):
                m=re.match(r'data:image/(\w+);base64,(.*)',u or '')
                if m: open(O+'%s%d.%s'%(k,i,m.group(1)),'wb').write(base64.b64decode(m.group(2)))
        print(len(d['b']),len(d['t']))
        await b.close()
asyncio.run(main())
