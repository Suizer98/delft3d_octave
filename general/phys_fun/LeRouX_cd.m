function [Cda, Cda_NC] = LeRouX_cd(windspeed,delta_C)
% Equation 2 from La Roex (2008)
% Cd in normal weather conditions
Cda     = (-1.7 * 10^-8 .*delta_C.^3 - 1.4*10^-6.*delta_C.^2 - 3*10^-5.*delta_C + 0.001) .* exp (windspeed.* (-1.6*10^-6 .*delta_C.^3 + 2*10^-5 .*delta_C.^2 + 0.001 .*delta_C + 0.0324));
Cda_NC  = 0.001 * (1.1 + 0.035 .*windspeed); 
end

