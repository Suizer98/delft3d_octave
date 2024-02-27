function v=compute_tangential_surge_c1(a,rmax,r35,shelf_width,phi)
% Computes tangential_surge_c1
% Script automatically generated by fit_tangential_surge_c1.m
% Inputs : 
% a              = a (-)
% rmax           = Rmax (km)
% r35            = Rmax (km)
% shelf_width    = width (km)
% phi            = track angle (deg)

% R2    = 0.54692
% RMSE  = 24.1725
% MEAN  = 100.0913
% RANGE = 37.5266 - 181.2973

beta( 1 )= 9.3765e-03 ;
beta( 2 )= 3.3092e-01 ;
beta( 3 )= 1.7899e+02 ;
beta( 4 )= 8.4609e-01 ;
beta( 5 )= 1.2300e-01 ;
beta( 6 )= 8.3576e-01 ;
beta( 7 )= 1.0119e+00 ;
beta( 8 )= 2.1894e+01 ;

v=beta(1) * a.^beta(2) .* max(shelf_width,beta(3)).^beta(4) .* rmax.^beta(5) .* r35.^beta(6) .* (beta(7) + cos((phi-beta(8))*pi/180));