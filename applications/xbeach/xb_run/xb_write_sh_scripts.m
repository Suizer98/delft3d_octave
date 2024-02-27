function fname = xb_write_sh_scripts(lpath, rpath, varargin)
%XB_WRITE_SH_SCRIPTS  Writes SH scripts to run applications on H5 cluster using MPI
%
%   Writes SH scripts to run applications on H5 cluster. Optionally
%   includes statements to run applications using MPI.
%
%   Syntax:
%   fname = xb_write_sh_scripts(lpath, rpath, varargin)
%
%   Input:
%   lpath     = Local path to store scripts
%   rpath     = Path to store scripts seen from H4/H5 cluster
%   varargin  = name:       Name of the run
%               binary:     Binary to use
%               nodes:      Number of nodes to use (1 = no MPI)
%               mpitype:    Type of MPI application (MPICH2/OpenMPI)
%
%   Output:
%   fname     = Name of start script
%
%   Preferences:
%   mpitype   = Type of MPI application (MPICH2/OpenMPI)
%
%               Preferences overwrite default options (not explicitly
%               defined options) and can be set and retrieved using the
%               xb_setpref and xb_getpref functions.
%
%   Example
%   fname = xb_write_sh_scripts(lpath, rpath, 'binary', 'bin/xbeach')
%   fname = xb_write_sh_scripts(lpath, rpath, 'binary', 'bin/xbeach', 'nodes', 4)
%
%   See also xb_run_remote

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
% Created: 10 Feb 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: xb_write_sh_scripts.m 16985 2021-01-08 14:35:09Z ridde_mo $
% $Date: 2021-01-08 22:35:09 +0800 (Fri, 08 Jan 2021) $
% $Author: ridde_mo $
% $Revision: 16985 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_run/xb_write_sh_scripts.m $
% $Keywords: $

%% read options

OPT = struct( ...
    'name', ['xb_' datestr(now, 'YYYYmmddHHMMSS')], ...
    'cluster', 'h6', ... 
    'email', [], ... % Fill out email adress to receive mail upon completion or abortion
    'binary', '', ...
    'version', 'trunk', ...
    'nodes', 1, ...
    'mpidomains',4,...
    'queuetype', 'normal-e3', ...
    'mpitype', 'OPENMPI' ...
);

OPT = setproperty(OPT, varargin{:});

[fdir, name, fext] = fileparts(OPT.binary);

% make slashes unix compatible
OPT.binary = strrep(OPT.binary, '\', '/');

% set preferences
if isempty(OPT.mpitype); OPT.mpitype = xb_getprefdef('mpitype', 'MPICH2'); end;

%% write mpi script
fname = 'mpi.sh';

if strcmpi(OPT.cluster,'h4') && ~ismember(OPT.binary(1), {'/' '~' '$'})
    OPT.binary = ['$(pwd)/' OPT.binary];
end

fid = fopen(fullfile(lpath, 'mpi.sh'), 'w');

switch upper(OPT.mpitype)
    case 'OPENMPI'
        fprintf(fid,'#!/bin/sh\n');
        fprintf(fid,'#$ -cwd\n');
        fprintf(fid,'#$ -j yes\n');
        fprintf(fid,'#$ -V\n');
        fprintf(fid,'#$ -N %s\n', OPT.name);
        if ~isempty(OPT.email)
            fprintf(fid,'#$ -M %s\n', OPT.email);
        end
        fprintf(fid,'#$ -m ea\n');
        fprintf(fid,'#$ -q %s\n', OPT.queuetype);
        fprintf(fid,'#$ -pe distrib %d\n\n', OPT.nodes);
        
        switch OPT.cluster
            case 'h5'                
                fprintf(fid,'hostFile="$JOB_NAME.h$JOB_ID"\n\n');
                fprintf(fid,'cat $PE_HOSTFILE | while read line; do\n');
                fprintf(fid,'   echo $line | awk ''{print $1 " slots=" $4}''\n');
                fprintf(fid,'done > $hostFile\n\n');
                xb_write_sh_scripts_xbversions(fid, 'version', OPT.version)
                fprintf(fid,'mpirun -report-bindings -np %d -map-by core -hostfile $hostFile xbeach\n\n', (OPT.nodes*OPT.mpidomains+1));
                fprintf(fid,'rm -f $hostFile\n');
                fprintf(fid,'%s\n', 'echo finished >> finished.txt');
            case 'h6'
                fprintf(fid,'hostFile="$JOB_NAME.h$JOB_ID"\n\n');
                fprintf(fid,'cat $PE_HOSTFILE | while read line; do\n');
                fprintf(fid,'   echo $line | awk ''{print $1 " slots=" $4}''\n');
                fprintf(fid,'done > $hostFile\n\n');
                xb_write_sh_scripts_xbversions(fid, 'version', OPT.version)
                fprintf(fid,'mpirun -report-bindings -np %d -map-by core -hostfile $hostFile xbeach\n\n', (OPT.nodes*OPT.mpidomains+1));
                fprintf(fid,'rm -f $hostFile\n');
                fprintf(fid,'%s\n', 'echo finished >> finished.txt');
            case 'h6-c7'
                fprintf(fid,'hostFile="$JOB_NAME.h$JOB_ID"\n\n');
                fprintf(fid,'cat $PE_HOSTFILE | while read line; do\n');
                fprintf(fid,'   echo $line | awk ''{print $1 " slots=" $4}''\n');
                fprintf(fid,'done > $hostFile\n\n');
                % h6-c7 is not compatible with all the older xbeach versions
                fprintf(fid,'module purge\n');
                fprintf(fid,'module load gcc/7.3.0\n');
                fprintf(fid,'module load hdf5/1.12.0_gcc7.3.0\n');
                fprintf(fid,'module load netcdf/v4.7.4_v4.5.3_gcc7.3.0\n');
                fprintf(fid,'module load openmpi/4.0.4_gcc7.3.0\n');
                fprintf(fid,'module load /opt/apps/modules/xbeach/xbeach-trunk_gcc_7.3.0_openmpi_4.0.4_HEAD\n\n');
                fprintf(fid,'module list\n');
                
                fprintf(fid,'mpirun -report-bindings -np %d -oversubscribe -hostfile $hostFile xbeach\n\n', (OPT.nodes*OPT.mpidomains+1));
                fprintf(fid,'rm -f $hostFile\n');
                fprintf(fid,'%s\n', 'echo finished >> finished.txt');
        end
        
otherwise
        error(['Unknown MPI type [' OPT.mpitype ']']);
end

fclose(fid);
end