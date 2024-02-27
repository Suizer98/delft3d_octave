function runs = xb_check_run(xb, varargin)
%XB_CHECK_RUN  Checks whether a run from an XBeach input structure is still running
%
%   Checks whether a run started using either xb_run or xb_run_remote is
%   still running. The check can be repeated using a certain time interval
%   to get a warning once the run is finished.
%
%   Syntax:
%   runs = xb_check_run(xb, varargin)
%
%   Input:
%   xb        = XBeach run structure
%   varargin  = repeat:     boolean flag to determine if the check is
%                           repeated
%               interval:   seconds between checks, if repeated
%               display:    boolean to determine whether a message is
%                           displayed after process has finished
%               sound:      boolean to determine whether a sound is made
%                           after process has finished
%               callback:   callback function fired after process has
%                           finished
%
%   Output:
%   runs      = boolean that indicates whether the job is still running
%
%   Example
%   xb_check_run(xb)
%
%   See also xb_run, xb_run_remote

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
% Created: 10 Dec 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: xb_check_run.m 7531 2012-10-19 11:14:02Z hoonhout $
% $Date: 2012-10-19 19:14:02 +0800 (Fri, 19 Oct 2012) $
% $Author: hoonhout $
% $Revision: 7531 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_run/xb_check_run.m $
% $Keywords: $

%% read options

OPT = struct( ...
    'repeat', false, ...
    'interval', 60, ...
    'display', true, ...
    'sound', true, ...
    'callback', {{0}} ...
);

OPT = setproperty(OPT, varargin{:});

if ~iscell(OPT.callback); OPT.callback = {OPT.callback}; end;

OPT.interval = xb_getprefdef('interval', OPT.interval);

%% check run

runs = false;

if xs_exist(xb, 'ssh')
    % remote job
    exe_path = fullfile(fileparts(which(mfilename)), 'plink.exe');
    
    [host user pass id messages] = xs_get(xb, 'ssh.host', 'ssh.user', 'ssh.pass', 'id', 'messages');

    cmd = sprintf('%s %s@%s -pw %s -batch ". /opt/sge/InitSGE && qstat -u %s"', ...
            exe_path, user, host, pass, user);

    [retcode messages] = system(cmd);

    if ~isempty(regexp(messages, ['(^|\n)\s*' num2str(id) '\s'], 'once'))
        runs = true;
    end
elseif xs_exist(xb, 'id')
    % local job
    
    id = xs_get(xb, 'id');
    
    % get current running xbeach instances
    [r tasklist] = system('tasklist /FI "IMAGENAME eq xbeach.exe"');
    if regexp(tasklist, ['xbeach.exe\s+' num2str(id) '\s+'], 'start')
    	runs = true;
    end
end

%% start timer

if OPT.repeat && runs
     t = timer( ...
         'TimerFcn', {@repeatCheck,xb,OPT}, ...
         'ExecutionMode', 'fixedDelay', ...
         'Period', OPT.interval ...
     );
 
    start(t);
end

%% private functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function repeatCheck(obj, event, xb, OPT)

if ~xb_check_run(xb)
    stop(obj); delete(obj);
    
    % halleluja
    if OPT.sound
        try
            load handel;
            sound(y,Fs);
        end
    end
    
    if OPT.display
        msg = sprintf([ 'XBeach run "%s" [%d] has finished. \n' ...
                        'Model output is stored in the following location: \n\n' ...
                        '%s' ], ...
                        xs_get(xb, 'name'), xs_get(xb, 'id'), xs_get(xb, 'path'));
    
        msgbox(msg,'Run has finished','warn','modal')
    end
    
    % fire callback function
    if isa(OPT.callback{1}, 'function_handle')
        OPT.callback = {OPT.callback{1} xb OPT.callback{2:end}};
        feval(OPT.callback{:});
    end
end
