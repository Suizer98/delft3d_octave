function ddb_NestingToolbox_DFlowFM_nest1(varargin)
%DDB_NESTINGTOOLBOX_NESTHD1  One line description goes here.
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

% $Id: ddb_NestingToolbox_DFlowFM_nest1.m 15807 2019-10-04 06:00:45Z ormondt $
% $Date: 2019-10-04 14:00:45 +0800 (Fri, 04 Oct 2019) $
% $Author: ormondt $
% $Revision: 15807 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/Nesting/ddb_NestingToolbox_DFlowFM_nest1.m $
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

%% Overall model is DFLOW-FM

switch handles.toolbox.nesting.dflowfm.detailmodeltype
    
    case{'delft3dflow'}
        
        %% Detail model is Delft3D-FLOW
        
        if isempty(handles.toolbox.nesting.dflowfm.grdFile)
            ddb_giveWarning('text','Please first load grid file of nested model!');
            return
        end
        
        if isempty(handles.toolbox.nesting.dflowfm.encFile)
            ddb_giveWarning('text','Please first load enclosure file of nested model!');
            return
        end
        
        if isempty(handles.toolbox.nesting.dflowfm.bndFile)
            ddb_giveWarning('text','Please first load boundary file of nested model!');
            return
        end
        
        cs.name=handles.toolbox.nesting.dflowfm.detailmodelcsname;
        cs.type=handles.toolbox.nesting.dflowfm.detailmodelcstype;
        
        newpoints=nest1_delft3dflow_in_dflowfm('grdfile',handles.toolbox.nesting.dflowfm.grdFile, ...
            'encfile',handles.toolbox.nesting.dflowfm.encFile, ...
            'bndfile',handles.toolbox.nesting.dflowfm.bndFile, ...
            'csoverall',handles.screenParameters.coordinateSystem,'csdetail',cs);
        
        if ~isempty(newpoints)
            
            k=handles.model.dflowfm.domain(ad).nrobservationpoints;
            
            for ip=1:length(newpoints)
                handles.model.dflowfm.domain(ad).observationpoints(ip+k).name=newpoints(ip).name;
                handles.model.dflowfm.domain(ad).observationpoints(ip+k).x=newpoints(ip).x;
                handles.model.dflowfm.domain(ad).observationpoints(ip+k).y=newpoints(ip).y;
                handles.model.dflowfm.domain(ad).observationpointnames{ip+k}=newpoints(ip).name;
            end
            
            handles.model.dflowfm.domain(ad).nrobservationpoints=k+length(newpoints);
            
            [filename, pathname, filterindex] = uiputfile('*.xyn', 'Observation File Name',[handles.model.dflowfm.domain(ad).attName '.xyn']);
            if pathname~=0
                %                        ddb_DFlowFM_addTideStations;
                %                        handles=getHandles;
                handles.model.dflowfm.domain(ad).obsfile=filename;
                ddb_DFlowFM_saveObsFile(handles,ad);
                handles=ddb_DFlowFM_plotObservationPoints(handles,'plot','visible',1,'active',0);
                setHandles(handles);
            end
            
        end
        
    case{'dflowfm'}
        
        %% Detail model is DFLOW-FM
        
        if isempty(handles.toolbox.nesting.dflowfm.extfile)
            ddb_giveWarning('text','Please first load external forcing file of nested model!');
            return
        end
        
        cs.name=handles.toolbox.nesting.dflowfm.detailmodelcsname;
        cs.type=handles.toolbox.nesting.dflowfm.detailmodelcstype;
        
        newpoints=nest1_dflowfm_in_dflowfm('extfile',handles.toolbox.nesting.dflowfm.extfile, ...
            'csoverall',handles.screenParameters.coordinateSystem,'csdetail',cs, ...
            'admfile',handles.toolbox.nesting.dflowfm.admFile);
        
        if ~isempty(newpoints)
            
            k=handles.model.dflowfm.domain(ad).nrobservationpoints;
            
            for ip=1:length(newpoints)
                handles.model.dflowfm.domain(ad).observationpoints(ip+k).name=newpoints(ip).name;
                handles.model.dflowfm.domain(ad).observationpoints(ip+k).x=newpoints(ip).x;
                handles.model.dflowfm.domain(ad).observationpoints(ip+k).y=newpoints(ip).y;
                handles.model.dflowfm.domain(ad).observationpointnames{ip+k}=newpoints(ip).name;
            end
            
            handles.model.dflowfm.domain(ad).nrobservationpoints=k+length(newpoints);
            
            [filename, pathname, filterindex] = uiputfile('*.xyn', 'Observation File Name',[handles.model.dflowfm.domain(ad).attName '.xyn']);
            if pathname~=0
                %                        ddb_DFlowFM_addTideStations;
                %                        handles=getHandles;
                handles.model.dflowfm.domain(ad).obsfile=filename;
                ddb_DFlowFM_saveObsFile(handles,ad);
                handles=ddb_DFlowFM_plotObservationPoints(handles,'plot','visible',1,'active',0);
                setHandles(handles);
            end
            
        end
        
        
end

%%
function selectCS

handles=getHandles;

% Open GUI to select data set

[cs,type,nr,ok]=ddb_selectCoordinateSystem(handles.coordinateData,handles.EPSG,'default','WGS 84','type','both','defaulttype','geographic');

if ok
    handles.toolbox.nesting.dflowfm.detailmodelcsname=cs;
    handles.toolbox.nesting.dflowfm.detailmodelcstype=type;    
    setHandles(handles);
end

gui_updateActiveTab;

