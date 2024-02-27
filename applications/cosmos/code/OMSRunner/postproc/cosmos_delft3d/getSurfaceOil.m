function data=getSurfaceOil(dr,runid,fld)


if ~exist([dr 'map-' runid '.dat'],'file')
   killAll;
else
if ~exist([dr 'com-' runid '.lga'],'file')
   killAll;
else

fid=qpfopen([dr 'map-' runid '.dat'],[dr 'com-' runid '.lga']);
times=qpread(fid,1,fld,'times');
end
end
for it=1:length(times)
    if it==1
        oil=qpread(fid,1,fld,'griddata',1);
        data.parameter='Oil';
        data.time(it,1)=times(1);
        data.X=squeeze(oil.X(:,:,1));
        data.Y=squeeze(oil.Y(:,:,1));
        data.Val(it,:,:)=squeeze(oil.Val(:,:,1));
    else
        oil=qpread(fid,1,fld,'data',it);
        data.time(it,1)=times(it);
        data.Val(it,:,:)=squeeze(oil.Val(:,:,1));
    end
end

maxval=max(max(max(data.Val)));
data.Val(data.Val<0.001*maxval)=NaN;
