function v=compute_inflow_surge_bt(vmax,rmax,r35,vt,phi,phi_in,w,a,n,lat)
% Computes inflow surge t shift
% Script automatically generated by fit_inflow_surge_bt.m
% Inputs : 
% vmax           = Vmax (km/h)
% rmax           = Rmax (km)
% r35            = R35 (km)
% vt             = forward speed (km/h)
% phi            = track angle (deg)
% phi_in         = inflow angle (deg)
% w              = shelf width (km)
% a              = Dean slope a (-)
% n              = Mannings n
% lat            = latitude (deg)

% R2    = 0.86254
% RMSE  = 1.0513
% MEAN  = 2.9829
% RANGE = -1.7439 - 9.9825

beta( 1 )= -6.3057e+00 ;
beta( 2 )= 8.1044e+01 ;
beta( 3 )= 6.3777e-01 ;
beta( 4 )= 2.8613e-01 ;
beta( 5 )= 5.6609e-01 ;

v=beta(1)+beta(2).*(cos(phi*pi/180).*vt).^-1 + beta(3).*a.^beta(4).*w.^beta(5);
