function WL_t = getWaterlevelWeibull(omega, rho, alfa, sigma, Pexceedance)
%GETWATERLEVELWEIBULL 	routine to get water level from Weibull distribution
%
%   Routine to derive the water level for a specified probability of
%   exceedance based on a Weibull distribution
%
%   syntax:
%   WL_t = getWaterlevelWeibull(omega, rho, alfa, sigma, Pexceedance)
%
%   input:
%       omega           =   lower threshold of distribution [m]
%       rho             =   freqency of exceedance of the threshold level
%                               omega [year^-1]
%       alfa            =   shape parameter
%       sigma           =   scale parameter
%       Pexceedance     =   probability of exceedance [year^-1]
%
%   example:
%
%
%   See also 
%
% -------------------------------------------------------------
% Copyright (c) WL|Delft Hydraulics / TU Delft 2004-2008 FOR INTERNAL USE ONLY
% Version:      Version 1.0, February 2008 (Version 1.0, February 2008)
% By:           <C.(Kees) den Heijer (email: C.denHeijer@tudelft.nl)>
% -------------------------------------------------------------

%%
stepsize = .01;

%%
WL_t = omega; % start at lower threshold level
Pexc = getPexcWeibull(omega, rho, alfa, sigma, WL_t); % corresponding probability of exceedance
while Pexc(end) > Pexceedance
    WL_t(end+1) = WL_t(end) + stepsize; %#ok<AGROW> %
    Pexc(end+1) = getPexcWeibull(omega, rho, alfa, sigma, WL_t(end)); %#ok<AGROW>
end

% semilogx(Pexc,WL_t)

WL_t = interp1(log(Pexc), WL_t, log(Pexceedance));

%%
function Pexc = getPexcWeibull(omega, rho, alfa, sigma, WL_t)
Fexc = rho*exp(-(WL_t/sigma)^alfa + (omega/sigma)^alfa);
Pexc = 1 - exp(-Fexc);