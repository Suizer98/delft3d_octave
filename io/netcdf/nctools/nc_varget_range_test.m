function OK = nc_varget_range_test
%NC_VARGET_RANGE_TEST   test for nc_varget_range
%
%See also: nc_varget_range, nc_cf_time_range

%% subset orthogonal Smith & Sandwell worldbathymetric data for DCSM region
%  The full grid is way too large too handle so we need to subset

   D.url     = 'http://coast-enviro.er.usgs.gov/thredds/dodsC/bathy/smith_sandwell_v11';

   OPT.lon       = [-4 10];
   OPT.lat       = [48 58];

%% with full coordinate sticks 

tic

   D.lon          = nc_varget (D.url,'lon'); % -180 ... 180
   D.lat          = nc_varget (D.url,'lat'); %   90 ... -90

   ind1.lon       = find(D.lon > OPT.lon(1) & D.lon < OPT.lon(2) | D.lon > OPT.lon(1)+360 & D.lon < OPT.lon(2)+360);
   ind1.lat       = find(D.lat > OPT.lat(1) & D.lat < OPT.lat(2));
   
   D1.lon         = D.lon(ind1.lon);
   D1.lat         = D.lat(ind1.lat);
   
toc % Elapsed time is 2.559636 seconds.

%% with remote subset

tic

  [D2.lon,ind2.lon]      = nc_varget_range(D.url,'lon',OPT.lon,'chunksize',Inf); % chunksize < Inf is actually SLOWER!
  [D2.lat,ind2.lat]      = nc_varget_range(D.url,'lat',OPT.lat,'chunksize',Inf);
  
toc % Elapsed time is 4.307951 seconds.

OK = isequal(ind1.lon(:),ind2.lon(:)) && isequal(ind1.lat(:),ind2.lat(:));

