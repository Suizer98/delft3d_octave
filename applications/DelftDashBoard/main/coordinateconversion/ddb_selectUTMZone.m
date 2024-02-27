function UTMZone = ddb_selectUTMZone
%DDB_SELECTUTMZONE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   UTMZone = ddb_selectUTMZone
%
%   Input:

%
%   Output:
%   UTMZone =
%
%   Example
%   ddb_selectUTMZone
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

% fig0=gcf;

%fig=MakeNewWindow('Select UTM Zone',[950 550],[h.settingsDir filesep 'icons' filesep 'deltares.gif'],'modal');
fig=MakeNewWindow('Select UTM Zone',[950 550],[h.settingsDir filesep 'icons' filesep 'deltares.gif']);

set(fig,'Renderer','opengl');

handles.PushOK     = uicontrol(gcf,'Style','pushbutton','String','OK',    'Position',[670 30 60 30]);
handles.PushCancel = uicontrol(gcf,'Style','pushbutton','String','Cancel','Position',[600 30 60 30]);

set(handles.PushOK,              'CallBack',{@PushOK_CallBack});
set(handles.PushCancel,          'CallBack',{@PushCancel_CallBack});

ax=gca;
set(ax,'Units','pixels');
set(ax,'Position',[50 100 850 400]);

x=h.mapData.worldCoastLine5000000(:,1);
y=h.mapData.worldCoastLine5000000(:,2);
z=zeros(size(x))+5000;
plt=plot(x,y);hold on;
set(plt,'Color',[0.3 0.3 0.3]);

set(ax,'xlim',[-180 180],'ylim',[-80 84]);

lonx=[-180:6:180];
for i=1:length(lonx)-1
    plt=plot([lonx(i) lonx(i)],[-90 90]);
    set(plt,'Color',[0.7 0.7 0.7]);
    tx=text(lonx(i)+3,2,num2str(i));
    set(tx,'HorizontalAlignment','center');
    set(tx,'FontSize',6);
end

handles.zn={'C','D','E','F','G','H','J','K','L','M','N','P','Q','R','S','T','U','V','W','X'};

laty=[-80:8:80];
for i=1:length(laty)-1
    plt=plot([-180 180],[laty(i) laty(i)]);
    set(plt,'Color',[0.5 0.5 0.5]);
    tx=text(3,laty(i)+5,handles.zn{i});
    set(tx,'HorizontalAlignment','center');
    set(tx,'FontSize',6);
end

str=[num2str(h.screenParameters.UTMZone{1}) h.screenParameters.UTMZone{2}];
handles.TextZone = uicontrol(gcf,'Style','text','String',['UTM Zone : ',str],'Position',[50  505  300 20],'HorizontalAlignment','left');

PlotUTMZone(h.screenParameters.UTMZone);

drawnow;
%pause(0.2);

set(fig,'WindowButtonDownFcn',{@SelectZone});
handles.screenParameters.UTMZone=h.screenParameters.UTMZone;

guidata(gcf,handles);

uiwait;

handles=guidata(gcf);
UTMZone=handles.screenParameters.UTMZone;

close(gcf);

%%
function PlotUTMZone(zone)

hh=findobj(gcf,'Tag','zone');
if ~isempty(hh)
    delete(hh);
end

zn={'C','D','E','F','G','H','J','K','L','M','N','P','Q','R','S','T','U','V','W','X'};
ilat=strmatch(zone{2},zn,'exact');

x0=-180+(zone{1}-1)*6;
y0=-80+(ilat-1)*8;

x=[x0 x0+6 x0+6 x0];
if ilat==20
    y=[y0 y0 y0+12 y0+12];
else
    y=[y0 y0 y0+8 y0+8];
end

ptch=patch(x,y,'r');
set(ptch,'Tag','zone');

%%
function SelectZone(imagefig, varargins)

handles=guidata(gcf);

pos = get(gca, 'CurrentPoint');

x0=pos(1,1);
y0=pos(1,2);
if x0>-180 && x0<180 && y0>-80 && y0<84
    zn={'C','D','E','F','G','H','J','K','L','M','N','P','Q','R','S','T','U','V','W','X'};
    ilat=ceil((y0+80)/8);
    ilon=ceil((x0+180)/6);
    handles.screenParameters.UTMZone{1}=ilon;
    handles.screenParameters.UTMZone{2}=zn{ilat};
    PlotUTMZone(handles.screenParameters.UTMZone);
    str=[num2str(handles.screenParameters.UTMZone{1}) handles.screenParameters.UTMZone{2}];
    set(handles.TextZone,'String',['UTM Zone : ',str]);
end

guidata(gcf,handles);

%%
function PushOK_CallBack(hObject,eventdata)
uiresume;

%%
function PushCancel_CallBack(hObject,eventdata)
handles=guidata(gcf);
handles.screenParameters.UTMZone=[];
guidata(gcf,handles);
uiresume;


