function v=compute_ekman_surge_eexp(vmax,rmax,r35,vt,phi,phi_in,w,a,n,lat)
% Computes ekman_surge_eexp
% Script automatically generated by fit_ekman_surge_eexp.m
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

% R2    = 0.85565
% RMSE  = 0.11403
% MEAN  = -0.13704
% RANGE = -0.71934 - 0.39035

beta( 1 )= -8.0370e-01 ;
beta( 2 )= 1.1363e+00 ;
beta( 3 )= 1.7046e+02 ;
beta( 4 )= -5.6058e+00 ;
beta( 5 )= 1.2388e-02 ;
beta( 6 )= -1.3174e-02 ;
beta( 7 )= 5.6660e-04 ;
beta( 8 )= 1.0287e-02 ;
beta( 9 )= 2.5985e-01 ;
beta( 10 )= 1.1785e-01 ;

v=beta(1) + beta(2)*exp(-w/beta(3)) + beta(4)*a + beta(5)*vt + beta(6)*lat + beta(7)*r35 + beta(8)*phi_in + beta(9).*sin(phi*pi/180) + beta(10).*cos(phi*pi/180);