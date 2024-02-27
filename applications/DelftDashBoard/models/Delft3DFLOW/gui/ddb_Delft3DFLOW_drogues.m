function ddb_Delft3DFLOW_drogues(varargin)
%DDB_DELFT3DFLOW_DROGUES  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_Delft3DFLOW_drogues(varargin)
%
%   Input:
%   varargin =
%
%
%
%
%   Example
%   ddb_Delft3DFLOW_drogues
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

% $Id: ddb_Delft3DFLOW_drogues.m 10447 2014-03-26 07:06:47Z ormondt $
% $Date: 2014-03-26 15:06:47 +0800 (Wed, 26 Mar 2014) $
% $Author: ormondt $
% $Revision: 10447 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/models/Delft3DFLOW/gui/ddb_Delft3DFLOW_drogues.m $
% $Keywords: $

%%
handles=getHandles;

ddb_zoomOff;

if isempty(varargin)
    ddb_refreshScreen;
    handles.model.delft3dflow.domain(ad).addDrogue=0;
    handles.model.delft3dflow.domain(ad).selectDrogue=0;
    handles.model.delft3dflow.domain(ad).changeDrogue=0;
    handles.model.delft3dflow.domain(ad).deleteDrogue=0;
    handles=ddb_Delft3DFLOW_plotAttributes(handles,'update','drogues');
    setHandles(handles);    
else
    
    opt=varargin{1};
    
    switch(lower(opt))
        
        case{'add'}
            handles.model.delft3dflow.domain(ad).selectDrogue=0;
            handles.model.delft3dflow.domain(ad).changeDrogue=0;
            handles.model.delft3dflow.domain(ad).deleteDrogue=0;
            if handles.model.delft3dflow.domain(ad).addDrogue
                handles.editMode='add';
                ddb_dragLine(@addDrogue,'free');
                setInstructions({'','','Click point on map for new drogue(s)'});
            else
                set(gcf, 'windowbuttondownfcn',[]);
                clearInstructions;
            end
            setHandles(handles);
            
        case{'delete'}
            handles.model.delft3dflow.domain(ad).addDrogue=0;
            handles.model.delft3dflow.domain(ad).selectDrogue=0;
            handles.model.delft3dflow.domain(ad).changeDrogue=0;
            ddb_clickObject('tag','Drogue','callback',@deleteDrogueFromMap);
            setInstructions({'','','Select drogue from map to delete'});
            if handles.model.delft3dflow.domain(ad).deleteDrogue
                % Delete drogue selected from list
                handles=deleteDrogue(handles);
            end
            setHandles(handles);
            
        case{'select'}
            handles.model.delft3dflow.domain(ad).addDrogue=0;
            handles.model.delft3dflow.domain(ad).deleteDrogue=0;
            handles.model.delft3dflow.domain(ad).changeDrogue=0;
            if handles.model.delft3dflow.domain(ad).selectDrogue
                ddb_clickObject('tag','Drogue','callback',@selectDrogueFromMap);
                setInstructions({'','','Select drogue from map'});
            else
                set(gcf, 'windowbuttondownfcn',[]);
                clearInstructions;
            end
            setHandles(handles);
            
        case{'change'}
            handles.model.delft3dflow.domain(ad).addDrogue=0;
            handles.model.delft3dflow.domain(ad).selectDrogue=0;
            handles.model.delft3dflow.domain(ad).deleteDrogue=0;
            if handles.model.delft3dflow.domain(ad).changeDrogue
                ddb_clickObject('tag','Drogue','callback',@changeDrogueFromMap);
                setInstructions({'','','Select drogue to change from map'});
            else
                set(gcf, 'windowbuttondownfcn',[]);
                clearInstructions;
            end
            setHandles(handles);
            
        case{'edit'}
            handles.model.delft3dflow.domain(ad).addDrogue=0;
            handles.model.delft3dflow.domain(ad).selectDrogue=0;
            handles.model.delft3dflow.domain(ad).changeDrogue=0;
            handles.model.delft3dflow.domain(ad).deleteDrogue=0;
            handles.editMode='edit';
            n=handles.model.delft3dflow.domain(ad).activeDrogue;
            name=handles.model.delft3dflow.domain(ad).drogues(n).name;
            if strcmpi(handles.model.delft3dflow.domain(ad).drogues(n).name(1),'(')
                mstr=num2str(handles.model.delft3dflow.domain(ad).drogues(n).M);
                nstr=num2str(handles.model.delft3dflow.domain(ad).drogues(n).N);
                name=['('  mstr ',' nstr ')'];
            end
            handles.model.delft3dflow.domain(ad).drogueNames{n}=name;
            handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','drogues');
            setHandles(handles);
            clearInstructions;
            
        case{'selectfromlist'}
            handles.model.delft3dflow.domain(ad).addDrogue=0;
            handles.model.delft3dflow.domain(ad).selectDrogue=0;
            handles.model.delft3dflow.domain(ad).changeDrogue=0;
            % Delete selected drogue next time delete is clicked
            handles.model.delft3dflow.domain(ad).deleteDrogue=1;
            handles=ddb_Delft3DFLOW_plotAttributes(handles,'update','drogues');
            setHandles(handles);
            clearInstructions;
            
        case{'openfile'}
            handles=ddb_readDroFile(handles);
            handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','drogues');
            setHandles(handles);
            
        case{'savefile'}
            ddb_saveDroFile(handles,ad);
            
    end
end


refreshDrogues;

%%
function addDrogue(x,y)

x1=x(1);
y1=y(1);

handles=getHandles;
% Find grid indices
[m1,n1]=findgridcell(x1,y1,handles.model.delft3dflow.domain(ad).gridX,handles.model.delft3dflow.domain(ad).gridY);
% Check if start and end are in one grid line
if ~isempty(m1)
    if m1>0
        if handles.model.delft3dflow.domain(ad).changeDrogue
            iac=handles.model.delft3dflow.domain(ad).activeDrogue;
        else
            % Add mode
            handles.model.delft3dflow.domain(ad).nrDrogues=handles.model.delft3dflow.domain(ad).nrDrogues+1;
            iac=handles.model.delft3dflow.domain(ad).nrDrogues;
        end
        handles.model.delft3dflow.domain(ad).drogues(iac).M=m1;
        handles.model.delft3dflow.domain(ad).drogues(iac).N=n1;
        handles.model.delft3dflow.domain(ad).drogues(iac).releaseTime=handles.model.delft3dflow.domain(ad).startTime;
        handles.model.delft3dflow.domain(ad).drogues(iac).recoveryTime=handles.model.delft3dflow.domain(ad).stopTime;
        handles.model.delft3dflow.domain(ad).drogues(iac).name=['(' num2str(m1) ',' num2str(n1) ')'];
        handles.model.delft3dflow.domain(ad).drogueNames{iac}=handles.model.delft3dflow.domain(ad).drogues(iac).name;
        handles.model.delft3dflow.domain(ad).activeDrogue=iac;
        handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','drogues');
        setHandles(handles);
        
        if handles.model.delft3dflow.domain(ad).changeDrogue
            ddb_clickObject('tag','drogue','callback',@changeDrogueFromMap);
            setInstructions({'','','Select drogue'});
        else
            ddb_dragLine(@addDrogue,'free');
            setInstructions({'','','Click position of new drogue'});
        end
    end
end
refreshDrogues;

%%
function handles=deleteDrogue(handles)

nrobs=handles.model.delft3dflow.domain(ad).nrDrogues;

if nrobs>0
    iac=handles.model.delft3dflow.domain(ad).activeDrogue;
    handles=ddb_Delft3DFLOW_plotAttributes(handles,'delete','drogues');
    if nrobs>1
        handles.model.delft3dflow.domain(ad).drogues=removeFromStruc(handles.model.delft3dflow.domain(ad).drogues,iac);
        handles.model.delft3dflow.domain(ad).drogueNames=removeFromCellArray(handles.model.delft3dflow.domain(ad).drogueNames,iac);
    else
        handles.model.delft3dflow.domain(ad).drogueNames={''};
        handles.model.delft3dflow.domain(ad).activeDrogue=1;
        handles.model.delft3dflow.domain(ad).drogues(1).M=[];
        handles.model.delft3dflow.domain(ad).drogues(1).N=[];
    end
    if iac==nrobs
        iac=nrobs-1;
    end
    handles.model.delft3dflow.domain(ad).nrDrogues=nrobs-1;
    handles.model.delft3dflow.domain(ad).activeDrogue=iac;
    handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','drogues');
    setHandles(handles);
    refreshDrogues;
end

%%
function deleteDrogueFromMap(h)

handles=getHandles;
iac=get(h,'UserData');
handles.model.delft3dflow.domain(ad).activeDrogue=iac;
handles=deleteDrogue(handles);
setHandles(handles);

%%
function selectDrogueFromMap(h)

handles=getHandles;
iac=get(h,'UserData');
handles.model.delft3dflow.domain(ad).activeDrogue=iac;
ddb_Delft3DFLOW_plotAttributes(handles,'update','drogues');
setHandles(handles);
refreshDrogues;

%%
function changeDrogueFromMap(h)

handles=getHandles;
iac=get(h,'UserData');
handles.model.delft3dflow.domain(ad).activeDrogue=iac;
ddb_Delft3DFLOW_plotAttributes(handles,'update','drogues');
setHandles(handles);
refreshDrogues;
ddb_dragLine(@addDrogue,'free');
setInstructions({'','','Click new position of drogue'});

%%
function refreshDrogues
gui_updateActiveTab;
