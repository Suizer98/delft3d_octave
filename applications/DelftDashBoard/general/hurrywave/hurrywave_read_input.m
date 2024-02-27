function inp=hurrywave_read_input(fname,inp)

% Read input file
fid=fopen(fname,'r');
while 1
    str=fgetl(fid);
    if str==-1
        break
    end
    c=textscan(str,'%s','delimiter','=');
    c=c{1};
    keyw=deblank2(c{1});
    val=deblank2(c{2});
    if ~isnan(str2double(val))
        val=str2double(val);
    end
    inp.(keyw)=val;
end
fclose(fid);

if ischar(inp.tref)
    inp.tref=datenum(inp.tref,'yyyymmdd HHMMSS');
end
if ischar(inp.tstart)
    inp.tstart=datenum(inp.tstart,'yyyymmdd HHMMSS');
end
if ischar(inp.tstop)
    inp.tstop=datenum(inp.tstop,'yyyymmdd HHMMSS');
end

keywords=fieldnames(inp);

for ii=1:length(keywords)
    keyw=keywords{ii};
    switch lower(keyw)
        case{'cdwnd','cdval'}
            if ischar(inp.(keyw))
                inp.(keyw)=str2num(inp.(keyw));
            end
    end
end
