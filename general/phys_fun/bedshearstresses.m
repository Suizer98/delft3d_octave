function [fw, TauC, ThetaC, TauW, ThetaW, TauM, ThetaM, TauCW, ...
    ThetaCW, UstarW, UstarCW] = bedshearstresses(Vr, Udelta, T, h, ...
    D50, rhos, rhow)
%BEDSHEARSTRESSES computes shear stresses
%  
%   [fw, TauC, ThetaC, TauW, ThetaW, TauM, ThetaM, TauCW, ...
%    ThetaCW, UstarW, UstarCW] = bedshearstresses(Vr, Udelta, T, h, ...
%    D50, rhos, rhow)
%
%   Computes the wave friction coefficient, current-related shear stress,
%   wave-related shear stress, combined current- and wave-related shear stress 
%   and shear velocities
%
%   Input:
%   Vr is the time- and depth-averaged velocity
%   Udelta is the peak near-bed orbital velocity
%   T is the wave period
%   h is the water depth
%   D50 is the median grain diameter of the sediment
%   rhos is the sediment density
%   rhow is the water density
%   
%   Output:
%   fw is the wave-related friction coefficient
%   TauC is the current-related shear stress
%   ThetaC is the current-related Shields parameter
%   TauW is the wave-related shear stress
%   ThetaW is the wave-related Shields parameter
%   TauCW is the combined wave-current shear stress
%   ThetaCW is the combined wave-current Shields parameter
%
%   Example
%   Untitled
%
%   See also criticalbedshearstress

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Alkyon Hydraulic Consultancy & Research
%       grasmeijerb
%
%       bart.grasmeijer@alkyon.nl	
%
%       P.O. Box 248
%       8300 AE Emmeloord
%       The Netherlands
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 07 Dec 2010
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id: bedshearstresses.m 5733 2012-01-20 16:11:22Z boer_g $
% $Date: 2012-01-21 00:11:22 +0800 (Sat, 21 Jan 2012) $
% $Author: boer_g $
% $Revision: 5733 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/phys_fun/bedshearstresses.m $
% $Keywords: $

%%

g = 9.81;

Adelta = (Udelta .* T)/ (2*pi);                                             % orbital excursion
fw = exp(-5.977 + 5.213 * ((Adelta ./ (2.5 * D50)) .^-0.194));              % friction coefficient
if fw > 0.3
    fw = 0.3;
end
TauW = 0.5 * rhow * fw .* (Udelta).^2;                                      % wave-related shear stress
ThetaW = TauW ./ (g .* (rhos - rhow) .* D50);                               % wave-related shields parameter
TauW = 0.5 * rhow * fw .* (Udelta).^2;                                      % wave-related shear stress based on urms
ThetaW = TauW ./ (g .* (rhos - rhow) .* D50);                               % wave-related shields parameter based on urms

Chezy = 18 * log10(12 * h ./ (2.5 * D50));                                  % Chezy
TauC = rhow .* (g ./ (Chezy).^2) .* (Vr.^2);                                % current-related shear stress
ThetaC = TauC ./ (g .* (rhos - rhow) .* D50);                               % current-related shields parameter
UstarC = sqrt(TauC ./ rhow);

TauM = TauC .* (1 + 1.2 .* ((TauW ./ (TauC + TauW)).^3.2));                 % Soulsby (1997)
ThetaM = TauM ./ (g * (rhos - rhow) * D50);
TauCW = sqrt(TauM.^2 + TauW.^2);
ThetaCW = TauCW ./ (g * (rhos - rhow) * D50);

UstarW = sqrt(0.5 .* fw) .* Adelta .* 2 .* pi ./ T;
UstarCW = sqrt(TauCW ./ rhow);
