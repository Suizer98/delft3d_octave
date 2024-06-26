function ww3_write_obstructions_file(fname,x,y,sx,sy,scalingfactor)

nx=size(x,2);
ny=size(x,1);

sx=round(sx/scalingfactor);
sy=round(sy/scalingfactor);

nlines=floor(nx/11);
nremn=nx-nlines*11;

fid=fopen(fname,'wt');
for ii=1:size(x,1)
    s=squeeze(sx(ii,:));    
    if nlines>0
        fmt=[repmat('%8.0f',1,11) '\n'];
        fmt=repmat(fmt,1,nlines);
        fmt=[fmt repmat('%8.0f',1,nremn) '\n'];
    else
        fmt=[repmat('%8.0f',1,nremn) '\n'];
    end
    fprintf(fid,fmt,s);
end
for ii=1:size(x,1)
    s=squeeze(sy(ii,:));    
    if nlines>0
        fmt=[repmat('%8.0f',1,11) '\n'];
        fmt=repmat(fmt,1,nlines);
        fmt=[fmt repmat('%8.0f',1,nremn) '\n'];
    else
        fmt=[repmat('%8.0f',1,nremn) '\n'];
    end
    fprintf(fid,fmt,s);
end
fclose(fid);

