function sfincs_write_input(fname,inp)

keywords=fieldnames(inp);

inp.tref=datestr(inp.tref,'yyyymmdd HHMMSS');
inp.tstart=datestr(inp.tstart,'yyyymmdd HHMMSS');
inp.tstop=datestr(inp.tstop,'yyyymmdd HHMMSS');
inp.t0out=[];

fid=fopen(fname,'wt');

for ii=1:length(keywords)
    keyw=keywords{ii};
    val=inp.(keyw);
    if ~isempty(val)
        str1=[keyw repmat(' ',[1 15-length(keyw)]) '= '];
        if ischar(val)
            str2=deblank2(val);
        else
            str2=num2str(val);
        end
        fprintf(fid,'%s\n',[str1 str2]);
    end
end
fclose(fid);
