function ddb_Delft3DFLOW_weirs2D(varargin)
%DDB_DELFT3DFLOW_weirs2D  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_Delft3DFLOW_weirs2D(varargin)
%
%   Input:
%   varargin =
%
%
%
%
%   Example
%   ddb_Delft3DFLOW_weirs2D
%
%   See also

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
% Created: 29 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: ddb_Delft3DFLOW_weirs2D.m 10447 2014-03-26 07:06:47Z ormondt $
% $Date: 2014-03-26 15:06:47 +0800 (Wed, 26 Mar 2014) $
% $Author: ormondt $
% $Revision: 10447 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/models/Delft3DFLOW/gui/ddb_Delft3DFLOW_weirs2D.m $
% $Keywords: $

%%
handles=getHandles;

ddb_zoomOff;

if isempty(varargin)
    ddb_refreshScreen;
    handles.model.delft3dflow.domain(ad).addWeir2D=0;
    handles.model.delft3dflow.domain(ad).selectWeir2D=0;
    handles.model.delft3dflow.domain(ad).changeWeir2D=0;
    handles.model.delft3dflow.domain(ad).deleteWeir2D=0;
    handles=ddb_Delft3DFLOW_plotAttributes(handles,'update','weirs2d');
    setHandles(handles);
else
    opt=varargin{1};
    switch(lower(opt))
        
        case{'add'}
            handles.model.delft3dflow.domain(ad).selectWeir2D=0;
            handles.model.delft3dflow.domain(ad).changeWeir2D=0;
            handles.model.delft3dflow.domain(ad).deleteWeir2D=0;
            if handles.model.delft3dflow.domain(ad).addWeir2D
                ddb_dragLine(@addWeir2D,'method','alonggridline','x',handles.model.delft3dflow.domain(ad).gridX,'y',handles.model.delft3dflow.domain(ad).gridY);
                setInstructions({'','','Drag line on map for new 2D weir'});
            else
                set(gcf, 'windowbuttondownfcn',[]);
                clearInstructions;
            end
            setHandles(handles);
            
        case{'delete'}
            handles.model.delft3dflow.domain(ad).addWeir2D=0;
            handles.model.delft3dflow.domain(ad).selectWeir2D=0;
            handles.model.delft3dflow.domain(ad).changeWeir2D=0;
            ddb_clickObject('tag','weir2d','callback',@deleteWeir2DFromMap);
            setInstructions({'','','Select 2D weir from map to delete'});
            if handles.model.delft3dflow.domain(ad).deleteWeir2D
                handles=deleteWeir2D(handles);
            end
            setHandles(handles);
            
        case{'select'}
            handles.model.delft3dflow.domain(ad).addWeir2D=0;
            handles.model.delft3dflow.domain(ad).deleteWeir2D=0;
            handles.model.delft3dflow.domain(ad).changeWeir2D=0;
            ddb_clickObject('tag','weir2d','callback',@selectWeir2DFromMap);
            setHandles(handles);
            setInstructions({'','','Select 2D weir from map'});
            
        case{'change'}
            handles.model.delft3dflow.domain(ad).addWeir2D=0;
            handles.model.delft3dflow.domain(ad).selectWeir2D=0;
            handles.model.delft3dflow.domain(ad).deleteWeir2D=0;
            if handles.model.delft3dflow.domain(ad).changeWeir2D
                ddb_clickObject('tag','weir2d','callback',@changeWeir2DFromMap);
                setInstructions({'','','Select 2D weir to change from map'});
            end
            setHandles(handles);
            
        case{'edit'}
            handles.model.delft3dflow.domain(ad).addWeir2D=0;
            handles.model.delft3dflow.domain(ad).selectWeir2D=0;
            handles.model.delft3dflow.domain(ad).changeWeir2D=0;
            handles.model.delft3dflow.domain(ad).deleteWeir2D=0;
            handles.editMode='edit';
            n=handles.model.delft3dflow.domain(ad).activeWeir2D;
            m1str=num2str(handles.model.delft3dflow.domain(ad).weirs2D(n).M1);
            m2str=num2str(handles.model.delft3dflow.domain(ad).weirs2D(n).M2);
            n1str=num2str(handles.model.delft3dflow.domain(ad).weirs2D(n).N1);
            n2str=num2str(handles.model.delft3dflow.domain(ad).weirs2D(n).N2);
            handles.model.delft3dflow.domain(ad).weir2DNames{n}=['('  m1str ',' n1str ')...(' m2str ',' n2str ')'];
            handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','weirs2d');
            setHandles(handles);
            clearInstructions;
            
        case{'selectfromlist'}
            handles.model.delft3dflow.domain(ad).addWeir2D=0;
            handles.model.delft3dflow.domain(ad).selectWeir2D=0;
            handles.model.delft3dflow.domain(ad).changeWeir2D=0;
            % Delete selected dry point next time delete is clicked
            handles.model.delft3dflow.domain(ad).deleteWeir2D=1;
            handles=ddb_Delft3DFLOW_plotAttributes(handles,'update','weirs2d');
            setHandles(handles);
            clearInstructions;
            
        case{'openfile'}
            handles=ddb_read2DWFile(handles,ad);
            handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','weirs2d');
            setHandles(handles);
            
        case{'savefile'}
            ddb_save2DWFile(handles,ad);
            
        case{'plot'}
            handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','weirs2d');
            setHandles(handles);
            
    end
end


refreshWeirs2D;

%%
function addWeir2D(x,y)

x1=x(1);x2=x(2);
y1=y(1);y2=y(2);

handles=getHandles;

if x1==x2 && y1==y2
    [m1,n1,uv]=findgridline(x1,y1,handles.model.delft3dflow.domain(ad).gridX,handles.model.delft3dflow.domain(ad).gridY);
    m2=m1;
    n2=n1;
else
    [m1,n1]=findcornerpoint(x1,y1,handles.model.delft3dflow.domain(ad).gridX,handles.model.delft3dflow.domain(ad).gridY);
    [m2,n2]=findcornerpoint(x2,y2,handles.model.delft3dflow.domain(ad).gridX,handles.model.delft3dflow.domain(ad).gridY);
end
if m1>0 && (m1==m2 || n1==n2)
    
    if handles.model.delft3dflow.domain(ad).changeWeir2D
        iac=handles.model.delft3dflow.domain(ad).activeWeir2D;
    else
        % Add mode
        handles.model.delft3dflow.domain(ad).nrWeirs2D=handles.model.delft3dflow.domain(ad).nrWeirs2D+1;
        iac=handles.model.delft3dflow.domain(ad).nrWeirs2D;
    end
    
    if x1==x2 && y1==y2
        if uv==1
            handles.model.delft3dflow.domain(ad).weirs2D(iac).UV='V';
        else
            handles.model.delft3dflow.domain(ad).weirs2D(iac).UV='U';
        end
    else
        if m2~=m1
            handles.model.delft3dflow.domain(ad).weirs2D(iac).UV='V';
        else
            handles.model.delft3dflow.domain(ad).weirs2D(iac).UV='U';
        end
    end
    if m2>m1
        m1=m1+1;
    end
    if m2<m1
        m2=m2+1;
    end
    if n2>n1
        n1=n1+1;
    end
    if n1>n2
        n2=n2+1;
    end
    
    handles.model.delft3dflow.domain(ad).weirs2D(iac).M1=m1;
    handles.model.delft3dflow.domain(ad).weirs2D(iac).N1=n1;
    handles.model.delft3dflow.domain(ad).weirs2D(iac).M2=m2;
    handles.model.delft3dflow.domain(ad).weirs2D(iac).N2=n2;
    handles.model.delft3dflow.domain(ad).weirs2D(iac).crestHeight=0.0;
    handles.model.delft3dflow.domain(ad).weirs2D(iac).frictionCoefficient=1.0;
    handles.model.delft3dflow.domain(ad).weirs2D(iac).name=['(' num2str(m1) ',' num2str(n1) ')...(' num2str(m2) ',' num2str(n2) ')'];
    handles.model.delft3dflow.domain(ad).weir2DNames{iac}=handles.model.delft3dflow.domain(ad).weirs2D(iac).name;
    handles.model.delft3dflow.domain(ad).activeWeir2D=iac;
    handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','weirs2d');
    
    if handles.model.delft3dflow.domain(ad).changeWeir2D
        ddb_clickObject('tag','thindam','callback',@changeWeir2DFromMap);
        setInstructions({'','','Select 2D weir'});
    else
        ddb_dragLine(@addWeir2D,'method','alonggridline','x',handles.model.delft3dflow.domain(ad).gridX,'y',handles.model.delft3dflow.domain(ad).gridY);
        setInstructions({'','','Drag new 2D weir'});
    end
end
setHandles(handles);
refreshWeirs2D;

%%
function handles=deleteWeir2D(handles)

nrdry=handles.model.delft3dflow.domain(ad).nrWeirs2D;

if nrdry>0
    iac=handles.model.delft3dflow.domain(ad).activeWeir2D;
    handles=ddb_Delft3DFLOW_plotAttributes(handles,'delete','weirs2d');
    if nrdry>1
        handles.model.delft3dflow.domain(ad).weirs2D=removeFromStruc(handles.model.delft3dflow.domain(ad).weirs2D,iac);
        handles.model.delft3dflow.domain(ad).weir2DNames=removeFromCellArray(handles.model.delft3dflow.domain(ad).weir2DNames,iac);
    else
        handles.model.delft3dflow.domain(ad).weir2DNames={''};
        handles.model.delft3dflow.domain(ad).activeWeir2D=1;
        handles.model.delft3dflow.domain(ad).weirs2D(1).M1=[];
        handles.model.delft3dflow.domain(ad).weirs2D(1).M2=[];
        handles.model.delft3dflow.domain(ad).weirs2D(1).N1=[];
        handles.model.delft3dflow.domain(ad).weirs2D(1).N2=[];
        handles.model.delft3dflow.domain(ad).weirs2D(1).UV=[];
        handles.model.delft3dflow.domain(ad).weirs2D(1).crestHeight=[];
        handles.model.delft3dflow.domain(ad).weirs2D(1).frictionCoefficient=[];
    end
    if iac==nrdry
        iac=nrdry-1;
    end
    handles.model.delft3dflow.domain(ad).nrWeirs2D=nrdry-1;
    handles.model.delft3dflow.domain(ad).activeWeir2D=iac;
    handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','weirs2d');
    setHandles(handles);
    refreshWeirs2D;
end

%%
function deleteWeir2DFromMap(h)

handles=getHandles;
iac=get(h,'UserData');
handles.model.delft3dflow.domain(ad).activeWeir2D=iac;
handles=deleteWeir2D(handles);
setHandles(handles);

%%
function selectWeir2DFromMap(h)

handles=getHandles;
iac=get(h,'UserData');
handles.model.delft3dflow.domain(ad).activeWeir2D=iac;
handles=ddb_Delft3DFLOW_plotAttributes(handles,'update','weirs2d');
setHandles(handles);
refreshWeirs2D;

%%
function changeWeir2DFromMap(h)

handles=getHandles;
iac=get(h,'UserData');
handles.model.delft3dflow.domain(ad).activeWeir2D=iac;
ddb_Delft3DFLOW_plotWeirs2D(handles,'update');
setHandles(handles);
refreshWeirs2D;
ddb_dragLine(@addWeir2D,'free');
setInstructions({'','','Drag line for new position of 2D weir'});

%%
function refreshWeirs2D
gui_updateActiveTab;

