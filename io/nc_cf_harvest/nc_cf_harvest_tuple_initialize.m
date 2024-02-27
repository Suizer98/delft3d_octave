function T = nc_cf_harvest_tuple_initialize(varargin)
%NC_CF_HARVEST_TUPLE_INITIALIZE  pre-allocate meta-data tuple-array
%
%   T = nc_cf_harvest_tuple_initialize(<n>)
%
% initializes a n-sizes structure, default n=1
%
%See also: nc_cf_harvest

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
% $Id: nc_cf_harvest_tuple_initialize.m 8360 2013-03-20 16:18:14Z boer_g $
% $Date: 2013-03-21 00:18:14 +0800 (Thu, 21 Mar 2013) $
% $Author: boer_g $
% $Revision: 8360 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/nc_cf_harvest/nc_cf_harvest_tuple_initialize.m $
% $Keywords$

OPT.featuretype   = 'timeseries';    %'timeseries' % http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/cf-conventions.html#discrete-sampling-geometries
OPT.platform_id   = 'platform_id';   % CF-1.6, older: 'station_id'  , harvested when OPT.featuretype='timeseries'
OPT.platform_name = 'platform_name'; % CF-1.6, older: 'station_name', harvested when OPT.featuretype='timeseries'

if nargin > 0 && isnumeric(varargin{1})
   n = varargin{1};varargin(1) = [];
else
   n = 1;
end

OPT = setproperty(OPT,varargin);

% URL

   T.urlPath       = '';
   T.dataSize      = nan;
   T.date          = nan;

% What: http://www.unidata.ucar.edu/projects/THREDDS/tech/catalog/v1.0.2/InvCatalogSpec.html#controlledVocabulary   
   
   T.Conventions   = '';
   T.variable_name = '';
   T.standard_name = '';
   T.units         = '';
   T.long_name     = '';

% Where: http://www.unidata.ucar.edu/projects/THREDDS/tech/catalog/v1.0.2/InvCatalogSpec.html#geospatialCoverage

   T.geospatialCoverage.northsouth = geospatialCoverage_initialize();
   T.geospatialCoverage.eastwest   = geospatialCoverage_initialize();
   T.geospatialCoverage.updown     = geospatialCoverage_initialize();
   T.geospatialCoverage.x          = geospatialCoverage_initialize();
   T.geospatialCoverage.y          = geospatialCoverage_initialize();
  %T.projectionEPSGcode            = []; % NB does not allow use of cell2mat later on
   
% When: http://www.unidata.ucar.edu/projects/THREDDS/tech/catalog/v1.0.2/InvCatalogSpec.html#timeCoverage

  T.timeCoverage                  = timeCoverage_initialize();
   
% Timeseries

   if strcmpi(OPT.featuretype,'timeseries')
      T.number_of_observations = nan;
      T.platform_id            = '';
      T.platform_name          = '';
   end
   
% replicate

  T = repmat(T,[n 1]);
   