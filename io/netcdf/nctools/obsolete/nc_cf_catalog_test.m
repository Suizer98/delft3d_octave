function nc_cf_catalog_test()
%NC_CF_CATALOG_TEST   test script for 
%
%See also: nc_cf_directory2catalog, nc_cf2catalog

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Gerben de Boer
%
%       gerben.deboer@deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id: nc_cf_catalog_test.m 11864 2015-04-15 14:51:13Z gerben.deboer.x $
% $Date: 2015-04-15 22:51:13 +0800 (Wed, 15 Apr 2015) $
% $Author: gerben.deboer.x $
% $Revision: 11864 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/netcdf/nctools/obsolete/nc_cf_catalog_test.m $
% $Keywords: $

if TeamCity.running
    TeamCity.ignore('Test needs user input');
    return;
end

%% get catalog

   OPT.baseurl = 'http://opendap.deltares.nl:8080/thredds/dodsC/opendap/rijkswaterstaat/waterbase/sea_surface_height/';
   
   C           = nc2struct([OPT.baseurl,'catalog.nc'])
   
%% query call
%
%             WHEN  datenum_start
%                   datenum_end  
%             WHERE geospatialCoverage_northsouth
%                   geospatialCoverage_northsouth
%                   geospatialCoverage_eastwest  
%                   geospatialCoverage_eastwest  
%             WHAT  standard_names

   index       = (C.datenum_start                      > datenum(1648,1,1) & ...
                  C.datenum_end                        < datenum(2010,1,1) & ...
                  C.geospatialCoverage_northsouth(:,1) >  52 + 19/60       & ...
                  C.geospatialCoverage_northsouth(:,2) <  52 + 42/60       & ...
                  C.geospatialCoverage_eastwest  (:,1) >   5 +  0/60       & ...
                  C.geospatialCoverage_eastwest  (:,2) <   5 + 28/60       & ...
 cell2mat(strfind(C.standard_names                   ,'sea_surface_height'))>0);
                  
   index = find(index);

%% query overview

   for ii=1:length(index)
   
   disp([C.timecoverage_start{index(ii)},'   ',...
           C.timecoverage_end{index(ii)},'   ',...
                    C.urlPath{index(ii)}]);
   
   end
   
%% use query

   [D,M]=nc_cf_timeseries([OPT.baseurl,filename(char(C.urlPath(index(1),:))),'.nc']);