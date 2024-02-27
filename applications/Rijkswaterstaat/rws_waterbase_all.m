function rws_waterbase_all
%RWS_WATERBASE_ALL    download waterbase.nl parameters from web, transform to netCDF, make kml,  make catalog.
%
%See also: KNMI_ALL, NC_CF_HARVEST, RWS_WATERBASE_*

% TO DO: merge kmls for al substances
% TO DO: move only identical DONAR ID to old

%% Initialize

   OPT.download       = 0; % get fresh downloads from rws and move exisitng to sub dir old
   OPT.make_nc        = 0; % makes also temporary mat files, moves exisiting nc to old subdir
   OPT.make_catalog   = 0; % otherwise load existing one
   OPT.make_kml       = 1; % processing all kml only takas about 4 hours
   OPT.baseurl        = 'http://live.waterbase.nl';
   OPT.institution    = 'rijkswaterstaat'; % for construcitng relative path
   OPT.dataset        = 'waterbase';       % for construcitng relative path
   OPT.directory_xml  = 'd:\checkouts\OpenEarthTools\configurations\dtvirt5.deltares.nl\'; % for static THREDDS catalogs in folder tomcat6/content/thredds

   %rawbase = '/Users/fedorbaart/Downloads/rws/raw/';% @ local, change this for your own computer
    %ncbase = '/Users/fedorbaart/Downloads/rws/nc/'; % @ local, change this for your own computer
   %kmlbase = '/Users/fedorbaart/Downloads/rws/kml/';% @ local, change this... no links to other kml or images any more

   rawbase =              'd:\checkouts\OpenEarthRawData\';       % @ local
    ncbase =     'D:\opendap.deltares.nl\thredds\dodsC\opendap\'; % @ local
   urlbase = 'http://opendap.deltares.nl/thredds/dodsC/opendap/'; % @ server
   kmlbase =                               'D:\kml.deltares.nl\'; % @ local

%% Parameter choice: select DONAR code or
%  0=all or select number from 'donar_wnsnum' column in rws_waterbase_name2standard_name.xls
%  DO get 1 always after 54 to make sure catalog and kml of 1 contains 54 as well.

   donar_wnsnum = [ 559   44  282  410  209  ... %    sal   T Chl SPM pO2
                     29   54   22   23   24  ... %      Q eta  Hs dir  Tm 
                    332  346  347  360  363  ... %    KjN   N   N  O2 PO4
                    364  380  491  492  493  ... %      P P04 NH4 N02 N03
                    541  560 1083    1  377  ... %    DSe  Si DOC zwl  pH
                   1238  713 1082  401       ];  % NO3NO2  E  POC TOC
   donar_wnsnum = [282] %1082 Use this if you want only an update of one some specific parameter.
   
   mfilename('fullpath')
   DONAR = xls2struct([fileparts(mfilename('fullpath')) filesep 'rws_waterbase_name2standard_name.xls']);

   if  donar_wnsnum==0
       donar_wnsnum = DONAR.donar_wnsnum;
   end
   
   multiWaitbar(mfilename,0,'label','Looping substances.','color',[0.3 0.8 0.3])

%% Parameter loop

   n = 0;
   for ivar=[donar_wnsnum]
   n = n+1;

      disp(['Processing donar_wnsnum: ',num2str(ivar)])
      
      index = find(DONAR.donar_wnsnum==ivar);

      OPT.code              = DONAR.donar_wnsnum(index);
      OPT.donar_wnsnum      = DONAR.donar_wnsnum(index);  % needed for url
      OPT.donar_wns_oms     = DONAR.donar_wns_oms{index}; % needed for url
      OPT.donar_parcode     = DONAR.donar_parcode{index}; % needed for disp
      OPT.name              = DONAR.name{index};          % needed for directory

      subdir                = OPT.name;
      OPT.directory_nc      = fullfile( ncbase,OPT.institution,OPT.dataset,subdir,filesep);
      OPT.directory_kml     = fullfile(kmlbase,OPT.institution,OPT.dataset,filesep);
      OPT.directory_raw     = fullfile(rawbase,OPT.institution,OPT.dataset,'cache',subdir,filesep);
      
      multiWaitbar(mfilename,n/length(donar_wnsnum),'label',['Processing substance: ',OPT.donar_parcode,' (',num2str(ivar),')'])

%% Download from waterbase.nl
   
   if OPT.download
      rws_waterbase_get_url_loop('donar_wnsnum' ,OPT.code,...
                                 'directory_raw',OPT.directory_raw,...
                             'directory_raw_old',[OPT.directory_raw filesep 'old'],...
                                       'cleanup',1); % remove date from file name > version control on cached download too ?
                                 
   end
   
%% Read raw, cache as *.mat and make netCDF
   
   if OPT.make_nc
   
      if any(OPT.code==[1 54 29 22 23 24]) % physical parameters have long time series: waterlevels(1 54), Q(29) or waves(22 23 24)
         OPT.method='fgetl';
      else
         OPT.method='textread';
      end
      
%% TO DO: copy exisitng nc files to \OLD
   
      rws_waterbase2nc('donar_wnsnum' ,OPT.code,...
                       'directory_nc' ,OPT.directory_nc,...
                       'directory_raw',OPT.directory_raw,...
                              'method',OPT.method,... % 'fgetl' for water levels or discharges
                            'att_name',{},...
                             'att_val',{},...
                                'load',1,...% 1 = skip cached mat file, always load zipped txt file
                               'debug',0,...% check unit conversion and more
                                'mask',['id' num2str(OPT.code) '*.zip']);  % as more ids are in same dir
   end

%% Make catalog.nc (and write human readable subset to catalog.xls)
%  make sure urlPath alreayd links to place where we are going to put them.
%  so we can copy catalog.nc together with the other nc files.
%  For making kml below we use local still files !
%  Idea: make a special *_local_machine catalog? Be aware this causes
%  catalog to contain non-expected files.

   if OPT.make_catalog
   CATALOG = nc_cf_harvest(OPT.directory_nc,...             % dir where to READ netcdf
                    'featuretype','timeseries',...
                          'debug',[],...
                     'catalog.nc',[OPT.directory_nc ,'catalog.nc'],...  % dir where to SAVE catalog
                    'catalog.xml',[OPT.directory_xml,OPT.institution,'_',mkvar(OPT.dataset),'_',subdir,'.xml'],... % dir where to SAVE catalog
                    'catalog.xls',[OPT.directory_nc ,'catalog.xls'],... % dir where to SAVE catalog
                    'catalog.mat',[OPT.directory_nc ,'catalog.mat'],... % dir where to SAVE catalog
                     'urlPathFcn',@(s) path2os(strrep(s,ncbase,urlbase),'h'),... % dir where to LINK to for netCDF
                           'disp','multiWaitbar',...
                             'ID',[OPT.institution,'/',mkvar(OPT.dataset),'/',subdir],...
                           'name',[OPT.institution,'_',mkvar(OPT.dataset),'_',subdir]);
   end

%% Make KML overview with links to netCDFs on http://opendap.deltares.nl THREDDS
      
   if OPT.make_kml
      if (~OPT.make_catalog)
        CATALOG = nc2struct([OPT.directory_nc,'catalog.nc']);
      end

      OPT2.fileName           = [OPT.directory_kml,filesep,subdir,'.kml'];
      OPT2.kmlName            = ['Rijkswaterstaat time series ' subdir];
      OPT2.text               = {['<B>',OPT.name,'</B>']};

     %OPT2.iconnormalState    = 'http://maps.google.com/mapfiles/kml/shapes/placemark_square.png';
     %OPT2.iconhighlightState = 'http://www.rijkswaterstaat.nl/images/favicon.ico';
     %OPT2.description        = {['data: Rijkswaterstaat (http://www.rws.nl) via (',OPT.baseurl,'), presentation: http://www.OpenEarth.eu']};
      OPT2.description        = ['<hr> This is a proof-of-concept demo of how time series of the MWTL monitoring '...
                                 'data from Rijkswaterstaat could be presented in Google Earth for easy navigation in time space. '...
                                 'For documentation on this demo and all sources material please refer to the <a href="https://publicwiki.deltares.nl/display/OET/Dataset+documentation+MWTL">OpenEarth wiki</a>.'...
                                 'The data in this proof-of-concept demo is a cache that is updated a few times per year. For up-to-date'...
                                 'data and meta-data please visit the original source provided by Rijkswaterstaat: <a href="http://live.waterbase.nl">waterbase</a>.'....
                                 '<hr><table bgcolor="#333333" cellpadding="3" cellspacing="1"><tbody><tr><td colspan="2" bgcolor="#666666"><div style="color:#FFFFFF;">Credits:</div></td></tr>',...
	                             '<tr><td    bgcolor="#FFFFFF">data source     </td><td bgcolor="#FFFFFF">Rijkswaterstaat</td></tr>',...
	                             '<tr><td    bgcolor="#FFFFFF">data source url </td><td bgcolor="#FFFFFF">http://www.rws.nl</td></tr>',...
	                             '<tr><td    bgcolor="#FFFFFF">data provider   </td><td bgcolor="#FFFFFF">',OPT.baseurl,'</td>',...
	                             '<tr><td    bgcolor="#FFFFFF">data distributor</td><td bgcolor="#FFFFFF">http://www.OpenEarth.eu</td>',...
	                             '</tr></tbody></table><hr>',...
                                 '<p><font size="1" face="courier" color="gray">$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/rws_waterbase_all.m $ $Id: rws_waterbase_all.m 10463 2014-03-28 09:16:25Z boer_g $</font></p>'];
      
      OPT2.lon                = 1;
      OPT2.lat                = 54;
      OPT2.z                  = 100e4;
      
      OPT2.logokmlName        = {}; %{'Rijkswaterstaat logo','OpenEarth logo'};
      OPT2.overlayXY          = {[.5 1],[0    0.00]};
      OPT2.screenXY           = {[.5 1],[0.01 0.03]};
      OPT2.imName             = {'http://www.rws.nl/en/images/ENRO_VW_RW~LI.png',[fileparts(oetlogo),filesep,'OpenEarth-logo-blurred-white-background4kml.png'];};
      OPT2.logoName           = {'overheid4GE.png','OpenEarth-logo-blurred-white-background4GE.png'};
      
      OPT2.varPathFcn         = @(s) path2os(strrep(s,urlbase,ncbase),filesep); % use local netCDF files for preview/statistics when CATALOG refers already to server
      OPT2.resolveUrl         = cellfun(@(x) ['http://live.waterbase.nl/waterbase_dbh.cfm?loc=',upper(x),'&page=start.locaties.databeschikbaarheid&taal=nl&loc=&wbwns=',num2str(OPT.donar_wnsnum),'|',strtrim(strrep(OPT.donar_wns_oms,' ','+')),'&whichform=2'],CATALOG.platform_id,'un',0);
      OPT2.resolveName        = 'www.rws.nl (waterbase)';

      OPT2.iconnormalStateScale    = 1;
      OPT2.iconhighlightStateScale = 1;   
      OPT2.iconnormalState    = 'http://www.ndbc.noaa.gov//images/maps/markers/tiny_active_marker.png';
      OPT2.iconhighlightState = 'http://www.ndbc.noaa.gov//images/maps/markers/tiny_active_marker.png';

      OPT2.credit             = ' data: www.rws.nl plot: www.OpenEarth.eu';
      OPT2.varname            = subdir;
      OPT2.name               = OPT.name;
      OPT2.preview            = 1;
      OPT2.open               = 0; % too slow
      
      nc_cf_harvest_matrix2kml(CATALOG,OPT2); % inside urlPath is used to read netCDF data for plotting previews
      
      close all
      
   end  
      
end

multiWaitbar(mfilename,1,'label','Looping substances.')

