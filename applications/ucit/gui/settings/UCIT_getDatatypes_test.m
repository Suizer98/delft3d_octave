function UCIT_getDatatypes_test()
%UCIT_GETDATATYPES_TEST  make list of gridded datasets defined for UCIT
%
%
%See also: grid_2D_orthogonal, opendap_catalog, rijkswaterstaat, nc_cf_gridset_get_list

%   url      = 'http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/vaklodingen/catalog.xml';
%   xls      = [OPT.dir,filesep,'jarkus_grids.xls'];
%
%   nc_cf_gridset_get_list(url,'xlsname',xls)
%   
%   url      = 'http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/jarkus/grids/catalog.html';
%   xls      = [OPT.dir,filesep,'jarkus_grids.xls'];
%
%   nc_cf_gridset_get_list(url,'xlsname',xls)
%   
%   url      = 'http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/kustlidar/catalog.html';
%   xls      = [OPT.dir,filesep,'jarkus_grids.xls'];
%
%   nc_cf_gridset_get_list(url,'xlsname',xls)


   L       = UCIT_getDatatypes;
   n       = length(L.grid.urls);
   OPT.dir = fileparts(mfilename('fullpath'));
   
   disp(['Testing datasets, results are saved as Excel files in: ',])

   for i=1:n
   
      disp(['Processing: ',L.grid.names{i}, L.grid.catalog{i}]);
      disp ('----------')
   
      try
      nc_cf_gridset_get_list(L.grid.catalog{i},'xlsname',[OPT.dir,filesep,mkvar(char(L.grid.names{i}))])
      end
   
   end
