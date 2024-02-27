function ddb_editViewSettings
%DDB_EDITVIEWSETTINGS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_editViewSettings
%
%   Input:

%
%
%
%
%   Example
%   ddb_editViewSettings
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
h=getHandles;

f=MakeNewWindow('View Settings',[250 250],'modal',[h.settingsDir filesep 'icons' filesep 'deltares.gif']);

bgc=get(gcf,'Color');

str={'Earth','Jet'};
ii=strmatch(h.screenParameters.colorMap,str,'exact');
handles.SelectColorMap = uicontrol(gcf,'Style','popupmenu','Position',[30 195 80 20],'String',str,'BackgroundColor',[1 1 1],'Tag','UIControl');
handles.TextColorMap = uicontrol(gcf,'Style','text','String','Color Map','Position',[30 215  80 20],'BackgroundColor',bgc,'Tag','UIControl');
set(handles.SelectColorMap,'Value',ii);

handles.EditCMin = uicontrol(gcf,'Style','edit','Position',[30 145  50 20],'HorizontalAlignment','right', 'BackgroundColor',[1 1 1],'Tag','UIControl');
handles.EditCMax = uicontrol(gcf,'Style','edit','Position',[30 170  50 20],'HorizontalAlignment','right', 'BackgroundColor',[1 1 1],'Tag','UIControl');
set(handles.EditCMin,'String',h.screenParameters.cMin);
set(handles.EditCMax,'String',h.screenParameters.cMax);
handles.TextCMin = uicontrol(gcf,'Style','text','String','CMin','Position',[85 141  50 20],'HorizontalAlignment','left','BackgroundColor',bgc,'Tag','UIControl');
handles.TextCMax = uicontrol(gcf,'Style','text','String','CMax','Position',[85 166  50 20],'HorizontalAlignment','left','BackgroundColor',bgc,'Tag','UIControl');

handles.ToggleAutomatic = uicontrol(gcf,'Style','checkbox','String','Automatic Color Limits','Position',[30 120  200 20],'BackgroundColor',bgc,'Tag','UIControl');
set(handles.ToggleAutomatic,'Value',h.screenParameters.automaticColorLimits);

handles.TextQuality = uicontrol(gcf,'Style','text','String','Quality','Position',[30 92  50 20],'BackgroundColor',bgc,'Tag','UIControl');
str={'Low','Medium','High'};
handles.SelectQuality = uicontrol(gcf,'Style','popupmenu','Position',[86 95 80 20],'String',str,'BackgroundColor',[1 1 1],'Tag','UIControl');
ii=strmatch(h.screenParameters.backgroundQuality,str,'exact');
set(handles.SelectQuality,'Value',ii);

handles.EditHillShading = uicontrol(gcf,'Style','edit','Position',[100 65 40 20],'HorizontalAlignment','right', 'BackgroundColor',[1 1 1],'Tag','UIControl');
handles.TextHillShading = uicontrol(gcf,'Style','text','String','Hill Shading','Position',[30 62 60 20],'HorizontalAlignment','left','BackgroundColor',bgc,'Tag','UIControl');
set(handles.EditHillShading,'String',h.screenParameters.hillShading);


handles.PushOK     = uicontrol(gcf,'Style','pushbutton','String','OK',    'Position',[110 20 60 30]);
handles.PushCancel = uicontrol(gcf,'Style','pushbutton','String','Cancel','Position',[40 20 60 30]);

if h.screenParameters.automaticColorLimits
    set(handles.EditCMin,'Enable','off');
    set(handles.EditCMax,'Enable','off');
    set(handles.TextCMin,'Enable','off');
    set(handles.TextCMax,'Enable','off');
end

set(handles.ToggleAutomatic,     'CallBack',{@ToggleAutomatic_CallBack});

set(handles.PushOK,              'CallBack',{@PushOK_CallBack});
set(handles.PushCancel,          'CallBack',{@PushCancel_CallBack});

guidata(f,handles);

uiwait;

%%
function ToggleAutomatic_CallBack(hObject,eventdata)
handles=guidata(gcf);
if get(hObject,'Value')
    set(handles.EditCMin,'Enable','off');
    set(handles.EditCMax,'Enable','off');
    set(handles.TextCMin,'Enable','off');
    set(handles.TextCMax,'Enable','off');
else
    set(handles.EditCMin,'Enable','on');
    set(handles.EditCMax,'Enable','on');
    set(handles.TextCMin,'Enable','on');
    set(handles.TextCMax,'Enable','on');
end

%%
function PushOK_CallBack(hObject,eventdata)

h=getHandles;

handles=guidata(gcf);
cmin=str2double(get(handles.EditCMin,'String'));
cmax=str2double(get(handles.EditCMax,'String'));
autocol=get(handles.ToggleAutomatic,'Value');
str=get(handles.SelectColorMap,'String');
ii=get(handles.SelectColorMap,'Value');
clmap=str{ii};
str=get(handles.SelectQuality,'String');
ii=get(handles.SelectQuality,'Value');
qual=str{ii};

hs=str2double(get(handles.EditHillShading,'String'));

if cmin~=h.screenParameters.cMin || cmax~=h.screenParameters.cMax || autocol~=h.screenParameters.automaticColorLimits || ~strcmpi(h.screenParameters.colorMap,clmap)
    plotnew=1;
else
    plotnew=0;
end

h.screenParameters.cMin=cmin;
h.screenParameters.cMax=cmax;
h.screenParameters.colorMap=clmap;
h.screenParameters.automaticColorLimits=autocol;
h.screenParameters.backgroundQuality=qual;
h.screenParameters.hillShading=hs;

setHandles(h);

closereq;
uiresume;

if plotnew
%    ddb_plotBackgroundBathymetry(h);
    x11=h.GUIData.x;
    y11=h.GUIData.y;
    z11=h.GUIData.z;
    ddb_plotBackgroundBathymetryImage(h,x11,y11,z11);
end

%%
function PushCancel_CallBack(hObject,eventdata)
closereq;
uiresume;

