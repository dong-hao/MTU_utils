function [ts, tag]=readTSN(fpath,fname)
% readTSN reads a (binary) TS file of the legacy Pheonix MTU-5A instrument 
% (TS2, TS3, TS4, TS5) and the even older V5-2000 system (TSL, TSH), and 
% output the "ts" array and "tinfo" metadata structure. 
% ======================================================================= %
% fpath: path to the TS file 
% fname: name of the TS file (including extensions)
% ts:    output array of the TS data
% tag:   output tag struct of the TSn metadata
% ======================================================================= %
% defination of the TS tag (or what I guessed after reading the user manual
% and fiddling with their files) 
% 0-7   UTC time of first scan in the record. 
% 8-9   instrument serial number (16-bit integer)
% 10-11 number of scans in the record (16-bit integer)
% 12    number of channels per scan
% 13    tag length (TSn) or tag length code (TSH, TSL)
% 14    status code
% 15    bit-wise saturation flags (please note that the older TSH/L tag 
%       ends here )
% 16    reserved for future indication of different tag and/or sample
%       formats
% 17    sample length in bytes
% 18-19 sample rate (in units defined by byte 20)
% 20    units of sample rate
% 21    clock status
% 22-25 clock error in seconds
% 26-32 reserved; must be 0
% ======================================================================= %
% notes on the TS format of TSn files:
% The binary TS file consists of several data blocks, each contains a data 
% tag and a number of records in it.
% Each time record consists of three bytes (24 bit), let's name them byte1,
% byte2, and byte3:
% the ts record (int) should be (+/-) (byte3*65536 + byte2*256 + byte1)
%
% Hao
% 2012.07.04
% Beijing
% ======================================================================= %
%  	try opening the ts data file 
TSfid=fopen([fpath fname ],'r','ieee-le');
disp(['# opening file: ' fname]);
% some constants used for format conversion
p16=2^16;
p8=2^8;
% scan through time series
% firstly reading a 32 Byte header info
s = fread(TSfid, 1, 'uint8' ) ; %Starting second
if isempty(s)
    ts=[];
    tag=[];
    return
end
m = fread(TSfid, 1, 'uint8' ) ; %Starting minute
h = fread(TSfid, 1, 'uint8' ) ; %Starting hour
d = fread(TSfid, 1, 'uint8' ) ; %Starting day
l = fread(TSfid, 1, 'uint8' ) ; %Starting month
y = fread(TSfid, 1, 'uint8' ) ; %Starting year
fread(TSfid, 1, 'uint8' ) ;     % skip the Starting weekday
c = fread(TSfid, 1, 'uint8' ) ; %Starting centry(-1)
bnum = fread ( TSfid, 1, 'uint16'); % box series number
Nscan = fread ( TSfid, 1, 'uint16'); % Number of scans in a data block
Nch = fread ( TSfid, 1, 'uint8'); % Number of channels in a record
Taglen = fread ( TSfid, 1, 'uint8'); % length of the tag
if Taglen~=32
    tstype='V5-2000';
else
    tstype='MTU-5';
end
disp(['# TS type is: ', tstype]);
if Taglen==32
    fseek(TSfid,4,'cof'); % skip to sampling frequency
    Fs = fread(TSfid, 1, 'uint16' ,0,'l'); % Sampling frequency
    fseek(TSfid,12,'cof');% skip some (unknown) head info...
    disp(['# sampling frequency is ' num2str(Fs) ' Hz'])
    disp(['# number of records is ' num2str(Nscan) ' in each data block'])
end
% now go to the end of the file...
fseek(TSfid,0,'eof');
Nblock=round(ftell(TSfid)/(Nscan*Nch*3+32)); % number of data blocks in the file
% preallocate some memory for ts
ts=zeros(Nch,Nscan*Nblock);
disp(['# total ' num2str(Nblock) ' block(s) found in current file'])
fseek(TSfid,0,'bof'); % now go back to the beginning of the file...
for iblock=1:Nblock
    % now start loading the data 
    % here=ftell(TSfid); % for debug
    fseek(TSfid,32,'cof'); %skip the file tag
    data=fread(TSfid,[Nch*3,Nscan],'uint8'); % 3*5  = 15 Byte per record
    if isempty(data)
        disp('# warning: no data read in current block...')
        break
    end
    if Nch==3
        ts(1,(iblock-1)*Nscan+1:iblock*Nscan)=getsign24(data(3,:)*p16+data(2,:)*p8+data(1,:)); % Ex1 
        ts(2,(iblock-1)*Nscan+1:iblock*Nscan)=getsign24(data(6,:)*p16+data(5,:)*p8+data(4,:)); % Ex2
        ts(3,(iblock-1)*Nscan+1:iblock*Nscan)=getsign24(data(9,:)*p16+data(8,:)*p8+data(7,:)); % Ex3
    elseif Nch==4
        ts(1,(iblock-1)*Nscan+1:iblock*Nscan)=getsign24(data(3,:)*p16+data(2,:)*p8+data(1,:)); % Ex1 
        ts(2,(iblock-1)*Nscan+1:iblock*Nscan)=getsign24(data(6,:)*p16+data(5,:)*p8+data(4,:)); % Ex2
        ts(3,(iblock-1)*Nscan+1:iblock*Nscan)=getsign24(data(9,:)*p16+data(8,:)*p8+data(7,:)); % Ex3
        ts(4,(iblock-1)*Nscan+1:iblock*Nscan)=getsign24(data(15,:)*p16+data(14,:)*p8+data(13,:)); % Hy
    elseif Nch==5
        ts(1,(iblock-1)*Nscan+1:iblock*Nscan)=getsign24(data(3,:)*p16+data(2,:)*p8+data(1,:)); % Ex
        ts(2,(iblock-1)*Nscan+1:iblock*Nscan)=getsign24(data(6,:)*p16+data(5,:)*p8+data(4,:)); % Ey
        ts(3,(iblock-1)*Nscan+1:iblock*Nscan)=getsign24(data(9,:)*p16+data(8,:)*p8+data(7,:)); % Hx 
        ts(4,(iblock-1)*Nscan+1:iblock*Nscan)=getsign24(data(12,:)*p16+data(11,:)*p8+data(10,:)); % Hy 
        ts(5,(iblock-1)*Nscan+1:iblock*Nscan)=getsign24(data(15,:)*p16+data(14,:)*p8+data(13,:)); % Hz 
    elseif Nch==6
        ts(1,(iblock-1)*Nscan+1:iblock*Nscan)=getsign24(data(3,:)*p16+data(2,:)*p8+data(1,:)); % Ex 
        ts(2,(iblock-1)*Nscan+1:iblock*Nscan)=getsign24(data(6,:)*p16+data(5,:)*p8+data(4,:)); % Ey 
        ts(3,(iblock-1)*Nscan+1:iblock*Nscan)=getsign24(data(9,:)*p16+data(8,:)*p8+data(7,:)); % Ez 
        ts(4,(iblock-1)*Nscan+1:iblock*Nscan)=getsign24(data(12,:)*p16+data(11,:)*p8+data(10,:)); % Hx 
        ts(5,(iblock-1)*Nscan+1:iblock*Nscan)=getsign24(data(15,:)*p16+data(14,:)*p8+data(13,:)); % Hy 
        ts(6,(iblock-1)*Nscan+1:iblock*Nscan)=getsign24(data(18,:)*p16+data(17,:)*p8+data(16,:)); % Hz 
    end    
end
fclose(TSfid);
disp('# finish reading time series...')
tag.boxnum=bnum;
tag.tstype=tstype;
tag.Fs=Fs;
tag.Nch=Nch;
tag.Nscan=Nscan;
tag.Tstr=[(c*100)+y l d h m s];
tag.Tlen=Nscan/Fs;
tag.Nblock=Nblock;
return

function x=getsign24(x)
% a simple function to calculate the sign for a 24 bit number
% I should have made it in-line
x(x>2^23-1)=x(x>2^23-1)-2^24;
return