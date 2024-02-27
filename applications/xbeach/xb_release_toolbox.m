function varargout = xb_release_toolbox(varargin)
%XB_RELEASE_TOOLBOX  create release of xbeach toolbox
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = xb_release_toolbox(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   xb_release_toolbox
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Kees den Heijer
%
%       Kees.denHeijer@Deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
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
% Created: 21 Dec 2010
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id: xb_release_toolbox.m 6359 2012-06-08 14:27:48Z hoonhout $
% $Date: 2012-06-08 22:27:48 +0800 (Fri, 08 Jun 2012) $
% $Author: hoonhout $
% $Revision: 6359 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_release_toolbox.m $
% $Keywords: $

%% read options

OPT = struct( ...
    'type', 'zip', ...
    'name', ['xbeach_release_' datestr(now, 'ddmmmyyyy')] ...
);

OPT = setproperty(OPT, varargin);

%% release

% select xb_* diretories only
fdir = [fileparts(which(mfilename)) filesep];
cd(fdir);

%fdirs = dir(fullfile(fdir, 'xb_*'));
%ffolders = {fdirs.name};
%ffolders = ffolders([fdirs.isdir]);
%folders = [{'..\..\io\' '..\..\general\'} ffolders];
folders = [{'..\..\io\opendap\' '..\..\io\netcdf\snctools\' '..\..\io\netcdf\mexnc\' '..\..\general\xstruct_fun' '..\..\general\oet_defaults\' '..\..\general\oet_template\'} fdir];
for i = 1:length(folders); folders{i} = abspath(folders{i}); end;

% select all files and oetsettings
%fffiles = dir(fdir);
%ffiles = {fffiles.name};
%ffiles = ffiles(~[fffiles.isdir]);
files = {'oetsettings' 'wlgrid' 'wldep'};

% release toolbox
switch OPT.type
    case 'zip'
        oetrelease(...
            'targetdir'     , fullfile('D:', OPT.name), ...
            'zipfilename'   , fullfile('D:', [OPT.name '.zip']), ...
            'folders'       , folders, ...
            'files'         , files, ...
            'omitfiles'     , {'*xb_tutorial_*','*xb_release_*','*xb_addpath_old.m','*h4xb.m','*xb_get_profilespecs.m','*xb_scale.m'},...
            'omitdirs'      , {'svn' '_old' '_bak', 'old', '.old', 'xb_testbed','xb_human', 'xb_nesting', 'xb_gui', 'debug_fun', 'maintenance', 'tests'});
    case 'tag'

        [r m] = system('svn ?');

        if r > 0; error('Command-line Subversion client not found [svn]'); end;

        system(sprintf('cd %s && svn update\n', oetroot));

        files = oetrelease(...
            'folders'       , folders, ...
            'files'         , files, ...
            'omitdirs'      , {'svn' '_old' '_bak', 'old', '.old', 'xb_testbed'}, ...
            'copy'          , false );

        rootdir = abspath(fullfile(oetroot, '..', '..'));
        tagsdir = abspath(fullfile(rootdir, 'tags'));
        tagdir = abspath(fullfile(tagsdir, OPT.name));

        fid = fopen('maketag.bat','w');

        if ~exist(tagsdir, 'dir')
            fprintf(fid, 'cd %s\n', rootdir);
            fprintf(fid, 'svn checkout --depth=empty %s/tags\n', OPT.url);
        end

        fprintf(fid, 'cd %s\n', tagsdir);
        fprintf(fid, 'svn mkdir %s\n', OPT.name);
        fprintf(fid, 'cd %s\n', tagdir);
        fprintf(fid, 'svn mkdir _externals\n');

        for i = 1:length(files)
            url_src = strrep(files{i}, [abspath(oetroot) filesep], oeturl);
            %url_dst = regexprep(oeturl, 'trunk\/.*$', ['tags/' OPT.name '/']);
            url_dst = regexprep(oetroot, 'trunk[\\\/].*$', ['tags/' OPT.name '/']);

            if strfind(files{i}, fdir) == 1
                url_dst = [url_dst strrep(files{i}, fdir, '')];
            elseif ~strcmpi(fileparts(oetroot), fileparts(files{i}))
                url_dst = [url_dst strrep(files{i}, oetroot, ['_externals' filesep])];
            else
                url_dst = strrep(url_src, oeturl, url_dst);
            end

            url_src = strrep(url_src, '\', '/');
            url_dst = strrep(url_dst, '/', '\');

            fprintf(fid, 'svn copy --parents %s %s\n', url_src, url_dst);
        end

        fprintf(fid, 'cd ..\n');
        %fprintf(fid, 'svn commit -m "Added tag %s" %s\n', OPT.name, OPT.name);

        fclose(fid);

        fprintf('Creating tag "%s"...', OPT.name);

        [r m] = system('maketag.bat');

        if r > 0
            disp(m);
            error(['Creating tag failed']);
        else
            fprintf(' done');
        end

        delete('maketag.bat');

    otherwise
        error(['Unknown release type [' OPT.type ']']);
end
