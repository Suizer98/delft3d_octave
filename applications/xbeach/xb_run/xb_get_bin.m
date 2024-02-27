function fpath = xb_get_bin(varargin)
%XB_GET_BIN  Retrieves a XBeach binary from a remote source
%
%   Retrieves a XBeach binary from a remote source. By default this is the
%   latest binary from the TeamCity build server. Several flavours of
%   binaries exist. By default the normal win32 binary is downloaded. A
%   custom host can be provided as well. Returns the location where the
%   downloaded binary can be found.
%
%   WARNING: SOME BINARY TYPES ARE STILL MISSING, SINCE NOT AVAILABLE IN
%   TEAMCITY YET
%
%   Syntax:
%   fpath = xb_get_bin(varargin)
%
%   Input:
%   varargin  = type:       Type of binary (win32/unix/mpi/netcdf).
%                           Multiple qualifiers separated by a space can be
%                           used. Specifying "custom" will use the host
%                           provided in the equally named varargin
%                           parameter.
%               host:       Host to be used in case of custom type.
%
%   Output:
%   fpath     = Path to downloaded executable
%
%   Example
%   fpath = xb_get_bin()
%   fpath = xb_get_bin('type', 'win32 mpi')
%   fpath = xb_get_bin('type', 'win32 netcdf')
%   fpath = xb_get_bin('type', 'win32 netcdf mpi')
%   fpath = xb_get_bin('type', 'unix netcdf mpi')
%   fpath = xb_get_bin('type', 'custom', 'host', ' ... ')
%
%   See also xb_run

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

% $Id: xb_get_bin.m 5234 2011-09-14 13:02:27Z hoonhout $
% $Date: 2011-09-14 21:02:27 +0800 (Wed, 14 Sep 2011) $
% $Author: hoonhout $
% $Revision: 5234 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_run/xb_get_bin.m $
% $Keywords: $

%% read options

OPT = struct( ...
    'type', 'win32', ...
    'host', '' ...
);

OPT = setproperty(OPT, varargin{:});

OPT.type = regexp(OPT.type, '\s+', 'split');

warning('OET:xbeach:underconstruction', [...
    'Warning: the automatic retrieval of XBeach executables depend on ' ...
    'daily builds that come from a build server. Currently, the default ' ...
    'XBeach build server is out of order. Therefore, executable obtained ' ...
    'using this function may be from ancient Rome.']);

%% define default hosts

hosts = struct( ...
    'win32', 'http://content.oss.deltares.nl/xbeach/testbed/bin/xbeach_trunk.exe', ...
    'win32_mpi', 'http://content.oss.deltares.nl/xbeach/testbed/bin/xbeach_mpi.exe', ...
    'win32_mpi_netcdf', '', ...
    'win32_netcdf', 'http://content.oss.deltares.nl/xbeach/testbed/bin/xbeach_netcdf.exe', ...
    'unix', 'https://build.deltares.nl/guestAuth/repository/download/bt145/.lastSuccessful/executable/trunk/nompi/xbeach', ...
    'unix_mpi', 'https://build.deltares.nl/guestAuth/repository/download/bt146/.lastSuccessful/executable/trunk/mpi/xbeach', ...
    'unix_mpi_netcdf', '', ...
    'unix_netcdf', '' ...
);

%% determine host

host = '';
if ismember('custom', OPT.type)
    host = OPT.host;
else
    fnames = fieldnames(hosts);
    types = regexp(fnames, '_', 'split');
    for i = 1:length(types)
        if all(ismember(OPT.type, types{i}))
            if ~isempty(hosts.(fnames{i}))
                host = hosts.(fnames{i});
                break;
            end
        end
    end
end

if isempty(host)
    error(['No valid host found [' sprintf(' %s', OPT.type{:}) ' ]']);
end

%% retrieve data

[fhost fname fext] = fileparts(host);

tmpfile = tempname;
mkdir(tmpfile);

% unzip, if zipped
if strcmpi(fext, '.zip')
    fpath = tmpfile;
    
    urlwrite(host, [fpath fext]);
    unzip([fpath fext], fpath);
    delete([fpath fext]);
    
    % return exe dir, if it exists
    if exist(fullfile(fpath, 'exe'), 'dir')
        fpath = fullfile(fpath, 'exe');
    end
    
    % return filename if only one file or xbeach* file unzipped
    if length(dir(fpath)) == 3
        d = dir(fpath);
        fpath = fullfile(fpath, d(3).name);
    else
        d = dir(fullfile(fpath, 'xbeach*'));
        if ~isempty(d)
            fpath = fullfile(fpath, d(1).name);
        end
    end
else
    fpath = fullfile(tmpfile, [fname fext]);
    urlwrite(host, fpath);
end
