function v=compute_inflow_surge_ct(vmax,rmax,r35,vt,phi,phi_in,w,a,n,lat)
% Computes inflow surge ct
% Script automatically generated by fit_inflow_surge_ct.m
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

% R2    = 0.88138
% RMSE  = 0.7864
% MEAN  = 4.8398
% RANGE = 0.88961 - 10.0066

beta( 1 )= 4.3694e-01 ;
beta( 2 )= 2.0083e+01 ;
beta( 3 )= 4.4248e-01 ;
beta( 4 )= 2.7546e-01 ;
beta( 5 )= 1.3852e-01 ;

v=beta(1).*exp(-(cos(phi*pi/180).*vt)/beta(2)).*w.^beta(3).*r35.^beta(4).*a.^beta(5);
