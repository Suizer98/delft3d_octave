function v=compute_ekman_surge_a1n(latitude,r35,foreward_speed,phi,a,shelf_width)
% Computes ekman_surge_a1n
% Script automatically generated by fit_ekman_surge_a1n.m
% Inputs : 
% a              = a (-)
% vmax           = Vmax (km/h)
% shelf_width    = width (km)
% foreward_speed = foreward speed (km/h)
% phi            = track angle (deg)

% R2    = 0.28004
% RMSE  = 3.0143
% MEAN  = 8.1647
% RANGE = 2.5609 - 17.6493

beta( 1 )= 5.7310e+00 ;
beta( 2 )= 9.7594e-09 ;
beta( 3 )= 2.6226e+00 ;
beta( 4 )= -9.0018e-02 ;
beta( 5 )= -1.9951e-02 ;
beta( 6 )= 8.6201e+01 ;
beta( 7 )= 1.2792e-02 ;

v=beta(1)+beta(2)*r35.^beta(3)+beta(4)*latitude+beta(5)*(cos(phi*pi/180).*foreward_speed)+beta(6)*a+beta(7)*shelf_width;
