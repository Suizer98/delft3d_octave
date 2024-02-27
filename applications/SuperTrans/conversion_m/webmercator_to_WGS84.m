function [xLon, yLat] = webmercator_to_WGS84(xLon, yLat)
% This function converts Web Mercator to WGS84
% Code 1: 7483 Code 2: 4326
% source: http://www.neercartography.com/latitudelongitude-tofrom-web-mercator/
% v1.0  Nederhoff   Dec-16

%% Beginning checks
if (abs(xLon) < 180) and (abs(yLat) > 90)
    return
end
if (abs(xLon) > 20037508.3427892) | (abs(yLat) > 20037508.3427892)
    return
end

%% Calculate
semimajorAxis   = 6378137.0;
yLat            = (1.5707963267948966 - (2.0 *atan(exp((-1.0 * yLat) / semimajorAxis)))) * (180/pi);
xLon            = ((xLon / semimajorAxis) * 57.295779513082323) - ((floor((((xLon / semimajorAxis) * 57.295779513082323) + 180.0) / 360.0)) * 360.0);
    
end

