function [xx,yy,cr]=rotateGeoImage(imgfile,geofile,xori,yori,wdt1,wdt2,hgt1,hgt2,rot)
% Extracts part of georeferenced image and rotates it around user-defined origin

rot=rot*pi/180;

% Read image file
frm=imgfile(end-2:end);
switch lower(frm),
    case{'jpg','epg','bmp'}
        jpgcol=imread(imgfile);
    case{'png'}
        [jpgcol,map,alpha]=imread(imgfile,'BackgroundColor','none');
    case{'gif'}
        jpgcol=imread(imgfile,1);
end
sz=size(jpgcol);

% Read reference file
r=load(geofile);
dx=r(1);
roty=r(2);
rotx=r(3);
dy=r(4);
x0=r(5);
y0=r(6);

a=dx;
d=roty;
b=rotx;
e=dy;
c=x0;
f=y0;

if rotx~=0 || roty~=0
    [x0,y0]=meshgrid(1:sz(2),1:sz(1));
    x=a*x0+b*y0+c;
    y=d*x0+e*y0+f;
else
    x=x0:dx:x0+(sz(2)-1)*dx;
    y=y0:dy:y0+(sz(1)-1)*dy;
end

nx1=round(wdt1/dx);
nx2=round(wdt2/dx);
ny1=round(hgt1/dx);
ny2=round(hgt2/dx);

xx=-nx1*dx:dx:nx2*dx;
yy=-ny1*dx:dx:ny2*dx;
[xg0,yg0]=meshgrid(xx,yy);

xg =  xg0 .*  cos(rot) + yg0 .* -sin(rot) + xori;
yg =  xg0 .*  sin(rot) + yg0 .* cos(rot) + yori;

xg=flipud(xg);
yg=flipud(yg);
yy=fliplr(yy);

cr(:,:,1)=interp2(x,y,double(squeeze(jpgcol(:,:,1))),xg,yg);
cr(:,:,2)=interp2(x,y,double(squeeze(jpgcol(:,:,2))),xg,yg);
cr(:,:,3)=interp2(x,y,double(squeeze(jpgcol(:,:,3))),xg,yg);

cr=uint8(cr);
