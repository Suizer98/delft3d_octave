function deg = rad2deg(rad)
%RAD2DEG   conversion of radians to degrees
%
% Note the official Mathworks RAD2DEG is part of the mapping toolbox.
%
%See also: DEG2RAD, ANGLE2DOMAIN, MAP

deg = (180/pi).*rad;

% eof