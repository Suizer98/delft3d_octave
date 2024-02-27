function [] = d3dplotgrid(grd);
% D3DPLOTGRID plots grid which can be used by Delft3D. 
%
% syntax:
% d3dplotgrid(grd);
%
% input:
% grd.X   - X data of the grid.
% grd.Y   - Y data of the grid
%
% output: [none]
%
% example:
% grd = d3dmakestraightgrid(4.0,9.4,20,55);
% d3dplotgrid(grd);
% 
% See also d3dmakecurvedgrid, d3djoingrid, d3dplotgrid, wlgrid 
%
% -------------------------------------------------------------------------
%  Copyright (C) 2008 Delft University of Technology
%    Faculty of Civil Engineering and Geosciences
%    Willem Ottevanger  (email: w.ottevanger@tudelft.nl)
%    Version 0.2 (11-08-08)
% -------------------------------------------------------------------------



plot(grd.X',grd.Y','b');
hold on;
plot(grd.X,grd.Y,'b');
hold off;
axis equal tight;