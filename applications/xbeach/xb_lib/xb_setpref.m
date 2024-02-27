function xb_setpref(varargin)
%XB_SETPREF  Sets customised preferences for XBeach Toolbox
%
%   Sets customised preferences for XBeach Toolbox and initialises default
%   preferences if not done yet.
%
%   Syntax:
%   xb_setpref(varargin)
%
%   Input:
%   varargin  = name/value pairs of preferences
%
%   Output:
%   none
%
%   Example
%   xb_setpref('interactive', false);
%   xb_setpref('interactive', false, 'ssh_user', ' ... ', 'ssh_pass', ' ... ');
%
%   See also xb_defpref, xb_getpref

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
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
% Created: 05 Jan 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: xb_setpref.m 3837 2011-01-10 09:29:20Z hoonhout $
% $Date: 2011-01-10 17:29:20 +0800 (Mon, 10 Jan 2011) $
% $Author: hoonhout $
% $Revision: 3837 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_lib/xb_setpref.m $
% $Keywords: $

%% set xbeach preferences

if ~ispref('xbeach') || isempty(varargin)
    xb_defpref;
end

for i = 2:2:length(varargin)
    setpref('xbeach', varargin{i-1}, varargin{i});
end
