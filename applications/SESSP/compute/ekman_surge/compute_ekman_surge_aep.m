function v=compute_ekman_surge_aep(vmax,rmax,r35,vt,phi,phi_in,w,a,n,lat)
% Computes ekman_surge_semax
% Script automatically generated by fit_ekman_surge_semax.m
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

% R2    = 0.92459
% RMSE  = 0.15274
% MEAN  = 0.92547
% RANGE = 0.1646 - 2.3675

beta( 1 )= 1.6961e-05 ;
beta( 2 )= 6.0658e-02 ;
beta( 3 )= 7.3640e+01 ;
beta( 4 )= 3.8800e-01 ;
beta( 5 )= 5.6644e-01 ;
beta( 6 )= 6.7201e-01 ;
beta( 7 )= 7.5068e-01 ;
beta( 8 )= -5.4798e-01 ;
beta( 9 )= -6.4188e-02 ;
beta( 10 )= 1.3861e-01 ;

v=beta(1) * exp(-a/beta(2)) .* tanh(w/beta(3)) .* (1+beta(4)*sin(phi*pi/180))  .* vmax.^beta(5)  .* rmax.^beta(10)  .* r35.^beta(6)  .* lat.^beta(7)  .* n.^beta(8)   .* vt.^beta(9);
