function inp=sfincs_read_input(fname,inp)

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

inp.tref=datenum(inp.tref,'yyyymmdd HHMMSS');
inp.tstart=datenum(inp.tstart,'yyyymmdd HHMMSS');
inp.tstop=datenum(inp.tstop,'yyyymmdd HHMMSS');

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
