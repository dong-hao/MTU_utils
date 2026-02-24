"""
MTU_utils - Utility to read the Canadian Phoenix MTU-5A instrument 
files (time series and instrument response ) in Matlab (and Python)

A bunch of simple scripts to read the legacy Phoenix MTU-5A format
files ... including the time series (.TSN) and table (.TBL) formats, 
and the instrument (.clb) and coil (.clc) calibration ascii formats.


DONG Hao
donghao@cugb.edu.cn
China University of Geosciences, Beijing
"""

from .read_tbl import read_tbl
from .read_tsn import read_tsn
from .read_boxcal import read_boxcal
from .read_coilcal import read_coilcal

__all__ = ['read_tbl', 'read_tsn', "read_boxcal", "read_coilcal"]
__version__ = '1.0.1'
