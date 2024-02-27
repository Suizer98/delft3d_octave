function ddb_DFlowFM_observationPoints(varargin)
%ddb_DFlowFM_observationPoints  One line description goes here.

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
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

% $Id: ddb_DFlowFM_observationPoints.m 15813 2019-10-04 06:15:03Z ormondt $
% $Date: 2019-10-04 14:15:03 +0800 (Fri, 04 Oct 2019) $
% $Author: ormondt $
% $Revision: 15813 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/models/DFlowFM/gui/ddb_DFlowFM_observationPoints.m $
% $Keywords: $

%%
handles=getHandles;

ddb_zoomOff;

if isempty(varargin)
    ddb_refreshScreen;
    handles.model.dflowfm.domain(ad).addobservationpoint=0;
    handles.model.dflowfm.domain(ad).selectobservationpoint=0;
    handles.model.dflowfm.domain(ad).changeobservationpoint=0;
    handles.model.dflowfm.domain(ad).deleteobservationpoint=0;
    handles=ddb_DFlowFM_plotObservationPoints(handles,'update','active',1);
    setHandles(handles);    
else
    
    opt=varargin{1};

    % Default cloud behavior
    h=handles.model.dflowfm.domain(ad).observationpointshandle;
    clearInstructions;
    
    switch(lower(opt))
        
        case{'add'}
            % Click Add in GUI
            handles.model.dflowfm.domain(ad).deleteobservationpoint=0;
            handles.model.dflowfm.domain(ad).changeobservationpoint=0;
            if handles.model.dflowfm.domain(ad).addobservationpoint
                gui_clickpoint('xy','callback',@addObservationPoint,'multiple',1);
                setInstructions({'','','Click point on map for new observation point(s)'});
            else
                set(gcf, 'windowbuttondownfcn',[]);
            end
            setHandles(handles);
            
        case{'deletefromlist'}
            % Click Delete From List in GUI
            handles.model.dflowfm.domain(ad).addobservationpoint=0;
            handles.model.dflowfm.domain(ad).changeobservationpoint=0;
            handles.model.dflowfm.domain(ad).deleteobservationpoint=0;
            set(gcf, 'windowbuttondownfcn',[]);
            % Delete observation point selected from list
            handles=deleteObservationPoint(handles);
            setHandles(handles);

        case{'deletefrommap'}
            % Click Delete From Map in GUI
            handles.model.dflowfm.domain(ad).addobservationpoint=0;
            handles.model.dflowfm.domain(ad).changeobservationpoint=0;
            set(gcf, 'windowbuttondownfcn',[]);
            if handles.model.dflowfm.domain(ad).deleteobservationpoint
                setInstructions({'','','Select observation point to delete from map'});
            end
            setHandles(handles);
            
        case{'change'}
            % Click Change in GUI
            handles.model.dflowfm.domain(ad).addobservationpoint=0;
            handles.model.dflowfm.domain(ad).deleteobservationpoint=0;
            set(gcf, 'windowbuttondownfcn',[]);
            if handles.model.dflowfm.domain(ad).changeobservationpoint
                setInstructions({'','','Select observation point on map to change'});
                
            end
            setHandles(handles);
            
        case{'edit'}
            % Edit something in GUI
            handles.model.dflowfm.domain(ad).addobservationpoint=0;
            handles.model.dflowfm.domain(ad).changeobservationpoint=0;
            handles.model.dflowfm.domain(ad).deleteobservationpoint=0;
            set(gcf, 'windowbuttondownfcn',[]);
            n=handles.model.dflowfm.domain(ad).activeobservationpoint;
            name=handles.model.dflowfm.domain(ad).observationpoints(n).name;
            handles.model.dflowfm.domain(ad).observationpointnames{n}=name;
            h=handles.model.dflowfm.domain(ad).observationpointshandle;
            
            for ii=1:length(handles.model.dflowfm.domain(ad).observationpoints)
                xy(ii,1)=handles.model.dflowfm.domain(ad).observationpoints(ii).x;
                xy(ii,2)=handles.model.dflowfm.domain(ad).observationpoints(ii).y;
            end
            gui_pointcloud(h,'change','xy',xy,'text',handles.model.dflowfm.domain(ad).observationpointnames);
            setHandles(handles);
            
        case{'selectfromlist'}
            handles.model.dflowfm.domain(ad).addobservationpoint=0;
            handles.model.dflowfm.domain(ad).changeobservationpoint=0;
            handles.model.dflowfm.domain(ad).deleteobservationpoint=0;
            set(gcf, 'windowbuttondownfcn',[]);
            % Delete selected observation point next time delete is clicked
            handles.model.dflowfm.domain(ad).deleteobservationpoint=0;
            h=handles.model.dflowfm.domain(ad).observationpointshandle;
            gui_pointcloud(h,'change','activepoint',handles.model.dflowfm.domain(ad).activeobservationpoint);
            setHandles(handles);
            clearInstructions;

        case{'selectfrommap'}
            iac=varargin{3};
            handles.model.dflowfm.domain(ad).activeobservationpoint=iac;
            if handles.model.dflowfm.domain(ad).deleteobservationpoint
                % Delete selected point
                handles=deleteObservationPoint(handles);
            elseif handles.model.dflowfm.domain(ad).changeobservationpoint
                % Change selected point
                gui_clickpoint('xy','callback',@addObservationPoint,'multiple',0);
                setInstructions({'','','Click new point on map for this observation point'});
            end
            setHandles(handles);
            
        case{'openfile'}
            handles.model.dflowfm.domain(ad).addobservationpoint=0;
            set(gcf, 'windowbuttondownfcn',[]);
            handles.model.dflowfm.domain(ad).changeobservationpoint=0;
            handles.model.dflowfm.domain(ad).deleteobservationpoint=0;
            handles=ddb_DFlowFM_readObsFile(handles,ad);
            handles=ddb_DFlowFM_plotObservationPoints(handles,'plot','active',1);
            setHandles(handles);
            
        case{'savefile'}
            handles.model.dflowfm.domain(ad).addobservationpoint=0;
            set(gcf, 'windowbuttondownfcn',[]);
            handles.model.dflowfm.domain(ad).changeobservationpoint=0;
            handles.model.dflowfm.domain(ad).deleteobservationpoint=0;
            ddb_DFlowFM_saveObsFile(handles,ad);
            
    end
end

refreshObservationPoints;

%%
function addObservationPoint(x,y)

x1=x(1);
y1=y(1);

handles=getHandles;

if handles.model.dflowfm.domain(ad).changeobservationpoint
    iac=handles.model.dflowfm.domain(ad).activeobservationpoint;
    set(gcf, 'windowbuttondownfcn',[]);
else
    % Add mode
    handles.model.dflowfm.domain(ad).nrobservationpoints=handles.model.dflowfm.domain(ad).nrobservationpoints+1;
    iac=handles.model.dflowfm.domain(ad).nrobservationpoints;
    handles.model.dflowfm.domain(ad).observationpoints(iac).name=['obspoint ' num2str(iac)];
    handles.model.dflowfm.domain(ad).observationpointnames{iac}=handles.model.dflowfm.domain(ad).observationpoints(iac).name;
end

handles.model.dflowfm.domain(ad).observationpoints(iac).x=x1;
handles.model.dflowfm.domain(ad).observationpoints(iac).y=y1;
handles.model.dflowfm.domain(ad).activeobservationpoint=iac;

handles=ddb_DFlowFM_plotObservationPoints(handles,'plot','active',1);
setHandles(handles);

refreshObservationPoints;

%%
function handles=deleteObservationPoint(handles)

nrobs=handles.model.dflowfm.domain(ad).nrobservationpoints;

if nrobs>0
    iac=handles.model.dflowfm.domain(ad).activeobservationpoint;
    handles=ddb_DFlowFM_plotObservationPoints(handles,'delete','observationpoints');
    if nrobs>1
        handles.model.dflowfm.domain(ad).observationpoints=removeFromStruc(handles.model.dflowfm.domain(ad).observationpoints,iac);
        handles.model.dflowfm.domain(ad).observationpointnames=removeFromCellArray(handles.model.dflowfm.domain(ad).observationpointnames,iac);
    else
        handles.model.dflowfm.domain(ad).observationpointnames={''};
        handles.model.dflowfm.domain(ad).activeobservationpoint=1;
        handles.model.dflowfm.domain(ad).observationpoints(1).x=NaN;
        handles.model.dflowfm.domain(ad).observationpoints(1).y=NaN;
    end
    if iac==nrobs
        iac=nrobs-1;
    end
    handles.model.dflowfm.domain(ad).nrobservationpoints=nrobs-1;
    handles.model.dflowfm.domain(ad).activeobservationpoint=max(iac,1);
    handles=ddb_DFlowFM_plotObservationPoints(handles,'plot','active',1);
    setHandles(handles);
    refreshObservationPoints;
end

%%
function refreshObservationPoints
gui_updateActiveTab;
