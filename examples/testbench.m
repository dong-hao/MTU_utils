% simple testbench script, to read the MTU-5 TBL and TSN files 
% DONG Hao
% 2011/07/04
% Beijing
% ======================================================================= %
clear
addpath(genpath('..'),'-end');
% read the TBL file
info=readTBL('./','1690C16C.TBL');
% read the TS5 file
[ts, tag] = readTSN('./','1690C16C.TS4');
exch = 1;
eych = 2;
hxch = 3;
hych = 4;
% convert to physical units
% E field as mV/km
exfield = ts(exch,:) * info.FSCV /2^23 * 1000 / info.EGN / info.EXLN * 1000;
eyfield = ts(eych,:) * info.FSCV /2^23 * 1000 / info.EGN / info.EXLN * 1000;
% H field as nT
hxfield = ts(hxch,:) * info.FSCV /2^23 * 1000 / info.HGN / info.HATT/ info.HNOM;
hyfield = ts(hych,:) * info.FSCV /2^23 * 1000 / info.HGN / info.HATT/ info.HNOM;
%　and plot the time series
figure(1);
stt = 1;
edn = info.L4NS* info.SRL4;
subplot(4,1,1);
plot(exfield(stt:edn));
subplot(4,1,2);
plot(eyfield(stt:edn));
subplot(4,1,3);
plot(hxfield(stt:edn));
subplot(4,1,4);
plot(hyfield(stt:edn));