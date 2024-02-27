function [grd3] = d3djoingrid(grd1,grd2);

% D3DJOINGRID combines grids created using d3dmakestraightgrid and
% d3dmakecurvedgrid or this function. The number of grid cells over the
% width in grd1 and grd2 should coincide.
%
% syntax:
% [grd3] = d3djoingrid(grd1,grd2);
%
% input:
% grd1     - struct contaning X and Y Data. 
% grd2     - struct contaning X and Y Data. 
%
% output:
% grd3.X   - X data of the grid.
% grd3.Y   - Y data of the grid
%
% example:
% grd1 = d3dmakecurvedgrid(4.0,9.4,180,20,55);
% grd2 = d3dmakestraightgrid(4.0,9.4,20,55);
% grd3 = d3djoingrid(grd1,grd2);
% 
% See also d3dmakestraightgrid, d3dmakecurvedgrid, d3dplotgrid, wlgrid  
%
% -------------------------------------------------------------------------
%  Copyright (C) 2008 Delft University of Technology
%    Faculty of Civil Engineering and Geosciences
%    Willem Ottevanger  (email: w.ottevanger@tudelft.nl)
%    Version 0.2 (11-08-08)
% -------------------------------------------------------------------------

%grd2.X = grd2.X';
%grd2.Y = grd2.Y';
%grd1.X = grd1.X';
%grd1.Y = grd1.Y';

dx1=grd1.X(end,1);
dy1=grd1.Y(end,1);
grd1 = d3dtranslategrid(grd1,-dx1,-dy1);

dx2=grd2.X(1,1);
dy2=grd2.Y(1,1);
grd2 = d3dtranslategrid(grd2,-dx2,-dy2);

%grd2 = d3drotategrid(grd2,130);

x1=grd1.X(end,end);
y1=grd1.Y(end,end);

x2=grd2.X(1,end);
y2=grd2.Y(1,end);

grd2 = d3drotategrid(grd2,atan2(x2,y2)*180/pi);
grd1 = d3drotategrid(grd1,atan2(x1,y1)*180/pi);

try 
   grd3.X = [grd1.X(1:end-1,:);grd2.X];
   grd3.Y = [grd1.Y(1:end-1,:);grd2.Y];
catch
   error('Grid sizes are not compatible');
end

% dx3=grd3.X(1,1);
% dy3=grd3.Y(1,1);
% grd3 = d3dtranslategrid(grd3,-dx3,-dy3);
% 
% x3=grd3.X(end,1);
% y3=grd3.Y(end,1);
% 
% grd3 = d3drotategrid(grd3,360-atan2(x3,-y3)*180/pi);
% 
% grd3.X = grd3.X';
% grd3.Y = grd3.Y';
