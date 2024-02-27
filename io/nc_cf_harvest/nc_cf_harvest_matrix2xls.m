function nc_cf_opendap2catalog2xls(xlsname,ATT,varargin)
%nc_cf_harvest_matrix2xls  write nc_cf_harvest object to Excel file
%
% deprecated: use nc_cf_harvest2xls
%
%See also: NC_CF_HARVEST, nc_cf_harvest2nc, nc_cf_harvest2xml,
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
% $Id: nc_cf_harvest_matrix2xls.m 8360 2013-03-20 16:18:14Z boer_g $
% $Date: 2013-03-21 00:18:14 +0800 (Thu, 21 Mar 2013) $
% $Author: boer_g $
% $Revision: 8360 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/nc_cf_harvest/nc_cf_harvest_matrix2xls.m $
% $Keywords$

OPT.debug       = 0;

OPT = setproperty(OPT,varargin);

      if OPT.debug
      structfun(@(x) x{1},ATT,'UniformOutput',0)	
      end
      n = length(ATT.geospatialCoverage_northsouth_start);

% Timeseries

      if isfield(ATT,'platform_id')
      D.platform_id                   = ATT.platform_id;   
      end

      if isfield(ATT,'platform_name')
      D.platform_name                 = ATT.platform_name;
      end

      if isfield(ATT,'number_of_observations')
      D.number_of_observations        = ATT.number_of_observations;
      end

% When: http://www.unidata.ucar.edu/projects/THREDDS/tech/catalog/v1.0.2/InvCatalogSpec.html#timeCoverage

      D.timeCoverage_start            = datestr(ATT.timeCoverage_start,'yyyy-mm-ddTHH:MM:SS');
      D.timeCoverage_end              = datestr(ATT.timeCoverage_end  ,'yyyy-mm-ddTHH:MM:SS');

% Where: http://www.unidata.ucar.edu/projects/THREDDS/tech/catalog/v1.0.2/InvCatalogSpec.html#geospatialCoverage

      D.longitude_start               = ATT.geospatialCoverage_eastwest_start;
      D.longitude_end                 = ATT.geospatialCoverage_eastwest_end;
      D.latitude_start                = ATT.geospatialCoverage_northsouth_start;
      D.latitude_end                  = ATT.geospatialCoverage_northsouth_end;

% URL

      D.urlPath                       = ATT.urlPath;

% What: http://www.unidata.ucar.edu/projects/THREDDS/tech/catalog/v1.0.2/InvCatalogSpec.html#controlledVocabulary   

      D.variable_name                 = ATT.variable_name     ;%char(cellfun(@(x) str2line(x,'s',' ')  ,ATT.variable_name,'UniformOutput',false));
      D.standard_name                 = ATT.standard_name     ;%char(cellfun(@(x) str2line(x,'s',' ')  ,ATT.standard_name,'UniformOutput',false));
      D.units                         = ATT.units             ;%char(cellfun(@(x) str2line(x,'s',' ')  ,ATT.units        ,'UniformOutput',false));
      D.long_name                     = ATT.long_name         ;%char(cellfun(@(x) addrowcol(str2line(x,'s','" "'),0,[-1 1],'"'),ATT.long_name    ,'UniformOutput',false));
      
      xlsname = fullfile(xlsname);
      if exist(xlsname)
         delete(xlsname);
      end
 
      struct2xls(xlsname,D,'header','catalog.nc was created offline by $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/nc_cf_harvest/nc_cf_harvest_matrix2xls.m $ from the associatec catalog.xml. Catalog.xls is a test development, please do not rely on it. Please join www.OpenEarth.eu and request a password to change $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/nc_cf_harvest/nc_cf_harvest_matrix2xls.m $ until it harvests all meta-data you need.');