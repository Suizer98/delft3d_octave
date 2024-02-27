function G0 = getG0(bend)
%GETG0  Returns G0
%
%   More detailed description goes here.
%
%   Syntax:
%   G0 = getG0(bend)
%
%   Input:
%   bend  = coastal bend (bend of the coastline in degrees / 1000 meter)
%
%   Output:
%   G0 = G0 volume to apply in DUROS calculation
%
%   Example
%   G0 = getG0(10);
%
%   See also getG

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
%       Pieter van Geer
%
%       Pieter.vanGeer@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
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
% Created: 12 Jun 2012
% Created with Matlab version: 7.14.0.739 (R2012a)

% $Id: getG0.m 6379 2012-06-12 14:25:13Z geer $
% $Date: 2012-06-12 22:25:13 +0800 (Tue, 12 Jun 2012) $
% $Author: geer $
% $Revision: 6379 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DUROS/applications/2_Coastal_Bend/getG0.m $
% $Keywords: $

%% 

if bend <= 6
    G0 = 0;
elseif bend <= 12
    G0 = 50;
elseif bend <= 18
    G0 = 75;
elseif bend <= 24
    G0 = 100;
else
    G0 = [];
end