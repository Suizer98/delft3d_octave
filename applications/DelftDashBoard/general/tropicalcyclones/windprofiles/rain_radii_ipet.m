function [pr] = rain_radii_ipet(pdef, rmax, radius)
% Function to calculate the rainfall intensity based on the USACE' IPET rainfall model
% Based on the pressure deficit and the radius of maximum wind
% Between the Eye and rmax the rainfall rate is constant
% Input rmax and radius in km

 pr = NaN(size(radius));
                
for ip = 1:length(radius)
    if radius(ip) <= rmax
        pr(ip) = 1.14 + (0.12*pdef);
    elseif radius(ip) > rmax
        pr(ip) = (1.14 + (0.12*pdef)) * exp(-0.3*((radius(ip)-rmax)/rmax));
    end                
end          