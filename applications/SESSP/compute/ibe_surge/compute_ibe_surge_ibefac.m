function v=compute_ibe_surge_ibefac(a,foreward_speed,vmax,rmax,r35,shelf_width,latitude)
% Computes inflow surge magnitude
% Script automatically generated by fit_inflow_surge_amax.m
% Inputs : 
% vmax        = Vmax (km/h)
% phi_piral   = inflow angle (deg)
% shelf_width = width (km)
% a           = Dean slope (-)
% track_angle = track angle (deg)

% R2    = 0.96324
% RMSE  = 0.057512
% MEAN  = 1.2846
% RANGE = 1.0122 - 2.1666

beta( 1 )= 6.4470e-03 ;
beta( 2 )= 2.1740e+00 ;
beta( 3 )= 2.8531e-02 ;
beta( 4 )= -6.0110e-01 ;
beta( 5 )= 4.2311e+01 ;

v=1.0 + beta(1) * (foreward_speed).^beta(2) .* exp(-a/beta(3)) .* rmax.^beta(4) .* tanh(shelf_width/beta(5));
