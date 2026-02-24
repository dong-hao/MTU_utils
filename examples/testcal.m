% simple testbench script to read ascii Phoenix MTU-5/A instrument 
% calibration files (clc/clb) exported from their official "syscal" routine 
% note there is no official documents on how to read (and more importantly,
% apply) the binary calibration, so we should settle with the ascii version
% for now. 
% 
% DONG Hao
% 2011/08/04
% Beijing
% ======================================================================= %
clear
addpath(genpath('..'),'-end');
% read the box calibration file
boxcal=readBoxcal('./','MTU-1690.clb');
% read the coil calibration file
coilcal = cell(3,1);
coilcal{1}=readCoilcal('./','coil1693.clc');
coilcal{2}=readCoilcal('./','coil1694.clc');
coilcal{3}=readCoilcal('./','coil1695.clc');
fullcal = boxcal;
for ihch = 1:3
    % calculate the response for each channel
    fullcal{ihch+2}.mag = fullcal{ihch+2}.mag .* coilcal{ihch}.mag;
    fullcal{ihch+2}.phs = fullcal{ihch+2}.phs + coilcal{ihch}.phs;
end
% now we plot the magnitude and phase response for Hx channel
figure(1)
ihch = 3;
subplot(2,1,1);
loglog(fullcal{ihch}.freq,fullcal{ihch}.mag);
ylabel('Magnitude');
xlabel('frequency (Hz)');
subplot(2,1,2);
semilogx(fullcal{ihch}.freq, fullcal{ihch}.phs);
ylabel('Phase (degree)');
xlabel('frequency (Hz)');