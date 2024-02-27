function grid = jarkus_netcdf2grid(filename)
%JARKUS_NETCDF2GRID converts netCDF-CF file to Jarkus grid struct
%
%    [grid] = jarkus_netcdf2grid(filename)
%
% See web : <a href="http://www.watermarkt.nl/kustenzeebodem/">www.watermarkt.nl/kustenzeebodem/</a>
% See also: JARKUS_TRANSECT2GRID  , JARKUS_NETCDF2GRID, JARKUS_UPDATEGRID, 
%           JARKUS_TRANSECT2NETCDF, JARKUS_GRID2NETCDF 

    grid.id          = nc_varget(filename, 'id');
    grid.areacode    = nc_varget(filename, 'areacode');
    grid.areaname    = nc_varget(filename, 'areaname');
    grid.alongshore  = nc_varget(filename, 'alongshore');
    grid.cross_shore = nc_varget(filename, 'cross_shore');
    grid.time        = nc_varget(filename, 'time');
    grid.year        = nc_varget(filename, 'year');

end % function jarkus_netcdf2grid