%% nc_cf_timeseries_TUTORIAL  how to read and subset a netCDF time series file
%
%
%See also: SNCTOOLS, nc_cf_timeseries,...
%          NC_CF_GRID_TUTORIAL,...
%          nc_cf_timeseries_WRITE_TUTORIAL
%          pg_stationTimeSeries_tutorial

%% subset > 100 year Rijkswaterstaat time series at Hoek van Holland
%  The full timeseries (15MB) is a bit slow to handle via OPeNDAP.

   D.url     = 'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/waterbase/sea_surface_height/id1-TERNZN.nc';
   nc_dump(D.url)

%% Determine indices of subset based on the the subregion you want 

   OPT.datenum   = datenum(1953,1,30 + [0 5]);% datestr(OPT.datenum)

%% Because the time series is rather big, getting the full time vector to determine
%  the indices we want takes rather long.
%  Get full coordinate sticks 
%
%   D.datenum     = nc_cf_time(D.url,'time');
%   ind.datenum   = find(D.datenum > OPT.datenum(1) & D.datenum < OPT.datenum(2));
%   D.datenum     = D.datenum(ind.datenum);
%   
%  In fact, this approach gets already 50% of the whole file. 
%  Therefore we made a special query function that downloads
%  only the times you need without downloading the whole time vector.

  [D.datenum,start,count]  = nc_varget_range(D.url,'time',OPT.datenum);

%% get subset
%  note: nc_varget is zero-based
%  note: the 1D timeseries has two dimensions, 1st dimension is dummy

   D.z           = nc_varget(D.url,'sea_surface_height' ,[0 start],[1 count]);
   M.z.units     = nc_attget(D.url,'sea_surface_height','units');
   M.z.long_name = nc_attget(D.url,'sea_surface_height','long_name');

%% plot

   plot(D.datenum,D.z);
   datetick('x')
   grid on
   ylabel([M.z.long_name,' [',M.z.units,']'])
   print('-dpng',['Hoek_van_Holland_time_',datestr(OPT.datenum(1)),'_',datestr(OPT.datenum(2))])
   
%% This 15 Mb dataset could also be loaded as a whole at once using a dedicated function

   figure
   nc_cf_timeseries(D.url,'sea_surface_height','plot',1);
   
