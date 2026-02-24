"""
read_boxcal - reads an ascii instrument response file of the legacy Phoenix
format (MTU-5A) and outputs channel-wise frequency response dictionaries.
"""

import os
from typing import Dict, List

import numpy as np


def _trim_padding(channel: Dict[str, np.ndarray]) -> Dict[str, np.ndarray]:
    first_zero = np.where(channel["freq"] == 0)[0]
    if first_zero.size == 0:
        return channel

    nrec = first_zero[0]
    channel["freq"] = channel["freq"][:nrec]
    channel["mag"] = channel["mag"][:nrec]
    channel["phs"] = channel["phs"][:nrec]
    return channel


def read_boxcal(fpath: str, fname: str, nc: int = 5) -> List[Dict[str, np.ndarray]]:
    """
    Parameters:
        fpath: path to the calibration file
        fname: name of calibration file (including extension)
        nc: number of channels (default 5 for MTU-5A)

    Returns:
        boxcal: list of channel dictionaries with keys:
                channel, freq, mag, phs
    """
    filepath = os.path.join(fpath, fname)
    if not os.path.isfile(filepath):
        raise FileNotFoundError(f"Box calibration {fname} not found")

    print(f"opening box calibration file: {fname}")

    calength = 150
    boxcal: List[Dict[str, np.ndarray]] = []
    for i in range(nc):
        boxcal.append(
            {
                "channel": i + 1,
                "freq": np.zeros(calength, dtype=np.float64),
                "mag": np.ones(calength, dtype=np.float64),
                "phs": np.zeros(calength, dtype=np.float64),
            }
        )

    with open(filepath, "r", encoding="latin-1") as fid:
        for _ in range(5):
            fid.readline()

        for j in range(calength):
            line = fid.readline()
            if not line:
                break

            line = line.replace(",", " ")
            vals = np.fromstring(line, sep=" ", dtype=np.float64)
            if vals.size == 0:
                continue

            expected = 11 if nc == 5 else 9
            if vals.size < expected:
                continue

            freq = vals[0]
            for i in range(nc):
                boxcal[i]["freq"][j] = freq
                boxcal[i]["mag"][j] = vals[2 * i + 1]
                boxcal[i]["phs"][j] = vals[2 * i + 2]

    for i in range(nc):
        boxcal[i] = _trim_padding(boxcal[i])

    return boxcal


if __name__ == "__main__":
    import sys

    if len(sys.argv) >= 3:
        cal = read_boxcal(sys.argv[1], sys.argv[2])
        print(f"Loaded {len(cal)} channels")
        if len(cal) > 0:
            print(f"Records in channel 1: {cal[0]['freq'].size}")
