function ddb_navigationChartPlotOptions
%DDB_NAVIGATIONCHARTPLOTOPTIONS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_navigationChartPlotOptions
%
%   Input:

%
%
%
%
%   Example
%   ddb_navigationChartPlotOptions
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
% Created: 02 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
h=getHandles;

handles=handles.toolbox.navigationcharts;

MakeNewWindow('Plot Options',[800 650],'modal',[h.SettingsDir filesep 'icons' filesep 'deltares.gif']);

s=handles.Layers;
layers=fieldnames(s);
k=0;
posx=30;
posy=620;

nrows=30;

w=100;
x0=30;
y0=620;

posx=x0;
posy=y0;

for i=1:length(layers)
    layer=layers{i};
    if ~strcmpi(layer(1:4),'doll')
        handles.(layer).Text    =uicontrol(gcf,'Style','text','String',layer,'Position',   [posx posy 60 20]);
        handles.(layer).CheckBox=uicontrol(gcf,'Style','checkbox','String','','Position',   [posx+60 posy+5 60 20],'Tag',layer);
        lyr=layer;
        if ~isempty(handles.Layers.(lyr))
            if handles.Layers.(lyr)(1).Plot
                set(handles.(layer).CheckBox,'Value',1);
            end
        else
            set(handles.(layer).Text,'Enable','off');
            set(handles.(layer).CheckBox,'Enable','off');
        end
        posy=posy-20;
        if i/nrows==floor(i/nrows)
            posx=posx+w;
            posy=y0;
        end
        set(handles.(layer).CheckBox,  'Callback',{@CheckBox_Callback});
    end
end

handles.PushOK     = uicontrol(gcf,'Style','pushbutton','String','OK','Position',[700 30 70 20]);
handles.PushCancel = uicontrol(gcf,'Style','pushbutton','String','Cancel','Position',[620 30 70 20]);

set(handles.PushOK,  'Callback',{@PushOK_Callback});
set(handles.PushCancel,  'Callback',{@PushCancel_Callback});

guidata(gcf,handles);

%%
function PushOK_Callback(hObject,eventdata)
h=getHandles;
handles=guidata(gcf);
h.Toolbox(tb).Layers=handles.Layers;
setHandles(h);
close(gcf);

%%
function PushCancel_Callback(hObject,eventdata)
close(gcf);

%%
function CheckBox_Callback(hObject,eventdata)
handles=guidata(gcf);
layer=get(hObject,'Tag');
for i=1:length(handles.(layer))
    handles.(layer)(i).Plot=get(hObject,'Value');
    %    bbb=handles.(layer)(i).Plot;
end
guidata(gcf,handles);

