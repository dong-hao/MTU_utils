function info=readTBL(fpath,fname)
% readTBL reads a (binary) TBL table file of the legacy Phoenix format 
% (MTU-5A) and output the "info" metadata structure
% fpath: path to the tbl 
% frame: name of the tbl file (including extensions)
% info: output struct of the TBL metadata
% ======================================================================= %
% definition of the TBL tags (or what I guessed after reading the user 
% manual and fiddling with their files) 
% SITE: site name
% SNUM: serial number (of the box)
% FILE: file name recorded
% CMPY: company/institute of the survey
% SRVY: survey project name
% EXLN: Ex channel dipole length 
% EYLN: Ey channel dipole length 
% NREF: North reference (true, or magnetic north)
% LNGG: longitude in degree-minute format (DDD MM.MM)
% LATG: latitude in degree-minute format (DD MM.MM)
% ELEV: elevation (in metres)
% HXSN: Hx channel coil serial number
% HYSN: Hy channel coil serial number
% HZSN: Hz channel coil serial number
% STIM: starting time (UTC)
% ETIM: ending time (UTC)
% LFRQ: powerline frequency for filtering (can only be 50 or 60 Hz)
% HGN:  final H-channel gain 
% HGNC: H-channel gain control: HGN = PA * 2^HGNC (note: PA =
%       PreAmplifier gain)
% EGN:  final E-channel gain 
% EGNC: E-channel gain control: HGN = PA * 2^HGNC (note: PA =
%       PreAmplifier gain)
% HSMP: L3 and L4 time slot (in second), this means the instrument will
%       record L3NS seconds for L3 and L4NS seconds for L4, every HSMP
%       seconds. 
% L3NS: L3 sample time (in second)
% L4NS: L4 sample time (in second)
% SRL3: L3 sample rate
% SRL4: L4 sample rate
% SRL5: L5 sample rate
% HATT: H channel attenuation (1/4.3 for MTU-5A)
% HNOM: H channel normalization (mA/nT) 
% TCMB: Type of comb filter (probably used to suppress the harmonics of the
%       powerline noise. 
% TALS: Type of anti-aliasing filter 
% LPFR: Parameter of Low-pass/VLF filter. this is a quite complicated
%       part as the low-pass filter is simply an R-C circuit with a switch
%       to connect to different capacitors. To ensure enough bandwidth
%       (proportion to 1/RC), one should use smaller capacitors with larger
%       ground resistance. 
% ACDC: AC/DC coupling (DC = 0, AC = 1; MT should always be DC)
% FSCV: full scaling A-D converter voltage (in unit of V)
% ======================================================================= %
% note: 
% Phoenix Legacy TBL is a straight-forward parameter-value metadata file,
% stored in a bizarre format. The parameter tag and value are stored in a
% series of 25-byte data blocks, in mixed data type: the first 12 bytes are
% reserved for the tag name (first 4 bytes as char). The values are stored
% in the 13 bytes afterwards, in various formats (char, int, float, etc.).
% 
% So a good practice is to read in those blocks one by one and extract all 
% of them. However, not every thing is useful for the metadata, so I only 
% extract a few of them, for now. 
% 
% Hao
% 2012.07.04
% Beijing
% ======================================================================= %
% firstly open the file
fid=fopen([fpath fname ],'r','ieee-le');
% ========================= site basic info  ============================ %
findTblTag(fid,'SNUM',1);
fseek(fid,-13,0);
info.SNUM = fread(fid,1,'int');
ctemp = findTblTag(fid,'SITE',1);
info.SITE = char(ctemp(13:24));
ctemp = findTblTag(fid,'FILE',1);
info.FILE = char(ctemp(13:24));
ctemp = findTblTag(fid,'CMPY',1);
info.CMPY = char(ctemp(13:24));
ctemp = findTblTag(fid,'SRVY',1);
info.SRVY = char(ctemp(13:24));
ctemp = findTblTag(fid,'LATG',1);
info.LATG = char(ctemp(13:24));
ctemp = findTblTag(fid,'LNGG',1);
info.LONG = char(ctemp(13:24));
findTblTag(fid,'ELEV',1);
fseek(fid,-13,0);
info.ELEV = fread(fid,1,'int');
findTblTag(fid,'NREF',1);
fseek(fid,-13,0);
info.NREF = fread(fid,1,'int');
% ===================== starting and ending time  ======================= %
% output as a string
ctemp= findTblTag(fid,'STIM',1);
info.STIM = [num2str(ctemp(17)),'-',num2str(ctemp(16)),'-','20',...
    num2str(ctemp(18)),' ',num2str(ctemp(15)),':',num2str(ctemp(14)),...
    ':',num2str(ctemp(13))];
% output as a string
ctemp = findTblTag(fid,'ETIM',1);
info.ETIM = [num2str(ctemp(17)),'-',num2str(ctemp(16)),'-','20',...
    num2str(ctemp(18)),' ',num2str(ctemp(15)),':',num2str(ctemp(14)),...
    ':',num2str(ctemp(13))];
% ========================= E and H channels  =========================== %
findTblTag(fid,'EXLN',1);
fseek(fid,-13,0);
info.EXLN = fread(fid,1,'float64');
findTblTag(fid,'EYLN',1);
fseek(fid,-13,0);
info.EYLN = fread(fid,1,'float64');
% find_tbltag(fid,'EZLN',1);
% fseek(fid,-13,0);
% info.EZLN = fread(fid,1,'float64');
ctemp = findTblTag(fid,'HXSN',1);
info.HXSN = char(ctemp(13:24));
ctemp = findTblTag(fid,'HYSN',1);
info.HYSN = char(ctemp(13:24));
ctemp = findTblTag(fid,'HZSN',1);
info.HZSN = char(ctemp(13:24));
findTblTag(fid,'EAZM',1);
fseek(fid,-13,0);
info.EAZM = fread(fid,1,'float64');
findTblTag(fid,'HAZM',1);
fseek(fid,-13,0);
info.HAZM = fread(fid,1,'float64');
% =================== L3, L4 and L5 sample parameter ==================== %
findTblTag(fid,'HSMP',1);
fseek(fid,-13,'cof');
info.HSMP = fread(fid,1,'int');
findTblTag(fid,'L3NS',1);
fseek(fid,-13,'cof');
info.L3NS = fread(fid,1,'int');
findTblTag(fid,'L4NS',1);
fseek(fid,-13,'cof');
info.L4NS = fread(fid,1,'int');
findTblTag(fid,'SRL3',1);
fseek(fid,-13,'cof');
info.SRL3 = fread(fid,1,'int');
findTblTag(fid,'SRL4',1);
fseek(fid,-13,'cof');
info.SRL4 = fread(fid,1,'int');
findTblTag(fid,'SRL5',1);
fseek(fid,-13,'cof');
info.SRL5 = fread(fid,1,'int');
% ========================= gain and filtering ========================== %
ctemp = findTblTag(fid,'LFRQ',1);
info.LFRQ = ctemp(13:13);
findTblTag(fid,'EGNC',1);
fseek(fid,-13,0);
info.EGNC = fread(fid,1,'int');
findTblTag(fid,'HGNC',1);
fseek(fid,-13,0);
info.HGNC = fread(fid,1,'int');
findTblTag(fid,'EGN',2);
fseek(fid,-13,0);
info.EGN = fread(fid,1,'int');
findTblTag(fid,'HGN',2);
fseek(fid,-13,0);
info.HGN = fread(fid,1,'int');
findTblTag(fid,'HATT',1);
fseek(fid,-13,0);
info.HATT = fread(fid,1,'float64');
findTblTag(fid,'HNOM',1);
fseek(fid,-13,0);
info.HNOM = fread(fid,1,'float64');
findTblTag(fid,'TCMB',1);
fseek(fid,-13,0);
info.TCMB = fread(fid,1,'uint8');
findTblTag(fid,'TALS',1);
fseek(fid,-13,0);
info.TALS = fread(fid,1,'uint8');
findTblTag(fid,'LPFR',1);
fseek(fid,-13,0);
info.LPFR = fread(fid,1,'uint8');
findTblTag(fid,'ACDC',1);
fseek(fid,-13,0);
info.ACDC = fread(fid,1,'uint8');
findTblTag(fid,'FSCV',1);
fseek(fid,-13,0);
info.FSCV = fread(fid,1,'float64');
% ======================================================================= %
% now close the file
fclose(fid);
return 

function[ctemp,pos] = findTblTag(fid,tag,inum)
% findTblTag find the position of a certain tag at its "inum"th occurrence 
% in file - and returns the tag values, for the legacy Phoenix MTU-5A TBL 
% format
% 
% ======================================================================= %
% note:
% yes, it's a bit silly to search for the tag each time from the beginning
% it doesn't matter too much as the file is quite small
% Hao
% 2012.07.04
% Beijing
% ======================================================================= %
% firstly return to the beginning of the file
fseek(fid,0,-1);
% read a first tag group
ctemp = fread(fid,25,'uint8')';
n = 0;
% continue reading, until we got the "inum" occurance 
while (~contains(char(ctemp),tag) || n~=inum)
    % the size (tag + value) is always 25 bytes 
    ctemp = fread(fid,25,'uint8')';
    if (contains(char(ctemp),tag))
        n=n+1; 
    end
    if feof(fid) 
        pos=0; 
        disp(['Warning: tag not found: ', tag]);
        return
    end
end
pos = ftell(fid);
return