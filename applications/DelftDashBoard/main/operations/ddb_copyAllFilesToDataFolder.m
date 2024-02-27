function ddb_copyAllFilesToDataFolder(inipath,datadir,additionalToolboxDir)
%DDB_COPYALLFILESTODATAFOLDER  Copies file to data folder (function is called during compilation and first time Dashboard is called from Matlab)
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_copyAllFilesToDataFolder(inipath,repodatadir,additionalToolboxDir)
%
%   Input:
%   inipath              =
%   datadir               =
%   additionalToolboxDir =
%
%
%
%
%   Example
%   ddb_copyAllFilesToDataFolder
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

% $Id: ddb_copyAllFilesToDataFolder.m 17408 2021-07-14 14:26:15Z zoeh@x $
% $Date: 2021-07-14 22:26:15 +0800 (Wed, 14 Jul 2021) $
% $Author: zoeh@x $
% $Revision: 17408 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/main/operations/ddb_copyAllFilesToDataFolder.m $
% $Keywords: $

%%
% Create new folder
disp('Copying data files from repository ...');

% Name of data folder in repository 
repodatadir=[inipath filesep 'data' filesep];

if ~isdir(datadir)
   mkdir(datadir);
end

inipath=[inipath filesep];
datadir=[datadir filesep];
additionalToolboxDir=[additionalToolboxDir filesep];

mkdir([datadir 'bathymetry']);
mkdir([datadir 'imagery']);
mkdir([datadir 'shorelines']);
mkdir([datadir 'tidemodels']);

%  Do the same for the tropical cyclone directory structure, but don't
%  perform a copyfiles() call, as there should be no files to copy.
mkdir([datadir 'tropicalcyclone']);
mkdir([datadir 'tropicalcyclone' filesep 'JTWC']);  % JTWC warning files subdir.
mkdir([datadir 'tropicalcyclone' filesep 'NHC']);   % NHC warning files subdir.

mkdir([datadir 'toolboxes']);
mkdir([datadir 'supertrans']);

% Bathymetry
copyfile([repodatadir 'bathymetry', filesep, 'bathymetry.xml'],[datadir 'bathymetry']);
% And now copy zoomlevel 6 of GEBCO08
mkdir([datadir 'bathymetry', filesep, 'gebco08']);
mkdir([datadir 'bathymetry', filesep, 'gebco08', filesep, 'zl06']);
copyfile([repodatadir 'bathymetry', filesep, 'gebco08', filesep, 'gebco08.nc'],[datadir 'bathymetry', filesep, 'gebco08']);
copyfiles([repodatadir 'bathymetry', filesep, 'gebco08', filesep, 'zl06'],[datadir 'bathymetry', filesep, 'gebco08', filesep, 'zl06']);

% Shorelines
copyfile([repodatadir 'shorelines', filesep, 'shorelines.xml'],[datadir 'shorelines']);
% And now copy coarse shore line from wvs
mkdir([datadir 'shorelines', filesep, 'wvs']);
mkdir([datadir 'shorelines', filesep, 'wvs', filesep, 'c']);
copyfile([repodatadir 'shorelines', filesep, 'wvs', filesep, 'wvs.nc'],[datadir 'shorelines', filesep, 'wvs']);
copyfiles([repodatadir 'shorelines', filesep, 'wvs', filesep, 'c'],[datadir 'shorelines', filesep, 'wvs', filesep, 'c']);

% Tide models
copyfile([repodatadir 'tidemodels', filesep, 'tidemodels.xml'],[datadir 'tidemodels']);

% SuperTrans
% Copy EPSG.mat file from SuperTrans data folder to DDB data folder
dr=fileparts(which('EPSG.mat'));
copyfile([dr filesep 'EPSG.mat'],[datadir 'supertrans']);
copyfile([dr filesep 'EPSG_ud.mat'],[datadir 'supertrans']);
% Copy supertrans.xml from repo data folder to DDB data folder
copyfile([repodatadir 'supertrans', filesep, 'SuperTrans.xml'],[datadir 'supertrans']);

% Find toolboxes and copy xml files to data folders
flist=dir([inipath 'toolboxes']);
for i=1:length(flist)
    toolbox=flist(i).name;
    if isdir([inipath 'toolboxes' filesep toolbox])
        switch lower(toolbox)
            case{'.','..','.svn'}
            otherwise
                xmlfile=[inipath 'toolboxes' filesep toolbox filesep 'xml' filesep 'toolbox.' lower(toolbox) '.xml'];
                %xmlfile=[inipath 'toolboxes' filesep toolbox filesep 'xml' filesep toolbox '.xml'];
                if exist(xmlfile,'file')
                    xml=xml2struct(xmlfile);
                    switch lower(xml(1).enable)
                        case{'1','y','yes'}                            
                            % Check if there is a data folder in directory of this
                            % toolbox
                            if isdir([inipath 'toolboxes' filesep toolbox filesep 'data'])
                                if ~isdir([datadir 'toolboxes' filesep toolbox])
                                    mkdir([datadir 'toolboxes' filesep toolbox]);
                                end
                                copyfile([inipath 'toolboxes' filesep toolbox filesep 'data' filesep '*'],[datadir 'toolboxes' filesep toolbox]);
                            end
                    end
                end
        end
    end
end

% Find ADDITIONAL toolboxes and copy xml files to data folders
if ~isempty(additionalToolboxDir)
    flist=dir(additionalToolboxDir);
    for i=1:length(flist)
        toolbox=flist(i).name;
        if isdir([additionalToolboxDir filesep toolbox])
            switch lower(toolbox)
                case{'.','..','.svn'}
                otherwise
                    xmlfile=[additionalToolboxDir filesep toolbox filesep 'xml' filesep 'toolbox.' lower(toolbox) '.xml'];
                    %xmlfile=[additionalToolboxDir filesep toolbox filesep 'xml' filesep toolbox '.xml'];
                    if exist(xmlfile,'file')
                        xml=xml2struct(xmlfile);
                        switch lower(xml.enable)
                            case{'1','y','yes'}
                                % Check if there is a data folder in directory of this
                                % toolbox
                                if isdir([additionalToolboxDir filesep toolbox filesep 'data'])
                                    if ~isdir([datadir 'toolboxes' filesep toolbox])
                                        mkdir([datadir 'toolboxes' filesep toolbox]);
                                    end
                                    copyfile([additionalToolboxDir filesep toolbox filesep 'data' filesep '*'],[datadir 'toolboxes' filesep toolbox]);
                                end
                        end
                    end
            end
        end
    end
end
