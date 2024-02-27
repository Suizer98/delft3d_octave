function ldb_rotated=rotateLDB(ldb,x0,y0,phi)
%ROTATELDB Rotate a landboundary
%
% This function rotates an existing ldb around an origin (x0,y0) with angle
% phi.
%
% Syntax:
% ldbOut = rotateLDB(ldbIn,x0,y0,phi);
%
% ldbIn:    the landboury, which should already be specified by the 
%           function ldb=landboundary('read','landboundary')
% x0:       x-coordinate of rotation point
% y0:       y-coordinate of rotation point
% phi:      rotation angle (degrees), NB: anti-clockwise rotation!!
% ldbOut:   the output landboury%
% 
% See also: LDBTOOL, ROTATE

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Arjan Mol
%
%       arjan.mol@deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
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

%% Code
ldb=[ldb(:,1)-x0 ldb(:,2)-y0];
phi=deg2rad(phi);
rotMat=[cos(phi) -sin(phi); sin(phi) cos(phi)];
ldb=[ldb*rotMat];
ldb_rotated=[ldb(:,1)+x0 ldb(:,2)+y0];

