function ww3_write_bottom_depth_file(fname,x,y,z,scalingfactor)

nx=size(x,2);
ny=size(x,1);

z=round(z/scalingfactor);

nlines=floor(nx/11);
nremn=nx-nlines*11;

fid=fopen(fname,'wt');
for ii=1:size(x,1)
    zz=squeeze(z(ii,:));    
    if nlines>0
        fmt=[repmat('%8.0f',1,11) '\n'];
        fmt=repmat(fmt,1,nlines);
        fmt=[fmt repmat('%8.0f',1,nremn) '\n'];
    else
        fmt=[repmat('%8.0f',1,nremn) '\n'];
    end
    fprintf(fid,fmt,zz);
end
fclose(fid);

