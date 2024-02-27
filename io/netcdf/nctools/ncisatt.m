function bool = ncisatt(ncfile,varname,attrname)
%NCISATT  determines if an attribute is present in a netCDF file.
%
%   BOOL = NCISATT(NCFILE,VARNAME,ATTRNAME) returns true if the attribute
%   specified by VARNAME and ATTRNAME is present in the given file.   Use
%   nc_global to specify a global attribute.
%
%   Example:  Determine if the global attribute 'creation_date' is present
%   in the example file shipped with R2008b.
%       bool = ncisatt('example.nc',nc_global,'creation_date);
%
%   See also ncreadatt, ncisvar, ncisdim

bool = true;

ncid = netcdf.open(ncfile,'nowrite');
try
	if ischar(varname)
		varid = netcdf.inqVarID(ncid,varname);
	else
		varid = varname;
	end
catch me
	netcdf.close(ncid);
	rethrow(me);
end

try
	attid = netcdf.inqAttID(ncid,varid,attrname);
catch me
	bool = false;
end	

netcdf.close(ncid);
return