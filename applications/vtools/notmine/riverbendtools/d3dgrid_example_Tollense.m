
%function [grd4] = d3dgrid_example()
% D3DGRID_EXAMPLE - Recreates the physical domain from Booij (2003)
%
% syntax: d3dgrid_example
%
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


W = 30.8100;
L = (134.2352-2*36)+4*36;
L1 = 2*36;
L2 = 2*36;
R = 35;
%dx = 0.05;
n = 39; %13;%W/dx;
m = 319;
dm = L/m;
dn = W/n;

m1 = round(L1/dm);
m2 = round(L2/dm);
m3 = m-m1-m2;
angle = (L-L1-L2)/(2*pi*R)*360

file=['TolleSc',num2str(R),'.grd'];
enc =[];

%n2 = round(R*2*pi*angle/360/dy);

grd1a = d3dmakestraightgrid(W,L1,n,m1);
grd1b = d3dmakestraightgrid(W,L2,n,m2);
%grd2  = d3dmakecurvedgrid  (W,R,angle,m,n2);
grd2  = d3dmakecurvedgrid  (W,R,angle,n,m3);

%grd2  = d3dmakestraightgrid(W,R*2*pi*angle/360,m,n2);

grd3 = d3djoingrid(grd1a,grd2);
grd4 = d3djoingrid(grd3,grd1b);

grd4 = d3dtranslategrid(grd4, 0, -(2*R+W)/2);
grd4 = d3drotategrid(grd4,angle+90)
d3dplotgrid(grd4);

try
   ok=WLGRID('write',file,grd4.X,grd4.Y,enc);
   disp(['Gridfile written to ',file]) 
catch
   error('Function wlgrid could not be accessed')
end


