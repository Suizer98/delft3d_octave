function varargout = xb_getprefdef(varargin)
%XB_GETPREFDEF  Gets values for XBeach Toolbox preferences or supplied default
%
%   Gets values for XBeach Toolbox preferences and initialises default
%   preferences if not done yet. Returns supplied default if no preference
%   is found.
%
%   Syntax:
%   varargout = xb_getprefdef(varargin)
%
%   Input:
%   varargin  = list of pairs with preference names and defaults
%
%   Output:
%   varargout = list of corresponding preference values
%
%   Example
%   value = xb_getprefdef(name, default)
%
%   See also xb_setpref

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
% Created: 29 Mar 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: xb_getprefdef.m 4378 2011-04-01 07:01:35Z hoonhout $
% $Date: 2011-04-01 15:01:35 +0800 (Fri, 01 Apr 2011) $
% $Author: hoonhout $
% $Revision: 4378 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_lib/xb_getprefdef.m $
% $Keywords: $

%% get xbeach preferences

if ~ispref('xbeach'); xb_defpref; end;

varargout = {};
for i = 2:2:length(varargin)
    if ispref('xbeach', varargin{i-1})
        varargout{i-1} = getpref('xbeach', varargin{i-1});
        if isempty(varargout{i-1})
            varargout{i-1} = varargin{i};
        end
    else
        varargout{i-1} = varargin{i};
    end
end
