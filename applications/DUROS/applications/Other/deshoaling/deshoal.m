function Hs2 = deshoal(Hs1,Tp,h1,h2,varargin)
%DESHOAL  calculates the significant wave height at a different depth
%
%   This method is based on linear wave theory. According to this theory
%   the significant wave height at two locations are correlated by:
%
%               Hs2 = Hs1 * (Ks2 / Ks1)
%
%   In this relation Ks values can be obtained by:
%   
%               Ks = sqrt( cg0 / cg )
%   
%   cg0 is constant at any location. Combining this with the first relation 
%   gives:
%
%               Hs2 = Hs1 * (cg1 / cg2)
%
%   To calculate the wave height at a location with a different depth,
%   therefore only the wave group velocity (cg) has to be calculated
%   according to:
%
%               cg = ((g * Tp) / (2 * pi())) * n
%
%   in which:
%
%               n = 0.5 + kh / sinh(2kh)
%
%               k = 2*pi() / L
%
%   All variables are known except for the wave length (L). Wave lengths
%   can be calculated according to:
%
%               L = L0 * tanh (2*pi()*h / L)
%
%   in which:
%
%               L0 = (g * Tp^2) / (2 * pi())
%
%   With this set of equations L can be calculated iteratively and
%   substituded in the equations above. This will finally lead to the
%   significant wave height at the required output depth (Hs2).
%
%   Syntax:
%   Hs2 = deshoal(Hs1,Tp,h1,h2)
%
%   Input:
%   Hs1     = Given significant wave height [m]
%   Tp      = Input wave peak period [s]
%   h1      = depth at which Hs and Tp are given in m (if not specified, 
%               h1 = 8 [m]).
%   h2      = required output depth (if not specified, h2 = 20 [m]).
%
%   Output:
%   Hs2      = Calculated significant wave height at the depth of h2.
%
%   Example
%   Untitled
%
%   See also iterateWaveLength

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Pieter van Geer
%
%       pieter.vangeer@deltares.nl	
%
%       <ADDRESS>
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% Created: 26 Jan 2009
% Created with Matlab version: 7.6.0.324 (R2008a)

% $Id: deshoal.m 1660 2009-02-11 16:07:51Z geer $
% $Date: 2009-02-12 00:07:51 +0800 (Thu, 12 Feb 2009) $
% $Author: geer $
% $Revision: 1660 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DUROS/applications/Other/deshoaling/deshoal.m $
% $KeyWords: shoaling wave deshoaling

%% process input
if nargin<2
    error('Deshoal:NotEnoughInput','Not egnough input arguments');
end
if nargin == 2
    h2 = 20;
    h1 = 8;
end
if nargin == 3
    h2 = 20;
end

g = 9.81;
if nargin > 4
    g = varargin{1};
end

%% calculate cg at input location / depth
L1 = iterateWaveLength(h1,Tp,g);
k1 = (2*pi()) / L1;
c1 = L1/Tp;
n1 = 0.5+(k1.*h1)./(sinh(2*k1.*h1));
cg1 = c1 * n1;

%% calculate cg at output location / depth
L2 = iterateWaveLength(h2,Tp,g);
k2 = (2*pi()) / L2;
c2 = L2/Tp;
n2 = 0.5+(k2.*h2)./(sinh(2*k2.*h2));
cg2 = c2 * n2;

%% Calculate Hs2 at output location
Hs2  = Hs1 * (sqrt(cg1) / sqrt(cg2));