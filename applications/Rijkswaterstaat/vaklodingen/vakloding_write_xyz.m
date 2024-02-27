function [xyz]=vakloding_write_xyz(vl_name)
%% read vakloding data for given name such as 'vaklodingenKB121_2524', 
% write .xyz file and return x, y and z values
%
% to find vl_name check 
% http://kml.deltares.nl/kml/rijkswaterstaat/vaklodingen_overview.kml
%
% Dano Roelvink, 2014

url = ['http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/',vl_name,'.nc']
x = nc_varget(url, 'x');
y = nc_varget(url, 'y');
time=nc_varget(url,'time');
[X,Y]=meshgrid(x,y);
Z = squeeze(nc_varget(url, 'z', [length(time)-1 0 0], [1 -1 -1]));
nx=size(X,1);
ny=size(X,2);
x=reshape(X,nx*ny,1);
y=reshape(Y,nx*ny,1);
z=reshape(Z,nx*ny,1);
xyz(:,1)=x(~isnan(z));
xyz(:,2)=y(~isnan(z));
xyz(:,3)=z(~isnan(z));
save([vl_name,'.xyz'],'xyz','-ascii');
date=datestr(datenum(1970,1,1)+time(end))
figure;scatter(xyz(:,1),xyz(:,2),5,xyz(:,3),'filled');
caxis([-20,5]);
axis equal;
colorbar
title(date)
