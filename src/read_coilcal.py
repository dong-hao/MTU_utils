"""
read_coilcal - reads an ascii coil response file of the legacy Phoenix
format (MTU-5A) and outputs a frequency-response dictionary.
"""

import os
from typing import Dict

import numpy as np


def read_coilcal(cdir: str, fname: str) -> Dict[str, np.ndarray]:
    """
    Parameters:
        cdir: path to the calibration file
        fname: name of calibration file (including extension)

    Returns:
        coilcal: dictionary with keys name, freq, mag, phs
    """
    filepath = os.path.join(cdir, fname)
    if not os.path.isfile(filepath):
        raise FileNotFoundError(f"Coil calibration {fname} not found")

    print(f"opening coil calibration file: {fname}")

    calength = 150
    coilcal: Dict[str, np.ndarray] = {
        "name": fname,
        "freq": np.zeros(calength, dtype=np.float64),
        "mag": np.ones(calength, dtype=np.float64),
        "phs": np.zeros(calength, dtype=np.float64),
    }

    with open(filepath, "r", encoding="latin-1") as fid:
        for _ in range(5):
            fid.readline()

        for j in range(calength):
            line = fid.readline()
            if not line:
                break

            line = line.replace(",", " ")
            vals = np.fromstring(line, sep=" ", dtype=np.float64)
            if vals.size < 3:
                continue

            coilcal["freq"][j] = vals[0]
            coilcal["mag"][j] = vals[1]
            coilcal["phs"][j] = vals[2]

    first_zero = np.where(coilcal["freq"] == 0)[0]
    if first_zero.size > 0:
        nrec = first_zero[0]
        coilcal["freq"] = coilcal["freq"][:nrec]
        coilcal["mag"] = coilcal["mag"][:nrec]
        coilcal["phs"] = coilcal["phs"][:nrec]

    return coilcal


if __name__ == "__main__":
    import sys

    if len(sys.argv) >= 3:
        cal = read_coilcal(sys.argv[1], sys.argv[2])
        print(f"Records: {cal['freq'].size}")
