function OK = nc_cf_time_range_test
%NC_CF_TIME_RANGE_TEST  test for nc_cf_time_range
%
%See also: nc_varget_range, nc_cf_time_range

ncfile = 'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/waterbase/sea_surface_height/id1-DENHDR.nc'; % empty in request range
ncfile = 'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/waterbase/sea_surface_height/id1-TERNZN.nc';

OPT.datenum   = datenum(1953,1,30 + [0 5]);% datestr(OPT.datenum)
OPT.plot      = 0;

%% get full time series: order  5.0 seconds.

   tic
   D = nc_cf_timeseries(ncfile,'sea_surface_height','plot',OPT.plot);
   S0.datenum   = find(D.datenum > OPT.datenum(1) & D.datenum < OPT.datenum(2));
   toc

%% subset time series: order 0.5 seconds.

   tic
   [S.datenum,S.ind] = nc_cf_time_range(ncfile,'time',OPT.datenum)
   if ~isempty(S.ind)
    S.sea_surface_height   = nc_varget(ncfile,'sea_surface_height',[0 S.ind(1)-1],[1 length(S.ind)]);
    if OPT.plot
     hold on
     plot(S.datenum,S.sea_surface_height,'r:')
    end
   end
   toc

%% subset time series: order 0.5 seconds.
   clear S
   tic
   [S.datenum,start,count] = nc_cf_time_range(ncfile,'time',OPT.datenum);
   if ~isempty(start)
    S.sea_surface_height   = nc_varget(ncfile,'sea_surface_height',[0 start],[1 count]);
    toc
    if OPT.plot
     plot(S.datenum,S.sea_surface_height,'g.')
     xlim(OPT.datenum)
    end
   end

%% assess

   % datestr(S.datenum)
   % datestr(D.datenum(ind.datenum))

   OK = isequal(S.datenum,S.datenum);