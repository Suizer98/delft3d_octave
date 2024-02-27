function ddb_ModelMakerToolbox_Delft3DFLOW_quickMode(varargin)
%DDB_MODELMAKERTOOLBOX_QUICKMODE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_ModelMakerToolbox_quickMode(varargin)
%
%   Input:
%   varargin =
%
%
%
%
%   Example
%   ddb_ModelMakerToolbox_quickMode
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

% $Id: ddb_ModelMakerToolbox_quickMode.m 10436 2014-03-24 22:26:17Z ormondt $
% $Date: 2014-03-24 23:26:17 +0100 (Mon, 24 Mar 2014) $
% $Author: ormondt $
% $Revision: 10436 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/ModelMaker/ddb_ModelMakerToolbox_quickMode.m $
% $Keywords: $

%%
handles=getHandles;
ddb_zoomOff;

if isempty(varargin)
    % New tab selected
    ddb_refreshScreen;
    ddb_plotModelMaker('activate');
    if ~isempty(handles.toolbox.modelmaker.gridOutlineHandle)
        setInstructions({'Left-click and drag markers to change corner points','Right-click and drag YELLOW marker to move entire box', ...
            'Right-click and drag RED markers to rotate box'});
    end
else
    
    %Options selected
    
    opt=lower(varargin{1});
    
    switch opt
        case{'drawgridoutline'}
            drawGridOutline;
        case{'editgridoutline'}
            editGridOutline;
        case{'editresolution'}
            editResolution;
        case{'generategrid'}
            generateGrid;
        case{'generatebathymetry'}
            generateBathymetry;
        case{'loadsetup'}
            loadSetup;
        case{'savesetup'}
            saveSetup;
    end
    
end

%%
function drawGridOutline
handles=getHandles;
setInstructions({'','','Use mouse to draw grid outline on map'});
UIRectangle(handles.GUIHandles.mapAxis,'draw','Tag','GridOutline','Marker','o','MarkerEdgeColor','k','MarkerSize',6,'rotate',1,'callback',@updateGridOutline,'onstart',@deleteGridOutline, ...
    'ddx',handles.toolbox.modelmaker.dX,'ddy',handles.toolbox.modelmaker.dY,'number',1);

%%
function updateGridOutline(x0,y0,dx,dy,rotation,h)

setInstructions({'Left-click and drag markers to change corner points','Right-click and drag YELLOW marker to move entire box', ...
    'Right-click and drag RED markers to rotate box'});

handles=getHandles;

handles.toolbox.modelmaker.gridOutlineHandle=h;

handles.toolbox.modelmaker.xOri=x0;
handles.toolbox.modelmaker.yOri=y0;
handles.toolbox.modelmaker.rotation=rotation;
handles.toolbox.modelmaker.nX=round(dx/handles.toolbox.modelmaker.dX);
handles.toolbox.modelmaker.nY=round(dy/handles.toolbox.modelmaker.dY);
handles.toolbox.modelmaker.lengthX=dx;
handles.toolbox.modelmaker.lengthY=dy;

setHandles(handles);

gui_updateActiveTab;

%%
function deleteGridOutline
handles=getHandles;
if ~isempty(handles.toolbox.modelmaker.gridOutlineHandle)
    try
        delete(handles.toolbox.modelmaker.gridOutlineHandle);
    end
end


%%
function editGridOutline

handles=getHandles;

if ~isempty(handles.toolbox.modelmaker.gridOutlineHandle)
    try
        delete(handles.toolbox.modelmaker.gridOutlineHandle);
    end
end

handles.toolbox.modelmaker.lengthX=handles.toolbox.modelmaker.dX*handles.toolbox.modelmaker.nX;
handles.toolbox.modelmaker.lengthY=handles.toolbox.modelmaker.dY*handles.toolbox.modelmaker.nY;

lenx=handles.toolbox.modelmaker.dX*handles.toolbox.modelmaker.nX;
leny=handles.toolbox.modelmaker.dY*handles.toolbox.modelmaker.nY;
h=UIRectangle(handles.GUIHandles.mapAxis,'plot','Tag','GridOutline','Marker','o','MarkerEdgeColor','k','MarkerSize',6,'rotate',1,'callback',@updateGridOutline, ...
    'x0',handles.toolbox.modelmaker.xOri,'y0',handles.toolbox.modelmaker.yOri,'dx',lenx,'dy',leny,'rotation',handles.toolbox.modelmaker.rotation, ...
    'ddx',handles.toolbox.modelmaker.dX,'ddy',handles.toolbox.modelmaker.dY,'number',1);
handles.toolbox.modelmaker.gridOutlineHandle=h;

setHandles(handles);

%%
function editResolution

handles=getHandles;

lenx=handles.toolbox.modelmaker.lengthX;
leny=handles.toolbox.modelmaker.lengthY;

dx=handles.toolbox.modelmaker.dX;
dy=handles.toolbox.modelmaker.dY;

nx=round(lenx/max(dx,1e-9));
ny=round(leny/max(dy,1e-9));

handles.toolbox.modelmaker.nX=nx;
handles.toolbox.modelmaker.nY=ny;

handles.toolbox.modelmaker.lengthX=nx*dx;
handles.toolbox.modelmaker.lengthY=ny*dy;

if ~isempty(handles.toolbox.modelmaker.gridOutlineHandle)
    try
        delete(handles.toolbox.modelmaker.gridOutlineHandle);
    end
end

h=UIRectangle(handles.GUIHandles.mapAxis,'plot','Tag','GridOutline','Marker','o','MarkerEdgeColor','k','MarkerSize',6,'rotate',1,'callback',@updateGridOutline, ...
    'x0',handles.toolbox.modelmaker.xOri,'y0',handles.toolbox.modelmaker.yOri,'dx',handles.toolbox.modelmaker.lengthX,'dy',handles.toolbox.modelmaker.lengthY, ...
    'rotation',handles.toolbox.modelmaker.rotation, ...
    'ddx',handles.toolbox.modelmaker.dX,'ddy',handles.toolbox.modelmaker.dY,'number',1)
    
handles.toolbox.modelmaker.gridOutlineHandle=h;

setHandles(handles);

%%
function generateGrid

handles=getHandles;
npmax=20000000;
if handles.toolbox.modelmaker.nX*handles.toolbox.modelmaker.nY<=npmax
    handles=ddb_modflowusg_generate_grid(handles,ad);
    setHandles(handles);
else
    ddb_giveWarning('Warning',['Maximum number of grid points (' num2str(npmax) ') exceeded ! Please reduce grid resolution.']);
end

%%
function generateBathymetry
handles=getHandles;
% Use background bathymetry data
datasets(1).name=handles.screenParameters.backgroundBathymetry;
ad = handles.activeDomain;
handles=ddb_ModelMakerToolbox_Delft3DFLOW_generateBathymetry(handles,ad,datasets);
setHandles(handles);

%%
function saveSetup
handles=getHandles;
xml.x0=handles.toolbox.modelmaker.xOri;
xml.y0=handles.toolbox.modelmaker.yOri;
xml.rotation=handles.toolbox.modelmaker.rotation;
xml.nx=handles.toolbox.modelmaker.nX;
xml.ny=handles.toolbox.modelmaker.nY;
xml.dx=handles.toolbox.modelmaker.lengthX;
xml.dy=handles.toolbox.modelmaker.lengthY;
for ii=1:handles.toolbox.modelmaker.gridgen.nrlines
    xml.lines(ii).lines.name=handles.toolbox.modelmaker.gridgen.lines(ii).name;
    xml.lines(ii).lines.x=handles.toolbox.modelmaker.gridgen.lines(ii).x;
    xml.lines(ii).lines.y=handles.toolbox.modelmaker.gridgen.lines(ii).y;
    xml.lines(ii).lines.refinement_level=handles.toolbox.modelmaker.gridgen.lines(ii).refinement_level;
end
struct2xml('test.xml',xml,'structuretype','short');


%%
function loadSetup

handles=getHandles;

xml=xml2struct('test.xml','structuretype','short');

handles.toolbox.modelmaker.xOri=str2num(xml.x0);
handles.toolbox.modelmaker.yOri=str2num(xml.y0);
handles.toolbox.modelmaker.rotation=str2num(xml.rotation);
handles.toolbox.modelmaker.nX=str2num(xml.nx);
handles.toolbox.modelmaker.nY=str2num(xml.ny);
handles.toolbox.modelmaker.lengthX=str2num(xml.dx);
handles.toolbox.modelmaker.lengthY=str2num(xml.dy);

handles.toolbox.modelmaker.gridgen.lines=[];
handles.toolbox.modelmaker.gridgen.nrlines=0;
handles.toolbox.modelmaker.gridgen.activeline=1;
handles.toolbox.modelmaker.gridgen.lines(1).name='';
handles.toolbox.modelmaker.gridgen.lines(1).x=[];
handles.toolbox.modelmaker.gridgen.lines(1).y=[];
handles.toolbox.modelmaker.gridgen.lines(1).refinement_level=[];
handles.toolbox.modelmaker.gridgen.linenames=[];

if isfield(xml,'lines')
    for ii=1:length(xml.lines)
        handles.toolbox.modelmaker.gridgen.lines(ii).name=xml.lines(ii).lines.name;
        handles.toolbox.modelmaker.gridgen.lines(ii).x=str2num(xml.lines(ii).lines.x);
        handles.toolbox.modelmaker.gridgen.lines(ii).y=str2num(xml.lines(ii).lines.y);
        handles.toolbox.modelmaker.gridgen.lines(ii).refinement_level=str2num(xml.lines(ii).lines.refinement_level);
        handles.toolbox.modelmaker.gridgen.linenames{ii}=xml.lines(ii).lines.name;
    end
    handles.toolbox.modelmaker.gridgen.nrlines=length(xml.lines);
end

setHandles(handles);

% Plot grid outline

% Plot lines
ddb_ModelMakerToolbox_modflowusg_lines('plotlines');

