function ddb_bathymetryExport
%DDB_SHORELINEEXPORT  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = ddb_shorelineExport(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   ddb_shorelineExport
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

% $Id: ddb_shorelineExport.m 5560 2011-12-02 11:26:29Z boer_we $
% $Date: 2011-12-02 19:26:29 +0800 (Fri, 02 Dec 2011) $
% $Author: boer_we $
% $Revision: 5560 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/Shoreline/ddb_shorelineExport.m $
% $Keywords: $

%%
ddb_refreshScreen('Toolbox','Export');

handles=getHandles;

ddb_plotShoreline(handles,'activate');

handles.Toolbox(tb).activeZoomLevel=1;

handles.ListDatasets    = uicontrol(gcf,'Style','listbox','String','Export',         'Position',[40 80 200 70],'BackgroundColor',[1 1 1],'Tag','UIControl');
handles.SelectZoomLevel = uicontrol(gcf,'Style','popupmenu', 'String','Zoom Levels',    'Position',[40  50 200 20],'BackgroundColor',[1 1 1],'Tag','UIControl');
handles.TextCellSize    = uicontrol(gcf,'Style','text', 'String','Cell Size : ',    'Position',[40  25 200 20],'HorizontalAlignment','left','Tag','UIControl');

handles.PushDrawPolygon   = uicontrol(gcf,'Style','pushbutton','String','Draw Polygon',   'Position',[260 130 100 20],'Tag','UIControl');
handles.PushDeletePolygon = uicontrol(gcf,'Style','pushbutton','String','Delete Polygon', 'Position',[260 105 100 20],'Tag','UIControl');

handles.PushExport        = uicontrol(gcf,'Style','pushbutton','String','Export',         'Position',[260 50 100 20],'Tag','UIControl');

set(handles.ListDatasets,'Value',1);
set(handles.ListDatasets,'String',handles.bathymetry.datasets);

set(handles.PushDrawPolygon,   'CallBack',{@PushDrawPolygon_Callback});
set(handles.PushDeletePolygon, 'CallBack',{@PushDeletePolygon_Callback});
set(handles.ListDatasets,      'CallBack',{@ListDatasets_Callback});
set(handles.SelectZoomLevel,   'CallBack',{@SelectZoomLevel_Callback});
set(handles.PushExport,        'CallBack',{@PushExport_Callback});

RefreshAll(handles);

SetUIBackgroundColors;

setHandles(handles);

%%
function ListDatasets_Callback(hObject,eventdata)
handles=getHandles;

handles.Toolbox(tb).activeDataset=get(hObject,'Value');
handles.Toolbox(tb).activeZoomLevel=1;
RefreshAll(handles);
setHandles(handles);

%%
function SelectZoomLevel_Callback(hObject,eventdata)
handles=getHandles;
handles.Toolbox(tb).activeZoomLevel=get(hObject,'Value');
RefreshAll(handles);
setHandles(handles);

%%
function PushExport_Callback(hObject,eventdata)

[filename, pathname, filterindex] = uiputfile('*.xyz', 'Select Samples File','');

handles=getHandles;

if pathname~=0
    
    if handles.bathymetry.dataset(handles.Toolbox(tb).activeDataset).isAvailable
        
        wb = waitbox('Exporting samples ...');pause(0.1);
        
        cs.name=handles.bathymetry.dataset(handles.Toolbox(tb).activeDataset).horizontalCoordinateSystem.name;
        cs.type=handles.bathymetry.dataset(handles.Toolbox(tb).activeDataset).horizontalCoordinateSystem.type;
        
        [xx,yy]=ddb_coordConvert(handles.Toolbox(tb).polygonX,handles.Toolbox(tb).polygonY,handles.screenParameters.coordinateSystem,cs);
        
        ii=handles.Toolbox(tb).activeDataset;
        str=handles.bathymetry.datasets;
        bset=str{ii};
        
        xlim(1)=min(xx);
        xlim(2)=max(xx);
        ylim(1)=min(yy);
        ylim(2)=max(yy);
        
        fname=[pathname filename];
        handles.originalBackgroundBathymetry=handles.screenParameters.backgroundBathymetry;
        handles.backgroundBathymetry=bset;
        
        zoomlevel=get(handles.SelectZoomLevel,'Value');
        
        [x,y,z,ok]=ddb_getBathy(handles,xlim,ylim,zoomlevel);
        
        [x,y]=ddb_coordConvert(x,y,cs,handles.screenParameters.coordinateSystem);
        
        handles.screenParameters.backgroundBathymetry=handles.originalBackgroundBathymetry;
        
        np=size(x,1)*size(x,2);
        
        x=reshape(x,[np,1]);
        y=reshape(y,[np,1]);
        z=reshape(z,[np,1]);
        
        in = inpolygon(x,y,handles.Toolbox(tb).polygonX,handles.Toolbox(tb).polygonY);
        
        x=x(in);
        y=y(in);
        z=z(in);
        isn=isnan(z);
        
        %     if min(isn)==0
        x=x(~isn);
        y=y(~isn);
        z=z(~isn);
        %     end
        
        data(:,1)=x;
        data(:,2)=y;
        data(:,3)=z;
        
        save(fname,'data','-ascii');
        
        close(wb);
        
        setHandles(handles);
        
    end
end

%%
function PushDrawPolygon_Callback(hObject,eventdata)

handles=getHandles;
ddb_zoomOff;
h=findobj(gcf,'Tag','BathymetryPolygon');

if ~isempty(h)
    delete(h);
end

UIPolyline(gca,'draw','Tag','BathymetryPolygon','Marker','o','Callback',@changePolygon,'closed',1);

setHandles(handles);

%%
function PushDeletePolygon_Callback(hObject,eventdata)

handles=getHandles;

handles.Toolbox(tb).polygonX=[];
handles.Toolbox(tb).polygonY=[];

h=findobj(gcf,'Tag','BathymetryPolygon');
if ~isempty(h)
    delete(h);
end

setHandles(handles);

%%
function changePolygon(x,y,varargin)
handles=getHandles;
handles.Toolbox(tb).polygonX=x;
handles.Toolbox(tb).polygonY=y;
setHandles(handles);

%%
function RefreshAll(handles)
ii=handles.Toolbox(tb).activeDataset;
jj=handles.Toolbox(tb).activeZoomLevel;
set(handles.ListDatasets,'Value',ii);
%if isempty(handles.Toolbox(tb).dataset(ii).refinementFactor)
nz=handles.bathymetry.dataset(ii).nrZoomLevels;
%else
%   nz
for i=1:nz
    zstr{i}=['Zoom Level ' num2str(i)];
end
set(handles.SelectZoomLevel,'Value',jj);
set(handles.SelectZoomLevel,'String',zstr);

if isempty(handles.bathymetry.dataset(ii).refinementFactor)
    
    %     dg=handles.bathymetry.dataset(ii).zoomLevel(jj).GridCellSize(1);
    %     mn=handles.bathymetry.dataset(ii).zoomLevel(jj).GridCellSize(2);
    %     sc=handles.bathymetry.dataset(ii).zoomLevel(jj).GridCellSize(3);
    
    cellSize=handles.bathymetry.dataset(ii).zoomLevel(jj).dx;
    %     cellSize=dms2degrees([dg mn sc]);
    if strcmpi(handles.bathymetry.dataset(ii).horizontalCoordinateSystem.type,'Geographic')
        cellSize=cellSize*100000;
    end
    
    str=['Cell Size : ~ ' num2str(cellSize,'%10.0f') ' m'];
    %    str=['Cell Size : ' num2str(dg) 'd ' num2str(mn) 'm ' num2str(sc) 's'];
    set(handles.TextCellSize,'String',str);
else
    
    %     tileMax=handles.bathymetry.dataset(ii).MaxTileSize;
    %     nLevels=handles.bathymetry.dataset(ii).nrZoomLevels;
    %     nRef=handles.bathymetry.dataset(ii).refinementFactor;
    %     nCell=handles.bathymetry.dataset(ii).nrCells;
    %
    %     tileSizes(1)=tileMax;
    %     for i=2:nLevels
    %         tileSizes(i)=tileSizes(i-1)/nRef;
    %     end
    %     cellSizes=tileSizes/nCell;
    %     cellSize=cellSizes(jj);
    
    
    cellSizeX=handles.bathymetry.dataset(ii).zoomLevel(jj).dx;
    cellSizeY=handles.bathymetry.dataset(ii).zoomLevel(jj).dy;
    
    %     ym=mean(handles.Toolbox(tb).polygonY);
    if strcmpi(handles.bathymetry.dataset(ii).horizontalCoordinateSystem.type,'geographic')
        cellSize=0.5*(cellSizeX+cellSizeY)*100000;
    else
        cellSize=0.5*(cellSizeX+cellSizeY);
    end
    
    str=['Cell Size : ~ ' num2str(cellSize,'%10.0f') ' m'];
    set(handles.TextCellSize,'String',str);
    
end


