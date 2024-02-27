function cf_cf_gridset2kml(varargin)
%CF_CF_GRIDSET2KML   make vectorized kml files per tile in a netCDF gridset
%
%   cf_cf_gridset2kml(<keyword,value>)
%
% creates 3D surface of set of tiles (full 3D, tri simplified and tiled)
%
%See also: nc_cf_gridset_overview, snctools, nc_multibeam > nc_gridset, nc_cf_gridset_overview

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares for Building with Nature
%       Thijs Damsma
%
%       Thijs.Damsma@deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% $Id: nc_cf_gridset2kml.m 3120 2010-10-04 16:00:24Z boer_g $
% $Date: 2010-10-05 00:00:24 +0800 (Tue, 05 Oct 2010) $
% $Author: boer_g $
% $Revision: 3120 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/netcdf/nctools/nc_cf_gridset2kml.m $
% $Keywords: $

%% initialize

 OPT.load_nc                 = 'F:\opendap\thredds\rijkswaterstaat\kustlidar\'; % for reading
 OPT.save_kml                = 'F:\_KML\rijkswaterstaat\kustlidar\'; % for writing

 OPT.EPSGcode                = 28992; % should be inside dataset
 OPT.calculate_latlon_local  = 0; %true;
 OPT.datestr                 = 'YYYY-mm'; % for 3d kml file names
 OPT.clim                    = [-50 25];
 OPT.colorMap                = @(m)colormap_cpt('bathymetry_vaklodingen',m);
 OPT.colorSteps              = 500;
 OPT.zScaleFun               = @(z)(z+20)*5;
 OPT.CBcolorTitle            = 'depth [m]';
 %OPT for throowing aay old kml
 
%%

EPSG  = load('EPSG');
files = opendap_catalog(OPT.load_nc);

for ii = 1:length(files);

   [path, fname] = fileparts(files{ii});
   x       = nc_varget (files{ii},   'x');
   y       = nc_varget (files{ii},   'y');
   time    = nc_cf_time(files{ii},'time');
   timestr =  cellstr(datestr(time,OPT.datestr));

   %% calculate coordinates, should not be necessary!!

   if OPT.calculate_latlon_local
     % it is though ... but it goes lightning fast anyways ;-)
     [x,y] = meshgrid(x,y);
     [lon,lat] = convertCoordinates(x,y,EPSG,'CS1.code',OPT.EPSGcode,'CS2.name','WGS 84','CS2.type','geo');
   else
     lon  = nc_varget (files{ii}, 'lon');
     lat  = nc_varget (files{ii}, 'lat');
   end


%% create output directory: Check dir, make if needed
    
   outputDir = [OPT.save_kml filesep '3D'];
   if ~isdir(outputDir)
       mkdir(outputDir);
   end

%% loop through all the years
   
   for jj = size(time,1)
    
      %% display progress

      disp([num2str(ii) '/' num2str(length(files)) ': ' fname ' ' timestr{jj}]);
      z=[];
      
      %% filenames

      kml3dname_orth  = [outputDir filesep fname '_' timestr{jj} '_3D_orth.kmz' ];
      kml3dname_tri   = [outputDir filesep fname '_' timestr{jj} '_3D_tri.kmz'  ];
      kml3dname_tiled = [outputDir filesep fname '_' timestr{jj} '_3D_tiled.kmz'];

      %% 3D: surf
   
      if 1 %~exist(kml3dname_orth,'file') % assume rets was genereted simultaneoulsy
          % load z data
          z = nc_varget(files{ii},'z',[jj-1,0,0],[1,-1,-1]);
          z(z>500) = nan;
          disp(['elements: ' num2str(sum(~isnan(z(:))))]);
          
          % make *.kmz
          %KMLsurf_tiled(lat,lon,z,'fileName',[outputDir timestr(jj,:) '_3D.kmz'])%,'fileName',[outputDir timestr(jj,:) '_3D.kmz'],...
              %'kmlName',[fname ' ' timestr(jj,:) ' 2D'],'cLim',[(a-c)*b (a+c)*b]);
              
if 0
          KMLsurf(lat ,lon ,z ,...
                 'fileName',kml3dname_orth,...
                  'kmlName',[fname ' ' timestr{jj} ' 3D'],...
             'CBcolorTitle',OPT.CBcolorTitle,...
               'zScaleFun',OPT.zScaleFun,...
                 'colormap',OPT.colorMap,...
               'colorSteps',OPT.colorSteps,...
                     'cLim',OPT.clim);

          m = ~isnan(z);
          [tri1,lon1,lat1,z1] = delaunay_simplified(lon(m),lat(m),z(m),.05);
          
          KMLtrisurf(tri1,lat1,lon1,z1,...
                 'fileName',kml3dname_tri,...
                  'kmlName',[fname ' ' timestr{jj} ' 3D simplified'],...
             'CBcolorTitle',OPT.CBcolorTitle,...
                'zScaleFun',OPT.zScaleFun,...
                 'colormap',OPT.colorMap,...
               'colorSteps',OPT.colorSteps,...
                     'cLim',OPT.clim);
end
          KMLsurf_tiled(lat,lon,z,...
                 'fileName',kml3dname_tiled,...
                  'kmlName',[fname ' ' timestr{jj} ' 3D simplified'],...
             'CBcolorTitle',OPT.CBcolorTitle,...
                'zScaleFun',OPT.zScaleFun,...
                 'colormap',OPT.colorMap,...
               'colorSteps',OPT.colorSteps,...
                     'cLim',OPT.clim);
                     
      else
          disp ([kml3dname_orth ' already exists'])
      end

   end
end