function v=compute_ekman_surge_bexp(vmax,rmax,r35,vt,phi,phi_in,w,a,n,lat)
% Computes ekman_surge_bexp
% Script automatically generated by fit_ekman_surge_bexp.m
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

% R2    = 0.85161
% RMSE  = 13.5371
% MEAN  = -15.8191
% RANGE = -93.1561 - 53.8689

beta( 1 )= -4.3543e+01 ;
beta( 2 )= 5.1680e-03 ;
beta( 3 )= 4.7004e-01 ;
beta( 4 )= 9.0804e-01 ;
beta( 5 )= -5.7470e-02 ;
beta( 6 )= -4.2497e-01 ;
beta( 7 )= 5.0719e+02 ;

v=beta(1) + beta(2)*w .* phi + beta(3)*vt + beta(4)*phi_in + beta(5).*w + beta(6).*lat + beta(7).*a;