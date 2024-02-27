function [grd2] = d3dtranslategrid(grd1,dx,dy);
% D3DTRANSLATEGRID shifts grid dx along x and dy along y
%
% syntax:
% grd2 = d3dtranslategrid(grd1,dx,dy);
%
% input:
% grd1.X   - X data of the grid.
% grd1.Y   - Y data of the grid
% dx       - shift in x direction
% dy       - shift in y direction
%
% output:
% grd2.X   - X data of the grid.
% grd2.Y   - Y data of the grid
%
% example:
% grd1 = d3dmakestraightgrid(4.0,9.4,20,55);
% grd2 = d3dtranslategrid(grd1,2,1.2);
% 
% See also d3dmakecurvedgrid, d3djoingrid, d3dplotgrid, wlgrid 
%
% -------------------------------------------------------------------------
%  Copyright (C) 2008 Delft University of Technology
%    Faculty of Civil Engineering and Geosciences
%    Willem Ottevanger  (email: w.ottevanger@tudelft.nl)
%    Version 0.2 (11-08-08)
% -------------------------------------------------------------------------


grd2.X = [grd1.X]+dx;
grd2.Y = [grd1.Y]+dy;
