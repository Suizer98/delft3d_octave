function [Hs,T] = bretschneider(u,h,fetch)
%Computes the wave height and wave period  based on the formulation by
% Bretchneider (1958)
%
%   Syntax:
%   [Hs,T] = bretschneider(u,h,fetch)
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
%   See also breugem_holthuijsen

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

% $Id: bretschneider.m 12910 2016-10-06 12:39:54Z bartgrasmeijer.x $
% $Date: 2016-10-06 20:39:54 +0800 (Thu, 06 Oct 2016) $
% $Author: bartgrasmeijer.x $
% $Revision: 12910 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/waves/bretschneider.m $
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

Hs = (((0.283.*(tanh(0.530.*(g.*h./u.^2).^0.750))).*tanh((0.0125.*((g.*fetch./u.^2).^0.42))/(tanh(0.530.*((g.*h./u.^2).^0.750))))).*u.^2)./g;

T = ((((2.*pi.*1.2).*(tanh(0.833.*(g.*h./u.^2).^0.375))).*tanh((0.077.*((g.*fetch./u.^2).^0.25))/(tanh(0.833.*((g.*h./u.^2).^0.375))))).*u)./g;

