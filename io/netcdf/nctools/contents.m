%NCTOOLS  extra tools for netCDF files
%
%Generic netCDF tools
%
%    ncisatt                        - determines if an attribute is present in a netCDF file.
%    ncisdim                        - determines if a dimension is present in a netCDF file.
%    ncisvar                        - determines if a variable is present in a netCDF file.
%    nc_type                        - find netCDF type corresponding to Matlab types
%
%    nc2struct                      - load netCDF file with to struct (beta)
%    struct2nc                      - save struct with 1D arrays to netCDF file (beta)
%
%    ncread_cf_time                 - reads time data from specified CF compliant time variable into matlab datenum 
%    ncwrite_cf_time                - writes time data in matlab datenum to a specified cf compliant time variable in a nc file
%
%    nc_actual_range                - reads or retrieves actual range from contiguous netCDF variable
%    nc_dimension_subset            - subset slices along 1 dimension from all nc variables
%    nc_atrname2index               - get index of attribute name from ncfile
%    nc_varname2index               - get index of variable name from ncfile
%    nc_varfind                     - Lookup variable name(s) in NetCDF file using attributename and -value pair
%    ncread_strict_dimension_order  - Reads the data from the netcdf file in the specified dimension order
%    nc_nantest                     - This shows how NaNs behave in snctools
%    netcdf_addvar                  - adds a variable to a NetCDF file using the matlab netcdf library
%
% CF conventions:
%
%    nc_cf_bounds2cor               - rewrite 3D CF bounds matrix to 2D matrix of corners
%    nc_cf_cor2bounds               - rewrite vector or matrix of corners to CF bounds matrix
%
%    nc_cf_time                     - reads time variables from a netCDF file into Matlab datenumber
%
%    nc_cf_grid_mapping             - get CF/ADAGUC grid mapping nc attributes from epsg code
%
% Collection of netCDF grid files
%
%    nc_cf_gridset2kml              - CF_CF_GRIDSET2KML   make vectorized kml files per tile in a netCDF gridset
%    nc_cf_gridset_example          - NC_CF_GRIDSET_TUTORIAL  how to acces a set of netCDF tiles
%    nc_cf_gridset_getData          - interpolate data in space (and time) from a netCDF tile set
%    nc_cf_gridset_getData_test     - tets for nc_cf_gridset_getData
%    nc_cf_gridset_getData_tutorial - Extract subset of grid data from set of time-depdendent tiles
%    nc_cf_gridset_get_list         - list of all tiles and their times from opendap server
%    nc_cf_gridset_overview         - make kml file with links to each tile in a netCDF gridset
%
% Semantics:
%
%    nc_cf_standard_name_table      - read/search CF parameter vocabulary
%    nc_cf_standard_names           - Routine facilitates adding variables that are part of standard-name glossaries
%    nc_cf_standard_names_generate  - generates nc_CF_standards based nc_cf_standard_names_catalogue.xls
%    nc_oe_standard_names           - Routine facilitates adding variables that are part of standard-name glossaries
%    nc_oe_standard_names_generate  - generates nc_CF_standards based nc_cf_standard_names_catalogue.xls
%
% Value-based subsetting (instead if index based)
%
%    nc_varget_range                - get a monotonous subset from HUGE vector based on variable value
%    nc_varget_range2d              - get a subset from 2d x/y matrices based on polygon
%    nc_varget_range2d_test         - Test for nc_varget_range2d
%    nc_varget_range_test           - test for nc_varget_range
%    nc_cf_time_range               - reads get a monotonous subset from HUGE time vector into Matlab datenumber
%    nc_cf_time_range_test          - test for nc_cf_time_range
%
% Tutotials on creating netCDF grid files:
%
%     ncwritetutorial_grid_lat_lon_swath       - Create netCDF-CF file of orthogonal  x-y grid
%     ncwritetutorial_grid_lat_lon_curvilinear - Create netCDF-CF file of curvilinear lat-lon grid
%     ncwritetutorial_grid_lat_lon_orthogonal  - Create netCDF-CF file of orthogonal  lat-lon grid
%     ncwritetutorial_grid_x_y_curvilinear     - Create netCDF-CF file of curvilinear x-y grid
%     ncwritetutorial_grid_x_y_orthogonal      - Create netCDF-CF file of orthogonal  x-y grid
%
% Functions to create special standardized netCDF data types incl tutorial:
% These files aim to adhere to the CF, OceanSites and SeaDataNet conventions.
%
%     ncwrite_profile                 - write timeSeriesProfile to netCDF-CF file
%     ncwrite_profile_tutorial        - tutorial for writing timeSeriesProfile to netCDF-CF file
%     ncwrite_timeseries              - write timeseries to netCDF-CF file
%     ncwrite_timeseries_tutorial     - tutorial for writing timeseries on disconnected platforms to netCDF-CF file
%     ncwrite_trajectory              - write trajectory to netCDF-CF file
%     ncwrite_trajectory_tutorial     - tutorial for writing trajectory to netCDF-CF file
%
% Functions to read special netCDF data types incl tutorial:
%
%     nc_cf_timeseries_tutorial       - how to read and subset a netCDF time series file
%     nc_cf_grid                      - load/plot one variable from netCDF grid file
%     nc_cf_grid_tutorial             - how to read and subset a netCDF grid file
%     nc_cf_grid_write                - save orthogonal/curvilinear lat-lon or x-y grid as netCDF-CF file
%     nc_cf_line                      - write  (NaN-seperated) (poly-)line (segments) to netCDF file
%     nc_cf_timeseries                - load/plot one variable from TimeSeries netCDF file
%
% See also: netcdf, ncread, ncwrite, outdated: snctools
