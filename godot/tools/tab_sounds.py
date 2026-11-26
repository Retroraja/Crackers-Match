# 26 Nov: 5 louder tab-tap sounds to choose from (made in code). Output: /tmp/v/tab1..5.wav
import numpy as np, wave
from scipy.signal import butter, sosfilt
SR = 44100
rng = np.random.default_rng(11)
def bp(x, lo, hi): return sosfilt(butter(3, [lo, hi], 'bandpass', fs=SR, output='sos'), x)
def save(p, x, peak=0.97):
    x = sosfilt(butter(2, 150, 'highpass', fs=SR, output='sos'), x)
    x = np.tanh(x / np.max(np.abs(x)) * 1.4) / np.tanh(1.4) * peak
    x = np.concatenate([x, np.zeros(int(0.03 * SR))])
    w = wave.open(p, 'w'); w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR)
    w.writeframes((x * 32767).astype('<i2').tobytes()); w.close()
def t_(d): return np.arange(int(d * SR)) / SR
# 1 tock (the first one, louder)
t = t_(0.08); f = 1050 - 2500 * t
s = np.sin(2 * np.pi * np.cumsum(f) / SR) * np.exp(-t * 70) + bp(rng.normal(0, 1, len(t)), 2000, 6000) * np.exp(-t * 400) * 0.3
save('/tmp/v/tab1.wav', s)
# 2 bubble pop (rising pitch, round)
t = t_(0.09); f = 500 + 6000 * t
s = np.sin(2 * np.pi * np.cumsum(f) / SR) * np.exp(-t * 55) * np.minimum(1, t * 600)
save('/tmp/v/tab2.wav', s)
# 3 wooden block (two hollow partials)
t = t_(0.1)
s = (np.sin(2 * np.pi * 820 * t) + 0.6 * np.sin(2 * np.pi * 2240 * t) + 0.3 * np.sin(2 * np.pi * 3900 * t)) * np.exp(-t * 60)
s += bp(rng.normal(0, 1, len(t)), 1500, 5000) * np.exp(-t * 600) * 0.6
save('/tmp/v/tab3.wav', s)
# 4 bright tick + tiny bell (festive)
t = t_(0.18)
s = (np.sin(2 * np.pi * 1760 * t) + 0.5 * np.sin(2 * np.pi * 2640 * t) + 0.25 * np.sin(2 * np.pi * 5280 * t)) * np.exp(-t * 28)
s += bp(rng.normal(0, 1, len(t)), 3000, 9000) * np.exp(-t * 700) * 0.8
save('/tmp/v/tab4.wav', s)
# 5 soft thump-click (deep, punchy)
t = t_(0.09); f = 260 - 1200 * t
s = np.sin(2 * np.pi * np.cumsum(np.maximum(f, 90)) / SR) * np.exp(-t * 45)
s += bp(rng.normal(0, 1, len(t)), 2500, 7000) * np.exp(-t * 500) * 0.5
save('/tmp/v/tab5.wav', s)
