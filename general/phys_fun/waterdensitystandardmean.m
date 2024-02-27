function dens = waterdensitystandardmean(T)
%WATERDENSITYSTANDARDMEAN(T) density of standard mean sea water (pure water) using EOS 1980
%
% computes the density of standard mean ocean water 
%(pure water) using EOS 1980. 
%
% INPUT: 
%   T = temperature [degree C (IPTS-68)]
%
% OUTPUT:
%   dens = density  [kg/m^3] 
% 
% This function is adapted based on the function by Phil Morgan 92-11-05 
% (morgan@ml.csiro.au).
%
% REFERENCES:
%     Unesco 1983. Algorithms for computation of fundamental properties of 
%     seawater, 1983. _Unesco Tech. Pap. in Mar. Sci._, No. 44, 53 pp.
%     UNESCO 1983 p17  Eqn(14)
%
%     Millero, F.J & Poisson, A.
%     INternational one-atmosphere equation of state for seawater.
%     Deep-Sea Research Vol28A No.6. 1981 625-629.    Eqn (6)
%
%   Copyright (C) CSIRO, Phil Morgan 1992
%

if nargin ~= 1
   error('Only one input argument allowed')
end

Transpose = 0;
[mT,nT] = size(T);
if mT == 1
   T = T(:);
   Transpose = 1;
end

a0 = 999.842594;
a1 =   6.793952e-2;
a2 =  -9.095290e-3;
a3 =   1.001685e-4;
a4 =  -1.120083e-6;
a5 =   6.536332e-9;

dens = a0 + (a1 + (a2 + (a3 + (a4 + a5*T).*T).*T).*T).*T;

if Transpose
  dens = dens';
end

return
