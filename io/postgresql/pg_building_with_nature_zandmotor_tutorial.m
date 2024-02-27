%PG_ZANDMOTOR_TUTORIAL  extract all tables with all columns into one struct
%
% You cna request a dump without data of the BwN/Zandmotor
% database. This dump contains all meta-data tables.
% This tutorial loads all those tables into one struct
% if the table is shorter then a specified criterion.
%
%See also: postgresql, netcdf

OPT.host   = 'localhost';
OPT.db     = 'BWN';
OPT.schema = 'public';                            % 'imares';
OPT.user   = '';
OPT.pass   = '';

OPT.host   = 'postgresx03.infra.xtr.deltares.nl'; % 'localhost';
OPT.db     = 'PMR';                               % 'zandmotor'; % 'PMR';
OPT.schema = 'public';                            % 'imares';
OPT.user   = '';
OPT.pass   = '';

%% connect

   if ~(pg_settings('check',1)==1)
      pg_settings
   end
   if isempty(OPT.user)
   [OPT.user,OPT.pass] = pg_credentials(OPT.host,OPT.db); % this function is not in OET ;-)
   end
   
   conn=pg_connectdb(OPT.db,'host',OPT.host,'user',OPT.user,'pass',OPT.pass,'schema',OPT.schema);

%% List all table names, but exclude PostGIS tables 'geometry_columns' & 'spatial_ref_sys'
%  exclude 'observation' for filled databases!!

   tables  = {... % 'failed_location', 'geometry_columns'
               'location','method','observation','observation_type','parameter',...
               'parameter_hilucs','parameter_physical','parameter_sediment','parameter_worms',...
               'quality','unit',... % 'spatial_ref_sys'
               'value_age_class','value_broken','value_length_class'};
   tables = {'location'};  
   
   for i=1:length(tables)
      table = tables{i};
      pg_dump(conn,table)
      disp('loading ...')
      D.(table) = pg_table2struct(conn,table,[],52000);
   end
   
%% parse geometry objects

   n = length(D.location.idlocation);
   D.location.x = repmat(nan,[n 1]);
   D.location.y = repmat(nan,[n 1]);
   for i=1:n
     if mod(i,500)==0;disp([num2str(i/n*100),'%']);end
     [~,~,D.location.x(i),D.location.y(i)] = pg_ewkb(D.location.thegeometry{i});
   end   
   
%% plot in matlab

   plot(D.location.x,D.location.y,'r.')
   hold on
   axis([2.5 7 51 54])
   axislat
   tickmap('ll')
   grid on
   L = nc2struct('http://opendap.deltares.nl/thredds/dodsC/opendap/noaa/gshhs/gshhs_h.nc','include',{'lon','lat'})
   plot(L.lon,L.lat,'k')   
   
%% plot locations in Google Earth

   KMLscatter(D.location.y,D.location.x,D.location.x.*0,'fileName',[OPT.db,'.kml'])
