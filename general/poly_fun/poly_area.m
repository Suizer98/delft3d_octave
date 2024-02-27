function  a = poly_area(x,y);
%POLY_AREA  SIGNED area of a planar polygon (+ for counterclockwise)
%
%    A = poly_area(X,Y) 
%
%  calculates the area of a 2-dimensional
%  polygon formed by vertices with coordinate vectors
%  X and Y. The result is direction-sensitive: the
%  area is positive if the bounding contour is counter-
%  clockwise and negative if it is clockwise.
%
%See also: POLYFUN, TRAPZ.

%  Copyright (c) 1995 by Kirill K. Pankratov,
%	kirill@plume.mit.edu.
%	04/20/94, 05/20/95  

 % Make polygon closed ( even if it already is) .............
x = [x(:); x(1)];
y = [y(:); y(1)];

 % Calculate contour integral Int -y*dx  (same as Int x*dy).
 
lx = length(x);
if isfloat(x) && isfloat(y) 
a  = -(x(2:lx)-x(1:lx-1))'*(y(1:lx-1)+y(2:lx))/2;
else % mtimes can not handle ints: return double
a  = -sum((x(2:lx)-x(1:lx-1)).*(y(1:lx-1)+y(2:lx)))/2;
end
