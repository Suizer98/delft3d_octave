function [ws] = fallvelocity(D50, rhos, sal, temp)
%FALLVELOCITY(D50, rhos, sal, temp) computes the sediment particle fall velocity water in m/s
%
%   [ws] = fallvelocity(D50, rhos, sal, temp)
%
%   D50: median diameter of the sediment (m)
%   rhos: sediment density (kg/m^3);
%   sal: salinity (psu); Ocean water has a salinity of approximately 35 psu
%   temp: water temperature (degrees Celcius)
%
%   The relations used here are published in 'Principles of sediment transport
%   in rivers estuaries and coastal seas' by L.C. van Rijn (1993), page
%   3.13
%
%   Example:
%   ws = fallvelocity(0.0002,2650, 35, 10)
%
%   CALLS:
%   kinviscwater.m
%   waterdensity0.m
%

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
% Created: 14 Jul 2010
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id: fallvelocity.m 5733 2012-01-20 16:11:22Z boer_g $
% $Date: 2012-01-21 00:11:22 +0800 (Sat, 21 Jan 2012) $
% $Author: boer_g $
% $Revision: 5733 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/phys_fun/fallvelocity.m $
% $Keywords: $

%%

if nargin<2,
    rhos = 2650;
    sal = 35;
    temp = 10;
end

g = 9.81;                                                                       % acceleration of gravity

kinvisc = kinviscwater(sal, temp);
rhow = waterdensity0(sal, temp);
s = rhos./rhow;
for i = 1:length(D50),
    if D50(i) < 0.0001
        ws(i) = ((s - 1) * g * (D50(i)^2)) / (18 * kinvisc);
    else if D50(i) < 0.001
            ws(i) = (10 * kinvisc / D50(i)) * (sqrt(1 + 0.01 * (s - 1) * g * D50(i)^3 / (kinvisc)^2) - 1);
        else ws(i) = 1.1 * sqrt((s - 1) * g * D50(i));
        end
    end
end