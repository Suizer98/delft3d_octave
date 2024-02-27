function v=compute_total_surge_xmax(rmax,phi,iid,phi_spiral,shelf_width,a,vmax)
% Computes normal surge along-track shift (in km)
% Script automatically generated by fit_along_track_shift.m
% Inputs : 
% shelf_width    = width (km)
% phi            = track angle (deg)
% a              = dean slope (-)

% R2    = 0.73285
% RMSE  = 11.3963
% MEAN  = 31.9773
% RANGE = 5 - 95.0001

beta( 1 )= 8.7418e+00 ;
beta( 2 )= 1.5351e+00 ;
beta( 3 )= 9.3267e-01 ;
beta( 4 )= 1.2541e+03 ;
beta( 5 )= -1.3434e-02 ;
beta( 6 )= -2.2401e-03 ;
beta( 7 )= 1.0000e+00 ;

v=beta(1)+beta(2).*rmax.*(1+beta(3)*sin(phi*pi/180)).*tanh((shelf_width./a)/beta(4)).*(1+beta(5)*phi_spiral).*(1+beta(6)*vmax.^beta(7));
