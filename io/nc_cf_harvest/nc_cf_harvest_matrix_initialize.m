function D = nc_cf_harvest_matrix_initialize(varargin)
%NC_CF_HARVEST_MATRIX_INITIALIZE  pre-allocate meta-data meta-data struct with matrices
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
% $Id: nc_cf_harvest_matrix_initialize.m 8360 2013-03-20 16:18:14Z boer_g $
% $Date: 2013-03-21 00:18:14 +0800 (Thu, 21 Mar 2013) $
% $Author: boer_g $
% $Revision: 8360 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/nc_cf_harvest/nc_cf_harvest_matrix_initialize.m $
% $Keywords$

OPT.featuretype   = 'timeseries';    %'timeseries' % http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/cf-conventions.html#discrete-sampling-geometries
OPT.platform_id   = 'platform_id';   % CF-1.6, older: 'station_id'  , harvested when OPT.featuretype='timeseries'
OPT.platform_name = 'platform_name'; % CF-1.6, older: 'station_name', harvested when OPT.featuretype='timeseries'

if nargin>0
   n = varargin{1};varargin{1} = [];
else
   n = 1;
end

OPT = setproperty(OPT,varargin);
        
% URL

        D.urlPath       = cell(1,n);
        D.dataSize      = repmat(nan,[1 n]);
        D.date          = repmat(nan,[1 n]);

% What: http://www.unidata.ucar.edu/projects/THREDDS/tech/catalog/v1.0.2/InvCatalogSpec.html#controlledVocabulary   

        D.Conventions   = cell(1,n);
        D.variable_name = cell(1,n);
        D.standard_name = cell(1,n);
        D.long_name     = cell(1,n);
        D.units         = cell(1,n);

% Where: http://www.unidata.ucar.edu/projects/THREDDS/tech/catalog/v1.0.2/InvCatalogSpec.html#geospatialCoverage

        D.geospatialCoverage_northsouth_start      = repmat(nan,[1 n]);
        D.geospatialCoverage_northsouth_size       = repmat(nan,[1 n]);
        D.geospatialCoverage_northsouth_resolution = repmat(nan,[1 n]);
        D.geospatialCoverage_northsouth_end        = repmat(nan,[1 n]);

        D.geospatialCoverage_eastwest_start        = repmat(nan,[1 n]);
        D.geospatialCoverage_eastwest_size         = repmat(nan,[1 n]);
        D.geospatialCoverage_eastwest_resolution   = repmat(nan,[1 n]);
        D.geospatialCoverage_eastwest_end          = repmat(nan,[1 n]);

        D.geospatialCoverage_updown_start          = repmat(nan,[1 n]);
        D.geospatialCoverage_updown_size           = repmat(nan,[1 n]);
        D.geospatialCoverage_updown_resolution     = repmat(nan,[1 n]);
        D.geospatialCoverage_updown_end            = repmat(nan,[1 n]);

        D.geospatialCoverage_x_start               = repmat(nan,[1 n]);
        D.geospatialCoverage_x_size                = repmat(nan,[1 n]);
        D.geospatialCoverage_x_resolution          = repmat(nan,[1 n]);
        D.geospatialCoverage_x_end                 = repmat(nan,[1 n]);

        D.geospatialCoverage_y_start               = repmat(nan,[1 n]);
        D.geospatialCoverage_y_size                = repmat(nan,[1 n]);
        D.geospatialCoverage_y_resolution          = repmat(nan,[1 n]);
        D.geospatialCoverage_y_end                 = repmat(nan,[1 n]);
        %D.projectionEPSGcode                      = cell(1,n);

% When: http://www.unidata.ucar.edu/projects/THREDDS/tech/catalog/v1.0.2/InvCatalogSpec.html#timeCoverage

        D.timeCoverage_start      = repmat(nan,[1 n]);
        D.timeCoverage_duration   = repmat(nan,[1 n]);
        D.timeCoverage_resolution = repmat(nan,[1 n]);
        D.timeCoverage_end        = repmat(nan,[1 n]);

% TO DO Timeseries

        D.number_of_observations  = repmat(nan,[1 n]);
        D.(OPT.platform_id)       = cell(1,n);
        D.(OPT.platform_name)     = cell(1,n);

%                     D.title = cell(1,n);
%               D.institution = cell(1,n);
%                    D.source = cell(1,n);
%                   D.history = cell(1,n);
%                D.references = cell(1,n);
%                     D.email = cell(1,n);
%                   D.comment = cell(1,n);
%                   D.version = cell(1,n);
%               D.Conventions = cell(1,n);
%             D.terms_for_use = cell(1,n);
%                D.disclaimer = cell(1,n);
