%function v=compute_inflow_surge_ct(vmax,rmax,r35,vt,phi,phi_in,w,a,n,lat)
function v=compute_inflow_surge_ct(w,phi,vt,a,r35)
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

% R2    = 0.88673
% RMSE  = 0.83558
% MEAN  = 5.0696
% RANGE = 0.9374 - 10.931

beta( 1 )= 3.3790e-01 ;
beta( 2 )= 1.9168e+01 ;
beta( 3 )= 4.5185e-01 ;
beta( 4 )= 3.2775e-01 ;
beta( 5 )= 1.5195e-01 ;

v=beta(1).*exp(-(cos(phi*pi/180).*vt)/beta(2)).*w.^beta(3).*r35.^beta(4).*a.^beta(5);