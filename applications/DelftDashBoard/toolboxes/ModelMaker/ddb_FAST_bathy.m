function [xg,yg,zg] = ddb_FAST_bathy(xg,yg,coor_XB)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

% Settings
coor_WGS.name   ='WGS 84';
coor_WGS.type   = 'geo';

% Make and download the bounding box
[lon,lat]= ddb_coordConvert(xg,yg, coor_XB, coor_WGS);
[nx, ny] = size(lon);
for xi = 1:nx
for xj = 1:ny
[xLon(xi, xj), yLat(xi, xj)]    = WGS84_to_toWebMercator(lon(xi, xj), lat(xi, xj));
end
end

% TMP: only 1D line to overcome instabilities
diffX = min(min(xLon)) - max(max(xLon));
diffY = min(min(yLat)) - max(max(yLat));
if diffY > diffX
    xtmp1 = round(min(min(xLon))); xtmp2 = round(max(max(xLon)));
    ytmp1 = round(min(min(yLat))); ytmp2 = round(max(max(yLat)));
else
    xtmp1 = round(min(min(xLon))); xtmp2 = round(max(max(xLon)));
    ytmp1 = round(min(min(yLat))); ytmp2 = round(max(max(yLat)));
end

% If not TMP
boundary_box = [num2str(round(xtmp1)), ',', num2str(round(ytmp1)), ',', num2str(round(xtmp2)),',', num2str(round(ytmp2))];
[status, filename, pathname] = ddb_clip_from_my_target_layer('http://tw-089.xtr.deltares.nl/', 'mi-safe-expert-delftdashboard',boundary_box,'FAST_global_imagery:GEE_intertidal_elev', 'd:\data\FAST\');

% Get the geotiff
fname = [pathname, filename];
[A,x,y,I]   = ddb_geoimread(fname); [Xveg Yveg] = meshgrid(x,y);
xLon = []; yLat = []; 
for xi = 1:length(x);
for xj = 1:length(y);
[xLon(xj,xi), yLat(xj,xi)]    = webmercator_to_WGS84(x(xi), y(xj));
end
end
coor_WGS.name   = 'WGS 84';
coor_WGS.type   = 'geo';
[XFAST,YFAST]=ddb_coordConvert(xLon,yLat,coor_WGS,coor_XB);

% Interpolate it to the grid
dx = abs(xg(2,1) - xg(1,2));
dy = abs(yg(1,2) - yg(1,1));
dd = max(dx, dy);
zg = qinterp2(XFAST,YFAST,A,xg,yg,0);

%figure; pcolor(XFAST, YFAST, A); shading flat;
%figure; pcolor(xg,yg, zg); shading flat;