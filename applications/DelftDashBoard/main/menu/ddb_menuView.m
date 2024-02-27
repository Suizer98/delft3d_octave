function ddb_menuView(hObject, eventdata)
%DDB_MENUVIEW  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_menuView(hObject, eventdata)
%
%   Input:
%   hObject   =
%   eventdata =
%
%
%
%
%   Example
%   ddb_menuView
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

%%
handles=getHandles;

tg=get(hObject,'Tag');

switch tg,
    case{'menuViewShoreline'}
        menuViewShorelines_Callback(hObject,eventdata,handles);
    case{'menuViewBackgroundBathymetry'}
        menuViewBackgroundBathymetry_Callback(hObject,eventdata,handles);
    case{'menuViewAerial'}
        menuViewAerial_Callback(hObject,eventdata,handles);
    case{'menuViewHybrid'}
        menuViewHybrid_Callback(hObject,eventdata,handles);
    case{'menuViewRoads'}
        menuViewRoads_Callback(hObject,eventdata,handles);
    case{'menuViewNone'}
        menuViewNone_Callback(hObject,eventdata,handles);
    case{'menuViewCities'}
        menuViewCities_Callback(hObject,eventdata,handles);
    case{'menuViewSettings'}
        menuViewSettings_Callback(hObject,eventdata);
end    

%%
function menuViewShorelines_Callback(hObject, eventdata, handles)

checked=get(hObject,'Checked');

if strcmp(checked,'on')
    set(hObject,'Checked','off');
    set(handles.mapHandles.shoreline,'Visible','off');
else
    set(hObject,'Checked','on');
    set(handles.mapHandles.shoreline,'Visible','on');
end

%%
function menuViewBackgroundBathymetry_Callback(hObject, eventdata, handles)

checked=get(hObject,'Checked');

if strcmp(checked,'on')
    set(hObject,'Checked','off');
    set(handles.mapHandles.backgroundImage,'Visible','off');
else
    set(hObject,'Checked','on');
    set(handles.mapHandles.backgroundImage,'Visible','on');
    handles.GUIData.backgroundImageType='bathymetry';
    set(handles.GUIHandles.Menu.View.Aerial,'Checked','off');
    set(handles.GUIHandles.Menu.View.Hybrid,'Checked','off');
    set(handles.GUIHandles.Menu.View.Roads,'Checked','off');
    set(handles.GUIHandles.Menu.View.None,'Checked','off');
    setHandles(handles);
    ddb_updateDataInScreen;
end

%%
function menuViewAerial_Callback(hObject, eventdata, handles)

checked=get(hObject,'Checked');

if strcmp(checked,'on')
    set(hObject,'Checked','off');
    set(handles.mapHandles.backgroundImage,'Visible','off');
else
    set(hObject,'Checked','on');
    set(handles.mapHandles.backgroundImage,'Visible','on');
    handles.GUIData.backgroundImageType='satellite';
    handles.screenParameters.satelliteImageType='aerial';
    set(handles.GUIHandles.Menu.View.BackgroundBathymetry,'Checked','off');
    set(handles.GUIHandles.Menu.View.Hybrid,'Checked','off');
    set(handles.GUIHandles.Menu.View.Roads,'Checked','off');
    set(handles.GUIHandles.Menu.View.None,'Checked','off');
    setHandles(handles);
    ddb_updateDataInScreen;
end

%%
function menuViewHybrid_Callback(hObject, eventdata, handles)

checked=get(hObject,'Checked');

if strcmp(checked,'on')
    set(hObject,'Checked','off');
    set(handles.mapHandles.backgroundImage,'Visible','off');
else
    set(hObject,'Checked','on');
    set(handles.mapHandles.backgroundImage,'Visible','on');
    handles.GUIData.backgroundImageType='satellite';
    handles.screenParameters.satelliteImageType='hybrid';
    set(handles.GUIHandles.Menu.View.BackgroundBathymetry,'Checked','off');
    set(handles.GUIHandles.Menu.View.Aerial,'Checked','off');
    set(handles.GUIHandles.Menu.View.Roads,'Checked','off');
    set(handles.GUIHandles.Menu.View.None,'Checked','off');
    setHandles(handles);
    ddb_updateDataInScreen;
end

%%
function menuViewRoads_Callback(hObject, eventdata, handles)

checked=get(hObject,'Checked');

if strcmp(checked,'on')
    set(hObject,'Checked','off');
    set(handles.mapHandles.backgroundImage,'Visible','off');
else
    set(hObject,'Checked','on');
    set(handles.mapHandles.backgroundImage,'Visible','on');
    handles.GUIData.backgroundImageType='satellite';
    handles.screenParameters.satelliteImageType='road';
    set(handles.GUIHandles.Menu.View.BackgroundBathymetry,'Checked','off');
    set(handles.GUIHandles.Menu.View.Aerial,'Checked','off');
    set(handles.GUIHandles.Menu.View.Hybrid,'Checked','off');
    set(handles.GUIHandles.Menu.View.None,'Checked','off');
    setHandles(handles);
    ddb_updateDataInScreen;
end

%%
function menuViewNone_Callback(hObject, eventdata, handles)

checked=get(hObject,'Checked');

if strcmp(checked,'on')
    set(hObject,'Checked','off');
    set(handles.mapHandles.backgroundImage,'Visible','off');
else
    set(hObject,'Checked','on');
    set(handles.mapHandles.backgroundImage,'Visible','off');
    handles.GUIData.backgroundImageType='none';
    set(handles.GUIHandles.Menu.View.BackgroundBathymetry,'Checked','off');
    set(handles.GUIHandles.Menu.View.Aerial,'Checked','off');
    set(handles.GUIHandles.Menu.View.Hybrid,'Checked','off');
    setHandles(handles);
%     ddb_updateDataInScreen;
end

%%
function menuViewCities_Callback(hObject, eventdata, handles)
checked=get(hObject,'Checked');
if strcmp(checked,'on')
    set(hObject,'Checked','off');
    set(handles.mapHandles.textCities,'Visible','off');
    set(handles.mapHandles.cities,'Visible','off');
else
    set(hObject,'Checked','on');
    set(handles.mapHandles.textCities,'Visible','on');
    set(handles.mapHandles.cities,'Visible','on');
end    

%%
function menuViewSettings_Callback(hObject, eventdata)

ddb_zoomOff;
ddb_editViewSettings;
