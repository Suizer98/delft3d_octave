function ddb_BathymetryToolbox_fillcache(varargin)
%DDB_BATHYMETRYTOOLBOX_FILLCACHE  DDB Tab for filling the bathymetry cache

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

% $Id: ddb_BathymetryToolbox_fillcache.m 12732 2016-05-12 15:47:18Z nederhof $
% $Date: 2016-05-12 23:47:18 +0800 (Thu, 12 May 2016) $
% $Author: nederhof $
% $Revision: 12732 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/Bathymetry/ddb_BathymetryToolbox_fillcache.m $
% $Keywords: $

%%
if isempty(varargin)
    % New tab selected
    ddb_zoomOff;
    ddb_refreshScreen;
    selectDataset;
    ddb_plotBathymetry('activate');
    h=findobj(gca,'Tag','bathymetrypolygon');
    set(h,'Visible','off');
    h=findobj(gca,'Tag','bathymetryrectangle');
    set(h,'Visible','on');
else
    %Options selected
    opt=lower(varargin{1});
    switch opt
        case{'selectdataset'}
            selectDataset;
        case{'fillcache'}
            fillCache;
        case{'drawrectangle'}
            drawRectangle;
        case{'deleterectangle'}
            deleteRectangle;
    end
end

%%
function selectDataset

handles=getHandles;
handles.toolbox.bathymetry.activeZoomLevel=1;
setHandles(handles);

%%
function fillCache

handles=getHandles;

if handles.bathymetry.dataset(handles.toolbox.bathymetry.activeDataset).isAvailable
    
    cs.name=handles.bathymetry.dataset(handles.toolbox.bathymetry.activeDataset).horizontalCoordinateSystem.name;
    cs.type=handles.bathymetry.dataset(handles.toolbox.bathymetry.activeDataset).horizontalCoordinateSystem.type;
    
    x0=handles.toolbox.bathymetry.rectanglex0;
    y0=handles.toolbox.bathymetry.rectangley0;
    dx=handles.toolbox.bathymetry.rectangledx;
    dy=handles.toolbox.bathymetry.rectangledy;
    
    xx=[x0 x0+dx x0+dx x0];
    yy=[y0 y0 y0+dy y0+dy];
    
    [xx,yy]=ddb_coordConvert(xx,yy,handles.screenParameters.coordinateSystem,cs);
    
    xlim(1)=min(xx);
    xlim(2)=max(xx);
    ylim(1)=min(yy);
    ylim(2)=max(yy);

    ii=handles.toolbox.bathymetry.activeDataset;
    str=handles.bathymetry.datasets;
    bset=str{ii};
    
    [x,y,z,ok]=ddb_getBathymetry(handles.bathymetry,xlim,ylim,'bathymetry',bset,'zoomlevel',-1);
    
end

%%
function drawRectangle

handles=getHandles;
ddb_zoomOff;
h=findobj(gcf,'Tag','bathymetryrectangle');
if ~isempty(h)
    delete(h);
end

handles.toolbox.bathymetry.rectanglex0=[];
handles.toolbox.bathymetry.rectanglex0=[];
handles.toolbox.bathymetry.rectangledx=[];
handles.toolbox.bathymetry.rectangledy=[];

UIRectangle(handles.GUIHandles.mapAxis,'draw','Tag','bathymetryrectangle','Marker','o','MarkerEdgeColor','k', ...
    'MarkerSize',6,'rotate',0,'callback',@changeRectangle, 'number', 1);

setHandles(handles);

function changeRectangle(x0,y0,dx,dy,rotation,h)

handles=getHandles;

handles.toolbox.bathymetry.rectanglehandle=h;

handles.toolbox.bathymetry.rectanglex0=x0;
handles.toolbox.bathymetry.rectangley0=y0;
handles.toolbox.bathymetry.rectangledx=dx;
handles.toolbox.bathymetry.rectangledy=dy;

setHandles(handles);

gui_updateActiveTab;

%%
function deleteRectangle
handles=getHandles;
if ~isempty(handles.toolbox.bathymetry.rectanglehandle)
    try
        delete(handles.toolbox.bathymetry.rectanglehandle);
    end
end
handles.toolbox.bathymetry.rectanglex0=[];
handles.toolbox.bathymetry.rectanglex0=[];
handles.toolbox.bathymetry.rectangledx=[];
handles.toolbox.bathymetry.rectangledy=[];
setHandles(handles);
