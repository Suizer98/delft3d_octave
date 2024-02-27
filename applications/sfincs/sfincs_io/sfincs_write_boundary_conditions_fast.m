function sfincs_write_boundary_conditions_fast(filename,t,v)
if isrow(t)
    t = t';
end

n = size(v,1);
if n ~= length(t)
    v = v';
end

m=size(v,2);
fmt=['%10.2f' repmat('%8.3f',[1 m]) '\n'];

fid=fopen(filename,'wt');
myvar = [t v]';
fprintf(fid,fmt,myvar);

fclose(fid);
end
