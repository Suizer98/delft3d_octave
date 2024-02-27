function varargout = xb_axes(xb, var, varargin)
%XB_AXES  Returns the data axes corresponding to a certain variable
%
%   Returns all data axes corresponding to a certain variable, taking into
%   account the start, stride, length and index used.
%
%   Syntax:
%   varargout = xb_axes(xb, var, varargin)
%
%   Input:
%   xb        = XBeach output structure
%   var       = Variable name
%   varargin  = none
%
%   Output:
%   varargout = Data axes
%
%   Example
%   [t y x] = xb_axes(xb, 'H');
%
%   See also xb_show

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl
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
% Created: 23 Dec 2011
% Created with Matlab version: 7.12.0.635 (R2011a)

% $Id: xb_axes.m 6208 2012-05-15 15:30:24Z hoonhout $
% $Date: 2012-05-15 23:30:24 +0800 (Tue, 15 May 2012) $
% $Author: hoonhout $
% $Revision: 6208 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_lib/xb_axes.m $
% $Keywords: $

%% examine xbeach struct

idx = strcmpi(var, {xb.data.name});

[start len stride index] = xs_get(xb, 'DIMS.START', 'DIMS.LENGTH', 'DIMS.STRIDE', 'DIMS.INDEX');

[start len stride] = xb_index(size(xb.data(idx).value), start, len, stride);

%% crop dimensions

varargout = {};

dims = xb.data(idx).dimensions;

for i = 1:length(dims)
    dim = xs_get(xb, ['DIMS.' dims{i} '_DATA']);
    
    if iscell(index)
        if length(index) >= i
            if ~isempty(index{i})
                varargout{i} = dim(index{i});
                continue;
            end
        end
    elseif i == 1
        if ~isempty(index)
            varargout{i} = dim(index);
            continue;
        end
    end
    
    varargout{i} = dim(start(i)+[1:stride(i):len(i)]);
end
    
