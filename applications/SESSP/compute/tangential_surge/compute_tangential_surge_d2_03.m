function v=compute_tangential_surge_d2_03(vmax,rmax,r35,vt,phi,phi_in,w,a,n,lat)
% Computes tangential_surge_d2
% Script automatically generated by fit_tangential_surge_d2.m
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

% R2    = 0.76887
% RMSE  = 0.54443
% MEAN  = -2.2926
% RANGE = -4.7305 - -0.41894

beta( 1 )= 1.5890e+01 ;
beta( 2 )= -2.9700e+01 ;
beta( 3 )= 6.2111e+00 ;
beta( 4 )= -2.2092e-01 ;
beta( 5 )= -1.4990e+01 ;
beta( 6 )= -2.0238e-02 ;
beta( 7 )= -5.2394e-03 ;

v=beta(1) + beta(2)*(vt.*cos((phi-beta(3))*pi/180)).^beta(4) + beta(5)*a + beta(6)*rmax + beta(7)*w;