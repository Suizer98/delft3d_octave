function ddb_DFlowFM_crossSections(varargin)
%ddb_DFlowFM_crossSections  One line description goes here.

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

% $Id: ddb_DFlowFM_crossSections.m 10447 2014-03-26 07:06:47Z ormondt $
% $Date: 2014-03-26 15:06:47 +0800 (Wed, 26 Mar 2014) $
% $Author: ormondt $
% $Revision: 10447 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/models/DFlowFM/gui/ddb_DFlowFM_crossSections.m $
% $Keywords: $

%%

ddb_zoomOff;

if isempty(varargin)
    handles=getHandles;
    ddb_refreshScreen;
    handles=ddb_DFlowFM_plotCrossSections(handles,'update','active',1);
    setHandles(handles);    
else
    
    opt=varargin{1};

    clearInstructions;
    
    switch(lower(opt))

        case{'add'}
            drawCrossSection;

        case{'selectfromlist'}
            selectFromList;
            
        case{'deletefromlist'}
            deleteCrossSection;

        case{'edit'}
            editCrossSection;

        case{'changecrosssection'}
            h=varargin{2};
            x=varargin{3};
            y=varargin{4};
            changeCrossSection(h,x,y);
            
        case{'openfile'}
            handles=getHandles;
            handles.model.dflowfm.domain.crosssections=ddb_DFlowFM_readCrsFile(handles.model.dflowfm.domain.crsfile);
            handles.model.dflowfm.domain.nrcrosssections=length(handles.model.dflowfm.domain.crosssections);
            handles=updateNames(handles);
            handles=ddb_DFlowFM_plotCrossSections(handles,'plot','active',1);
            setHandles(handles);
            
        case{'savefile'}
            handles=getHandles;
            ddb_DFlowFM_saveCrsFile(handles.model.dflowfm.domain.crsfile,handles.model.dflowfm.domain.crosssections);

    end
end

refreshCrossSections;

%%
function drawCrossSection

handles=getHandles;
% Click Add in GUI
handles.model.dflowfm.domain(ad).deletecrosssection=0;
ddb_zoomOff;
setInstructions({'','','Draw cross section'});
gui_polyline('draw','tag','dflowfmcrosssection','Marker','o','createcallback',@addCrossSection,'changecallback',@changeCrossSection,'closed',0, ...
    'color','g','markeredgecolor','r','markerfacecolor','r');
setHandles(handles);

%%
function addCrossSection(h,x,y)

clearInstructions;

handles=getHandles;

% Add mode
handles.model.dflowfm.domain(ad).nrcrosssections=handles.model.dflowfm.domain(ad).nrcrosssections+1;
iac=handles.model.dflowfm.domain(ad).nrcrosssections;
handles.model.dflowfm.domain(ad).crosssections(iac).name=['crosssection ' num2str(iac)];
handles.model.dflowfm.domain(ad).crosssectionnames{iac}=handles.model.dflowfm.domain(ad).crosssections(iac).name;

handles.model.dflowfm.domain(ad).crosssections(iac).x=x;
handles.model.dflowfm.domain(ad).crosssections(iac).y=y;
handles.model.dflowfm.domain(ad).crosssections(iac).handle=h;
handles.model.dflowfm.domain(ad).activecrosssection=iac;

handles=ddb_DFlowFM_plotCrossSections(handles,'plot','active',1);

setHandles(handles);

refreshCrossSections;

%%
function changeCrossSection(h,x,y)

% Cross section changed on map

handles=getHandles;

for ii=1:handles.model.dflowfm.domain(ad).nrcrosssections
    if handles.model.dflowfm.domain(ad).crosssections(ii).handle==h
        iac=ii;
        break;
    end
end

handles.model.dflowfm.domain(ad).crosssections(iac).x=x;
handles.model.dflowfm.domain(ad).crosssections(iac).y=y;
handles.model.dflowfm.domain(ad).activecrosssection=iac;

handles=ddb_DFlowFM_plotCrossSections(handles,'plot','active',1);

setHandles(handles);

refreshCrossSections;

%%
function deleteCrossSection

clearInstructions;

handles=getHandles;

nrobs=handles.model.dflowfm.domain(ad).nrcrosssections;

if nrobs>0
    iac=handles.model.dflowfm.domain(ad).activecrosssection;
    handles=ddb_DFlowFM_plotCrossSections(handles,'delete','crosssections');
    if nrobs>1
        handles.model.dflowfm.domain(ad).crosssections=removeFromStruc(handles.model.dflowfm.domain(ad).crosssections,iac);
        handles.model.dflowfm.domain(ad).crosssectionnames=removeFromCellArray(handles.model.dflowfm.domain(ad).crosssectionnames,iac);
    else
        handles.model.dflowfm.domain(ad).crosssectionnames={''};
        handles.model.dflowfm.domain(ad).activecrosssection=1;
        handles.model.dflowfm.domain(ad).crosssections(1).name='';
        handles.model.dflowfm.domain(ad).crosssections(1).x=0;
        handles.model.dflowfm.domain(ad).crosssections(1).y=0;
    end
    if iac==nrobs
        iac=max(nrobs-1,1);
    end
    handles.model.dflowfm.domain(ad).nrcrosssections=nrobs-1;
    handles.model.dflowfm.domain(ad).activecrosssection=iac;
    handles=ddb_DFlowFM_plotCrossSections(handles,'plot','active',1);
    setHandles(handles);
    refreshCrossSections;
end

%%
function editCrossSection
clearInstructions;
handles=getHandles;
handles=updateNames(handles);
handles=ddb_DFlowFM_plotCrossSections(handles,'plot','active',1);
setHandles(handles);

%%
function selectFromList
clearInstructions;
handles=getHandles;
handles=ddb_DFlowFM_plotCrossSections(handles,'plot','active',1);
setHandles(handles);

%%
function handles=updateNames(handles)
handles.model.dflowfm.domain.crosssectionnames=[];
for ib=1:handles.model.dflowfm.domain.nrcrosssections
    handles.model.dflowfm.domain.crosssectionnames{ib}=handles.model.dflowfm.domain.crosssections(ib).name;
end

%%
function refreshCrossSections
gui_updateActiveTab;
