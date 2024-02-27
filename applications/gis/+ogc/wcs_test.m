%WCS_test test for wcs
%
% test using these servers:
% 
% With dimensions
%   1.1.0 4326=?? DescribeCoverage=1 http://geodata.nationaalgeoregister.nl/ahn1/wcs?service=WCS&version=1.0.0&request=GetCapabilities
%
%  see also: http://disc.sci.gsfc.nasa.gov/services/ogc_wms

warning('implement checks for: crs, resx, resy, interpolation')
import ogc.*
%% Statics Dutch AHN2
% AHN2 http://www.nationaalgeoregister.nl/geonetwork/srv/dut/search#|f20e948e-9e22-4b5a-96a1-f3cc1d16b808
% http://www.nationaalgeoregister.nl/geonetwork/srv/dut/search#|94e5b115-bece-4140-99ed-93b8f363948e

server = 'http://geodata.nationaalgeoregister.nl/ahn2/wcs?';
[url,OPT,lim] = wcs('server',server,...
    'coverage','ahn2:ahn2_5m',... 
    'format','tiff',...% should not work: GeoTIFF (case)
    'crs','epsg:4326',...
    'axis',[94000 466000 96000 468000],...
    'resx',5,'resy',5);

cachename = [OPT.cachedir,mkvar(OPT.coverage),'.',OPT.format];
urlwrite(url,cachename);

% plot data
% Kaag: water and land, wit
% train through it and some high buildings (loodsen)
% http://geodata.nationaalgeoregister.nl/ahn1/wcs?&service=wcs&version=1.0.0&request=GetCoverage&bbox=94000,466000,96000,468000&coverage=ahn1:ahn1_5m&format=GeoTIFF&crs=epsg:28992&resx=5&resy=5

a = imread(cachename);
a(a<-3.402e+38)=nan;  % ahn2
%a(a==-32768)=nan;    % ahn1
pcolorcorcen(OPT.x,OPT.y,double(a))
tickmap('xy')
print2screensize([filepathstrname(cachename),'.png'])
close
%% dynamic WCS
wcs0 = 'http://thredds.jpl.nasa.gov/thredds/wcs/ncml_aggregation/Chlorophyll/seawifs/aggregate__SEAWIFS_L3_CHLA_MONTHLY_9KM_R.ncml?' % service=WCS&version=1.0.0&request=GetCapabilities
wcs0 = 'http://thredds.jpl.nasa.gov/thredds/wcs/ncml_aggregation/Chlorophyll/seawifs/aggregate__SEAWIFS_L3_CHLA_MONTHLY_9KM_R.ncml?' % service=WCS&version=1.0.0&request=GetCapabilities
[url,OPT,lims] = wcs('server',wcs0,...
                         'axis',[-10 50 15 60],...
                         'time','1997-09-01T00:00:00Z');
cachename = [OPT.cachedir,mkvar(OPT.coverage),'.',OPT.format];
urlwrite(url,cachename);                     
                   %%
figure('name',OPT.coverage)
A = nc2struct(cachename)
OPT.x = linspace(OPT.axis(1),OPT.axis(3),size(A.(OPT.coverage),3));
OPT.y = linspace(OPT.axis(4),OPT.axis(2),size(A.(OPT.coverage),2));
pcolorcorcen(OPT.x,OPT.y,double(A.(OPT.coverage)))
tickmap('ll');grid on;
set(gca,'ydir','normal')
axislat
title(OPT.time);
colorbar
caxis(clim)
[ax, h]=colorbarwithvtext(OPT.coverage);
print2screensize([filepathstrname(cachename),'.png'])