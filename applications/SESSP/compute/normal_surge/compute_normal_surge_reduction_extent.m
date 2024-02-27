function v=compute_normal_surge_reduction_extent(shelf_width,phi,rmax,r35,a)
% Computes normal surge reduction extent (km)
% Script automatically generated by fit_normal_surge_reduction_extent.m
% Inputs : 
% shelf_width    = width (km)
% phi            = track angle (deg)
% rmax           = rmax (km)
% r35            = r35 (km)
% a              = dean slope (-)

% R2    = 0.82703
% RMSE  = 15.473
% MEAN  = 72.1411
% RANGE = 13.1255 - 155.9004

beta( 1 )= 1.5168e+01 ;
beta( 2 )= 1.1805e-01 ;
beta( 3 )= 1.3517e+00 ;
beta( 4 )= -4.6522e-01 ;
beta( 5 )= -1.1983e+01 ;
beta( 6 )= 1.9483e-01 ;
beta( 7 )= 1.0875e-02 ;
beta( 8 )= 3.1602e-01 ;

v=beta(1) + beta(2)*shelf_width.^beta(3).*(1+beta(4)*cos((phi-beta(5))*pi/180)).*rmax.^beta(6).*r35.^beta(7).*a.^beta(8);