function ddb_compile
%DDCOMPILE Compiles DelftDashboard
%
%   Example
%   ddb_compile
%
%   See also mcc

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

% $Id: ddb_compile.m 13673 2017-09-06 12:16:16Z ormondt $
% $Date: 2017-09-06 20:16:16 +0800 (Wed, 06 Sep 2017) $
% $Author: ormondt $
% $Revision: 13673 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/main/operations/ddb_compile.m $
% $Keywords: $

%%
warning 'off';
% matlabfolder='c:\Program Files\MATLAB\R2016b\';
% compilefolder='c:\Users\grasmeijerb\Documents\delftdashboardsetup\';
% ddbsettingsdir='c:\Users\grasmeijerb\Documents\delftdashboardsetup\ddbsettings\';
% include_additional_toolboxes=0;
% ddb_path = 'c:\SVN_Projects\OpenEarthTools\matlab\applications\DelftDashBoard\';
% netcdf_path = 'c:\SVN_Projects\OpenEarthTools\matlab\io\netcdf\netcdfAll-4.2.jar';

matlabfolder='c:\Program Files\Matlab\MATLAB2013b_64\';
compilefolder='d:\delftdashboardsetup\';
ddbsettingsdir='d:\ddbsettings\';
include_additional_toolboxes=0;
ddb_path = 'd:\checkouts\OET\trunk\matlab\applications\DelftDashBoard';
netcdf_path = 'd:\checkouts\OET\trunk\matlab\io\netcdf\netcdfAll-4.2.jar';

% % Throw away compilefolder
% if exist(compilefolder,'dir')
%    rmdir(compilefolder,'s');
% end
% 
% if exist(ddbsettingsdir,'dir')
%    rmdir(ddbsettingsdir,'s');
% end

% Make new compile folder
disp('Making compile folder...')
mkdir(compilefolder);
mkdir([compilefolder 'data']);
mkdir([compilefolder 'bin']);
exedir=[compilefolder 'bin'];
compiledatadir=[compilefolder 'data'];

mkdir(ddbsettingsdir);

inipath=[fileparts(fileparts(fileparts(which('DelftDashBoard')))) filesep];

%% Remove statistics toolbox paths
statspath=[matlabfolder 'toolbox' filesep 'stats'];
rmpath(statspath);
statspath=[matlabfolder 'toolbox' filesep 'stats' filesep 'stats'];
rmpath(statspath);
statspath=[matlabfolder 'toolbox' filesep 'stats' filesep 'classreg'];
rmpath(statspath);
statspath=[matlabfolder 'toolbox' filesep 'stats' filesep 'statsdemos'];
rmpath(statspath);

fid=fopen([inipath 'complist'],'wt');

fprintf(fid,'%s\n','-a');

fprintf(fid,'%s\n','DelftDashBoard.m');

% Make directory for compiled settings
disp('Making directory for compiled settings...')
flist=dir([inipath 'settings']);
for i=1:length(flist)
    switch flist(i).name
        case{'.','..','.svn'}
        otherwise
            mkdir([ddbsettingsdir filesep flist(i).name]);
            copyfiles([inipath 'settings' filesep flist(i).name],[ddbsettingsdir filesep flist(i).name]);
    end
end

% Add models
disp('Adding models...')
flist=dir([inipath 'models']);
for j=1:length(flist)
    if flist(j).isdir
        model=flist(j).name;
        % Check if xml file exists and whether model is enabled
        xmlfile=[inipath 'models' filesep model filesep 'xml' filesep 'model.' lower(model) '.xml'];
        if exist(xmlfile,'file')
            xml=xml2struct(xmlfile);
            switch lower(xml(1).enable)
                case{'1','y','yes'}
                    % Model is enabled
                    % Add all m files
                    files=ddb_findAllFiles([inipath 'models' filesep model],'*.m');
                    for i=1:length(files)
                        fprintf(fid,'%s\n',files{i});
                    end
                    % Copy xml files
                    try
                        mkdir([ddbsettingsdir filesep 'models' filesep model filesep 'xml']);
                        copyfile([inipath 'models' filesep model filesep 'xml' filesep '*.xml'],[ddbsettingsdir filesep 'models' filesep model filesep 'xml']);
                    end
            end
        end
    end
end

% Add toolboxes
disp('Adding toolboxes...')
flist=dir([inipath 'toolboxes']);
for j=1:length(flist)
    if flist(j).isdir
        toolbox=flist(j).name;
        % Check if xml file exists and whether toolbox is enabled
        xmlfile=[inipath 'toolboxes' filesep toolbox filesep 'xml' filesep 'toolbox.' lower(toolbox) '.xml'];
        if exist(xmlfile,'file')
            xml=xml2struct(xmlfile);
            switch lower(xml(1).enable)
                case{'1','y','yes'}
                    % Toolbox is enabled
                    files=ddb_findAllFiles([inipath 'toolboxes' filesep toolbox],'*.m');
                    for i=1:length(files)
                        fprintf(fid,'%s\n',files{i});
                    end
                    % Copy xml files
                    try
                        mkdir([ddbsettingsdir filesep 'toolboxes' filesep toolbox filesep 'xml']);
                        copyfile([inipath 'toolboxes' filesep toolbox filesep 'xml' filesep '*.xml'],[ddbsettingsdir filesep 'toolboxes' filesep toolbox filesep 'xml']);
                    end
            end
        end
    end
end

additionalToolboxDir=[];
if include_additional_toolboxes
    % Add additional toolboxes
    inifile=[inipath 'DelftDashboard.ini'];
    %DataDir=getINIValue(inifile,'DataDir');
    try
        additionalToolboxDir=getINIValue(inifile,'AdditionalToolboxDir');
    end
    if ~isempty(additionalToolboxDir)
        % Add toolboxes
        flist=dir(additionalToolboxDir);
        for j=1:length(flist)
            if flist(j).isdir
                toolbox=flist(j).name;
                % Check if xml file exists and whether toolbox is enabled
                xmlfile=[additionalToolboxDir filesep toolbox filesep 'xml' filesep 'toolbox.' lower(toolbox) '.xml'];
                if exist(xmlfile,'file')
                    xml=xml2struct(xmlfile);
                    switch lower(xml(1).enable)
                        case{'1','y','yes'}
                            % Model is enabled
                            files=ddb_findAllFiles([additionalToolboxDir toolbox],'*.m');
                            for i=1:length(files)
                                fprintf(fid,'%s\n',files{i});
                            end
                            % Copy xml files
                            try
                                mkdir([ddbsettingsdir filesep 'toolboxes' filesep toolbox filesep 'xml']);
                                copyfile([additionalToolboxDir filesep toolbox filesep 'xml' filesep '*.xml'],[ddbsettingsdir filesep 'toolboxes' filesep toolbox filesep 'xml']);
                            end
                    end
                end
            end
        end
    end
end

%% dummy tab callback
fprintf(fid,'%s\n',which('ddb_dummyTabCallback'));

fclose(fid);

%% Include icon
% try
%     fid=fopen('earthicon.rc','wt');
%     fprintf(fid,'%s\n','ConApp ICON settings\icons\Earth-icon32x32.ico');
%     fclose(fid);
%     system(['"' matlabroot '\sys\lcc\bin\lrc" /i "' pwd '\earthicon.rc"']);
% end

%% Generate data folder in exe folder
disp('Generating data folder...')
ddb_copyAllFilesToDataFolder(inipath,compiledatadir,additionalToolboxDir);

%mcc -m -v -d exe\bin DelftDashBoard.m -B complist -a ddbsettings -a ..\..\io\netcdf\toolsUI-4.1.jar -M earthicon.res
% copyfile('settings\icons\earthicon.res','.\');

%mcc -m -v -d exe2 DelftDashBoard.m -B complist -a ddbsettings -a ..\..\io\netcdf\netcdfAll-4.2.jar -M earthicon.res
%mcc('-m','-v','-d',exedir,'DelftDashBoard.m','-B','complist','-a',ddbsettingsdir,'-a','..\..\io\netcdf\netcdfAll-4.2.jar','-M','earthicon.res');

cd(ddb_path)
disp('Start compiling ...');
mcc('-m','-v','-d',exedir,'DelftDashBoard.m','-B','complist','-a',ddbsettingsdir,'-a',netcdf_path);
% % ddbsettings folder no longer linked
% mcc('-m','-v','-d',exedir,'DelftDashBoard.m','-B','complist','-a',netcdf_path);

% copyfile('exe2\delftdashboard.exe',exedir);
% rmdir('exe','s');

% make about.txt file
Revision = '$Revision: 13673 $';
eval([strrep(Revision(Revision~='$'),':','=') ';']);

dos(['copy ' fileparts(which('ddsettings')) filesep 'main' filesep 'menu' filesep 'ddb_aboutDelftDashBoard.txt ' fileparts(which('ddsettings')) filesep 'exe']);
strrep(fullfile(fileparts(which('ddsettings')),'exe','ddb_aboutDelftDashBoard.txt'),'$revision',num2str(Revision));

delete('complist'); delete('exe');
% delete('earthicon.rc');
% delete('earthicon.res');
rmdir(ddbsettingsdir,'s');
