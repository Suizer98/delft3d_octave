function v=compute_ekman_surge_cexn(vmax,rmax,r35,vt,phi,phi_in,w,a,n,lat)
% Computes ekman_surge_cexn
% Script automatically generated by fit_ekman_surge_cexn.m
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

% R2    = 0.53749
% RMSE  = 40.4987
% MEAN  = 193.3186
% RANGE = 74.9543 - 294.0514

beta( 1 )= 6.1123e+00 ;
beta( 2 )= 3.5346e-01 ;
beta( 3 )= 3.8844e-01 ;

v=beta(1)*w.^beta(2).*(90-phi).^beta(3);
