function Volume = getErosionVolumeSSL(x1,z1,x2,z2,wl)

if size(x1,1)<size(x1,2)
    x1 = x1';
end
if size(x2,1)<size(x2,2)
    x2 = x2';
end
if size(z1,1)<size(z1,2)
    z1 = z1';
end
if size(z2,1)<size(z2,2)
    z2 = z2';
end

xgrid = unique([x1; x2]);
z1new = interp1(x1,max(z1,wl),xgrid);
z2new = interp1(x2,max(z2,wl),xgrid);

xdiffs = diff(xgrid);
mz1 = mean([z1new(1:end-1),z1new(2:end)],2);
mz2 = mean([z2new(1:end-1),z2new(2:end)],2);

ids = ~isnan(mz1) & ~isnan(mz2);
Volume = sum(xdiffs(ids).*(mz1(ids)-mz2(ids)));
