% OpenEarhTools netCDF toolbox distribution.
%
%   netcdf_settings     - adds all netCDF tools below to matlab path
%                         incl. some legacies solutions and JAVA library.
%                         Automatically uses Matlab native netcdf library (R2008b+)
%                         for write, uses JAVA library for OPeNDAP read.
%
% Note that all matlab tools use a different dimension order than all other
% netcdf libraries, so ncinfo sows soemhting different than e.g. ncbrowse.
%
% For more info on netCDF and the CF conventions:
%  http://www.unidata.ucar.edu/software/netcdf/, http://cf-pcmdi.llnl.gov/
%
% * OFFICIAL LOW-LEVEL TOOLBOX
%   netcdf                                       - netcdf C API
% * OFFICIAL HIGH-LEVEL READ TOOLBOX
%   ncread, ncreadatt                            - read
%   nccreate, ncwriteschema, ncwrite, ncwriteatt - add
%   ncdisp, ncinfo                               - info
% * OPENEARTH EXTRA NETCDF-CF TOOLS
%   nctools                                      - toolbox
% * OBSOLETE
%   mexnc                                        - external low-level netCDF io (OBSOLETE)
%   snctools                                     - external simple netCDF io before R2012b (OBSOLETE)
% * JAVA TOOLBOX
%   njtbx                                        - external netCDF java toolbox
%
% See also: OpenEarthTools: general, applications, netcdf
