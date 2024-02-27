function ATT = nc_cf_harvest_tuple_from_inspire(xmlname);
%nc_cf_harvest_tuple_from_inspire  read metadata from INSPIRE web editor xml
%
% tuple = nc_cf_harvest_tuple_from_inspire(xmlfile);
%
% See also: nc_cf_harvest_matrix_from_inspire, http://inspire-geoportal.ec.europa.eu/editor/

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2015 Van Oord
%       Gerben de Boer, <gerben.deboer@vanoord.com>
%
%       Watermanweg 64
%       3067 GG
%       Rotterdam
%       Netherlands
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

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 09 Nov 2012
% Created with Matlab version: 8.0.0.783 (R2012b)

% $Id: running_median_filter.m 10097 2014-01-29 23:02:09Z boer_g $
% $Date: 2014-01-30 00:02:09 +0100 (Thu, 30 Jan 2014) $
% $Author: boer_g $
% $Revision: 10097 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/signal_fun/running_median_filter.m $
% $Keywords: $

R = xml2struct(xmlname);

ATT = nc_cf_harvest_tuple_initialize;

try
ATT.platform_name = R.fileIdentifier.fileIdentifier.CharacterString;
ATT.platform_id   = ATT.platform_name;
ATT.urlPath       = [R.identificationInfo.identificationInfo.MD_DataIdentification.MD_DataIdentification.citation.citation.CI_Citation.CI_Citation.identifier.identifier.RS_Identifier.RS_Identifier.codeSpace.codeSpace.CharacterString,ATT.platform_name];
end

try
ATT.geospatialCoverage.eastwest.start = R.identificationInfo.identificationInfo.MD_DataIdentification.MD_DataIdentification.extent.extent.EX_Extent.EX_Extent.geographicElement.geographicElement.EX_GeographicBoundingBox.EX_GeographicBoundingBox.westBoundLongitude.westBoundLongitude.Decimal;
ATT.geospatialCoverage.eastwest.end   = R.identificationInfo.identificationInfo.MD_DataIdentification.MD_DataIdentification.extent.extent.EX_Extent.EX_Extent.geographicElement.geographicElement.EX_GeographicBoundingBox.EX_GeographicBoundingBox.eastBoundLongitude.eastBoundLongitude.Decimal;
ATT.geospatialCoverage.eastwest.start = str2num(ATT.geospatialCoverage.eastwest.start);
ATT.geospatialCoverage.eastwest.end   = str2num(ATT.geospatialCoverage.eastwest.end  );
end

try
ATT.geospatialCoverage.northsouth.start   = R.identificationInfo.identificationInfo.MD_DataIdentification.MD_DataIdentification.extent.extent.EX_Extent.EX_Extent.geographicElement.geographicElement.EX_GeographicBoundingBox.EX_GeographicBoundingBox.southBoundLatitude.southBoundLatitude.Decimal;
ATT.geospatialCoverage.northsouth.end     = R.identificationInfo.identificationInfo.MD_DataIdentification.MD_DataIdentification.extent.extent.EX_Extent.EX_Extent.geographicElement.geographicElement.EX_GeographicBoundingBox.EX_GeographicBoundingBox.northBoundLatitude.northBoundLatitude.Decimal;
ATT.geospatialCoverage.northsouth.start   = str2num(ATT.geospatialCoverage.northsouth.start);
ATT.geospatialCoverage.northsouth.end     = str2num(ATT.geospatialCoverage.northsouth.end  );
end

try
ATT.timeCoverage.start                  = R.identificationInfo.identificationInfo.MD_DataIdentification.MD_DataIdentification.extent.extent.EX_Extent.EX_Extent.temporalElement.temporalElement.EX_TemporalExtent.EX_TemporalExtent.extent.extent.TimePeriod.TimePeriod.beginPosition;
ATT.timeCoverage.start = datenum(ATT.timeCoverage.start);
end

try
ATT.timeCoverage.end                    = R.identificationInfo.identificationInfo.MD_DataIdentification.MD_DataIdentification.extent.extent.EX_Extent.EX_Extent.temporalElement.temporalElement.EX_TemporalExtent.EX_TemporalExtent.extent.extent.TimePeriod.TimePeriod.endPosition;
ATT.timeCoverage.end = datenum(ATT.timeCoverage.end);
end



