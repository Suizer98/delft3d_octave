function ddb_ModelMakerToolbox_DFlowFM_quickMode(varargin)
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

% $Id: ddb_ModelMakerToolbox_quickMode_DFlowFM.m 10447 2014-03-26 07:06:47Z ormondt $
% $Date: 2014-03-26 08:06:47 +0100 (Wed, 26 Mar 2014) $
% $Author: ormondt $
% $Revision: 10447 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/ModelMaker/ddb_ModelMakerToolbox_quickMode_DFlowFM.m $
% $Keywords: $

%%
handles=getHandles;
ddb_zoomOff;

if isempty(varargin)
    
    % New tab selected
    ddb_refreshScreen;
    
    % setUIElements('modelmakerpanel.quickmode');
    setHandles(handles);
    ddb_plotModelMaker('activate');
    if ~isempty(handles.toolbox.modelmaker.gridOutlineHandle)
        setInstructions({'Left-click and drag markers to change corner points','Right-click and drag YELLOW marker to move entire box', ...
            'Right-click and drag RED markers to rotate box (note: rotating grid in geographic coordinate systems is NOT recommended!)'});
    end
else
    
    % Options selected
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
        case{'generateopenboundaries'}
            generateOpenBoundaries;
        case{'generateboundaryconditions'}
            generateBoundaryConditions;
        case{'generateinitialconditions'}
            generateInitialConditions;
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

% Start
setInstructions({'Left-click and drag markers to change corner points','Right-click and drag YELLOW marker to move entire box', ...
    'Right-click and drag RED markers to rotate box (note: rotating grid in geographic coordinate systems is NOT recommended!)'});
handles = getHandles;

% Update grid
handles.toolbox.modelmaker.gridOutlineHandle=h;
handles.toolbox.modelmaker.xOri=x0;
handles.toolbox.modelmaker.yOri=y0;
handles.toolbox.modelmaker.rotation=rotation;
handles.toolbox.modelmaker.nX=round(dx/handles.toolbox.modelmaker.dX);
handles.toolbox.modelmaker.nY=round(dy/handles.toolbox.modelmaker.dY);
handles.toolbox.modelmaker.lengthX=dx;
handles.toolbox.modelmaker.lengthY=dy;

% Close
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

% Start
handles=getHandles;

% Delete grid
if ~isempty(handles.toolbox.modelmaker.gridOutlineHandle)
    try
        delete(handles.toolbox.modelmaker.gridOutlineHandle);
    end
end

% Update grid
handles.toolbox.modelmaker.lengthX=handles.toolbox.modelmaker.dX*handles.toolbox.modelmaker.nX;
handles.toolbox.modelmaker.lengthY=handles.toolbox.modelmaker.dY*handles.toolbox.modelmaker.nY;
lenx=handles.toolbox.modelmaker.dX*handles.toolbox.modelmaker.nX;
leny=handles.toolbox.modelmaker.dY*handles.toolbox.modelmaker.nY;
h=UIRectangle(handles.GUIHandles.mapAxis,'plot','Tag','GridOutline','Marker','o','MarkerEdgeColor','k','MarkerSize',6,'rotate',1,'callback',@updateGridOutline, ...
    'x0',handles.toolbox.modelmaker.xOri,'y0',handles.toolbox.modelmaker.yOri,'dx',lenx,'dy',leny,'rotation',handles.toolbox.modelmaker.rotation, ...
    'ddx',handles.toolbox.modelmaker.dX,'ddy',handles.toolbox.modelmaker.dY);

% Close
handles.toolbox.modelmaker.gridOutlineHandle=h;
setHandles(handles);

%%
function editResolution

% Start
handles=getHandles;

% Values
lenx    = handles.toolbox.modelmaker.lengthX;
leny    = handles.toolbox.modelmaker.lengthY;
dx      = handles.toolbox.modelmaker.dX;
dy      = handles.toolbox.modelmaker.dY;
nx      = round(lenx/max(dx,1e-9));
ny      = round(leny/max(dy,1e-9));
handles.toolbox.modelmaker.nX       = nx;
handles.toolbox.modelmaker.nY       = ny;
handles.toolbox.modelmaker.lengthX  =nx*dx;
handles.toolbox.modelmaker.lengthY  =ny*dy;
lenx    =handles.toolbox.modelmaker.lengthX;
leny    =handles.toolbox.modelmaker.lengthY;

% Delete
if ~isempty(handles.toolbox.modelmaker.gridOutlineHandle)
    try
        delete(handles.toolbox.modelmaker.gridOutlineHandle);
    end
end

% Draw
h=UIRectangle(handles.GUIHandles.mapAxis,'plot','Tag','GridOutline','Marker','o','MarkerEdgeColor','k','MarkerSize',6,'rotate',1,'callback',@updateGridOutline, ...
    'x0',handles.toolbox.modelmaker.xOri,'y0',handles.toolbox.modelmaker.yOri,'dx',handles.toolbox.modelmaker.lengthX,'dy',handles.toolbox.modelmaker.lengthY, ...
    'rotation',handles.toolbox.modelmaker.rotation, ...
    'ddx',handles.toolbox.modelmaker.dX,'ddy',handles.toolbox.modelmaker.dY);
handles.toolbox.modelmaker.gridOutlineHandle=h;

% Finish
setHandles(handles);

%%
function generateGrid

% Start
handles     = getHandles;
npmax       = 20000000;

% Generate grid; not too big
if handles.toolbox.modelmaker.nX*handles.toolbox.modelmaker.nY<=npmax   
    handles=ddb_ModelMakerToolbox_DFlowFM_generateGrid(handles,ad);
else
    ddb_giveWarning('Warning',['Maximum number of grid points (' num2str(npmax) ') exceeded ! Please reduce grid resolution.']);
end
setHandles(handles);

%%
function generateBathymetry

% Start
handles=getHandles;

% Use background bathymetry data
datasets(1).name=handles.screenParameters.backgroundBathymetry;
handles=ddb_ModelMakerToolbox_DFlowFM_generateBathymetry(handles,ad,datasets);

% Finish
setHandles(handles);

%%
function generateOpenBoundaries

% Start
handles=getHandles;

if isnan(nanmax(handles.model.dflowfm.domain(ad).netstruc.node.mesh2d_node_z))
    ddb_giveWarning('text','Could not generate open boundaries! Please generate bathymetry first.');
    return
end

[filename,ok]=gui_uiputfile('*.ext', 'External Forcing File',handles.model.dflowfm.domain(ad).extforcefilenew);
if ~ok
    return
end
handles.model.dflowfm.domain(ad).extforcefilenew=filename;

[filename,ok]=gui_uiputfile('*.bc', 'Boundary Conditions File',handles.model.dflowfm.domain(ad).bcfile);
if ~ok
    return
end
handles.model.dflowfm.domain(ad).bcfile=filename;

% First edit type of boundary etc.
h.type=handles.toolbox.modelmaker.dflowfm.boundary_type;
h.forcing=handles.toolbox.modelmaker.dflowfm.boundary_forcing;
h.minimum_depth=handles.toolbox.modelmaker.dflowfm.boundary_minimum_depth;
h.auto_section_length=handles.toolbox.modelmaker.dflowfm.boundary_auto_section_length;

xmldir=handles.model.dflowfm.xmlDir;
xmlfile='model.dflowfm.modelmaker.boundaryoptions.xml';

[h,ok]=gui_newWindow(h,'xmldir',xmldir,'xmlfile',xmlfile,'iconfile',[handles.settingsDir filesep 'icons' filesep 'deltares.gif'],'modal',1);
if ok
    handles.toolbox.modelmaker.dflowfm.boundary_type=h.type;
    handles.toolbox.modelmaker.dflowfm.boundary_forcing=h.forcing;
    handles.toolbox.modelmaker.dflowfm.boundary_minimum_depth=h.minimum_depth;
    handles.toolbox.modelmaker.dflowfm.boundary_auto_section_length=h.auto_section_length;
else
    return
end

% Find boundaries
maxdist     = handles.toolbox.modelmaker.sectionLengthMetres;
minlev      = -handles.toolbox.modelmaker.dflowfm.boundary_minimum_depth;

boundarysections = ddb_DFlowFM_findBoundarySections(handles.model.dflowfm.domain(ad).circumference,maxdist,minlev,handles.screenParameters.coordinateSystem.type);
handles.model.dflowfm.domain(ad).boundarynames = {''};

% Delete existing boundaries
ddb_DFlowFM_plotBoundaries(handles,'delete','domain',ad);

handles.model.dflowfm.domain(ad).boundary=[];
handles.model.dflowfm.domain(ad).boundarynames=[];

nr=length(boundarysections);

% Name boundaries
for ib=1:nr
    
    name=['bnd' num2str(ib,'%0.3i')];
    tp=handles.toolbox.modelmaker.dflowfm.boundary_type;
    x=boundarysections(ib).x;
    y=boundarysections(ib).y;
    boundary  = ddb_delft3dfm_initialize_boundary(name,tp,handles.toolbox.modelmaker.dflowfm.boundary_forcing,handles.model.dflowfm.domain(ad).tstart,handles.model.dflowfm.domain(ad).tstop,x,y);    
    handles.model.dflowfm.domain(ad).boundary(ib).boundary = boundary;
    handles.model.dflowfm.domain(ad).boundarynames{ib}=boundary.name;

end

handles.model.dflowfm.domain.activeboundary=1;

% Save files
handles.model.dflowfm.domain(ad).nrboundaries = nr;
handles = ddb_DFlowFM_plotBoundaries(handles,'plot','active',1);
% for ipol=1:length(handles.model.dflowfm.domain(ad).boundaries)
%     ddb_DFlowFM_saveBoundaryPolygon('.\',handles.model.dflowfm.domain(ad).boundaries,ipol);
% end
% handles.model.dflowfm.domain(ad).extforcefilenew='forcing.ext';
% ddb_DFlowFM_saveExtFile(handles);


ddb_delft3dfm_save_boundary_ext_file(handles);

% Finish
setHandles(handles);

%%
function generateBoundaryConditions

handles = getHandles;

if handles.model.dflowfm.domain(ad).nrboundaries==0
    ddb_giveWarning('text','No boundary polylines have been specified!');
    return
end


% [filename,ok]=gui_uiputfile('*.ext', 'External Forcing File',handles.model.dflowfm.domain(ad).extforcefilenew);
% if ~ok
%     return
% end
% handles.model.dflowfm.domain(ad).extforcefilenew=filename;

[forcing_file,ok]=gui_uiputfile('*.bc', 'Boundary Forcing File',handles.model.dflowfm.domain(ad).bcfile);
if ~ok
    return
end

% Start
wb      = waitbox('Generating Boundary Conditions ...');

% Make the tides
for ipol=1:length(handles.model.dflowfm.domain(ad).boundary)


    bnd=handles.model.dflowfm.domain(ad).boundary(ipol).boundary;

    disp(['Processing boundary ' bnd.name]);
    
    [bnd,error] = ddb_ModelMakerToolbox_Delft3DFM_generate_astronomic_tides(handles, bnd, forcing_file);
    
    if error == 1
        ddb_giveWarning('Warning',['Delft Dashboard was unable to generate the tides']);
        return
    end
    
    handles.model.dflowfm.domain(ad).boundary(ipol).boundary=bnd;
    
end

ddb_delft3dfm_save_boundary_ext_file(handles);

%  % Save the data
% ddb_DFlowFM_saveBCfile(handles.model.dflowfm.domain.bcfile,boundaries);
% % for ii=1:length(boundaries)
% %     for jj=1:length(boundaries(ii).nodes)
% %         ddb_DFlowFM_saveCmpFile(boundaries,ii,jj);
% %     end
% % end
% handles.model.dflowfm.domain(ad).boundaries=boundaries;
% ddb_DFlowFM_saveExtFile(handles);
setHandles(handles);
fclose('all');

% Finish
% setHandles(handles);
close(wb);
