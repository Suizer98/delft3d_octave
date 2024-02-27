function argus2kmz(kmzfile,station,t,dr,xori,yori,wdt,hgt,rotation,csname,cstype)
% FUNCTION argus2kmz(station,t,dr,xori,yori,wdt,hgt,rotation,csname,cstype)
% Download merged Argus image and stores it in KMZ file
% station = e.g. jvanspeijk
% t       = time (datenum number)
% dr      = folder where kmz file will be stored
% xori    = x origin lower left corner of merged image (local coordinates)
% yori    = y origin lower left corner of merged image (local coordinates)
% wdt     = width of image (in metres)
% hgt     = height of image (in metres)
% rotation= rotation to be applied (counter-clockwise, decimal degrees)
% csname  = coordinate system name (e.g. Amersfoort / RD New)
% cstype  = coordinate system type (e.g. projected)

if ~strcmpi(dr(end),'filesep')
    dr=[dr filesep];
end

dtvec=datevec(t);
daynr=floor(t)-datenum(dtvec(1),1,1)+1;
nsecs=86400*(t-datenum(1970,1,1));

url=['http://argus-data.wldelft.nl/sites/' station '/' num2str(dtvec(1)) '/cx/' num2str(daynr) '_' datestr(t,'mmm.dd') '/' num2str(nsecs) '.' datestr(t,'ddd.mmm.dd_HH_MM_SS') '.GMT.' num2str(dtvec(1)) '.jvspeijk.cx.plan.jpg'];


fname=[dr 'argus_temp.jpg'];

urlwrite(url,fname);
jpgcol=imread(fname);

delete(fname);

r=double(squeeze(jpgcol(:,:,1)));
g=double(squeeze(jpgcol(:,:,2)));
b=double(squeeze(jpgcol(:,:,3)));

xx=1:size(jpgcol,2);
yy=1:size(jpgcol,1);
yy=fliplr(yy);

% Compute pixel size
dx=wdt/size(jpgcol,2);
dy=hgt/size(jpgcol,1);

% Multiply by pixel size
xx=xx*dx;
yy=yy*dy;

[xg0,yg0]=meshgrid(xx,yy);

% Rotate image
rot=pi*rotation/180;
xg =  xg0 .*  cos(rot) + yg0 .* -sin(rot) + xori;
yg =  xg0 .*  sin(rot) + yg0 .* cos(rot) + yori;

% Convert grid to WGS 84
[xg,yg]=convertCoordinates(xg,yg,'CS1.name',csname,'CS1.type',cstype,'CS2.name','WGS 84','CS2.type','geographic');

% New grid
xmin=min(min(xg));
xmax=max(max(xg));
ymin=min(min(yg));
ymax=max(max(yg));

dx=dx/50000;
dy=dy/50000;

xx=xmin:dx:xmax;
yy=ymin:dy:ymax;
[xg1,yg1]=meshgrid(xx,yy);

r=flipud(griddata(xg,yg,r,xg1,yg1));
g=flipud(griddata(xg,yg,g,xg1,yg1));
b=flipud(griddata(xg,yg,b,xg1,yg1));

alfa=zeros(size(r))+1;
alfa(isnan(r))=0;

cr(:,:,1)=r;
cr(:,:,2)=g;
cr(:,:,3)=b;
cr=uint8(cr);

pngfile=['argus_' station '_' datestr(t,'yyyymmddHHMMSS') '.png'];
imwrite(cr,[dr filesep pngfile],'png','alpha',alfa);
flist{1}=pngfile;

writeMapKMZ('filename',kmzfile,'xlim',[xx(1) xx(end)],'ylim',[yy(1) yy(end)],'dir',dr,'filelist',flist,'deletefiles',1);

