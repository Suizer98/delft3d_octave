function [job_id job_name user pass messages] = xb_run_sh_scripts(rpath, script, varargin)
%XB_RUN_SH_SCRIPTS  Run SH scripts on H4 cluster
%
%   Run SH scripts on H4 cluster
%
%   Syntax:
%   [job_id job_name messages] = xb_run_sh_scripts(rpath, script, varargin)
%
%   Input:
%   rpath     = Path where script is located seen from remote source
%   script    = Name of the script to run
%   varargin  = ssh_host:   Host name of remote computer
%               ssh_user:   Username for remote computer
%               ssh_pass:   Password for remote computer
%               ssh_prompt: Boolean indicating if password prompt should be
%                           used
%               cd:         Boolean flag to determine if directory should
%                           be changed to rpath
%
%   Output:
%   job_id    = Job number of process started
%   job_name  = Name of process started
%   messages  = Messages returned by remote source
%
%   Preferences:
%   ssh_user        = Username for remote computer
%   ssh_pass        = Password for remote computer
%
%               Preferences overwrite default options (not explicitly
%               defined options) and can be set and retrieved using the
%               xb_setpref and xb_getpref functions.
%
%   Example
%   job_id = xb_run_sh_scripts('~/', 'run.sh', 'ssh_prompt', true)
%
%   See also xb_run_remote, xb_write_sh_scripts

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
% Created: 15 Feb 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: xb_run_sh_scripts.m 16985 2021-01-08 14:35:09Z ridde_mo $
% $Date: 2021-01-08 22:35:09 +0800 (Fri, 08 Jan 2021) $
% $Author: ridde_mo $
% $Revision: 16985 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_run/xb_run_sh_scripts.m $
% $Keywords: $

%% read options

OPT = struct( ...
    'ssh_host', 'h6', ...
    'ssh_user', '', ...
    'ssh_pass', '', ...
    'ssh_prompt', false, ...
    'queue', 'normal-e3', ...
    'cd', false ...
);

OPT = setproperty(OPT, varargin{:});

%% prompt for password

if OPT.ssh_prompt
    [OPT.ssh_user OPT.ssh_pass] = uilogin;
elseif isempty(OPT.ssh_user) && isempty(OPT.ssh_pass)
    [OPT.ssh_user OPT.ssh_pass] = xb_getpref('ssh_user', 'ssh_pass');
end

if isempty(OPT.ssh_user) && isempty(OPT.ssh_pass)
    error('No username and password found');
end

%% run model

if isunix()
    % use expect to work around ssh password prompt
    cmd = sprintf('expect -c ''spawn ssh %s@%s "dos2unix %s/%s"; expect assword; send "%s\\n"; interact''', ...
        OPT.ssh_user, OPT.ssh_host, rpath, script, OPT.ssh_pass); system(cmd);
    cmd = sprintf('expect -c ''spawn ssh %s@%s "%s/%s"; expect assword; send "%s\\n"; interact''', ...
        OPT.ssh_user, OPT.ssh_host, rpath, script, OPT.ssh_pass);
else
    % use plink for remote command execution
    exe_path = fullfile(fileparts(which(mfilename)), 'plink.exe');
    
    if strcmpi(OPT.ssh_host,'h4') && OPT.cd
        cmd = sprintf('%s %s@%s -pw %s -batch "cd %s && dos2unix %s && %s"', ...
            exe_path, OPT.ssh_user, OPT.ssh_host, OPT.ssh_pass, rpath, script, script);
    elseif strcmpi(OPT.ssh_host,'h5')
        if isempty(OPT.queue)
            cmd = sprintf('%s %s@%s -pw %s -batch "cd %s && qsub %s/%s"', ...
                exe_path, OPT.ssh_user, OPT.ssh_host, OPT.ssh_pass, rpath, rpath, script);
        else
            cmd = sprintf('%s %s@%s -pw %s -batch "cd %s && qsub -q %s %s/%s"', ...
                exe_path, OPT.ssh_user, OPT.ssh_host, OPT.ssh_pass, rpath, OPT.queue, rpath, script);
        end
    elseif strcmpi(OPT.ssh_host,'h6')
        if isempty(OPT.queue)
            cmd = sprintf('%s %s@%s -pw %s -batch "cd %s && qsub %s/%s"', ...
                exe_path, OPT.ssh_user, OPT.ssh_host, OPT.ssh_pass, rpath, rpath, script);
        else
            cmd = sprintf('%s %s@%s -pw %s -batch "cd %s && qsub -q %s %s/%s"', ...
                exe_path, OPT.ssh_user, OPT.ssh_host, OPT.ssh_pass, rpath, OPT.queue, rpath, script);
        end
    elseif strcmpi(OPT.ssh_host,'h6-c7')

        cmd = sprintf('%s %s@%s -pw %s -batch "cd %s && qsub %s/%s"', ...
                exe_path, OPT.ssh_user, 'h6', OPT.ssh_pass, rpath, rpath, script);

    else
        cmd = sprintf('%s %s@%s -pw %s -batch "dos2unix %s/%s && %s/%s"', ...
            exe_path, OPT.ssh_user, OPT.ssh_host, OPT.ssh_pass, rpath, script, rpath, script);
    end
end

cmd = strrep(cmd, '\', '/');

[retcode messages] = system(cmd);

% remove passwords from possible error messages
cmd         = strrep(cmd, OPT.ssh_pass, '*****');
messages    = strrep(messages, OPT.ssh_pass, '*****');

job_id = 0;
job_name = 0;

% extract job number and name
if retcode == 0
    s = regexp(messages, 'Your job (?<id>\d+) \("(?<name>.+)"\) has been submitted', 'names');

    if ~isempty(s)
        job_id = str2double(s.id);
        job_name = s.name;
    else
        disp(messages);
        
        error(['Submitting remote job failed [' cmd ']']);
    end
else
    disp(messages);
    
    error(['Submitting remote job failed [' cmd ']']);
end

user = OPT.ssh_user;
pass = OPT.ssh_pass;