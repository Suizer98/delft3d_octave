function d3dgrid_example_ashida1990()
% d3dgrid_example_ashida1990 - Recreates the physical domain from Ashida (1990)
%
% syntax: d3dgrid_example_ashida1990
%
% Ashida K., 1990. Sorting and bed topography in meander channels.
% Annuals, Disas. Prev. Res. Inst., Kyoto Univ No 33 B-2.
%
%
% -------------------------------------------------------------------------
%  Copyright (C) 2017 Deltares
%  Willem Otevanger (13/11/2017)
% -------------------------------------------------------------------------

try
    oetroot;
catch
    error('Open Earth Tools not loaded');
end

teta_0 = 35/180*pi;  % [rad] maximum angle
lambda = 2.2;          % [m] wave length
B = 0.2;              % [m] flume width

filename = 'Ashida1990.grd';
ds = 0.025;
scal = 0; %.1834;
s = [0:ds:lambda*4.5+ds]-scal;

enc =[];

phi = teta_0*sin(2*pi*s/lambda);
x(1)= 0;
y(1)= 0;
for j=1:length(s)-1;
    x(j+1) = x(j) + ds*cos(phi(j));
    y(j+1) = y(j) + ds*sin(phi(j));
end

plot(x,y)
axis equal;

mmax = round(4.5*lambda/ds);
nmax = floor(B/ds*2);

grd   = d3dspline2grid(x,y,B,mmax,nmax);
d3dplotgrid(grd);
hold on; plot(x,y,'r.');

try
   ok=wlgrid('write',filename,grd.X,grd.Y,enc);
   disp(['Gridfile written to ',filename])
catch
   error('Function wlgrid could not be accessed')
end
