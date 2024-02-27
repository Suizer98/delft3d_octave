function quad=ddb_getQuadtreeAddress(long, lat,zoomlevel)

% now convert to normalized square coordinates
% use standard equations to map into mercator projection
x = (180.0 + long) / 360.0;
y = MercatorToNormal(lat);
quad = 't'; % google addresses start with t
lookup = 'qrts'; % tl tr bl br
for digits = 0:min(18,zoomlevel)
    id=1;
    % make sure we only look at fractional part
    x = x - floor(x);
    y = y - floor(y);
    if x>0.5
        id=id+1;
    end
    if y>0.5
        id=id+2;
    end
    quad = [quad lookup(id)];
    % now descend into that square
    x = 2 * x;
    y = 2 * y;
end


function y=MercatorToNormal(y)

y = -y * pi/ 180; % convert to radians
y = sin(y);
y = (1+y)/(1-y);
y = 0.5 * log(y);
y = y / (2 * pi); % scale factor from radians to normalized
y = y + 0.5; % and make y range from 0 - 1


