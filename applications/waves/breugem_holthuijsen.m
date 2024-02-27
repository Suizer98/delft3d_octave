function [Hs,T] = breugem_holthuijsen(u,h,fetch)
%Computes the wave height and wave period  based on the formulation by
% Young & Verhagen (1996a) modified by Breugem & Holthuijsen (2006)
%
%   Syntax:
%   [Hs,T] = breugem_holthuijsen(u,h,fetch)
%
%   Input:
%   u = wind speed in m/s at 10 m height
%   h = water depth in m
%   fetch = fetch length in m
%
%   Output:
%   Hs = significant wave height (m)
%   T = wave spectrum peak period (s)
%
%   Example
%   [Hs,T] = breugem_holthuijsen(u,h,fetch)
%
%   See also bretschneider

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2016 Arcadis
%       grasmeijerb
%
%       bart.grasmeijer@arcadis.com
%
%       Arcadis Nederland B.V.
%       Hanzelaan 286
%       8017 JJ Zwolle
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 12 Sep 2016
% Created with Matlab version: 9.0.0.341360 (R2016a)

% $Id: breugem_holthuijsen.m 12909 2016-10-06 12:25:35Z bartgrasmeijer.x $
% $Date: 2016-10-06 20:25:35 +0800 (Thu, 06 Oct 2016) $
% $Author: bartgrasmeijer.x $
% $Revision: 12909 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/waves/breugem_holthuijsen.m $
% $Keywords: $

%%
% OPT.keyword=value;
% % return defaults (aka introspection)
% if nargin==0;
%     varargout = {OPT};
%     return
% end
% % overwrite defaults with user arguments
% OPT = setproperty(OPT, varargin);
%% code

% u = 10;       %m/s
% h = 1;        %m
% fetch = 1000; %m
g = 9.82;     %m/s^2

%% Young & Verhagen (1996a) modified by Breugem & Holthuijsen (2006)
Hinf = 0.24;
k1 = 4.14e-4;
m1 = 0.79;
p = 0.572;
k3 = 0.343;
m3 = 1.14;

Tinf = 7.69;
k2 = 2.77e-7;
m2 = 1.45;
q = 0.187;
k4 = 0.10;
m4 = 2.01;

dtilde = g.*h./(u.^2);      % dimensionless depth
Ftilde = g.*fetch./(u.^2);  % dimensionless fetch

Htilde = Hinf.*(tanh(k3.*dtilde.^m3).*tanh(k1.*Ftilde.^m1./(tanh(k3.*dtilde.^m3)))).^p;
Ttilde = Tinf.*(tanh(k4.*dtilde.^m4).*tanh(k2.*Ftilde.^m2./(tanh(k4.*dtilde.^m4)))).^q;

Hs = (Htilde.*u.^2)./g;
T = (Ttilde.*u)./g;