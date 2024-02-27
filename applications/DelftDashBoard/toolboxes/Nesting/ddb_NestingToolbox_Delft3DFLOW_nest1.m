function ddb_NestingToolbox_Delft3DFLOW_nest1(varargin)
%ddb_NestingToolbox_Delft3DFLOW_nest1  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_NestingToolbox_nestHD1(varargin)
%
%   Input:
%   varargin =
%
%
%
%
%   Example
%   ddb_NestingToolbox_nestHD1
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

% $Id: ddb_NestingToolbox_nestHD1.m 11472 2014-11-27 15:12:11Z ormondt $
% $Date: 2014-11-27 16:12:11 +0100 (Thu, 27 Nov 2014) $
% $Author: ormondt $
% $Revision: 11472 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/Nesting/ddb_NestingToolbox_nestHD1.m $
% $Keywords: $

%%
if isempty(varargin)
    % New tab selected
    ddb_zoomOff;
    ddb_refreshScreen;
    setInstructions({'','Click Make Observation Points in order to generate observation points in the overall grid', ...
                'The overall model domain must be selected!'});
else
    %Options selected
    opt=lower(varargin{1});
    switch opt
        case{'nesthd1'}
            nestHD1;
        case{'selectcs'}
            selectCS;
    end
end

%%
function nestHD1
    
handles=getHandles;


% Should use the nesthd1 compiled for this system if that is
% available
if exist([handles.model.delft3dflow.exedir,'nesthd1.exe'],'file'),
    exedir=handles.model.delft3dflow.exedir;
else
%    exedir=handles.toolbox.nesting.delft3dflow.dataDir;
    exedir=handles.toolbox.nesting.dataDir;
end

%% Overall model is Delft3D-FLOW

switch handles.toolbox.nesting.delft3dflow.detailmodeltype
    
    case{'delft3dflow'}
        
        %% Detail model is Delft3D-FLOW


        if isempty(handles.toolbox.nesting.delft3dflow.grdFile)
            ddb_giveWarning('text','Please first load grid file of nested model!');
            return
        end
        
        if isempty(handles.toolbox.nesting.delft3dflow.encFile)
            ddb_giveWarning('text','Please first load enclosure file of nested model!');
            return
        end
        
        if isempty(handles.toolbox.nesting.delft3dflow.bndFile)
            ddb_giveWarning('text','Please first load boundary file of nested model!');
            return
        end
        
        if isempty(handles.model.delft3dflow.domain(ad).gridX)
            ddb_giveWarning('text','Please first load or create model grid!');
            return
        end
        
        % Input arguments
        admfile=handles.toolbox.nesting.delft3dflow.admFile;
        overall.grdfile=handles.model.delft3dflow.domain(ad).grdFile;
        overall.encfile=handles.model.delft3dflow.domain(ad).encFile;
        detail.grdfile=handles.toolbox.nesting.delft3dflow.grdFile;
        detail.encfile=handles.toolbox.nesting.delft3dflow.encFile;
        detail.bndfile=handles.toolbox.nesting.delft3dflow.bndFile;
        overall.cs=handles.screenParameters.coordinateSystem;
        detail.cs.name=handles.toolbox.nesting.delft3dflow.detailmodelcsname;
        detail.cs.type=handles.toolbox.nesting.delft3dflow.detailmodelcstype;
        
        obspoints=nest1_delft3dflow_in_delft3dflow('admfile',admfile,'overall',overall,'detail',detail,'exedir',exedir);
        
        
    case{'dflowfm'}
        
        %% Detail model is DFLOW-FM
        
        if isempty(handles.toolbox.nesting.delft3dflow.extfile)
            ddb_giveWarning('text','Please first load external forcing file of nested model!');
            return
        end
        
        cs.name=handles.toolbox.nesting.delft3dflow.detailmodelcsname;
        cs.type=handles.toolbox.nesting.delft3dflow.detailmodelcstype;
        
        obspoints=nest1_dflowfm_in_delft3dflow('admfile',handles.toolbox.nesting.delft3dflow.admFile,'extfile',handles.toolbox.nesting.delft3dflow.extfile, ...
            'grdfile',handles.model.delft3dflow.domain(ad).grdFile,'encfile',handles.model.delft3dflow.domain(ad).encFile, ...
            'csoverall',handles.screenParameters.coordinateSystem,'csdetail',cs);
        
    case{'xbeach'}
        
        %% Detail model is XBeach
        
        if isempty(handles.toolbox.nesting.delft3dflow.grdFile)
            ddb_giveWarning('text','Please first load grid file of nested model!');
            return
        end
        
        if isempty(handles.model.delft3dflow.domain(ad).gridX)
            ddb_giveWarning('text','Please first load or create model grid!');
            return
        end
        
        % Assuming gridform=delft3d
        
        % Input arguments
        admfile=handles.toolbox.nesting.delft3dflow.admFile;
        
        overall.grdfile=handles.model.delft3dflow.domain(ad).grdFile;
        overall.encfile=handles.model.delft3dflow.domain(ad).encFile;
        detail.grdfile=handles.toolbox.nesting.delft3dflow.grdFile;
        detail.encfile=[];
        detail.bndfile=[];
        overall.cs=handles.screenParameters.coordinateSystem;
        detail.cs.name=handles.toolbox.nesting.delft3dflow.detailmodelcsname;
        detail.cs.type=handles.toolbox.nesting.delft3dflow.detailmodelcstype;
        
        obspoints=ddb_nesthd1_xbeach_in_delft3dflow('admfile',admfile,'overall',overall,'detail',detail,'exedir',exedir);
        
    case{'sfincs'}
        
        %% Detail model is SFINCS
        
        if isempty(handles.toolbox.nesting.delft3dflow.sfincs_flow_bnd_file)
            ddb_giveWarning('text','Please first load boundary file of nested model!');
            return
        end

        overall.grdfile=handles.model.delft3dflow.domain(ad).grdFile;
        overall.encfile=handles.model.delft3dflow.domain(ad).encFile;
        overall.cs=handles.screenParameters.coordinateSystem;

        detail.bndfile=handles.toolbox.nesting.delft3dflow.sfincs_flow_bnd_file;
        detail.cs.name=handles.toolbox.nesting.delft3dflow.detailmodelcsname;
        detail.cs.type=handles.toolbox.nesting.delft3dflow.detailmodelcstype;

        admfile=handles.toolbox.nesting.delft3dflow.admFile;
        
        obspoints=nest1_sfincs_in_delft3dflow('overall',overall,'detail',detail,'admfile',admfile);
        
end

%% Now add observation points to Delft3D-FLOW structure

k=handles.model.delft3dflow.domain(ad).nrObservationPoints;
for i=1:length(obspoints)
    % Check if observation point already exists
    nm=deblank(obspoints(i).name);
    ii=strmatch(nm,handles.model.delft3dflow.domain(ad).observationPointNames,'exact');
    if isempty(ii)
        % Observation point does not yet exist
        k=k+1;
        handles.model.delft3dflow.domain(ad).observationPoints(k).name=nm;
        handles.model.delft3dflow.domain(ad).observationPoints(k).M=obspoints(i).m;
        handles.model.delft3dflow.domain(ad).observationPoints(k).N=obspoints(i).n;
        handles.model.delft3dflow.domain(ad).observationPoints(k).x=handles.model.delft3dflow.domain(ad).gridXZ(obspoints(i).m,obspoints(i).n);
        handles.model.delft3dflow.domain(ad).observationPoints(k).y=handles.model.delft3dflow.domain(ad).gridYZ(obspoints(i).m,obspoints(i).n);
        handles.model.delft3dflow.domain(ad).observationPointNames{k}=handles.model.delft3dflow.domain(ad).observationPoints(k).name;
    end
end

handles.model.delft3dflow.domain(ad).nrObservationPoints=length(handles.model.delft3dflow.domain(ad).observationPoints);

[filename, pathname, filterindex] = uiputfile('*.obs', 'Select Observations File',handles.model.delft3dflow.domain(ad).obsFile);
if filename~=0
    [path,name,ext]=fileparts(filename);
    handles.model.delft3dflow.domain(ad).obsFile=[name '.obs'];
    ddb_saveObsFile(handles,ad);
end

handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','observationpoints','domain',ad,'visible',1,'active',0);

setHandles(handles);
  

%%
function selectCS

handles=getHandles;

% Open GUI to select data set

[cs,type,nr,ok]=ddb_selectCoordinateSystem(handles.coordinateData,handles.EPSG,'default','WGS 84','type','both','defaulttype','geographic');

if ok    
    handles.toolbox.nesting.delft3dflow.detailmodelcsname=cs;
    handles.toolbox.nesting.delft3dflow.detailmodelcstype=type;    
    setHandles(handles);
end

gui_updateActiveTab;

