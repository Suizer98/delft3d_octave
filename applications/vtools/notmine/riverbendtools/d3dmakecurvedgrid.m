function [grd] = d3dmakecurvedgrid(width,radius,angle,m,n)
% D3DMAKECURVEDGRID makes a rectangular grid 
%
% syntax:
% [grd] = d3dmakecurvedgrid(width,radius,angle,m,n)
%
% input:
% width   - width of the new grid. 
% radius  - radius of curvature of the new grid 
%           (negative radius turns the other direction)
% angle   - angle in degrees which the grid passes through
% m       - number of grid cells over the width
% n       - number of grid cells over the length
%
% output:
% grd.X   - X data of the grid.
% grd.Y   - Y data of the grid
%
% example:
% grd = d3dmakecurvedgrid(4.0,9.4,180,20,55);
% 
% See also d3dmakestraightgrid, d3djoingrid, d3dplotgrid, wlgrid 
%
% -------------------------------------------------------------------------
%  Copyright (C) 2008 Delft University of Technology
%    Faculty of Civil Engineering and Geosciences
%    Willem Ottevanger  (email: w.ottevanger@tudelft.nl)
%    Version 0.2 (11-08-08)
% -------------------------------------------------------------------------



W = width;
R = radius;
phi = angle;

if abs(R)<W/1.9
    error('Radius of curvature too small or grid too wide.')
end

grd.X   = NaN*zeros(m+1,n+1);
grd.Y   = NaN*zeros(m+1,n+1);

rr = R+W/2:-W/m:R-W/2;
yy = 0:phi/n:phi;

grd.X(1:m+1,1:n+1) = sign(R)*rr'*sin(yy/180*pi);
grd.Y(1:m+1,1:n+1) = -rr'*cos(yy/180*pi) + (R+W/2);

grd.X = grd.X';
grd.Y = grd.Y';