function ddb_DrawingToolbox(varargin)
%ddb_DrawingToolbox  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_DrawingToolbox(varargin)
%
%   Input:
%   varargin =
%
%
%
%
%   Example
%   ddb_DrawingToolbox
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2017 Deltares
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

% $Id: ddb_drawingToolbox_export.m 12926 2016-10-15 07:47:58Z ormondt $
% $Date: 2016-10-15 09:47:58 +0200 (Sat, 15 Oct 2016) $
% $Author: ormondt $
% $Revision: 12926 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/drawing/ddb_drawingToolbox_export.m $
% $Keywords: $

%%
if isempty(varargin)
    % New tab selected
    ddb_zoomOff;
    ddb_refreshScreen;
    ddb_plotDrawing('activate');
else
    %Options selected
    opt=lower(varargin{1});
    switch opt
        case{'selectpolyline'}
            selectPolyline;
        case{'drawpolyline'}
            drawPolyline;
        case{'deletepolyline'}
            deletePolyline;
        case{'loadpolyline'}
            loadPolyline;
        case{'savepolyline'}
            savePolyline;
        case{'selectpolygon'}
            selectPolygon;
        case{'drawpolygon'}
            drawPolygon;
        case{'deletepolygon'}
            deletePolygon;
        case{'loadpolygon'}
            loadPolygon;
        case{'savepolygon'}
            savePolygon;
        case{'selectspline'}
            selectSpline;
        case{'drawspline'}
            drawSpline;
        case{'deletespline'}
            deleteSpline;
        case{'loadspline'}
            loadSpline;
        case{'savespline'}
            saveSpline;
    end
end

%%
function selectPolyline
handles=getHandles;
setHandles(handles);


%%
function drawPolyline

handles=getHandles;
ddb_zoomOff;

handles.toolbox.drawing.polylinehandle=gui_polyline('draw','tag','drawingpolyline','marker','o', ...
    'createcallback',@createPolyline,'changecallback',@changePolyline, ...
    'closed',0);

setHandles(handles);

%%
function createPolyline(h,x,y)
handles=getHandles;
handles.toolbox.drawing.nrpolylines=handles.toolbox.drawing.nrpolylines+1;
iac=handles.toolbox.drawing.nrpolylines;
handles.toolbox.drawing.polyline(iac).handle=h;
handles.toolbox.drawing.polyline(iac).x=x;
handles.toolbox.drawing.polyline(iac).y=y;
handles.toolbox.drawing.polyline(iac).length=length(x);
handles.toolbox.drawing.polylinenames{iac}=['polyline_' num2str(iac,'%0.3i')];
handles.toolbox.drawing.activepolyline=iac;
setHandles(handles);
gui_updateActiveTab;

%%
function deletePolyline

handles=getHandles;

iac=handles.toolbox.drawing.activepolyline;
if handles.toolbox.drawing.nrpolylines>0
    h=handles.toolbox.drawing.polyline(iac).handle;
    if ~isempty(h)
        delete(h);
    end
end

handles.toolbox.drawing.polyline=removeFromStruc(handles.toolbox.drawing.polyline,iac);
handles.toolbox.drawing.polylinenames=removeFromCellArray(handles.toolbox.drawing.polylinenames,iac);

handles.toolbox.drawing.nrpolylines=max(handles.toolbox.drawing.nrpolylines-1,0);
handles.toolbox.drawing.activepolyline=min(handles.toolbox.drawing.activepolyline,handles.toolbox.drawing.nrpolylines);

if handles.toolbox.drawing.nrpolylines==0
    handles.toolbox.drawing.polyline=[];
    handles.toolbox.drawing.polyline(1).x=[];
    handles.toolbox.drawing.polyline(1).y=[];
    handles.toolbox.drawing.polyline(1).length=0;
    handles.toolbox.drawing.polyline(1).handle=[];
    handles.toolbox.drawing.nrpolylines=0;
    handles.toolbox.drawing.polylinenames={''};
    handles.toolbox.drawing.activepolyline=1;
end

setHandles(handles);

%%
function changePolyline(h,x,y,varargin)
handles=getHandles;
for ip=1:handles.toolbox.drawing.nrpolylines
    if handles.toolbox.drawing.polyline(ip).handle==h
        iac=ip;
        break
    end
end

handles.toolbox.drawing.polyline(iac).x=x;
handles.toolbox.drawing.polyline(iac).y=y;
handles.toolbox.drawing.polyline(iac).length=length(x);
handles.toolbox.drawing.activepolyline=iac;
setHandles(handles);
gui_updateActiveTab;

%%
function loadPolyline

handles=getHandles;

% Clear all
handles.toolbox.drawing.polyline=[];
handles.toolbox.drawing.polyline(1).x=[];
handles.toolbox.drawing.polyline(1).y=[];
handles.toolbox.drawing.polyline(1).length=0;
handles.toolbox.drawing.polyline(1).handle=[];
handles.toolbox.drawing.nrpolylines=0;
handles.toolbox.drawing.polylinenames={''};

h=findobj(gca,'Tag','drawingpolyline');
delete(h);

data=tekal('read',handles.toolbox.drawing.polylinefile,'loaddata');
handles.toolbox.drawing.nrpolylines=length(data.Field);
handles.toolbox.drawing.activepolyline=1;
for ip=1:handles.toolbox.drawing.nrpolylines
    x=data.Field(ip).Data(:,1);
    y=data.Field(ip).Data(:,2);
    handles.toolbox.drawing.polyline(ip).x=x;
    handles.toolbox.drawing.polyline(ip).y=y;
    handles.toolbox.drawing.polyline(ip).length=length(x);
    handles.toolbox.drawing.polylinenames{ip}=deblank2(data.Field(ip).Name);
    h=gui_polyline('plot','x',x,'y',y,'tag','drawingpolyline','marker','o', ...
        'changecallback',@changePolyline);
    handles.toolbox.drawing.polyline(ip).handle=h;
end

setHandles(handles);

%%
function savePolyline
handles=getHandles;

cs=handles.screenParameters.coordinateSystem.type;
if strcmpi(cs,'geographic')
    fmt='%12.7f %12.7f\n';
else
    fmt='%11.1f %11.1f\n';
end

fid=fopen(handles.toolbox.drawing.polylinefile,'wt');
for ip=1:handles.toolbox.drawing.nrpolylines
    fprintf(fid,'%s\n',handles.toolbox.drawing.polylinenames{ip});
    fprintf(fid,'%i %i\n',[handles.toolbox.drawing.polyline(ip).length 2]);
    for ix=1:handles.toolbox.drawing.polyline(ip).length
        fprintf(fid,fmt,[handles.toolbox.drawing.polyline(ip).x(ix) handles.toolbox.drawing.polyline(ip).y(ix)]);
    end
end
fclose(fid);


%%
function selectPolygon
handles=getHandles;
setHandles(handles);


%%
function drawPolygon

handles=getHandles;
ddb_zoomOff;

handles.toolbox.drawing.polygonhandle=gui_polyline('draw','tag','drawingpolygon','marker','o', ...
    'createcallback',@createPolygon,'changecallback',@changePolygon, ...
    'closed',1);

setHandles(handles);

%%
function createPolygon(h,x,y)
handles=getHandles;
handles.toolbox.drawing.nrpolygons=handles.toolbox.drawing.nrpolygons+1;
iac=handles.toolbox.drawing.nrpolygons;
handles.toolbox.drawing.polygon(iac).handle=h;
handles.toolbox.drawing.polygon(iac).x=x;
handles.toolbox.drawing.polygon(iac).y=y;
handles.toolbox.drawing.polygon(iac).length=length(x);
handles.toolbox.drawing.polygonnames{iac}=['polygon_' num2str(iac,'%0.3i')];
handles.toolbox.drawing.activepolygon=iac;
setHandles(handles);
gui_updateActiveTab;

%%
function deletePolygon

handles=getHandles;

iac=handles.toolbox.drawing.activepolygon;
if handles.toolbox.drawing.nrpolygons>0
    h=handles.toolbox.drawing.polygon(iac).handle;
    if ~isempty(h)
        delete(h);
    end
end

handles.toolbox.drawing.polygon=removeFromStruc(handles.toolbox.drawing.polygon,iac);
handles.toolbox.drawing.polygonnames=removeFromCellArray(handles.toolbox.drawing.polygonnames,iac);

handles.toolbox.drawing.nrpolygons=max(handles.toolbox.drawing.nrpolygons-1,0);
handles.toolbox.drawing.activepolygon=min(handles.toolbox.drawing.activepolygon,handles.toolbox.drawing.nrpolygons);

if handles.toolbox.drawing.nrpolygons==0
    handles.toolbox.drawing.polygon=[];
    handles.toolbox.drawing.polygon(1).x=[];
    handles.toolbox.drawing.polygon(1).y=[];
    handles.toolbox.drawing.polygon(1).length=0;
    handles.toolbox.drawing.polygon(1).handle=[];
    handles.toolbox.drawing.nrpolygons=0;
    handles.toolbox.drawing.polygonnames={''};
    handles.toolbox.drawing.activepolygon=1;
end

setHandles(handles);

%%
function changePolygon(h,x,y,varargin)
handles=getHandles;
for ip=1:handles.toolbox.drawing.nrpolygons
    if handles.toolbox.drawing.polygon(ip).handle==h
        iac=ip;
        break
    end
end

handles.toolbox.drawing.polygon(iac).x=x;
handles.toolbox.drawing.polygon(iac).y=y;
handles.toolbox.drawing.polygon(iac).length=length(x);
handles.toolbox.drawing.activepolygon=iac;
setHandles(handles);
gui_updateActiveTab;

%%
function loadPolygon

handles=getHandles;

% Clear all
handles.toolbox.drawing.polygon=[];
handles.toolbox.drawing.polygon(1).x=[];
handles.toolbox.drawing.polygon(1).y=[];
handles.toolbox.drawing.polygon(1).length=0;
handles.toolbox.drawing.polygon(1).handle=[];
handles.toolbox.drawing.nrpolygons=0;
handles.toolbox.drawing.polygonnames={''};

h=findobj(gca,'Tag','drawingpolygon');
delete(h);

data=tekal('read',handles.toolbox.drawing.polygonfile,'loaddata');
handles.toolbox.drawing.nrpolygons=length(data.Field);
handles.toolbox.drawing.activepolygon=1;
for ip=1:handles.toolbox.drawing.nrpolygons
    x=data.Field(ip).Data(:,1);
    y=data.Field(ip).Data(:,2);
    if x(end)~=x(1) || y(end)~=y(1)
        x=[x;x(1)];
        y=[y;y(1)];
    end
    handles.toolbox.drawing.polygon(ip).x=x;
    handles.toolbox.drawing.polygon(ip).y=y;
    handles.toolbox.drawing.polygon(ip).length=length(x);
    handles.toolbox.drawing.polygonnames{ip}=deblank2(data.Field(ip).Name);
    h=gui_polyline('plot','x',x,'y',y,'tag','drawingpolygon','marker','o', ...
        'changecallback',@changePolygon);
    handles.toolbox.drawing.polygon(ip).handle=h;
end

setHandles(handles);

%%
function savePolygon

handles=getHandles;

cs=handles.screenParameters.coordinateSystem.type;
if strcmpi(cs,'geographic')
    fmt='%12.7f %12.7f\n';
else
    fmt='%11.1f %11.1f\n';
end

fid=fopen(handles.toolbox.drawing.polygonfile,'wt');
for ip=1:handles.toolbox.drawing.nrpolygons
    fprintf(fid,'%s\n',handles.toolbox.drawing.polygonnames{ip});
    fprintf(fid,'%i %i\n',[handles.toolbox.drawing.polygon(ip).length 2]);
    for ix=1:handles.toolbox.drawing.polygon(ip).length
        fprintf(fid,fmt,[handles.toolbox.drawing.polygon(ip).x(ix) handles.toolbox.drawing.polygon(ip).y(ix)]);
    end
end
fclose(fid);


%%
function selectSpline
handles=getHandles;
setHandles(handles);

%%
function drawSpline

handles=getHandles;
ddb_zoomOff;

handles.toolbox.drawing.splinehandle=gui_polyline('draw','tag','drawingspline','marker','o', ...
    'createcallback',@createSpline,'changecallback',@changeSpline, ...
    'type','spline','dxspline',handles.toolbox.drawing.dxspline,'cstype',handles.screenParameters.coordinateSystem.type);

setHandles(handles);

%%
function createSpline(h,x,y)
handles=getHandles;
handles.toolbox.drawing.nrsplines=handles.toolbox.drawing.nrsplines+1;
iac=handles.toolbox.drawing.nrsplines;
handles.toolbox.drawing.spline(iac).handle=h;
handles.toolbox.drawing.spline(iac).x=x;
handles.toolbox.drawing.spline(iac).y=y;
handles.toolbox.drawing.spline(iac).length=length(x);
handles.toolbox.drawing.splinenames{iac}=['spline_' num2str(iac,'%0.3i')];
handles.toolbox.drawing.activespline=iac;
setHandles(handles);
gui_updateActiveTab;

%%
function deleteSpline

handles=getHandles;

iac=handles.toolbox.drawing.activespline;
if handles.toolbox.drawing.nrsplines>0
    h=handles.toolbox.drawing.spline(iac).handle;
    if ~isempty(h)
        delete(h);
    end
end

handles.toolbox.drawing.spline=removeFromStruc(handles.toolbox.drawing.spline,iac);
handles.toolbox.drawing.splinenames=removeFromCellArray(handles.toolbox.drawing.splinenames,iac);

handles.toolbox.drawing.nrsplines=max(handles.toolbox.drawing.nrsplines-1,0);
handles.toolbox.drawing.activespline=min(handles.toolbox.drawing.activespline,handles.toolbox.drawing.nrsplines);

if handles.toolbox.drawing.nrsplines==0
    handles.toolbox.drawing.spline=[];
    handles.toolbox.drawing.spline(1).x=[];
    handles.toolbox.drawing.spline(1).y=[];
    handles.toolbox.drawing.spline(1).length=0;
    handles.toolbox.drawing.spline(1).handle=[];
    handles.toolbox.drawing.nrsplines=0;
    handles.toolbox.drawing.splinenames={''};
    handles.toolbox.drawing.activespline=1;
end

setHandles(handles);

%%
function changeSpline(h,x,y,varargin)
handles=getHandles;
for ip=1:handles.toolbox.drawing.nrsplines
    if handles.toolbox.drawing.spline(ip).handle==h
        iac=ip;
        break
    end
end

handles.toolbox.drawing.spline(iac).x=x;
handles.toolbox.drawing.spline(iac).y=y;
handles.toolbox.drawing.spline(iac).length=length(x);
handles.toolbox.drawing.activespline=iac;
setHandles(handles);
gui_updateActiveTab;

%%
function loadSpline

handles=getHandles;

% Clear all
handles.toolbox.drawing.spline=[];
handles.toolbox.drawing.spline(1).x=[];
handles.toolbox.drawing.spline(1).y=[];
handles.toolbox.drawing.spline(1).length=0;
handles.toolbox.drawing.spline(1).handle=[];
handles.toolbox.drawing.nrsplines=0;
handles.toolbox.drawing.splinenames={''};

h=findobj(gca,'Tag','drawingspline');
delete(h);

data=tekal('read',handles.toolbox.drawing.splinefile,'loaddata');
handles.toolbox.drawing.nrsplines=length(data.Field);
handles.toolbox.drawing.activespline=1;
for ip=1:handles.toolbox.drawing.nrsplines
    x=data.Field(ip).Data(:,1);
    y=data.Field(ip).Data(:,2);
    handles.toolbox.drawing.spline(ip).x=x;
    handles.toolbox.drawing.spline(ip).y=y;
    handles.toolbox.drawing.spline(ip).length=length(x);
    handles.toolbox.drawing.splinenames{ip}=deblank2(data.Field(ip).Name);
    h=gui_polyline('plot','x',x,'y',y,'tag','drawingspline','marker','o', ...
        'changecallback',@changeSpline,'type','spline');
    handles.toolbox.drawing.spline(ip).handle=h;
end

setHandles(handles);

%%
function saveSpline

handles=getHandles;

cs=handles.screenParameters.coordinateSystem.type;
if strcmpi(cs,'geographic')
    fmt='%12.7f %12.7f\n';
else
    fmt='%11.1f %11.1f\n';
end

fid=fopen(handles.toolbox.drawing.splinefile,'wt');
for ip=1:handles.toolbox.drawing.nrsplines
    
    xs=handles.toolbox.drawing.spline(ip).x;
    ys=handles.toolbox.drawing.spline(ip).y;
    
    if handles.toolbox.drawing.dxxspline>0
        [xs,ys]=spline2d(xs,ys,handles.toolbox.drawing.dxxspline,cs);
    end
    
    fprintf(fid,'%s\n',handles.toolbox.drawing.splinenames{ip});
    fprintf(fid,'%i %i\n',[length(xs) 2]);
    for ix=1:length(xs)
        fprintf(fid,fmt,[xs(ix) ys(ix)]);
    end
end
fclose(fid);


