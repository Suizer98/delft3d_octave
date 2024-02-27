function handles = ddb_initializeModelMaker(handles, varargin)
%DDB_INITIALIZEMODELMAKER  start-up file for model maker
%
%   Syntax:
%   handles = ddb_initializeModelMaker(handles, varargin)
%
%   Input:
%   handles  =
%   varargin =
%
%   Output:
%   handles  =
%
%   Example
%   ddb_initializeModelMaker
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

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%

ddb_getToolboxData(handles,handles.toolbox.modelmaker.dataDir,'modelmaker','ModelMaker');

if nargin>1
    switch varargin{1}
        case{'test'}
            return
        case{'veryfirst'}
            handles.toolbox.modelmaker.longName='Model Maker';
            return
    end
end

handles.toolbox.modelmaker.nX=1;
handles.toolbox.modelmaker.dX=0.1;
handles.toolbox.modelmaker.wavedX=0.1;
handles.toolbox.modelmaker.xOri=0.0;
handles.toolbox.modelmaker.nY=1;
handles.toolbox.modelmaker.dY=0.1;
handles.toolbox.modelmaker.wavedY=0.1;
handles.toolbox.modelmaker.yOri=1.0;
handles.toolbox.modelmaker.lengthX=0.1;
handles.toolbox.modelmaker.lengthY=0.1;
handles.toolbox.modelmaker.rotation=0.0;
handles.toolbox.modelmaker.sectionLength=10;
handles.toolbox.modelmaker.sectionLengthMetres=50000;
handles.toolbox.modelmaker.zMax=0;
handles.toolbox.modelmaker.viewGridOutline=1;

handles.toolbox.modelmaker.yOffshore=400;
handles.toolbox.modelmaker.dxCoast=100;
handles.toolbox.modelmaker.dyMinCoast=10;
handles.toolbox.modelmaker.dyMaxCoast=50;
handles.toolbox.modelmaker.coastSplineX=[];
handles.toolbox.modelmaker.coastSplineY=[];
handles.toolbox.modelmaker.courantCoast=10;
handles.toolbox.modelmaker.nSmoothCoast=1.1;
handles.toolbox.modelmaker.depthRelCoast=5;

handles.toolbox.modelmaker.activeTideModelBC=1;
handles.toolbox.modelmaker.activeTideModelIC=1;

% Make TPXO72 the default tide model
jj=strmatch('tpxo72',handles.tideModels.names,'exact');
if ~isempty(jj)
    handles.toolbox.modelmaker.activeTideModelBC=jj;
    handles.toolbox.modelmaker.activeTideModelIC=jj;
end

handles.toolbox.modelmaker.gridOutlineHandle=[];

if strcmpi(handles.screenParameters.coordinateSystem.type,'cartesian')
    handles.toolbox.modelmaker.dX=1000;
    handles.toolbox.modelmaker.dY=1000;
end


%% FAST
% Polygon
handles.toolbox.modelmaker.polygonHandle=[];
handles.toolbox.modelmaker.polygonX=[];
handles.toolbox.modelmaker.polygonY=[];
handles.toolbox.modelmaker.polyLength=0;
handles.toolbox.modelmaker.polygonFile='';
% Contours
handles.toolbox.modelmaker.depthcontour=-50;
handles.toolbox.modelmaker.distance=1000;
handles.toolbox.modelmaker.dirbin=0.25;
handles.toolbox.modelmaker.radbin=100;
handles.toolbox.modelmaker.maxrad=50000;
handles.toolbox.modelmaker.maxelevation=25;

% DEM
handles.toolbox.modelmaker.dem.outlinehandle=[];
handles.toolbox.modelmaker.dem.xlim=[0 0];
handles.toolbox.modelmaker.dem.ylim=[0 0];
handles.toolbox.modelmaker.dem.dx=1;
handles.toolbox.modelmaker.dem.dy=1;
handles.toolbox.modelmaker.dem.demfile='';

%% Bathymetry
handles.toolbox.modelmaker.bathymetry.activeDataset=1;
handles.toolbox.modelmaker.bathymetry.activeSelectedDataset=1;
handles.toolbox.modelmaker.bathymetry.selectedDatasetNames={''};
handles.toolbox.modelmaker.bathymetry.selectedDatasets(1).verticalLevel=0;
handles.toolbox.modelmaker.bathymetry.selectedDatasets(1).verticalDatum=0;
handles.toolbox.modelmaker.bathymetry.nrSelectedDatasets=0;
handles.toolbox.modelmaker.bathymetry.selectedDatasets(1).type='unknown';
handles.toolbox.modelmaker.bathymetry.selectedDatasets(1).zMax=10000;
handles.toolbox.modelmaker.bathymetry.selectedDatasets(1).zMin=-10000;
handles.toolbox.modelmaker.bathymetry.selectedDatasets(1).startDate=datenum(2000,1,1);
handles.toolbox.modelmaker.bathymetry.selectedDatasets(1).searchInterval=5;
handles.toolbox.modelmaker.bathymetry.verticalDatum=0;
handles.toolbox.modelmaker.bathymetry.internalDiffusion=0;
handles.toolbox.modelmaker.bathymetry.internalDiffusionRange=[-20000 20000];

%% Initial conditions
handles.toolbox.modelmaker.initialConditions.parameterList={'Water Level','Current'};
handles.toolbox.modelmaker.initialConditions.activeParameter=1;
handles.toolbox.modelmaker.initialConditions.parameter='Water Level';

handles.toolbox.modelmaker.initialConditions.activeDataSource=1;
handles.toolbox.modelmaker.initialConditions.dataSourceList={'Constant'};
handles.toolbox.modelmaker.initialConditions.dataSource='Constant';

%% Roughness
handles.toolbox.modelmaker.roughness.landelevation=0;
handles.toolbox.modelmaker.roughness.landroughness=0.08;
handles.toolbox.modelmaker.roughness.searoughness=0.024;

%% XBeach specific
handles.toolbox.modelmaker.areasize = 50;
handles.toolbox.modelmaker.dxmax = 50;
handles.toolbox.modelmaker.dymax = 50;
handles.toolbox.modelmaker.SSL = 2;
handles.toolbox.modelmaker.Hs = 5;
handles.toolbox.modelmaker.Tp = 10;
handles.toolbox.modelmaker.waveangle = 180;
handles.toolbox.modelmaker.domain1d = 0;
% handles.model.xbeach.domain.thetamin = 90;
% handles.model.xbeach.domain.thetamax = 270;

%% Boundary options for Delft3D
handles.toolbox.modelmaker.delft3d.boundary_type='Z';
handles.toolbox.modelmaker.delft3d.boundary_forcing='A';
handles.toolbox.modelmaker.delft3d.boundary_minimum_depth=5;
handles.toolbox.modelmaker.delft3d.boundary_auto_section_length=1;

%% Boundary options for Delft3D-FM
handles.toolbox.modelmaker.dflowfm.boundary_type='water_level';
handles.toolbox.modelmaker.dflowfm.boundary_forcing='astronomic';
handles.toolbox.modelmaker.dflowfm.boundary_minimum_depth=5;
handles.toolbox.modelmaker.dflowfm.boundary_auto_section_length=1;

%% GridGen
handles.toolbox.modelmaker.gridgen.nrlines=0;
handles.toolbox.modelmaker.gridgen.lines=[];
handles.toolbox.modelmaker.gridgen.lines(1).refinement_level=[];
handles.toolbox.modelmaker.gridgen.activeline=1;
handles.toolbox.modelmaker.gridgen.linenames={''};

%% ESM
handles.toolbox.modelmaker.esm.coastline.filename='';
handles.toolbox.modelmaker.esm.coastline.length=0;
handles.toolbox.modelmaker.esm.coastline.x=[];
handles.toolbox.modelmaker.esm.coastline.y=[];
handles.toolbox.modelmaker.esm.coastline.dx=5000;
handles.toolbox.modelmaker.esm.coastline.xon=20000;
handles.toolbox.modelmaker.esm.coastline.xoff=200000;
handles.toolbox.modelmaker.esm.depthcontour.value=-100;

%% DFLowFM refinement
handles.toolbox.modelmaker.dflowfm.nr_refinement_steps=1;
handles.toolbox.modelmaker.dflowfm.dtmax=60;
handles.toolbox.modelmaker.polyLength=0;
handles.toolbox.modelmaker.polygonFile='';
handles.toolbox.modelmaker.clipzmax=10000;
handles.toolbox.modelmaker.clipzmin=-10000;

%% SFINCS
handles.toolbox.modelmaker.sfincs.zmin=-2;
handles.toolbox.modelmaker.sfincs.zmax=10;
handles.toolbox.modelmaker.sfincs.zlev_polygon=5;
handles.toolbox.modelmaker.sfincs.include_xy=[];
handles.toolbox.modelmaker.sfincs.exclude_xy=[];
handles.toolbox.modelmaker.sfincs.closedboundary_xy=[];
handles.toolbox.modelmaker.sfincs.outflowboundary_xy=[];
handles.toolbox.modelmaker.sfincs.waterlevelboundary_xy=[];

handles.toolbox.modelmaker.sfincs.mask.nrincludepolygons=0;
handles.toolbox.modelmaker.sfincs.mask.includepolygonnames={''};
handles.toolbox.modelmaker.sfincs.mask.activeincludepolygon=1;
handles.toolbox.modelmaker.sfincs.mask.includepolygon(1).length=0;
handles.toolbox.modelmaker.sfincs.mask.includepolygon(1).x=[];
handles.toolbox.modelmaker.sfincs.mask.includepolygon(1).y=[];
handles.toolbox.modelmaker.sfincs.mask.includepolygonfile='';

handles.toolbox.modelmaker.sfincs.mask.nrexcludepolygons=0;
handles.toolbox.modelmaker.sfincs.mask.excludepolygonnames={''};
handles.toolbox.modelmaker.sfincs.mask.activeexcludepolygon=1;
handles.toolbox.modelmaker.sfincs.mask.excludepolygon(1).length=0;
handles.toolbox.modelmaker.sfincs.mask.excludepolygon(1).x=[];
handles.toolbox.modelmaker.sfincs.mask.excludepolygon(1).y=[];
handles.toolbox.modelmaker.sfincs.mask.excludepolygonfile='';

handles.toolbox.modelmaker.sfincs.mask.nrclosedboundarypolygons=0;
handles.toolbox.modelmaker.sfincs.mask.closedboundarypolygonnames={''};
handles.toolbox.modelmaker.sfincs.mask.activeclosedboundarypolygon=1;
handles.toolbox.modelmaker.sfincs.mask.closedboundarypolygon(1).length=0;
handles.toolbox.modelmaker.sfincs.mask.closedboundarypolygon(1).x=[];
handles.toolbox.modelmaker.sfincs.mask.closedboundarypolygon(1).y=[];
handles.toolbox.modelmaker.sfincs.mask.closedboundarypolygonfile='';

handles.toolbox.modelmaker.sfincs.mask.nroutflowboundarypolygons=0;
handles.toolbox.modelmaker.sfincs.mask.outflowboundarypolygonnames={''};
handles.toolbox.modelmaker.sfincs.mask.activeoutflowboundarypolygon=1;
handles.toolbox.modelmaker.sfincs.mask.outflowboundarypolygon(1).length=0;
handles.toolbox.modelmaker.sfincs.mask.outflowboundarypolygon(1).x=[];
handles.toolbox.modelmaker.sfincs.mask.outflowboundarypolygon(1).y=[];
handles.toolbox.modelmaker.sfincs.mask.outflowboundarypolygonfile='';

handles.toolbox.modelmaker.sfincs.mask.nrwaterlevelboundarypolygons=0;
handles.toolbox.modelmaker.sfincs.mask.waterlevelboundarypolygonnames={''};
handles.toolbox.modelmaker.sfincs.mask.activewaterlevelboundarypolygon=1;
handles.toolbox.modelmaker.sfincs.mask.waterlevelboundarypolygon(1).length=0;
handles.toolbox.modelmaker.sfincs.mask.waterlevelboundarypolygon(1).x=[];
handles.toolbox.modelmaker.sfincs.mask.waterlevelboundarypolygon(1).y=[];
handles.toolbox.modelmaker.sfincs.mask.waterlevelboundarypolygonfile='';

% options for sfincs_make_mask_advanced
handles.toolbox.modelmaker.sfincs.mask.activegrid_options = {'current mask','elevation','include polygon','exclude polygon'};
handles.toolbox.modelmaker.sfincs.mask.nr_activegrid_options = 1;
handles.toolbox.modelmaker.sfincs.mask.activegrid_index = 1;
handles.toolbox.modelmaker.sfincs.mask.activegrid_option = 1;
handles.toolbox.modelmaker.sfincs.mask.activegrid_action={'current mask'};

handles.toolbox.modelmaker.sfincs.mask.boundarycells_options = {'waterlevel boundary','outflow boundary','closed boundary','elevation'};
handles.toolbox.modelmaker.sfincs.mask.nr_boundarycells_options = 0;
handles.toolbox.modelmaker.sfincs.mask.boundarycells_index = 1;
handles.toolbox.modelmaker.sfincs.mask.boundarycells_option = 1;
handles.toolbox.modelmaker.sfincs.mask.boundarycells_action={};

% Quadtree
handles.toolbox.modelmaker.sfincs.buq.nr_refinement_polygons=0;
handles.toolbox.modelmaker.sfincs.buq.refinement_polygon_names={''};
handles.toolbox.modelmaker.sfincs.buq.active_refinement_polygon=1;
handles.toolbox.modelmaker.sfincs.buq.refinement_polygon=[];
handles.toolbox.modelmaker.sfincs.buq.refinement_polygon(1).length=0;
handles.toolbox.modelmaker.sfincs.buq.refinement_polygon(1).x=[];
handles.toolbox.modelmaker.sfincs.buq.refinement_polygon(1).y=[];
handles.toolbox.modelmaker.sfincs.buq.refinement_polygon_file='';
handles.toolbox.modelmaker.sfincs.buq.refinement_level_strings={''};
handles.toolbox.modelmaker.sfincs.buq.refinement_level_values=[];
handles.toolbox.modelmaker.sfincs.buq.active_refinement_level=1;

%% HurryWave
handles.toolbox.modelmaker.hurrywave.zmin=-2;
handles.toolbox.modelmaker.hurrywave.zmax=10;
handles.toolbox.modelmaker.hurrywave.zlev_polygon=5;
handles.toolbox.modelmaker.hurrywave.include_xy=[];
handles.toolbox.modelmaker.hurrywave.exclude_xy=[];
handles.toolbox.modelmaker.hurrywave.boundary_xy=[];

handles.toolbox.modelmaker.hurrywave.mask.nrincludepolygons=0;
handles.toolbox.modelmaker.hurrywave.mask.includepolygonnames={''};
handles.toolbox.modelmaker.hurrywave.mask.activeincludepolygon=1;
handles.toolbox.modelmaker.hurrywave.mask.includepolygon(1).length=0;
handles.toolbox.modelmaker.hurrywave.mask.includepolygon(1).x=[];
handles.toolbox.modelmaker.hurrywave.mask.includepolygon(1).y=[];
handles.toolbox.modelmaker.hurrywave.mask.includepolygonfile='';

handles.toolbox.modelmaker.hurrywave.mask.nrexcludepolygons=0;
handles.toolbox.modelmaker.hurrywave.mask.excludepolygonnames={''};
handles.toolbox.modelmaker.hurrywave.mask.activeexcludepolygon=1;
handles.toolbox.modelmaker.hurrywave.mask.excludepolygon(1).length=0;
handles.toolbox.modelmaker.hurrywave.mask.excludepolygon(1).x=[];
handles.toolbox.modelmaker.hurrywave.mask.excludepolygon(1).y=[];
handles.toolbox.modelmaker.hurrywave.mask.excludepolygonfile='';

handles.toolbox.modelmaker.hurrywave.mask.nrboundarypolygons=0;
handles.toolbox.modelmaker.hurrywave.mask.boundarypolygonnames={''};
handles.toolbox.modelmaker.hurrywave.mask.activeboundarypolygon=1;
handles.toolbox.modelmaker.hurrywave.mask.boundarypolygon(1).length=0;
handles.toolbox.modelmaker.hurrywave.mask.boundarypolygon(1).x=[];
handles.toolbox.modelmaker.hurrywave.mask.boundarypolygon(1).y=[];
handles.toolbox.modelmaker.hurrywave.mask.boundarypolygonfile='';

% options for hurrywave_make_mask_advanced
handles.toolbox.modelmaker.hurrywave.mask.activegrid_options = {'current mask','elevation','include polygon','exclude polygon'};
handles.toolbox.modelmaker.hurrywave.mask.nr_activegrid_options = 1;
handles.toolbox.modelmaker.hurrywave.mask.activegrid_index = 1;
handles.toolbox.modelmaker.hurrywave.mask.activegrid_option = 1;
handles.toolbox.modelmaker.hurrywave.mask.activegrid_action={'current mask'};

handles.toolbox.modelmaker.hurrywave.mask.boundarycells_options = {'waterlevel boundary','outflow boundary','closed boundary','elevation'};
handles.toolbox.modelmaker.hurrywave.mask.nr_boundarycells_options = 0;
handles.toolbox.modelmaker.hurrywave.mask.boundarycells_index = 1;
handles.toolbox.modelmaker.hurrywave.mask.boundarycells_option = 1;
handles.toolbox.modelmaker.hurrywave.mask.boundarycells_action={};
