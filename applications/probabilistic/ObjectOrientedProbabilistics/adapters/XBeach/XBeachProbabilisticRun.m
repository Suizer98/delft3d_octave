function XBeachProbabilisticRun(ModelOutputDir, varargin)
%XBEACHPROBABILISTICRUN  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = XBeachProbabilisticRun(varargin)
%
%   Input: For <keyword,value> pairs call XBeachProbabilisticRun() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   XBeachProbabilisticRun
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
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
% Created: 16 Oct 2013
% Created with Matlab version: 8.1.0.604 (R2013a)

% $Id: XBeachProbabilisticRun.m 16860 2020-11-30 16:20:33Z bieman $
% $Date: 2020-12-01 00:20:33 +0800 (Tue, 01 Dec 2020) $
% $Author: bieman $
% $Revision: 16860 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/ObjectOrientedProbabilistics/adapters/XBeach/XBeachProbabilisticRun.m $
% $Keywords: $

%% Settings
OPT = struct(...
    'Ph',               [],         ...
    'PHm0',             [],         ...
    'PTp',              [],         ...
    'D50',              225e-6,     ...
    'MinHm0',           0.5,        ...
    'MinTp',            2.5,        ...
    'JarkusID',         [],         ...
    'ModelSetupDir',    '',         ...
    'ExecutablePath',   '',         ...
    'tstop',            5*3600,     ...
    'RunRemote',        false,      ...
    'NrNodes',          1,          ...
    'QueueType',        'normal-e3',   ...
    'sshUser',          [],         ...
    'sshPassword',      [],         ...
    'LSFChecker',       []);

OPT = setproperty(OPT, varargin{:});

%% Load initial model setup

xbModel = xb_read_input(fullfile(OPT.ModelSetupDir, 'params.txt'));

%% Calculate unspecified variables

[Lambda, ~, Station1, Station2]         = getLambda_2Stations('JarkusId', OPT.JarkusID);

[h, h1, h2, Station1, Station2, Lambda] = getWl_2Stations(norm_cdf(OPT.Ph, 0, 1), Lambda, Station1, Station2);
[Hs, Hs1, Hs2, Station1, Station2]      = getHs_2Stations(OPT.PHm0, Lambda, h1, h2, Station1, Station2);
[Tp, Tp1, Tp2, Station1, Station2]      = getTp_2Stations(OPT.PTp, Lambda, Hs1, Hs2, Station1, Station2);

%% Check for impossible values

if Hs < OPT.MinHm0
    Hs = OPT.MinHm0;
end

if Tp < OPT.MinTp
    Tp = OPT.MinTp;
end

fp = 1/Tp;

%% Change stochastic variables in XBeach model

xbModel = xs_set(xbModel, 'zs0file.tide', [h -20; h -20]);
xbModel = xs_set(xbModel, 'bcfile.Hm0', Hs);
xbModel = xs_set(xbModel, 'bcfile.Tp', Tp);
xbModel = xs_set(xbModel, 'bcfile.fp', fp);
xbModel = xs_set(xbModel, 'D50', OPT.D50);
xbModel = xs_set(xbModel, 'tstop', OPT.tstop);

%% Run model

ModelOutputDirLinux = path2os(ModelOutputDir);
ModelOutputDirLinux = strrep(ModelOutputDirLinux,'\','/');
ModelOutputDirLinux = ['/' strrep(ModelOutputDirLinux,':','')];

mkdir(ModelOutputDir)
if OPT.RunRemote
    [DirWin, FolderName, pt2]  = fileparts(ModelOutputDir);
    FolderName = [FolderName, pt2];
    [DirLinux, ~, ~]  = fileparts(ModelOutputDirLinux);
    xb_run_remote(xbModel, 'nodes', OPT.NrNodes, 'queuetype', OPT.QueueType, ...
        'netcdf', true, 'ssh_user', OPT.sshUser, 'ssh_pass', OPT.sshPassword, ...
        'path_local', DirWin, 'path_remote', DirLinux, ...
        'mpitype', 'OPENMPI', 'name', FolderName, 'mpidomains', 1);
else
    xb_run(xbModel, 'binary', OPT.ExecutablePath, 'netcdf', true, ...
        'path', ModelOutputDir, 'name', '', 'copy', false);
end