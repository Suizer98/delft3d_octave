function xb_run_remote_multiple(varargin)
%XB_RUN_REMOTE_MULTIPLE  Sends multiple different processes/model runs to
%one single cluster node
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = xb_run_remote_multiple(varargin)
%
%   Input: For <keyword,value> pairs call xb_run_remote_multiple() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   xb_run_remote_multiple
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2014 Deltares
%       Joost den Bieman
%
%       joost.denbieman@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 20 Oct 2014
% Created with Matlab version: 8.2.0.701 (R2013b)

% $Id: xb_run_remote_multiple.m 12401 2015-12-01 12:28:26Z bieman $
% $Date: 2015-12-01 20:28:26 +0800 (Tue, 01 Dec 2015) $
% $Author: bieman $
% $Revision: 12401 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_run/xb_run_remote_multiple.m $
% $Keywords: $

%% Settings
OPT = struct( ...
    'name', ['xb_' datestr(now, 'YYYYmmddHHMMSS')], ...
    'binary', '', ...
    'version', 1.22, ...
    'cores_per_node', 4, ...
    'queuetype', 'normal-e3', ...
    'ssh_host', 'h6', ...
    'email', [], ...
    'ssh_user', '', ...
    'ssh_pass', '', ...
    'ssh_prompt', false, ...
    'rundir', '', ...
    'rundirLocal', '', ...
    'subdirs', '', ...
    'path_remote', ''  ...
);

OPT = setproperty(OPT, varargin{:});

% check whether we deal with path or XBeach stucture
% write = ~(ischar(xb) && (exist(xb, 'dir') || exist(xb, 'file')));

if iscell(OPT.subdirs) 
    nr_runs     = numel(OPT.subdirs);
    nr_nodes    = ceil(nr_runs/OPT.cores_per_node);
else
    error('path_local and path_remote need to be cells');
end

%% Loop over nodes and runs
for iNode = 1:nr_nodes
    MinRun = (iNode-1)*OPT.cores_per_node+1;
    MaxRun = iNode*OPT.cores_per_node;
    RunFilter = MinRun:min(MaxRun,nr_runs);
        
    % write run scripts
    fname = xb_write_sh_scripts_multiple('rundir', OPT.rundir, 'rundirLocal', OPT.rundirLocal, 'subdirs', OPT.subdirs(RunFilter), ...
        'name', [OPT.name num2str(iNode)], 'cluster', OPT.ssh_host, 'email', OPT.email, 'scriptNr', iNode,  ...
        'version', OPT.version, 'queuetype', OPT.queuetype);
    
    % run run scripts
    [job_id job_name OPT.ssh_user OPT.ssh_pass messages] = ...
        xb_run_sh_scripts(OPT.rundir, fname, 'ssh_host', OPT.ssh_host, ...
        'ssh_user', OPT.ssh_user, 'ssh_pass', OPT.ssh_pass, 'ssh_prompt', OPT.ssh_prompt, ...
        'queue',OPT.queuetype);
end