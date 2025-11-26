"""
MTU_utils - Utility to read the Canadian Phoenix MTU-5A instrument 
time series binary files in Python

A bunch of simple scripts to read the legacy Phoenix MTU-5A binary format 
files ... including the time series (.TSN) and table (.TBL) formats.

Author: DONG Hao
Email: donghao@cugb.edu.cn
Affiliation: China University of Geosciences, Beijing
"""

from .read_tbl import read_tbl
from .read_tsn import read_tsn

__all__ = ['read_tbl', 'read_tsn']
__version__ = '1.0.0'
