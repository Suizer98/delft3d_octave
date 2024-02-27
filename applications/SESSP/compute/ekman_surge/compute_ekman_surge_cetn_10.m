function v=compute_ekman_surge_cetn(vmax,rmax,r35,vt,phi,phi_in,w,a,n,lat)
% Computes ekman_surge_cetn
% Script automatically generated by fit_ekman_surge_cetn.m
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

% R2    = 0.41964
% RMSE  = 2.0685
% MEAN  = 6.6282
% RANGE = 1.6255 - 13.0327

beta( 1 )= 0.0000e+00 ;
beta( 2 )= 9.2818e-02 ;
beta( 3 )= 1.0000e+00 ;
beta( 4 )= -6.4254e-01 ;
beta( 5 )= 3.5500e+00 ;
beta( 6 )= 1.1027e+03 ;
beta( 7 )= 8.7878e-02 ;
beta( 8 )= 1.0000e+00 ;
beta( 9 )= -1.0387e+02 ;
beta( 10 )= 1.4518e+02 ;
beta( 11 )= 8.2716e+01 ;
beta( 12 )= 6.5325e+00 ;

v = (beta(1) + beta(2)*r35.^beta(3) + beta(4)*lat + beta(5).*vt + beta(6)*a.^beta(8) + beta(7)*w + beta(9).*tanh(vmax/beta(10)) + beta(11)*cos((phi-beta(12))*pi/180) ) ./ ((cos(phi*pi/180).*vt));
