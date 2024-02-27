function ddb_Delft3DFLOW_discharges(varargin)
%DDB_DELFT3DFLOW_DISCHARGES  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_Delft3DFLOW_discharges(varargin)
%
%   Input:
%   varargin =
%
%
%
%
%   Example
%   ddb_Delft3DFLOW_discharges
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

% $Id: ddb_Delft3DFLOW_discharges.m 10447 2014-03-26 07:06:47Z ormondt $
% $Date: 2014-03-26 15:06:47 +0800 (Wed, 26 Mar 2014) $
% $Author: ormondt $
% $Revision: 10447 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/models/Delft3DFLOW/gui/ddb_Delft3DFLOW_discharges.m $
% $Keywords: $

%%
handles=getHandles;

ddb_zoomOff;

if isempty(varargin)
    ddb_refreshScreen;
    handles.model.delft3dflow.domain(ad).addDischarge=0;
    handles.model.delft3dflow.domain(ad).selectDischarge=0;
    handles.model.delft3dflow.domain(ad).changeDischarge=0;
    handles.model.delft3dflow.domain(ad).deleteDischarge=0;
    handles=ddb_Delft3DFLOW_plotAttributes(handles,'update','discharges');
    setHandles(handles);
else
    
    opt=varargin{1};
    
    switch(lower(opt))
        
        case{'add'}
            handles.model.delft3dflow.domain(ad).selectDischarge=0;
            handles.model.delft3dflow.domain(ad).changeDischarge=0;
            handles.model.delft3dflow.domain(ad).deleteDischarge=0;
            if handles.model.delft3dflow.domain(ad).addDischarge
                handles.editMode='add';
                ddb_dragLine(@addDischarge,'free');
                setInstructions({'','','Click point on map for new discharge(s)'});
            else
                set(gcf, 'windowbuttondownfcn',[]);
                clearInstructions;
            end
            setHandles(handles);
            refreshDischarges;
            
        case{'delete'}
            handles.model.delft3dflow.domain(ad).addDischarge=0;
            handles.model.delft3dflow.domain(ad).selectDischarge=0;
            handles.model.delft3dflow.domain(ad).changeDischarge=0;
            ddb_clickObject('tag','Discharge','callback',@deleteDischargeFromMap);
            setInstructions({'','','Select discharge from map to delete'});
            if handles.model.delft3dflow.domain(ad).deleteDischarge
                % Delete discharge selected from list
                handles=deleteDischarge(handles);
            end
            setHandles(handles);
            refreshDischarges;
            
        case{'select'}
            handles.model.delft3dflow.domain(ad).addDischarge=0;
            handles.model.delft3dflow.domain(ad).deleteDischarge=0;
            handles.model.delft3dflow.domain(ad).changeDischarge=0;
            if handles.model.delft3dflow.domain(ad).selectDischarge
                ddb_clickObject('tag','Discharge','callback',@selectDischargeFromMap);
                setInstructions({'','','Select discharge from map'});
            else
                set(gcf, 'windowbuttondownfcn',[]);
                clearInstructions;
            end
            setHandles(handles);
            refreshDischarges;
            
        case{'change'}
            handles.model.delft3dflow.domain(ad).addDischarge=0;
            handles.model.delft3dflow.domain(ad).selectDischarge=0;
            handles.model.delft3dflow.domain(ad).deleteDischarge=0;
            if handles.model.delft3dflow.domain(ad).changeDischarge
                ddb_clickObject('tag','Discharge','callback',@changeDischargeFromMap);
                setInstructions({'','','Select discharge to change from map'});
            else
                set(gcf, 'windowbuttondownfcn',[]);
                clearInstructions;
            end
            setHandles(handles);
            refreshDischarges;
            
        case{'edit'}
            handles.model.delft3dflow.domain(ad).addDischarge=0;
            handles.model.delft3dflow.domain(ad).selectDischarge=0;
            handles.model.delft3dflow.domain(ad).changeDischarge=0;
            handles.model.delft3dflow.domain(ad).deleteDischarge=0;
            handles.editMode='edit';
            n=handles.model.delft3dflow.domain(ad).activeDischarge;
            name=handles.model.delft3dflow.domain(ad).discharges(n).name;
            if strcmpi(handles.model.delft3dflow.domain(ad).discharges(n).name(1),'(')
                mstr=num2str(handles.model.delft3dflow.domain(ad).discharges(n).M);
                nstr=num2str(handles.model.delft3dflow.domain(ad).discharges(n).N);
                name=['('  mstr ',' nstr ')'];
            end
            handles.model.delft3dflow.domain(ad).dischargeNames{n}=name;
            handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','discharges');
            clearInstructions;
            setHandles(handles);
            refreshDischarges;
            
        case{'editdischargedata'}
            handles.model.delft3dflow.domain(ad).selectDischarge=0;
            handles.model.delft3dflow.domain(ad).changeDischarge=0;
            handles.model.delft3dflow.domain(ad).deleteDischarge=0;
            setHandles(handles);
            clearInstructions;
            ddb_editD3DDischargeData(handles.model.delft3dflow.domain(ad).activeDischarge)
            
        case{'selectfromlist'}
            handles.model.delft3dflow.domain(ad).addDischarge=0;
            handles.model.delft3dflow.domain(ad).selectDischarge=0;
            handles.model.delft3dflow.domain(ad).changeDischarge=0;
            % Delete selected discharge next time delete is clicked
            handles.model.delft3dflow.domain(ad).deleteDischarge=1;
            handles=ddb_Delft3DFLOW_plotAttributes(handles,'update','discharges');
            clearInstructions;
            setHandles(handles);
            refreshDischarges;
            
        case{'opensrcfile'}
            handles=ddb_readSrcFile(handles,ad);
            handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','discharges');
            setHandles(handles);
            refreshDischarges;
            
        case{'savesrcfile'}
            ddb_saveSrcFile(handles,ad);
            
        case{'opendisfile'}
            handles=ddb_readDisFile(handles,ad);
            setHandles(handles);
            
        case{'savedisfile'}
            ddb_saveDisFile(handles,ad);
            
    end
end

%%
function addDischarge(x,y)

x1=x(1);
y1=y(1);

handles=getHandles;
% Find grid indices
[m1,n1]=findgridcell(x1,y1,handles.model.delft3dflow.domain(ad).gridX,handles.model.delft3dflow.domain(ad).gridY);
% Check if start and end are in one grid line
if ~isempty(m1)
    if m1>0
        if handles.model.delft3dflow.domain(ad).changeDischarge
            iac=handles.model.delft3dflow.domain(ad).activeDischarge;
        else
            % Add mode
            handles.model.delft3dflow.domain(ad).nrDischarges=handles.model.delft3dflow.domain(ad).nrDischarges+1;
            iac=handles.model.delft3dflow.domain(ad).nrDischarges;
            handles=ddb_initializeDischarge(handles,ad,iac);
        end
        handles.model.delft3dflow.domain(ad).discharges(iac).M=m1;
        handles.model.delft3dflow.domain(ad).discharges(iac).N=n1;
        handles.model.delft3dflow.domain(ad).discharges(iac).name=['(' num2str(m1) ',' num2str(n1) ')'];
        handles.model.delft3dflow.domain(ad).dischargeNames{iac}=handles.model.delft3dflow.domain(ad).discharges(iac).name;
        handles.model.delft3dflow.domain(ad).activeDischarge=iac;
        handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','discharges');
        setHandles(handles);
        
        if handles.model.delft3dflow.domain(ad).changeDischarge
            ddb_clickObject('tag','discharge','callback',@changeDischargeFromMap);
            setInstructions({'','','Select discharge'});
        else
            ddb_dragLine(@addDischarge,'free');
            setInstructions({'','','Click position of new discharge'});
        end
    end
end
refreshDischarges;

%%
function handles=deleteDischarge(handles)

nrdis=handles.model.delft3dflow.domain(ad).nrDischarges;

if nrdis>0
    iac=handles.model.delft3dflow.domain(ad).activeDischarge;
    handles=ddb_Delft3DFLOW_plotAttributes(handles,'delete','discharges');
    if nrdis>1
        handles.model.delft3dflow.domain(ad).discharges=removeFromStruc(handles.model.delft3dflow.domain(ad).discharges,iac);
        handles.model.delft3dflow.domain(ad).dischargeNames=removeFromCellArray(handles.model.delft3dflow.domain(ad).dischargeNames,iac);
    else
        handles.model.delft3dflow.domain(ad).dischargeNames={''};
        handles.model.delft3dflow.domain(ad).activeDischarge=1;
        handles.model.delft3dflow.domain(ad).discharges(1).M=[];
        handles.model.delft3dflow.domain(ad).discharges(1).N=[];
        handles.model.delft3dflow.domain(ad).discharges(1).type='normal';
    end
    if iac==nrdis
        iac=nrdis-1;
    end
    handles.model.delft3dflow.domain(ad).nrDischarges=nrdis-1;
    handles.model.delft3dflow.domain(ad).activeDischarge=max(iac,1);
    handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','discharges');
    setHandles(handles);
    refreshDischarges;
end

%%
function deleteDischargeFromMap(h)

handles=getHandles;
iac=get(h,'UserData');
handles.model.delft3dflow.domain(ad).activeDischarge=iac;
handles=deleteDischarge(handles);
setHandles(handles);

%%
function selectDischargeFromMap(h)

handles=getHandles;
iac=get(h,'UserData');
handles.model.delft3dflow.domain(ad).activeDischarge=iac;
ddb_Delft3DFLOW_plotAttributes(handles,'update','discharges');
setHandles(handles);
refreshDischarges;

%%
function changeDischargeFromMap(h)

handles=getHandles;
iac=get(h,'UserData');
handles.model.delft3dflow.domain(ad).activeDischarge=iac;
ddb_Delft3DFLOW_plotAttributes(handles,'update','discharges');
setHandles(handles);
refreshDischarges;
ddb_dragLine(@addDischarge,'free');
setInstructions({'','','Click new position of discharge'});

%%
function refreshDischarges
gui_updateActiveTab;

