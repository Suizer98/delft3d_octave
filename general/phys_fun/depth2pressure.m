function [Pressure] = depth2pressure(Z,lat)

% Pressure = pressure in MPa. 1 MPa = 100 decibar
% Z = depth in m
% lat = latitude in [deg]
    
lat = lat*(pi/180);
p_z45 = 1.00818*10^-2.*Z + 2.465*10^-8.*Z.^2 - 1.25*10^-13.*Z.^3 + 2.8*10^-19.*Z.^4;
g_phi = 9.780318*(1 + 5.2788*10^-3.*(sin(lat).^2) + 2.36*10^-5*(sin(lat).^4));
k_zphi = (g_phi - 2*10^-5.*Z)./(9.80612 - 2*10^-5 .*Z);
Pressure = p_z45 .* k_zphi;
end


