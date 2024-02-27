function handles = ddb_makeMenu(handles)
%DDB_MAKEMENU  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_makeMenu(handles)
%
%   Input:
%   handles =
%
%   Output:
%   handles =
%
%   Example
%   ddb_makeMenu
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

%% File
uimenu('Label','File','Tag','menufile');
% Items are added when ddb_selectModel is called

%% Toolbox
uimenu('Label','Toolbox','Tag','menutoolbox');
ddb_menuToolbox;

%% Models
model_names=fieldnames(handles.model);
if ~strcmpi(model_names{1},'none')
    uimenu('Label','Model','Tag','menumodel');
    ddb_menuModel;
    
    %% Domain
    uimenu('Label','Domain','Tag','menuDomain');
    handles=ddb_addMenuItem(handles,'Domain','Add Domain ...',      'Callback',{@ddb_menuDomain});
    handles=ddb_addMenuItem(handles,'Domain','tst',                 'Callback',{@ddb_menuDomain},'Separator','on','HandleName','FirstDomain');
    
end

%% Bathymetry
uimenu('Label','Bathymetry','Tag','menuBathymetry');
ddb_updateBathymetryMenu(handles);

if handles.configuration.include_menu_shoreline
    %% Shoreline
    uimenu('Label','Shoreline','Tag','menuShoreline');
    for i=1:handles.shorelines.nrShorelines
        if strcmpi(handles.shorelines.longName{i},handles.screenParameters.shoreline)
            if handles.shorelines.shoreline(i).isAvailable
                handles=ddb_addMenuItem(handles,'Shoreline',handles.shorelines.longName{i},'Callback',{@ddb_menuShoreline},'Checked','on','Enable','on');
            else
                handles=ddb_addMenuItem(handles,'Shoreline',handles.shorelines.longName{i},'Callback',{@ddb_menuShoreline},'Checked','on','Enable','off');
            end
        else
            if handles.shorelines.shoreline(i).isAvailable
                handles=ddb_addMenuItem(handles,'Shoreline',handles.shorelines.longName{i},'Callback',{@ddb_menuShoreline},'Checked','off','Enable','on');
            else
                handles=ddb_addMenuItem(handles,'Shoreline',handles.shorelines.longName{i},'Callback',{@ddb_menuShoreline},'Checked','off','Enable','off');
            end
        end
    end
end

%% View -> from now model specific items to be filled in by a model select function (for example: ddb_selectDelft3DFLOW.m)
uimenu('Label','View','Tag','menuView');
handles=ddb_addMenuItem(handles,'View','Background Bathymetry','Callback',{@ddb_menuView},'Checked','on','longname','Bathymetry');
handles=ddb_addMenuItem(handles,'View','Aerial',               'Callback',{@ddb_menuView},'Checked','off','Enable','on','longname','Aerial');
handles=ddb_addMenuItem(handles,'View','Hybrid',               'Callback',{@ddb_menuView},'Checked','off','Enable','on','longname','Hybrid');
handles=ddb_addMenuItem(handles,'View','Roads',                'Callback',{@ddb_menuView},'Checked','off','Enable','on','longname','Map');
handles=ddb_addMenuItem(handles,'View','None',                 'Callback',{@ddb_menuView},'Checked','off','Enable','on','longname','None');

set(handles.GUIHandles.Menu.View.BackgroundBathymetry,'Checked','off');
set(handles.GUIHandles.Menu.View.Aerial,'Checked','off');
set(handles.GUIHandles.Menu.View.Hybrid,'Checked','off');
set(handles.GUIHandles.Menu.View.Roads,'Checked','off');
set(handles.GUIHandles.Menu.View.None,'Checked','off');

switch lower(handles.configuration.background_image)
    case{'bathymetry'}
        set(handles.GUIHandles.Menu.View.BackgroundBathymetry,'Checked','on');
    case{'satellite'}
        set(handles.GUIHandles.Menu.View.Roads,'Checked','on');
end

if handles.configuration.include_menu_shoreline
    handles=ddb_addMenuItem(handles,'View','Shoreline',            'Callback',{@ddb_menuView},'Checked','on','longname','Shoreline','Separator','on');
    handles=ddb_addMenuItem(handles,'View','Cities',               'Callback',{@ddb_menuView});
end
% handles=ddb_addMenuItem(handles,'View','Model',                'longname','Model specific items','Separator','on');
handles=ddb_addMenuItem(handles,'View','Settings',             'Callback',{@ddb_menuView},'Separator','on');

handles=ddb_addModelViewMenu(handles);

%% Coordinate System

if handles.configuration.include_menu_coordinate_system
    
    uimenu('Label','Coordinate System','Tag','menuCoordinateSystem');
    
    % Determine what type of coordinate system
    name=handles.screenParameters.coordinateSystem.name;
    type=handles.screenParameters.coordinateSystem.type;
    
    geoname='WGS 84';
    prjname='Amersfoort / RD New';
    utmname='WGS 84 / UTM zone 31N';
    
    geocheck='off';
    prjcheck='off';
    utmcheck='off';
    
    if strcmpi(type,'geographic')
        geocheck='on';
        if ~strcmpi(name,'wgs 84')
            geoname=name;
        end
    else
        if strcmpi(name(1:12),'WGS 84 / UTM')
            utmname=name;
            utmcheck='on';
        else
            prjname=name;
            prjcheck='on';
        end
    end
    
    handles=ddb_addMenuItem(handles,'CoordinateSystem',geoname,               'Callback',{@ddb_menuCoordinateSystem},'Checked',geocheck,'HandleName','Geographic');
    
    handles=ddb_addMenuItem(handles,'CoordinateSystem','Other Geographic ...',     'Callback',{@ddb_menuCoordinateSystem});
    
    handles=ddb_addMenuItem(handles,'CoordinateSystem',prjname,  'Callback',{@ddb_menuCoordinateSystem},'Separator','on','HandleName','Cartesian','Checked',prjcheck);
    
    handles=ddb_addMenuItem(handles,'CoordinateSystem','Other Cartesian ...',      'Callback',{@ddb_menuCoordinateSystem});
    
    handles=ddb_addMenuItem(handles,'CoordinateSystem',utmname,'Callback',{@ddb_menuCoordinateSystem},'Separator','on','HandleName','UTM','Checked',utmcheck);
    
    handles=ddb_addMenuItem(handles,'CoordinateSystem','Select UTM Zone ...',  'Callback',{@ddb_menuCoordinateSystem});
    
end

%% Options
if handles.configuration.include_menu_options
    ddb_menuOptions;
end

%% Help
hhelp=uimenu('Label','Help','Tag','menuHelp');
for j=1:length(handles.configuration.menu_help)
    if isfield(handles.configuration.menu_help(j).menu_help,'url')
        url = handles.configuration.menu_help(j).menu_help.url;
        h1=uimenu(hhelp,'Label',handles.configuration.menu_help(j).menu_help.text,'Callback',{@menu_help_web,url});
    else
        callback = handles.configuration.menu_help(j).menu_help.callback;
        h1=uimenu(hhelp,'Label',handles.configuration.menu_help(j).menu_help.text,'Callback',callback);
    end
end
%handles=ddb_addMenuItem(handles,'Help','Deltares Online',        'Callback',{@ddb_menuHelp});
%handles=ddb_addMenuItem(handles,'Help','Delft Dashboard Online', 'Callback',{@ddb_menuHelp});
%handles=ddb_addMenuItem(handles,'Help','About Delft Dashboard',  'Callback',{@ddb_menuHelp});

%% Debug
if ~isdeployed
    uimenu('Label','Debug','Tag','menuDebug');
    handles=ddb_addMenuItem(handles,'Debug','Reload XML','Callback',{@ddb_menuDebug},'Checked','off');
end

function menu_help_web(hObject, eventdata, url)

web(url,'-browser');
