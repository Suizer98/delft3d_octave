function v=compute_tangential_surge_xshift(phi,vmax)
% Computes tangential_surge_xshift
% Script automatically generated by fit_tangential_surge_xshift.m
% Inputs : 
% vmax           = Vmax (km/h)
% phi            = track angle (deg)

% R2    = 0.52465
% RMSE  = 6.5307
% MEAN  = 2.638
% RANGE = -22.3439 - 21.047

beta( 1 )= -3.5397e+01 ;
beta( 2 )= 5.0878e+01 ;
beta( 3 )= -6.2095e+01 ;
beta( 4 )= -2.2331e-02 ;

v = beta(1) + beta(2)*sin((phi-beta(3))*pi/180)+beta(4).*vmax;
