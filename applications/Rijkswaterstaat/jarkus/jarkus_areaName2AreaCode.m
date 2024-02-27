function areacode = jarkus_areaName2AreaCode(areaname)
%JARKUS_AREANAME2AREACODE  returns jarkus area code of selected jarkus area name

url = 'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/profiles/transect.nc'; % jarkus_url
areanames = nc_varget(url, 'areaname');
areacodes = nc_varget(url, 'areacode');
if size(areaname,1) == 1
    ids      = strcmp(areaname,cellstr(areanames));
    areacode = areacodes(find(ids > 0, 1, 'first'));
else
    [dum idcell]      = ismember(areaname,cellstr(areanames));
    areacode          = NaN(areaname);
    for i = 1:size(areaname,1);
        areacode(i)   = areacodes(idcell(idcell>0));
    end
end

