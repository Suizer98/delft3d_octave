%========================================================================
% Get bathymetry grid data from the specified 'grid_xxx' file. 
%
% USAGE:
% [lon,lat,z]=get_grid(Model);
% 
% PARAMETERS
% Input:
% Model - control file name for a tidal model, consisting of lines
%         <elevation file name>
%         <transport file name>
%         <grid file name>
%         <function to convert lat,lon to x,y>
%
% Output:    
%         lon - Longitude
%         lat - Latitude
%           z - Water depth (water column thickness under ice shelves)
%
% Sample call:
%
%        [lon,lat,z]=get_grid('Model_Ross_prior');
%
%========================================================================

function [x,y,z] = get_grid(Model);

type='z'; k=1; % Just sets values (for 'z') to sue for rdModFile
[ModName,GridName,Fxy_ll]=rdModFile(Model,k);
[Flag]=checkTypeName(ModName,GridName,type);
if Flag>0,return;end

disp(['Accessing depth/wct file ... ' GridName]);

[ll_lims, z, mz, iob] =  grd_in(GridName); % Reads the file;
[n, m]=size(z);                           % z array size;
[x, y] = XY(ll_lims, n, m); 
loc=find(z==0); z(loc)=NaN;
pcolor(x,y,z');shading flat;colorbar
grid on; set(gca,'layer','top')
return