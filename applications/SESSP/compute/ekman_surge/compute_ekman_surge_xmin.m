function v=compute_ekman_surge_xmin(shelf_width,foreward_speed,phi,phi_spiral)
% Computes ekman_surge_xmin
% Script automatically generated by fit_ekman_surge_xmin.m
% Inputs : 
% a              = a (-)
% vmax           = Vmax (km/h)
% shelf_width    = width (km)
% foreward_speed = foreward speed (km/h)
% phi            = track angle (deg)

% R2    = 0.034825
% RMSE  = 81.8187
% MEAN  = -42.4669
% RANGE = -185.3652 - 170.6829

beta( 1 )= 7.2457e+00 ;
beta( 2 )= 5.0650e+03 ;
beta( 3 )= -5.1314e+03 ;
beta( 4 )= -2.5674e+00 ;

v=beta(1) + beta(2)*(foreward_speed.*cos(phi*pi/180)).^beta(3) + beta(4)*phi_spiral;
%v=zeros(size(shelf_width))-50;