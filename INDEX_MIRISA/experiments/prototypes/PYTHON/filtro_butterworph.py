


# import numpy as np


# b, a = signal.butter(4, 100, 'bandpass', analog=True)
# w, h = signal.freqs(b, a)
# plt.semilogx(w, 20 * np.log10(abs(h)))
# plt.title('Butterworth filter frequency response')
# plt.xlabel('Frequency [radians / second]')
# plt.ylabel('Amplitude [dB]')
# plt.margins(0, 0.1)
# plt.grid(which='both', axis='both')
# plt.axvline(100, color='green') # cutoff frequency
# plt.show()

# t = np.linspace(0, 1, 1000, False)  # 1 second
# sig = np.sin(2*np.pi*10*t) + np.sin(2*np.pi*20*t)
# fig, (ax1, ax2) = plt.subplots(2, 1, sharex=True)
# ax1.plot(t, sig)
# ax1.set_title('10 Hz and 20 Hz sinusoids')
# ax1.axis([0, 1, -2, 2])

# sos = signal.butter(10, 15, 'hp', fs=1000, output='sos')
# filtered = signal.sosfilt(sos, sig)
# ax2.plot(t, filtered)
# ax2.set_title('After 15 Hz high-pass filter')
# ax2.axis([0, 1, -2, 2])
# ax2.set_xlabel('Time [seconds]')
# plt.tight_layout()
# plt.show()

import numpy as np
import matplotlib.pyplot as plt
import pandas as pd

from scipy.signal import freqz
from scipy.signal import butter, lfilter
from scipy import signal


data = pd.read_csv("teste.csv")

print(data["x"])

def butter_bandpass(lowcut, highcut, fs, order=5):
    return butter(order, [lowcut, highcut], fs=fs, btype='band')

def butter_bandpass_filter(data, lowcut, highcut, fs, order=5):
    b, a = butter_bandpass(lowcut, highcut, fs, order=order)
    y = lfilter(b, a, data)
    return y






# Sample rate and desired cutoff frequencies (in Hz).
fs = 2191
lowcut = 20 #500.0
highcut = 100 #1250.0

x = data["x"] 
t = data["t"]
# plt.figure(1)
# plt.clf()
# plt.plot(t, x, label='Noisy signal')

y = butter_bandpass_filter(x, lowcut, highcut, fs, order=5)
# plt.plot(t, y, label='Filtered signal (%g Hz)') # % f0)

# plt.show()

d = {'time': t, 'x_btwP': y}
df = pd.DataFrame(data=d)
df.to_csv("btw_py.csv", encoding='utf-8', index=False)
