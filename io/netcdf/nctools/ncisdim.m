function bool = ncisdim(ncfile,dimname)
%NCISDIM  determines if a dimension is present in a netCDF file.
%
%   BOOL = NCISDIm(NCFILE,DIMNAME) returns true if the dimension
%   specified by DIMNAME is present in the given file.   Use
%   nc_global to specify a global attribute.
%
%   Example:  Determine if the dimension 'peaks' is present
%   in the example file shipped with R2008b.
%       bool = ncisdim('example.nc','peaks');
%
%   See also ncread, ncisvar, ncisdim

ncid = netcdf.open(ncfile,'NOWRITE');
try
	netcdf.inqDimID(ncid,dimname);
	bool = true;
catch myException %#ok<NASGU>
	bool = false;
end

netcdf.close(ncid);
return

