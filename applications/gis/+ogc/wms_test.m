%WMS_test test for wms
%
% test using these servers:
% 
% With dimensions
%   CRS image/png 1.3.0 4326=NO http://data.ncof.co.uk/thredds/wms/METOFFICE-NWS-AF-BIO-DAILY?&service=wms&version=1.3.0&request=GetMap&bbox=-19.8888,40.0667,12.9997,65&layers=CHL&format=image/png&CRS=EPSG%3A4326&width=800&height=600&transparent=true&styles=boxfill/ferret&colorscalerange=0,1
%   SRS image/png 1.1.1 4326=OK http://geoservices.knmi.nl/cgi-bin/RADNL_OPER_R___25PCPRR_L3.cgi?&service=wms&version=1.1.1&request=GetMap&bbox=0,48.8953,10.8564,55.9736&layers=RADNL_OPER_R___25PCPRR_L3_COLOR&format=image/png&SRS=EPSG%3A4326&width=800&height=600&transparent=true&styles=default&colorscalerange=-50,50
%
% Aerial
%   SRS image/png 1.1.1 4326=OK http://gdsc.nlr.nl/wms/lufo2005?&service=wms&version=1.1.1&request=GetMap&bbox=2.8146,50.2269,8.1661,54.067&layers=lufo2005-1m&format=image/png&SRS=EPSG%3A4326&width=800&height=600&transparent=true&styles=default
%   CRS image/png 1.3.0 4326=OK http://wms.agiv.be/ogc/wms/omkl?&service=wms&version=1.3.0&request=GetMap&bbox=50.64,2.52,51.51,5.94&layers=Ortho&format=image/png&CRS=EPSG%3A4326&width=800&height=600&transparent=true&styles=default
%   CRS image/jpg 1.3.0 4326=OK http://geoint.lmic.state.mn.us/cgi-bin/wmsll?&service=wms&version=1.3.0&request=GetMap&bbox=43.37,-97.39,49.41,-89.33&layers=fsa2010&format=image/jpeg&CRS=EPSG%3A4326&width=800&height=600&transparent=true&styles=default
%
% Bathymetry
%   CRS image/png 1.3.0 4326=OK http://www.gebco.net/data_and_products/gebco_web_services/web_map_service/mapserv?&service=wms&version=1.3.0&request=GetMap&bbox=-90,-180,90,180&layers=GEBCO_08_Grid&format=image/png&CRS=EPSG%3A4326&width=800&height=600&transparent=true&styles=
%   CRS image/png 1.3.0 4326=OK http://geoport.whoi.edu/thredds/wms/bathy/etopo2_v2c.nc?&service=wms&version=1.3.0&request=GetMap&bbox=-89.9833,-179.9833,89.9833,179.9833&layers=topo&format=image/png&CRS=EPSG%3A4326&width=800&height=600&transparent=true&styles=boxfill/ferret&colorscalerange=-4000,4000
%   CRS image/png 1.3.0 4326=OK http://geodata.nationaalgeoregister.nl/ahn25m/wms?&service=wms&version=1.3.0&request=GetMap&bbox=50.672,3.198,53.611,7.276&layers=ahn25m&format=image/png&CRS=EPSG%3A4326&width=800&height=600&transparent=true&styles=ahn25_cm
%
%  see also: http://disc.sci.gsfc.nasa.gov/services/ogc_wms

% http://www.nationaalgeoregister.nl/geonetwork/srv/dut/search#|94e5b115-bece-4140-99ed-93b8f363948e

SET.plot = 1; % 0 for catalogue only, 1 to download wms (SLOW)
clc
import ogc.*
%% THREDDS MyOcean (bit slow)
%  test: need to use color range
%  test: 2 dimenions: elevation + time
%  test: interactive: many styles
%  test: lat,lon swap in bbox for version=1.3.0 and crs=epsg:4326: use crs=crs:84

warning('test: x-y swap for 1.3.0 and 4326')

server = 'http://data.ncof.co.uk/thredds/wms/METOFFICE-NWS-AF-BIO-DAILY?';
[url,OPT,lims] = wms('server',server,...
    'layers','CHL',...
    'colorscalerange',[0,1],...  % explicit values required for nice colors
    'styles','boxfill/ferret',...
    'time'     ,'2012-11-02T12:00:00.000Z',... % VALUE FROM LIST
    'elevation','-10.0',...
     'crs','crs:84');
[url,OPT,lims] = wms('server',server,...
    'layers','CHL',...
    'colorscalerange',[0,1],...  % explicit values required for nice colors
    'styles','boxfill/ferret',...
    'time'     ,'default',... % DEFAULT
    'elevation','default',...
     'crs','crs:84');
[url,OPT,lims] = wms('server',server,...
    'layers','CHL',...
    'colorscalerange',[0,1],...  % explicit values required for nice colors
    'styles','boxfill/ferret',...
    'time'     ,'',... % EMPTY
    'elevation','',...
     'crs','crs:84');
[url,OPT,lims] = wms('server',server,...
    'layers','CHL',...
    'colorscalerange',[0,1],...  % explicit values required for nice colors
    'styles','boxfill/ferret',...
    'time'     ,datenum(2012,11,2,12,0,0),...
    'elevation',-10.0,... % NUMERIC: PRECISION MISMATCH
     'crs','crs:84'); 
disp(['wms_test:version: ',num2str(OPT.version),' crs: ',num2str(OPT.crs), ' ',url])
if SET.plot;wms_image_plot(url,OPT);end
  
%% KNMI adaguc buienradar
%  test: requires &service= (other servers don't)
%  test: &srs= in url instead of &crs= 
%  test: one dimension: time as extent
server = 'http://geoservices.knmi.nl/cgi-bin/RADNL_OPER_R___25PCPRR_L3.cgi?';
% [url,OPT,lims] = wms('server',server,...
%     'crs'   ,'EPSG%3A4326',...
%     'format','image/png',...
%     'layers',2,... % 1st layer
%     'styles',9,... % 9th style
%     'time','2012-12-07T00:00:00Z',... % VALUE FROM LIST
%     'colorscalerange',[-50,50]);% explicit values required for nice colors
warning('checking time while xml supplies range does work yet')
[url,OPT,lims] = wms('server',server,...
    'crs'   ,'EPSG%3A4326',...
    'format','image/png',...
    'layers',2,... % 1st layer
    'styles',9,... % 9th style
    'time','default',... % DEFAULT
    'colorscalerange',[-50,50]);% explicit values required for nice colors
[url,OPT,lims] = wms('server',server,...
    'crs'   ,'EPSG%3A4326',...
    'format','image/png',...
    'layers',2,... % 1st layer
    'styles',9,... % 9th style
    'time','',... % EMPTY
    'colorscalerange',[-50,50]);% explicit values required for nice colors
[url,OPT,lims] = wms('server',server,...
    'crs'   ,'EPSG%3A4326',...
    'format','image/png',...
    'layers',2,... % 1st layer
    'styles',9,... % 9th style
    'time',datenum(2012,11,2,12,0,0),... % NUMERIC: PRECISION MISMATCH
    'colorscalerange',[-50,50]);% explicit values required for nice colors
disp(['wms_test:version: ',num2str(OPT.version),' crs: ',num2str(OPT.crs), ' ',url])
%if SET.plot;wms_image_plot(url,OPT);end
 

%% USA Minnesota state aerial imagery
%  test: basic

server = 'http://geoint.lmic.state.mn.us/cgi-bin/wmsll?';
[url,OPT,lims] = wms('server',server,'layers','fsa2010','styles','default');
disp(['wms_test:version: ',num2str(OPT.version),' crs: ',num2str(OPT.crs), ' ',url])
if SET.plot;wms_image_plot(url,OPT);end
  
%% Netherlands aerial imagery
%  test: BoundingBox is a layer property per coordinate system (incl. one 4326 system), and not global 4326 property 
%  test: version=1.1.1 only

server = 'https://geodata1.nationaalgeoregister.nl/luchtfoto/wms?';
[url,OPT,lims] = wms('server',server,'layers','Ortho','styles','default');
disp(['wms_test:version: ',num2str(OPT.version),' crs: ',num2str(OPT.crs), ' ',url])
if SET.plot;wms_image_plot(url,OPT);end

%% Belgium aerial imagery
%  test: crashed on http://wms.agiv.be/ogc/wms/omkl?service=WMS&version=1.3.0&request=GetCapabilities&service=WMS

server = 'http://wms.agiv.be/ogc/wms/omkl?';
[url,OPT,lims] = wms('server',server,'layers','Ortho');
disp(['wms_test:version: ',num2str(OPT.version),' crs: ',num2str(OPT.crs), ' ',url])
if SET.plot;wms_image_plot(url,OPT);end
  
%% GEBCO
%  test: no style

server = 'http://www.gebco.net/data_and_products/gebco_web_services/web_map_service/mapserv?';
[url,OPT,lims] = wms('server',server,'layers','GEBCO_08_GRID'); % issues with GEBCO_LATEST
disp(['wms_test:version: ',num2str(OPT.version),' crs: ',num2str(OPT.crs), ' ',url])
if SET.plot;wms_image_plot(url,OPT);end
  
 
%% THREDDS bathymetry
%  test: one dimension: time

server = 'http://geoport.whoi.edu/thredds/wms/bathy/etopo2_v2c.nc?';
[url,OPT,lims] = wms('server',server,...
    'bbox',[],...
    'format','image/png',...
    'layers',1,... % 1st layer
    'styles',9,... % 9th style
    'colorscalerange',[-4000,4000]); % explicit values required for nice colors
disp(['wms_test:version: ',num2str(OPT.version),' crs: ',num2str(OPT.crs), ' ',url])
if SET.plot;wms_image_plot(url,OPT);end

%% AHN2 http://www.nationaalgeoregister.nl/geonetwork/srv/dut/search#|94e5b115-bece-4140-99ed-93b8f363948e
%  test: layer.layer (no 3rd layer level)

server = 'http://geodata.nationaalgeoregister.nl/ahn25m/wms?';
[url,OPT,lims] = wms('server',server,'layers','ahn25m');
disp(['wms_test:version: ',num2str(OPT.version),' crs: ',num2str(OPT.crs), ' ',url])
if SET.plot;wms_image_plot(url,OPT);end

%% THREDDS vaklodingen
%  test: lat,lon swap in bbox for version=1.3.0 and crs=epsg:4326: use crs=crs:84

% server = 'http://opendap.deltares.nl/thredds/wms/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB121_2120.nc?';
% [url,OPT,lims] = wms('server',server,'crs','crs:84');
% disp(['wms_test:version: ',num2str(OPT.version),' crs: ',num2str(OPT.crs), ' ',url])
% if SET.plot;wms_image_plot(url,OPT);end

%% SIMONA
%  test: CF

 server = 'http://opendap.deltares.nl/thredds/wms/opendap/test/SDSddhzee2CF3.nc?';
 [url,OPT,lims] = wms('server',server,'crs','crs:84',...
     'bbox',[],...
    'format','image/png',...
    'layers','SEP',... % 1st layer
    'styles','boxfill/ferret',... % 9th style
    'colorscalerange',[-1,1]);
 disp(['wms_test:version: ',num2str(OPT.version),' crs: ',num2str(OPT.crs), ' ',url])
 if SET.plot;wms_image_plot(url,OPT);end