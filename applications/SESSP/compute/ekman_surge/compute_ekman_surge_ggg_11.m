function v=compute_ekman_surge_ggg(vmax,rmax,r35,vt,phi,phi_in,w,a,n,lat)
% Computes ekman_surge_ggg
% Script automatically generated by fit_ekman_surge_ggg.m
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

% R2    = 0.010146
% RMSE  = 0.0079703
% MEAN  = 0.0034795
% RANGE = 2.2204e-14 - 0.02258

beta( 1 )= 0.0000e+00 ;
beta( 2 )= 9.3238e+02 ;
beta( 3 )= 2.1256e+02 ;
beta( 4 )= -8.5919e+01 ;
beta( 5 )= -1.8005e+00 ;
beta( 6 )= -2.8804e-01 ;
beta( 7 )= 1.1353e+00 ;
beta( 8 )= -6.4740e-01 ;
beta( 9 )= 2.1074e-01 ;

v=beta(1) + beta(2) * exp(-vmax/beta(3)).*(sin((phi-beta(4))*pi/180)).*r35.^beta(5).*lat.^beta(6).*a.^beta(7).*n.^beta(8).*w.^beta(9);
v=max(v,0);
