function v=compute_tangential_surge_e2(vmax,rmax,r35,vt,phi,phi_in,w,a,n,lat)
% Computes tangential_surge_e2
% Script automatically generated by fit_tangential_surge_e2.m
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

% R2    = 0.83873
% RMSE  = 0.36491
% MEAN  = 1.7157
% RANGE = 0.55654 - 4.3177

beta( 1 )= 1.7026e-02 ;
beta( 2 )= 3.3256e-01 ;
beta( 3 )= 3.7114e-01 ;
beta( 4 )= 3.0382e-01 ;
beta( 5 )= 2.8651e-01 ;

v=beta(1) + beta(2) * w.^beta(3) .* rmax.^beta(4) .* r35.^beta(5) ./ (vt.*cos(phi*pi/180));
