%WFS_test test for wcs
%
% test using these servers:
% 
% With dimensions
%   1.1.0 4326=?? DescribeCoverage=1 http://geo.vliz.be/geoserver/wfs?service=WFS&request=GetCapabilities
%
%  see also: http://disc.sci.gsfc.nasa.gov/services/ogc_wms

warning('WIP')
import ogc.*
%% get url and data
% http://www.nationaalgeoregister.nl/geonetwork/srv/dut/search#|94e5b115-bece-4140-99ed-93b8f363948e

server = 'http://geo.vliz.be/geoserver/wfs?';
[url,OPT,lim] = wfs('server',server,...
                    'typename','World:worldcities',...
                        'axis',[4 51 5 55]);
cachename = [OPT.cachedir,mkvar(OPT.typename),'.xml'];
urlwrite(url,cachename);

%% load data
F = xml_read(cachename,struct('Str2Num',0,'KeepNS',0))

%% plot data
clear P
P.n   = length(F.featureMembers.worldcities);
P.lon = nan(P.n,1);
P.lat = nan(P.n,1);
P.txt = cell(P.n,1);

for i=1:P.n
    ll = str2num(F.featureMembers.worldcities(i).the_geom.Point.pos);
    P.lon(i) = ll(2);
    P.lat(i) = ll(1);
    P.txt{i} = F.featureMembers.worldcities(i).city_name;
end

plot(P.lon,P.lat,'.')
hold on
text(P.lon,P.lat,P.txt)
axislat
tickmap('ll')
print2screensize([filepathstrname(cachename),'.png'])