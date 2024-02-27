function delft3dfm_write_ext_file(filename,bnd)

% Boundaries in new ext
fid=fopen(filename,'wt');
for ip=1:length(bnd)
    fprintf(fid,'%s\n','[boundary]');
    fprintf(fid,'%s\n',['quantity       = ' bnd(ip).quantity]);
    fprintf(fid,'%s\n',['locationfile   = ' bnd(ip).locationfile]);
    fprintf(fid,'%s\n',['forcingfile    = ' bnd(ip).forcingfile]);
    fprintf(fid,'%s\n','');
end
fclose(fid);
