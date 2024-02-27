function sfincs_make_superoverlay(name,hmaxfile,geomskfile,colorbarlabel,colorlimits,zmin)

kmlfile=[name '.kml'];

[x,y,z]=sfincs_read_hmaxgeo_bin(geomskfile,hmaxfile);
z(z<zmin)=NaN;

xl(1)=floor(min(x));
xl(2)=ceil(max(x));
yl(1)=floor(min(y));
yl(2)=ceil(max(y));
dx=x(2)-x(1);
dy=y(2)-y(1);

folder=['TMP_', name '_kmz\'];

xmin=xl(1);
xmax0=xl(2);
ymin=yl(1);
ymax0=yl(2);

npx0=round((xmax0-xmin)/dx)+1;
npy0=round((ymax0-ymin)/dy)+1;

npx=roundup(npx0,256);
npy=roundup(npy0,256);

ii=0:20;
tilesizes=256*2.^ii;
npmax=max(npx,npy);
ii=find(tilesizes>=npmax,1,'first');
npmax=tilesizes(ii);

% ntx=npmax/256;
% nty=npmax/256;

s=sparse(npmax,npmax);

%% Now put data in sparse matrix
% Find indices in sparse matrix
i1=round((x(1)-xmin)/dx+1);
i2=round((x(end)-xmin)/dx+1);
j1=round((y(1)-ymin)/dy+1);
j2=round((y(end)-ymin)/dy+1);

% Take maximum
d0=full(s(j1:j2,i1:i2));
z=max(z,d0);

s(j1:j2,i1:i2)=z;

superoverlay(kmlfile,s,xmin,ymin,dx,dy,'name',name,'colorlimits',colorlimits,'directory',folder,'transparency',0.5,'colorbarlabel',colorbarlabel,'kmz');
