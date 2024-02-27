function sfincs_write_boundary_conditions(filename,t,v)

np=size(v,2);
fmt=['%10.1f' repmat('%8.3f',[1 np]) '\n'];

fid=fopen(filename,'wt');
for it=1:length(t)
    val=[t(it) v(it,:)];
    fprintf(fid,fmt,val);
end
fclose(fid);
