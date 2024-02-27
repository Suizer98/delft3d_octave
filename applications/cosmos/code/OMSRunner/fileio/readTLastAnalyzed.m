function tlastanalyzed=readTLastAnalyzed(meteodir)

fname=[meteodir 'tlastanalyzed.txt'];
if exist(fname,'file');
    fid=fopen(fname,'r');
    s=fgetl(fid);
    tlastanalyzed=datenum(s,'yyyymmdd HHMMSS');
else
    tlastanalyzed=datenum(2050,1,1);
end
