function ddcompile2(varargin)
%DDCOMPILE2  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddcompile2(varargin)
%
%   Input:
%   varargin =
%
%
%
%
%   Example
%   ddcompile2
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
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
% Created: 29 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: ddcompile2.m 7724 2012-11-23 14:43:42Z boer_we $
% $Date: 2012-11-23 22:43:42 +0800 (Fri, 23 Nov 2012) $
% $Author: boer_we $
% $Revision: 7724 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/main/operations/ddcompile2.m $
% $Keywords: $

%%
% To exclude models or toolboxes in the compiled program, use:
% ddcompile('model1','model2','toolbox1') with model1, model2 and toolbox the models/toolboxes to exclude.

% exclude={''};
%
% for i=1:length(varargin)
%     switch lower(varargin{i})
%         case{'exclude'}
%             if ~iscell(varargin{i+1})
%                 exclude={varargin{i+1}};
%             else
%                 exclude=varargin{i+1};
%             end
%     end
% end

inipath=[fileparts(fileparts(fileparts(which('DelftDashBoard')))) filesep];

mkdir('exe/data');
mkdir('exe/bin');

statspath='Y:/app/MATLAB2009b/toolbox/stats';
rmpath(statspath);

delete('exe/*');

fid=fopen('complist','wt');

fprintf(fid,'%s\n','-a');

fprintf(fid,'%s\n','DelftDashBoard.m');

exclude = varargin;

% Add models
flist=dir([inipath 'models']);
for i=1:length(flist)
    switch flist(i).name
        case{'.','..','.svn'}
        case exclude
        otherwise
            % m files
            flist2=dir([inipath 'models' filesep flist(i).name filesep '*']);
            for j=1:length(flist2)
                switch flist2(j).name
                    case{'.','..','.svn'}
                    case exclude
                    otherwise
                        if strcmpi(flist2(j).name,'toolbox')
                            flist3=dir([inipath 'models' filesep flist(i).name filesep 'toolbox']);
                            for n=1:length(flist3)
                                switch flist3(n).name
                                    case{'.','..','.svn'}
                                    case exclude
                                    otherwise
                                        f=dir(['models' filesep flist(i).name filesep 'toolbox' filesep flist3(n).name filesep '*.m']);
                                        for k=1:length(f)
                                            fname=f(k).name;
                                            fprintf(fid,'%s\n',fname);
                                        end
                                end
                            end
                        else
                            f=dir(['models' filesep flist(i).name filesep flist2(j).name filesep '*.m']);
                            for k=1:length(f)
                                fname=f(k).name;
                                fprintf(fid,'%s\n',fname);
                            end
                        end
                end
            end
    end
end

% Add toolboxes
flist=dir('toolboxes');
for i=1:length(flist)
    switch flist(i).name
        case{'.','..','.svn'}
        case exclude
        otherwise
            flist2=dir(['toolboxes' filesep flist(i).name filesep '*.m']);
            for j=1:length(flist2)
                fname=flist2(j).name;
                fprintf(fid,'%s\n',fname);
            end
    end
end

fclose(fid);

% Make directory for compiled settings
mkdir('ddbsettings');
flist=dir('settings');
for i=1:length(flist)
    switch flist(i).name
        case{'.','..','.svn'}
        otherwise
            mkdir(['ddbsettings' filesep flist(i).name]);
            copyfiles(['settings' filesep flist(i).name],['ddbsettings' filesep flist(i).name]);
    end
end

mkdir(['ddbsettings' filesep 'models' filesep 'xml']);
mkdir(['ddbsettings' filesep 'toolboxes' filesep 'xml']);

%% Copy xml files

% Models
flist=dir('models');
for i=1:length(flist)
    switch flist(i).name
        case{'.','..','.svn'}
        otherwise
            try
                mkdir(['ddbsettings' filesep 'models' filesep flist(i).name filesep 'xml']);
                copyfile(['models' filesep flist(i).name filesep 'xml' filesep '*.xml'],['ddbsettings' filesep 'models' filesep flist(i).name filesep 'xml']);
            end
            try
                if isdir(['models' filesep flist(i).name filesep 'misc'])
                    mkdir(['ddbsettings' filesep 'models' filesep flist(i).name filesep 'misc']);
                    copyfiles(['models' filesep flist(i).name filesep 'misc'],['ddbsettings' filesep 'models' filesep flist(i).name filesep 'misc']);
                end
            end
    end
end

% Toolboxes
flist=dir('toolboxes');
for i=1:length(flist)
    switch flist(i).name
        case{'.','..','.svn'}
        otherwise
            try
                mkdir(['ddbsettings' filesep 'toolboxes' filesep flist(i).name filesep 'xml']);
                copyfile(['toolboxes' filesep flist(i).name filesep 'xml' filesep '*.xml'],['ddbsettings' filesep 'toolboxes' filesep flist(i).name filesep 'xml']);
            end
            try
                if isdir(['toolboxes' filesep flist(i).name filesep 'misc'])
                    mkdir(['ddbsettings' filesep 'toolboxes' filesep flist(i).name filesep 'misc']);
                    copyfiles(['toolboxes' filesep flist(i).name filesep 'misc'],['ddbsettings' filesep 'toolboxes' filesep flist(i).name filesep 'misc']);
                end
            end
    end
end

%% Include icon
try
    fid=fopen('earthicon.rc','wt');
    fprintf(fid,'%s\n','ConApp ICON settings/icons/Earth-icon32x32.ico');
    fclose(fid);
    system(['"' matlabroot '/sys/lcc/bin/lrc" /i "' pwd '/earthicon.rc"']);
end

%% Generate data folder in exe folder


mkdir('exe/data');
inipath=

ddb_copyAllFilesToDataFolder(inipath,ddbdir,additionalToolboxDir);


mcc -m -v -d exe DelftDashBoard.m -B complist -a ddbsettings -a ../../io/netcdf\toolsUI-4.1.jar -M earthicon.res

% make about.txt file
Revision = '$Revision: 7724 $';
eval([strrep(Revision(Revision~='$'),':','=') ';']);

dos(['copy ' fileparts(which('ddsettings')) '/main/menu/ddb_aboutDelftDashBoard.txt ' fileparts(which('ddsettings')) filesep 'exe']);
strrep(fullfile(fileparts(which('ddsettings')),'exe','ddb_aboutDelftDashBoard.txt'),'$revision',num2str(Revision));

delete('complist');
delete('earthicon.rc');
delete('earthicon.res');

rmdir('ddbsettings','s');

