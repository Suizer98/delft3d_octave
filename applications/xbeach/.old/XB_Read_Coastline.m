function [x y ix iy] = XB_Read_Coastline(XB, varargin)
%XB_READ_COASTLINE  Determines the coastline location based on a XBeach grid
%
%   Determines the cells closest to a certain reference level assuming
%   these cells to be part of the coastline. Function only works for 3D
%   Xbeach result structures.
%
%   Syntax:
%   [x y ix iy] = XB_Read_Coastline(XB, varargin)
%
%   Input:
%   XB          = XBeach result structure
%   varargin    = key/value pairs of optional parameters
%                 z     = reference level (default: 0)
%                 t     = time step to be observed (default: 1)
%
%   Output:
%   x           = x-coordinates of coastline
%   y           = y-coordinates of coastline
%   xi          = index numbers of x-coordinates of coastline
%   yi          = index numbers of y-coordinates of coastline
%
%   Example
%   XB_Read_Coastline(XB)
%
%   See also XB_Read_Results, XB_Plot_Results, XB_Animate_Results

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       Bas Hoonhout
%
%       bas@hoonhout.com
%
%       Stevinweg 1
%       2628CN Delft
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

% This tool is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 2 Dec 2009
% Created with Matlab version: 7.5.0.338 (R2007b)

% $Id: XB_Read_Coastline.m 3489 2010-12-02 13:36:58Z heijer $
% $Date: 2010-12-02 21:36:58 +0800 (Thu, 02 Dec 2010) $
% $Author: heijer $
% $Revision: 3489 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/.old/XB_Read_Coastline.m $
% $Keywords: $

%% settings

OPT = struct( ...
    'z', 0, ...
    't', 1 ...
);

OPT = setproperty(OPT, varargin{:});

if ndims(XB.Output.zb) < 3; error('No 3D XBeach result struct given'); end;
    
%% read coastline

% retrieve depth contours at given time step
depth = XB.Output.zb(:,:,OPT.t);

% determine grids closest to reference level
distance = abs(depth - OPT.z);
distanceCL = min(distance, [], 1);
indexCL = find(distance == ones(size(depth,1),1)*distanceCL);

% determine grid indices of coastline
iy = ceil(indexCL./size(depth,1));
ix = mod(indexCL, size(depth,1));

% retrieve grid locations of coastline
x = XB.Output.x(ix, 1);
y = XB.Output.y(1, iy)';