function val = get_optval(var, varargin)
%GET_OPTVAL  Retrieves a value from a name/value cell array, if it exists
%
%   Retrieves a value from a opt cell array, if it exists
%
%   Syntax:
%   val = get_optval(var, varargin)
%
%   Input:
%   var         = name variable to be retrieved
%   varargin    = name/value pairs in cell array
%
%   Output:
%   val         = value of requested variable
%
%   Example
%   val = get_optval(var, varargin)
%
%   See also get_optval

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

% $Id: get_optval.m 3766 2010-12-29 15:59:16Z hoonhout $
% $Date: 2010-12-29 23:59:16 +0800 (Wed, 29 Dec 2010) $
% $Author: hoonhout $
% $Revision: 3766 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/struct_fun/get_optval.m $
% $Keywords: $

%% read settings

if length(varargin) == 1 && iscell(varargin)
    varargin = varargin{1};
end

%% get opt value

val = [];

i = find(strcmpi(var, varargin))+1;
if length(varargin) >= i
    val = varargin{i};
end
