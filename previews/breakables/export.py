import asyncio,base64,os,json
from playwright.async_api import async_playwright
OUT='/home/claude/crackers-match/godot/art/brk';os.makedirs(OUT,exist_ok=True)
SZ=240
async def main():
  async with async_playwright() as p:
    b=await p.chromium.launch(executable_path='/usr/bin/google-chrome',args=['--no-sandbox'])
    pg=await b.new_page(viewport={'width':540,'height':960},device_scale_factor=1)
    await pg.goto('file:///home/claude/prev/breakables.html?rec=1');await pg.wait_for_function('window.__ready&&__ready()')
    async def save(name,url):
      open(f'{OUT}/{name}.png','wb').write(base64.b64decode(url.split(',')[1]))
    cr_pot='makeCracks(77,5,0,-.02,.36)'
    states={'pot_1':'{}','pot_c':'{cr:'+cr_pot+'}','soda_1':'{}','coco_2':'{}','coco_1':'{hp:1,split:__cocosplit}',
      'match_3':'{hp:3}','match_2':'{hp:2}','match_1':'{hp:1}','match_o':'{hp:1,showBoxes:1,open:1}',
      'news_2':'{}','news_1':'{hp:1}','bangle_1':'{}','gift_2':'{}',
      'gift_1':'{hp:1,tear:[[-.3,-.08],[-.17,-.12],[-.1,.0],[-.16,.08],[-.08,.2],[-.24,.24],[-.34,.14],[-.33,.02]]}',
      'diya_1':'{}','diya_c':'{cr:(function(){var L=[];DPOS.forEach(function(p,i){makeCracks(i*7+5,3,p[0]-.04,p[1]+.05,.14).forEach(function(c){L.push(c)})});return L})()}'}
    for n,st in states.items():
      k=n.split('_')[0]
      await save(n,await pg.evaluate(f"__exp('{k}',{st},{SZ})"))
    for i in range(7): await save(f'ring{i}',await pg.evaluate(f"__spr('ring',{SZ},{i})"))
    for i in range(3): await save(f'mbox{i}',await pg.evaluate(f"__spr('mbox',{SZ},{i})"))
    for i in range(2): await save(f'half{i}',await pg.evaluate(f"__spr('half',{SZ},{i})"))
    for n in ['sheet','bow','flame']: await save(n,await pg.evaluate(f"__spr('{n}',{SZ},0)"))
    # diya flame positions + misc geometry for Godot
    geo=await pg.evaluate("({dpos:DPOS,mpos:MPOS,split:__cocosplit})")
    json.dump(geo,open(f'{OUT}/geo.json','w'))
    await b.close()
asyncio.run(main())
