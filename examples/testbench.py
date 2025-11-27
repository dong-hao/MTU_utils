# =======================================================================
# original comments from MATLAB script:
# simple testbench script, to read the MTU-5 TBL and TSN files
# DONG Hao
# 2011/07/04
# Beijing
# =======================================================================
import os
import sys
import matplotlib.pyplot as plt

# Add parent directory to path to import src modules
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

from src.read_tbl import read_tbl
from src.read_tsn import read_tsn

# Get the directory where this script is located
script_dir = os.path.dirname(os.path.abspath(__file__))

# read the TBL file
info = read_tbl(script_dir + '/', '1690C16C.TBL')

# read the TS4 file
ts, tag = read_tsn(script_dir + '/', '1690C16C.TS4')

exch = 0  # note python uses 0-based indexing
eych = 1
hxch = 2
hych = 3

# convert to physical units
# E field as mV/km
exfield = ts[exch, :] * info['FSCV'] / 2**23 * 1000 / info['EGN'] / info['EXLN'] * 1000
eyfield = ts[eych, :] * info['FSCV'] / 2**23 * 1000 / info['EGN'] / info['EYLN'] * 1000

# H field as nT
hxfield = ts[hxch, :] * info['FSCV'] / 2**23 * 1000 / info['HGN'] / info['HATT'] / info['HNOM']
hyfield = ts[hych, :] * info['FSCV'] / 2**23 * 1000 / info['HGN'] / info['HATT'] / info['HNOM']

# and plot the time series
fig, axs = plt.subplots(4, 1, figsize=(10, 8))
stt = 0  # adjust for 0-based indexing
edn = info['L4NS'] * info['SRL4'] -1  # adjust for 0-based indexing

axs[0].plot(exfield[stt:edn])
axs[0].set_ylabel('Ex (mV/km)')

axs[1].plot(eyfield[stt:edn])
axs[1].set_ylabel('Ey (mV/km)')

axs[2].plot(hxfield[stt:edn])
axs[2].set_ylabel('Hx (nT)')

axs[3].plot(hyfield[stt:edn])
axs[3].set_ylabel('Hy (nT)')
axs[3].set_xlabel('Sample')

plt.tight_layout()
plt.savefig(os.path.join(script_dir, 'timeseries_plot.png'), dpi=150)
print('# Plot saved to timeseries_plot.png')
plt.show()
