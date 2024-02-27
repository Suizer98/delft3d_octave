function ddb_Delft3DFLOW_observationPoints(varargin)
%DDB_DELFT3DFLOW_OBSERVATIONPOINTS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_Delft3DFLOW_observationPoints(varargin)
%
%   Input:
%   varargin =
%
%
%
%
%   Example
%   ddb_Delft3DFLOW_observationPoints
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

% $Id: ddb_Delft3DFLOW_observationPoints.m 11766 2015-03-03 14:31:39Z ormondt $
% $Date: 2015-03-03 22:31:39 +0800 (Tue, 03 Mar 2015) $
% $Author: ormondt $
% $Revision: 11766 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/models/Delft3DFLOW/gui/ddb_Delft3DFLOW_observationPoints.m $
% $Keywords: $

%%
handles=getHandles;

ddb_zoomOff;

if isempty(varargin)
    ddb_refreshScreen;
    handles.model.delft3dflow.domain(ad).addObservationPoint=0;
    handles.model.delft3dflow.domain(ad).selectObservationPoint=0;
    handles.model.delft3dflow.domain(ad).changeObservationPoint=0;
    handles.model.delft3dflow.domain(ad).deleteObservationPoint=0;
    handles=ddb_Delft3DFLOW_plotAttributes(handles,'update','observationpoints');
    setHandles(handles);    
else
    
    opt=varargin{1};
    
    switch(lower(opt))
        
        case{'add'}
            handles.model.delft3dflow.domain(ad).selectObservationPoint=0;
            handles.model.delft3dflow.domain(ad).changeObservationPoint=0;
            handles.model.delft3dflow.domain(ad).deleteObservationPoint=0;
            if handles.model.delft3dflow.domain(ad).addObservationPoint
                handles.editMode='add';
                ddb_dragLine(@addObservationPoint,'free');
                setInstructions({'','','Click point on map for new observation point(s)'});
            else
                set(gcf, 'windowbuttondownfcn',[]);
                clearInstructions;
            end
            setHandles(handles);
            
        case{'delete'}
            handles.model.delft3dflow.domain(ad).addObservationPoint=0;
            handles.model.delft3dflow.domain(ad).selectObservationPoint=0;
            handles.model.delft3dflow.domain(ad).changeObservationPoint=0;
            ddb_clickObject('tag','ObservationPoint','callback',@deleteObservationPointFromMap);
            setInstructions({'','','Select observation point from map to delete'});
            if handles.model.delft3dflow.domain(ad).deleteObservationPoint
                % Delete observation point selected from list
                handles=deleteObservationPoint(handles);
            end
            setHandles(handles);
            
        case{'select'}
            handles.model.delft3dflow.domain(ad).addObservationPoint=0;
            handles.model.delft3dflow.domain(ad).deleteObservationPoint=0;
            handles.model.delft3dflow.domain(ad).changeObservationPoint=0;
            if handles.model.delft3dflow.domain(ad).selectObservationPoint
                ddb_clickObject('tag','ObservationPoint','callback',@selectObservationPointFromMap);
                setInstructions({'','','Select observation point from map'});
            else
                set(gcf, 'windowbuttondownfcn',[]);
                clearInstructions;
            end
            setHandles(handles);
            
        case{'change'}
            handles.model.delft3dflow.domain(ad).addObservationPoint=0;
            handles.model.delft3dflow.domain(ad).selectObservationPoint=0;
            handles.model.delft3dflow.domain(ad).deleteObservationPoint=0;
            if handles.model.delft3dflow.domain(ad).changeObservationPoint
                ddb_clickObject('tag','ObservationPoint','callback',@changeObservationPointFromMap);
                setInstructions({'','','Select observation point to change from map'});
            else
                set(gcf, 'windowbuttondownfcn',[]);
                clearInstructions;
            end
            setHandles(handles);
            
        case{'edit'}
            handles.model.delft3dflow.domain(ad).addObservationPoint=0;
            handles.model.delft3dflow.domain(ad).selectObservationPoint=0;
            handles.model.delft3dflow.domain(ad).changeObservationPoint=0;
            handles.model.delft3dflow.domain(ad).deleteObservationPoint=0;
            handles.editMode='edit';
            n=handles.model.delft3dflow.domain(ad).activeObservationPoint;
            name=handles.model.delft3dflow.domain(ad).observationPoints(n).name;
            if strcmpi(handles.model.delft3dflow.domain(ad).observationPoints(n).name(1),'(')
                mstr=num2str(handles.model.delft3dflow.domain(ad).observationPoints(n).M);
                nstr=num2str(handles.model.delft3dflow.domain(ad).observationPoints(n).N);
                name=['('  mstr ',' nstr ')'];
            end
            handles.model.delft3dflow.domain(ad).observationPointNames{n}=name;
            handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','observationpoints');
            setHandles(handles);
            clearInstructions;
            
        case{'selectfromlist'}
            handles.model.delft3dflow.domain(ad).addObservationPoint=0;
            handles.model.delft3dflow.domain(ad).selectObservationPoint=0;
            handles.model.delft3dflow.domain(ad).changeObservationPoint=0;
            % Delete selected observation point next time delete is clicked
            handles.model.delft3dflow.domain(ad).deleteObservationPoint=1;
            handles=ddb_Delft3DFLOW_plotAttributes(handles,'update','observationpoints');
            setHandles(handles);
            clearInstructions;
            
        case{'openfile'}
            handles=ddb_readObsFile(handles,ad);
            handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','observationpoints');
            setHandles(handles);
            
        case{'savefile'}
            ddb_saveObsFile(handles,ad);

        case{'addobservationpointsfromfile'}
            addObservationPointsFromFile;
            
    end
end

refreshObservationPoints;

%%
function addObservationPoint(x,y)

x1=x(1);
y1=y(1);

handles=getHandles;
% Find grid indices
[m1,n1]=findgridcell(x1,y1,handles.model.delft3dflow.domain(ad).gridX,handles.model.delft3dflow.domain(ad).gridY);
% Check if start and end are in one grid line
if ~isempty(m1)
    if m1>0
        if handles.model.delft3dflow.domain(ad).changeObservationPoint
            iac=handles.model.delft3dflow.domain(ad).activeObservationPoint;
            handles.model.delft3dflow.domain(ad).observationPoints(iac).M=m1;
            handles.model.delft3dflow.domain(ad).observationPoints(iac).N=n1;
        else
            % Add mode
            handles.model.delft3dflow.domain(ad).nrObservationPoints=handles.model.delft3dflow.domain(ad).nrObservationPoints+1;
            iac=handles.model.delft3dflow.domain(ad).nrObservationPoints;
            handles.model.delft3dflow.domain(ad).observationPoints(iac).M=m1;
            handles.model.delft3dflow.domain(ad).observationPoints(iac).N=n1;
            handles.model.delft3dflow.domain(ad).observationPoints(iac).name=['(' num2str(m1) ',' num2str(n1) ')'];
        end
        handles.model.delft3dflow.domain(ad).observationPoints(iac).x=x1;
        handles.model.delft3dflow.domain(ad).observationPoints(iac).y=y1;
        handles.model.delft3dflow.domain(ad).observationPointNames{iac}=handles.model.delft3dflow.domain(ad).observationPoints(iac).name;
        handles.model.delft3dflow.domain(ad).activeObservationPoint=iac;
        handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','observationpoints');
        setHandles(handles);
        
        if handles.model.delft3dflow.domain(ad).changeObservationPoint
            ddb_clickObject('tag','observationpoint','callback',@changeObservationPointFromMap);
            setInstructions({'','','Select observation point'});
        else
            ddb_dragLine(@addObservationPoint,'free');
            setInstructions({'','','Click position of new observation point'});
        end
    end
end
refreshObservationPoints;

%%
function addObservationPointsFromFile

handles=getHandles;

[filename, pathname, filterindex] = uigetfile('*.ann', 'Load annotation file','');
if pathname==0
    return
end

fid=fopen([pathname filename],'r');

k=0;
while 1
    tx0=fgets(fid);
    if and(ischar(tx0), size(tx0>0))
        v0=strread(tx0,'%q');
        if ~strcmp(v0{1}(1),'#')
            k=k+1;
            x(k)=str2double(v0{1});
            y(k)=str2double(v0{2});
            text{k}=v0{3};
        end
    else
        break
    end
end

fclose(fid);

%[x,y]=convertCoordinates(x,y,'CS1.name','WGS 84 / UTM zone 11N','CS1.type','projected','CS2.name','WGS 84','CS2.type','geographic');

for ip=1:length(x)
    % Find grid indices
    [m1,n1]=findgridcell(x(ip),y(ip),handles.model.delft3dflow.domain(ad).gridX,handles.model.delft3dflow.domain(ad).gridY);
    % Check if start and end are in one grid line
    if ~isempty(m1)
        if m1>0
            handles.model.delft3dflow.domain(ad).nrObservationPoints=handles.model.delft3dflow.domain(ad).nrObservationPoints+1;
            iac=handles.model.delft3dflow.domain(ad).nrObservationPoints;
            handles.model.delft3dflow.domain(ad).observationPoints(iac).M=m1;
            handles.model.delft3dflow.domain(ad).observationPoints(iac).N=n1;
            handles.model.delft3dflow.domain(ad).observationPoints(iac).name=text{ip};
            handles.model.delft3dflow.domain(ad).observationPointNames{iac}=handles.model.delft3dflow.domain(ad).observationPoints(iac).name;
            handles.model.delft3dflow.domain(ad).activeObservationPoint=iac;
            handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','observationpoints');
        end
    end
end
setHandles(handles);


%%
function handles=deleteObservationPoint(handles)

nrobs=handles.model.delft3dflow.domain(ad).nrObservationPoints;

if nrobs>0
    iac=handles.model.delft3dflow.domain(ad).activeObservationPoint;
    handles=ddb_Delft3DFLOW_plotAttributes(handles,'delete','observationpoints');
    if nrobs>1
        handles.model.delft3dflow.domain(ad).observationPoints=removeFromStruc(handles.model.delft3dflow.domain(ad).observationPoints,iac);
        handles.model.delft3dflow.domain(ad).observationPointNames=removeFromCellArray(handles.model.delft3dflow.domain(ad).observationPointNames,iac);
    else
        handles.model.delft3dflow.domain(ad).observationPointNames={''};
        handles.model.delft3dflow.domain(ad).activeObservationPoint=1;
        handles.model.delft3dflow.domain(ad).observationPoints(1).name='';
        handles.model.delft3dflow.domain(ad).observationPoints(1).M=[];
        handles.model.delft3dflow.domain(ad).observationPoints(1).N=[];
    end
    if iac==nrobs
        iac=nrobs-1;
    end
    handles.model.delft3dflow.domain(ad).nrObservationPoints=nrobs-1;
    handles.model.delft3dflow.domain(ad).activeObservationPoint=max(iac,1);
    handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','observationpoints');
    setHandles(handles);
    refreshObservationPoints;
end

%%
function deleteObservationPointFromMap(h)

handles=getHandles;
iac=get(h,'UserData');
handles.model.delft3dflow.domain(ad).activeObservationPoint=iac;
handles=deleteObservationPoint(handles);
setHandles(handles);

%%
function selectObservationPointFromMap(h)

handles=getHandles;
iac=get(h,'UserData');
handles.model.delft3dflow.domain(ad).activeObservationPoint=iac;
ddb_Delft3DFLOW_plotAttributes(handles,'update','observationpoints');
setHandles(handles);
refreshObservationPoints;

%%
function changeObservationPointFromMap(h)

handles=getHandles;
iac=get(h,'UserData');
handles.model.delft3dflow.domain(ad).activeObservationPoint=iac;
ddb_Delft3DFLOW_plotAttributes(handles,'update','observationPoints');
setHandles(handles);
refreshObservationPoints;
ddb_dragLine(@addObservationPoint,'free');
setInstructions({'','','Click new position of observation point'});

%%
function refreshObservationPoints
gui_updateActiveTab;
