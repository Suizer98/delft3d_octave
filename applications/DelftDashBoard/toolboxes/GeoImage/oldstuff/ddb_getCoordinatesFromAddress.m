function ret=ddb_getCoordinatesFromAddress(str)

% get normalized coordinate first
x = 0.0;
y = 0.0;
scale = 1.0;
str = lower(str);
str = str(2:end); % skip the first character
while (length(str)) > 0
    scale = 0.5 * scale;
    c = str(1); % remove first character
    if c=='r' | c=='s'
        x = x + scale;
    end
    if c=='t' | c=='s'
        y = y + scale;
    end
    str = str(2:end);
end

ret.longmin = (x - 0.5) * 360;
ret.latmin = NormalToMercator(y);
ret.longmax = (x + scale - 0.5) * 360;
ret.latmax = NormalToMercator(y + scale);
ret.long = (x + scale * 0.5 - 0.5) * 360;
ret.lat = NormalToMercator(y + scale * 0.5);

function y=NormalToMercator(y)
y = y - 0.5;
y = 2 * pi * y;
y = exp(2 * y);
y = (y-1)/(y+1);
y = asin(y);
y = -180/pi * y;
