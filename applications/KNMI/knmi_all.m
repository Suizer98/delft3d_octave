function knmi_all
%KNMI_ALL    download potwind + etmgeg from web, transform to netCDF, make kml,  make catalog.
%
%See also: KNMI_POTWIND_GET_URL, KNMI_ETMGEG_GET_URL, KNMI_UURGEG_GET_URL
%          KNMI_POTWIND2NC,      KNMI_ETMGEG2NC,      KNMI_UURGEG2NC
%          RWS_WATERBASE_ALL, NC_CF_HARVEST, http://data.knmi.nl

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id: knmi_all.m 9897 2013-12-17 17:12:27Z santinel $
% $Date: 2013-12-18 01:12:27 +0800 (Wed, 18 Dec 2013) $
% $Author: santinel $
% $Revision: 9897 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/KNMI/knmi_all.m $
% $Keywords: $

   clear all
   close all

% TO DO: merge kmls for al substances

%% Initialize

   OPT.download             = 1; % get fresh downloads
   OPT.make_nc              = 1;
   OPT.make_catalog         = 1; % loading a cached one does not work at the moment
   OPT.make_kml             = 1;
   OPT.institution    = 'knmi'; % for construcitng relative path
   OPT.directory_xml  = 'D:\OpenEarthTools\configurations\dtvirt5.deltares.nl\'; % for static THREDDS catalogs in folder tomcat6/content/thredds

   rawbase =              'D:\OpenEarthRawData\';       % @ local
    ncbase =     'D:\opendap.deltares.nl\thredds\dodsC\opendap\'; % @ local
   urlbase = 'http://opendap.deltares.nl/thredds/dodsC/opendap/'; % @ server
   kmlbase =                               'D:\kml.deltares.nl\'; % @ local   

   preview     = [1 0 0];
   subdirs     = {'potwind','etmgeg','uurgeg'}; % take 9 and 14 mins respectively
   varnames    = {'wind_speed','air_temperature_mean','air_temperature_mean'};
   resolveUrls = {'http://www.knmi.nl/klimatologie/onderzoeksgegevens/potentiele_wind/',...
                  'http://www.knmi.nl/klimatologie/daggegevens/download.html',...
                  'http://www.knmi.nl/klimatologie/uurgegevens/'};
   
   resolveTitles    = {'KNMI potwind','KNMI etmgeg','KNMI uurgeg'};
   resolveSummaries = {'Potential wind (potwind)','Daily mean quantities (etmgeg)','Hourly quantities (uurgeg)'};

   multiWaitbar(mfilename,0,'label','Looping substances.','color',[0.3 0.8 0.3])

%% Parameter loop

n = 0;
for ii=1:length(subdirs)
n = n+1;
   
   subdir                = subdirs{ii};

   disp(['Processing ',num2str(ii),' / ',num2str(length(subdirs)),': '   ,subdirs{ii}])
      
   OPT.directory_nc      = [ ncbase,'\knmi\',filesep,subdir,filesep];
   OPT.directory_kml     = [kmlbase,'\knmi\',filesep,];
   OPT.directory_raw     = [rawbase,'\knmi\',filesep,subdir,filesep,'raw',filesep];
   
   multiWaitbar(mfilename,n/length(subdirs),'label',['Processing substance: ',num2str(ii)])

%% Download from waterbase.nl and make netCDF

   if strcmpi(subdir,'potwind')
   
   KNMI_potwind_get_url        ('download'       , OPT.download,...
                                'directory_raw'  , OPT.directory_raw,...
                                'directory_nc'   , OPT.directory_nc,...
                                'nc'             , OPT.make_nc)
   elseif strcmpi(subdir,'etmgeg')
   
   KNMI_etmgeg_get_url         ('download'       , OPT.download,...
                                'directory_raw'  , OPT.directory_raw,...
                                'directory_nc'   , OPT.directory_nc,...
                                'nc'             , OPT.make_nc)
   elseif strcmpi(subdir,'uurgeg')
   
   KNMI_uurgeg_get_url         ('download'       , OPT.download,...
                                'directory_raw'  , OPT.directory_raw,...
                                'directory_nc'   , OPT.directory_nc,...
                                'nc'             , OPT.make_nc)
   else
       error('unknown subdir')
   end


%% Make catalog.nc (and write human readable subset to catalog.xls)
%  make sure urlPath alreayd links to place where we are going to put them.
%  so we can copy catalog.nc together with the other nc files.
%  For making kml below we use local still files !
%  Idea: make a special *_local_machine catalog?

   if OPT.make_catalog

   OPT.documentation.url       = resolveUrls{ii};
   OPT.documentation.title     = resolveTitles{ii};
   OPT.documentation.summary   = resolveSummaries{ii};
   
   if ~exist(OPT.directory_nc,'dir'); mkdir(OPT.directory_nc); end
   
   CATALOG = nc_cf_harvest(OPT.directory_nc,...             % dir where to READ netcdf
                    'featuretype','timeseries',...
                          'debug',[],...
                     'catalog.nc',[OPT.directory_nc ,'catalog.nc'],...  % dir where to SAVE catalog
                    'catalog.xml',[OPT.directory_xml,OPT.institution,'_',subdir,'.xml'],... % dir where to SAVE catalog
                    'catalog.xls',[OPT.directory_nc ,'catalog.xls'],... % dir where to SAVE catalog
                    'catalog.mat',[OPT.directory_nc ,'catalog.mat'],... % dir where to SAVE catalog
                     'urlPathFcn',@(s) path2os(strrep(s,ncbase,urlbase),'h'),... % dir where to LINK to for netCDF
                           'disp','multiWaitbar',...
                             'ID',[OPT.institution,'/',subdir],...
                           'name',[OPT.institution,'_',subdir],...
                  'documentation',OPT.documentation);
   end
      
%% Make KML overview with links to netCDFs on http://opendap.deltares.nl THREDDS

%  TO DO loop over varnames inside netCDF files (etmgeg)

   if OPT.make_kml
      
      if ~exist(OPT.directory_kml,'dir'); mkdir(OPT.directory_kml); end

      if (~OPT.make_catalog)
        CATALOG = nc2struct([OPT.directory_nc,'catalog.nc']);
      end
      OPT2.fileName           = [OPT.directory_kml,filesep,subdir,'.kml'];
      OPT2.kmlName            = ['KNMI time series: ' subdir];
      OPT2.text               = {['<B>',subdir,'</B>']};

     %OPT2.iconnormalState    = 'http://maps.google.com/mapfiles/kml/shapes/placemark_square.png';
     %OPT2.iconhighlightState = 'http://www.rijkswaterstaat.nl/images/favicon.ico';
     %OPT2.description        = ['parameter: ',subdir,'source: <a href="http://www.knmi.nl">KNMI</a>'];
      OPT2.description        = ['<hr> This is a proof-of-concept demo of how wind time series from '...
                                 'KNMI could be presented in Google Earth for easy navigation in time space. '...
                                 'The data in this proof-of-concept demo is a cache that is updated a few times per year. For up-to-date '...
                                 'data and meta-data please visit the original source provided by <a href="http://www.knmi.nl/">KNMI</a>.'....
                                 '<hr><table bgcolor="#333333" cellpadding="3" cellspacing="1"><tbody><tr><td colspan="2" bgcolor="#666666"><div style="color:#FFFFFF;">Credits:</div></td></tr>',...
	                             '<tr><td    bgcolor="#FFFFFF">data source     </td><td bgcolor="#FFFFFF">KNMI</td></tr>',...
	                             '<tr><td    bgcolor="#FFFFFF">data source url </td><td bgcolor="#FFFFFF">http://www.KNMI.nl</td></tr>',...
	                             '<tr><td    bgcolor="#FFFFFF">data provider   </td><td bgcolor="#FFFFFF">',resolveUrls{ii},'</td>',...
	                             '<tr><td    bgcolor="#FFFFFF">data distributor</td><td bgcolor="#FFFFFF">http://www.OpenEarth.eu</td>',...
	                             '</tr></tbody></table><hr>',...
                                 '<p><font size="1" face="courier" color="gray">$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/KNMI/knmi_all.m $ $Id: knmi_all.m 9897 2013-12-17 17:12:27Z santinel $</font></p>'];
      OPT2.lon                = 1;
      OPT2.lat                = 54;
      OPT2.z                  = 100e4;
      
      OPT2.logokmlName        = {'Overheids logo','OpenEarth logo'};
      OPT2.overlayXY          = {[.5 1],[0 0.00]};
      OPT2.screenXY           = {[.5 1],[0 0.03]};
      OPT2.imName             = {'http://www.knmi.nl/images/logo_knmi_venw_engels.png',[fileparts(oetlogo),filesep,'OpenEarth-logo-blurred-white-background4kml.png'];};
      OPT2.logoName           = {'overheid4GE.png','oet4GE.png'};

      OPT2.varPathFcn         = @(s) path2os(strrep(s,urlbase,ncbase),filesep); % use local netCDF files for preview/statistics when CATALOG refers already to server
      OPT2.resolveUrl         = cellfun(@(x) resolveUrls{ii},cellstr(CATALOG.platform_name),'un',0);
      OPT2.resolveName        = 'www.knmi.nl';
      
      OPT2.iconnormalStateScale    = 1;
      OPT2.iconhighlightStateScale = 1;   
      OPT2.iconnormalState    = 'http://www.ndbc.noaa.gov//images/maps/markers/tiny_active_marker.png';
      OPT2.iconhighlightState = 'http://www.ndbc.noaa.gov//images/maps/markers/tiny_active_marker.png';

      OPT2.credit             = ' data: www.knmi.nl plot: www.OpenEarth.eu';
      OPT2.preview            = preview(ii);
      OPT2.name               = subdir;
      if OPT2.preview
      OPT2.varname            = varnames{ii};
      else
      OPT2.varname            = '';
      end

      nc_cf_harvest_matrix2kml(CATALOG,OPT2); % inside urlPath is used to read netCDF data for plotting previews

   end   
end
   