function ddb_Delft3DFLOW_openBoundaries(varargin)
%DDB_DELFT3DFLOW_OPENBOUNDARIES  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_Delft3DFLOW_openBoundaries(varargin)
%
%   Input:
%   varargin =
%
%
%
%
%   Example
%   ddb_Delft3DFLOW_openBoundaries
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

% $Id: ddb_Delft3DFLOW_openBoundaries.m 11463 2014-11-27 13:29:28Z ormondt $
% $Date: 2014-11-27 21:29:28 +0800 (Thu, 27 Nov 2014) $
% $Author: ormondt $
% $Revision: 11463 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/models/Delft3DFLOW/gui/ddb_Delft3DFLOW_openBoundaries.m $
% $Keywords: $

%%
handles=getHandles;

ddb_zoomOff;
ddb_setWindowButtonUpDownFcn;
ddb_setWindowButtonMotionFcn;

if isempty(varargin)
    ddb_refreshScreen;
%     iac=handles.model.delft3dflow.domain(ad).activeOpenBoundary;
%     handles.model.delft3dflow.domain(ad).activeBoundaryType=handles.model.delft3dflow.domain(ad).openBoundaries(iac).type;
%     handles.model.delft3dflow.domain(ad).activeBoundaryType=handles.model.delft3dflow.domain(ad).openBoundaries(iac).type;
    handles=ddb_Delft3DFLOW_plotAttributes(handles,'update','openboundaries');
    setHandles(handles);
else
    opt=varargin{1};
    if length(varargin)>1
        opt2=varargin{2};
    end
    
    switch(lower(opt))
        
        case{'add'}
            handles.model.delft3dflow.domain(ad).selectOpenBoundary=0;
            handles.model.delft3dflow.domain(ad).changeOpenBoundary=0;
            handles.model.delft3dflow.domain(ad).deleteOpenBoundary=0;
            if handles.model.delft3dflow.domain(ad).addOpenBoundary
                handles.editMode='add';
                ddb_dragLine(@addOpenBoundary,'method','alonggridline','x',handles.model.delft3dflow.domain(ad).gridX,'y',handles.model.delft3dflow.domain(ad).gridY);
                setInstructions({'','','Drag line on map for new open boundary'});
            else
                set(gcf, 'windowbuttondownfcn',[]);
                clearInstructions;
            end
            setHandles(handles);
            
        case{'delete'}
            handles.model.delft3dflow.domain(ad).addOpenBoundary=0;
            handles.model.delft3dflow.domain(ad).selectOpenBoundary=0;
            handles.model.delft3dflow.domain(ad).changeOpenBoundary=0;
            ddb_clickObject('tag','openboundary','callback',@deleteOpenBoundaryFromMap);
            setInstructions({'','','Select open boundary from map to delete'});
            setHandles(handles);
            if handles.model.delft3dflow.domain(ad).deleteOpenBoundary
                % Delete open boundary selected from list
                deleteOpenBoundaries;
            end
            
        case{'select'}
            handles.model.delft3dflow.domain(ad).addOpenBoundary=0;
            handles.model.delft3dflow.domain(ad).deleteOpenBoundary=0;
            handles.model.delft3dflow.domain(ad).changeOpenBoundary=0;
            if handles.model.delft3dflow.domain(ad).selectOpenBoundary
                ddb_clickObject('tag','openboundary','callback',@selectOpenBoundaryFromMap);
                setInstructions({'','','Select open boundary from map'});
            else
                set(gcf, 'windowbuttondownfcn',[]);
                clearInstructions;
            end
            setHandles(handles);
            
        case{'change'}
            handles.model.delft3dflow.domain(ad).addOpenBoundary=0;
            handles.model.delft3dflow.domain(ad).selectOpenBoundary=0;
            handles.model.delft3dflow.domain(ad).deleteOpenBoundary=0;
            if handles.model.delft3dflow.domain(ad).changeOpenBoundary
                ddb_clickObject('tag','openboundary','callback',@changeOpenBoundaryFromMap);
                setInstructions({'','','Select open boundary to change from map'});
            else
                set(gcf, 'windowbuttondownfcn',[]);
                clearInstructions;
            end
            setHandles(handles);
            
        case{'editindices'}
            handles.model.delft3dflow.domain(ad).addOpenBoundary=0;
            handles.model.delft3dflow.domain(ad).selectOpenBoundary=0;
            handles.model.delft3dflow.domain(ad).changeOpenBoundary=0;
            handles.model.delft3dflow.domain(ad).deleteOpenBoundary=0;
            handles.editMode='edit';
            n=handles.model.delft3dflow.domain(ad).activeOpenBoundary;
            xg=handles.model.delft3dflow.domain(ad).gridX;
            yg=handles.model.delft3dflow.domain(ad).gridY;
            zg=handles.model.delft3dflow.domain(ad).depthZ;
            kcs=handles.model.delft3dflow.domain(ad).kcs;
            [xb,yb,zb,alphau,alphav,side,orientation]=delft3dflow_getBoundaryCoordinates(handles.model.delft3dflow.domain(ad).openBoundaries(n),xg,yg,zg,kcs);
            handles.model.delft3dflow.domain(ad).openBoundaries(n).x=xb;
            handles.model.delft3dflow.domain(ad).openBoundaries(n).y=yb;
            handles.model.delft3dflow.domain(ad).openBoundaries(n).depth=zb;
            handles.model.delft3dflow.domain(ad).openBoundaries(n).side=side;
            handles.model.delft3dflow.domain(ad).openBoundaries(n).orientation=orientation;
            handles.model.delft3dflow.domain(ad).openBoundaries(n).alphau=alphau;
            handles.model.delft3dflow.domain(ad).openBoundaries(n).alphav=alphav;
            m1str=num2str(handles.model.delft3dflow.domain(ad).openBoundaries(n).M1);
            m2str=num2str(handles.model.delft3dflow.domain(ad).openBoundaries(n).M2);
            n1str=num2str(handles.model.delft3dflow.domain(ad).openBoundaries(n).N1);
            n2str=num2str(handles.model.delft3dflow.domain(ad).openBoundaries(n).N2);
            name=['('  m1str ',' n1str ')...(' m2str ',' n2str ')'];
            if strcmpi(handles.model.delft3dflow.domain(ad).openBoundaries(n).name(1),'(') && ...
                    strcmpi(handles.model.delft3dflow.domain(ad).openBoundaries(n).name(end),')')
                handles.model.delft3dflow.domain(ad).openBoundaries(n).name=name;
                handles.model.delft3dflow.domain(ad).openBoundaryNames{n}=name;
            end
            handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','openboundaries');
            clearInstructions;
            setHandles(handles);
            refreshOpenBoundaries;
            
        case{'editname'}
            handles.model.delft3dflow.domain(ad).addOpenBoundary=0;
            handles.model.delft3dflow.domain(ad).selectOpenBoundary=0;
            handles.model.delft3dflow.domain(ad).changeOpenBoundary=0;
            handles.model.delft3dflow.domain(ad).deleteOpenBoundary=0;
            n=handles.model.delft3dflow.domain(ad).activeOpenBoundary;
            handles.model.delft3dflow.domain(ad).openBoundaryNames{n}=handles.model.delft3dflow.domain(ad).openBoundaries(n).name;
            handles.model.delft3dflow.domain(ad).bctChanged=1;
            handles.model.delft3dflow.domain(ad).bccChanged=1;
            handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','openboundaries');
            setHandles(handles);
            clearInstructions;
            refreshOpenBoundaries;
            
        case{'selectfromlist'}
            handles.model.delft3dflow.domain(ad).addOpenBoundary=0;
            handles.model.delft3dflow.domain(ad).selectOpenBoundary=0;
            handles.model.delft3dflow.domain(ad).changeOpenBoundary=0;
            % Delete selected open boundary next time delete is clicked
            handles.model.delft3dflow.domain(ad).deleteOpenBoundary=1;
            handles=ddb_Delft3DFLOW_plotAttributes(handles,'update','openboundaries');
            clearInstructions;
            setHandles(handles);
            refreshOpenBoundaries;
            
        case{'selecttype'}
            tp=handles.model.delft3dflow.domain(ad).openBoundaries(handles.model.delft3dflow.domain(ad).activeOpenBoundary).type;
%            tp=handles.model.delft3dflow.domain(ad).activeBoundaryType;
%            if strcmpi(tp,handles.model.delft3dflow.domain(ad).openBoundaries(iac).type)
%                % No change in boundary type
%                return
%            end
%             buttonname = questdlg('Boundary conditions will be set to 0.0! Continue?', ...
%                 '', ...
%                 'Cancel', 'OK', 'OK');
%             switch buttonname,
%                 case 'Cancel'
%                     return;
%             end
            iac=handles.model.delft3dflow.domain(ad).activeOpenBoundaries;
            for ii=1:length(iac)
                n=iac(ii);
                handles.model.delft3dflow.domain(ad).openBoundaries(n).type=tp;
%                 handles=resetBoundaryConditions(handles,n);
            end
            handles.model.delft3dflow.domain(ad).bctChanged=1;
            handles.model.delft3dflow.domain(ad).bccChanged=1;
            setHandles(handles);
            refreshOpenBoundaries;
            
        case{'selectforcing'}
            fc=handles.model.delft3dflow.domain(ad).openBoundaries(handles.model.delft3dflow.domain(ad).activeOpenBoundary).forcing;
%             if strcmpi(fc,handles.model.delft3dflow.domain(ad).openBoundaries(handles.model.delft3dflow.domain(ad).activeOpenBoundary).forcing)
%                 % No change in boundary forcing
%                 return
%             end
%             buttonname = questdlg('Boundary conditions will be set to 0.0! Continue?', ...
%                 '', ...
%                 'Cancel', 'OK', 'OK');
%             switch buttonname,
%                 case 'Cancel'
%                     return;
%             end
            iac=handles.model.delft3dflow.domain(ad).activeOpenBoundaries;
            for ii=1:length(iac)
                n=iac(ii);
                handles.model.delft3dflow.domain(ad).openBoundaries(n).forcing=fc;
%                 handles=resetBoundaryConditions(handles,n);
            end
            handles=ddb_countOpenBoundaries(handles,ad);
            handles.model.delft3dflow.domain(ad).bctChanged=1;
            setHandles(handles);
            refreshOpenBoundaries;
            
        case{'editalpha'}
            alp=handles.model.delft3dflow.domain(ad).openBoundaries(handles.model.delft3dflow.domain(ad).activeOpenBoundary).alpha;
            iac=handles.model.delft3dflow.domain(ad).activeOpenBoundaries;
            for ii=1:length(iac)
                n=iac(ii);
                handles.model.delft3dflow.domain(ad).openBoundaries(n).alpha=alp;
            end
            handles=ddb_countOpenBoundaries(handles,ad);
            setHandles(handles);
            refreshOpenBoundaries;
            
        case{'selectprofile'}
            prf=handles.model.delft3dflow.domain(ad).openBoundaries(handles.model.delft3dflow.domain(ad).activeOpenBoundary).profile;
            iac=handles.model.delft3dflow.domain(ad).activeOpenBoundaries;
            for ii=1:length(iac)
                n=iac(ii);
                handles.model.delft3dflow.domain(ad).openBoundaries(n).profile=prf;
                switch lower(handles.model.delft3dflow.domain(ad).openBoundaries(n).type)
                    case{'z','n'}
                        handles.model.delft3dflow.domain(ad).openBoundaries(n).profile='uniform';
                    case{'q','t'}
                        if strcmpi(handles.model.delft3dflow.domain(ad).openBoundaries(n).profile,'3d-profile')
                            handles.model.delft3dflow.domain(ad).openBoundaries(n).profile='uniform';
                        end
                    case{'r'}
                        if strcmpi(handles.model.delft3dflow.domain(ad).openBoundaries(n).profile,'logarithmic')
                            handles.model.delft3dflow.domain(ad).openBoundaries(n).profile='uniform';
                        end
                end
                if size(handles.model.delft3dflow.domain(ad).openBoundaries(n).timeSeriesA,2)<handles.model.delft3dflow.domain(ad).KMax
                    for k=2:handles.model.delft3dflow.domain(ad).KMax
                        handles.model.delft3dflow.domain(ad).openBoundaries(n).timeSeriesA(:,k)=handles.model.delft3dflow.domain(ad).openBoundaries(n).timeSeriesA(:,1);
                        handles.model.delft3dflow.domain(ad).openBoundaries(n).timeSeriesB(:,k)=handles.model.delft3dflow.domain(ad).openBoundaries(n).timeSeriesB(:,1);
                    end
                end
            end
            handles.model.delft3dflow.domain(ad).bctChanged=1;
            setHandles(handles);
            refreshOpenBoundaries;
            
        case{'flowconditions'}
            ddb_zoomOff;
            set(gcf, 'windowbuttondownfcn',   []);
            i=handles.model.delft3dflow.domain(ad).activeOpenBoundary;
            frc=handles.model.delft3dflow.domain(ad).openBoundaries(i).forcing;
            switch frc
                case{'A'}
                    ddb_editD3DFlowConditionsAstronomic;
                case{'H'}
                    ddb_editD3DFlowConditionsHarmonic;
                case{'T'}
                    % Check if there is a bct file and whether it has has been loaded
                    if ~isempty(handles.model.delft3dflow.domain(ad).bctFile)
                        if ~handles.model.delft3dflow.domain(ad).bctLoaded
                            wb = waitbox('Reading bct file ...');
                            try
                                handles=ddb_readBctFile(handles,ad);
                            catch
                                close(wb);
                                ddb_giveWarning('text','An error occured while reading bct file!');
                                return
                            end
                            close(wb);
                            handles.model.delft3dflow.domain(ad).bctLoaded=1;
                            setHandles(handles);
                        end
                    end
                    ddb_editD3DFlowConditionsTimeSeries;
                    handles=getHandles;
                    handles.model.delft3dflow.domain(ad).bctChanged=1;
                    setHandles(handles);
                case{'Q'}
%                    EditD3DFlowConditionsQHRelation;
            end
            
        case{'transportconditions'}
            ddb_zoomOff;
            set(gcf, 'windowbuttondownfcn',   []);
            % Check if there is a bct file and whether it has has been loaded
            if ~isempty(handles.model.delft3dflow.domain(ad).bccFile)
                if ~handles.model.delft3dflow.domain(ad).bccLoaded
                    
                    wb = waitbox('Reading bcc file ...');
                    try
                        handles=ddb_readBccFile(handles,ad);
                    catch
                        close(wb);
                        ddb_giveWarning('text','An error occured while reading bcc file!');
                        return
                    end
                    close(wb);
                    handles.model.delft3dflow.domain(ad).bccLoaded=1;
                    setHandles(handles);
                end
            end
            ddb_editD3DFlowTransportConditionsTimeSeries;
            handles=getHandles;
            handles.model.delft3dflow.domain(ad).bccChanged=1;
            setHandles(handles);
            
        case{'open'}
            handles.model.delft3dflow.domain(ad).addOpenBoundary=0;
            handles.model.delft3dflow.domain(ad).selectOpenBoundary=0;
            handles.model.delft3dflow.domain(ad).changeOpenBoundary=0;
            handles.model.delft3dflow.domain(ad).deleteOpenBoundary=0;
            switch lower(opt2)
                case{'bnd'}
                    tp='*.bnd';
                    txt='Select Boundary Definition File';
                case{'bca'}
                    tp='*.bca';
                    txt='Select Astronomical Conditions File';
                case{'cor'}
                    tp='*.cor';
                    txt='Select Astronomical Corrections File';
                case{'bch'}
                    tp='*.bch';
                    txt='Select Harmonic Conditions File';
                case{'bct'}
                    tp='*.bct';
                    txt='Select Time Series Conditions File';
                case{'bcc'}
                    tp='*.bcc';
                    txt='Select Harmonic Conditions File';
            end
            [filename, pathname, filterindex] = uigetfile(tp,txt);
            if pathname~=0
                curdir=[lower(cd) '\'];
                if ~strcmpi(curdir,pathname)
                    filename=[pathname filename];
                end
                switch lower(opt2)
                    case{'bnd'}
                        handles.model.delft3dflow.domain(ad).bndFile=filename;
                        handles=ddb_readBndFile(handles,ad);
                        handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','openboundaries');
                    case{'bca'}
                        handles.model.delft3dflow.domain(ad).bcaFile=filename;
                        handles=ddb_readBcaFile(handles,ad);
                    case{'cor'}
                        handles.model.delft3dflow.domain(ad).corFile=filename;
                        handles=ddb_readCorFile(handles,ad);
                    case{'bch'}
                        handles.model.delft3dflow.domain(ad).bchFile=filename;
                        handles=ddb_readBchFile(handles,ad);
                    case{'bct'}
                        handles.model.delft3dflow.domain(ad).bctFile=filename;
                        handles=ddb_readBctFile(handles,ad);
                        handles.model.delft3dflow.domain(ad).bctChanged=0;
                    case{'bcc'}
                        handles.model.delft3dflow.domain(ad).bccFile=filename;
                        handles=ddb_readBccFile(handles,ad);
                        handles.model.delft3dflow.domain(ad).bccChanged=0;
                end
                clearInstructions;
                setHandles(handles);
                refreshOpenBoundaries;
            end
            
        case{'save'}
            handles.model.delft3dflow.domain(ad).addOpenBoundary=0;
            handles.model.delft3dflow.domain(ad).selectOpenBoundary=0;
            handles.model.delft3dflow.domain(ad).changeOpenBoundary=0;
            handles.model.delft3dflow.domain(ad).deleteOpenBoundary=0;
            switch lower(opt2)
                case{'bnd'}
                    tp='*.bnd';
                    txt='Select Boundary Definition File';
                case{'bca'}
                    tp='*.bca';
                    txt='Select Astronomical Conditions File';
                case{'cor'}
                    tp='*.cor';
                    txt='Select Astronomical Corrections File';
                case{'bch'}
                    tp='*.bch';
                    txt='Select Harmonic Conditions File';
                case{'bct'}
                    tp='*.bct';
                    txt='Select Time Series Conditions File';
                case{'bcc'}
                    tp='*.bcc';
                    txt='Select Transport Conditions File';
            end
            [filename, pathname, filterindex] = uiputfile(tp,txt);
            if pathname~=0
                curdir=[lower(cd) '\'];
                if ~strcmpi(curdir,pathname)
                    filename=[pathname filename];
                end
                switch lower(opt2)
                    case{'bnd'}
                        handles.model.delft3dflow.domain(ad).bndFile=filename;
                        ddb_saveBndFile(handles.model.delft3dflow.domain(ad).openBoundaries,handles.model.delft3dflow.domain(ad).bndFile);
                    case{'bca'}
                        handles.model.delft3dflow.domain(ad).bcaFile=filename;
                        handles=ddb_saveBcaFile(handles,ad);
                    case{'cor'}
                        handles.model.delft3dflow.domain(ad).corFile=filename;
                        handles=ddb_saveCorFile(handles,ad);
                    case{'bch'}
                        handles.model.delft3dflow.domain(ad).bchFile=filename;
                        handles=ddb_saveBchFile(handles,ad);
                    case{'bct'}
                        handles.model.delft3dflow.domain(ad).bctFile=filename;
                        handles.model.delft3dflow.domain(ad).bctChanged=0;
                        ddb_saveBctFile(handles,ad);
                    case{'bcc'}
                        handles.model.delft3dflow.domain(ad).bccFile=filename;
                        handles.model.delft3dflow.domain(ad).bccChanged=0;
                        ddb_saveBccFile(handles,ad);
                end
                clearInstructions;
                setHandles(handles);
                refreshOpenBoundaryFiles;
            end
            
    end
end


%%
function addOpenBoundary(x,y)

x1=x(1);x2=x(2);
y1=y(1);y2=y(2);
handles=getHandles;
id=ad;
[m1,n1]=findcornerpoint(x1,y1,handles.model.delft3dflow.domain(id).gridX,handles.model.delft3dflow.domain(id).gridY);
[m2,n2]=findcornerpoint(x2,y2,handles.model.delft3dflow.domain(id).gridX,handles.model.delft3dflow.domain(id).gridY);
[m1,n1,m2,n2,ok]=checkBoundaryPoints(m1,n1,m2,n2,1);

if ok==1
    
    if handles.model.delft3dflow.domain(ad).changeOpenBoundary
        iac=handles.model.delft3dflow.domain(ad).activeOpenBoundary;
    else
        % Add mode
        handles.model.delft3dflow.domain(ad).nrOpenBoundaries=handles.model.delft3dflow.domain(ad).nrOpenBoundaries+1;
        iac=handles.model.delft3dflow.domain(ad).nrOpenBoundaries;
    end
    
    handles.model.delft3dflow.domain(ad).openBoundaries(iac).M1=m1;
    handles.model.delft3dflow.domain(ad).openBoundaries(iac).N1=n1;
    handles.model.delft3dflow.domain(ad).openBoundaries(iac).M2=m2;
    handles.model.delft3dflow.domain(ad).openBoundaries(iac).N2=n2;
    
    handles.model.delft3dflow.domain(ad).openBoundaries=delft3dflow_setDefaultBoundaryType(handles.model.delft3dflow.domain(ad).openBoundaries,iac);
    
    t0=handles.model.delft3dflow.domain(ad).startTime;
    t1=handles.model.delft3dflow.domain(ad).stopTime;
    nrsed=handles.model.delft3dflow.domain(ad).nrSediments;
    nrtrac=handles.model.delft3dflow.domain(ad).nrTracers;
    nrharmo=handles.model.delft3dflow.domain(ad).nrHarmonicComponents;
    x=handles.model.delft3dflow.domain(ad).gridX;
    y=handles.model.delft3dflow.domain(ad).gridY;
    depthZ=handles.model.delft3dflow.domain(ad).depthZ;
    kcs=handles.model.delft3dflow.domain(ad).kcs;
    kmax=handles.model.delft3dflow.domain(ad).KMax;
    
    handles.model.delft3dflow.domain(ad).openBoundaries=delft3dflow_initializeOpenBoundary(handles.model.delft3dflow.domain(ad).openBoundaries,iac, ...
        t0,t1,nrsed,nrtrac,nrharmo,x,y,depthZ,kcs,kmax);
    
    handles.model.delft3dflow.domain(ad).openBoundaries(iac).name=['(' num2str(m1) ',' num2str(n1) ')...(' num2str(m2) ',' num2str(n2) ')'];
    handles.model.delft3dflow.domain(ad).openBoundaryNames{iac}=handles.model.delft3dflow.domain(ad).openBoundaries(iac).name;
    handles.model.delft3dflow.domain(ad).activeOpenBoundary=iac;
    handles.model.delft3dflow.domain(ad).activeOpenBoundaries=iac;

    handles.model.delft3dflow.domain(ad).bctChanged=1;
    handles.model.delft3dflow.domain(ad).bccChanged=1;
    
    handles=ddb_countOpenBoundaries(handles,ad);
    
    handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','openboundaries');
    
    if handles.model.delft3dflow.domain(ad).changeOpenBoundary
        ddb_clickObject('tag','openboundary','callback',@changeOpenBoundaryFromMap);
        setInstructions({'','','Select open boundary'});
    else
        ddb_dragLine(@addOpenBoundary,'method','alonggridline','x',handles.model.delft3dflow.domain(ad).gridX,'y',handles.model.delft3dflow.domain(ad).gridY);
        setInstructions({'','','Drag line on map for new open boundary'});
    end
end
setHandles(handles);
refreshOpenBoundaries;

%%
function deleteOpenBoundaries
handles=getHandles;
iac=handles.model.delft3dflow.domain(ad).activeOpenBoundaries;
for ii=length(iac):-1:1
    handles.model.delft3dflow.domain(ad).activeOpenBoundary=iac(ii);
    setHandles(handles);
    deleteOpenBoundary;    
    handles=getHandles;
end

%%
function deleteOpenBoundary

handles=getHandles;

nrbnd=handles.model.delft3dflow.domain(ad).nrOpenBoundaries;

if nrbnd>0
    iac=handles.model.delft3dflow.domain(ad).activeOpenBoundary;
    handles=ddb_Delft3DFLOW_plotAttributes(handles,'delete','openboundaries');
    if nrbnd>1
        handles.model.delft3dflow.domain(ad).openBoundaries=removeFromStruc(handles.model.delft3dflow.domain(ad).openBoundaries,iac);
        handles.model.delft3dflow.domain(ad).openBoundaryNames=removeFromCellArray(handles.model.delft3dflow.domain(ad).openBoundaryNames,iac);
    else
        handles.model.delft3dflow.domain(ad).openBoundaryNames={''};
        handles.model.delft3dflow.domain(ad).activeOpenBoundary=1;
        handles.model.delft3dflow.domain(ad).openBoundaries(1).name='';
        handles.model.delft3dflow.domain(ad).openBoundaries(1).M1=[];
        handles.model.delft3dflow.domain(ad).openBoundaries(1).M2=[];
        handles.model.delft3dflow.domain(ad).openBoundaries(1).N1=[];
        handles.model.delft3dflow.domain(ad).openBoundaries(1).N2=[];
        handles.model.delft3dflow.domain(ad).openBoundaries(1).type='Z';
        handles.model.delft3dflow.domain(ad).openBoundaries(1).forcing='A';
        handles.model.delft3dflow.domain(ad).openBoundaries(1).profile='uniform';
        handles.model.delft3dflow.domain(ad).openBoundaries(1).alpha=0;
        clearInstructions;
    end
    if iac==nrbnd
        iac=nrbnd-1;
    end
    handles.model.delft3dflow.domain(ad).nrOpenBoundaries=nrbnd-1;
    handles.model.delft3dflow.domain(ad).activeOpenBoundary=max(iac,1);
    handles.model.delft3dflow.domain(ad).activeOpenBoundaries=handles.model.delft3dflow.domain(ad).activeOpenBoundary;
    
    handles=ddb_countOpenBoundaries(handles,ad);

    handles.model.delft3dflow.domain(ad).bctChanged=1;
    handles.model.delft3dflow.domain(ad).bccChanged=1;
    
    handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','openboundaries');
    setHandles(handles);
    refreshOpenBoundaries;
    %    refreshOpenBoundaryFiles;
end

%%
function deleteOpenBoundaryFromMap(h)

handles=getHandles;
iac=get(h,'UserData');
handles.model.delft3dflow.domain(ad).activeOpenBoundary=iac;
setHandles(handles);
deleteOpenBoundary;

%%
function selectOpenBoundaryFromMap(h)

handles=getHandles;
iac=get(h,'UserData');
handles.model.delft3dflow.domain(ad).activeOpenBoundary=iac;
ddb_Delft3DFLOW_plotAttributes(handles,'update','openboundaries');
setHandles(handles);
refreshOpenBoundaries;

%%
function changeOpenBoundaryFromMap(h)

handles=getHandles;
iac=get(h,'UserData');
handles.model.delft3dflow.domain(ad).activeOpenBoundary=iac;
ddb_Delft3DFLOW_plotAttributes(handles,'update','openboundaries');
setHandles(handles);
refreshOpenBoundaries;
ddb_dragLine(@addOpenBoundary,'free');
setInstructions({'','','Drag new open boundary'});

%%
function refreshOpenBoundaries

handles=getHandles;

iac=handles.model.delft3dflow.domain(ad).activeOpenBoundary;

handles.model.delft3dflow.domain(ad).activeBoundaryType=handles.model.delft3dflow.domain(ad).openBoundaries(iac).type;
handles.model.delft3dflow.domain(ad).activeBoundaryForcing=handles.model.delft3dflow.domain(ad).openBoundaries(iac).forcing;

if handles.model.delft3dflow.domain(ad).KMax>1
    switch lower(handles.model.delft3dflow.domain(ad).openBoundaries(iac).type)
        case{'z','n'}
            handles.model.delft3dflow.domain(ad).profileTexts={'Uniform'};
            handles.model.delft3dflow.domain(ad).profileOptions={'uniform'};
        case{'c'}
            handles.model.delft3dflow.domain(ad).profileTexts={'Uniform','Logarithmic','Per Layer'};
            handles.model.delft3dflow.domain(ad).profileOptions={'uniform','logarithmic','3d-profile'};
        case{'r'}
            handles.model.delft3dflow.domain(ad).profileTexts={'Uniform','Per Layer'};
            handles.model.delft3dflow.domain(ad).profileOptions={'uniform','3d-profile'};
        case{'t','q'}
            handles.model.delft3dflow.domain(ad).profileTexts={'Uniform','Logarithmic'};
            handles.model.delft3dflow.domain(ad).profileOptions={'uniform','logarithmic'};
    end
else
    handles.model.delft3dflow.domain(ad).profileTexts={'Uniform'};
    handles.model.delft3dflow.domain(ad).profileOptions={'uniform'};
end

setHandles(handles);

gui_updateActiveTab;

refreshOpenBoundaryFiles;

%%
function refreshOpenBoundaryFiles
gui_updateActiveTab;

%%
function [m1,n1,m2,n2,ok]=checkBoundaryPoints(m1,n1,m2,n2,icp)

handles=getHandles;

kcs=handles.model.delft3dflow.domain(ad).kcs;

ok=0;

if m1~=m2 && n1~=n2
    return
end

if icp==1
    
    if m1==m2 && n1==n2
        return
    end
    
    if m2~=m1
        if m2>m1
            m1=m1+1;
            mm1=m1;
            mm2=m2;
        else
            m2=m2+1;
            mm1=m2;
            mm2=m1;
        end
        sumkcs1=sum(kcs(mm1:mm2,n1));
        sumkcs2=sum(kcs(mm1:mm2,n1+1));
        if sumkcs1==mm2-mm1+1 && sumkcs2==0
            % upper
            ok=1;
            n1=n1+1;
            n2=n1;
        elseif sumkcs2==mm2-mm1+1 && sumkcs1==0
            % lower
            ok=1;
        else
            ok=0;
        end
        if mm2==mm1 && (kcs(mm2+1,n1)==1 || kcs(mm2-1,n1)==1)
            ok=0;
        end
    else
        if n2>n1
            n1=n1+1;
            nn1=n1;
            nn2=n2;
        else
            n2=n2+1;
            nn1=n2;
            nn2=n1;
        end
        sumkcs1=sum(kcs(m1,nn1:nn2));
        sumkcs2=sum(kcs(m1+1,nn1:nn2));
        if sumkcs1==nn2-nn1+1 && sumkcs2==0
            % right
            ok=1;
            m1=m1+1;
            m2=m1;
        elseif sumkcs2==nn2-nn1+1 && sumkcs1==0
            % left
            ok=1;
        else
            ok=0;
        end
        if nn2==nn1 && (kcs(m1,nn2+1)==1 || kcs(m1,nn2-1)==1)
            ok=0;
        end
    end
end

%%
function handles=resetBoundaryConditions(handles,iac)

kmax=handles.model.delft3dflow.domain(ad).KMax;

zeros2d=zeros(2,1);
zeros3d=zeros(2,kmax);

if kmax>1
    switch lower(handles.model.delft3dflow.domain(ad).openBoundaries(iac).type)
        case{'z','n'}
            handles.model.delft3dflow.domain(ad).openBoundaries(iac).profile='uniform';
        case{'q','t'}
            if strcmpi(handles.model.delft3dflow.domain(ad).openBoundaries(iac).profile,'3d-profile')
                handles.model.delft3dflow.domain(ad).openBoundaries(iac).profile='uniform';
            end
        case{'r'}
            if strcmpi(handles.model.delft3dflow.domain(ad).openBoundaries(iac).profile,'logarithmic')
                handles.model.delft3dflow.domain(ad).openBoundaries(iac).profile='uniform';
            end
    end
else
    handles.model.delft3dflow.domain(ad).openBoundaries(iac).profile='uniform';
end

% Timeseries
t0=handles.model.delft3dflow.domain(ad).openBoundaries(iac).timeSeriesT;
handles.model.delft3dflow.domain(ad).openBoundaries(iac).timeSeriesT=[t0(1);t0(end)];
switch lower(handles.model.delft3dflow.domain(ad).openBoundaries(iac).profile)
    case{'3d-profile'}
        handles.model.delft3dflow.domain(ad).openBoundaries(iac).timeSeriesA=zeros3d;
        handles.model.delft3dflow.domain(ad).openBoundaries(iac).timeSeriesB=zeros3d;
    otherwise
        handles.model.delft3dflow.domain(ad).openBoundaries(iac).timeSeriesA=zeros2d;
        handles.model.delft3dflow.domain(ad).openBoundaries(iac).timeSeriesB=zeros2d;
end
handles.model.delft3dflow.domain(ad).openBoundaries(iac).nrTimeSeries=2;

% Harmonic
nrharmo=2;
handles.model.delft3dflow.domain(ad).openBoundaries(iac).harmonicAmpA=zeros(1,nrharmo);
handles.model.delft3dflow.domain(ad).openBoundaries(iac).harmonicAmpB=zeros(1,nrharmo);
handles.model.delft3dflow.domain(ad).openBoundaries(iac).harmonicPhaseA=zeros(1,nrharmo);
handles.model.delft3dflow.domain(ad).openBoundaries(iac).harmonicPhaseB=zeros(1,nrharmo);

% QH
handles.model.delft3dflow.domain(ad).openBoundaries(iac).QHDischarge =[0.0 100.0];
handles.model.delft3dflow.domain(ad).openBoundaries(iac).QHWaterLevel=[0.0 0.0];
