function ddb_TilingBathymetry
%DDB_TILINGBATHYMETRY  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_TilingBathymetry
%
%   Input:

%
%
%
%
%   Example
%   ddb_TilingBathymetry
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

% $Id: ddb_TilingBathymetry.m 5560 2011-12-02 11:26:29Z boer_we $
% $Date: 2011-12-02 19:26:29 +0800 (Fri, 02 Dec 2011) $
% $Author: boer_we $
% $Revision: 5560 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/Tiling/ddb_TilingBathymetry.m $
% $Keywords: $

%%
ddb_refreshScreen('Toolbox','Bathymetry');

handles=getHandles;

ddb_plotTiling(handles,'activate');

handles.GUIHandles.pushSelectFile = uicontrol(gcf,'Style','pushbutton','String','Select ArcInfo File','Position',   [60 120 100  20],'Tag','UIControl');
handles.GUIHandles.textFile=uicontrol(gcf,'Style','text','String',['File : ' handles.Toolbox(tb).Bathymetry.fileName], 'Position',  [170 116 750  20],'HorizontalAlignment','left','Tag','UIControl');

handles.GUIHandles.editX0=uicontrol(gcf,'Style','edit','String',num2str(handles.Toolbox(tb).Bathymetry.x0), 'Position',  [135 90 50  20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.editY0=uicontrol(gcf,'Style','edit','String',num2str(handles.Toolbox(tb).Bathymetry.y0), 'Position',  [245 90 50  20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.editNX=uicontrol(gcf,'Style','edit','String',num2str(handles.Toolbox(tb).Bathymetry.nx), 'Position',  [135 65 50  20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.editNY=uicontrol(gcf,'Style','edit','String',num2str(handles.Toolbox(tb).Bathymetry.ny), 'Position',  [245 65 50  20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.editNrZoom=uicontrol(gcf,'Style','edit','String',num2str(handles.Toolbox(tb).Bathymetry.nrZoom), 'Position',  [135 40 50  20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');

handles.GUIHandles.textX0=uicontrol(gcf,'Style','text','String','X Origin', 'Position',         [ 60 86 70  20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.textY0=uicontrol(gcf,'Style','text','String','Y Origin', 'Position',         [190 86 50  20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.textNX=uicontrol(gcf,'Style','text','String','Nr Cells X', 'Position',       [ 60 61 70  20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.textNY=uicontrol(gcf,'Style','text','String','Nr Cells Y', 'Position',       [190 61 50  20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.textNrZoom=uicontrol(gcf,'Style','text','String','Zoom Levels', 'Position',  [ 60 36 70  20],'HorizontalAlignment','left','Tag','UIControl');

handles.GUIHandles.editDataName=uicontrol(gcf,'Style','edit','String',handles.Toolbox(tb).Bathymetry.dataName, 'Position',  [350 90 100  20],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.editDataDir =uicontrol(gcf,'Style','edit','String',handles.Toolbox(tb).Bathymetry.dataDir,  'Position',  [350 65 300  20],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.textDataName=uicontrol(gcf,'Style','text','String','Name',   'Position',         [310 86 40  20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.textDataDir =uicontrol(gcf,'Style','text','String','Folder', 'Position',         [310 61 40  20],'HorizontalAlignment','left','Tag','UIControl');

handles.GUIHandles.radioGeo          = uicontrol(gcf,'Style','radiobutton','String','Geographic', 'Position',  [245 30 80  20],'Enable','off','Tag','UIControl');
handles.GUIHandles.radioProj         = uicontrol(gcf,'Style','radiobutton','String','Projected',  'Position',  [325 30 80  20],'Enable','off','Tag','UIControl');

switch lower(handles.Toolbox(tb).Bathymetry.EPSGtype)
    case{'geo','geographic','geographic 2d','geographic 3d','latlon','lonlat','spherical'}
        set(handles.GUIHandles.radioGeo, 'Value',1);
        set(handles.GUIHandles.radioProj,'Value',0);
    case{'xy','proj','projected','projection','cart','cartesian'}
        set(handles.GUIHandles.radioGeo, 'Value',0);
        set(handles.GUIHandles.radioProj,'Value',1);
end

handles.GUIHandles.textCoordName     = uicontrol(gcf,'Style','text','String',handles.Toolbox(tb).Bathymetry.EPSGname,  'Position',  [410 26 200  20],'HorizontalAlignment','left','Tag','UIControl');

handles.GUIHandles.selectType        = uicontrol(gcf,'Style','popupmenu','String',{'int','single','double'},  'Position',  [750 80 60  20],'BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.textType          = uicontrol(gcf,'Style','text','String','Type','Position',  [665 76 80  20],'HorizontalAlignment','right','Tag','UIControl');
switch lower(handles.Toolbox(tb).Bathymetry.type)
    case{'int32','int','integer'}
        ii=1;
    case{'single','float'}
        ii=2;
    case{'double'}
        ii=3;
end
set(handles.GUIHandles.selectType,'Value',ii);

handles.GUIHandles.editVerticalCS    = uicontrol(gcf,'Style','edit','String',handles.Toolbox(tb).Bathymetry.VertCoordName,'Position',  [750 55 60  20],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.editVerticalLev   = uicontrol(gcf,'Style','edit','String',num2str(handles.Toolbox(tb).Bathymetry.VertCoordLevel,'%10.2f'),'Position',  [750 30 60  20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.textVerticalCS    = uicontrol(gcf,'Style','text','String','Ref Level','Position',  [665 51 80  20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.textVerticalLev   = uicontrol(gcf,'Style','text','String','Dif with MSL','Position',  [665 26 80  20],'HorizontalAlignment','right','Tag','UIControl');

handles.GUIHandles.pushSelectCS      = uicontrol(gcf,'Style','pushbutton','String','Coordinate System','Position',   [830 80 120  20],'Tag','UIControl');
handles.GUIHandles.pushEditAttributes = uicontrol(gcf,'Style','pushbutton','String','Edit Attributes','Position',   [830 55 120  20],'Tag','UIControl');
handles.GUIHandles.pushGenerateTiles = uicontrol(gcf,'Style','pushbutton','String','Generate Tiles','Position',   [830 30 120  20],'Tag','UIControl');

set(handles.GUIHandles.editNX,'Callback',{@editNX_Callback});
set(handles.GUIHandles.editNY,'Callback',{@editNY_Callback});
set(handles.GUIHandles.editX0,'Callback',{@editX0_Callback});
set(handles.GUIHandles.editY0,'Callback',{@editY0_Callback});
set(handles.GUIHandles.editNrZoom,'Callback',{@editNrZoom_Callback});

set(handles.GUIHandles.editDataName,'Callback',{@editDataName_Callback});
set(handles.GUIHandles.editDataDir,'Callback',{@editDataDir_Callback});

set(handles.GUIHandles.selectType,'Callback',{@selectType_Callback});
set(handles.GUIHandles.editVerticalCS,'Callback',{@editVerticalCS_Callback});
set(handles.GUIHandles.editVerticalLev,'Callback',{@editVerticalLev_Callback});

set(handles.GUIHandles.pushSelectFile,'Callback',{@pushSelectFile_Callback});
set(handles.GUIHandles.pushGenerateTiles,'Callback',{@pushGenerateTiles_Callback});
set(handles.GUIHandles.pushEditAttributes,'Callback',{@pushEditAttributes_Callback});
set(handles.GUIHandles.pushSelectCS,'Callback',{@pushSelectCS_Callback});

SetUIBackgroundColors;

setHandles(handles);

%%
function pushSelectFile_Callback(hObject,eventdata)
handles=getHandles;
[filename, pathname, filterindex] = uigetfile('*.*', 'Select ArcInfo Bathymetry File');
if ~pathname==0
    handles.Toolbox(tb).Bathymetry.fileName=[pathname filename];
    [ncols,nrows,x0,y0,cellsz]=readArcInfo([pathname filename],'info');
    
    handles.Toolbox(tb).Bathymetry.x0=x0;
    handles.Toolbox(tb).Bathymetry.y0=y0;
    
    set(handles.GUIHandles.editX0,'String',num2str(x0));
    set(handles.GUIHandles.editY0,'String',num2str(y0));
    
    if ncols>500 && nrows>500
        handles.Toolbox(tb).Bathymetry.nx=300;
        handles.Toolbox(tb).Bathymetry.ny=300;
        zm=1:50;
        nnx=ncols./(handles.Toolbox(tb).Bathymetry.nx.*2.^(zm-1));
        nny=nrows./(handles.Toolbox(tb).Bathymetry.ny.*2.^(zm-1));
        iix=find(nnx>1,1,'last');
        iiy=find(nny>1,1,'last');
        handles.Toolbox(tb).Bathymetry.nrZoom=max(iix,iiy);
    else
        handles.Toolbox(tb).Bathymetry.nx=ncols;
        handles.Toolbox(tb).Bathymetry.ny=nrows;
        handles.Toolbox(tb).Bathymetry.nrZoom=1;
    end
    
    set(handles.GUIHandles.editNX,'String',num2str(handles.Toolbox(tb).Bathymetry.nx));
    set(handles.GUIHandles.editNY,'String',num2str(handles.Toolbox(tb).Bathymetry.ny));
    set(handles.GUIHandles.editNrZoom,'String',num2str(handles.Toolbox(tb).Bathymetry.nrZoom));
    set(handles.GUIHandles.textFile,'String',['File : ' pathname filename]);
end
setHandles(handles);

%%
function pushGenerateTiles_Callback(hObject,eventdata)
handles=getHandles;

OPT.EPSGcode                     = handles.Toolbox(tb).Bathymetry.EPSGcode;
OPT.EPSGname                     = handles.Toolbox(tb).Bathymetry.EPSGname;
OPT.EPSGtype                     = handles.Toolbox(tb).Bathymetry.EPSGtype;
OPT.VertCoordName                = handles.Toolbox(tb).Bathymetry.VertCoordName;
OPT.VertCoordLevel               = handles.Toolbox(tb).Bathymetry.VertCoordLevel;
OPT.nc_library                   = handles.Toolbox(tb).Bathymetry.nc_library;
OPT.tp                           = handles.Toolbox(tb).Bathymetry.type;

f=fieldnames(handles.Toolbox(tb).Bathymetry.Attributes);

for i=1:length(f);
    OPT.(f{i})=handles.Toolbox(tb).Bathymetry.Attributes.(f{i});
end

fname=handles.Toolbox(tb).Bathymetry.fileName;
dr=[handles.Toolbox(tb).Bathymetry.dataDir filesep handles.Toolbox(tb).Bathymetry.dataName filesep];
dataname=handles.Toolbox(tb).Bathymetry.dataName;
nrzoom=handles.Toolbox(tb).Bathymetry.nrZoom;
nx=handles.Toolbox(tb).Bathymetry.nx;
ny=handles.Toolbox(tb).Bathymetry.ny;

wb = waitbox('Generating Tiles ...');
makeNCBathyTiles(fname,dr,dataname,nrzoom,nx,ny,OPT);
close(wb);

%%
function editX0_Callback(hObject,eventdata)
handles=getHandles;
handles.Toolbox(tb).Bathymetry.x0=str2double(get(hObject,'String'));
setHandles(handles);

%%
function editY0_Callback(hObject,eventdata)
handles=getHandles;
handles.Toolbox(tb).Bathymetry.y0=str2double(get(hObject,'String'));
setHandles(handles);

%%
function editNX_Callback(hObject,eventdata)
handles=getHandles;
handles.Toolbox(tb).Bathymetry.nx=str2double(get(hObject,'String'));
setHandles(handles);

%%
function editNY_Callback(hObject,eventdata)
handles=getHandles;
handles.Toolbox(tb).Bathymetry.ny=str2double(get(hObject,'String'));
setHandles(handles);

%%
function editNrZoom_Callback(hObject,eventdata)
handles=getHandles;
handles.Toolbox(tb).Bathymetry.nrZoom=str2double(get(hObject,'String'));
setHandles(handles);

%%
function editDataName_Callback(hObject,eventdata)
handles=getHandles;
handles.Toolbox(tb).Bathymetry.dataName=get(hObject,'String');
setHandles(handles);

%%
function editDataDir_Callback(hObject,eventdata)
handles=getHandles;
handles.Toolbox(tb).Bathymetry.dataDir=get(hObject,'String');
setHandles(handles);

%%
function pushEditAttributes_Callback(hObject,eventdata)
handles=getHandles;
attr=handles.Toolbox(tb).Bathymetry.Attributes;
attr=ddb_editTilingAttributes(attr);
handles.Toolbox(tb).Bathymetry.Attributes=attr;
setHandles(handles);

%%
function selectType_Callback(hObject,eventdata)
handles=getHandles;
ii=get(hObject,'Value');
switch ii
    case 1
        handles.Toolbox(tb).Bathymetry.type='int';
    case 2
        handles.Toolbox(tb).Bathymetry.type='float';
    case 3
        handles.Toolbox(tb).Bathymetry.type='double';
end
setHandles(handles);

%%
function editVerticalCS_Callback(hObject,eventdata)
handles=getHandles;
handles.Toolbox(tb).Bathymetry.VertCoordName=get(hObject,'String');
setHandles(handles);

%%
function editVerticalLev_Callback(hObject,eventdata)
handles=getHandles;
handles.Toolbox(tb).Bathymetry.VertCoordLevel=str2double(get(hObject,'String'));
setHandles(handles);

%%
function pushSelectCS_Callback(hObject,eventdata)
handles=getHandles;
[cs,type,nr,ok]=ddb_selectCoordinateSystem(handles.CoordinateData,handles.EPSG,'default',handles.Toolbox(tb).Bathymetry.EPSGname,'type','both','defaulttype',handles.Toolbox(tb).Bathymetry.EPSGtype);
if ok
    handles.Toolbox(tb).Bathymetry.EPSGname=cs;
    handles.Toolbox(tb).Bathymetry.EPSGtype=type;
    handles.Toolbox(tb).Bathymetry.EPSGcode=nr;
    set(handles.GUIHandles.textCoordName,'String',cs);
    if strcmpi(type,'geographic')
        set(handles.GUIHandles.radioGeo, 'Value',1);
        set(handles.GUIHandles.radioProj,'Value',0);
    else
        set(handles.GUIHandles.radioGeo, 'Value',0);
        set(handles.GUIHandles.radioProj,'Value',1);
    end
    setHandles(handles);
end

