%OPENDAP_SELECT_EXAMPLE  example how to subset select data using catalog.nc
%
% How to benefit from a catalog.nc crawled/harvested 
% with nc_cf_opendap2catalog to select a subset of netCDF files.
%
%See also: opendap, polydraw, nc_cf_opendap2catalog

%% define box in space-time

   OPT.datenum = datenum([2004 2010],1,1);
   OPT.lon     = [] ; %[ 4 4.5 4.5 5 4 4]; % define polygon here, when empty you can draw one
   OPT.lat     =  []; %[52 52 52.5 53 53 52]; % define polygon here, when empty you can draw one
   OPT.catalog = 'f:\opendap/rijkswaterstaat/waterbase/turbidity/catalog.nc'; % obtained via opendap_get_cache
   OPT.catalog = 'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/waterbase/turbidity/catalog.nc';
   
%% load catalog (no data yet)

  %catalog = nc2struct(OPT.catalog);
   
   catalog.urlPath                       = cellstr(nc_varget(OPT.catalog,'urlPath'));
   catalog.datenum_end                   = nc_varget(OPT.catalog,'datenum_end');
   catalog.datenum_start                 = nc_varget(OPT.catalog,'datenum_start');
   catalog.geospatialCoverage_northsouth = nc_varget(OPT.catalog,'geospatialCoverage_northsouth');
   catalog.geospatialCoverage_eastwest   = nc_varget(OPT.catalog,'geospatialCoverage_eastwest');
   
%% plot selection

   L = nc2struct('http://opendap.deltares.nl/thredds/dodsC/opendap/noaa/gshhs/gshhs_i.nc');
   TMP = figure;
   plot(catalog.geospatialCoverage_eastwest,catalog.geospatialCoverage_northsouth,'k.')
   axislat
   tickmap('ll')
   hold on
   axis(axis)
   plot(L.lon,L.lat,'color',[.5 .5 .5])
   
   if isempty(OPT.lon) | isempty(OPT.lat)
       disp('Draw closed polygon for selection [right mouse button when done].')
       [OPT.lon,OPT.lat] = polydraw
   end

%% find the stations you want
%  this only applies if you want a small subset
%  if you want a large subsets, you might just as well load everything
%  with opendap_get_cache
   
   mask = logical(zeros(length(catalog.urlPath),1));
   n    = 0;
   for i=1:length(catalog.urlPath)
      if any(~(catalog.datenum_end(i)   < OPT.datenum(1)) |...
             ~(catalog.datenum_start(i)                 > OPT.datenum(2))) & ...
             inpolygon(catalog.geospatialCoverage_eastwest(i),...
                       catalog.geospatialCoverage_northsouth(i),...
                       OPT.lon,OPT.lat); % use inpolygon here for better selection
      n = n +1;
      disp(['searched ',num2str(i),' loaded: ',num2str(n)])
      mask(i)=1;          
      end
   end
   
   plot(OPT.lon,OPT.lat,'r')
   h = plot(catalog.geospatialCoverage_eastwest(mask,1),catalog.geospatialCoverage_northsouth(mask,1),'ro');
   
   pausedisp

%% load chosen subset

   n = sum(mask);
   ind = find(mask);
   D = nc2struct(catalog.urlPath{ind(1)});
   for i=2:n
      disp(['searched ',num2str(i),' = ',num2str(100.*(i/n))])
   D(i) = nc2struct(catalog.urlPath{ind(i)});
   end
   
%% check coordinates of chosen subset

   delete(h)
   plot([D.lon],[D.lat],'o')
