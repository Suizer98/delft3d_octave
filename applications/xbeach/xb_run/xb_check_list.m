function varargout = xb_check_list(varargin)
%XB_CHECK_LIST  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = xb_check_list(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   xb_check_list
%
%   See also 

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
% Created: 01 Apr 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: xb_check_list.m 4381 2011-04-01 08:59:12Z hoonhout $
% $Date: 2011-04-01 16:59:12 +0800 (Fri, 01 Apr 2011) $
% $Author: hoonhout $
% $Revision: 4381 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_run/xb_check_list.m $
% $Keywords: $

%% list timers

timers = timerfindall;

formatstr = '%8s %-10s: %-30s %-20s: %-30s\n';

for i = 1:length(timers)
    fcn = t(i).TimerFcn;
    if strcmpi(func2str(fcn{1}), 'repeatCheck')
        disp(fcn{2}.path);
    end
end
