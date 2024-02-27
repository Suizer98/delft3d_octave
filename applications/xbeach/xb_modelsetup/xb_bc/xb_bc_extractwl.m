function wl = xb_bc_extractwl(xb)
%XB_BC_EXTRACTWL  Extracts water level from XBeach input structure
%
%   Extracts water level from XBeach input structure
%
%   Syntax:
%   wl = xb_bc_extractwl(xb)
%
%   Input:
%   xb          = XBeach input structure
%
%   Output:
%   wl          = water level
%
%   Example
%   wl = xb_bc_extractwl(xb)
%
%   See also xb_bc_extracttp, xb_generate_model

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl	
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 17 Dec 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%% read water level

wl = 0;

if xs_exist(xb, 'zs0file')
    tide = xs_get(xb, 'zs0file.tide');
    switch size(tide, 2)
        case 4
            wl = max(mean(tide(:,1:2),2));
        otherwise
            wl = max(tide(:,1));
    end
elseif xs_exist(xb, 'zs0')
    wl = xs_get(xb, 'zs0');
end
