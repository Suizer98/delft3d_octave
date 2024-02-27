function varargout= gade1958(sigma,g,H0,h0,rhow,rhom,nuw,num)
%GADE1958  complex wave number in dispersion relation Gade(1958) for 2-layer system.
%
% k      = gade1958(sigma,g,H0,h0,rhow,rhom,nuw,num)
% [k,k2] = gade1958(...) % returns both roots.
%
% from:
%
%    Herman G. Gade, 1958. "Effects of a nonrigid, impermeable bottom 
%    on plane surface waves in shallow water", J. of Marine Res., 16(2), 61-82.
%
% where:
%
%    k      = complex wave number         [rad/m]
%
%    sigma  = angular frequency           [rad/s]
%    g      = gravity (9.81)              [m/s2]
%    hw (H0)= depth of top water layer    [m]
%    hm (h0)= depth of bottom mud layer   [m]
%    rhow   = density of water layer      [kg/m3]
%    rhom   = density of mud layer        [kg/m3]
%    nuw    = viscosity of water (DUMMY)  [m2/s]
%    num    = viscosity of mud layer      [m2/s]
%
% Note that for hm=0 [m] NaN is returned. Gade does not have a solution
% and solution for hw nearing 0 is not equal to regular dispersion relation.
%
% Note: We found the wollowing errors in the manuscript:
%    1. Eq.  I-25: make the denominator (1-gamma*g*H0*(k/sigma)2)
%    2. Eq.  I-27: replace (1 - Gamma*ho/H0) with (1 + Gamma*ho/H0)
%    3. Fig.    2: tick marks imaginary scale should be [0.1 0.2] instead of [0.001 0.002]
%    4. Eq. II- 8: multiply with sigma
%    5. Eq. II- 9: multiply with sigma
%    6. Eq. II-11: multiply with sigma
%
% Same argument list as fortran subroutine GADE1958 in swanmud.
%
% See also: WAVEDISPERSION, WAVELENGTH (matlab downloadcentral)

% 2009 jun: matched argument order of SWAN Dispersion_Relations.f90

   T = 2*pi./sigma;

%% Case hm=0 should be calculated with limit case
% and gives other answer than standard wave dispersion
% due to different boundary condition

   h0(h0==0) = nan;
   
%% Rest

   gamma     = 1- (rhow./rhom);
  %sigma     = 2.*pi./period;
   m         = (1 - 1i).*sqrt(sigma./2./num);
   GAMMA     = 1-(tanh(m.*h0)./(m.*h0));
  
  %Cmin      = (1 - (GAMMA.*h0./H0)); % error in manuscript of Gade (1958)
   Cpos      = (1 + (GAMMA.*h0./H0));
   C1        = 2.*gamma.*GAMMA.*h0./H0;
  
   k1        = sigma.*sqrt((Cpos  - sqrt(Cpos .^2 - 2.*C1      ))./(g.*H0.*C1        ));
   k2        = sigma.*sqrt((Cpos  + sqrt(Cpos .^2 - 2.*C1      ))./(g.*H0.*C1        ));
 
%% Output

   if     nargout<2
      varargout = {k1};
   elseif nargout==2
      varargout = {k1,k2};
   end

% EOF