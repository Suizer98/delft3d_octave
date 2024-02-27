function v=compute_inflow_surge_cx(vmax,rmax,r35,vt,phi,phi_in,w,a,n,lat)
% Computes inflow surge cx shift
% Script automatically generated by fit_inflow_surge_cx.m
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

% R2    = 0.85365
% RMSE  = 14.2457
% MEAN  = 114.6558
% RANGE = 31.571 - 184.0797

beta( 1 )= 7.1863e-01 ;
beta( 2 )= 5.8728e-01 ;
beta( 3 )= 5.5235e-01 ;
beta( 4 )= -9.2419e-01 ;
beta( 5 )= -1.1005e+01 ;
beta( 6 )= -3.0909e-01 ;

v=beta(1).*w.^beta(2).*r35.^beta(3).*(1-beta(4).*cos((phi-beta(5))*pi/180)).*vmax.^beta(6);