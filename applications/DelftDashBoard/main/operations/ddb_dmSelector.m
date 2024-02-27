function handles = ddb_dmSelector(handles,figTitle,data,names,locs)
%DDB_DMSELECTOR  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_dmSelector(handles,title,data,names,locs)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   handles = ddb_dmSelector(handles,'Bathymetry',{'set1','set2'},{'set1.nc','set2.nc'},{'opendap','local'});
%
%   See also DelftDashboard

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 <COMPANY>
%       Arjan Mol
%
%       arjan.mol@deltares.nl
%
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
% Created: 15 Sep 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: ddb_dmSelector.m 16776 2020-11-09 10:02:09Z leijnse $
% $Date: 2020-11-09 18:02:09 +0800 (Mon, 09 Nov 2020) $
% $Author: leijnse $
% $Revision: 16776 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/main/operations/ddb_dmSelector.m $
% $Keywords: $

%%
dmFig = makeNewWindow(figTitle,[600 400],[handles.SettingsDir filesep 'icons' filesep 'deltares.gif']);

% static items
dataTxt = uicontrol('Parent',dmFig,'Units','normalized','Style','text','Tag','ddb_dmDataTxt','String','Data set',...
    'FontWeight','bold','Position',[0.01 0.9 0.2 0.05],'horizontalAlignment','left','BackgroundColor',get(dmFig,'color'));
nameTxt = uicontrol('Parent',dmFig,'Units','normalized','Style','text','Tag','ddb_dmNameTxt','String','File name',...
    'FontWeight','bold','Position',[0.41 0.9 0.2 0.05],'horizontalAlignment','left','BackgroundColor',get(dmFig,'color'));
odTxt = uicontrol('Parent',dmFig,'Units','normalized','Style','text','Tag','ddb_dmOdTxt','String','OpenDap',...
    'FontWeight','bold','Position',[0.61 0.9 0.2 0.05],'horizontalAlignment','left','BackgroundColor',get(dmFig,'color'));
locTxt = uicontrol('Parent',dmFig,'Units','normalized','Style','text','Tag','ddb_dmLocTxt','String','Local',...
    'FontWeight','bold','Position',[0.81 0.9 0.2 0.05],'horizontalAlignment','left','BackgroundColor',get(dmFig,'color'));

applyBut = uicontrol('Parent',dmFig','Units','normalized','Style','pushbutton','String','Apply','position',[0.6 0.05 0.18 0.05],'Callback',{@dmApply});
cancelBut = uicontrol('Parent',dmFig','Units','normalized','Style','pushbutton','String','Cancel','position',[0.8 0.05 0.18 0.05],'Callback',{@dmCancel});
if ~strcmp(figTitle,'Tidemodels')
    cacheBut = uicontrol('Parent',dmFig','Units','normalized','Style','pushbutton','String','Clear cache','position',[0.02 0.05 0.18 0.05],'Callback',{@dmDeleteCache});
end

% dynamic items
if length(data)>1
    vertPos = [0.2:0.6/(length(data)-1):0.8];
else
    vertPos = [0.8];
end

for ii = 1:length(data)
    hData(ii) = uicontrol('Parent',dmFig,'Units','normalized','Style','text','Tag',['ddb_dmData_' num2str(ii)],'String',data{ii},...
        'FontWeight','normal','Position',[0.01 vertPos(ii) 0.39 0.05],'horizontalAlignment','left','BackgroundColor',get(dmFig,'color'));
    hName(ii) = uicontrol('Parent',dmFig,'Units','normalized','Style','text','Tag',['ddb_dmName_' num2str(ii)],'String',names{ii},...
        'FontWeight','normal','Position',[0.41 vertPos(ii) 0.39 0.05],'horizontalAlignment','left','BackgroundColor',get(dmFig,'color'));
    hRB(1,ii) = uicontrol('Parent',dmFig,'Units','normalized','Style','radiobutton','Tag',['ddb_dmOd_' num2str(ii)],...
        'Value',strcmp(locs{ii},'opendap'),'Position',[0.61 vertPos(ii) 0.05 0.05],'BackgroundColor',get(dmFig,'color'),'Callback',{@dmRadioBut});
    hRB(2,ii) = uicontrol('Parent',dmFig,'Units','normalized','Style','radiobutton','Tag',['ddb_dmLoc_' num2str(ii)],...
        'Value',strcmp(locs{ii},'local'),'Position',[0.81 vertPos(ii) 0.05 0.05],'BackgroundColor',get(dmFig,'color'),'Callback',{@dmRadioBut});
end

%%
function dmApply(hObject,eventdata)
handles=getHandles;
dmFig = get(hObject,'Parent');
datatype = lower(get(dmFig,'Tag'));
dataDir = handles.BathyDir(1:findstr(handles.BathyDir,'bathymetry')-1);
ddb_opendap_fileS   = 'https://opendap.deltares.nl/thredds/fileServer/opendap/deltares/delftdashboard/';
ddb_opendap_dodsC   = 'https://opendap.deltares.nl/thredds/dodsC/opendap/deltares/delftdashboard/';
ddb_opendap_catalog = 'https://opendap.deltares.nl/thredds/catalog/opendap/deltares/delftdashboard/';
cache = 'yes';

switch datatype
    case 'bathymetry'
        defFile = [handles.BathyDir '\tiledbathymetries.def'];
        
        % make backup
        copyfile(defFile,[defFile '.bu']);
        
        % create new def file
        fid = fopen(defFile,'w');
        
        for ii = 1:length(handles.Bathymetry.NrDatasets)
            name = handles.Bathymetry.Dataset(ii).Name;
            fprintf(fid,'%s\n\n',['BathymetryDataset "' handles.Bathymetry.Dataset(ii).longName '"']);
            fprintf(fid,'%s\n',['    Type "' handles.Bathymetry.Dataset(ii).Type '"']);
            fprintf(fid,'%s\n',['    Name "' name '"']);
            if get(findobj(dmFig,'tag',['ddb_dmOd_' num2str(ii)]),'Value') % use opendap data
                fprintf(fid,'%s\n',['    URL "' ddb_opendap_fileS 'bathymetry/' name]);
                handles.Bathymetry.Dataset(ii).URL = [ddb_opendap_fileS 'bathymetry/' name];
            elseif get(findobj(dmFig,'tag',['ddb_dmLoc_' num2str(ii)]),'Value') % use local data
                fprintf(fid,'%s\n',['    URL "' dataDir 'bathymetry' filesep name]);
                handles.Bathymetry.Dataset(ii).URL = [dataDir 'bathymetry' filesep name];
                % copy files to local datadir
                if ~exist(handles.Bathymetry.Dataset(ii).URL,'dir')
                    mkdir(handles.Bathymetry.Dataset(ii).URL);
                end
                ddb_urlwrite([ddb_opendap_fileS 'bathymetry/' name '/' name '.nc'],[handles.Bathymetry.Dataset(ii).URL filesep name '.nc']);
                % copy tiles
                hW  = waitbar(0,'Please wait while downloading tiles...');
                tiles = opendap_catalog([ddb_opendap_catalog 'bathymetry/' name '/catalog.html'],'maxlevel',Inf);
                tiles = strrep(tiles,'dodsC','fileServer');
                for t = 1:length(tiles)
                    tname = fliplr(strtok(fliplr(tiles{t}),'/'));
                    dir = strrep(strrep(tiles{t},[ddb_opendap_fileS 'bathymetry/' name '/'],''),tname,'');
                    if ~isempty(dir)
                        mkdir([dataDir 'bathymetry' filesep name],dir);
                    end
                    ddb_urlwrite(tiles{t},[dataDir 'bathymetry' filesep name filesep dir filesep tname]);
                    waitbar(t/length(tiles),hW);
                end
                close(hW);
            end
            fprintf(fid,'%s\n\n',['    useCache ' cache]);
            fprintf(fid,'%s\n\n','EndShoreline');
        end
        fclose(fid);
    case 'tidemodels'
        defFile = [handles.TideDir '\tidemodels.def'];
        
        % make backup
        copyfile(defFile,[defFile '.bu']);
        
        % create new def file
        fid = fopen(defFile,'w');
        
        for ii = 1:length(handles.TideModels.nrModels)
            name = handles.TideModels.Model(ii).Name;
            fprintf(fid,'%s\n\n',['TideModel "' handles.TideModels.Model(ii).longName '"']);
            fprintf(fid,'%s\n',['    Type "' handles.TideModels.Model(ii).Type '"']);
            fprintf(fid,'%s\n',['    Name "' name '"']);
            if get(findobj(dmFig,'tag',['ddb_dmOd_' num2str(ii)]),'Value') % use opendap data
                fprintf(fid,'%s\n',['    URL "' ddb_opendap_dodsC 'tidemodels']);
                handles.TideModels.Model(ii).URL = [ddb_opendap_dodsC 'tidemodels'];
            elseif get(findobj(dmFig,'tag',['ddb_dmLoc_' num2str(ii)]),'Value') % use local data
                fprintf(fid,'%s\n',['    URL "' dataDir 'tidemodels']);
                handles.TideModels.Model(ii).URL = [dataDir 'tidemodels'];
                % copy files to local datadir
                if ~exist(handles.TideModels.Model(ii).URL,'dir')
                    mkdir(handles.TideModels.Model(ii).URL);
                end
                ddb_urlwrite([ddb_opendap_fileS 'tidemodels/' name '.nc'],[handles.TideModels.Model(ii).URL filesep name '.nc']);
                % copy tiles (no tiles for tidemodels!
            end
            fprintf(fid,'%s\n\n',['    useCache ' cache]);
            fprintf(fid,'%s\n\n','EndTideModels');
        end
        fclose(fid);
    case 'shorelines'
        defFile = [handles.ShorelineDir '\shorelines.def'];
        
        % make backup
        copyfile(defFile,[defFile '.bu']);
        
        % create new def file
        fid = fopen(defFile,'w');
        
        for ii = 1:length(handles.Shorelines.nrShorelines)
            name = handles.Shorelines.Shoreline(ii).Name;
            fprintf(fid,'%s\n\n',['Shoreline "' handles.Shorelines.Shoreline(ii).longName '"']);
            fprintf(fid,'%s\n',['    Type "' handles.Shorelines.Shoreline(ii).Type '"']);
            fprintf(fid,'%s\n',['    Name "' name '"']);
            if get(findobj(dmFig,'tag',['ddb_dmOd_' num2str(ii)]),'Value') % use opendap data
                fprintf(fid,'%s\n',['    URL "' ddb_opendap_fileS 'shorelines/' name]);
                handles.Shorelines.Shoreline(ii).URL = [ddb_opendap_fileS 'shorelines/' name];
            elseif get(findobj(dmFig,'tag',['ddb_dmLoc_' num2str(ii)]),'Value') % use local data
                fprintf(fid,'%s\n',['    URL "' dataDir 'shorelines' filesep name]);
                handles.Shorelines.Shoreline(ii).URL = [dataDir 'shorelines' filesep name];
                % copy files to local datadir
                if ~exist(handles.Shorelines.Shoreline(ii).URL,'dir')
                    mkdir(handles.Shorelines.Shoreline(ii).URL);
                end
                ddb_urlwrite([ddb_opendap_fileS 'shorelines/' name '/' name '.nc'],[handles.Shorelines.Shoreline(ii).URL filesep name '.nc']);
                % copy tiles
                hW  = waitbar(0,'Please wait while downloading tiles...');
                tiles = opendap_catalog([ddb_opendap_catalog 'shorelines/' name '/catalog.html'],'maxlevel',Inf);
                tiles = strrep(tiles,'dodsC','fileServer');
                for t = 1:length(tiles)
                    tname = fliplr(strtok(fliplr(tiles{t}),'/'));
                    dir = strrep(strrep(tiles{t},[ddb_opendap_fileS 'shorelines/' name '/'],''),tname,'');
                    if ~isempty(dir)
                        mkdir([dataDir 'shorelines' filesep name],dir);
                    end
                    ddb_urlwrite(tiles{t},[dataDir 'shorelines' filesep name filesep dir filesep tname]);
                    waitbar(t/length(tiles),hW);
                end
                close(hW);
            end
            fprintf(fid,'%s\n\n',['    useCache ' cache]);
            fprintf(fid,'%s\n\n','EndShoreline');
        end
        fclose(fid);
end

setHandles(handles);
%%
function dmCancel(hObject,eventdata)
close(get(hObject,'Parent'));
%%
function dmRadioBut(hObject,eventdata)
set(hObject,'Value',1);
if ~isempty(findstr(get(hObject,'tag'),'Loc'))
    set(findobj(get(hObject,'Parent'),'tag',strrep(get(hObject,'tag'),'Loc','Od')),'Value',0);
elseif ~isempty(findstr(get(hObject,'tag'),'Od'))
    set(findobj(get(hObject,'Parent'),'tag',strrep(get(hObject,'tag'),'Od','Loc')),'Value',0);
end

%%
function dmDeleteCache(hObject,eventdata)
handles=getHandles;
dmFig = get(hObject,'Parent');
datatype = lower(get(dmFig,'Tag'));
dataDir = handles.BathyDir(1:findstr(handles.BathyDir,'bathymetry')-1);

clearData = questdlg(['You are about to clear all cached ' datatype 'data!'], 'Clear cache', 'Ok', 'Cancel','Ok');

if strcmp(clearData,'Ok')
    dirs = dir([dataDir filesep datatype]);
    dirs = dirs([dirs.isdir] & ~strcmp('..',{dirs.name})&~strcmp('.',{dirs.name}));
    
    for d = 1:length(dirs)
        rmdir([dataDir filesep datatype filesep dirs(d).name],'s');
    end
    
    hOd  = findobj(dmFig,'-regexp','tag','ddb_dmOd_.*');
    hLoc = findobj(dmFig,'-regexp','tag','ddb_dmLoc_.*');
    for ii = 1:length(hOd)
        set(hOd(ii),'Value',1);
        set(hLoc(ii),'Value',0);
    end
    dmApply(hObject,eventdata);
    
    msgbox('Cached data cleared!');
else
    msgbox('Cached data not cleared!');
end
