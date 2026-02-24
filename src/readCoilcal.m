function coilcal=readCoilcal(cdir, fname)
% readBoxcal reads an ascii coil response file of the legacy Phoenix 
% format (MTU-5A) and output the "coilcal" frequency-response structure
% fpath: path to the calibration file 
% fname: name of the calibration file (including extensions)
% 
% coilcal: output struct of the coil response

% start finding calibration files
if exist([cdir fname],'file')
    disp(['opening coil calibration file: ',fname]);
    coilcal.name= fname;
else
    errordlg(['Coil calibration ' fname 'not found','?']);
    return;
end
% set calibration length here (hard coded)
% just play safe - normally it should be of length 99
calength=150;
coilcal.freq=zeros(calength,1);
coilcal.mag=ones(calength,1);
coilcal.phs=zeros(calength,1);
% reading coil cals
fid=fopen([cdir coilcal.name],'r');
for i=1:5 
    % skipping some information (as we can read them from the TBL file)
    fgetl(fid);
end
for j=1:length(coilcal.freq)
    if ~feof(fid)
        line=fgetl(fid);
        line=strrep(line,',',' ');
        temp=sscanf(line,'%f %f %f');
        coilcal.freq(j)=temp(1); 
        coilcal.mag(j)=temp(2); 
        coilcal.phs(j)=temp(3);       
    end
end    
% remove the trailing zeros (if any)
nrec = find(coilcal.freq==0,1,"first");
coilcal.freq(nrec:end)=[];
coilcal.mag(nrec:end)=[];
coilcal.phs(nrec:end)=[];
fclose(fid);
return