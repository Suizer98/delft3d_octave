function dist = jarkus_distancetoZ(Z,z,x)
% jarkus_distancetoZ calculates the distance to a certain depth Z
% if profile crosses depth multiple times all crossings are given
% this function is used by jarkus_getdepthline
%
%   Syntax:
%     distance=jarkus_distancetoZ(Z,altitude,distance)
%
%   Input:
%     Z = specified depth
%     z = vector with depths at locations x
%     x = vector with distances (for example distance from RSP)
%
%   Output:
%     dist = distance(s) to Z or NaN if profile is not crossed
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

% $Id: jarkus_distancetoZ.m 12995 2016-11-21 12:45:12Z l.w.m.roest.x $
% $Date: 2016-11-21 20:45:12 +0800 (Mon, 21 Nov 2016) $
% $Author: l.w.m.roest.x $
% $Revision: 12995 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/jarkus/jarkus_distancetoZ.m $
% $Keywords: $

%%
x = x(~isnan(z)); %cross-shore distance
if ~iscolumn(x); x=x'; end
z = z(~isnan(z)); %altitude at x
if ~iscolumn(z); z=z'; end

up=z>=Z; %indices of z>=Z
low=z<Z;  %indices of z<=Z
cr_index=up(1:end-1)+low(2:end); %up- and downcrossing indices
cr_index=find(cr_index~=1);
if sum(cr_index~=1)==0 %if no crossings
    dist = NaN;
else %if crossings
    dz  = z(cr_index+1)-z(cr_index);
    dx  = x(cr_index+1)-x(cr_index);
    ddz = (Z-z(cr_index+1))./dz;
    
    dist = x(cr_index+1)+ddz.*dx;
end
end
%EOF