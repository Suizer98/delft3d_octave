function ddb_Delft3DFLOW_crossSections(varargin)
%DDB_DELFT3DFLOW_CROSSSECTIONS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_Delft3DFLOW_crossSections(varargin)
%
%   Input:
%   varargin =
%
%
%
%
%   Example
%   ddb_Delft3DFLOW_crossSections
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

% $Id: ddb_Delft3DFLOW_crossSections.m 10447 2014-03-26 07:06:47Z ormondt $
% $Date: 2014-03-26 15:06:47 +0800 (Wed, 26 Mar 2014) $
% $Author: ormondt $
% $Revision: 10447 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/models/Delft3DFLOW/gui/ddb_Delft3DFLOW_crossSections.m $
% $Keywords: $

%%
handles=getHandles;

ddb_zoomOff;

if isempty(varargin)
    ddb_refreshScreen;
    handles.model.delft3dflow.domain(ad).addCrossSection=0;
    handles.model.delft3dflow.domain(ad).selectCrossSection=0;
    handles.model.delft3dflow.domain(ad).changeCrossSection=0;
    handles.model.delft3dflow.domain(ad).deleteCrossSection=0;
    handles=ddb_Delft3DFLOW_plotAttributes(handles,'update','crosssections');
    setHandles(handles);    
else
    opt=varargin{1};
    switch(lower(opt))
        
        case{'add'}
            handles.model.delft3dflow.domain(ad).selectCrossSection=0;
            handles.model.delft3dflow.domain(ad).changeCrossSection=0;
            handles.model.delft3dflow.domain(ad).deleteCrossSection=0;
            if handles.model.delft3dflow.domain(ad).addCrossSection
                ddb_dragLine(@addCrossSection,'method','alonggridline','x',handles.model.delft3dflow.domain(ad).gridX,'y',handles.model.delft3dflow.domain(ad).gridY);
                setInstructions({'','','Drag line on map for new cross section'});
            else
                set(gcf, 'windowbuttondownfcn',[]);
                clearInstructions;
            end
            setHandles(handles);
            
        case{'delete'}
            handles.model.delft3dflow.domain(ad).addCrossSection=0;
            handles.model.delft3dflow.domain(ad).selectCrossSection=0;
            handles.model.delft3dflow.domain(ad).changeCrossSection=0;
            ddb_clickObject('tag','crosssection','callback',@deleteCrossSectionFromMap);
            setInstructions({'','','Select cross section from map to delete'});
            if handles.model.delft3dflow.domain(ad).deleteCrossSection
                handles=deleteCrossSection(handles);
            end
            setHandles(handles);
            
        case{'select'}
            handles.model.delft3dflow.domain(ad).addCrossSection=0;
            handles.model.delft3dflow.domain(ad).deleteCrossSection=0;
            handles.model.delft3dflow.domain(ad).changeCrossSection=0;
            ddb_clickObject('tag','crosssection','callback',@selectCrossSectionFromMap);
            setInstructions({'','','Select cross section from map'});
            setHandles(handles);
            
        case{'change'}
            handles.model.delft3dflow.domain(ad).addCrossSection=0;
            handles.model.delft3dflow.domain(ad).selectCrossSection=0;
            handles.model.delft3dflow.domain(ad).deleteCrossSection=0;
            if handles.model.delft3dflow.domain(ad).changeCrossSection
                ddb_clickObject('tag','crosssection','callback',@changeCrossSectionFromMap);
                setInstructions({'','','Select cross section to change from map'});
            end
            setHandles(handles);
            
        case{'edit'}
            handles.model.delft3dflow.domain(ad).addCrossSection=0;
            handles.model.delft3dflow.domain(ad).selectCrossSection=0;
            handles.model.delft3dflow.domain(ad).changeCrossSection=0;
            handles.model.delft3dflow.domain(ad).deleteCrossSection=0;
            handles.editMode='edit';
            n=handles.model.delft3dflow.domain(ad).activeCrossSection;
            handles.model.delft3dflow.domain(ad).crossSectionNames{n}=handles.model.delft3dflow.domain(ad).crossSections(n).name;
            if strcmpi(handles.model.delft3dflow.domain(ad).crossSections(n).name(1),'(')
                m1str=num2str(handles.model.delft3dflow.domain(ad).crossSections(n).M1);
                m2str=num2str(handles.model.delft3dflow.domain(ad).crossSections(n).M2);
                n1str=num2str(handles.model.delft3dflow.domain(ad).crossSections(n).N1);
                n2str=num2str(handles.model.delft3dflow.domain(ad).crossSections(n).N2);
                handles.model.delft3dflow.domain(ad).crossSectionNames{n}=['('  m1str ',' n1str ')...(' m2str ',' n2str ')'];
            end
            handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','crosssections');
            clearInstructions;
            setHandles(handles);
            
        case{'selectfromlist'}
            handles.model.delft3dflow.domain(ad).addCrossSection=0;
            handles.model.delft3dflow.domain(ad).selectCrossSection=0;
            handles.model.delft3dflow.domain(ad).changeCrossSection=0;
            % Delete selected cross section next time delete is clicked
            handles.model.delft3dflow.domain(ad).deleteCrossSection=1;
            handles=ddb_Delft3DFLOW_plotAttributes(handles,'update','crosssections');
            clearInstructions;
            setHandles(handles);
            
        case{'openfile'}
            handles=ddb_readCrsFile(handles,ad);
            handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','crosssections');
            setHandles(handles);
            
        case{'savefile'}
            ddb_saveCrsFile(handles,ad);
            
        case{'plot'}
            handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','crosssections');
            setHandles(handles);
            
    end
end

refreshCrossSections;

%%
function addCrossSection(x,y)

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
    
    if handles.model.delft3dflow.domain(ad).changeCrossSection
        iac=handles.model.delft3dflow.domain(ad).activeCrossSection;
    else
        % Add mode
        handles.model.delft3dflow.domain(ad).nrCrossSections=handles.model.delft3dflow.domain(ad).nrCrossSections+1;
        iac=handles.model.delft3dflow.domain(ad).nrCrossSections;
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
    
    handles.model.delft3dflow.domain(ad).crossSections(iac).M1=m1;
    handles.model.delft3dflow.domain(ad).crossSections(iac).N1=n1;
    handles.model.delft3dflow.domain(ad).crossSections(iac).M2=m2;
    handles.model.delft3dflow.domain(ad).crossSections(iac).N2=n2;
    handles.model.delft3dflow.domain(ad).crossSections(iac).name=['(' num2str(m1) ',' num2str(n1) ')...(' num2str(m2) ',' num2str(n2) ')'];
    handles.model.delft3dflow.domain(ad).crossSectionNames{iac}=handles.model.delft3dflow.domain(ad).crossSections(iac).name;
    handles.model.delft3dflow.domain(ad).activeCrossSection=iac;
    handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','crosssections');
    
    if handles.model.delft3dflow.domain(ad).changeCrossSection
        ddb_clickObject('tag','crosssection','callback',@changeCrossSectionFromMap);
        setInstructions({'','','Select cross section'});
    else
        ddb_dragLine(@addCrossSection,'method','alonggridline','x',handles.model.delft3dflow.domain(ad).gridX,'y',handles.model.delft3dflow.domain(ad).gridY);
        setInstructions({'','','Drag new cross section'});
    end
end
setHandles(handles);
refreshCrossSections;

%%
function handles=deleteCrossSection(handles)

nrcrs=handles.model.delft3dflow.domain(ad).nrCrossSections;

if nrcrs>0
    iac=handles.model.delft3dflow.domain(ad).activeCrossSection;
    handles=ddb_Delft3DFLOW_plotAttributes(handles,'delete','crosssections');
    if nrcrs>1
        handles.model.delft3dflow.domain(ad).crossSections=removeFromStruc(handles.model.delft3dflow.domain(ad).crossSections,iac);
        handles.model.delft3dflow.domain(ad).crossSectionNames=removeFromCellArray(handles.model.delft3dflow.domain(ad).crossSectionNames,iac);
    else
        handles.model.delft3dflow.domain(ad).crossSectionNames={''};
        handles.model.delft3dflow.domain(ad).activeCrossSection=1;
        handles.model.delft3dflow.domain(ad).crossSections(1).M1=[];
        handles.model.delft3dflow.domain(ad).crossSections(1).M2=[];
        handles.model.delft3dflow.domain(ad).crossSections(1).N1=[];
        handles.model.delft3dflow.domain(ad).crossSections(1).N2=[];
        handles.model.delft3dflow.domain(ad).crossSections(1).name='';
    end
    if iac==nrcrs
        iac=nrcrs-1;
    end
    handles.model.delft3dflow.domain(ad).nrCrossSections=nrcrs-1;
    handles.model.delft3dflow.domain(ad).activeCrossSection=iac;
    handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','crosssections');
    setHandles(handles);
    refreshCrossSections;
end

%%
function deleteCrossSectionFromMap(h)

handles=getHandles;
iac=get(h,'UserData');
handles.model.delft3dflow.domain(ad).activeCrossSection=iac;
handles=deleteCrossSection(handles);
setHandles(handles);

%%
function selectCrossSectionFromMap(h)

handles=getHandles;
iac=get(h,'UserData');
handles.model.delft3dflow.domain(ad).activeCrossSection=iac;
handles=ddb_Delft3DFLOW_plotAttributes(handles,'update','crosssections');
setHandles(handles);
refreshCrossSections;

%%
function changeCrossSectionFromMap(h)

handles=getHandles;
iac=get(h,'UserData');
handles.model.delft3dflow.domain(ad).activeCrossSection=iac;
ddb_Delft3DFLOW_plotCrossSections(handles,'update');
setHandles(handles);
refreshCrossSections;
ddb_dragLine(@addCrossSection,'free');
setInstructions({'','','Drag line for new position of cross section'});

%%
function refreshCrossSections
gui_updateActiveTab;
