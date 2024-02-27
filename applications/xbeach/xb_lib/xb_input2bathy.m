function [x y z ne] = xb_input2bathy(xb, varargin)
%XB_INPUT2BATHY  Reads bathymetry from XBeach input structure
%
%   Converts XBeach input structure to a bathymetry with x, y and z values.
%   Also supports reading of non-erodible layers.
%
%   Syntax:
%   [x y z ne] = xb_input2bathy(xb)
%
%   Input:
%   xb  = XBeach input structure array
%
%   Output:
%   x   = x-coordinates of bathymetry
%   y   = y-coordinates of bathymetry
%   z   = z-coordinates of bathymetry
%   ne  = non-erodible layers in bathymetry
%
%   Example
%   [x y z] = xb_input2bathy(xb)
%
%   See also xb_bathy2input, xb_read_bathy, xb_read_input

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
% Created: 02 Dec 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: xb_input2bathy.m 6208 2012-05-15 15:30:24Z hoonhout $
% $Date: 2012-05-15 23:30:24 +0800 (Tue, 15 May 2012) $
% $Author: hoonhout $
% $Revision: 6208 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_lib/xb_input2bathy.m $
% $Keywords: $

%% convert input to bathy

if ~xs_check(xb); error('Invalid XBeach structure'); end;

if xs_exist(xb, 'xyfile')
    xb = xb_grid_delft3d(xb);
end

[x y z ne] = xs_get(xb, 'xfile.xfile', 'yfile.yfile', 'depfile.depfile', 'ne_layer.ne_layer');
