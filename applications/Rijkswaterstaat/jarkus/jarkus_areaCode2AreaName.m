function areaname = jarkus_areaCode2AreaName(areacode)
%JARKUS_AREACODE2AREANAME  returns jarkus area name of selected jarkus area code
%
% See also JARKUS_AREANAME2AREACODE

% url = jarkus_url;
url       = 'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/profiles/transect.nc'; 
areanames = nc_varget(url, 'areaname');
areacodes = nc_varget(url, 'areacode');
ids       = ismember(areacodes,areacode);
areaname  = char(cellstr(areanames(find(ids > 0, 1, 'first'),:)));