function boxcal=readBoxcal(fpath, fname, nc)
% readBoxcal reads an ascii instrument response file of the legacy Phoenix 
% format (MTU-5A) and output the "boxcal" frequency-response cell array
% fpath: path to the calibration file 
% fname: name of the calibration file (exluding extensions)
%
% boxcal: output cell array of the instrument response

% check the input arguments
if nargin < 3
    % 5 for MTU-5 
    nc = 5;
end
% start reading calibration files
if exist([fpath fname],'file')
    disp(['opening box calibration file: ',fname]);
else
    errordlg(['Box calibration ' fname ' not found','?']);
    return;
end
% set calibration length here (hard coded)
% just play safe - normally it should be of length 99
calength=150;
% allocate box cell array
boxcal=cell(nc,1);
for i=1:nc
    boxcal{i}.channel=i;
    boxcal{i}.freq=zeros(calength,1);
    boxcal{i}.mag=ones(calength,1);
    boxcal{i}.phs=zeros(calength,1);
end
% reading box cals
fid=fopen([fpath fname],'r');
for i=1:5 
    % skipping some information (as we can read them from the TBL file)
    fgetl(fid);
end
for j=1:length(boxcal{1}.freq)
    if ~feof(fid)
        line=fgetl(fid);
        line=strrep(line,',',' ');
        if nc==5
            temp=sscanf(line,'%f %f %f %f %f %f %f %f %f %f %f');
        else
            temp=sscanf(line,'%f %f %f %f %f %f %f %f %f');
        end
        for i=1:nc          
            boxcal{i}.freq(j)=temp(1);
            boxcal{i}.mag(j)=temp(2*i);
            boxcal{i}.phs(j)=temp(2*i+1);
        end           
    end
end
% remove the trailing zeros (if any)
nrec = find(boxcal{1}.freq==0,1,"first");
for i=1:nc
    boxcal{i}.freq(nrec:end)=[];
    boxcal{i}.mag(nrec:end)=[];
    boxcal{i}.phs(nrec:end)=[];
end
fclose(fid);
return