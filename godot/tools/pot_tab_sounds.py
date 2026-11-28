# 26 Nov: new sounds (made in code, like tools/plate_sound.py):
#  ob_pot2.wav  clay pot breaking (dull body thump + crack, chunky terracotta pieces, a little gritty rattle)
#  ui_tab.wav   bottom menu tab tap: short soft "tock"
#  ui_slide.wav page slide: very quiet airy whoosh
import numpy as np, wave
from scipy.signal import butter, sosfilt
SR = 44100
rng = np.random.default_rng(7)
def save(p, x, peak=0.92, hp=120):
    x = sosfilt(butter(2, hp, 'highpass', fs=SR, output='sos'), x)
    x = x / np.max(np.abs(x)) * peak
    w = wave.open(p, 'w'); w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR)
    w.writeframes((x * 32767).astype('<i2').tobytes()); w.close()
def bp(x, lo, hi, o=3): return sosfilt(butter(o, [lo, hi], 'bandpass', fs=SR, output='sos'), x)
def lp(x, f): return sosfilt(butter(2, f, 'lowpass', fs=SR, output='sos'), x)
# ---- clay pot break
out = np.zeros(int(SR * 0.95))
def add(s, t):
    i = int(t * SR); out[i:i + len(s)] += s[:len(out) - i]
L = int(0.09 * SR); t = np.arange(L) / SR
add(np.sin(2 * np.pi * (260 - 400 * t) * t) * np.exp(-t * 45) * 1.1, 0)          # hollow body thump
n = int(0.05 * SR); t = np.arange(n) / SR
add(bp(rng.normal(0, 1, n), 600, 5200) * np.exp(-t * 70) * 1.6, 0.003)               # dry crack
for k in range(26):                                                                    # chunky pieces
    tt = 0.03 + (k / 26) ** 1.5 * 0.55
    L = int(rng.uniform(0.025, 0.06) * SR); t = np.arange(L) / SR
    f = rng.uniform(700, 2200)
    s = np.sin(2 * np.pi * f * t) * np.exp(-t * rng.uniform(90, 160)) * 0.6
    s += bp(rng.normal(0, 1, L), 900, 4500) * np.exp(-t * 180) * 0.8
    add(s * rng.uniform(0.3, 0.8) * (1 - k / 34), tt)
n = int(0.45 * SR); t = np.arange(n) / SR                                              # gritty rattle settling
add(bp(rng.normal(0, 1, n), 1500, 6000) * (np.abs(np.sin(t * 90)) ** 6) * np.exp(-t * 7) * 0.25, 0.12)
save('sfx/ob_pot2.wav', lp(out, 7000))
# ---- tab tap
L = int(0.08 * SR); t = np.arange(L) / SR
f = 1050 - 2500 * t
s = np.sin(2 * np.pi * np.cumsum(f) / SR) * np.exp(-t * 70)
s += bp(rng.normal(0, 1, L), 2000, 6000) * np.exp(-t * 400) * 0.25
save('sfx/ui_tab.wav', np.concatenate([s, np.zeros(int(0.02 * SR))]), peak=0.55)
# ---- page slide whoosh
n = int(0.28 * SR); t = np.arange(n) / SR
env = np.sin(np.pi * t / t[-1]) ** 2
noise = rng.normal(0, 1, n)
lo = 600 + 2200 * t / t[-1]
s = np.zeros(n)
for i in range(0, n, 512):          # band sweeping up
    seg = noise[i:i + 512]
    c = lo[i]
    s[i:i + 512] = bp(np.concatenate([noise[max(0, i - 1024):i], seg]), c, c * 2.2, 2)[-len(seg):]
save('sfx/ui_slide.wav', s * env, peak=0.35)
