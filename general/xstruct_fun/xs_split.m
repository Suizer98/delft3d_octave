function varargout = xs_split(xs, varargin)
%XS_SPLIT  Splits a XStruct in multiple XStructs
%
%   Splits a XStruct in multiple XStructs by moving
%   several fields to one XStruct and others to another. User '*'
%   to select all non-matched fields.
%
%   Syntax:
%   varargout = xs_split(xs, varargin)
%
%   Input:
%   xs        = XStruct array
%   varargin  = List of fields to be stored in one XStruct. To
%               store multiple fields in a XStruct, use a cell
%               array of field names as item in the list.
%
%   Output:
%   varargout = List of XStruct arrays.
%
%   Example
%   [xs1 xs2 xs3] = xs_split(xs, {'nx' 'ny'}, 'bcfile', {'xfile', 'yfile'})
%
%   See also xs_join, xs_empty, xs_set, xs_get

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

% $Id: xs_split.m 6208 2012-05-15 15:30:24Z hoonhout $
% $Date: 2012-05-15 23:30:24 +0800 (Tue, 15 May 2012) $
% $Author: hoonhout $
% $Revision: 6208 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/xstruct_fun/xs_split.m $
% $Keywords: $

%% split structures

varargout = {};

ri = nan;
r  = false(size(xs.data));

for i = 1:length(varargin)
    f = varargin{i};
    
    if ~iscell(f)
        f = {f};
    end
    
    if ~ismember('*', f)
        idx = ismember({xs.data.name}, f);

        r(idx) = true;

        varargout{i} = xs;
        varargout{i}.data = xs.data(idx);
    else
        ri = i;
    end
end

if ~isnan(ri)
    varargout{ri} = xs;
	varargout{ri}.data = xs.data(~r);
end
