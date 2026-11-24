import numpy as np, wave
from scipy.signal import butter, sosfilt
SR = 44100
rng = np.random.default_rng(3)
def save(p, x):
    x = sosfilt(butter(2, 700, 'highpass', fs=SR, output='sos'), x)
    x = x / np.max(np.abs(x)) * 0.92
    w = wave.open(p, 'w'); w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR)
    w.writeframes((x * 32767).astype('<i2').tobytes()); w.close()
def bp(x, lo, hi): return sosfilt(butter(3, [lo, hi], 'bandpass', fs=SR, output='sos'), x)
# 1. ceramic plate smash: hard crack, then a shower of bright shards
out = np.zeros(int(SR * 1.0))
def add(s, t):
    i = int(t * SR); out[i:i + len(s)] += s[:len(out) - i]
n = int(0.03 * SR); t = np.arange(n) / SR
add(bp(rng.normal(0, 1, n), 1500, 11000) * np.exp(-t * 120) * 2.2, 0)
L = int(0.12 * SR); t = np.arange(L) / SR
add((np.sin(2*np.pi*1850*t) + .6*np.sin(2*np.pi*4100*t)) * np.exp(-t * 40) * 0.8, 0.002)
for k in range(46):
    tt = 0.015 + (k / 46) ** 1.6 * 0.75
    f = rng.uniform(3000, 9000)
    L = int(rng.uniform(0.02, 0.07) * SR); t = np.arange(L) / SR
    s = np.sin(2*np.pi*f*t + rng.uniform(0, 6)) * np.exp(-t * rng.uniform(60, 140))
    s += bp(rng.normal(0, 1, L), 4000, 10000) * np.exp(-t * 250) * 0.5
    add(s * rng.uniform(0.25, 0.7) * (1 - k / 60), tt)
save('tools/plate_smash.wav', out)
# 2. steel plate dropped: bright metal ring that spins down, wah-wah-wah faster and faster
out = np.zeros(int(SR * 1.6))
T = np.arange(len(out)) / SR
parts = [(1180, 1.0, 3.2), (2710, 0.7, 4.5), (4620, 0.5, 6), (6930, 0.35, 8)]
ring = sum(a * np.sin(2*np.pi*f*T) * np.exp(-T * d) for f, a, d in parts)
# the spin: amplitude wobble whose speed rises (like a plate settling on the floor)
ph = 2*np.pi*np.cumsum(6 + 38 * (T / T[-1]) ** 2) / SR
wob = 0.55 + 0.45 * np.abs(np.sin(ph))
out += ring * wob
for k, tt in enumerate([0, 0.18, 0.31]):          # first hit + two small bounces
    n = int(0.02 * SR); t = np.arange(n) / SR
    i = int(tt * SR); out[i:i+n] += bp(rng.normal(0, 1, n), 2000, 12000) * np.exp(-t * 200) * (1.6 - k * 0.5)
save('/tmp/steel_plate.wav', out)
