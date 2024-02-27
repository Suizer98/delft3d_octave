function v=compute_tangential_surge_a2(vmax,rmax,r35,vt,phi,phi_in,w,a,n,lat)
% Computes tangential_surge_a1
% Script automatically generated by fit_tangential_surge_a2.m
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

% R2    = 0.93847
% RMSE  = 0.085392
% MEAN  = 0.46557
% RANGE = 0.09654 - 1.5115

beta( 1 )= 7.0239e-05 ;
beta( 2 )= 2.7052e-02 ;
beta( 3 )= 4.1712e-01 ;
beta( 4 )= -2.7408e-01 ;
beta( 5 )= 6.4647e-02 ;
beta( 6 )= 1.0000e+00 ;
beta( 7 )= -7.2961e-01 ;
beta( 8 )= 7.8630e+01 ;

v=beta(1) * exp(-a/beta(2)) .* w.^beta(3) .* (1+beta(5).*vt) .* vmax.^beta(6) .* n.^beta(4) .* (1+beta(7)*sin((phi-beta(8))*pi/180));
