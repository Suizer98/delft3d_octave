function sfincs_make_geomask_file(geomaskfile,x0,y0,dx,dy,mmax,nmax,rotation,indexfile,maskfile,dlon,cs)

% xml=xml2struct([folder filesep xmlfile],'structuretype','supershort');
% 
% x0=str2double(xml.x0);
% y0=str2double(xml.y0);
% dx=str2double(xml.dx);
% dy=str2double(xml.dy);
% rotation=str2double(xml.rotation);
% mmax=floor(str2double(xml.box.lenx)/str2double(xml.box.dx));
% nmax=floor(str2double(xml.box.leny)/str2double(xml.box.dy));

% Load binary index file
fid=fopen(indexfile,'r');
np=fread(fid,1,'integer*4');
indices=fread(fid,np,'integer*4');
fclose(fid);

% Load binary mask file
fid=fopen(maskfile,'r');
mask=fread(fid,np,'integer*1');
fclose(fid);

% cs.name=xml.csname;
% cs.type=xml.cstype;

dlat=dlon;

[xll,yll,nrows,ncols,indgeo,indmdl]=determine_indices_for_geographic_grid(mmax,nmax,x0,y0,dx,dy,rotation,indices,mask,cs,dlon,dlat);

% Save geo grid and mask file
fid=fopen(geomaskfile,'w');
fwrite(fid,ncols,'int32');
fwrite(fid,nrows,'int32');
fwrite(fid,xll,'double');
fwrite(fid,yll,'double');
fwrite(fid,dlon,'double');
fwrite(fid,length(indgeo),'int32');
%fwrite(fid,length(indmdl),'int32');
fwrite(fid,indgeo,'int32');
fwrite(fid,indmdl,'int32');
fclose(fid);

function [lonmin,latmin,nrows,ncols,indgeo,indmdl]=determine_indices_for_geographic_grid(mmaxin,nmaxin,x0in,y0in,dxin,dyin,rotin,indices,mskv,cs,dlon,dlat)

%% Determine projected coordinates of SFINCS output
xx=0:dxin:(mmaxin-1)*dxin;
yy=0:dyin:(nmaxin-1)*dyin;
[xg,yg]=meshgrid(xx,yy);

% Rotate and translate
rot=rotin*pi/180;
x=x0in+cos(rot)*xg-sin(rot)*yg;
y=y0in+sin(rot)*xg+cos(rot)*yg;

xmin=min(min(x));
xmax=max(max(x));
ymin=min(min(y));
ymax=max(max(y));

[lonmin,latmin]=convertCoordinates(xmin,ymin,'persistent','CS1.name',cs.name,'CS1.type',cs.type,'CS2.name','WGS 84','CS2.type','geographic');
[lonmax,latmax]=convertCoordinates(xmax,ymax,'persistent','CS1.name',cs.name,'CS1.type',cs.type,'CS2.name','WGS 84','CS2.type','geographic');

% Add buffer
dln=lonmax-lonmin;
dlt=latmax-latmin;
lonmin=lonmin-0.05*dln;
lonmax=lonmax+0.05*dln;
latmin=latmin-0.05*dlt;
latmax=latmax+0.05*dlt;

% Round up/down
lonmin=rounddown(lonmin,dlon);
lonmax=roundup(lonmax,dlon);
latmin=rounddown(latmin,dlat);
latmax=roundup(latmax,dlat);

% Vectors for lon and lat
lon=lonmin:dlon:lonmax;
lat=latmin:dlat:latmax;
nrows=length(lat);
ncols=length(lon);

% lon-lat grid
[lon1,lat1]=meshgrid(lon,lat);
% lon-lat grid in coordinate system of original data
[xout,yout]=convertCoordinates(lon1,lat1,'persistent','CS1.name','WGS 84','CS1.type','geographic','CS2.name',cs.name,'CS2.type',cs.type);

% Translate to (0,0)
xout=xout-x0in;
yout=yout-y0in;
% And now the rotated coordinate system
x2=cos(-rot)*xout-sin(-rot)*yout;
y2=sin(-rot)*xout+cos(-rot)*yout;

% Now determine model grid indices of nearest point
ix=round(x2/dxin);
iy=round(y2/dyin);

ix(ix<1)=0;
iy(iy<1)=0;
ix(ix>mmaxin)=0;
iy(iy>nmaxin)=0;
ix(ix==0)=NaN;
iy(iy==0)=NaN;

indmdl=sub2ind(size(xg),iy,ix);
[mg,ng]=meshgrid(1:ncols,1:nrows);
indgeo=sub2ind(size(x2),ng,mg);
indmdl=reshape(indmdl,[nrows*ncols 1]);
indgeo=reshape(indgeo,[nrows*ncols 1]);
indgeo(isnan(indmdl))=NaN;
indmdl=indmdl(~isnan(indmdl));
indgeo=indgeo(~isnan(indgeo));

% Create mask from indices
msk=zeros(size(xg));
 msk(indices)=mskv;

% Check mask of model grid
masker=msk(indmdl);
indmdl(masker==0)=NaN;
indgeo(isnan(indmdl))=NaN;
indmdl=indmdl(~isnan(indmdl));
indgeo=indgeo(~isnan(indgeo));


