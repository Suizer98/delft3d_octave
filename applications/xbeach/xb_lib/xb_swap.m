function xb = xb_swap(xb, varargin)
%XB_SWAP  Swap dimensions of XBeach output matrices from new to old convention and back
%
%   Swaps dimensions of matrices in XBeach output structure from the order
%   t,y,x to x,y,t and back. Current order is determined based on dimension
%   information included in the XBeach structure (DIMS). If the current
%   dimension order cannot be determined, the given order is used. Usage of
%   the given order can also be forced. Returns the modified XBeach
%   structure.
%
%   Syntax:
%   xb = xb_swap(xb, varargin)
%
%   Input:
%   xb          = XBeach output structure
%   varargin    = order:        Current dimension order (tyx/xyt)
%                 force:        Boolean to determine whether given order
%                               should be used in all cases or not
%
%   Output:
%   xb          = Modified XBeach output structure
%
%   Example
%   xb = xb_swap(xb)
%   xb = xb_swap(xb, 'order', 'xyt', 'force', true)
%
%   See also xb_read_output

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
% Created: 28 Dec 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: xb_swap.m 6208 2012-05-15 15:30:24Z hoonhout $
% $Date: 2012-05-15 23:30:24 +0800 (Tue, 15 May 2012) $
% $Author: hoonhout $
% $Revision: 6208 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_lib/xb_swap.m $
% $Keywords: $

%% read options

if ~xs_check(xb); error('Invalid XBeach structure'); end;

OPT = struct( ...
    'order', 'tyx', ...
    'force', false ...
);

OPT = setproperty(OPT, varargin{:});

%% determine dimensions

if xs_exist(xb, 'DIMS')
    nx = max([0 xs_get(xb, 'DIMS.globalx')]);
    ny = max([0 xs_get(xb, 'DIMS.globaly')]);
    nt = max([0 xs_get(xb, 'DIMS.globaltime')]);
end

%% swap matrices

for i = 1:length(xb.data)
    v = xb.data(i).value;
    if isnumeric(v) && ndims(v) >= 3
        s = size(v);
        
        % detremine current dimension order
        if ~OPT.force && s(1) == nt && s(2) == ny && s(3) == nx
            perm = [3 2 4:ndims(v) 1];
        elseif ~OPT.force && s(1) == nx && s(2) == ny && s(end) == nt
            perm = [ndims(v) 2 1 3:ndims(v)-1];
        else
            switch OPT.order
                case 'tyx'
                    perm = [3 2 4:ndims(v) 1];
                case 'xyt'
                    perm = [ndims(v) 2 1 3:ndims(v)-1];
                otherwise
                    % skip if unknowm
                    continue;
            end
        end
        
        xb.data(i).value = permute(v, perm);
        if isfield(xb.data, 'dimensions') && ~isempty(xb.data(i).dimensions)
            xb.data(i).dimensions = xb.data(i).dimensions(perm);
        end
    end
end
