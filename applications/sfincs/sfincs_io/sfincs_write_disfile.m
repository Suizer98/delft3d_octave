function sfincs_write_disfile(filename,source)

np=length(source.x);
val=[];
t=source(1).time;

for ip=1:np
    val=[val source(ip).q];
end

fmt=['%10.1f' repmat('%8.2f',[1 np]) '\n'];

fid=fopen(filename,'wt');
for it=1:length(t)
    val=[t(it) v(it,:)];
    fprintf(fid,fmt,val);
end
fclose(fid);
