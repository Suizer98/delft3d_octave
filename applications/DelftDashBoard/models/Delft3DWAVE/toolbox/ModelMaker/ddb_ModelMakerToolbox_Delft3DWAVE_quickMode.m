function ddb_ModelMakerToolbox_Delft3DWAVE_quickMode(varargin)
%DDB_MODELMAKERTOOLBOX_QUICKMODE_DELFT3DWAVE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_ModelMakerToolbox_quickMode_Delft3DWAVE(varargin)

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
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

% $Id: ddb_ModelMakerToolbox_quickMode_Delft3DWAVE.m 10447 2014-03-26 07:06:47Z ormondt $
% $Date: 2014-03-26 08:06:47 +0100 (Wed, 26 Mar 2014) $
% $Author: ormondt $
% $Revision: 10447 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/ModelMaker/ddb_ModelMakerToolbox_quickMode_Delft3DWAVE.m $
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
            'Right-click and drag RED markers to rotate box (note: rotating grid in geographic coordinate systems is NOT recommended!)'});
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
        case{'generatenewgrid'}
            generateGrid('new');
        case{'generateexistinggrid'}
            generateGrid('existing');
        case{'generatebathymetry'}
            generateBathymetry;
        case{'copyfromflow'}
            copyFromFlow;
    end
    
end

%%
function drawGridOutline
handles=getHandles;
setInstructions({'','','Use mouse to draw grid outline on map'});
UIRectangle(handles.GUIHandles.mapAxis,'draw','Tag','GridOutline','Marker','o','MarkerEdgeColor','k','MarkerSize',6,'rotate',1,'callback',@updateGridOutline,'onstart',@deleteGridOutline, ...
    'ddx',handles.toolbox.modelmaker.dX,'ddy',handles.toolbox.modelmaker.dY);

%%
function updateGridOutline(x0,y0,dx,dy,rotation,h)

setInstructions({'Left-click and drag markers to change corner points','Right-click and drag YELLOW marker to move entire box', ...
    'Right-click and drag RED markers to rotate box (note: rotating grid in geographic coordinate systems is NOT recommended!)'});

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
    'ddx',handles.toolbox.modelmaker.dX,'ddy',handles.toolbox.modelmaker.dY);
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
    'ddx',handles.toolbox.modelmaker.dX,'ddy',handles.toolbox.modelmaker.dY);
handles.toolbox.modelmaker.gridOutlineHandle=h;

setHandles(handles);

%%
function generateGrid(opt)

handles=getHandles;

npmax=20000000;
if handles.toolbox.modelmaker.nX*handles.toolbox.modelmaker.nY>npmax
    ddb_giveWarning('Warning',['Maximum number of grid points (' num2str(npmax) ') exceeded ! Please reduce grid resolution.']);
    return
end

handles=ddb_ModelMakerToolbox_Delft3DWAVE_generateGrid(handles,'option',opt);

setHandles(handles);

    

%%
function generateBathymetry
handles=getHandles;
% Use background bathymetry data
datasets(1).name=handles.screenParameters.backgroundBathymetry;
handles=ddb_ModelMakerToolbox_Delft3DWAVE_generateBathymetry(handles,datasets);
setHandles(handles);

%%
function copyFromFlow

handles=getHandles;
grdfile=handles.model.delft3dflow.domain(1).grdFile;
depfile=handles.model.delft3dflow.domain(1).depFile;

if isempty(grdfile)
    ddb_giveWarning('text','No grid file has been specified in Delft3D-FLOW model!');
    return
end

if isempty(depfile)
    ddb_giveWarning('text','No depth file has been specified in Delft3D-FLOW model!');
    return
end

ButtonName = questdlg('Couple with Delft3D-FLOW model?', ...
    'Couple with flow', ...
    'Cancel', 'No', 'Yes', 'Yes');
switch ButtonName,
    case 'Cancel',
        return;
    case 'No',
        couplewithflow=0;
    case 'Yes',
        couplewithflow=1;
end

ddb_plotDelft3DWAVE('delete');

if handles.model.delft3dflow.domain(1).comInterval==0 || handles.model.delft3dflow.domain(1).comStartTime==handles.model.delft3dflow.domain(1).comStopTime
    ddb_giveWarning('text','Please make sure to set the communication file times in Delft3D-FLOW model!');
end

handles=ddb_initializeDelft3DWAVEInput(handles,handles.model.delft3dflow.domain(1).runid);
handles.model.delft3dwave.domain.runid=handles.model.delft3dflow.domain(1).runid;

%handles.model.delft3dwave.domain=[];
handles.model.delft3dwave.domain.nrgrids=1;
handles.model.delft3dwave.domain.gridnames=[];
handles.model.delft3dwave.domain.gridnames{1}=grdfile(1:end-4);
handles.model.delft3dwave.domain.domains=[];
handles.model.delft3dwave.domain.domains=ddb_initializeDelft3DWAVEDomain(handles.model.delft3dwave.domain.domains,1);
handles.activeWaveGrid=1;
handles.model.delft3dwave.domain.domains(1).gridx=handles.model.delft3dflow.domain(1).gridX;
handles.model.delft3dwave.domain.domains(1).gridy=handles.model.delft3dflow.domain(1).gridY;
handles.model.delft3dwave.domain.domains(1).depth=handles.model.delft3dflow.domain(1).depth;
handles.model.delft3dwave.domain.domains(1).gridname=grdfile;
handles.model.delft3dwave.domain.domains(1).bedlevelgrid=grdfile;
handles.model.delft3dwave.domain.domains(1).bedlevel=depfile;
% TODO : change coordsyst
handles.model.delft3dwave.domain.domains(1).coordsyst = handles.screenParameters.coordinateSystem.type;
handles.model.delft3dwave.domain.domains(1).mmax=size(handles.model.delft3dwave.domain.domains(1).gridx,1);
handles.model.delft3dwave.domain.domains(1).nmax=size(handles.model.delft3dwave.domain.domains(1).gridx,2);
handles.model.delft3dwave.domain.domains(1).nestgrid='';

if couplewithflow
    handles=ddb_coupleWaveWithFlow(handles);
end

setHandles(handles);

ddb_plotDelft3DWAVE('plot');

%%
