function handles = ddb_initializeFlowDomain(handles, opt, id, runid)
%DDB_INITIALIZEFLOWDOMAIN  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_initializeFlowDomain(handles, opt, id, runid)
%
%   Input:
%   handles =
%   opt     =
%   id      =
%   runid   =
%
%   Output:
%   handles =
%
%   Example
%   ddb_initializeFlowDomain
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

handles.model.delft3dflow.domain(id).runid=runid;

switch lower(opt)
    case{'griddependentinput'}
        handles=ddb_initializeGridDependentInput(handles,id);
    case{'all'}
        handles=ddb_initializeGridDependentInput(handles,id);
        handles=ddb_initializeOtherInput(handles,id,runid);
end

%%
function handles=ddb_initializeGridDependentInput(handles,id)

handles.model.delft3dflow.domain(id).grid=[];
handles.model.delft3dflow.domain(id).bathy=[];

handles.model.delft3dflow.domain(id).nrDischarges=0;

%% Observation points
handles.model.delft3dflow.domain(id).nrObservationPoints=0;
handles.model.delft3dflow.domain(id).activeObservationPoint=1;
handles.model.delft3dflow.domain(id).observationPointNames={''};
handles.model.delft3dflow.domain(id).activeObservationPoint=1;
handles.model.delft3dflow.domain(id).observationPoints(1).name='';
handles.model.delft3dflow.domain(id).observationPoints(1).M=[];
handles.model.delft3dflow.domain(id).observationPoints(1).N=[];
handles.model.delft3dflow.domain(id).addObservationPoint=0;
handles.model.delft3dflow.domain(id).selectObservationPoint=0;
handles.model.delft3dflow.domain(id).deleteObservationPoint=0;
handles.model.delft3dflow.domain(id).changeObservationPoint=0;

%% Discharges
handles.model.delft3dflow.domain(id).nrDischarges=0;
handles.model.delft3dflow.domain(id).activeDischarge=1;
handles.model.delft3dflow.domain(id).dischargeNames={''};
handles.model.delft3dflow.domain(id).discharges(1).name='';
handles.model.delft3dflow.domain(id).discharges(1).M=[];
handles.model.delft3dflow.domain(id).discharges(1).N=[];
handles.model.delft3dflow.domain(id).discharges(1).K=[];
handles.model.delft3dflow.domain(id).discharges(1).outM=[];
handles.model.delft3dflow.domain(id).discharges(1).outN=[];
handles.model.delft3dflow.domain(id).discharges(1).outK=[];
handles.model.delft3dflow.domain(id).discharges(1).interpolation='linear';
handles.model.delft3dflow.domain(id).discharges(1).type='normal';
handles.model.delft3dflow.domain(id).addDischarge=0;
handles.model.delft3dflow.domain(id).selectDischarge=0;
handles.model.delft3dflow.domain(id).deleteDischarge=0;
handles.model.delft3dflow.domain(id).changeDischarge=0;

%% Cross sections
handles.model.delft3dflow.domain(id).nrCrossSections=0;
handles.model.delft3dflow.domain(id).crossSectionNames={''};
handles.model.delft3dflow.domain(id).activeCrossSection=1;
handles.model.delft3dflow.domain(id).crossSections(1).name='';
handles.model.delft3dflow.domain(id).crossSections(1).M1=[];
handles.model.delft3dflow.domain(id).crossSections(1).M2=[];
handles.model.delft3dflow.domain(id).crossSections(1).N1=[];
handles.model.delft3dflow.domain(id).crossSections(1).N2=[];
handles.model.delft3dflow.domain(id).addCrossSection=0;
handles.model.delft3dflow.domain(id).selectCrossSection=0;
handles.model.delft3dflow.domain(id).deleteCrossSection=0;
handles.model.delft3dflow.domain(id).changeCrossSection=0;

%% Dry points
handles.model.delft3dflow.domain(id).nrDryPoints=0;
handles.model.delft3dflow.domain(id).dryPointNames={''};
handles.model.delft3dflow.domain(id).activeDryPoint=1;
handles.model.delft3dflow.domain(id).dryPoints(1).M1=[];
handles.model.delft3dflow.domain(id).dryPoints(1).M2=[];
handles.model.delft3dflow.domain(id).dryPoints(1).N1=[];
handles.model.delft3dflow.domain(id).dryPoints(1).N2=[];
handles.model.delft3dflow.domain(id).addDryPoint=0;
handles.model.delft3dflow.domain(id).selectDryPoint=0;
handles.model.delft3dflow.domain(id).deleteDryPoint=0;
handles.model.delft3dflow.domain(id).changeDryPoint=0;

%% Thin dams
handles.model.delft3dflow.domain(id).nrThinDams=0;
handles.model.delft3dflow.domain(id).thinDamNames={''};
handles.model.delft3dflow.domain(id).activeThinDam=1;
handles.model.delft3dflow.domain(id).thinDams(1).M1=[];
handles.model.delft3dflow.domain(id).thinDams(1).M2=[];
handles.model.delft3dflow.domain(id).thinDams(1).N1=[];
handles.model.delft3dflow.domain(id).thinDams(1).N2=[];
handles.model.delft3dflow.domain(id).thinDams(1).UV='U';
handles.model.delft3dflow.domain(id).addThinDam=0;
handles.model.delft3dflow.domain(id).selectThinDam=0;
handles.model.delft3dflow.domain(id).deleteThinDam=0;
handles.model.delft3dflow.domain(id).changeThinDam=0;

%% 2D weirs
handles.model.delft3dflow.domain(id).nrWeirs2D=0;
handles.model.delft3dflow.domain(id).weir2DNames={''};
handles.model.delft3dflow.domain(id).activeWeir2D=1;
handles.model.delft3dflow.domain(id).weirs2D(1).M1=[];
handles.model.delft3dflow.domain(id).weirs2D(1).M2=[];
handles.model.delft3dflow.domain(id).weirs2D(1).N1=[];
handles.model.delft3dflow.domain(id).weirs2D(1).N2=[];
handles.model.delft3dflow.domain(id).weirs2D(1).UV='U';
handles.model.delft3dflow.domain(id).weirs2D(1).frictionCoefficient=1.0;
handles.model.delft3dflow.domain(id).weirs2D(1).crestHeight=0.0;
handles.model.delft3dflow.domain(id).addWeir2D=0;
handles.model.delft3dflow.domain(id).selectWeir2D=0;
handles.model.delft3dflow.domain(id).deleteWeir2D=0;
handles.model.delft3dflow.domain(id).changeWeir2D=0;

%% Open boundaries
handles.model.delft3dflow.domain(id).nrOpenBoundaries=0;
handles.model.delft3dflow.domain(id).openBoundaries=[];
handles.model.delft3dflow.domain(id).openBoundaryNames={''};
handles.model.delft3dflow.domain(id).openBoundaries(1).M1=[];
handles.model.delft3dflow.domain(id).openBoundaries(1).M2=[];
handles.model.delft3dflow.domain(id).openBoundaries(1).N1=[];
handles.model.delft3dflow.domain(id).openBoundaries(1).N2=[];
handles.model.delft3dflow.domain(id).openBoundaries(1).name='';
handles.model.delft3dflow.domain(id).openBoundaries(1).type='Z';
handles.model.delft3dflow.domain(id).openBoundaries(1).forcing='A';
handles.model.delft3dflow.domain(id).openBoundaries(1).profile='uniform';
handles.model.delft3dflow.domain(id).openBoundaries(1).alpha=0;
handles.model.delft3dflow.domain(id).activeOpenBoundary=1;
handles.model.delft3dflow.domain(id).activeOpenBoundaries=1;
handles.model.delft3dflow.domain(id).profileTexts={'Uniform','Logarithmic','Per Layer'};
handles.model.delft3dflow.domain(id).profileOptions={'uniform','logarithmic','3d-profile'};
handles.model.delft3dflow.domain(id).addOpenBoundary=0;
handles.model.delft3dflow.domain(id).selectOpenBoundary=0;
handles.model.delft3dflow.domain(id).deleteOpenBoundary=0;
handles.model.delft3dflow.domain(id).changeOpenBoundary=0;
handles.model.delft3dflow.domain(id).activeBoundaryType='Z';
handles.model.delft3dflow.domain(id).activeBoundaryForcing='A';

handles.model.delft3dflow.domain(id).bctLoaded=0;
handles.model.delft3dflow.domain(id).bccLoaded=0;
handles.model.delft3dflow.domain(id).bctChanged=0;
handles.model.delft3dflow.domain(id).bccChanged=0;

handles.model.delft3dflow.domain(id).nrAstro=0;
handles.model.delft3dflow.domain(id).nrHarmo=0;
handles.model.delft3dflow.domain(id).nrTime=0;
handles.model.delft3dflow.domain(id).nrCor=0;

%% Drogues
handles.model.delft3dflow.domain(id).nrDrogues=0;
handles.model.delft3dflow.domain(id).activeDrogue=1;
handles.model.delft3dflow.domain(id).drogueNames={''};
handles.model.delft3dflow.domain(id).activeDrogue=1;
handles.model.delft3dflow.domain(id).drogues(1).name='';
handles.model.delft3dflow.domain(id).drogues(1).M=[];
handles.model.delft3dflow.domain(id).drogues(1).N=[];
handles.model.delft3dflow.domain(id).drogues(1).releaseTime=floor(now);
handles.model.delft3dflow.domain(id).drogues(1).recoveryTime=floor(now)+2;
handles.model.delft3dflow.domain(id).addDrogue=0;
handles.model.delft3dflow.domain(id).selectDrogue=0;
handles.model.delft3dflow.domain(id).deleteDrogue=0;
handles.model.delft3dflow.domain(id).changeDrogue=0;

%% Files
handles.model.delft3dflow.domain(id).grdFile='';
handles.model.delft3dflow.domain(id).encFile='';
handles.model.delft3dflow.domain(id).depFile='';
handles.model.delft3dflow.domain(id).dryFile='';
handles.model.delft3dflow.domain(id).thdFile='';
handles.model.delft3dflow.domain(id).crsFile='';
handles.model.delft3dflow.domain(id).droFile='';
handles.model.delft3dflow.domain(id).iniFile='';
handles.model.delft3dflow.domain(id).rstId='';
handles.model.delft3dflow.domain(id).trimId='';
handles.model.delft3dflow.domain(id).bndFile='';
handles.model.delft3dflow.domain(id).bchFile='';
handles.model.delft3dflow.domain(id).bctFile='';
handles.model.delft3dflow.domain(id).bcqFile='';
handles.model.delft3dflow.domain(id).bccFile='';
handles.model.delft3dflow.domain(id).bcaFile='';
handles.model.delft3dflow.domain(id).bc0File='';
handles.model.delft3dflow.domain(id).corFile='';
handles.model.delft3dflow.domain(id).obsFile='';
handles.model.delft3dflow.domain(id).crsFile='';
handles.model.delft3dflow.domain(id).rghFile='';
handles.model.delft3dflow.domain(id).edyFile='';
handles.model.delft3dflow.domain(id).srcFile='';
handles.model.delft3dflow.domain(id).disFile='';
handles.model.delft3dflow.domain(id).w2dFile='';
handles.model.delft3dflow.domain(id).z0lFile='';

handles.model.delft3dflow.domain(id).MMax=0;
handles.model.delft3dflow.domain(id).NMax=0;
handles.model.delft3dflow.domain(id).lastKMax=1;
handles.model.delft3dflow.domain(id).KMax=1;
handles.model.delft3dflow.domain(id).depth=[];
handles.model.delft3dflow.domain(id).gridX=[];
handles.model.delft3dflow.domain(id).gridY=[];
handles.model.delft3dflow.domain(id).gridY=[];
handles.model.delft3dflow.domain(id).coordinateSystemType=handles.screenParameters.coordinateSystem.type;

handles.model.delft3dflow.domain(id).layerType='sigma';
handles.model.delft3dflow.domain(id).zBot=0;
handles.model.delft3dflow.domain(id).zTop=0;

handles.model.delft3dflow.domain(id).initialConditions='unif';
handles.model.delft3dflow.domain(id).initialConditionsFile='';

%%
function handles=ddb_initializeOtherInput(handles,id,runid)

handles.model.delft3dflow.domain(id).runid=runid;
handles.model.delft3dflow.domain(id).mdfFile=[runid '.mdf'];
handles.model.delft3dflow.domain(id).attName=handles.model.delft3dflow.domain(id).runid;

handles.model.delft3dflow.domain(id).nrAstronomicComponentSets=0;

handles.model.delft3dflow.domain(id).nrHarmonicComponents=2;
handles.model.delft3dflow.domain(id).harmonicComponents=[0.0 30.0];

handles.model.delft3dflow.domain(id).description='';

handles.model.delft3dflow.domain(id).uniformDepth=10;
handles.model.delft3dflow.domain(id).depthSource='uniform';

handles.model.delft3dflow.domain(id).fouFile='';
handles.model.delft3dflow.domain(id).sedFile='';
handles.model.delft3dflow.domain(id).morFile='';
handles.model.delft3dflow.domain(id).wndFile='';
handles.model.delft3dflow.domain(id).spwFile='';
handles.model.delft3dflow.domain(id).amuFile='';
handles.model.delft3dflow.domain(id).amvFile='';
handles.model.delft3dflow.domain(id).ampFile='';
handles.model.delft3dflow.domain(id).amtFile='';
handles.model.delft3dflow.domain(id).amcFile='';
handles.model.delft3dflow.domain(id).amrFile='';
handles.model.delft3dflow.domain(id).w2dFile='';
handles.model.delft3dflow.domain(id).wndgrd='';
handles.model.delft3dflow.domain(id).MNmaxw=[];

handles.model.delft3dflow.domain(id).nrTracers=0;
handles.model.delft3dflow.domain(id).nrConstituents=0;

handles.model.delft3dflow.domain(id).latitude=0.0;
handles.model.delft3dflow.domain(id).longitude=0.0;
handles.model.delft3dflow.domain(id).orientation=0.0;
handles.model.delft3dflow.domain(id).thick=100;
handles.model.delft3dflow.domain(id).sumLayers=100;
handles.model.delft3dflow.domain(id).uniformRoughness=1;
handles.model.delft3dflow.domain(id).uniformViscosity=1;

handles.model.delft3dflow.domain(id).zeta0=0.0;
handles.model.delft3dflow.domain(id).u0=0.0;
handles.model.delft3dflow.domain(id).v0=0.0;

handles.model.delft3dflow.domain(id).itDate=floor(now);
handles.model.delft3dflow.domain(id).startTime=floor(now);
handles.model.delft3dflow.domain(id).stopTime=floor(now)+2;
handles.model.delft3dflow.domain(id).timeStep=1.0;
handles.model.delft3dflow.domain(id).timeZone=0;
handles.model.delft3dflow.domain(id).mapStartTime=handles.model.delft3dflow.domain(id).startTime;
handles.model.delft3dflow.domain(id).mapStopTime=handles.model.delft3dflow.domain(id).stopTime;
handles.model.delft3dflow.domain(id).mapInterval=60;
handles.model.delft3dflow.domain(id).comStartTime=handles.model.delft3dflow.domain(id).startTime;
handles.model.delft3dflow.domain(id).comStopTime=handles.model.delft3dflow.domain(id).startTime;
handles.model.delft3dflow.domain(id).comInterval=0;
handles.model.delft3dflow.domain(id).hisInterval=10*handles.model.delft3dflow.domain(id).timeStep;
handles.model.delft3dflow.domain(id).rstInterval=0;
handles.model.delft3dflow.domain(id).onlineVisualisation=0;
handles.model.delft3dflow.domain(id).onlineCoupling=0;
handles.model.delft3dflow.domain(id).fourierAnalysis=0;
handles.model.delft3dflow.domain(id).airOut=0;
handles.model.delft3dflow.domain(id).heatOut=0;

handles.model.delft3dflow.domain(id).SMhydr='YYYYY';
handles.model.delft3dflow.domain(id).SMderv='YYYYYY';
handles.model.delft3dflow.domain(id).SMproc='YYYYYYYYYY';
handles.model.delft3dflow.domain(id).PMhydr='YYYYYY';    
handles.model.delft3dflow.domain(id).PMderv='YYY';       
handles.model.delft3dflow.domain(id).PMproc='YYYYYYYYYY';
handles.model.delft3dflow.domain(id).SHhydr='YYYY';      
handles.model.delft3dflow.domain(id).SHderv='YYYYY';     
handles.model.delft3dflow.domain(id).SHproc='YYYYYYYYYY';
handles.model.delft3dflow.domain(id).SHflux='YYYY';      
handles.model.delft3dflow.domain(id).PHhydr='YYYYYY';    
handles.model.delft3dflow.domain(id).PHderv='YYY';       
handles.model.delft3dflow.domain(id).PHproc='YYYYYYYYYY';
handles.model.delft3dflow.domain(id).PHflux='YYYY';      

handles.model.delft3dflow.domain(id).storeglm=0;

handles.model.delft3dflow.domain(id).salinity.include=0;
handles.model.delft3dflow.domain(id).temperature.include=0;
handles.model.delft3dflow.domain(id).tracers=0;
handles.model.delft3dflow.domain(id).wind=0;
handles.model.delft3dflow.domain(id).waves=0;
handles.model.delft3dflow.domain(id).onlineWave=0;
handles.model.delft3dflow.domain(id).waqmod=0;
handles.model.delft3dflow.domain(id).roller.include=0;
handles.model.delft3dflow.domain(id).secondaryFlow=0;
handles.model.delft3dflow.domain(id).tidalForces=0;
handles.model.delft3dflow.domain(id).dredging=0;
handles.model.delft3dflow.domain(id).constituents=0;

%% Tidal forces
handles.model.delft3dflow.domain(id).tidalForce.M2=0;
handles.model.delft3dflow.domain(id).tidalForce.S2=0;
handles.model.delft3dflow.domain(id).tidalForce.N2=0;
handles.model.delft3dflow.domain(id).tidalForce.K2=0;
handles.model.delft3dflow.domain(id).tidalForce.K1=0;
handles.model.delft3dflow.domain(id).tidalForce.O1=0;
handles.model.delft3dflow.domain(id).tidalForce.P1=0;
handles.model.delft3dflow.domain(id).tidalForce.Q1=0;
handles.model.delft3dflow.domain(id).tidalForce.MF=0;
handles.model.delft3dflow.domain(id).tidalForce.MM=0;
handles.model.delft3dflow.domain(id).tidalForce.SSA=0;

handles.model.delft3dflow.domain(id).latitude=0.0;
handles.model.delft3dflow.domain(id).orientation=0.0;
handles.model.delft3dflow.domain(id).g=9.81;
handles.model.delft3dflow.domain(id).rhoW=1000.0;
%Alph0 = [.]
handles.model.delft3dflow.domain(id).tempW=15;
handles.model.delft3dflow.domain(id).salW=31;
handles.model.delft3dflow.domain(id).rouWav='FR84';
handles.model.delft3dflow.domain(id).windStressCoefficients=[1.0000000e-003;3.0000000e-003];
handles.model.delft3dflow.domain(id).windStressSpeeds=[0.0000000e+000;2.5000000e+001];
handles.model.delft3dflow.domain(id).nrWindStressBreakpoints=2;
handles.model.delft3dflow.domain(id).windType='uniform';
handles.model.delft3dflow.domain(id).wndInt='Y';
handles.model.delft3dflow.domain(id).rhoAir=1.15;
handles.model.delft3dflow.domain(id).betaC=0.5;
handles.model.delft3dflow.domain(id).equili=0;
handles.model.delft3dflow.domain(id).verticalTurbulenceModel='K-epsilon';
handles.model.delft3dflow.domain(id).temint=1;
handles.model.delft3dflow.domain(id).roughnessType='M';
handles.model.delft3dflow.domain(id).uRoughness=0.02;
handles.model.delft3dflow.domain(id).vRoughness=0.02;
handles.model.delft3dflow.domain(id).xlo=0;
handles.model.delft3dflow.domain(id).vicoUV=1;
handles.model.delft3dflow.domain(id).dicoUV=1;
handles.model.delft3dflow.domain(id).HLES=0;
handles.model.delft3dflow.domain(id).vicoWW=1.0e-6;
handles.model.delft3dflow.domain(id).dicoWW=1.0e-6;
handles.model.delft3dflow.domain(id).irov=0;
handles.model.delft3dflow.domain(id).z0v=0.0;
handles.model.delft3dflow.domain(id).sedFile='';
handles.model.delft3dflow.domain(id).morFile='';
handles.model.delft3dflow.domain(id).iter=2;
handles.model.delft3dflow.domain(id).dryFlp=1;
handles.model.delft3dflow.domain(id).dpsOpt='MAX';
handles.model.delft3dflow.domain(id).dpuOpt='MEAN';
handles.model.delft3dflow.domain(id).dpuOptions={'MEAN','MIN','UPW','MOR','MEAN_DPS'};
handles.model.delft3dflow.domain(id).dryFlc=0.1;
handles.model.delft3dflow.domain(id).dco=-999.0;
handles.model.delft3dflow.domain(id).dgcuni=1000.0;
handles.model.delft3dflow.domain(id).smoothingTime=60.0;
handles.model.delft3dflow.domain(id).thetQH=0;
handles.model.delft3dflow.domain(id).forresterHor=0;
handles.model.delft3dflow.domain(id).forresterVer=0;
handles.model.delft3dflow.domain(id).sigmaCorrection=0;
handles.model.delft3dflow.domain(id).traSol='Cyclic-method';
handles.model.delft3dflow.domain(id).momSol='Cyclic';
handles.model.delft3dflow.domain(id).onlineVisualisation=0;
handles.model.delft3dflow.domain(id).onlineWave=0;
handles.model.delft3dflow.domain(id).nudge=0;
handles.model.delft3dflow.domain(id).ocorio=1;

% Heat model
handles.model.delft3dflow.domain(id).kTemp=0;
handles.model.delft3dflow.domain(id).fClou=0;
handles.model.delft3dflow.domain(id).sArea=0;
handles.model.delft3dflow.domain(id).timeZoneSolarRadiation=0;
handles.model.delft3dflow.domain(id).secchi=3;
handles.model.delft3dflow.domain(id).stanton=0.0013;
handles.model.delft3dflow.domain(id).dalton=0.0013;

% HLES stuff
handles.model.delft3dflow.domain(id).Htural=1.6666660e+000;
handles.model.delft3dflow.domain(id).Hturnd=2;
handles.model.delft3dflow.domain(id).Hturst=7.0000000e-001;
handles.model.delft3dflow.domain(id).Hturlp=3.3333330e-001;
handles.model.delft3dflow.domain(id).Hturrt=6.0000000e+001;
handles.model.delft3dflow.domain(id).Hturdm=0.0000000e+000;
handles.model.delft3dflow.domain(id).Hturel=1;

% Initial Condition Options
handles.model.delft3dflow.domain(id).waterLevel.ICOpt='unif';
handles.model.delft3dflow.domain(id).waterLevel.ICConst=0;
handles.model.delft3dflow.domain(id).waterLevel.ICPar=0;
handles.model.delft3dflow.domain(id).velocity.ICOpt='Constant';
handles.model.delft3dflow.domain(id).velocity.ICPar=[0 0 ; 100 0];
handles.model.delft3dflow.domain(id).velocity.ICConst=0;

% Wind
handles=ddb_initializeWind(handles,id);
handles.model.delft3dflow.domain(id).pAvBnd=-999;

% Constituents
handles=ddb_initializeSalinity(handles,id);
handles=ddb_initializeTemperature(handles,id);

handles.model.delft3dflow.domain(id).tracer=[];
%for i=1:handles.model.delft3dflow.domain(id).nrTracers
for ii=1:5
    handles.model.delft3dflow.domain(id).tracer(ii).name=['Tracer ' num2str(ii)];
    handles=ddb_initializeTracer(handles,id,ii);
end
handles.model.delft3dflow.domain(id).cstBnd=0;

%% Morphology
handles=ddb_Delft3DFLOW_initializeMorphology(handles,id);

%% Sediments
handles.model.delft3dflow.domain(id).nrSediments=0;
handles.model.delft3dflow.domain(id).sediment=[];
% handles.model.delft3dflow.domain(id).sediment(1).name='Sediment sand';
% handles.model.delft3dflow.domain(id).sediment(1).type='non-cohesive';
handles.model.delft3dflow.domain(id).sediments=[];
handles.model.delft3dflow.domain(id).sediments.include=0;
handles.model.delft3dflow.domain(id).sediments.cRef=1600;
handles.model.delft3dflow.domain(id).sediments.iOpSus=0;
handles.model.delft3dflow.domain(id).sediments.sedimentNames={''};
handles.model.delft3dflow.domain(id).sediments.activeSediment=1;
for ii=1:5
    handles.model.delft3dflow.domain(id).sediment(ii).name=['Sediment ' num2str(ii)];
    handles.model.delft3dflow.domain(id).sediment(ii).type='non-cohesive';
    handles=ddb_initializeSediment(handles,id,ii);
end
handles.model.delft3dflow.domain(id).trafrm='';

%% Roller Model
handles.model.delft3dflow.domain(id).roller.snellius=0;
handles.model.delft3dflow.domain(id).roller.gamDis=0.7;
handles.model.delft3dflow.domain(id).roller.betaRo=0.05;
handles.model.delft3dflow.domain(id).roller.fLam=-2;
handles.model.delft3dflow.domain(id).roller.thr=0.01;

%% Trachytopes
handles.model.delft3dflow.domain(id).trachy.traFrm='';
handles.model.delft3dflow.domain(id).trachy.trtrou=0;
handles.model.delft3dflow.domain(id).trachy.trtdef='';
handles.model.delft3dflow.domain(id).trachy.trtu='';
handles.model.delft3dflow.domain(id).trachy.trtv='';
handles.model.delft3dflow.domain(id).trachy.trtDt=0;

%% Fourier analysis
handles.model.delft3dflow.domain(id).fourier.parameterList={'water level','velocity','discharge'};
handles.model.delft3dflow.domain(id).fourier.pList={'wl','uv','qf'};
handles.model.delft3dflow.domain(id).fourier.optionList={'fourier','max','min','ellipse'};
handles.model.delft3dflow.domain(id).fourier.tableOption='generate';
handles.model.delft3dflow.domain(id).fourier.include=0;
handles.model.delft3dflow.domain(id).fourier.fouFile='';

% Edit table
handles.model.delft3dflow.domain(id).fourier.editTable.parameterNumber=1;
handles.model.delft3dflow.domain(id).fourier.editTable.startTime=floor(now);
handles.model.delft3dflow.domain(id).fourier.editTable.stopTime=floor(now)+1;
handles.model.delft3dflow.domain(id).fourier.editTable.nrCycles=1;
handles.model.delft3dflow.domain(id).fourier.editTable.nodalAmplificationFactor=1;
handles.model.delft3dflow.domain(id).fourier.editTable.astronomicalArgument=0;
handles.model.delft3dflow.domain(id).fourier.editTable.layer=1;
handles.model.delft3dflow.domain(id).fourier.editTable.max=0;
handles.model.delft3dflow.domain(id).fourier.editTable.min=0;
handles.model.delft3dflow.domain(id).fourier.editTable.ellipse=0;
handles.model.delft3dflow.domain(id).fourier.editTable.option=1;

handles.model.delft3dflow.domain(id).fourier.generateTable.parameterNumber=1;
handles.model.delft3dflow.domain(id).fourier.generateTable.astronomicalComponents='M2';
handles.model.delft3dflow.domain(id).fourier.generateTable.componentNumber=1;
handles.model.delft3dflow.domain(id).fourier.generateTable.layer=1;
handles.model.delft3dflow.domain(id).fourier.generateTable.fourier=1;
handles.model.delft3dflow.domain(id).fourier.generateTable.max=0;
handles.model.delft3dflow.domain(id).fourier.generateTable.min=0;
handles.model.delft3dflow.domain(id).fourier.generateTable.ellipse=0;

handles.model.delft3dflow.domain(id).fourier.layerList{1}='1';
handles.model.delft3dflow.domain(id).fourier.spinUpTime=1440;

tt=t_getconsts;
handles.model.delft3dflow.domain(id).fourier.astronomicalComponents=[];
for i=1:size(tt.name,1)
    handles.model.delft3dflow.domain(id).fourier.astronomicalComponents{i}=deblank(tt.name(i,:));
end

handles.model.delft3dflow.domain(id).thickTop=2;
handles.model.delft3dflow.domain(id).thickBot=2;
handles.model.delft3dflow.domain(id).layerOption=1;

%% WAQ input
handles.model.delft3dflow.domain(id).WAQcomStartTime=handles.model.delft3dflow.domain(id).startTime;
handles.model.delft3dflow.domain(id).WAQcomStopTime=handles.model.delft3dflow.domain(id).startTime;
handles.model.delft3dflow.domain(id).WAQcomInterval=0;
handles.model.delft3dflow.domain(id).ilAggr = {'1'};
handles.model.delft3dflow.domain(id).WaqAgg= 'active only';

handles.model.delft3dflow.domain(id).retmp=0;

