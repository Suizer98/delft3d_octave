function [x,y]=EHY_mn2xy(m,n,grdFile)
% [x,y]=EHY_mn2xy(m,n,grdFile)
%
% Find the x,y-location(s) of your m,n-location(s) in a structured
% Delft3D/SIMONA grid.
%
% Example1: [x,y]=EHY_mn2xy(20,30,'D:\Nederland.grd')
% Example2: [x,y]=EHY_mn2xy([20 40],[30 32],'D:\Nederland.grd')
%
% created by Julien Groenenboom, September 2017

tempGrdFile=[tempdir 'tmp.grd'];
copyfile(grdFile,tempGrdFile);
grd=wlgrid('read',tempGrdFile);
delete(tempGrdFile);

grd.Xcen=corner2centernan(grd.X);
grd.Ycen=corner2centernan(grd.Y);

if length(m)~=length(n); error('m and n should have the same length'); end

for imn=1:length(m)
    x(imn,1)=grd.Xcen(m(imn)-1,n(imn)-1);
    y(imn,1)=grd.Ycen(m(imn)-1,n(imn)-1);
end

