function xs = xs_rename(xs, varargin)
%XS_RENAME  Renames one or more fields in XStruct
%
%   Renames one or more fields in XStruct and returns the
%   resulting structure.
%
%   Syntax:
%   xs = xs_rename(xs, varargin)
%
%   Input:
%   xs        = XStruct array
%   varargin  = List of pairs of old and new fieldnames (e.g.
%               'old1','new1','old2','new2',...)
%
%   Output:
%   xs        = XStruct array
%
%   Example
%   xs = xs_rename(xs, 'globalx', 'x', 'globaly', 'y')
%
%   See also xs_empty, xs_get, xs_set, xs_del

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
% Created: 03 Dec 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: xs_rename.m 6208 2012-05-15 15:30:24Z hoonhout $
% $Date: 2012-05-15 23:30:24 +0800 (Tue, 15 May 2012) $
% $Author: hoonhout $
% $Revision: 6208 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/xstruct_fun/xs_rename.m $
% $Keywords: $

%% rename fields

if ~xs_check(xs); error('Invalid XStruct'); end;

if ~isempty([varargin{:}])
    if length(varargin) == 1
        old = varargin;
        new = {input([varargin{1} ': '], 's')};
    else
        old = varargin(1:2:end);
        new = varargin(2:2:end);
    end
    
    for i = 1:length(new)
        idx = strcmpi(old{i}, {xs.data.name});
        xs.data(idx).name = new{i};
    end
end
