function [CS type nr ok] = ddb_selectCoordinateSystem(coordinateSystems, EPSG, varargin)
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
handles.ok=0;
iboth=0;
handles.coordinateSystems=coordinateSystems;

% Default coordinate systems
handles.CSproj='Amersfoort / RD New';
handles.CSgeo ='WGS 84';
csdefaulttype='geographic';
cstype='both';

for i=1:length(varargin)
    if ischar(varargin{i})
    switch lower(varargin{i})
        case{'type'}
            cstype=varargin{i+1};
            if strcmpi(cstype,'both')
                iboth=1;
            end
        case{'default'}
            cs0=varargin{i+1};
        case{'defaulttype'}
            csdefaulttype=varargin{i+1};
    end
    end
end

if iboth
    cstype=csdefaulttype;
end

switch lower(cstype)
    case{'geographic'}
        CoordinateSystemStrings=handles.coordinateSystems.coordSysGeo;
        handles.CSgeo = cs0;
    case{'projected'}
        CoordinateSystemStrings=handles.coordinateSystems.coordSysCart;
        handles.CSproj= cs0;
end

% Find indices of default
handles.iproj=strmatch(lower(handles.CSproj),lower(handles.coordinateSystems.coordSysCart),'exact');
handles.igeo=strmatch(lower(handles.CSgeo),lower(handles.coordinateSystems.coordSysGeo),'exact');

if isempty(handles.iproj)
    handles.iproj=1;
end
if isempty(handles.igeo)
    handles.igeo=1;
end

switch lower(cstype)
    case{'geographic'}
        ics=handles.igeo;
    case{'projected'}
        ics=handles.iproj;
end

handles.Window=MakeNewWindow('Select Coordinate System',[400 480]);

handles.SelectCS = uicontrol(gcf,'Style','listbox','String','','Position', [ 30 70 340 390],'BackgroundColor',[1 1 1]);

bgc=get(gcf,'Color');
handles.radioGeo  = uicontrol(gcf,'Style','radiobutton','String','Geographic','Position', [ 30 30 80 20],'BackgroundColor',bgc);
handles.radioProj = uicontrol(gcf,'Style','radiobutton','String','Projected', 'Position', [110 30 80 20],'BackgroundColor',bgc);

if strcmpi(cstype,'geographic')
    set(handles.radioGeo,'Value',1);
    set(handles.radioProj,'Value',0);
else
    set(handles.radioGeo,'Value',0);
    set(handles.radioProj,'Value',1);
end

if ~iboth
    set(handles.radioGeo,'Enable','off');
    set(handles.radioProj,'Enable','off');
end

handles.pushFind  = uicontrol(gcf,'Style','pushbutton','String','Search','Position', [ 190 30 50 20]);

set(handles.SelectCS,'String',CoordinateSystemStrings);
set(handles.SelectCS,'Value',ics);

handles.PushOK = uicontrol(gcf,'Style','pushbutton','String','OK','Position', [ 320 30 50 20]);
handles.PushCancel = uicontrol(gcf,'Style','pushbutton','String','Cancel','Position', [ 260 30 50 20]);

set(handles.PushOK,     'CallBack',{@PushOK_CallBack});
set(handles.PushCancel, 'CallBack',{@PushCancel_CallBack});
set(handles.pushFind,   'CallBack',{@pushFind_CallBack});
set(handles.radioGeo,   'CallBack',{@radioGeo_CallBack});
set(handles.radioProj,  'CallBack',{@radioProj_CallBack});
set(handles.SelectCS,   'CallBack',{@SelectCS_CallBack});

pause(0.2);

guidata(gcf,handles);

uiwait;

handles=guidata(gcf);

if handles.ok
    ok=1;
    CS=handles.CS;
    type=handles.CStype;
    nr=findEPSGcode(EPSG,CS,type);
else
    ok=0;
    CS=cs0;
    type=[];
    nr=[];
end
close(gcf);

%%
function PushOK_CallBack(hObject,eventdata)
handles=guidata(gcf);
str=get(handles.SelectCS,'String');
ii=get(handles.SelectCS,'Value');
handles.CS=str{ii};
if get(handles.radioProj,'Value')
    handles.CStype='projected';
else
    handles.CStype='geographic';
end
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
    handles.CS=strs{ifound};
    guidata(gcf,handles);
    set(handles.SelectCS,'Value',ifound);
end

%%
function radioGeo_CallBack(hObject,eventdata)
handles=guidata(gcf);
set(handles.radioProj,'Value',0);
set(handles.radioGeo,'Value',1);
set(handles.SelectCS,'String',handles.coordinateSystems.coordSysGeo);
set(handles.SelectCS,'Value',handles.igeo);

%%
function radioProj_CallBack(hObject,eventdata)
handles=guidata(gcf);
set(handles.radioProj,'Value',1);
set(handles.radioGeo,'Value',0);
set(handles.SelectCS,'String',handles.coordinateSystems.coordSysCart);
set(handles.SelectCS,'Value',handles.iproj);

%%
function SelectCS_CallBack(hObject,eventdata)
handles=guidata(gcf);
if get(handles.radioProj,'Value')
    handles.iproj=get(hObject,'Value');
else
    handles.igeo=get(hObject,'Value');
end
guidata(gcf,handles);


