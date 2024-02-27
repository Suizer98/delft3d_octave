function grd2 = d3drotategrid(grd1,angle);
% D3DROTATEGRID rotates a grid about a certain angle
%
% syntax:
% grd2 = d3drotategrid(grd1,angle);
%
% input:
% grd1.X   - X data of the grid.
% grd1.Y   - Y data of the grid
% angle    - angle in degrees
%
% output:
% grd2.X   - X data of the grid.
% grd2.Y   - Y data of the grid
%
% example:
% grd1 = d3dmakestraightgrid(4.0,9.4,20,55);
% grd2 = d3drotategrid(grd1,angle);
% 
% See also d3drotategrid, d3djoingrid, d3dplotgrid, wlgrid 
%
% -------------------------------------------------------------------------
%  Copyright (C) 2008 Delft University of Technology
%    Faculty of Civil Engineering and Geosciences
%    Willem Ottevanger  (email: w.ottevanger@tudelft.nl)
%    Version 0.2 (11-08-08)
% -------------------------------------------------------------------------

grd2.X = [grd1.X]*cos(angle*pi/180)-[grd1.Y]*sin(angle*pi/180);
grd2.Y = [grd1.X]*sin(angle*pi/180)+[grd1.Y]*cos(angle*pi/180);
