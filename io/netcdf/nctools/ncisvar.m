function bool = ncisvar(ncfile,varname)
%NCISVAR  determines if a variable is present in a netCDF file.
%
%   BOOL = NCISVAR(NCFILE,VARNAME) returns true if the variable
%   specified by VARNAME is present in the given file.   Use
%   nc_global to specify a global attribute.
%
%   Example:  Determine if the variable 'peaks' is present
%   in the example file shipped with R2008b.
%       bool = ncisvar('example.nc','peaks');
%
%   See also ncread, ncisvar, ncisdim

ncid = netcdf.open(ncfile,'NOWRITE');
try
	netcdf.inqVarID(ncid,varname);
	bool = true;
catch myException %#ok<NASGU>
	bool = false;
end

netcdf.close(ncid);
return

