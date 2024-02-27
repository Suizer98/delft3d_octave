function T = nc_cf_harvest_matrix2tuple(D,varargin)
%NC_CF_HARVEST_MATRIX2TUPLE  convert meta-data struct with matrices to tuple-array
%
%   T = nc_cf_harvest_matrix2tuple(D,<ind>)
%
% extracts indices <ind> from matrix D into struct T, by default n entire D
%
%See also: nc_cf_harvest, nc_cf_harvest_tuple2matrix

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
% $Id: nc_cf_harvest_matrix2tuple.m 8360 2013-03-20 16:18:14Z boer_g $
% $Date: 2013-03-21 00:18:14 +0800 (Thu, 21 Mar 2013) $
% $Author: boer_g $
% $Revision: 8360 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/nc_cf_harvest/nc_cf_harvest_matrix2tuple.m $
% $Keywords$

OPT.featuretype   = 'timeseries';    %'timeseries' % http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/cf-conventions.html#discrete-sampling-geometries
OPT.platform_id   = 'platform_id';   % CF-1.6, older: 'station_id'  , harvested when OPT.featuretype='timeseries'
OPT.platform_name = 'platform_name'; % CF-1.6, older: 'station_name', harvested when OPT.featuretype='timeseries'

if nargin > 1 && isnumeric(varargin{1})
   ind = varargin{1};varargin(1) = [];
else
   ind = lenghth(D.urlPath);
end

OPT = setproperty(OPT,varargin);

T = nc_cf_harvest_tuple_initialize(length(ind),OPT);

for j=1:length(ind)

   jj = ind(j);

% URL

   T(j).urlPath                             = D.urlPath (jj);
   T(j).dataSize                            = D.dataSize(jj);
   T(j).date                                = D.date    (jj);
   
% What: http://www.unidata.ucar.edu/projects/THREDDS/tech/catalog/v1.0.2/InvCatalogSpec.html#controlledVocabulary   

   T(j).Conventions                         = D.Conventions{jj};
   T(j).variable_name                       = strtokens2cell(D.variable_name{jj});
   T(j).standard_name                       = strtokens2cell(D.standard_name{jj});
   T(j).units                               = strtokens2cell(D.units        {jj});
   T(j).long_name                           = strtokens2cell(D.long_name    {jj});

% Where: http://www.unidata.ucar.edu/projects/THREDDS/tech/catalog/v1.0.2/InvCatalogSpec.html#geospatialCoverage

   T(j).geospatialCoverage.northsouth.start      = D.geospatialCoverage_northsouth_start     (jj);
   T(j).geospatialCoverage.northsouth.size       = D.geospatialCoverage_northsouth_size      (jj);
   T(j).geospatialCoverage.northsouth.resolution = D.geospatialCoverage_northsouth_resolution(jj);
   T(j).geospatialCoverage.northsouth.end        = D.geospatialCoverage_northsouth_end       (jj);
   
   T(j).geospatialCoverage.eastwest.start        = D.geospatialCoverage_eastwest_start     (jj);
   T(j).geospatialCoverage.eastwest.size         = D.geospatialCoverage_eastwest_size      (jj);
   T(j).geospatialCoverage.eastwest.resolution   = D.geospatialCoverage_eastwest_resolution(jj);
   T(j).geospatialCoverage.eastwest.end          = D.geospatialCoverage_eastwest_end       (jj);
   
   T(j).geospatialCoverage.updown.start          = D.geospatialCoverage_updown_start     (jj);
   T(j).geospatialCoverage.updown.size           = D.geospatialCoverage_updown_size      (jj); 
   T(j).geospatialCoverage.updown.resolution     = D.geospatialCoverage_updown_resolution(jj); 
   T(j).geospatialCoverage.updown.end            = D.geospatialCoverage_updown_end       (jj); 
   
   T(j).geospatialCoverage.x.start               = D.geospatialCoverage_x_start     (jj);
   T(j).geospatialCoverage.x.size                = D.geospatialCoverage_x_size      (jj);
   T(j).geospatialCoverage.x.resolution          = D.geospatialCoverage_x_resolution(jj);
   T(j).geospatialCoverage.x.end                 = D.geospatialCoverage_x_end       (jj);
   
   T(j).geospatialCoverage.y.start               = D.geospatialCoverage_y_start     (jj);
   T(j).geospatialCoverage.y.size                = D.geospatialCoverage_y_size      (jj);
   T(j).geospatialCoverage.y.resolution          = D.geospatialCoverage_y_resolution(jj);
   T(j).geospatialCoverage.y.end                 = D.geospatialCoverage_y_end       (jj);
   
% When: http://www.unidata.ucar.edu/projects/THREDDS/tech/catalog/v1.0.2/InvCatalogSpec.html#timeCoverage
   
   T(j).timeCoverage.start                  = D.timeCoverage_start     (jj);
   T(j).timeCoverage.duration               = D.timeCoverage_duration  (jj);
   T(j).timeCoverage.resolution             = D.timeCoverage_resolution(jj);
   T(j).timeCoverage.end                    = D.timeCoverage_end       (jj);
   
% Timeseries

   if strcmpi(OPT.featuretype,'timeseries')
      T(j).number_of_observations = D.number_of_observations(jj);
      T(j).platform_id            = D.platform_id{jj}; 
      T(j).platform_name          = D.platform_name{jj};       
   end
   
end % ind   

