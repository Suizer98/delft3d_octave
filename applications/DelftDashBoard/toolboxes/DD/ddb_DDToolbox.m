function ddb_DDToolbox(varargin)
%DDB_DDTOOLBOX  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_DDToolbox(varargin)
%
%   Input:
%   varargin =
%
%
%
%
%   Example
%   ddb_DDToolbox
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
% Created: 01 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
if isempty(varargin)
    % New tab selected
    ddb_zoomOff;
    ddb_refreshScreen;
    ddb_plotDD('activate');
    handles=getHandles;
    
    % Make
    handles.toolbox.dd.domains=[];
    for i=1:length(handles.model.delft3dflow.domain)
        handles.toolbox.dd.domains{i}=handles.model.delft3dflow.domain(i).runid;
    end
    
    % If m2 or n2 is nan, set m1 and n1 to NaN
    m2=handles.toolbox.dd.secondCornerPointM;
    n2=handles.toolbox.dd.secondCornerPointN;
    if isnan(m2) || isnan(n2)
        handles.toolbox.dd.firstCornerPointM=NaN;
        handles.toolbox.dd.firstCornerPointN=NaN;
    end
    setHandles(handles);
    
    % If m1 or n1 is nan, delete corner points
    m1=handles.toolbox.dd.firstCornerPointM;
    n1=handles.toolbox.dd.firstCornerPointN;
    if isnan(m1) || isnan(n1)
        plotCornerPoints('delete');
    end
    
    clearInstructions;
    
else
    %Options selected
    opt=lower(varargin{1});
    switch opt
        case{'editrefinement'}
            editRefinement;
        case{'editm1'}
            editM1;
        case{'editn1'}
            editN1;
        case{'editm2'}
            editM2;
        case{'editn2'}
            editN2;
        case{'selectcornerpoints'}
            selectCornerPoints;
        case{'generatenewdomain'}
            makeNewDomain;
        case{'makeddboundaries'}
            generateDD;
    end
end

%%
function editRefinement
plotTemporaryDDGrid('plot');
handles=getHandles;
if ~odd(handles.toolbox.dd.mRefinement) || ~odd(handles.toolbox.dd.nRefinement)
    ddb_giveWarning('text','Refinement by an even number is not recommended!');
end

%%
function editM1

handles=getHandles;
ii=handles.toolbox.dd.firstCornerPointM;
sz=size(handles.model.delft3dflow.domain(ad).gridX);
if ii>sz(1)
    handles.toolbox.dd.firstCornerPointM=sz(1);
end
if ii<1
    handles.toolbox.dd.firstCornerPointM=1;
end

setHandles(handles);

plotCornerPoints('plot');
plotTemporaryDDGrid('plot');

%%
function editN1

handles=getHandles;
ii=handles.toolbox.dd.firstCornerPointN;
sz=size(handles.model.delft3dflow.domain(ad).gridX);
if ii>sz(2)
    handles.toolbox.dd.firstCornerPointN=sz(2);
end
if ii<1
    handles.toolbox.dd.firstCornerPointN=1;
end

setHandles(handles);

plotCornerPoints('plot');
plotTemporaryDDGrid('plot');

%%
function editM2

handles=getHandles;
ii=handles.toolbox.dd.secondCornerPointM;
sz=size(handles.model.delft3dflow.domain(ad).gridX);
if ii>sz(1)
    handles.toolbox.dd.secondCornerPointM=sz(1);
end
if ii<1
    handles.toolbox.dd.secondCornerPointM=1;
end

setHandles(handles);

plotCornerPoints('plot');
plotTemporaryDDGrid('plot');

%%
function editN2

handles=getHandles;
ii=handles.toolbox.dd.secondCornerPointN;
sz=size(handles.model.delft3dflow.domain(ad).gridX);
if ii>sz(2)
    handles.toolbox.dd.secondCornerPointN=sz(2);
end
if ii<1
    handles.toolbox.dd.secondCornerPointN=1;
end

setHandles(handles);

plotCornerPoints('plot');
plotTemporaryDDGrid('plot');

%%
function selectCornerPoints

handles=getHandles;

switch lower(handles.model.delft3dflow.name)
    case{'delft3dflow'}
    otherwise
        ddb_giveWarning('text',['Sorry, the Domain Decomposition toolbox does not support ' handles.model.delft3dflow.longName ' ...']);
        return
end

ddb_zoomOff;
ddb_setWindowButtonUpDownFcn;
setInstructions({'','','Click grid point on active grid for first corner point'});
xg=handles.model.delft3dflow.domain(handles.activeDomain).gridX;
yg=handles.model.delft3dflow.domain(handles.activeDomain).gridY;
if ~isempty(xg)
    ddb_clickPoint('cornerpoint','grid',xg,yg,'callback',@clickFirstCornerPoint,'single');
    setHandles(handles);
end

%%
function makeNewDomain

handles=getHandles;

switch lower(handles.model.delft3dflow.name)
    case{'delft3dflow'}
    otherwise
        ddb_giveWarning('text',['Sorry, the Domain Decomposition toolbox does not support ' handles.model.delft3dflow.longName ' ...']);
        return
end

% Check indices
m1=handles.toolbox.dd.firstCornerPointM;
n1=handles.toolbox.dd.firstCornerPointN;
m2=handles.toolbox.dd.secondCornerPointM;
n2=handles.toolbox.dd.secondCornerPointN;
mdd(1)=min(m1,m2);mdd(2)=max(m1,m2);
ndd(1)=min(n1,n2);ndd(2)=max(n1,n2);

% Check if domain with new runid already exists
ii=strmatch(lower(handles.toolbox.dd.newRunid),handles.toolbox.dd.domains,'exact');

if ~isempty(ii)
    
    ddb_giveWarning('Warning',['A domain with runid "' handles.toolbox.dd.newRunid '" already exists!']);
    
elseif mdd(2)>mdd(1) && ndd(2)>ndd(1)

    ddb_giveWarning('txt','The overall grid has changed! Please select file name of new overall grid.');
    
    [filename, pathname, filterindex] = uiputfile('*.grd', 'Select new overall grid file',handles.model.delft3dflow.domain(ad).grdFile);
    
    if pathname~=0
        
        % Delete existing domains
        ddb_plotDelft3DFLOW('delete');
        
        % Set filenames new grid file
        curdir=[lower(cd) '\'];
        if ~strcmpi(curdir,pathname)
            filename=[pathname filename];
        end
        handles.model.delft3dflow.domain(ad).grdFile=filename;
        ii=findstr(filename,'.grd');
        str=filename(1:ii-1);
        handles.model.delft3dflow.domain(ad).encFile=[str '.enc'];
        
        % Generate new domain
        runid1=handles.model.delft3dflow.domain(ad).runid;
        runid2=handles.toolbox.dd.newRunid;
        handles.model.delft3dflow.nrDomains=handles.model.delft3dflow.nrDomains+1;
        id2=handles.model.delft3dflow.nrDomains;
        handles.toolbox.dd.domains{handles.model.delft3dflow.nrDomains}=handles.toolbox.dd.newRunid;
        % Copy active domain to new domain
        handles.model.delft3dflow.domain(id2)=handles.model.delft3dflow.domain(ad);
        handles.model.delft3dflow.domain(id2).runid=runid2;
        handles.model.delft3dflow.domain(id2).attName=handles.toolbox.dd.attributeName;
        % Create backup of original model with id0
        handles.toolbox.dd.originalDomain=handles.model.delft3dflow.domain(ad);
        
        % Initialize grid dependent input new domain
        handles=ddb_initializeFlowDomain(handles,'griddependentinput',id2,runid2);
        
        % New Domain
        % Grid
        [handles,mdd,ndd]=ddb_makeDDModelNewGrid(handles,ad,id2,mdd,ndd,runid2);
        
        % Original Domain
        % Grid
        [handles,mcut,ncut]=ddb_makeDDModelOriginalGrid(handles,ad,mdd,ndd);
        
        if max(mcut)>0 || max(ncut)>0
            
            sz=size(handles.model.delft3dflow.domain(ad).depthZ);
            handles.model.delft3dflow.domain(ad).depth=handles.model.delft3dflow.domain(ad).depth(mcut(1)+1:sz(1)-mcut(2),ncut(1)+1:sz(2)-ncut(2));
            handles.model.delft3dflow.domain(ad).depthZ=handles.model.delft3dflow.domain(ad).depthZ(mcut(1)+1:sz(1)-mcut(2),ncut(1)+1:sz(2)-ncut(2));
            
            if mcut(1)>0 || ncut(1)>0
                % TODO Change m and n indices of attributes
                for i=1:handles.model.delft3dflow.domain(ad).nrObservationPoints
                    handles.model.delft3dflow.domain(ad).observationPoints(i).M=handles.model.delft3dflow.domain(ad).observationPoints(i).M - mcut(1);
                    handles.model.delft3dflow.domain(ad).observationPoints(i).N=handles.model.delft3dflow.domain(ad).observationPoints(i).N - ncut(1);
                end
            end
            
        end
        
        % New Domain
        % Attributes
        handles=ddb_makeDDModelNewAttributes(handles,ad,id2,handles.model.delft3dflow.domain(id2).attName);
        handles=ddb_removeDDModelAttributes(handles,ad);
        
        % Delete corner points and temporary grid
        plotCornerPoints('delete');
        plotTemporaryDDGrid('delete');
        
        handles.toolbox.dd.firstCornerPointM=NaN;
        handles.toolbox.dd.secondCornerPointM=NaN;
        handles.toolbox.dd.firstCornerPointN=NaN;
        handles.toolbox.dd.secondCornerPointN=NaN;
        
        setHandles(handles);
        
        ddb_refreshDomainMenu;
        
        % Generate dd boundaries
        generateDD;

        % Now replot all domains
        for id=1:handles.model.delft3dflow.nrDomains
            if id==ad
                ddb_plotDelft3DFLOW('plot','active',1,'visible',1,'domain',id);
            else
                ddb_plotDelft3DFLOW('plot','active',0,'visible',1,'domain',id);
            end
        end
        
        switch lower(handles.model.delft3dflow.domain(ad).initialConditions)
            case{'ini','trim','rst'}
                ddb_giveWarning('text',['The domain ' runid1 ' uses an initial conditions file. Please consider generating an initial conditions file for the domain ' runid2 ' as well.']);
        end
        
    else
        ddb_giveWarning('Warning','First select corner points!');
    end
    
end

% Clear original domain
handles.toolbox.dd.originalDomain=[];

%%
function clickFirstCornerPoint(m,n)

% First corner point was clicked
setInstructions({'','','Click grid point on active grid for second corner point'});

% Set values of corner points
handles=getHandles;
handles.toolbox.dd.firstCornerPointM=m;
handles.toolbox.dd.firstCornerPointN=n;
handles.toolbox.dd.secondCornerPointM=NaN;
handles.toolbox.dd.secondCornerPointN=NaN;
setHandles(handles);

% Plot markers on corner points
plotCornerPoints('plot');
plotTemporaryDDGrid('delete');

xg=handles.model.delft3dflow.domain(ad).gridX;
yg=handles.model.delft3dflow.domain(ad).gridY;
if ~isnan(m)
    ddb_clickPoint('cornerpoint','grid',xg,yg,'callback',@clickSecondCornerPoint,'single');
end

gui_updateActiveTab;

%%
function clickSecondCornerPoint(m,n)

clearInstructions;

handles=getHandles;
if ~isnan(m)
    handles.toolbox.dd.secondCornerPointM=m;
    handles.toolbox.dd.secondCornerPointN=n;
    setHandles(handles);
    plotCornerPoints('plot');
    plotTemporaryDDGrid('plot');
    ddb_setWindowButtonMotionFcn;
    gui_updateActiveTab;
end

%%
function plotTemporaryDDGrid(opt)

switch lower(opt)
    case{'plot'}
        
        % Delete existing grid
        h=findobj(gca,'Tag','TemporaryDDGrid');
        if ~isempty(h)
            delete(h);
        end
        
        %Plot new grid
        handles=getHandles;
        xg=handles.model.delft3dflow.domain(ad).gridX;
        yg=handles.model.delft3dflow.domain(ad).gridY;
        m1=handles.toolbox.dd.firstCornerPointM;
        n1=handles.toolbox.dd.firstCornerPointN;
        m2=handles.toolbox.dd.secondCornerPointM;
        n2=handles.toolbox.dd.secondCornerPointN;
        mm1=min(m1,m2);mm2=max(m1,m2);
        nn1=min(n1,n2);nn2=max(n1,n2);
        xg=xg(mm1:mm2,nn1:nn2);
        yg=yg(mm1:mm2,nn1:nn2);
        mref=handles.toolbox.dd.mRefinement;
        nref=handles.toolbox.dd.nRefinement;
        [x2,y2]=ddb_refineD3DGrid(xg,yg,mref,nref);
        z2=zeros(size(x2))+9000;
        grd=mesh(x2,y2,z2);
        set(grd,'FaceColor','none','EdgeColor','r','Tag','TemporaryDDGrid');
        
    case{'delete'}
        % Delete existing grid
        h=findobj(gca,'Tag','TemporaryDDGrid');
        if ~isempty(h)
            delete(h);
        end
end

%%
function plotCornerPoints(opt)

switch lower(opt)
    case{'plot'}
        
        handles=getHandles;
        
        % Delete old points
        if isfield(handles.toolbox.dd,'cornerPointHandles')
            hh=handles.toolbox.dd.cornerPointHandles;
            if ~isempty(hh)
                try
                    delete(hh);
                end
            end
        end
        
        % Now plot the corner points
        m1=handles.toolbox.dd.firstCornerPointM;
        m2=handles.toolbox.dd.secondCornerPointM;
        n1=handles.toolbox.dd.firstCornerPointN;
        n2=handles.toolbox.dd.secondCornerPointN;
        
        plt1=plot(handles.model.delft3dflow.domain(ad).gridX(m1,n1),handles.model.delft3dflow.domain(ad).gridY(m1,n1),'go');
        set(plt1,'MarkerEdgeColor','k','MarkerFaceColor','y','HitTest','off');
        set(plt1,'Tag','DDCornerPoint');
        
        plt2=[];
        if ~isnan(m2) && ~isnan(n2)
            plt2=plot(handles.model.delft3dflow.domain(ad).gridX(m2,n2),handles.model.delft3dflow.domain(ad).gridY(m2,n2),'go');
            set(plt2,'MarkerEdgeColor','k','MarkerFaceColor','y','HitTest','off');
            set(plt2,'Tag','DDCornerPoint');
        end
        
        handles.toolbox.dd.cornerPointHandles=[plt1 plt2];
        
        setHandles(handles);
        
    case{'delete'}
        h=findobj(gca,'Tag','DDCornerPoint');
        if ~isempty(h)
            delete(h);
        end
end

%%
function generateDD

handles=getHandles;

switch lower(handles.model.delft3dflow.name)
    case{'delft3dflow'}
    otherwise
        ddb_giveWarning('text',['Sorry, the Domain Decomposition toolbox does not support ' handles.model.delft3dflow.longName ' ...']);
        return
end

% Find DD boundaries
ddbound=[];
for i=1:handles.model.delft3dflow.nrDomains-1
    for j=i+1:handles.model.delft3dflow.nrDomains
        xg1=handles.model.delft3dflow.domain(i).gridX;
        yg1=handles.model.delft3dflow.domain(i).gridY;
        xg2=handles.model.delft3dflow.domain(j).gridX;
        yg2=handles.model.delft3dflow.domain(j).gridY;
        runid1=handles.model.delft3dflow.domain(i).runid;
        runid2=handles.model.delft3dflow.domain(j).runid;
        ddbound=ddb_findDDBoundaries(ddbound,xg1,yg1,xg2,yg2,runid1,runid2);
    end
end


% ddbound=handles.model.delft3dflow.DDBoundaries;


handles.model.delft3dflow.DDBoundaries=ddbound;

if ~isempty(ddbound)
    if handles.toolbox.dd.adjustBathymetry
        % Adjust bathymetries in all domains
        % This ensures that depths along boundaries in both domains are the same
        for i=1:handles.model.delft3dflow.nrDomains-1
            for j=i+1:handles.model.delft3dflow.nrDomains
                z1=handles.model.delft3dflow.domain(i).depth;
                z2=handles.model.delft3dflow.domain(j).depth;
                runid1=handles.model.delft3dflow.domain(i).runid;
                runid2=handles.model.delft3dflow.domain(j).runid;
                [z1,z2]=ddb_matchDDDepths(ddbound,z1,z2,runid1,runid2,handles.model.delft3dflow.domain(i).dpsOpt);
                handles.model.delft3dflow.domain(i).depth=z1;
                handles.model.delft3dflow.domain(j).depth=z2;
            end
        end
        % And save all dep files
        for id=1:handles.model.delft3dflow.nrDomains
            handles.model.delft3dflow.domain(id).depthZ=getDepthZ(handles.model.delft3dflow.domain(id).depth,handles.model.delft3dflow.domain(id).dpsOpt);
            % TODO make sure dep file has a name
            ddb_wldep('write',handles.model.delft3dflow.domain(id).depFile,handles.model.delft3dflow.domain(id).depth);
        end
    end
end


handles=ddb_Delft3DFLOW_plotDD(handles,'plot');

setHandles(handles);

% Save ddbound file
ddb_saveDDBoundFile(ddbound,handles.model.delft3dflow.ddFile);

ddb_writeDDBatchFile(handles.model.delft3dflow.ddFile);
