%KNM_POTWIND2KML   save wind vector timeseries as rotating arrow
%
%See also: googleplot

   url = 'http://opendap.deltares.nl/thredds/dodsC/opendap/knmi/potwind/potwind_225.nc';
   
   D.datenum      = nc_cf_time(url);
   D.institution  = nc_attget (url,nc_global,'institution');
   D.station_name = nc_varget (url,'station_name');
   D.station_id   = nc_varget (url,'station_id');
   D.lon          = nc_varget (url,'lon');
   D.lat          = nc_varget (url,'lat');
   D.U            = nc_varget (url,'wind_speed');
   D.deg          = degN2deguc(nc_varget(url,'wind_from_direction'));
   
   D.u = D.U.*cos(D.deg);
   D.v = D.U.*sin(D.deg);
   
   % TO DO correct for angle between RD epsg:28992 and wgs84 lat/lon !!!

   m     = ':'; % length(D.u)-5000:length(D.u); % 5000 times = 5 Mb for blackTip, 2.5 Mb for line
   scale = 1e3;

   KMLquiver( repmat(D.lat,size(D.u(m))),...
              repmat(D.lon,size(D.u(m))),...
              D.v(m).*scale,... % v
              D.u(m).*scale,... % u
            'fileName',[filename(url),'.kmz'],...
             'kmlName',[D.institution,' wind in ',D.station_name,' (',num2str(D.station_id),')'],...
          'arrowStyle','line',...
                  'W2',.2,...
                  'W3',.2,...
            'openInGE',1,...
              'timeIn',D.datenum(m),...
             'timeOut',D.datenum(m) + [diff(D.datenum(m)); 0]);

