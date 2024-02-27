function [xLon, yLat] = WGS84_to_toWebMercator(xLon, yLat)
% This function converts WGS84 to Web Mercator
% Code 1: 7483 Code 2: 4326
% source: http://www.neercartography.com/latitudelongitude-tofrom-web-mercator/
% v1.0  Nederhoff   Dec-16

%% Beginning checks
% Check if coordinate out of range for Latitude/Longitude
if xLon > 180
    xLon = 180;
end
if yLat > 85
    yLat = 85;
end
if xLon < -180 
    xLon = -180;
end
if yLat < -85
    yLat = -85;
end

%% Do the actual calculation
semimajorAxis   = 6378137.0;
east            = xLon * 0.017453292519943295;
north           = yLat * 0.017453292519943295;
yLat            = 3189068.5 .* log((1.0 + sin(north)) ./ (1.0 - sin(north)));
xLon            = semimajorAxis * east;

end

