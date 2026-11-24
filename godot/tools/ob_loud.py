# 24 Nov: obstacle sounds louder and clean, so the cracker blasts don't hide them.
# - ob_bangle.wav = the china plate smash (tools/plate_sound.py, chosen 24 Nov), driven louder
# - every sfx/ob_*.wav: low hum / offset removed (diya, soda, gift open had it), cut below 150 Hz (the crackers'
#   range), then pushed up with a soft limiter to the same loud level.
# Run from godot/: python3 tools/ob_loud.py   (reads tools/plate_smash.wav made by plate_sound.py)
import glob, wave, numpy as np
from scipy.signal import butter, sosfiltfilt
def load(p):
    w = wave.open(p); sr = w.getframerate(); ch = w.getnchannels()
    x = np.frombuffer(w.readframes(w.getnframes()), '<i2').astype(float) / 32768
    if ch == 2: x = x.reshape(-1, 2).mean(1)
    return x, sr
def save(p, x, sr):
    w = wave.open(p, 'w'); w.setnchannels(1); w.setsampwidth(2); w.setframerate(sr)
    w.writeframes((np.clip(x, -1, 1) * 32767).astype('<i2').tobytes()); w.close()
def loud(x, sr, drive):
    x = x - np.mean(x)
    x = sosfiltfilt(butter(4, 150, 'highpass', fs=sr, output='sos'), x)
    x = x / (np.max(np.abs(x)) + 1e-9)
    x = np.tanh(x * drive) / np.tanh(drive)       # soft limiter: more body, same peak
    return x * 0.97
DRIVE = {'ob_soda.wav': 4.5, 'ob_gift_open.wav': 3.5, 'ob_news_burst.wav': 3.5}
for p in sorted(glob.glob('sfx/ob_*.wav')):
    if p.endswith('ob_bangle.wav'):
        x, sr = load('tools/plate_smash.wav')
        x = loud(x, sr, 7.0)
    else:
        x, sr = load(p)
        x = loud(x, sr, DRIVE.get(p.split('/')[-1], 2.4))
    save(p, x, sr)
    print(p, 'rms %.3f' % np.sqrt(np.mean(x ** 2)))
