function xb = xb_bathy2input(xb, varargin)
%XB_BATHY2INPUT  Adds bathymetry to XBeach input structure
%
%   Adds bathymetry to XBeach input structure. Also supports non-erodible
%   layers.
%
%   Syntax:
%   xb = xb_bathy2input(xb, x, y, z, ne)
%
%   Input:
%   x   = x-coordinates of bathymetry
%   y   = y-coordinates of bathymetry
%   z   = z-coordinates of bathymetry
%   ne  = non-erodible layers in bathymetry
%
%   Output:
%   xb  = XBeach input structure array
%
%   Example
%   xb = xb_bathy2input(xb, x, y, z)
%
%   See also xb_input2bathy, xb_read_bathy, xb_read_input

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

% $Id: xb_bathy2input.m 6208 2012-05-15 15:30:24Z hoonhout $
% $Date: 2012-05-15 23:30:24 +0800 (Tue, 15 May 2012) $
% $Author: hoonhout $
% $Revision: 6208 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_lib/xb_bathy2input.m $
% $Keywords: $

%% convert bathy to input

if ~xs_check(xb)
    xb = xs_empty();
end

if length(varargin) > 0 && ~isempty(varargin{1})
    xb = xs_set(xb, 'xfile', xs_set([], 'xfile', varargin{1}));
    xb = xs_set(xb, 'nx', size(varargin{1},2)-1);
    xb = xs_set(xb, 'ny', size(varargin{1},1)-1);
end

if length(varargin) > 1 && ~isempty(varargin{2})
    xb = xs_set(xb, 'yfile', xs_set([], 'yfile', varargin{2}));
    xb = xs_set(xb, 'nx', size(varargin{2},2)-1);
    xb = xs_set(xb, 'ny', size(varargin{2},1)-1);
end

if length(varargin) > 2 && ~isempty(varargin{3})
    xb = xs_set(xb, 'depfile', xs_set([], 'depfile', varargin{3}));
    xb = xs_set(xb, 'nx', size(varargin{3},2)-1);
    xb = xs_set(xb, 'ny', size(varargin{3},1)-1);
end

if length(varargin) > 3 && ~isempty(varargin{4})
    xb = xs_set(xb, 'ne_layer', xs_set([], 'ne_layer', varargin{4}));
end
