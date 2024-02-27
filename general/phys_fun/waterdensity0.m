function [rhow] = waterdensity0(S,T)
%WATERDENSITY0 density sea water under atmospheric pressure using UNESCO 1983
%
%  [rhow] = waterdensity0(S,T)
%
% computes the density of sea water at atmospheric pressure
% using UNESCO 1983 (EOS 1980) polynomial.
%
% INPUT:  (all must have same dimensions)
%   S = salinity    [psu      (PSS-78)]
%   T = temperature [degree C (IPTS-68)]
%
% OUTPUT:
%   water density  [kg/m^3] of salt water with properties S,T,
%           P=0 (0 db gauge pressure)
% 
% This function is adapted based on the function by Phil Morgan 92-11-05 
% (morgan@ml.csiro.au).
%
% REFERENCES:
%    Fofonoff, P. and Millard, R.C. Jr
%    Unesco 1983. Algorithms for computation of fundamental properties of 
%    seawater, 1983. _Unesco Tech. Pap. in Mar. Sci._, No. 44, 53 pp.
%
%    Millero, F.J. and  Poisson, A.
%    International one-atmosphere equation of state of seawater.
%    Deep-Sea Res. 1981. Vol28A(6) pp625-629.
%
% CALLEE: waterdensitystandardmean.m
%
%   Copyright (C) CSIRO, Phil Morgan 1992
%

if nargin ~=2
   error('waterdensity0.m must pass 2 parameters')
end %if

[mS,nS] = size(S);
[mT,nT] = size(T);

if (mS~=mT) | (nS~=nT)
   error('S,T inputs must have the same dimensions')
end

Transpose = 0;
if mS == 1
  S = S(:);
  T = T(:);
  Transpose = 1;
end

b0 =  8.24493e-1; % define constants UNESCO 1983 eqn(13) p17.
b1 = -4.0899e-3;
b2 =  7.6438e-5;
b3 = -8.2467e-7;
b4 =  5.3875e-9;

c0 = -5.72466e-3;
c1 = +1.0227e-4;
c2 = -1.6546e-6;

d0 = 4.8314e-4;

rhow = waterdensitystandardmean(T) + (b0 + (b1 + (b2 + (b3 + b4.*T).*T).*T).*T).*S  ...
                   + (c0 + (c1 + c2.*T).*T).*S.*sqrt(S) + d0.*S.^2;	       
if Transpose
  rhow = rhow';
end

return	