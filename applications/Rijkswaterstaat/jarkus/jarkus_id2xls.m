function jarkus_id2xls(id)
%JARKUS_ID2XLS  extract all years from JarKus transect and saves as Excel file
%
%  jarkus_id2xls(id) where id is area_number*1e6 + strandpaal number.
%
% The area numbers are defined in JARKUS_DEFINITION.
%
%See also: jarkus, jarkus_definition

%% load data

   T = jarkus_transects('id', id);
   [T.lon,T.lat,logs]=convertCoordinates(T.x,T.y,'CS1.code',28992,'CS2.code',4326);
   dtnm = nc_cf_time(jarkus_url);

%% split 2D time-space matrix into an Excel column per year

   flds = fieldnames(T);
   
   for i=1:length(flds)
       if nc_isvar(jarkus_url,flds{i});
           if nc_isatt(jarkus_url,flds{i},'units');
               units.(flds{i}) = nc_attget(jarkus_url,flds{i},'units');
           else
               units.(flds{i}) = '';
           end
       end
   end

   T.altitude = permute(T.altitude,[1 3 2]);
   for it=length(T.time):-1:1
      fld         = ['altitude_',datestr(dtnm(it),'yyyy')];
      T.(fld)     = T.altitude(it,:);
      units.(fld) = units.altitude;
   end
   
%% make preview

   pcolorcorcen(T.cross_shore,dtnm,T.altitude)
   datetick('y')
   colorbarwithtitle('altitude [m]')
   set(gca,'xDir','reverse')
   grid on
   print2screensize([num2str(id),'_preview'])
   
%% save to excel

   T = rmfield(T,'time');
   T = rmfield(T,'altitude');

   OPT.header = ['source: ',jarkus_url,...
                 '. Date:',datestr(now),...
                 '. Data: Rijkswaterstaat.nl',...
                 '. Dissemination: OpenEarth.eu',...
                 '. History: ',nc_attget(jarkus_url,nc_global,'history')];
             
   struct2xls([num2str(id),'.xls'],T,'units',units,'header',OPT.header);
