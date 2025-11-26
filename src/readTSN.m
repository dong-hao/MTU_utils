function [Ts, Tinfo]=readTSN(TSfid,DAC,ELN,csetup,Egain,Egainc,Hgain,Hgainc)
% Nch=5 for Two E channels and Three H channels.
% TSfid: the file handle of TS file
% ELN:   1 by 3 array of Electrical Dipole length
% csetup: channel setup to distinguish from e and h channels
% Hgain: gain of H channels
% Egain: gain of E channels
% HNOM:  Normalizing Factor of H channels
% DAC:   DA convert from recorded values to mV
% ======================================================================= %
% 0-7   UTC time of first scan in the record. 
% 8-9   instrument serial number (16-bit integer)
% 10-11 number of scans in the record (16-bit integer)
% 12    number of channels per scan
% 13    tag length (TSn) or tag length code (TSH, TSL)
% 14    status code
% 15    bit-wise saturation flags (please note that the TSH/L tag ends
% here )
% 16    reserved for future indication of different tag and/or sample
% formats
% 17    sample length in bytes
% 18-19 sample rate (in units defined by byte 20)
% 20    units of sample rate
% 21    clock status
% 22-25 clock error in seconds
% 26-32 reserved; must be 0
% ======================================================================= %
% some notes on the ts format of tsn file
% each time record consists of three bytes,  
% let's name them byte 1, byte 2, and byte 3
% the time record should be (+-) (byte2*256 + byte1)
% please note that the third byte is merely a sigh byte. if read in uint8
% format, it should be 255(-) or 0(+).
% ======================================================================= %
%  	try opening the ts data file 
% p24=2^24;
global custom
p16=2^16;
p8=2^8;
% scan through time series
% now reading a 32 Byte header info
s = fread(TSfid, 1, 'uint8' ) ; %Starting second
if isempty(s)
    Ts=[];
    Tinfo=[];
    return
end
m = fread(TSfid, 1, 'uint8' ) ; %Starting minute
h = fread(TSfid, 1, 'uint8' ) ; %Starting hour
d = fread(TSfid, 1, 'uint8' ) ; %Starting day
l = fread(TSfid, 1, 'uint8' ) ; %Starting month
y = fread(TSfid, 1, 'uint8' ) ; %Starting year
fread(TSfid, 1, 'uint8' ) ; % skip the Starting weekday
c = fread(TSfid, 1, 'uint8' ) ; %Starting centry(-1)
bnum = fread ( TSfid, 1, 'uint16','ieee-le'); % box series number
Nscan = fread ( TSfid, 1, 'uint16'); % Number of scans in a data block
Nch = fread ( TSfid, 1, 'uint8'); % Number of channels in a record
% fread(TSfid,4,'uint32',0,'l'); % skip some (unknown) info...
fseek(TSfid,5,'cof'); % skip to sampling frequency
Fs = fread(TSfid, 1, 'uint16' ,0,'l'); % Sampling frequency
fseek(TSfid,12,'cof');% skip some (unknown) head info...
disp(['       sampling frequency is ' num2str(Fs) ' Hz'])
disp(['       number of records is ' num2str(Nscan) ' in each data block'])
% now go to the end of the file...
fseek(TSfid,0,'eof');
Nblock=round(ftell(TSfid)/(Nscan*Nch*3+32)); % number of data blocks in the file
Ts=zeros(Nch,Nscan*Nblock);
disp(['       total ' num2str(Nblock) ' block(s) found in current file'])
fseek(TSfid,0,'bof'); % now go to the beginning of the file...
% multiply those together
Egain = Egain * Egainc;
if strfind(custom.method,'AMT')
    Hgain = Hgain * Hgainc*1000;
else
    Hgain = Hgain * Hgainc;
end

for iblock=1:Nblock
    % now start loading the data 
    % here=ftell(TSfid); % for debug
    fseek(TSfid,32,'cof'); %skip the file tag
    data=fread(TSfid,[Nch*3,Nscan],'uint8','ieee-le'); % 3*5  = 15 Byte per record
    if isempty(data)
        disp('       finish reading time series...')
        disp('       no data read in current block...')
        fclose(TSfid);
        break
    end
    if Nch==3
        Ts(csetup(1),(iblock-1)*Nscan+1:iblock*Nscan)=getsign24(data(3,:)*p16+data(2,:)*p8+data(1,:))*DAC/Egain/ELN(1)*1000; % Ex1 
        Ts(csetup(2),(iblock-1)*Nscan+1:iblock*Nscan)=getsign24(data(6,:)*p16+data(5,:)*p8+data(4,:))*DAC/Egain/ELN(2)*1000; % Ex2
        Ts(csetup(3),(iblock-1)*Nscan+1:iblock*Nscan)=getsign24(data(9,:)*p16+data(8,:)*p8+data(7,:))*DAC/Egain/ELN(3)*1000; % Ex3
    elseif Nch==4
        Ts(csetup(1),(iblock-1)*Nscan+1:iblock*Nscan)=getsign24(data(3,:)*p16+data(2,:)*p8+data(1,:))*DAC/Egain/ELN(1)*1000; % Ex1 
        Ts(csetup(2),(iblock-1)*Nscan+1:iblock*Nscan)=getsign24(data(6,:)*p16+data(5,:)*p8+data(4,:))*DAC/Egain/ELN(2)*1000; % Ex2
        Ts(csetup(3),(iblock-1)*Nscan+1:iblock*Nscan)=getsign24(data(9,:)*p16+data(8,:)*p8+data(7,:))*DAC/Egain/ELN(3)*1000; % Ex3
        Ts(csetup(4),(iblock-1)*Nscan+1:iblock*Nscan)=getsign24(data(15,:)*p16+data(14,:)*p8+data(13,:))*DAC/Hgain; % Hy
    elseif Nch==5
        Ts(csetup(1),(iblock-1)*Nscan+1:iblock*Nscan)=getsign24(data(3,:)*p16+data(2,:)*p8+data(1,:))*DAC/Egain/ELN(1)*1000; % mV/km
        Ts(csetup(2),(iblock-1)*Nscan+1:iblock*Nscan)=getsign24(data(6,:)*p16+data(5,:)*p8+data(4,:))*DAC/Egain/ELN(2)*1000; % mV/km
        Ts(csetup(3),(iblock-1)*Nscan+1:iblock*Nscan)=getsign24(data(9,:)*p16+data(8,:)*p8+data(7,:))*DAC/Hgain; % Hx nT
        Ts(csetup(4),(iblock-1)*Nscan+1:iblock*Nscan)=getsign24(data(12,:)*p16+data(11,:)*p8+data(10,:))*DAC/Hgain; % Hy nT
        Ts(csetup(5),(iblock-1)*Nscan+1:iblock*Nscan)=getsign24(data(15,:)*p16+data(14,:)*p8+data(13,:))*DAC/Hgain; % Hz nT
    elseif Nch==6
        Ts(csetup(1),(iblock-1)*Nscan+1:iblock*Nscan)=getsign24(data(3,:)*p16+data(2,:)*p8+data(1,:))*DAC/Egain/ELN(1)*1000; % Ex mV/km
        Ts(csetup(2),(iblock-1)*Nscan+1:iblock*Nscan)=getsign24(data(6,:)*p16+data(5,:)*p8+data(4,:))*DAC/Egain/ELN(2)*1000; % Ey mV/km
        Ts(csetup(3),(iblock-1)*Nscan+1:iblock*Nscan)=getsign24(data(9,:)*p16+data(8,:)*p8+data(7,:))*DAC/Egain/ELN(3)*1000; % Ez mV/km
        Ts(csetup(4),(iblock-1)*Nscan+1:iblock*Nscan)=getsign24(data(12,:)*p16+data(11,:)*p8+data(10,:))*DAC/Hgain; % Hx nT
        Ts(csetup(5),(iblock-1)*Nscan+1:iblock*Nscan)=getsign24(data(15,:)*p16+data(14,:)*p8+data(13,:))*DAC/Hgain; % Hy nT
        Ts(csetup(6),(iblock-1)*Nscan+1:iblock*Nscan)=getsign24(data(18,:)*p16+data(17,:)*p8+data(16,:))*DAC/Hgain; % Hz nT
    end    
end
% now we consider trimming the time series to remove those we don't need
tskip1 = custom.tskip1;
tskip2 = custom.tskip2;
if (tskip1 > 0) && (tskip1 < 100)
    scan1 = ceil(Nblock*tskip1/100) + 1;
else
    scan1 = 1;
end
if (tskip2 > 0) && (tskip2 < 100)
    scan2 = Nblock - ceil(Nblock*tskip2/100);
else
    scan2 = Nblock;
end
if scan2 - scan1 > Nblock * 0.32
    Ts = Ts(:,scan1*Nscan:scan2*Nscan);
end
Tinfo.bnum=bnum;
Tinfo.Fs=Fs;
Tinfo.Nch=Nch;
Tinfo.Nscan=Nscan;
Tinfo.Tstr=[(c*100)+y l d h m s];
Tinfo.Tlen=Nscan/Fs;
Tinfo.Nblock=Nblock;
return