function v=compute_ekman_surge_bexn(vmax,rmax,r35,vt,phi,phi_in,w,a,n,lat)
% Computes ekman_surge_bexn
% Script automatically generated by fit_ekman_surge_bexn.m
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

% R2    = 0.019555
% RMSE  = 94.3279
% MEAN  = -28.8886
% RANGE = -130 - 130

beta( 1 )= 1.4695e+01 ;
beta( 2 )= 2.5249e+01 ;
beta( 3 )= -1.4100e+01 ;
beta( 4 )= -2.2124e+00 ;

v=beta(1) + beta(2)*(vt.*cos(phi*pi/180)).^beta(3) + beta(4)*phi_in;