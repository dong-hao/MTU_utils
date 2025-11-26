function info=readTBL(pname,tblname)
% read (binary) TBL table file and output info infomation structure
fid=fopen([pname tblname ],'r','ieee-le');
ctemp = find_tbltag(fid,'LFRQ',1);
lfrq = ctemp(13:13);
find_tbltag(fid,'L3NS',1);
fseek(fid,-13,'cof');
l3ns= fread(fid,1,'int');
find_tbltag(fid,'L4NS',1);
fseek(fid,-13,'cof');
l4ns= fread(fid,1,'int');
ctemp= find_tbltag(fid,'STIM',1);
stim = datenum([num2str(ctemp(17)),'-',num2str(ctemp(16)),'-','20',...
    num2str(ctemp(18)),' ',num2str(ctemp(15)),':',num2str(ctemp(14)),':',num2str(ctemp(13))]);
ctemp = find_tbltag(fid,'ETIM',1);
etim = datenum([num2str(ctemp(17)),'-',num2str(ctemp(16)),'-','20',...
    num2str(ctemp(18)),' ',num2str(ctemp(15)),':',num2str(ctemp(14)),':',num2str(ctemp(13))]);
find_tbltag(fid,'HSMP',1);
fseek(fid,-13,0);
hsmp = fread(fid,1,'int');
find_tbltag(fid,'EXLN',1);
fseek(fid,-13,0);
exln = fread(fid,1,'float64');
find_tbltag(fid,'EYLN',1);
fseek(fid,-13,0);
eyln = fread(fid,1,'float64');
% find_tbltag(fid,'EZLN',1);
% fseek(fid,-13,0);
ezln = fread(fid,1,'float32');
find_tbltag(fid,'EGNC',1);
fseek(fid,-13,0);
egnc = fread(fid,1,'int');
find_tbltag(fid,'HGNC',1);
fseek(fid,-13,0);
hgnc = fread(fid,1,'int');
find_tbltag(fid,'EGN',2);
fseek(fid,-13,0);
egn = fread(fid,1,'int');
find_tbltag(fid,'HGN',2);
fseek(fid,-13,0);
hgn = fread(fid,1,'int');
find_tbltag(fid,'SNUM',1);
fseek(fid,-13,0);
snum = fread(fid,1,'int');
ctemp = find_tbltag(fid,'SITE',1);
site = char(ctemp(13:16)');
ctemp = find_tbltag(fid,'FILE',1);
file = char(ctemp(13:20)');
find_tbltag(fid,'EAZM',1);
fseek(fid,-13,0);
eazm = fread(fid,1,'float');
find_tbltag(fid,'HAZM',1);
fseek(fid,-13,0);
hazm = fread(fid,1,'float');
ctemp = find_tbltag(fid,'HXSN',1);
hxsn = char(ctemp(13:20)');
ctemp = find_tbltag(fid,'HYSN',1);
hysn = char(ctemp(13:20)');
ctemp = find_tbltag(fid,'HZSN',1);
hzsn = char(ctemp(13:20)');
find_tbltag(fid,'ELEV',1);
fseek(fid,-13,0);
elev = fread(fid,1,'int');
ctemp = find_tbltag(fid,'LATG',1);
latg = char(ctemp(13:24)');
ctemp = find_tbltag(fid,'LNGG',1);
lngg = char(ctemp(13:24)');
fclose(fid);

info.SNUM=snum;
info.LAT=latg;
info.LON=lngg;
info.ELEV=elev;
info.STIM=stim;
info.ETIM=etim;
info.EXLN=exln;
info.EYLN=eyln;
info.EZLN=ezln;
info.EAZM=eazm;
info.HAZM=hazm;
info.HXSN=deblank(hxsn);
info.HYSN=deblank(hysn);
info.HZSN=deblank(hzsn);
info.EGNC=egnc;
info.EGN=egn;
info.HGNC=hgnc;
info.HGN=hgn;
info.L3NS=l3ns;
info.L4NS=l4ns;
info.LFRQ=lfrq;
info.HSMP=hsmp;
info.SITE=site;
info.FILE=file;
return 

function[ctemp,pos] = find_tbltag(fid,tag,inum)
  % positions (pos) tbl file (fid) to certain tag (tag, ctemp)
  % at its inum' occurrence in file.
  fseek(fid,0,-1);
  ctemp = fread(fid,25,'uint8');
  n = 0;
  while (~contains(char(ctemp'),tag) || n~=inum)
      ctemp = fread(fid,25,'uint8');
      if ( contains(char(ctemp'),tag))
          n=n+1; 
      end
      if feof(fid) 
          pos=0; 
          disp(['Warning: not found: ',tag]);
          return
      end
  end
  pos = ftell(fid);
  return