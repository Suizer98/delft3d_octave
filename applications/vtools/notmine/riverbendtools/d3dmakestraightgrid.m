function [grd] = d3dmakestraightgrid(width,length,m,n)
% D3DMAKESTRAIGHTGRID makes a rectangular grid 
%
% syntax:
% [grd] = d3dmakestraightgrid(width,length,m,n)
%
% input:
% width   - width of the new grid. 
% length  - length of the new grid
% m       - number of grid cells over the width
% n       - number of grid cells over the length
%
% output:
% grd.X   - X data of the grid.
% grd.Y   - Y data of the grid
%
% example:
% grd = d3dmakestraightgrid(4.0,9.4,20,55);
% 
% See also d3dmakecurvedgrid, d3djoingrid, d3dplotgrid, wlgrid 
%
% -------------------------------------------------------------------------
%  Copyright (C) 2008 Delft University of Technology
%    Faculty of Civil Engineering and Geosciences
%    Willem Ottevanger  (email: w.ottevanger@tudelft.nl)
%    Version 0.2 (11-08-08)
% -------------------------------------------------------------------------

W = width;
S = length;

grd.X   = NaN*zeros(m+1,n+1);
grd.Y   = NaN*zeros(m+1,n+1);

x = -W/2:W/m:W/2;
y = 0:S/n:S;

grd.X(1:m+1,1:n+1) = ones(m+1,1)*y;
grd.Y(1:m+1,1:n+1) = x'*ones(1,n+1);

grd.X = grd.X';
grd.Y = grd.Y';

