
%function d3dgridexample()
% D3DGRIDEXAMPLE - Recreates the physical domain from Booij (2003)
%
% syntax: d3dgridexample
%
% Booij R. 2003 - Measurements and large-eddy simulations of turbulence, J.
% Turbulence Vol. 4. p.1-17.
%
% 
% See also d3dmakestraightgrid, d3dmakecurvedgrid, d3dplotgrid, wlgrid  
%
% -------------------------------------------------------------------------
%  Copyright (C) 2008 Delft University of Technology
%    Faculty of Civil Engineering and Geosciences
%    Willem Ottevanger  (email: w.ottevanger@tudelft.nl)
%    Version 0.2 (11-08-08)
% -------------------------------------------------------------------------


W = 1.5;
R = 12;
dx = 0.1;
m = W/dx;
dy = 1.5*dx; %0.25;
L1 = 5*W;
n1 = round(L1/dy);
L3 = (28 - angle/180*pi*R/W)*W;
n3 = round(L2/dy);
angle = 135;

file='StruiksmaT2.grd';
enc =[];

n2 = round(R*2*pi*angle/360/dy);

grd1a = d3dmakestraightgrid(W,L1,m,n1);
grd1b = d3dmakestraightgrid(W,L3,m,n3);
%grd2  = d3dmakecurvedgrid  (W,R,angle,m,n2);
grd2  = d3dmakecurvedgrid  (W,R,angle,m,n2);

%grd2  = d3dmakestraightgrid(W,R*2*pi*angle/360,m,n2);

grd3 = d3djoingrid(grd1a,grd2);
grd4 = d3djoingrid(grd3,grd1b);

grd5 = d3drotategrid(grd4,-45);

grd6 = d3dtranslategrid(grd5,-max(grd5.X(:))+L1,-max(grd5.Y(:))+R+W/2)

d3dplotgrid(grd6);

try
   ok=wlgrid('write',file,grd6.X,grd6.Y,enc);
   disp(['Gridfile written to ',file]) 
catch
   error('Function wlgrid could not be accessed')
end


