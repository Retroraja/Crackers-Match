# Synthesises the story music and sounds (17 Nov): python3 tools/story_audio.py  (run in godot/), then theme and wind to .ogg with ffmpeg -c:a libvorbis -q:a 5
# story_theme: 72 bpm, D major, soft piano arpeggios + warm strings, bansuri-style flute from bar 5, swell into bar 9.
import numpy as np, scipy.io.wavfile as w
from scipy.signal import fftconvolve, butter, sosfilt

R = 44100
rng = np.random.default_rng(3)
BEAT = 60 / 72
BAR = BEAT * 4

def hz(n):  # note name -> Hz
    names = {'C': 0, 'C#': 1, 'D': 2, 'D#': 3, 'E': 4, 'F': 5, 'F#': 6, 'G': 7, 'G#': 8, 'A': 9, 'A#': 10, 'B': 11}
    o = int(n[-1]); k = names[n[:-1]]
    return 440 * 2 ** ((k - 9) / 12 + (o - 4))

def bp(x, lo, hi, order=2):
    return sosfilt(butter(order, [lo, hi], 'bandpass', fs=R, output='sos'), x)

def lp(x, f, order=2):
    return sosfilt(butter(order, f, 'lowpass', fs=R, output='sos'), x)

def add(buf, at, x):
    i = int(at * R)
    if i >= len(buf): return
    m = min(len(x), len(buf) - i)
    buf[i:i + m] += x[:m]

def piano(f, dur, vel):
    n = int((dur + 1.6) * R); t = np.arange(n) / R
    y = np.zeros(n)
    for h in range(1, 8):
        fh = f * h * (1 + 0.0004 * h * h)
        y += np.sin(2 * np.pi * fh * t) / h ** 1.6 * np.exp(-t * (0.9 + h * 0.55))
    y *= np.minimum(1, t / 0.004)
    rel = np.clip(1 - (t - dur) / 0.5, 0, 1); y *= np.where(t > dur, rel, 1)
    return y * vel

def strings(fs, dur, vel):
    n = int((dur + 2.0) * R); t = np.arange(n) / R
    y = np.zeros(n)
    for f in fs:
        for d in (-0.12, 0, 0.11):
            ff = f * 2 ** (d / 12)
            ph = rng.random() * 6.28
            for h in range(1, 10):
                y += np.sin(2 * np.pi * ff * h * t + ph * h) / h * (0.7 if h % 2 == 0 else 1)
    y = lp(y, 1600)
    env = np.minimum(1, t / 1.4) * np.where(t > dur, np.clip(1 - (t - dur) / 1.8, 0, 1), 1)
    return y * env * vel / (len(fs) * 3)

def flute(f, dur, vel):
    n = int((dur + 0.3) * R); t = np.arange(n) / R
    vib = 1 + 0.006 * np.sin(2 * np.pi * 5.2 * t) * np.minimum(1, t / 0.6)
    ph = 2 * np.pi * np.cumsum(f * vib) / R
    y = np.sin(ph) + 0.22 * np.sin(2 * ph) + 0.08 * np.sin(3 * ph)
    br = bp(rng.standard_normal(n), f * 0.9, min(f * 3.5, 15000)) * 0.12
    env = np.minimum(1, t / 0.09) * np.where(t > dur, np.clip(1 - (t - dur) / 0.25, 0, 1), 1) * (0.85 + 0.15 * np.minimum(1, t / 0.8))
    return (y + br) * env * vel

def drum(vel):
    n = int(1.2 * R); t = np.arange(n) / R
    f = 62 + 40 * np.exp(-t * 18)
    y = np.sin(2 * np.pi * np.cumsum(f) / R) * np.exp(-t * 3.2)
    y += lp(rng.standard_normal(n), 400) * np.exp(-t * 25) * 0.6
    return y * vel

def bell(f, vel, d=1.8):
    n = int(d * R); t = np.arange(n) / R
    y = sum(np.sin(2 * np.pi * f * r * t) * a * np.exp(-t * (1.6 + r)) for r, a in [(1, 1), (2.76, .35), (5.4, .18), (8.9, .08)])
    return y * np.minimum(1, t / 0.002) * vel

def reverb(x, wet=0.3, decay=0.7, length=2.6):
    n = int(length * R); t = np.arange(n) / R
    ir = rng.standard_normal(n) * np.exp(-t / decay)
    ir = lp(ir, 5000); ir[:int(0.012 * R)] = 0
    ir /= np.sqrt((ir ** 2).sum())
    return x * (1 - wet) + fftconvolve(x, ir)[:len(x)] * wet * 3

def save(name, x, peak=0.9):
    x = x / (np.abs(x).max() + 1e-9) * peak
    w.write(f'sfx/{name}.wav', R, (x * 32767).astype(np.int16))

# ---------------------------------------------------------------- theme
L = int((BAR * 9 + 4) * R)
mus = np.zeros(L)
CH = [['B2', 'F#3', 'B3', 'D4', 'F#4'], ['G2', 'D3', 'G3', 'B3', 'D4'], ['D3', 'A3', 'D4', 'F#4', 'A4'], ['A2', 'E3', 'A3', 'C#4', 'E4'],
      ['B2', 'F#3', 'B3', 'D4', 'F#4'], ['G2', 'D3', 'G3', 'B3', 'D4'], ['E2', 'B2', 'E3', 'G3', 'B3'], ['A2', 'E3', 'A3', 'C#4', 'E4'],
      ['D2', 'A2', 'D3', 'F#3', 'A3']]
pat = [0, 2, 3, 4, 3, 2, 1, 2]
for b, ch in enumerate(CH):
    t0 = b * BAR
    grow = 0.55 + 0.45 * min(1, b / 6)
    if b < 8:
        for i, k in enumerate(pat):
            add(mus, t0 + i * BEAT / 2, piano(hz(ch[k]) * (2 if k >= 3 and b >= 4 else 1), BEAT * 0.9, (0.22 if i % 4 == 0 else 0.15) * grow))
        add(mus, t0, piano(hz(ch[0]) / 2, BAR, 0.22))
    else:
        for i, k in enumerate([0, 1, 2, 3, 4]):
            add(mus, t0 + i * 0.06, piano(hz(ch[k]) * 2, BAR * 1.2, 0.26))
        add(mus, t0, piano(hz(ch[0]), BAR * 1.2, 0.3))
    add(mus, t0, strings([hz(n) for n in ch[1:4]], BAR, 0.10 * grow + (0.06 if b >= 6 else 0)))
# flute melody from bar 5
mel = [[('F#5', 2), ('D5', 1), ('E5', 1)], [('D5', 1.5), ('B4', .5), ('D5', 2)], [('E5', 1), ('G5', 1), ('B5', 2)],
       [('A5', 1.5), ('G5', .5), ('E5', 1), ('C#5', 1)], [('D5', 4)]]
for j, bar in enumerate(mel):
    t = (4 + j) * BAR
    for n, d in bar:
        add(mus, t, flute(hz(n), d * BEAT * 0.97, 0.16 if j < 4 else 0.2))
        t += d * BEAT
# soft drums and a cymbal swell into the last bar
for b in (6, 7):
    for bt in (0, 2, 3.5):
        add(mus, b * BAR + bt * BEAT, drum(0.22 if bt == 0 else 0.13))
n = int(BAR * 1.0 * R); t = np.arange(n) / R
sw = bp(rng.standard_normal(n), 3000, 12000) * (t / t[-1]) ** 3 * 0.18
add(mus, 7 * BAR, sw)
add(mus, 8 * BAR, drum(0.35))
for f, d in [('D6', 0), ('A6', 0.12), ('D7', 0.24)]:
    add(mus, 8 * BAR + d, bell(hz(f), 0.12, 3))
mus = reverb(mus, 0.32, 0.8, 3.0)
fade = int(2.5 * R); mus[-fade:] *= np.linspace(1, 0, fade)
save('story_theme', mus, 0.85)

# ---------------------------------------------------------------- wind (evening breeze, 30 s)
n = 30 * R; t = np.arange(n) / R
x = lp(np.cumsum(rng.standard_normal(n)) * 0.02, 900)
x -= lp(x, 40)
g = 0.55 + 0.45 * np.sin(2 * np.pi * 0.11 * t) * np.sin(2 * np.pi * 0.047 * t + 1)
x = x * g
x += bp(rng.standard_normal(n), 2500, 6000) * 0.004 * (0.5 + 0.5 * np.sin(2 * np.pi * 0.07 * t))
x[:R] *= np.linspace(0, 1, R)
save('story_wind', x, 0.5)

# ---------------------------------------------------------------- page flip
n = int(0.55 * R); t = np.arange(n) / R
nz = bp(rng.standard_normal(n), 900, 7000)
env = np.exp(-((t - 0.16) / 0.09) ** 2) + 0.5 * np.exp(-((t - 0.32) / 0.05) ** 2)
fl = 0.6 + 0.4 * np.sin(2 * np.pi * 34 * t)
th = np.sin(2 * np.pi * 90 * t) * np.exp(-np.maximum(0, t - 0.33) * 30) * (t > 0.33) * 0.4
save('story_page', nz * env * fl + th, 0.8)

# ---------------------------------------------------------------- pen scratch
n = int(0.09 * R); t = np.arange(n) / R
save('story_pen', bp(rng.standard_normal(n), 2500, 7000) * np.sin(np.pi * t / t[-1]) ** 2, 0.5)

# ---------------------------------------------------------------- chime
x = np.zeros(int(2.2 * R))
add(x, 0, bell(hz('A5'), 0.5)); add(x, 0.14, bell(hz('D6'), 0.5)); add(x, 0.28, bell(hz('F#6'), 0.45))
save('story_chime', reverb(x, 0.3), 0.7)

# ---------------------------------------------------------------- dream shimmer (factory outline appears)
n = int(3.0 * R); t = np.arange(n) / R
x = np.zeros(n)
pent = ['D6', 'E6', 'F#6', 'A6', 'B6', 'D7', 'E7']
for i in range(26):
    add(x, i * 0.09 + rng.random() * 0.05, bell(hz(pent[rng.integers(len(pent))]), 0.18 * (1 - i / 30), 1.2))
x += strings([hz('D4'), hz('A4'), hz('F#5')], 2.0, 0.12)[:n] * 1.0
save('story_dream', reverb(x, 0.4), 0.75)

# ---------------------------------------------------------------- rise into level 1
n = int(1.6 * R); t = np.arange(n) / R
k = (t / t[-1]) ** 2
x = bp(rng.standard_normal(n), 400, 9000) * k * 0.5
x += np.sin(2 * np.pi * np.cumsum(200 + 900 * k) / R) * k * 0.15
y = np.zeros(int(2.6 * R)); add(y, 0, x)
add(y, 1.45, bell(hz('D6'), 0.4, 1.2)); add(y, 1.45, bell(hz('A6'), 0.3, 1.2)); add(y, 1.45, drum(0.5))
save('story_rise', reverb(y, 0.3), 0.85)
print('ok')

# ---------------------------------------------------------------- v2: footstep, sigh, diya ting
n = int(0.22 * R); t = np.arange(n) / R
st = np.sin(2 * np.pi * np.cumsum(90 + 60 * np.exp(-t * 40)) / R) * np.exp(-t * 28) * 0.6
st += bp(rng.standard_normal(n), 600, 4000) * np.exp(-t * 22) * 0.5
save('story_step', st, 0.7)
n = int(1.4 * R); t = np.arange(n) / R
env = np.minimum(1, t / 0.25) * np.exp(-np.maximum(0, t - 0.25) * 2.6)
sg = bp(rng.standard_normal(n), 350, 1600) * env + bp(rng.standard_normal(n), 2000, 5000) * env * 0.3
save('story_sigh', sg, 0.6)
x = np.zeros(int(1.3 * R)); add(x, 0, bell(hz('D7'), 0.4, 1.2)); add(x, 0.03, bell(hz('A7'), 0.15, 1.0))
save('story_ting', reverb(x, 0.35), 0.6)
print('v2 ok')
