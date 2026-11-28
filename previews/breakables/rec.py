import asyncio,json,os,subprocess,numpy as np,wave
from playwright.async_api import async_playwright
FPS=30;DUR=17.5
EV=[(.5,'h0'),(1.3,'h1'),(2.1,'h2'),(2.8,'h2'),(3.6,'h3'),(4.1,'h3'),(4.6,'h3'),(5.5,'h4'),(6.1,'h4'),(6.9,'h5'),(7.7,'h6'),(8.3,'h6'),(9.1,'h7'),(11.0,'r1'),(12.2,'r2'),(13.6,'b'),(15.4,'b')]
os.makedirs('frames',exist_ok=True)
async def main():
  async with async_playwright() as p:
    b=await p.chromium.launch(executable_path='/usr/bin/google-chrome',args=['--no-sandbox'])
    pg=await b.new_page(viewport={'width':540,'height':960},device_scale_factor=2)
    await pg.goto('file:///home/claude/prev/breakables.html?rec=1');await pg.wait_for_function('window.__ready&&__ready()')
    ev=list(EV);n=int(DUR*FPS)
    for f in range(n):
      t=f/FPS
      while ev and ev[0][0]<=t:
        _,c=ev.pop(0)
        js={'h':f'__hit({c[1:]})','r':f'__rocket({c[1:]})','b':'__bomb()'}[c[0]]
        await pg.evaluate(js)
      await pg.evaluate(f'__adv({1/FPS})')
      await pg.screenshot(path=f'frames/{f:04d}.jpg',type='jpeg',quality=92)
    snd=await pg.evaluate('__snd');json.dump(snd,open('snd.json','w'))
    await b.close()
asyncio.run(main())
# audio mix
SR=44100
def load(n):
  p=f'sfx/{n}.wav' if os.path.exists(f'sfx/{n}.wav') else f'/home/claude/repo/godot/sfx/{n}.mp3'
  raw=subprocess.run(['ffmpeg','-loglevel','error','-i',p,'-f','s16le','-ac','1','-ar',str(SR),'-'],capture_output=True).stdout
  return np.frombuffer(raw,'<i2').astype(np.float32)/32768
cache={};mix=np.zeros(int(SR*(DUR+2)))
for e in json.load(open('snd.json')):
  x=cache.setdefault(e['n'],load(e['n']))
  r=e.get('r',1)
  if abs(r-1)>1e-3: x=np.interp(np.arange(0,len(x)-1,r),np.arange(len(x)),x)
  i=int((e['t']-1/FPS)*SR);i=max(i,0);m=min(len(x),len(mix)-i);mix[i:i+m]+=x[:m]*e.get('v',1)
pk=np.max(np.abs(mix));mix=np.tanh(mix/max(pk,1)*1.2)*.9
w=wave.open('mix.wav','wb');w.setnchannels(1);w.setsampwidth(2);w.setframerate(SR);w.writeframes((mix*32767).astype('<i2').tobytes());w.close()
subprocess.run(['ffmpeg','-loglevel','error','-y','-framerate',str(FPS),'-i','frames/%04d.jpg','-i','mix.wav','-vf','scale=720:1280:flags=lanczos','-c:v','libx264','-preset','veryfast','-crf','20','-pix_fmt','yuv420p','-c:a','aac','-b:a','128k','-shortest','-movflags','+faststart','breakables-preview.mp4'],check=True)
print('done',len(json.load(open('snd.json'))),'sounds')
