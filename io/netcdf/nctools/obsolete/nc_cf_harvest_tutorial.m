%extract meta-data from dynamic catalog to populate meta-data in static catalog
%
%See also: NC_CF_HARVEST, OPENDAP_CATALOG, ncgentools_generate_catalog

%% GRIDS   
%  This static catalog is hosted at as test at:
%  http://dtvirt5.deltares.nl:8080/thredds/rijkswaterstaat_kustlidar_catalog1.html
   
%   ncdir    = 'http://dtvirt5.deltares.nl:8080/thredds/catalog/opendap/rijkswaterstaat/kustlidar/catalog.html';
%   xmldir   =            'F:\opendap.deltares.nl\thredds\dodsC\opendap\rijkswaterstaat\kustlidar\';
%
%   disp(['Crawling ...',last_subdir(ncdir,1)])
%
%   ncfiles = sort(opendap_catalog(ncdir));
%   M       = nc_cf_harvest(ncfiles,'flat',0);
%   
%   nc_cf_harvest2xml([xmldir,'rijkswaterstaat_kustlidar_catalog1.xml'],M,...
%   'ID'                     ,'rijkswaterstaat/kustlidar',...
%   'name'                   ,'kustlidar',...
%   'publisher.name'         ,'Rijkswaterstaat',...
%   'publisher.contact.url'  ,'http://www.rws.nl',...
%   'publisher.contact.email','info@helpdeskwater.nl',...
%   'dataType'               ,'GRID',...
%   'documentation.summary'  ,'5 x 5 m2 grids of Lidar data',...
%   'documentation.title'    ,'Rijkswaterstaat',...
%   'documentation.url'      ,'http://www.rws.nl/water/scheepvaartberichten_waterdata/monitoring_meetsystemen/')
   
%% TIMESERIES

   D(1).institute               = 'knmi';
   D(1).publisher.name          = 'KNMI';
   D(1).publisher.contact.url   = 'http://www.knmi.nl';
   D(1).publisher.contact.email = '';
   D(1).name                    = 'potwind';
   D(1).documentation.title     = 'hourly wind timeseries';
   D(1).documentation.url       = 'http://www.knmi.nl/klimatologie/onderzoeksgegevens/potentiele_wind/';
   D(1).documentation.summary   = 'platform with meteo time series';

   D(2) = D(1);
   D(2).name                    = 'etmgeg'; 
   D(2).documentation.title     = 'daily atmospheric timeseries';
   D(2).documentation.url       = 'http://www.knmi.nl/klimatologie/daggegevens/download.html';
   D(2).documentation.summary   = 'platform with meteo time series';

   D(3).institute               = 'rijkswaterstaat';
   D(3).publisher.name          = 'RWS';
   D(3).publisher.contact.url   = 'http://www.rws.nl';
   D(3).publisher.contact.email = '';
   D(3).name                    = 'waterbase\concentration_of_suspended_matter_in_water';
   D(3).documentation.title     = 'MWTL surface samples';
   D(3).documentation.url       = 'http://live.waterbase.nl';
   D(3).documentation.summary   = 'platform with oceanographic samples';
   
   D(4) = D(3);
   D(4).name                    = 'vaklodingen';
   D(4).documentation.title     = 'vaklodingen';
   D(4).documentation.url       = 'http://live.rws.nl';
   D(4).documentation.summary   = 'DEM tiles with depth in zone up to 20 m deep at 20 m resolutionb';
   
   for i=1:length(D)
   
      d = D(i);
     %ncdir  = ['http://dtvirt5.deltares.nl:8080/thredds/catalog/opendap/',d.institute,'/',d.name,'/catalog.html'];
      ncdir  =            ['D:\opendap.deltares.nl\thredds\dodsC\opendap\',d.institute,'\',d.name,'\'];
     %xmldir =            ['D:\opendap.deltares.nl\thredds\dodsC\opendap\',d.institute,'\',d.name,'\'];
      xmldir =             'd:\checkouts\OpenEarthTools\configurations\dtvirt5.deltares.nl\thredds\';
      
      %% crawl
      disp(['Crawling   ...',last_subdir(ncdir,1)])
      ncfiles = sort(opendap_catalog(ncdir));
      
      %% harvest
      disp(['Harvesting ...',last_subdir(ncdir,1)])
      M       = nc_cf_harvest(ncfiles,'flat',0);
      
      %% cache harvest as THREDDS catalog.xml
      catalog.xml = [xmldir,d.institute,'_',mkvar(d.name),'_catalog1.xml'];
      nc_cf_harvest2xml(catalog.xml,M,...
      'ID'                     ,[d.institute,'/',path2os(d.name,'http')],...
      'name'                   ,[d.institute,'_',mkvar(d.name)],...
      'publisher.name'         ,d.publisher.name,...
      'publisher.contact.url'  ,d.publisher.contact.url,...
      'publisher.contact.email',d.publisher.contact.email,...
      'dataType'               ,'Station',...
      'documentation.summary'  ,d.documentation.summary,...
      'documentation.title'    ,d.documentation.title,...
      'documentation.url'      ,d.documentation.url)

   end