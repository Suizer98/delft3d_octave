function nc_cf_grid_test
%NC_CF_GRID_TEST  test for nc_cf_grid
%
% Also used to test full OpenEarthTools netCDF toolbox.
%
%See also: nc_cf_grid

%% read grid (OPeNDAP)

   figure('name','grid OPeNDAP')
   f = 'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB122_2120.nc';

   [G,GM] =nc_cf_grid(f,'z');
   
   pngfile  = fullfile(fileparts(mfilename('fullpath')),['tests',filesep,'nc_cf_grid_write_test_',num2str(getpref('SNCTOOLS','PRESERVE_FVD')),'_',version('-release'),  '.png']);
   text(1,0,version('-release'),'rotation',90,'units','normalized','verticalalignment','top')
   print2screensizeoverwrite(pngfile)

%% write grid

    ncfile  = fullfile(fileparts(mfilename('fullpath')),['tests',filesep,'nc_cf_grid_write_test_',num2str(getpref('SNCTOOLS','PRESERVE_FVD')),'_',version('-release'),  '.nc']);
   cdlfile  = fullfile(fileparts(mfilename('fullpath')),['tests',filesep,'nc_cf_grid_write_test_',num2str(getpref('SNCTOOLS','PRESERVE_FVD')),'_',version('-release'),  '.cdl']);
   pngfile2 = fullfile(fileparts(mfilename('fullpath')),['tests',filesep,'nc_cf_grid_write_test_',num2str(getpref('SNCTOOLS','PRESERVE_FVD')),'_',version('-release'),'rw.png']);

   if getpref('SNCTOOLS','PRESERVE_FVD')==0
      nc_cf_grid_write(ncfile,...
               'lon',permute(G.lon(:,:),  [2 1]),...
               'lat',permute(G.lat(:,:),  [2 1]),...
               'val',permute(G.z(1,:,:),[3 2 1]),...
             'units',GM.z.units,...
           'varname','z',...
         'long_name','z');
   else
      nc_cf_grid_write(ncfile,...
               'lon',permute(G.lon(:,:),  [1 2]),...
               'lat',permute(G.lat(:,:),  [1 2]),...
               'val',permute(G.z(:,:,1),[1 2 3]),...
             'units',GM.z.units,...
           'varname','z',...
         'long_name','z');
   end

%% read grid (local)

   figure('name','grid (local, just written)');
   [G2,GM2] = nc_cf_grid(ncfile,'z');
   fid = fopen(cdlfile,'w');
   nc_dump(ncfile,fid)
   fclose(fid);
   title({char(get(get(gca,'title'),'String')),''}); % add dummy 2nd title 
   text(1,0,version('-release'),'rotation',90,'units','normalized','verticalalignment','top')
   print2screensizeoverwrite(pngfile2)
   