function FileName = xb_write_sh_scripts_multiple(varargin)
%XB_WRITE_SH_SCRIPTS_MULTIPLE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = xb_write_sh_scripts_multiple(varargin)
%
%   Input: For <keyword,value> pairs call xb_write_sh_scripts_multiple() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   xb_write_sh_scripts_multiple
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

% $Id: xb_write_sh_scripts_multiple.m 13260 2017-04-13 12:37:27Z nederhof $
% $Date: 2017-04-13 20:37:27 +0800 (Thu, 13 Apr 2017) $
% $Author: nederhof $
% $Revision: 13260 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_run/xb_write_sh_scripts_multiple.m $
% $Keywords: $

%% Settings
OPT = struct( ...
    'name',         ['xb_' datestr(now, 'YYYYmmddHHMMSS')], ...
    'scriptNr',     [],                                     ...
    'cluster',      'h6',                                   ...
    'email',        [],                                     ... % Fill out email adress to receive mail upon completion or abortion
    'rundirLocal',  '',                                     ...
    'rundir',       '',                                     ...
    'subdirs',      '',                                     ...
    'version',      1.22,                                   ...
    'nodes',        1,                                      ...
    'queuetype',    'normal-e3'                             ...
    );

OPT = setproperty(OPT, varargin{:});

%% write mpi script
FileName = ['mpi' num2str(OPT.scriptNr) '.sh'];
fid = fopen(fullfile(OPT.rundirLocal, FileName), 'w');

fprintf(fid,'#!/bin/sh\n');
fprintf(fid,'#$ -cwd\n');
fprintf(fid,'#$ -N %s\n\n', OPT.name);
if ~isempty(OPT.email)
    fprintf(fid,'#$ -M %s\n', OPT.email);
end
fprintf(fid,'#$ -m ea\n');

fprintf(fid,'echo $HOSTNAME \n\n');

xb_write_sh_scripts_xbversions(fid, 'version', OPT.version)

fprintf(fid,'rundir=%s\n',OPT.rundir);
strs = '%s %s %s %s ';
subdirsstr = ['subdirs="' strs(1:(3*numel(OPT.subdirs))) '"\n\n'];
fprintf(fid,subdirsstr,OPT.subdirs{:});
fprintf(fid,'for i in $subdirs\n');
fprintf(fid,'do\n');
fprintf(fid,'    cd $rundir/$i\n');
fprintf(fid,'    pwd\n');
fprintf(fid,'    mpirun -np 2 xbeach > xb.log &\n');
fprintf(fid,'    cd $OLDPWD\n');
fprintf(fid,'done\n');
fprintf(fid,'wait\n');

fclose(fid);