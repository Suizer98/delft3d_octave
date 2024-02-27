function ddb_editBathymetryDetails
%DDB_EDITBATHYMETRYDETAILS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_editBathymetryDetails
%
%   Input:

%
%
%
%
%   Example
%   ddb_editBathymetryDetails
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
% Created: 01 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%
h=guidata(findobj('Tag','MainWindow'));

handles.Bathymetry=h.Bathymetry;
handles.CoordinateData.CoordinateSystems=h.CoordinateData.CoordinateSystems;

nm=handles.Bathymetry.Dataset(handles.Bathymetry.ActiveDataset).HorizontalCoordinateSystem.Name;
tp=handles.Bathymetry.Dataset(handles.Bathymetry.ActiveDataset).HorizontalCoordinateSystem.Type;

switch lower(tp)
    case{'cartesian'}
        handles.CSC=nm;
        handles.CSG='WGS 84';
    case{'geographic'}
        handles.CSC='Amersfoort / RD New';
        handles.CSG=nm;
end

nproj=0;
ngeo=0;
for i=1:length(handles.CoordinateData.CoordinateSystems)
    switch lower(handles.CoordinateData.CoordinateSystems(i).coord_ref_sys_kind),
        case{'projected'}
            nproj=nproj+1;
            handles.CSProj(nproj)=handles.CoordinateData.CoordinateSystems(i);
            handles.StrProj{nproj}=handles.CSProj(nproj).coord_ref_sys_name;
        case{'geographic 2d'}
            ngeo=ngeo+1;
            handles.CSGeo(ngeo)=handles.CoordinateData.CoordinateSystems(i);
            handles.StrGeo{ngeo}=handles.CSGeo(ngeo).coord_ref_sys_name;
    end
end

MakeNewWindow('Coordinate Details',[400 600],'modal',[handles.SettingsDir filesep 'icons' filesep 'deltares.gif']);

handles.SelectCS = uicontrol(gcf,'Style','listbox','String','','Position', [ 30 180 340 390],'BackgroundColor',[1 1 1]);

handles.ToggleProjected  = uicontrol(gcf,'Style','radiobutton','String','Projected','Position', [ 30 150 70 20]);
handles.ToggleGeographic = uicontrol(gcf,'Style','radiobutton','String','Geographic','Position',[100 150 90 20]);

str=handles.Bathymetry.Dataset(handles.Bathymetry.ActiveDataset).VerticalCoordinateSystem.Name;
lev=handles.Bathymetry.Dataset(handles.Bathymetry.ActiveDataset).VerticalCoordinateSystem.Level;
handles.EditVerticalCoordinateSystemName   = uicontrol(gcf,'Style','edit','String',str,         'Position', [195 120 100 20],'HorizontalAlignment','left');
handles.EditVerticalCoordinateSystemLevel  = uicontrol(gcf,'Style','edit','String',num2str(lev),'Position', [195  95 100 20],'HorizontalAlignment','right');
handles.TextVerticalCoordinateSystemName   = uicontrol(gcf,'Style','text','String','Vertical Coordinate System','Position', [ 30 116 155 20],'HorizontalAlignment','right');
handles.TextVerticalCoordinateSystemLevel  = uicontrol(gcf,'Style','text','String','Level w.r.t. Mean Sea Level (m)','Position', [30  91 155 20],'HorizontalAlignment','right');

handles.PushSave   = uicontrol(gcf,'Style','pushbutton','String','Save',  'Position', [ 300 60 70 20]);
handles.PushView   = uicontrol(gcf,'Style','pushbutton','String','View','Position', [ 220 60 70 20]);

handles.PushOK     = uicontrol(gcf,'Style','pushbutton','String','OK',    'Position', [ 300 30 70 20]);
handles.PushCancel = uicontrol(gcf,'Style','pushbutton','String','Cancel','Position', [ 220 30 70 20]);

set(handles.SelectCS, 'Callback',{@SelectCS_Callback});
set(handles.ToggleProjected,  'Callback',{@ToggleProjected_Callback});
set(handles.ToggleGeographic, 'Callback',{@ToggleGeographic_Callback});

set(handles.EditVerticalCoordinateSystemName,  'Callback',{@EditVerticalCoordinateSystemName_Callback});
set(handles.EditVerticalCoordinateSystemLevel, 'Callback',{@EditVerticalCoordinateSystemLevel_Callback});

set(handles.PushSave, 'Callback',{@PushSave_Callback});
set(handles.PushView, 'Callback',{@PushView_Callback});

set(handles.PushOK,     'Callback',{@PushOK_Callback});
set(handles.PushCancel, 'Callback',{@PushCancel_Callback});

if ~handles.Bathymetry.Dataset(handles.Bathymetry.ActiveDataset).Edit
    set(handles.SelectCS,'Enable','off');
    set(handles.ToggleProjected,'Enable','off');
    set(handles.ToggleGeographic,'Enable','off');
    set(handles.EditVerticalCoordinateSystemName,'Enable','off');
    set(handles.EditVerticalCoordinateSystemLevel,'Enable','off');
    set(handles.TextVerticalCoordinateSystemName,'Enable','off');
    set(handles.TextVerticalCoordinateSystemLevel,'Enable','off');
end

SetUIBackgroundColors;

guidata(gcf,handles);

RefreshAll(handles);

a=findobj(gcf,'type','axes');delete(a);

uiwait(gcf);

%%
function SelectCS_Callback(hObject,eventdata)
handles=guidata(gcf);
str=get(hObject,'String');
ii=get(hObject,'Value');
cs=str{ii};
j=handles.Bathymetry.ActiveDataset;
handles.Bathymetry.Dataset(j).HorizontalCoordinateSystem.Name=cs;
tp=handles.Bathymetry.Dataset(j).HorizontalCoordinateSystem.Type;
switch lower(tp)
    case{'cartesian'}
        handles.CSC=cs;
    case{'geographic'}
        handles.CSG=cs;
end
guidata(gcf,handles);

%%
function ToggleProjected_Callback(hObject,eventdata)
handles=guidata(gcf);
ii=get(hObject,'Value');
if ii==0
    set(hObject,'Value',1);
else
    j=handles.Bathymetry.ActiveDataset;
    handles.Bathymetry.Dataset(j).HorizontalCoordinateSystem.Name=handles.CSC;
    handles.Bathymetry.Dataset(j).HorizontalCoordinateSystem.Type='Cartesian';
    guidata(gcf,handles);
    RefreshAll(handles);
end

%%
function ToggleGeographic_Callback(hObject,eventdata)
handles=guidata(gcf);
ii=get(hObject,'Value');
if ii==0
    set(hObject,'Value',1);
else
    j=handles.Bathymetry.ActiveDataset;
    handles.Bathymetry.Dataset(j).HorizontalCoordinateSystem.Name=handles.CSG;
    handles.Bathymetry.Dataset(j).HorizontalCoordinateSystem.Type='Geographic';
    guidata(gcf,handles);
    RefreshAll(handles);
end

%%
function EditVerticalCoordinateSystemName_Callback(hObject,eventdata)
handles=guidata(gcf);
str=get(hObject,'String');
j=handles.Bathymetry.ActiveDataset;
handles.Bathymetry.Dataset(j).VerticalCoordinateSystem.Name=str;
guidata(gcf,handles);

%%
function EditVerticalCoordinateSystemLevel_Callback(hObject,eventdata)
handles=guidata(gcf);
str=get(hObject,'String');
j=handles.Bathymetry.ActiveDataset;
handles.Bathymetry.Dataset(j).VerticalCoordinateSystem.Level=str2double(str);
guidata(gcf,handles);

%%
function PushSave_Callback(hObject,eventdata)
handles=guidata(gcf);
j=handles.Bathymetry.ActiveDataset;
fname=handles.Bathymetry.Dataset(j).FileName;
fname=[fname(1:end-4) '.mat'];
[filename, pathname, filterindex] = uiputfile('*.mat', 'Select Output File',fname);
if pathname~=0
    curdir=[lower(cd) '\'];
    if ~strcmpi(curdir,pathname)
        filename=[pathname filename];
    end
    handles.Bathymetry.Dataset(j).FileName=filename;
    data.Comments=handles.Bathymetry.Dataset(j).Comments;
    data.Type=handles.Bathymetry.Dataset(j).Type;
    data.HorizontalCoordinateSystem.Name=handles.Bathymetry.Dataset(j).HorizontalCoordinateSystem.Name;
    data.HorizontalCoordinateSystem.Type=handles.Bathymetry.Dataset(j).HorizontalCoordinateSystem.Type;
    data.VerticalCoordinateSystem.Name=handles.Bathymetry.Dataset(j).VerticalCoordinateSystem.Name;
    data.VerticalCoordinateSystem.Level=handles.Bathymetry.Dataset(j).VerticalCoordinateSystem.Level;
    data.x=handles.Bathymetry.Dataset(j).x;
    data.y=handles.Bathymetry.Dataset(j).y;
    data.z=handles.Bathymetry.Dataset(j).z;
    save(filename,'-struct','data','Comments','Type','HorizontalCoordinateSystem','VerticalCoordinateSystem','x','y','z');
end
guidata(gcf,handles);

%%
function PushView_Callback(hObject,eventdata)
%     MakeNewWindow(filename,[800 600],'modal');
%     if mtx
%         [x,y]=meshgrid(handles.Bathymetry.Dataset(ii).x,handles.Bathymetry.Dataset(ii).y);
%         z=-handles.Bathymetry.Dataset(ii).z;
%         surf(x,y,z);view(2);shading flat;axis equal;colorbar;
%     else
%         x=handles.Bathymetry.Dataset(ii).x;
%         y=handles.Bathymetry.Dataset(ii).y;
%         z=handles.Bathymetry.Dataset(ii).z;
%         scatter(x,y,5,-z);view(2);axis equal;colorbar;
%     end

%%
function PushOK_Callback(hObject,eventdata)
handles=getHandles;
h=guidata(gcf);
handles.Bathymetry=h.Bathymetry;
setHandles(handles);
closereq;

%%
function PushCancel_Callback(hObject,eventdata)
closereq;

%%
function RefreshAll(handles)

ii=handles.Bathymetry.ActiveDataset;

tp=handles.Bathymetry.Dataset(ii).HorizontalCoordinateSystem.Type;
cs=handles.Bathymetry.Dataset(ii).HorizontalCoordinateSystem.Name;

if strcmpi(tp,'Cartesian')
    set(handles.SelectCS,'String',handles.StrProj);
    ii=strmatch(cs,handles.StrProj,'exact');
    set(handles.ToggleProjected,'Value',1);
    set(handles.ToggleGeographic,'Value',0);
else
    set(handles.SelectCS,'String',handles.StrGeo);
    ii=strmatch(cs,handles.StrGeo,'exact');
    set(handles.ToggleProjected,'Value',0);
    set(handles.ToggleGeographic,'Value',1);
end
if ~isempty(ii)
    set(handles.SelectCS,'Value',ii);
else
    set(handles.SelectCS,'Value',1);
end

a=findobj(gcf,'type','axes');
delete(a);

