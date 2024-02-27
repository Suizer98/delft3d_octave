%Extract subset of grid data from set of time-depdendent tiles
%
% This example extract data for a orthogonal grid.
%
%See also: NC_CF_GRIDSET_GETDATA, GRID_2D_ORTHOGONAL

%% Specify what you want

   D.filename    = 'Vlie_basin_example.asc';
   
  [D.x,D.y]      = meshgrid( 92080:80:219980,... % 20m = 250 Mb each, 80m = 14Mb, 100m = 9Mb each
                            537500:80:624980);   % define the grid where you want data, in [m]. This does not have to be a an orthogonal grid.
   D.data_url    = 'http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/kustlidar/catalog.html';

   %% get tile names where to get data from
   %  You only do this only once,
   % the 2nd time use only relevant subset of files: much faster
   D.data_files  = opendap_catalog(D.data_url);

  %D.data_files  = {'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen_remapped/vaklodingenKB124_1716.nc',...
  %                 'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen_remapped/vaklodingenKB124_1514.nc',...
  %                 'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen_remapped/vaklodingenKB123_1716.nc',...
  %                 'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen_remapped/vaklodingenKB123_1514.nc',...
  %                 'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen_remapped/vaklodingenKB122_1716.nc',...
  %                 'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen_remapped/vaklodingenKB122_1514.nc'}
   
   D.t0          = datenum(2004,1,1); % we want data from ABOUT this time, with ...
   D.dtmax       = 8*366;             % ... max 8 years time offset and ...
   D.order       = '|nearest|';       % ... only older data (not forward)

%% Get data           

   [D.z,D.t,D.fi,D.fn] = nc_cf_gridset_getData(D.x,D.y,'bathy',D.data_files,...
                                  'datenum',D.t0,...
                              'ddatenummax',D.dtmax,...
                                    'order',D.order,...
                                    'disp',11);
%% Get North Sea 'shapefile'

   L.x = nc_varget('http://opendap.deltares.nl/thredds/dodsC/opendap/deltares/landboundaries/northsea.nc','x');
   L.y = nc_varget('http://opendap.deltares.nl/thredds/dodsC/opendap/deltares/landboundaries/northsea.nc','y');

%% Plot data

   subplot(1,2,1)
   pcolorcorcen(D.x,D.y,D.z);
   axis equal
   colorbar
   title('depth [m]');
   axis(axis); % fix axis around data
   hold on
   plot(L.x,L.y,'k')
   tickmap('xy')
   
%% Plot time stamp of each data point

   subplot(1,2,2)
   v  = unique(D.t(find(~isnan(D.t))));
   nv = length(v);
   D.mask = D.t;
   for iv=1:nv
      D.mask(D.t==v(iv))=iv;
   end
   pcolorcorcen(D.x,D.y,D.mask);
   axis equal
   if nv > 0
   caxis   ([1-.5 nv+.5])
   colormap(jet(nv));
   [ax,c1] =  colorbarwithvtext('timestamp',1:nv+1);
   set(ax,'yticklabel',datestr(v,29))
   end
   axis(axis); % fix axis around data
   hold on
   plot(L.x,L.y,'k')
   tickmap('xy')
   
   %print2screensize([D.filename,'.png'])

%% save
   %arcgridwrite(D.filename,D.x,D.y,D.z)