function v=compute_inflow_surge_amax(vmax,rmax,r35,vt,phi,phi_in,w,a,n,lat)
% Computes inflow surge magnitude
% Script automatically generated by fit_inflow_surge_amax.m
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

% R2    = 0.84383
% RMSE  = 0.086397
% MEAN  = 0.34426
% RANGE = 0.049034 - 0.90167

beta( 1 )= 2.4917e-05 ;
beta( 2 )= 3.5750e-01 ;
beta( 3 )= 2.0365e-01 ;
beta( 4 )= 1.8484e-03 ;
beta( 5 )= 0.0000e+00 ;

v=beta(1).*vmax.*sin(phi_in*pi/180).*w.^beta(2).*a.^-1.*(1+beta(3).*sin(phi*pi/180)) + beta(4)*vt;
