%INMASK Find the point that are inside of the model/target grid domain
%   IN = INMASK(X,Y) returns a matrix IN the size of X and Y.
%   IN(p,q) = 1 if the point (X(p,q), Y(p,q)) is either strictly inside or
%   on the grid domain specified in the file 'northseamask.mat'
%   otherwise IN(p,q) = 0.
%   Arguments:
%   <X> x coordenates of the grid to be checked 
%   <Y> y coordenates of the grid to be checked 
%   <coord> the type of coordenates
%   See also: INPOLYGON, REDUCE2MASK

%   Copyright: Deltares, the Netherlands
%        http://www.delftsoftware.com
%        Date: 08.07.2009
%      Author: S. Gaytan Aguilar
% -------------------------------------------------------------------------
function IN = inmask(X,Y,coord)

IN = zeros(size(X));

load northseamask.mat
if nargin == 2
   coord = 'xypar';
end

switch coord
    
    case 'xypar'
         xdomain = mask.xpar;
         ydomain = mask.ypar;
    case 'lonlat'
         xdomain = mask.lon;
         ydomain = mask.lat;
    case 'xyutm'
         xdomain = mask.xutm;
         ydomain = mask.yutm;
end

% Poits inside of the polygon
[in on] = inpolygon(X,Y,xdomain,ydomain);
in = in | on;
if any(in(:))
   IN(in) = 1;
end

IN = logical(IN);