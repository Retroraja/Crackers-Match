import numpy as np, wave, os
SR = 22050
rng = np.random.default_rng(7)
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'sfx')
os.makedirs(OUT, exist_ok=True)

def t(d): return np.arange(int(SR * d)) / SR
def env(n, a=0.002, d=0.2):
    x = np.arange(n) / SR
    e = np.minimum(1, x / max(a, 1e-4)) * np.exp(-x / d)
    return e
def noise(d): return rng.uniform(-1, 1, int(SR * d))
def lp(x, fc):
    a = np.exp(-2 * np.pi * fc / SR); y = np.zeros_like(x); s = 0.0
    for i, v in enumerate(x): s = (1 - a) * v + a * s; y[i] = s
    return y
def hp(x, fc): return x - lp(x, fc)
def bp(x, lo, hi): return hp(lp(x, hi), lo)
def place(dst, src, at):
    i = int(at * SR); n = min(len(src), len(dst) - i)
    if n > 0: dst[i:i + n] += src[:n]
def sine(f, d, dec, f2=None):
    x = t(d); ff = f if f2 is None else f * (f2 / f) ** (x / d)
    ph = 2 * np.pi * np.cumsum(ff) / SR
    return np.sin(ph) * env(len(x), 0.001, dec)
def ping(f, d=0.5, dec=0.12, partials=(1, 2.76, 5.4), amps=(1, .5, .25)):
    s = sum(a * sine(f * p, d, dec / (1 + i * .6)) for i, (p, a) in enumerate(zip(partials, amps)))
    return s
def add(*xs):
    n=max(len(a) for a in xs); o=np.zeros(n)
    for a in xs: o[:len(a)]+=a
    return o
def save(name, x, gain=0.9):
    x = x / (np.max(np.abs(x)) + 1e-9) * gain
    fade = min(len(x), int(SR * .01)); x[-fade:] *= np.linspace(1, 0, fade)
    w = wave.open(os.path.join(OUT, name + '.wav'), 'wb'); w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR)
    w.writeframes((x * 32767).astype('<i2').tobytes()); w.close()

def thunk(d=0.35, f=120):
    return add(sine(f, d, .09, f * .55), lp(noise(d), 700) * env(int(SR * d), .001, .05) * 1.6)
def clatter(n, d, lo, hi, dec=.02, spread=.25):
    out = np.zeros(int(SR * d))
    for k in range(n):
        g = bp(noise(.08), lo, hi) * env(int(SR * .08), .0005, dec) * rng.uniform(.4, 1)
        place(out, g, rng.uniform(0, spread))
    return out

# 1 clay pot: crack tick + dull thunk + clay pieces
d = .6; x = np.zeros(int(SR * d))
place(x, bp(noise(.03), 1500, 5000) * env(int(SR * .03), .0005, .006) * .5, 0)
place(x, thunk(.4, 110), .03)
place(x, clatter(9, .55, 600, 2500, .025, .3) * .55, .07)
save('ob_pot', x)

# 2 soda: pop + clink + fizz
d = 1.1; x = np.zeros(int(SR * d))
pop = add(sine(420, .08, .02, 180), bp(noise(.05), 800, 3000) * env(int(SR * .05), .0005, .01) * .8)
place(x, pop, 0)
for f in (2600, 3400, 4100, 5200):
    place(x, ping(f, .4, .09, (1, 2.3, 3.9), (1, .4, .2)) * .35, rng.uniform(.03, .14))
place(x, clatter(10, .5, 3000, 8000, .012, .25) * .5, .04)
fz = hp(noise(.9), 3500) * (np.abs(lp(noise(.9), 30)) * 6 + .3)
fz *= np.minimum(1, t(.9) / .05) * np.exp(-t(.9) / .35)
place(x, fz * .35, .08)
save('ob_soda', x)

# 3 coconut knock (hit 1) and split + splash (hit 2)
d = .3; x = np.zeros(int(SR * d))
k = add(sine(330, .25, .045, 280) * .9, sine(760, .25, .02) * .4, bp(noise(.02), 1000, 4000) * env(int(SR * .02), .0003, .004) * .7)
place(x, k, 0); save('ob_coco_knock', x)
d = .9; x = np.zeros(int(SR * d))
place(x, bp(noise(.06), 900, 5000) * env(int(SR * .06), .0005, .012), 0)
place(x, sine(260, .3, .05, 180) * .8, 0)
for i in range(14):
    drop = sine(rng.uniform(900, 2200), .06, .012, rng.uniform(1800, 3600)) * rng.uniform(.15, .4)
    place(x, drop, .08 + rng.uniform(0, .45))
place(x, bp(noise(.5), 800, 6000) * env(int(SR * .5), .02, .12) * .35, .06)
save('ob_coco_split', x)

# 4 matchbox: flick (box flies) and final spark + strike
d = .35; x = np.zeros(int(SR * d))
place(x, bp(noise(.03), 1200, 4000) * env(int(SR * .03), .0005, .006), 0)
wh = bp(noise(.25), 1500, 4500) * np.sin(np.pi * t(.25) / .25) ** 2 * .35
place(x, wh, .02); place(x, sine(190, .12, .03) * .4, 0)
save('ob_match_flick', x)
d = 1.0; x = np.zeros(int(SR * d))
strike = hp(noise(.18), 2000) * np.minimum(1, t(.18) / .02) * np.exp(-t(.18) / .08) * 1.2
place(x, strike, 0)
place(x, lp(noise(.5), 900) * np.minimum(1, t(.5) / .03) * np.exp(-t(.5) / .2) * .6, .06)
for i in range(22):
    place(x, hp(noise(.01), 3000) * env(int(SR * .01), .0002, .002) * rng.uniform(.3, 1), .05 + rng.uniform(0, .7) ** 1.5)
save('ob_match_spark', x)

# 5 newspaper: string twang loosen; paper burst rustle
d = .45; x = np.zeros(int(SR * d))
tw = sine(330, .4, .1, 250) + .4 * sine(660, .4, .06, 500)
place(x, tw * .6, 0); place(x, bp(noise(.02), 1500, 5000) * env(int(SR * .02), .0005, .004), 0)
place(x, bp(noise(.3), 1500, 6000) * np.abs(lp(noise(.3), 40)) * 6 * np.exp(-t(.3) / .12) * .5, .03)
save('ob_news_loose', x)
d = .9; x = np.zeros(int(SR * d))
place(x, bp(noise(.08), 300, 3000) * env(int(SR * .08), .001, .03) * 1.0, 0)
rs = bp(noise(.8), 1200, 7000) * (np.abs(lp(noise(.8), 25)) * 8 + .1) * np.minimum(1, t(.8) / .02) * np.exp(-t(.8) / .28)
place(x, rs * .7, .02)
save('ob_news_burst', x)

# 6 bangles: glass crash + bright jingle cascade (louder)
d = 1.4; x = np.zeros(int(SR * d))
place(x, hp(noise(.25), 2500) * np.minimum(1, t(.25) / .002) * np.exp(-t(.25) / .05) * 1.4, 0)
place(x, sine(180, .2, .04, 90) * .6, 0)
place(x, clatter(26, .7, 3000, 10000, .012, .45) * .9, .01)
for i in range(30):
    f = rng.uniform(2000, 6000)
    place(x, ping(f, .7, rng.uniform(.1, .26), (1, 2.41, 4.1), (1, .4, .18)) * rng.uniform(.35, .8), rng.uniform(0, .7) ** 1.4)
x = np.tanh(x * 1.8)
save('ob_bangle', x, .98)
# 7 gift wrap: tear; open sparkle
d = .45; x = np.zeros(int(SR * d))
tr = bp(noise(.35), 900, 6000) * (np.abs(lp(noise(.35), 120)) * 5 + .15)
tr *= np.minimum(1, t(.35) / .01) * np.exp(-t(.35) / .15)
place(x, tr, 0); save('ob_gift_tear', x)
d = 1.2; x = np.zeros(int(SR * d))
place(x, tr * .9, 0)
for i, f in enumerate((1568, 2093, 2637, 3136, 4186)):
    place(x, ping(f, .7, .25, (1, 3.0), (1, .2)) * .35, .1 + i * .055)
for i in range(10):
    place(x, ping(rng.uniform(5000, 8000), .2, .05, (1,), (1,)) * .15, .15 + rng.uniform(0, .5))
save('ob_gift_open', x)

# 8 diyas: crack tick + glow whoosh + warm chime
d = 1.1; x = np.zeros(int(SR * d))
place(x, bp(noise(.03), 1500, 5000) * env(int(SR * .03), .0005, .006) * .6, 0)
place(x, thunk(.3, 150) * .5, .01)
place(x, clatter(6, .4, 700, 2800, .02, .2) * .4, .05)
whoosh = lp(noise(.6), 1400) * np.sin(np.pi * np.minimum(1, t(.6) / .6)) ** 2 * .45
place(x, whoosh, .06)
for i, f in enumerate((880, 1109, 1319)):
    place(x, ping(f, .8, .3, (1, 2.0, 3.0), (1, .3, .1)) * .3, .1 + i * .07)
save('ob_diya', x)
print(sorted(os.listdir(OUT)))
