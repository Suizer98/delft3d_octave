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

% R2    = 0.84089
% RMSE  = 17.4856
% MEAN  = -29.2433
% RANGE = -136.1046 - 46.9961

beta( 1 )= -2.4369e+01 ;
beta( 2 )= 5.9122e-03 ;
beta( 3 )= 8.9770e-01 ;
beta( 4 )= 1.2929e+00 ;
beta( 5 )= -1.9810e-01 ;
beta( 6 )= -1.0092e+00 ;
beta( 7 )= 2.2848e+02 ;

v=beta(1) + beta(2)*w .* phi + beta(3)*vt + beta(4)*phi_in + beta(5).*w + beta(6).*lat + beta(7).*a;