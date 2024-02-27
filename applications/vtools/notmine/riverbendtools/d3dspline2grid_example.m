function grd = d3dspline2grid_example()
% D3DSPLINE2GRID_EXAMPLE - Draws a grid based on a spline
%
% syntax: [grd] = example_spline2grid;
%
% See also: spline2grid, wlgrid
%
% -------------------------------------------------------------------------
%  Copyright (C) 2009 Delft University of Technology
%    Faculty of Civil Engineering and Geosciences
%    Willem Ottevanger  (email: w.ottevanger@tudelft.nl)
%    Version 0.2 (26-06-08)
% -------------------------------------------------------------------------
x     = [3:12].*sin([3:12]);
y     = [3:12].*cos([3:12]);
width = 1.1;
mmax  = 150;
nmax  = 9;

grd   = d3dspline2grid(x,y,width,mmax,nmax);
d3dplotgrid(grd);
hold on; plot(x,y,'ro');