
%function [grd4] = d3dgrid_example()
% D3DGRID_EXAMPLE - Recreates the physical domain from Booij (2003)
%
% syntax: d3dgrid_example
%
% Booij R. 2003 - Measurements and large-eddy simulations of turbulence, J.
% Turbulence Vol. 4. p.1-17.
% 
% See also: d3dmakestraightgrid, d3dmakecurvedgrid, d3dplotgrid, wlgrid, 
%           d3dtestgridorientation
%
% -------------------------------------------------------------------------
%  Copyright (C) 2008 Delft University of Technology
%    Faculty of Civil Engineering and Geosciences
%    Willem Ottevanger  (email: w.ottevanger@tudelft.nl)
%    Version 0.2 (11-08-08)
% -------------------------------------------------------------------------


W = 1.5;
L1 = 5*W;
L2 = 7*W;
R = 12;
%dx = 0.05;
m = 2; %13;%W/dx;
dy = 0.1;%0.1;
n1 = L1/dy;
n2 = L2/dy;
angle = 140;

file='DHL.grd';
enc =[];

n2 = round(R*2*pi*angle/360/dy);

grd1a = d3dmakestraightgrid(W,L1,m,n1);
grd1b = d3dmakestraightgrid(W,L2,m,n2);
%grd2  = d3dmakecurvedgrid  (W,R,angle,m,n2);
grd2  = d3dmakecurvedgrid  (W,R,angle,m,n2);

%grd2  = d3dmakestraightgrid(W,R*2*pi*angle/360,m,n2);

grd3 = d3djoingrid(grd1a,grd2);
grd4 = d3djoingrid(grd3,grd1b);

grd4 = d3dtranslategrid(grd4, 0, -(2*R+W)/2);
grd4 = d3drotategrid(grd4,140+90)
d3dplotgrid(grd4);

try
   ok=WLGRID('write',file,grd4.X,grd4.Y,enc);
   disp(['Gridfile written to ',file]) 
catch
   error('Function wlgrid could not be accessed')
end


