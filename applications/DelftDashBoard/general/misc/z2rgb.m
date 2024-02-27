function cdata=z2rgb(z,clmap,clim)

isn=isnan(z);

z=max(z,clim(1));
z=min(z,clim(2));

z(isn)=NaN;

v=clim(1):(clim(2)-clim(1))/(size(clmap,1)-1):clim(2);

r=interp1(v,clmap(:,1),z);
g=interp1(v,clmap(:,2),z);
b=interp1(v,clmap(:,3),z);

% Make NaN values white
r(isnan(z))=1;
g(isnan(z))=1;
b(isnan(z))=1;

cdata=[];
cdata(:,:,1)=r;
cdata(:,:,2)=g;
cdata(:,:,3)=b;

cdata=min(cdata,0.9999);
cdata=max(cdata,0.0001);
cdata=uint8(cdata*255);
