function [lat_deg,lon_deg] = osm2deg(zoom,xtile,ytile);
% OSM documentation
n=2^zoom;
lon_deg = xtile ./ n * 360.0 - 180.0;
lat_rad = atan(sinh(pi * (1 - 2 * ytile ./ n)));
lat_deg = lat_rad * 180.0 ./ pi;