function [dens] = waterdensityp(S,T,P)
%WATERDENSITYP density sea water under pressure P using UNESCO 1983
%
%  [dens] = waterdensityp(S,T,P)
%
% computes the density of sea water under pressure P 
% using UNESCO 1983 (EOS 80) polynomial.
%
% INPUT:  (all must have same dimensions)
%   S = salinity    [psu      (PSS-78)]
%   T = temperature [degree C (IPTS-68)]
%   P = pressure    [db]
%       (P may have dims 1x1, mx1, 1xn or mxn for S(mxn) )
%
% OUTPUT:
%   dens = density  [kg/m^3] 
% 
% This function is adapted based on the function by Phil Morgan 92-11-05 
% (morgan@ml.csiro.au).
%
% REFERENCES:
%    Fofonoff, P. and Millard, R.C. Jr
%    Unesco 1983. Algorithms for computation of fundamental properties of 
%    seawater, 1983. _Unesco Tech. Pap. in Mar. Sci._, No. 44, 53 pp.
%
%    Millero, F.J., Chen, C.T., Bradshaw, A., and Schleicher, K.
%    " A new high pressure equation of state for seawater"
%    Deap-Sea Research., 1980, Vol27A, pp255-264.
%
% CALLEE: waterdensity0.m waterseck.m
%
% UNESCO 1983. eqn.7  p.15
%
%   Copyright (C) CSIRO, Phil Morgan 1992.
%

if nargin ~=3
   error('sw_dens.m: Must pass 3 parameters')
end

% CHECK S,T,P dimensions and verify consistent
[ms,ns] = size(S);
[mt,nt] = size(T);
[mp,np] = size(P);

  
if (ms~=mt) | (ns~=nt)
   error('S & T must have same dimensions')
end

if     mp==1  & np==1         % P is a scalar.  Fill to size of S
   P = P(1)*ones(ms,ns);
elseif np==ns & mp==1         % P is row vector with same cols as S
   P = P( ones(1,ms), : );    %   Copy down each column.
elseif mp==ms & np==1         % P is column vector
   P = P( :, ones(1,ns) );    %   Copy across each row
elseif mp==ms & np==ns        % PR is a matrix size(S)
else
   error('P has wrong dimensions')
end
[mp,np] = size(P);
 
Transpose = 0;
if mp == 1,
   P       =  P(:);
   T       =  T(:);
   S       =  S(:);   
   Transpose = 1;
end

densP0 = waterdensity0(S,T);
K      = waterseck(S,T,P);
P      = P/10; % convert from db to atm pressure units
dens   = densP0./(1-P./K);

if Transpose
   dens = dens';
end

return



	