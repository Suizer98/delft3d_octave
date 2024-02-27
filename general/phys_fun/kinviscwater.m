function [visc] = kinviscwater(S, T, P)
%KINVISCWATER kinematic viscosity of sea-water based on Dan Kelley's fit to Knauss's TABLE II-8
%
% computes the kinematic viscosity of sea-water.
% based on Dan Kelley's fit to Knauss's TABLE II-8
%
% Input:  (all must have same dimensions)
%   S  = salinity    [psu      (PSS-78) ]
%   T  = temperature [degree C (IPTS-68)]
%   P  = pressure    [db]
%       (P may have dims 1x1, mx1, 1xn or mxn for S(mxn) )
%
% Output:
%   visc = kinematic viscosity of sea-water [m^2/s]
%
%   visc(40.,40.,1000.)=8.200167608E-7
%
% Callee:  waterdensityp.m
%
% Copy from sw_visc by Ayal Anis

%   --------------------------------------------------------------------
%   Copyright (C) 1998 Ayal Anis
%
%       added by Bart Grasmeijer
%
%       grasmeijer@alkyon.nl
%
%       P.O. Box 248, 8300 AE Emmeloord, The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% Created: 03 Apr 2009
% Created with Matlab version: 7.6.0.324 (R2008a)

% $Id: kinviscwater.m 5733 2012-01-20 16:11:22Z boer_g $
% $Date: 2012-01-21 00:11:22 +0800 (Sat, 21 Jan 2012) $
% $Author: boer_g $
% $Revision: 5733 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/phys_fun/kinviscwater.m $
% $Keywords: $

%%


if nargin < 3
    P = 0;
end

% check sal and temp dimensions and verify consistent
[ms,ns] = size(S);
[mt,nt] = size(T);

% check that sal & temp have the same shape
if (ms~=mt) | (ns~=nt)
    error('check_stp: sal & temp must have same dimensions')
end %if

Transpose = 0;
if ms == 1
    T =  T(:);
    S = S(:);
    Transpose = 1;
end

visc = 1e-4.*(17.91-0.5381.*T+0.00694.*T.^2+0.02305.*S)./waterdensityp(S,T,P);

if Transpose
    visc = visc';
end

return

