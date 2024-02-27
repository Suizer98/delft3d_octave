function varargout = nc_cf_opendap2catalog_test
%NC_CF_OPENDAP2CATALOG_TEST   test for nc_cf_opendap2catalog in locla files
%
%See also: nc_cf_opendap2catalog

%% create local files

   FIG(1) = figure;nc_cf_grid_write_lat_lon_orthogonal_tutorial
   FIG(2) = figure;nc_cf_grid_write_lat_lon_curvilinear_tutorial
   FIG(3) = figure;nc_cf_grid_write_x_y_orthogonal_tutorial
   FIG(4) = figure;nc_cf_grid_write_x_y_curvilinear_tutorial
   FIG(5) = figure;nc_cf_timeseries_write_tutorial
   
   delete(FIG)
   
   d = fileparts(mfilename('fullpath'));

%% harvest local files

   CATALOG = nc_cf_opendap2catalog(d,'save',1);
   
   ok(1) = any(strmatch([d,filesep,'nc_cf_timeseries_write_tutorial.nc']              ,CATALOG.urlPath))
   ok(2) = any(strmatch([d,filesep,'nc_cf_grid_write_lat_lon_orthogonal_tutorial.nc'] ,CATALOG.urlPath))
   ok(3) = any(strmatch([d,filesep,'nc_cf_grid_write_lat_lon_curvilinear_tutorial.nc'],CATALOG.urlPath))
   ok(4) = any(strmatch([d,filesep,'nc_cf_grid_write_x_y_orthogonal_tutorial.nc']     ,CATALOG.urlPath))
   ok(5) = any(strmatch([d,filesep,'nc_cf_grid_write_x_y_curvilinear_tutorial.nc']    ,CATALOG.urlPath))
   
   
   varargout = {all(ok)};
   
% TO DO

%% define remote files

   %  %http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/waterbase/mass_concentration_of_organic_detritus_expressed_as_nitrogen_in_sea_water/catalog.html
   %  
   %  % timeserie set
   %  url = 'F:\opendap\thredds\rijkswaterstaat\waterbase\mass_concentration_of_organic_detritus_expressed_as_nitrogen_in_sea_water\';
   %  % grid set
   %  url = 'F:\opendap\thredds\rijkswaterstaat\kustlidar\';
   %  

%% harvest remote files

   %  nc_cf_opendap2catalog('base',url,... % dir where to READ netcdf
   %                 'catalog_dir',,...    % dir where to SAVE catalog
   %                        'save',1,...
   %                  'urlPathFcn',@(s) strrep(s,url,'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/kustlidar/'))
   %  
