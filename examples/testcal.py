# simple testbench script to read ascii Phoenix MTU-5/A instrument
# calibration files (clc/clb) exported from their official "syscal" routine.

import os
import sys

import matplotlib.pyplot as plt

# Add parent directory to path to import src modules
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

from src.read_boxcal import read_boxcal
from src.read_coilcal import read_coilcal


def main() -> None:
    script_dir = os.path.dirname(os.path.abspath(__file__))

    boxcal = read_boxcal(script_dir + '/', 'MTU-1690.clb')
    coilcal = [
        read_coilcal(script_dir + '/', 'coil1693.clc'),
        read_coilcal(script_dir + '/', 'coil1694.clc'),
        read_coilcal(script_dir + '/', 'coil1695.clc'),
    ]

    fullcal = []
    for ch in boxcal:
        fullcal.append(
            {
                'channel': ch['channel'],
                'freq': ch['freq'].copy(),
                'mag': ch['mag'].copy(),
                'phs': ch['phs'].copy(),
            }
        )

    for ihch in range(3):
        fullcal[ihch + 2]['mag'] = fullcal[ihch + 2]['mag'] * coilcal[ihch]['mag']
        fullcal[ihch + 2]['phs'] = fullcal[ihch + 2]['phs'] + coilcal[ihch]['phs']

    ihch = 2  # Hx channel (0-based index)
    fig, axs = plt.subplots(2, 1, figsize=(8, 6))
    axs[0].loglog(fullcal[ihch]['freq'], fullcal[ihch]['mag'])
    axs[0].set_ylabel('Magnitude')
    axs[0].set_xlabel('frequency (Hz)')

    axs[1].semilogx(fullcal[ihch]['freq'], fullcal[ihch]['phs'])
    axs[1].set_ylabel('Phase (degree)')
    axs[1].set_xlabel('frequency (Hz)')

    plt.tight_layout()
    out = os.path.join(script_dir, 'calibration_plot.png')
    plt.savefig(out, dpi=150)
    print(f'# Plot saved to {out}')
    plt.show()


if __name__ == '__main__':
    main()
