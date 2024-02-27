function xb = xb_run_remote(xb, varargin)
%XB_RUN_REMOTE  Runs a XBeach model remote on the H5 cluster
%
%   Writes a XBeach structure to disk, retrieves a XBeach binary file and
%   runs it at a remote location accessed by SSH (by default, H5 cluster).
%   Supports the use of MPI.
%
%   TODO: UNIX SUPPORT
%
%   Syntax:
%   xb_run_remote(xb)
%
%   Input:
%   xb        = XBeach structure array
%   varargin  = name:       Name of the model run
%               binary:     XBeach binary to use
%               nodes:      Number of nodes to use in MPI mode (1 = no mpi)
%               netcdf:     Flag to use netCDF output (default: false)
%               ssh_host:   Host name of remote computer
%               ssh_user:   Username for remote computer
%               ssh_pass:   Password for remote computer
%               ssh_prompt: Boolean indicating if password prompt should be
%                           used
%               path_local: Local path to the XBeach model
%               path_remote:Path to XBeach model seen from remote computer
%
%   Output:
%   xb        = XBeach structure array
%
%   Preferences:
%   ssh_user        = Username for remote computer
%   ssh_pass        = Password for remote computer
%   path_local      = Local path to the XBeach model
%   path_remote     = Path to XBeach model seen from remote computer
%
%               Preferences overwrite default options (not explicitly
%               defined options) and can be set and retrieved using the
%               xb_setpref and xb_getpref functions.
%
%   Example
%   xb_run_remote(xb)
%   xb_run_remote(xb, 'path_local', 'u:\', 'path_remote', '~/')
%
%   See also xb_run, xb_get_bin

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
% Created: 09 Dec 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: xb_run_remote.m 16468 2020-07-03 09:31:01Z bieman $
% $Date: 2020-07-03 17:31:01 +0800 (Fri, 03 Jul 2020) $
% $Author: bieman $
% $Revision: 16468 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_run/xb_run_remote.m $
% $Keywords: $

%% read options

OPT = struct( ...
    'name', ['xb_' datestr(now, 'YYYYmmddHHMMSS')], ...
    'binary', '', ...
    'version', 'trunk', ...
    'nodes', 1, ...
    'mpidomains',4,...
    'mpitype', 'OPENMPI', ...
    'queuetype', 'normal-e3', ...
    'netcdf', false, ...
    'ssh_host', 'h6', ...
    'email', [], ...
    'ssh_user', '', ...
    'ssh_pass', '', ...
    'ssh_prompt', false, ...
    'path_local', '', ...
    'path_remote', '', ...
    'copy', true ...
);

OPT = setproperty(OPT, varargin{:});

% set preferences
if ~ischar(xb)
    if isempty(OPT.path_local)
        OPT.path_local = xb_getprefdef('path_local', 'u:\');
        OPT.path_remote = xb_getprefdef('path_remote', '~');
    end
    if isempty(OPT.path_remote)
        OPT.path_remote = xb_getprefdef('path_remote', guess_remote_path(OPT.path_local));
    end
end

% check whether we deal with path or XBeach stucture
write = ~(ischar(xb) && (exist(xb, 'dir') || exist(xb, 'file')));

% check if copying is possible
if ~exist(OPT.binary, 'file')
    OPT.copy = false;
end

%% write model

if ~write
    
    OPT.path_local = abspath(regexprep(xb, 'params.txt$', ''));
    
    if ischar(xb)
        fpath = OPT.path_local;
    else
        fpath = xb;
    end
    
    rpath = OPT.path_remote;
    
    if isempty(rpath)
        rpath = guess_remote_path(fpath);
    end
    
else
     
    fpath = fullfile(OPT.path_local, OPT.name);

    if ~exist(fpath,'dir'); mkdir(fpath); end;

    xb_write_input(fullfile(fpath, 'params.txt'), xb);

    rpath = [OPT.path_remote '/' OPT.name];
    
end

if OPT.copy
    if ~exist(fullfile(fpath, 'bin'),'dir')
        mkdir(fullfile(fpath, 'bin'));
    end
end

%% retrieve binary

if isempty(OPT.binary) && strcmpi(OPT.ssh_host,'h4')
    bin_type = 'unix';

    if OPT.nodes > 1
        bin_type = [bin_type ' mpi'];
    end

    if OPT.netcdf
        bin_type = [bin_type ' netcdf'];
    end
    
    OPT.binary = xb_get_bin('type', bin_type);
end

% move downloaded binary to destination directory
if OPT.copy
    binpath = 'bin/xbeach';
    
    if exist(OPT.binary, 'dir') == 7
        copyfile(fullfile(OPT.binary, '*'), fullfile(fpath, 'bin'));
    else
        copyfile(OPT.binary, fullfile(fpath, 'bin', 'xbeach'));

        % copy library versions along
        libdir_src = fullfile(fileparts(OPT.binary),'.libs');
        if exist(libdir_src, 'dir')
            libdir_dst = fullfile(fpath, 'bin', '.libs');
            if ~exist(libdir_dst, 'dir'); mkdir(libdir_dst); end;
            copyfile(fullfile(libdir_src, '*'), libdir_dst);
        end
    end
else
    binpath = OPT.binary;
end

%% write run scripts

fname = xb_write_sh_scripts(fpath, rpath, 'name', OPT.name, 'cluster', OPT.ssh_host, ...
    'email', OPT.email ,'binary', binpath, 'nodes', OPT.nodes, 'mpidomains', OPT.mpidomains,...
    'mpitype', OPT.mpitype, 'version', OPT.version, 'queuetype', OPT.queuetype);

%% run run scripts

[job_id job_name OPT.ssh_user OPT.ssh_pass messages] = ...
    xb_run_sh_scripts(rpath, fname, 'ssh_host', OPT.ssh_host, ...
	'ssh_user', OPT.ssh_user, 'ssh_pass', OPT.ssh_pass, 'ssh_prompt', OPT.ssh_prompt, ...
    'queue',OPT.queuetype);

%% create xbeach structure

sub = xs_empty();
sub = xs_set(sub, 'host', OPT.ssh_host, 'user', OPT.ssh_user, 'pass', OPT.ssh_pass);
sub = xs_meta(sub, mfilename, 'host');

xb = xs_empty();
xb = xs_set(xb, ...
    'path', fpath, ...
    'id', job_id, ...
    'name', job_name, ...
    'nodes', OPT.nodes, ...
    'binary', OPT.binary, ...
    'netcdf', OPT.netcdf, ...
    'ssh', sub, ...
    'messages', messages);
xb = xs_meta(xb, mfilename, 'run', fpath);

%% register job

xb_run_register(xb);

%% private functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function rpath = guess_remote_path(lpath)

    rpath = strrep(lpath,'\','/');
    rpath = regexprep(rpath,'^(\w):','/$1');