function ddb_editHLES
%DDB_EDITHLES  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_editHLES
%
%   Input:

%
%
%
%
%   Example
%   ddb_editHLES
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

handles=h.model.delft3dflow.domain(ad);

fig=MakeNewWindow('Horizontal Large Eddy Simulation',[300 250],'modal',[h.settingsDir filesep 'icons' filesep 'deltares.gif']);

bgc=get(fig,'Color');

handles.GUIHandles.EditHtural=uicontrol(gcf,'Style','edit','String',num2str(h.model.delft3dflow.domain(ad).Htural),'Position',[210 200 60 20],'HorizontalAlignment','right');
handles.GUIHandles.EditHturnd=uicontrol(gcf,'Style','edit','String',num2str(h.model.delft3dflow.domain(ad).Hturnd),'Position',[210 175 60 20],'HorizontalAlignment','right');
handles.GUIHandles.EditHturst=uicontrol(gcf,'Style','edit','String',num2str(h.model.delft3dflow.domain(ad).Hturst),'Position',[210 150 60 20],'HorizontalAlignment','right');
handles.GUIHandles.EditHturlp=uicontrol(gcf,'Style','edit','String',num2str(h.model.delft3dflow.domain(ad).Hturlp),'Position',[210 125 60 20],'HorizontalAlignment','right');
handles.GUIHandles.EditHturrt=uicontrol(gcf,'Style','edit','String',num2str(h.model.delft3dflow.domain(ad).Hturrt),'Position',[210 100 60 20],'HorizontalAlignment','right');
handles.GUIHandles.EditHturdm=uicontrol(gcf,'Style','edit','String',num2str(h.model.delft3dflow.domain(ad).Hturdm),'Position',[210  75 60 20],'HorizontalAlignment','right');

handles.GUIHandles.TextHtural=uicontrol(gcf,'Style','text','String','Slope in log-log spectrum [-]',          'Position',[25 197 175 20],'HorizontalAlignment','right','BackgroundColor',bgc);
handles.GUIHandles.TextHturnd=uicontrol(gcf,'Style','text','String','Dimensional number [-]',                 'Position',[25 172 175 20],'HorizontalAlignment','right','BackgroundColor',bgc);
handles.GUIHandles.TextHturst=uicontrol(gcf,'Style','text','String','Prandtl-Schmidt number [-]',             'Position',[25 147 175 20],'HorizontalAlignment','right','BackgroundColor',bgc);
handles.GUIHandles.TextHturlp=uicontrol(gcf,'Style','text','String','Spatial low-pass filter coefficient [-]','Position',[25 122 175 20],'HorizontalAlignment','right','BackgroundColor',bgc);
handles.GUIHandles.TextHturrt=uicontrol(gcf,'Style','text','String','Relaxation time [min]',                  'Position',[25  97 175 20],'HorizontalAlignment','right','BackgroundColor',bgc);
handles.GUIHandles.TextHturdm=uicontrol(gcf,'Style','text','String','Molecular diffusivity [m2/s]',           'Position',[25  72 175 20],'HorizontalAlignment','right','BackgroundColor',bgc);

handles.GUIHandles.PushOK     = uicontrol(gcf,'Style','pushbutton','String','OK',    'Position',[210 25 60 30]);
handles.GUIHandles.PushCancel = uicontrol(gcf,'Style','pushbutton','String','Cancel','Position',[140 25 60 30]);

set(handles.GUIHandles.PushOK,              'CallBack',{@PushOK_CallBack});
set(handles.GUIHandles.PushCancel,          'CallBack',{@PushCancel_CallBack});

SetUIBackgroundColors;

guidata(findobj('Name','Horizontal Large Eddy Simulation'),handles);

%%
function PushOK_CallBack(hObject,eventdata)
h2=guidata(findobj('Name','Horizontal Large Eddy Simulation'));
handles=getHandles;
handles.model.delft3dflow.domain(ad).Htural=str2double(get(h2.GUIHandles.EditHtural,'String'));
handles.model.delft3dflow.domain(ad).Hturnd=str2double(get(h2.GUIHandles.EditHturnd,'String'));
handles.model.delft3dflow.domain(ad).Hturst=str2double(get(h2.GUIHandles.EditHturst,'String'));
handles.model.delft3dflow.domain(ad).Hturlp=str2double(get(h2.GUIHandles.EditHturlp,'String'));
handles.model.delft3dflow.domain(ad).Hturrt=str2double(get(h2.GUIHandles.EditHturrt,'String'));
handles.model.delft3dflow.domain(ad).Hturdm=str2double(get(h2.GUIHandles.EditHturdm,'String'));
%    handles.model.delft3dflow.domain(ad).Hturel=1;
setHandles(handles);
closereq;

%%
function PushCancel_CallBack(hObject,eventdata)
closereq;

