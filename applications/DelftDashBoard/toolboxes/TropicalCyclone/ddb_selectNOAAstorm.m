function [foutput] = ddb_selectNOAAstorm
%DDB_SELECTCOORDINATESYSTEM  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   [CS type nr ok] = ddb_selectCoordinateSystem(coordinateSystems, EPSG, varargin)
%
%   Input:
%   coordinateSystems =
%   EPSG              =
%   varargin          =
%
%   Output:
%   CS                =
%   type              =
%   nr                =
%   ok                =
%
%   Example
%   ddb_selectCoordinateSystem
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
% Default choice
foutput         = [];
handles.fid     = 1;
handles.ok      = 0;


handles.Window=MakeNewWindow('Select Your Storm',[400 480]);

handles.SelectCS = uicontrol(gcf,'Style','listbox','String','','Position', [ 30 70 340 390],'BackgroundColor',[1 1 1]);

bgc=get(gcf,'Color');

handles.pushFind  = uicontrol(gcf,'Style','pushbutton','String','Search','Position', [ 190 30 50 20]);

handles2 = getHandles;
load([handles2.toolbox.tropicalcyclone.dataDir 'hurricanes.mat']);
for ii = 1:length(tc)
    years    = year(tc(ii).time(1));
    basin    = tc(ii).basin;
    storm    = tc(ii).storm_number(1);
    hurricane_names{ii} = [num2str(years), '_', basin,num2str(storm),'_', tc(ii).name];
    hurricane_numbers(ii) = ii;
end
set(handles.SelectCS,'String',hurricane_names);

handles.PushOK      = uicontrol(gcf,'Style','pushbutton','String','OK','Position', [ 320 30 50 20]);
handles.PushCancel  = uicontrol(gcf,'Style','pushbutton','String','Cancel','Position', [ 260 30 50 20]);

set(handles.PushOK,     'CallBack',{@PushOK_CallBack});
set(handles.PushCancel, 'CallBack',{@PushCancel_CallBack});
set(handles.pushFind,   'CallBack',{@pushFind_CallBack});
set(handles.SelectCS,   'CallBack',{@SelectCS_CallBack});

pause(0.2);

guidata(gcf,handles);

uiwait;

handles=guidata(gcf);

if handles.ok
    ok=1;
    foutput   = handles.CS;
else
    foutput   = [];
    ok = 0;
end
close(gcf);

%%
function PushOK_CallBack(hObject,eventdata)
handles=guidata(gcf);
str=get(handles.SelectCS,'String');
ii=get(handles.SelectCS,'Value');
handles.CS=str{ii};
handles.ok=1;
guidata(gcf,handles);
uiresume;

%%
function PushCancel_CallBack(hObject,eventdata)
uiresume;

%%
function pushFind_CallBack(hObject,eventdata)
handles=guidata(gcf);
strs=get(handles.SelectCS,'String');
ifound=findStringUI(strs);
if ~isempty(ifound)
    guidata(gcf,handles);
    set(handles.SelectCS,'Value',ifound(1));
end

%%
function radioGeo_CallBack(hObject,eventdata)
uiresume
%%
function radioProj_CallBack(hObject,eventdata)
uiresume

%%
function SelectCS_CallBack(hObject,eventdata)
handles=guidata(gcf);
guidata(gcf,handles);