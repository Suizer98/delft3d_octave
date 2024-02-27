function [x y z] = xb_grid_trim(x, y, z, varargin)
%XB_GRID_TRIM  Removes all empty rows and columns from a 2D grid
%
%   Removes all rows and columns in a 2D grid containing NaN's only.
%
%   Syntax:
%   [x y z] = xb_grid_trim(x, y, z, varargin)
%
%   Input:
%   x           = x-coordinates of grid to be trimmed
%   y           = y-coordinates of grid to be trimmed
%   z           = elevations of grid to be trimmed
%   varargin    = none
%
%   Output:
%   x           = x-coordinates of trimmed grid
%   y           = y-coordinates of trimmed grid
%   z           = elevations of trimmed grid
%
%   Example
%   [x y z] = xb_grid_trim(x, y, z)
%
%   See also xb_grid_extent

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
% Created: 15 Dec 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: xb_grid_trim.m 3687 2010-12-17 09:52:38Z hoonhout $
% $Date: 2010-12-17 17:52:38 +0800 (Fri, 17 Dec 2010) $
% $Author: hoonhout $
% $Revision: 3687 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_modelsetup/xb_grid/xb_grid_trim.m $
% $Keywords: $

%% read options

if ndims(z) ~= 2; error(['Dimensions of elevation matrix incorrect [' num2str(ndims(z)) ']']); end;

OPT = struct( ...
);

OPT = setproperty(OPT, varargin{:});

%% trim grid

% remove nan's in two dimensions
for n = 1:2
    
    % index cells
    idx = {':' ':'};
    idxs = {':' ':'};
    idxs{n} = [];
    
    for i = 1:size(z,n)
        idx{n} = i;
        if all(isnan(z(idx{:})))
            idxs{n} = [idxs{n} i];
        end
    end
    
    % remove nan columns/rows
    x(idxs{:}) = [];
    y(idxs{:}) = [];
    z(idxs{:}) = [];
end