function [handles ok] = ddb_getDirectories(handles)
%DDB_GETDIRECTORIES  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   [handles ok] = ddb_getDirectories(handles)
%
%   Input:
%   handles =
%
%   Output:
%   handles =
%   ok      =
%
%   Example
%   ddb_getDirectories
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

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%% Find DDB directories

ok=1;

% Read ini xml file


handles.workingDirectory=pwd;

if isdeployed
    
%    handles.settingsDir=[ctfroot filesep 'ddbsettings' filesep]; % Changed back (MvO 2017-4-20)
    handles.settingsDir=[ctfroot filesep 'DelftDashBoa' filesep 'ddbsettings' filesep]; % Changed back (MvO 2017-4-20)

    [status, result] = system('path');
    exeDir = char(regexpi(result, 'Path=(.*?);', 'tokens', 'once'));
    datadir=[fileparts(exeDir) filesep 'data' filesep];
    
    disp(['Exe directory      : ' exeDir]);
    disp(['Data directory     : ' datadir]);
    disp(['Settings directory : ' handles.settingsDir]);
%    handles.settingsDir=[fileparts(exeDir) filesep 'ddbsettings' filesep]; % by Bart Grasmeijer
    
    additionalToolboxDir=[];
    additionalModelsDir=[];
%     maindir=[fileparts(exeDir) filesep];
    
else
    
    inipath=fileparts(fileparts(fileparts(which('DelftDashBoard'))));
    
    % Check existence of ini file DelftDashBoard.ini
    
    inifile=[inipath filesep 'delftdashboard.ini'];
    
    if ~exist(inifile,'file')
        
        % Ini file does not exist, so ask for name of delftdashboard folder
        
        txt='Select folder (preferably named "delftdashboard") for data storage (e.g. d:\delftdashboard). You may need to create a new folder. Folder must be outside OET repository!';
        dirname = uigetdir(filedrive(inipath),txt);
        
        if isnumeric(dirname)
            dirname='';
        end
        
        if isempty(dirname)
            error('Local data directory not found, check reference in ini-file!');
        end
        
        datadir=[dirname filesep 'data'];
        
        % Create ini file
        disp('Making delftdashboard.ini file ...');
        fid=fopen([inipath filesep 'delftdashboard.ini'],'wt');
        fprintf(fid,'%s\n','% Data directories');
        fprintf(fid,'%s\n',['DataDir=' datadir filesep]);
        fclose(fid);
        
    end
    
    handles.settingsDir=[inipath filesep 'settings' filesep];
    datadir=getINIValue(inifile,'DataDir');
    if ~strcmpi(datadir(end),filesep)
        datadir=[datadir filesep];
    end
    
    try
        additionalToolboxDir=getINIValue(inifile,'AdditionalToolboxDir');
    catch
        additionalToolboxDir=[];
    end

    try
        additionalModelsDir=getINIValue(inifile,'AdditionalModelDir');
    catch
        additionalModelsDir=[];
    end
    
    if ~isdir(datadir)
        % Usually done the first time ddb is run. Files are copied from
        % repository to Delft Dashboard data folder
        mkdir(datadir);        
        ddb_copyAllFilesToDataFolder(inipath,datadir,additionalToolboxDir);        
    end
    
end

handles.bathymetry.dir=[datadir 'bathymetry' filesep];
handles.tideDir=[datadir 'tidemodels' filesep];
handles.toolBoxDir=[datadir 'toolboxes' filesep];
handles.additionalToolboxDir=additionalToolboxDir;
handles.additionalModelsDir=additionalModelsDir;
handles.shorelineDir=[datadir 'shorelines' filesep];
handles.satelliteDir=[datadir 'imagery' filesep];
handles.superTransDir=[datadir 'supertrans' filesep];
handles.proxyDir=[datadir 'proxysettings' filesep];
handles.sncDir=[datadir 'sncsettings' filesep];
handles.xmlConfigDir=datadir;

%  Tropical Cyclone bulletin download directory (used by check_tc_files.pl):
handles.tropicalCycloneDir = [datadir 'tropicalcyclone' filesep];
%  Check whether the TC download directory exists; if not, create the
%  structure now.
if (~exist(handles.tropicalCycloneDir, 'dir'))
    disp([10 ' NOTE: Creating the Tropical Cyclone directory structure in ' handles.tropicalCycloneDir 10]);
    [isok, msg, msgid]  = mkdir(handles.tropicalCycloneDir);
    if (~isok)
        warning(msgid,['unable to create the TC directory structure: ' msg]);
    end
end
%  Perform the same check for the JTWC subdirectory.
if (~exist([handles.tropicalCycloneDir filesep 'JTWC'], 'dir'))
    [isok, msg, msgid]  = mkdir([handles.tropicalCycloneDir filesep 'JTWC']);
    if (~isok)
        warning(msgid,['unable to create the JTWC subdirectory: ' msg]);
    end
end
%  Perform the same check for the NHC subdirectory.
if (~exist([handles.tropicalCycloneDir filesep 'NHC'], 'dir'))
    [isok, msg, msgid]  = mkdir([handles.tropicalCycloneDir filesep 'NHC']);
    if (~isok)
        warning(msgid,['unable to create the NHC subdirectory: ' msg]);
    end
end

