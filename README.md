# MTU_utils
Utility to read the Canadian Phoenix MTU-5A instrument time series binary files in Matlab

A bunch of simple scripts to read the legacy Phoenix MTU-5A binary format files ... including the time series (.TSN) and table (.TBL) formats.  

## The instrument

A Canadian Broadband magnetotellurics system manufactured by Phoenix Geophysics Limited, which was quite popular in China. Please see their website for details:
[https://www.phoenix-geosystem.com/geosystem-1-mtu-mtua.html]

## DATA FORMAT

Unfortunately, although the format of MTU-5A time series (.TSN) is clearly described in the Phoenix Geophysics Limited official document. The formats of TBL and the CLC/CLB files are never explicitly explained. So the current reading functions are based mainly on the works of previous researchers and my limited understanding, see: 

"MTU Time Series Format" document from Phoenix Geophysics Limited for more details. 

see also my code to read the Ukraine LEMI-417 instrument binary files: 

[https://github.com/dong-hao/LEMI_Utils]


## Something like a disclaimer

This was one of many toy codes I fiddled with when I was a student - I hope this could be useful to our students nowadays in the EM community. 
Those who want to try this script are free to use it on academic/educational cases. But of course, I cannot guarantee the script to be working properly and calculating correctly (although I wish so). Have you any questions or suggestions, please feel free to contact me (but don't you expect that I will reply quickly!).  

## HOW TO GET IT
```
git clone https://github.com/dong-hao/MTU_Utils/ your_local_folder
```

## UNITS
*IMPORTANT NOTE:* 
The code reads in only the raw discrete values (i.e. not coverted to physical units yet). To convert to practical unit for electrical field (mV/km) and magnetic field (nT), one needs both the raw value and the metadata information from the TBL file. Assuming the time series array is “ts”, and the metadata structure is “info”, the E and H fields should be: 

``` matlab
exfield = ts(exch,:) * info.FSCV /2^23 * 1000 / info.EGN / info.EXLN * 1000;
eyfield = ts(eych,:) * info.FSCV /2^23 * 1000 / info.EGN / info.EXLN * 1000;
hxfield = ts(hxch,:) * info.FSCV /2^23 * 1000 / info.HGN / info.HATT/ info.HNOM;
hyfield = ts(hxch,:) * info.FSCV /2^23 * 1000 / info.HGN / info.HATT/ info.HNOM;
hzfield = ts(hzch,:) * info.FSCV /2^23 * 1000 / info.HGN / info.HATT/ info.HNOM;
```


## HOW TO GET UPDATED
```
cd to_you_local_folder
git pull 
```

## Contact

DONG Hao –  donghao@cugb.edu.cn

China University of Geosciences, Beijing 

Distributed under the MIT license. See ``LICENSE`` for more information.

[https://github.com/dong-hao/MTU_Utils]

## Contributing

Those who are willing to contribute are welcomed to try - but I probably won't have the time to review the commits frequently (not that I would expect there will be any). 

1. Fork it (<https://github.com/dong-hao/MTU_Utils/fork>)
2. Create your feature branch (`git checkout -b feature/somename`)
3. Commit your changes (`git commit -am 'Add some features'`)
4. Push to the branch (`git push origin feature/somename`)
5. Create a new Pull Request - lather, rinse, repeat 
