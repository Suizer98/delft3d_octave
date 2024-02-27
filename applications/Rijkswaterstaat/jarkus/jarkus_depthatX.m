function depth = jarkus_depthatX(X,z,x)
% jarkus_depthatX calculates the depth at a certain distance X
%
%   Syntax:
%     depth=jarkus_depthatX(X,altitude,distance)
%
%
%   Input:
%     X = specified distance
%     z = vector with depths at locations x
%     x = vector with distances (for example distance from RSP)
%
%   Output:
%     depth = depth at distance X
%
% See also: JARKUS, snctools

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Tommer Vermaas
%
%       tommer.vermaas@gmail.com
%
%       Rotterdamseweg 185
%       2629HD Delft
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

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 31 Oct 2016
% Created with Matlab version: 8.6.0.267246 (R2015b)

% $Id: jarkus_depthatX.m 12995 2016-11-21 12:45:12Z l.w.m.roest.x $
% $Date: 2016-11-21 20:45:12 +0800 (Mon, 21 Nov 2016) $
% $Author: l.w.m.roest.x $
% $Revision: 12995 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/jarkus/jarkus_depthatX.m $
% $Keywords: $

%%

x = x(~isnan(z)); %cross-shore distance
z = z(~isnan(z)); %altitude at x

if find(x==X) %if X is entry of x
    depth=z(x==X);
elseif ~isempty(x) && max(x)>X && min(x)<X %X not entry of x, but between min(x) and max(x)
    b=find(x<X, 1, 'last' );
    e=find(x>X, 1, 'first');
    
    depth = z(b) - ( ((z(b)-z(e))/(x(b)-x(e))) * (x(b)-X) ); %Interpolate depth.
else %X outside x
    depth=NaN;
end
end
%EOF