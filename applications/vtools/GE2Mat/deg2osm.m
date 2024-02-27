function [xtile,ytile] = osm2deg(zoom,lat_deg,lon_deg);
n = 2 ^ zoom;
xtile = n * ((lon_deg + 180) / 360);
ytile = n/ 2 * (1 - (log(tan(lat_deg*pi/180) + sec(lat_deg*pi/180)) / pi)) ;