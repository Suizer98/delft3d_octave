function nc_cf_harvest_matrix2nc(ncname,ATT,varargin)
%nc_cf_harvest_matrix2nc save nc_cf_harvest data to catalog.nc
%
%   nc_cf_harvest_matrix2nc(ncname,ATT)
%
%See also: NC_CF_HARVEST, nc_cf_harvest2xml, nc_cf_harvest2xls,
%          thredds_dump, thredds_info

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011-2013 Deltares for Nationaal Modellen en Data centrum (NMDC),
%                           Building with Nature and internal Eureka competition.
%       Gerben J. de Boer
%
%       gerben.deboer@deltares.nl
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

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id: nc_cf_harvest_matrix2nc.m 12025 2015-06-22 08:13:14Z gerben.deboer.x $
% $Date: 2015-06-22 16:13:14 +0800 (Mon, 22 Jun 2015) $
% $Author: gerben.deboer.x $
% $Revision: 12025 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/nc_cf_harvest/nc_cf_harvest_matrix2nc.m $
% $Keywords$

   OPT.debug         = 0;
   OPT.featuretype   = 'timeseries';    %'timeseries' % http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/cf-conventions.html#discrete-sampling-geometries
   OPT.platform_id   = 'platform_id';   % CF-1.6, older: 'station_id'  , harvested when OPT.featuretype='timeseries'
   OPT.platform_name = 'platform_name'; % CF-1.6, older: 'station_name', harvested when OPT.featuretype='timeseries'

   OPT = setproperty(OPT,varargin);

% URL

        M.units.dataSize      = 'bytes';
        M.units.date          = 'days since 0000-00-00'; % matlab datenum

% What: http://www.unidata.ucar.edu/projects/THREDDS/tech/catalog/v1.0.2/InvCatalogSpec.html#controlledVocabulary   

% Where: http://www.unidata.ucar.edu/projects/THREDDS/tech/catalog/v1.0.2/InvCatalogSpec.html#geospatialCoverage

        M.units.geospatialCoverage_northsouth_start      = 'degrees_north';
        M.units.geospatialCoverage_northsouth_size       = 'degrees_north';
        M.units.geospatialCoverage_northsouth_resolution = 'degrees_north';
        M.units.geospatialCoverage_northsouth_end        = 'degrees_north';

        M.units.geospatialCoverage_eastwest_start        = 'degrees_east';
        M.units.geospatialCoverage_eastwest_size         = 'degrees_east';
        M.units.geospatialCoverage_eastwest_resolution   = 'degrees_east';
        M.units.geospatialCoverage_eastwest_end          = 'degrees_east';

        M.units.geospatialCoverage_updown_start          = 'm';
        M.units.geospatialCoverage_updown_size           = 'm';
        M.units.geospatialCoverage_updown_resolution     = 'm';
        M.units.geospatialCoverage_updown_end            = 'm';

        M.units.geospatialCoverage_x_start               = 'm';
        M.units.geospatialCoverage_x_size                = 'm';
        M.units.geospatialCoverage_x_resolution          = 'm';
        M.units.geospatialCoverage_x_end                 = 'm';

        M.units.geospatialCoverage_y_start               = 'm';
        M.units.geospatialCoverage_y_size                = 'm';
        M.units.geospatialCoverage_y_resolution          = 'm';
        M.units.geospatialCoverage_y_end                 = 'm';
        %M.projectionEPSGcode                      = cell(1,n);

        M.standard_name.geospatialCoverage_northsouth_start      = 'latitude';
        M.standard_name.geospatialCoverage_northsouth_size       = 'latitude';
        M.standard_name.geospatialCoverage_northsouth_resolution = 'latitude';
        M.standard_name.geospatialCoverage_northsouth_end        = 'latitude';

        M.standard_name.geospatialCoverage_eastwest_start        = 'longitude';
        M.standard_name.geospatialCoverage_eastwest_size         = 'longitude';
        M.standard_name.geospatialCoverage_eastwest_resolution   = 'longitude';
        M.standard_name.geospatialCoverage_eastwest_end          = 'longitude';

        M.standard_name.geospatialCoverage_x_start               = 'projection_x_coordinate';
        M.standard_name.geospatialCoverage_x_size                = 'projection_x_coordinate';
        M.standard_name.geospatialCoverage_x_resolution          = 'projection_x_coordinate';
        M.standard_name.geospatialCoverage_x_end                 = 'projection_x_coordinate';

        M.standard_name.geospatialCoverage_y_start               = 'projection_y_coordinate';
        M.standard_name.geospatialCoverage_y_size                = 'projection_y_coordinate';
        M.standard_name.geospatialCoverage_y_resolution          = 'projection_y_coordinate';
        M.standard_name.geospatialCoverage_y_end                 = 'projection_y_coordinate';
        %M.projectionEPSGcode                      = cell(1,n);

% When: http://www.unidata.ucar.edu/projects/THREDDS/tech/catalog/v1.0.2/InvCatalogSpec.html#timeCoverage

        M.units.timeCoverage_start      = 'days since 0000-00-00'; % matlab datenum
        M.units.timeCoverage_duration   = 'days since 0000-00-00'; % matlab datenum
        M.units.timeCoverage_resolution = 'days since 0000-00-00'; % matlab datenum
        M.units.timeCoverage_end        = 'days since 0000-00-00'; % matlab datenum

% Timeseries

   if strcmpi(OPT.featuretype,'timeseries')
      M.standard_name.platform_id            = 'platform_id'; 
      M.standard_name.platform_name          = 'platform_name';       
   end
   
   
      if exist(ncname)
          error([ncname,' already exists: skipped.'])
      else
          struct2nc(ncname,ATT,M);
      end

      nc_attput(ncname,nc_global,'comment'    ,'catalog.nc was created offline by $$.');
      nc_attput(ncname,nc_global,'Conventions','CF-1.6');
