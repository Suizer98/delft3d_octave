clear all
% function ddcompile_seamulator
%DDCOMPILE3  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddcompile_seamulator
%
%   Input:
%   varargin =
%
%
%
%
%   Example
%   ddcompile_seamulator
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

% $Id: ddcompile3.m 16899 2020-12-09 10:15:47Z ormondt $
% $Date: 2020-12-09 11:15:47 +0100 (wo, 09 dec 2020) $
% $Author: ormondt $
% $Revision: 16899 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/main/operations/ddcompile3.m $
% $Keywords: $

%%

% FOR THIS SCRIPT TO RUN, YOUR WORKING FOLDER MUST BE THE MAIN DELFT
% DASHBOARD SOURCE FOLDER (e.g. d:\checkouts\OET\trunk\matlab\applications\DelftDashBoard\)

compilefolder='d:/delftdashboard_seamulator_v00_01/'; % Folder where executable and data will be created

do_unzip = 1;

% addpath(genpath('d:\checkouts\ShorelineS\trunk\'));

include_additional_toolboxes=1;
include_additional_models=0;
revisionnumber='1';

if ~exist(compilefolder,'dir')
    mkdir(compilefolder);
end
try
    rmdir([compilefolder 'data']);
end
try
    rmdir([compilefolder 'bin']);
end
mkdir([compilefolder 'data']);
mkdir([compilefolder 'bin']);

inipath=[fileparts(fileparts(fileparts(which('DelftDashBoard')))) filesep];

cd(inipath)

% %% Remove statistics toolbox paths
matlabfolder='c:\Program Files\Matlab\Matlab2019a_64\';
imgpath=[matlabfolder 'toolbox' filesep 'images'];
rmpath(imgpath);
imgpath=[matlabfolder 'toolbox' filesep 'images' filesep 'images'];
rmpath(imgpath);
% statspath=[matlabfolder 'toolbox' filesep 'stats' filesep 'stats'];
% rmpath(statspath);
% statspath=[matlabfolder 'toolbox' filesep 'stats' filesep 'classreg'];
% rmpath(statspath);
% statspath=[matlabfolder 'toolbox' filesep 'stats' filesep 'statsdemos'];
% rmpath(statspath);

fid=fopen([inipath 'complist'],'wt');
% Make a compile list in the main DelftDashBoard source folder
fprintf(fid,'%s\n','-a');
% Add the main script
fprintf(fid,'%s\n','DelftDashBoard.m');

% Make a temporary directory for compiled settings
if exist([inipath 'ddbsettings'],'dir')
    try
    rmdir([inipath 'ddbsettings']);
    catch
    end
end
mkdir([inipath 'ddbsettings']);

% Copy every folder from the settings folder to the temporary folder
% These files and folders will be compiled into the exe file
flist=dir([inipath 'settings']);
for i=1:length(flist)
    switch flist(i).name
        case{'.','..','.svn'}
        otherwise
            mkdir([inipath 'ddbsettings' filesep flist(i).name]);
            copyfiles([inipath 'settings' filesep flist(i).name],[inipath 'ddbsettings' filesep flist(i).name]);
    end
end
% Also add the model and toolbox xml files
mkdir([inipath 'ddbsettings' filesep 'models' filesep 'xml']);
mkdir([inipath 'ddbsettings' filesep 'toolboxes' filesep 'xml']);

% Add all of the m files in the models folder to the comp list
% Also copy xml files to the temporary ddbsettings folder
flist=dir([inipath 'models']);
for j=1:length(flist)
    if flist(j).isdir
        model=flist(j).name;
        if strcmp('Delft3DWAVE',model) %only include Delft3DWAVE
            % Check if xml file exists and whether model is enabled
            xmlfile=[inipath 'models' filesep model filesep 'xml' filesep 'model.' model '.xml'];
            if exist(xmlfile,'file')>0
                xml=xml2struct(xmlfile);
                switch lower(xml.enable)
                    case{'1','y','yes'}
                        % Model is enabled
                        % Add all m files
                        files=ddb_findAllFiles([inipath 'models' filesep model],'*.m');
                        for i=1:length(files)
                            fprintf(fid,'%s\n',files{i});
                        end
                        % Copy xml files and misc files
                        try
                            mkdir([inipath 'ddbsettings' filesep 'models' filesep model filesep 'xml']);
                            copyfile([inipath 'models' filesep model filesep 'xml' filesep '*.xml'],[inipath 'ddbsettings' filesep 'models' filesep model filesep 'xml']);
                        end
                        try
                            if isfolder([inipath 'models' filesep model filesep 'misc'])
                                mkdir([inipath 'ddbsettings' filesep 'models' filesep model filesep 'misc']);
                                copyfiles([inipath 'models' filesep model filesep 'misc'],[inipath 'ddbsettings' filesep 'models' filesep model filesep 'misc']);
                            end
                        end
                end
            end
        end
    end
end

% Do the same for the toolboxes
flist=dir([inipath 'toolboxes']);
for j=1:length(flist)
    if flist(j).isdir
        toolbox=flist(j).name;
        if strcmp('ModelMaker',toolbox) || strcmp('Bathymetry',toolbox)  %only include ModelMaker  %% & Bathymetry 
        
            % Check if xml file exists and whether toolbox is enabled
            xmlfile=[inipath 'toolboxes' filesep toolbox filesep 'xml' filesep 'toolbox.' toolbox '.xml'];
            if exist(xmlfile,'file')>0
                xml=xml2struct(xmlfile);
                switch lower(xml.enable)
                    case{'1','y','yes'}
                        % Model is enabled
                        files=ddb_findAllFiles([inipath 'toolboxes' filesep toolbox],'*.m');
                        for i=1:length(files)
                            fprintf(fid,'%s\n',files{i});
                        end
                        % Copy xml files and misc files
                        try
                            mkdir([inipath 'ddbsettings' filesep 'toolboxes' filesep toolbox filesep 'xml']);
                            copyfile([inipath 'toolboxes' filesep toolbox filesep 'xml' filesep '*.xml'],[inipath 'ddbsettings' filesep 'toolboxes' filesep toolbox filesep 'xml']);
                        end
    %                     try
    %                         if isdir([inipath 'toolboxes' filesep toolbox filesep 'misc'])
    %                             mkdir([inipath 'ddbsettings' filesep 'toolboxes' filesep toolbox filesep 'misc']);
    %                             copyfiles([inipath 'toolboxes' filesep toolbox filesep 'misc'],[inipath 'ddbsettings' filesep 'toolboxes' filesep toolbox filesep 'misc']);
    %                         end
    %                     end
                end
            end
        end
    end
end

addbad=which('ddb_aboutDelftDashBoard');
[path,name,ext]=fileparts(addbad);
fprintf(fid,'%s\n',[name ext]);

% And the additional toolboxes
if include_additional_toolboxes
    % Add additional toolboxes
    inifile=[inipath 'DelftDashBoard.ini'];
    try
        additionalToolboxDir=getINIValue(inifile,'AdditionalToolboxDir');
        DataDir=getINIValue(inifile,'DataDir');
    catch
        additionalToolboxDir=[];
        DataDir=[];
    end
    if ~isempty(additionalToolboxDir)
        % Add toolboxes
        flist=dir(additionalToolboxDir);
        for j=1:length(flist)
            if flist(j).isdir
                toolbox=flist(j).name;
                if strcmpi(toolbox,'DDB-Seamulator-toolbox') %only seamulator additional toolbox wanted
                    toolboxnamexml = 'Seamulator';
                    % Check if xml file exists and whether toolbox is enabled
                    xmlfile=[additionalToolboxDir filesep toolbox filesep 'xml' filesep 'toolbox.' toolboxnamexml '.xml'];
                    if exist(xmlfile,'file')>0
                        xml=xml2struct(xmlfile);
                        switch lower(xml.enable)
                            case{'1','y','yes'}
                                % Model is enabled
                                files=ddb_findAllFiles([additionalToolboxDir toolbox],'*.m');
                                for i=1:length(files)
                                    fprintf(fid,'%s\n',files{i});
                                end
                                % Copy xml files 
                                try
                                    mkdir([inipath 'ddbsettings' filesep 'toolboxes' filesep toolbox filesep 'xml']);
%                                     copyfile([additionalToolboxDir filesep toolbox filesep 'xml' filesep '*.xml'],[inipath 'ddbsettings' filesep 'toolboxes' filesep toolbox filesep 'xml']);
                                    copyfile([additionalToolboxDir filesep toolbox filesep 'xml' filesep '*.xml'],[inipath 'ddbsettings' filesep 'toolboxes' filesep toolboxnamexml filesep 'xml']);
                                                                        
                                end
                                % Copy executables D3Dwave and SWAN                                
                                try
                                    if isfolder([additionalToolboxDir filesep toolbox filesep 'exe'])
%                                         mkdir([inipath 'ddbsettings' filesep 'toolboxes' filesep toolbox filesep 'exe']);
%                                         copyfiles([additionalToolboxDir filesep toolbox filesep 'exe'],[inipath 'ddbsettings' filesep 'toolboxes' filesep toolbox filesep 'exe']);
                                        mkdir([compilefolder filesep 'exe' filesep 'Delft3D 4.04.01']);
                                        copyfiles([additionalToolboxDir filesep toolbox filesep 'exe' filesep 'Delft3D 4.04.01'],[compilefolder filesep 'exe' filesep 'Delft3D 4.04.01']);
                                        mkdir([compilefolder filesep 'exe' filesep 'dlls']);
                                        copyfiles([additionalToolboxDir filesep toolbox filesep 'exe' filesep 'dlls' filesep],[compilefolder filesep 'exe' filesep 'dlls' filesep]);
                                         
                                    end
                                end
                                % Copy toolbox specific data file (not plural!)                               
                                try
                                    if isfolder([additionalToolboxDir filesep toolbox filesep 'data'])
                                        mkdir([inipath 'ddbsettings' filesep 'toolboxes' filesep toolbox filesep 'data']);
                                        copyfile([additionalToolboxDir filesep toolbox filesep 'copy_of_xml_for_DelftDashboard-data\delftdashboard.xml'],[compilefolder filesep 'data\']);
                                    end
                                end
                                % Copy toolbox specific data binary files while unzipping                               
                                try
                                    if isfolder([additionalToolboxDir filesep toolbox filesep 'data'])
                                        mkdir([compilefolder filesep 'data\selection_v05_processed_bin\']);

                                        if do_unzip == 1
                                            unzip([additionalToolboxDir filesep toolbox filesep 'data' filesep 'selection_v05_processed_bin.zip'], [compilefolder filesep 'data\selection_v05_processed_bin\'])
                                        end
                                    end
                                end                                
                                % copy specific Seamulator version of
                                % data/delftdashboard.xml
                                copyfile([additionalToolboxDir filesep toolbox filesep 'data\*.mat'],[compilefolder filesep 'data\']);

                                % Copy run batch script of Seamulator exe:
                                try
                                    if isfolder([additionalToolboxDir filesep toolbox filesep 'exe'])
                                        copyfile([additionalToolboxDir filesep toolbox filesep 'exe' filesep 'run_seamulator.bat'],compilefolder);
                                    end
                                end
                                
                                %                         try
                                %                             if isdir([additionalToolboxDir filesep toolbox filesep 'misc'])
                                %                                 mkdir([inipath 'ddbsettings' filesep 'toolboxes' filesep toolbox filesep 'misc']);
                                %                                 copyfiles([additionalToolboxDir filesep toolbox filesep 'misc'],[inipath 'ddbsettings' filesep 'toolboxes' filesep toolbox filesep 'misc']);
                                %                             end
                                %                         end
                        end
                    end
                end
            end
        end
    end
end

% % Add tropical cyclone selector
% mkdir([inipath 'ddbsettings' filesep 'tropical_cyclone_selector' filesep]);
% copyfile('d:\checkouts\OET\trunk\matlab\applications\DelftDashBoard\general\tropicalcyclones\tropical_cyclone_selector\*.pli',[inipath 'ddbsettings' filesep 'tropical_cyclone_selector' filesep]);
% copyfile('d:\checkouts\OET\trunk\matlab\applications\DelftDashBoard\general\tropicalcyclones\tropical_cyclone_selector\*.xml',[inipath 'ddbsettings' filesep 'tropical_cyclone_selector' filesep]);

fclose(fid);

%% Include icon
try
    fid=fopen('earthicon.rc','wt');
    fprintf(fid,'%s\n','ConApp ICON settings/icons/Earth-icon32x32.ico');
    fclose(fid);
    system(['"' matlabroot '/sys/lcc/bin/lrc" /i "' pwd '/earthicon.rc"']);
end

%% Generate data folder in exe folder
% ddb_copyAllFilesToDataFolder(inipath,[inipath filesep 'exe' filesep 'data' filesep],additionalToolboxDir,DataDir);
ddb_copyAllFilesToDataFolder(inipath,[compilefolder filesep 'data' filesep],additionalToolboxDir);

%mcc -m -v -d exe\bin DelftDashBoard.m -B complist -a ddbsettings -a ..\..\io\netcdf\toolsUI-4.1.jar -M earthicon.res
%copyfile('settings/icons/earthicon.res','./');
%copyfile('settings/icons/deltares_icon.res','./');
copyfile([inipath, filesep, 'settings/icons/deltares.ico'],compilefolder);

if ~exist([compilefolder, filesep,'exe'],'dir')
    mkdir([compilefolder, filesep,'exe']);
end
% if ~exist([compilefolder, filesep, 'exe' filesep 'bin'],'dir')
%     mkdir([compilefolder, filesep, 'exe' filesep 'bin']);
% end

% And now do the actual compiling
%mcc -m -v -d exe/bin DelftDashBoard.m -B complist -a ddbsettings -a ../../io/netcdf/netcdfAll-4.2.jar -r d:\checkouts\OET\trunk\matlab\applications\DelftDashBoard\settings\icons\deltares.gif
mcc -m -v -d exe/bin DelftDashBoard.m -B complist -a ddbsettings -a ../../io/netcdf/netcdfAll-4.2.jar -r ./ddbsettings/icons/deltares.ico

% cd(compilefolder)

% Change the revision number text
Revision = ['$Revision: ' revisionnumber ' $'];
eval([strrep(Revision(Revision~='$'),':','=') ';']);
dos(['copy ' fileparts(which('ddsettings')) filesep 'main' filesep 'menu' filesep 'ddb_aboutDelftDashBoard.txt ' fileparts(which('ddsettings')) filesep 'exe']);
strrep(fullfile(fileparts(which('ddsettings')),'exe','ddb_aboutDelftDashBoard.txt'),'$revision',num2str(Revision));

copyfile(['exe' filesep 'bin' filesep 'DelftDashboard.exe'],[compilefolder filesep 'bin\Seamulator_User_Interface.exe']);
% copyfile([inipath 'settings' filesep 'delftdashboard.xml'],[compilefolder
% filesep 'data\']); > do already before with version in Seamulator repos

% Delete temporary files
delete('complist');
%delete('earthicon.rc');
%delete('earthicon.res');
delete('deltares.ico');

rmdir('ddbsettings','s');

