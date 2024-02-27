function xb_run_queue(varargin)
%XB_RUN_QUEUE  Queues XBeach runs for local execution
%
%   Queues XBeach runs for local execution. All models are executed one at
%   a time, unless set otherwise. Runs are stored in an XBeach preference
%   variable and monitored using the xb_check_run function. A callback to
%   this function will fire the next model.
%
%   Syntax:
%   xb_run_queue(varargin)
%
%   Input:
%   varargin  = First argument may be an XBeach input structure to be
%               queued. Other arguments are expected to be from the
%               following list:
%               action:     Queue action to perform (add/start/next/clear)
%               options:    Options to be passed to the xb_run function
%               nr:         Number of parallel runs
%
%   Output:
%   none
%
%   Example
%   xb_run_queue(xb)
%   xb_run_queue(xb, 'options', {'binary', 'C:\xbeach.exe'})
%   xb_run_queue
%   xb_run_queue('action', 'next')
%   xb_run_queue('action', 'clear')
%
%   See also xb_run, xb_check_run

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
% Created: 07 Apr 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: xb_run_queue.m 6208 2012-05-15 15:30:24Z hoonhout $
% $Date: 2012-05-15 23:30:24 +0800 (Tue, 15 May 2012) $
% $Author: hoonhout $
% $Revision: 6208 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_run/xb_run_queue.m $
% $Keywords: $

%% read options

if ~isempty(varargin)
    if xs_check(varargin{1})
        xb = varargin{1};
        if length(varargin) > 1 && ~isempty(get_optval('action', varargin(2:end)))
            varargin = varargin(2:end);
        else
            varargin = set_optval('action', 'add', varargin(2:end));
        end
    elseif ischar(varargin{1}) && strcmpi(varargin{1}, 'clear')
        varargin = {'action', 'clear'};
    end
end

OPT = struct( ...
    'action', 'start', ...
    'options', {{}}, ...
    'nr', 1 ...
);

OPT = setproperty(OPT, varargin{:});

%% handle actions

queue = xb_getpref('queue');

switch OPT.action
    case 'add'
        item = struct( ...
            'model', xb, ...
            'status', 'queue', ...
            'options', {varargin}       );
        
        xb_setpref('queue', [queue item]);
        
        xb_run_queue;
    case 'start'
        if isstruct(queue)
            if sum(ismember({queue.status}, 'running')) < OPT.nr

                i = find(ismember({queue.status}, 'queue'), 1, 'first');

                queue(i).status = 'running';

                xb_setpref('queue', queue);

                xb      = queue(i).model;
                opts    = get_optval('options', queue(i).options);

                xbr = xb_run(xb, opts{:});

                xb_check_run(xbr, 'repeat', true, 'callback', {@xb_run_queue, 'action', 'next'});

            end
        end
    case 'next'
        if length(queue) > 1
            xb_setpref('queue', queue(2:end));
            
            xb_run_queue;
        else
            xb_setpref('queue', []);
        end
    case 'clear'
        xb_setpref('queue', []);
    otherwise
        error(['Unknown queue action [' OPT.action ']']);
end
