function xb_run_unregister(id)
%XB_RUN_UNREGISTER  Unregister registered run
%
%   Unregister run registered by xb_run_register
%
%   Syntax:
%   xb_run_unregister(id)
%
%   Input:
%   id        = Run index to be unregistered
%
%   Output:
%   none
%
%   Example
%   xb_run_unregister(1234)
%
%   See also xb_run_register

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
% Created: 15 Mar 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: xb_run_unregister.m 6208 2012-05-15 15:30:24Z hoonhout $
% $Date: 2012-05-15 23:30:24 +0800 (Tue, 15 May 2012) $
% $Author: hoonhout $
% $Revision: 6208 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_run/xb_run_unregister.m $
% $Keywords: $

%% unregister run

runs = xb_getpref('runs');

if ~isempty(runs) && iscell(runs)
    for i = 1:length(runs)
        if xs_check(runs{i})
            if ismember(xs_get(runs{i}, 'id'), str2double(id))
                runs(i) = [];
                break;
            end
        end
    end

    xb_setpref('runs', runs);
end
