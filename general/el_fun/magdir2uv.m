function [u,v] = magdir2uv(mag,dir,convention)
% magdir2uv derives the u and v component from the magnitude and direction data
%
% [u,v] = MAGDIR2UV(mag,dir,convention)
% -------------------------------------------------------------------------
% u          = u-component of magnitude
% v          = v-component of magnitude
% mag        = magnitude parameter
% dir        = directional parameter in degrees (going to)
% convention = either 'cartesian' or 'nautical'
%
% where:
% 'cartesian', the direction to where the vector points
% 'nautical', the direction where the vector comes from
% if no convention is assigned, 'cartesian'  convention is applied
% note that both convention are considered clockwise from geographic North

% created by E.Moerman 08-08-2012
% modified by P.W. van Steijn 09-02-2022 to make it faster without a loop over all elements

if nargin == 2
    convention='cartesian';
end

u = nan(size(dir));
v = nan(size(dir));

dir(dir>360) = dir(dir>360)-360; % substract 360 degrees for values larger than 360
dir(dir<0) = dir(dir<0)+360; % add 360 degrees for negative values

IDs = dir>0&dir<90; % quadrant 1, 0-90 degrees
if sum(IDs(:))>0
    if strcmp(convention,'cartesian')
        u(IDs) = sind(dir(IDs)).*mag(IDs);
        v(IDs) = cosd(dir(IDs)).*mag(IDs);
    else
        u(IDs) = sind(dir(IDs)).*mag(IDs).*-1;
        v(IDs) = cosd(dir(IDs)).*mag(IDs).*-1;
    end
end

IDs = dir > 90 & dir < 180; % quadrant 2, 90-180 degrees
if sum(IDs(:))>0
    if strcmp(convention,'cartesian')
        u(IDs) = cosd(dir(IDs)-90).*mag(IDs);
        v(IDs) = sind(dir(IDs)-90).*mag(IDs).*-1;
    else
        u(IDs) = cosd(dir(IDs)-90).*mag(IDs).*-1;
        v(IDs) = sind(dir(IDs)-90).*mag(IDs);
    end
end

IDs = dir > 180 & dir < 270; % quadrant 3, 180-270 degrees
if sum(IDs(:))>0
    if strcmp(convention,'cartesian')
        u(IDs) = sind(dir(IDs)-180).*mag(IDs).*-1;
        v(IDs) = cosd(dir(IDs)-180).*mag(IDs).*-1;
    else
        u(IDs) = sind(dir(IDs)-180).*mag(IDs);
        v(IDs) = cosd(dir(IDs)-180).*mag(IDs);
    end
end

IDs = dir > 270 & dir < 360; % quadrant 4, 270-360 degrees
if sum(IDs(:))>0
    if strcmp(convention,'cartesian')
        u(IDs) = cosd(dir(IDs)-270).*mag(IDs).*-1;
        v(IDs) = sind(dir(IDs)-270).*mag(IDs);
    else
        u(IDs) = cosd(dir(IDs)-270).*mag(IDs);
        v(IDs) = sind(dir(IDs)-270).*mag(IDs).*-1;
    end
end

IDs = dir == 0 | dir == 360;
if sum(IDs(:))>0
    if strcmp(convention,'cartesian')
        u(IDs) = 0;
        v(IDs) = mag(IDs);
    else
        u(IDs) = 0;
        v(IDs) = mag(IDs).*-1;
    end
end

IDs = dir == 90;
if sum(IDs(:))>0
    if strcmp(convention,'cartesian')
        u(IDs) = mag(IDs);
        v(IDs) = 0;
    else
        u(IDs) = mag(IDs).*-1;
        v(IDs) = 0;
    end
end

IDs = dir == 180;
if sum(IDs(:))>0
    if strcmp(convention,'cartesian')
        
        u(IDs) = 0;
        v(IDs) = mag(IDs).*-1;
    else
        u(IDs) = 0;
        v(IDs) = mag(IDs);
    end
end

IDs = dir == 270;
if sum(IDs(:))>0
    if strcmp(convention,'cartesian')
        u(IDs) = mag(IDs).*-1;
        v(IDs) = 0;
    else
        u(IDs) = mag(IDs);
        v(IDs) = 0;
    end
end

IDs = isnan(dir);
if sum(IDs(:))>0
    u(IDs) = NaN;
    v(IDs) = NaN;
end
