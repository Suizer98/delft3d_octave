function ddb_TsunamiToolbox_okada(varargin)
%DDB_TSUNAMITOOLBOX_OKADA  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_TsunamiToolbox_okada(varargin)
%
%   Input:
%   varargin =
%
%
%
%
%   Example
%   ddb_TsunamiToolbox_okada
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
    handles=getHandles;
    h=findobj(gca,'Tag','Plates');
    if isempty(h)
        dr=handles.toolbox.tsunami.dataDir;
        load([dr 'plates.mat']);
        cs1=handles.screenParameters.coordinateSystem;
        if ~strcmpi(cs1.type,'geographic')
            cs0.name='WGS 84';
            cs0.type='geographic';
            [platesx,platesy]=ddb_coordConvert(platesx,platesy,cs0,cs1);
        end
        h=plot(platesx,platesy);
        set(h,'Color',[1.0 0.5 0.00]);
        set(h,'Tag','Plates');
        set(h,'LineWidth',1.5);
        set(h,'HitTest','off');
    end
    ddb_plotTsunami('activate');
else
    %Options selected
    opt=lower(varargin{1});
    switch opt
        case{'editmw'}
            editMw;
        case{'drawfaultline'}
            drawFaultLine;
        case{'computewaterlevel'}
            handles=getHandles;     
            switch lower(handles.activeModel.name)
                case{'delft3dflow'}
                        computeWaterLevel_delft3dflow(varargin{2});                        
                case{'dflowfm'}
                        computeWaterLevel_dflowfm(varargin{2});                                
                otherwise
                    ddb_giveWarning('text',['Sorry, the tsunami toolbox does not support: ' handles.activeModel.name   ' ...']);
                    return
            end
        case{'loaddata'}
            loadTableData;
        case{'savedata'}
            saveTableData;
    end
end

%%
function editMw

handles=getHandles;

handles=updateTsunamiValues(handles,'mw');

if handles.toolbox.tsunami.updateTable
    handles=updateTableValues(handles);
end

setHandles(handles);

%%
function loadTableData

handles=getHandles;

[filename, pathname, filterindex] = uigetfile('*.xml', 'Select Tsunami File','');

if filename==0
    return
end

filename=[pathname filename];
handles.toolbox.tsunami.tsunameTableFile=[pathname filename];
handles=ddb_loadTsunamiTableFile(handles,filename);
handles=convertFaultCoordinates(handles,'latlon2xy');
handles=computeLengthAndStrike(handles);

% Update 'bulk' parameters
handles=updateTsunamiValues(handles,'length');

setHandles(handles);

plotFaultLine;

%%
function plotFaultLine

handles=getHandles;

ddb_zoomOff;

if strcmpi(handles.screenParameters.coordinateSystem.type,'geographic')
    x=handles.toolbox.tsunami.segmentLon;
    y=handles.toolbox.tsunami.segmentLat;
else
    x=handles.toolbox.tsunami.segmentX;
    y=handles.toolbox.tsunami.segmentY;
end

handles=deleteFaultLine(handles);
h=gui_polyline('plot','x',x,'y',y,'tag','tsunamifault','marker','o','changecallback',@changeFaultLine);
handles.toolbox.tsunami.faulthandle=h;

setHandles(handles);

%%
function saveTableData

handles=getHandles;

[filename, pathname, filterindex] = uiputfile('*.xml', 'Select Tsunami XML File','');
if filename==0
    return
end
filename=[pathname filename];
handles.toolbox.tsunami.tsunameTableFile=filename;
setHandles(handles);
ddb_saveTsunamiTableFile(handles,filename);


%%
function drawFaultLine

handles=getHandles;

xmldir=handles.toolbox.tsunami.xmlDir;
xmlfile='toolbox.tsunami.initialparameters.xml';

h=handles;

[h,ok]=gui_newWindow(h,'xmldir',xmldir,'xmlfile',xmlfile,'iconfile',[handles.settingsDir filesep 'icons' filesep 'deltares.gif']);

if ok
    
    handles=h;
    
    ddb_zoomOff;

    handles=deleteFaultLine(handles);

    gui_polyline('draw','Tag','tsunamifault','Marker','o','createcallback',@createFaultLine,'changecallback',@changeFaultLine,'closed',0);

    handles.toolbox.tsunami.newFaultLine=1;

    setHandles(handles);

end

%%
function handles=computeLengthAndStrike(handles)
% Compute new length
x = handles.toolbox.tsunami.segmentX;
y = handles.toolbox.tsunami.segmentY;
pd=pathdistance(x,y);
handles.toolbox.tsunami.length=pd(end)/1000;

% Compute new strike
handles.toolbox.tsunami.segmentStrike=[];
handles.toolbox.tsunami.segmentStrike(1)=90-180*atan2(y(2)-y(1),x(2)-x(1))/pi;
for i=2:length(x)
    handles.toolbox.tsunami.segmentStrike(i)=90-180*atan2(y(i)-y(i-1),x(i)-x(i-1))/pi;
end

%%
function createFaultLine(h,x,y,nr)

handles=getHandles;

handles.toolbox.tsunami.faulthandle=h;

if strcmpi(handles.screenParameters.coordinateSystem.type,'geographic')
    handles.toolbox.tsunami.segmentLon=x;
    handles.toolbox.tsunami.segmentLat=y;
    handles=convertFaultCoordinates(handles,'latlon2xy');
else
    handles.toolbox.tsunami.segmentX=x;
    handles.toolbox.tsunami.segmentY=y;
    handles=convertFaultCoordinates(handles,'xy2latlon');
end

handles=computeLengthAndStrike(handles);

% Update theoretical parameters
if handles.toolbox.tsunami.updateParameters
    handles=updateTsunamiValues(handles,'length');
end

% Update segment values
handles.toolbox.tsunami.segmentDepth=[];
handles.toolbox.tsunami.segmentDip=[];
handles.toolbox.tsunami.segmentSlipRake=[];
for i=1:length(x)
    handles.toolbox.tsunami.segmentDepth(i)=handles.toolbox.tsunami.depth;
    handles.toolbox.tsunami.segmentDip(i)=handles.toolbox.tsunami.dip;
    handles.toolbox.tsunami.segmentSlipRake(i)=handles.toolbox.tsunami.slipRake;
end
handles=updateTableValues(handles);

setHandles(handles);

gui_updateActiveTab;

%%
function changeFaultLine(h,x,y,nr)

handles=getHandles;

if strcmpi(handles.screenParameters.coordinateSystem.type,'geographic')
    handles.toolbox.tsunami.segmentLon=x;
    handles.toolbox.tsunami.segmentLat=y;
    handles=convertFaultCoordinates(handles,'latlon2xy');
else
    handles.toolbox.tsunami.segmentX=x;
    handles.toolbox.tsunami.segmentY=y;
    handles=convertFaultCoordinates(handles,'xy2latlon');
end

handles=computeLengthAndStrike(handles);

% Update theoretical parameters
if handles.toolbox.tsunami.updateParameters
    handles=updateTsunamiValues(handles,'length');
end

% Update segment values
if handles.toolbox.tsunami.updateTable
    handles.toolbox.tsunami.segmentDepth=[];
    handles.toolbox.tsunami.segmentDip=[];
    handles.toolbox.tsunami.segmentSlipRake=[];
    for i=1:length(x)
        handles.toolbox.tsunami.segmentDepth(i)=handles.toolbox.tsunami.depth;
        handles.toolbox.tsunami.segmentDip(i)=handles.toolbox.tsunami.dip;
        handles.toolbox.tsunami.segmentSlipRake(i)=handles.toolbox.tsunami.slipRake;
    end
    handles=updateTableValues(handles);
end

setHandles(handles);

gui_updateActiveTab;

%%
function handles=convertFaultCoordinates(handles,opt)

% Computes x and y or lat and lon values of fault line

switch lower(opt)
    case{'latlon2xy'}
    % Convert x and y to lat-lon
    x=handles.toolbox.tsunami.segmentLon;
    y=handles.toolbox.tsunami.segmentLat;
    x(x>180)=x(x>180)-360;
    switch lower(handles.screenParameters.coordinateSystem.type)
        case{'projected','cartesian'}
            % Horizontal coordinate system already projected
            cs0.name='WGS 84';
            cs0.type='geographic';
            cs1=handles.screenParameters.coordinateSystem;
        otherwise
            % Horizontal coordinate system is geographic, so find matching
            % UTM system
            cs0=handles.screenParameters.coordinateSystem;
            utmz = fix( ( x(1) / 6 ) + 31);
            utmz = mod(utmz,60);
            if y(1)>0
                utmZone=['WGS 84 / UTM zone ' num2str(utmz) 'N'];
                utmZoneShort=[num2str(utmz) 'N'];
            else
                utmZone=['WGS 84 / UTM zone ' num2str(utmz) 'S'];
                utmZoneShort=[num2str(utmz) 'S'];
            end
            handles.toolbox.tsunami.utmZone=utmZone;
            handles.toolbox.tsunami.utmZoneShort=utmZoneShort;
            cs1.name=utmZone;
            cs1.type='projected';
    end    
    [x,y]=ddb_coordConvert(x,y,cs0,cs1);
    handles.toolbox.tsunami.segmentX=x;
    handles.toolbox.tsunami.segmentY=y;
case{'xy2latlon'}
    % Only used if screen coordinate system is projected
    x=handles.toolbox.tsunami.segmentX;
    y=handles.toolbox.tsunami.segmentY;
    cs0=handles.screenParameters.coordinateSystem;
    cs1.name='WGS 84';
    cs1.type='geographic';
    [lon,lat]=ddb_coordConvert(x,y,cs0,cs1);
    handles.toolbox.tsunami.segmentLon=lon;
    handles.toolbox.tsunami.segmentLat=lat;
end

%%
function handles=updateTsunamiValues(handles,opt)

switch opt
    case{'mw'}
        Mw=handles.toolbox.tsunami.Mw;
    case{'length'}
        % Compute magnitude based on length
        if (handles.toolbox.tsunami.length > 0)
            Mw = (log10(handles.toolbox.tsunami.length) + 2.44) / 0.59;
            handles.toolbox.tsunami.Mw = Mw ;
        end
end

mu=30.0e9;
Areaeq=4;

%
%       Options to detrmine the fault area, names below refers to the authors
%         1 = Ward 2004;
%         2 = Coopersmith / Wells 1994 [Dreger 1999];
%         3 = average (Jef);
%         4 = Max. Length and Max width from options 1 & 2
%

fwidth=0;
totflength=0;
disloc=0;

if (Mw > 5)
    Mo = 10.0^(1.5*Mw+9.05);
    disloc = 0.02*10.0^(0.5*Mw-1.8); % dslip in meters
    if (Areaeq == 1)
        totflength  = 10.0^(0.5*Mw-1.8);
        mu1         = mu * 1.66666;
        area        = Mo/(mu1*disloc)/1000000.;
        fwidth      = area/totflength;
    elseif (Areaeq == 2 )
        totflength = 10^(-2.44+0.59*Mw);
        area       = 10^(-3.49+0.91*Mw);
        fwidth     = area/totflength;
    elseif (Areaeq == 3)
        L1  = 10.0^(0.5*Mw-1.8);
        mu1 = mu * 1.66666;
        area= Mo/(mu1*disloc)/1000000.0;
        fw1 = area/L1;
        L2    = 10^(-2.44+0.59*Mw);
        area2 = 10^(-3.49+0.91*Mw);
        fw2   = area2/L2;
        totflength = 0.5*(L1+L2);
        fwidth = 0.5*(fw1 + fw2);
    elseif (Areaeq == 4)
        totflength = 10^(-2.44+0.59*Mw);
        area       = Mo/(mu*disloc)/1000000.0;
        fwidth     = area/totflength;
    end
    
    %     handles.toolbox.tsunami.TotalFaultLength=totflength;
    %     handles.toolbox.tsunami.FaultWidth=fwidth;
    %     handles.toolbox.tsunami.Dislocation=disloc;
else
    %     handles.toolbox.tsunami.Mw=0.0;
    %     handles.toolbox.tsunami.TotalFaultLength=0;
    %     handles.toolbox.tsunami.FaultWidth=0;
    %     handles.toolbox.tsunami.Dislocation=0;
end

handles.toolbox.tsunami.width=fwidth;
handles.toolbox.tsunami.slip=disloc;
handles.toolbox.tsunami.theoreticalFaultLength=totflength;



%%
function handles=updateTableValues(handles)

handles.toolbox.tsunami.segmentWidth=[];
handles.toolbox.tsunami.segmentSlip=[];

for i=1:length(handles.toolbox.tsunami.segmentLon)
    handles.toolbox.tsunami.segmentWidth(i)=handles.toolbox.tsunami.width;
    handles.toolbox.tsunami.segmentSlip(i)=handles.toolbox.tsunami.slip;
end

%% Delft3D-FLOW
function computeWaterLevel_delft3dflow(opt)

handles=getHandles;

% First check to see if a grid was loaded
if isempty(handles.model.delft3dflow.domain(ad).gridX)
    ddb_giveWarning('text','Please first create or load model grid!');
    return
end

for id=1:handles.model.delft3dflow.nrDomains
    [filename, pathname, filterindex] = uiputfile('*.ini', ['Select initial conditions file for domain ' upper(handles.model.delft3dflow.domain(id).runid)],'');
    filenames{id}=filename;
    if handles.toolbox.tsunami.adjustBathymetry
        [filename, pathname, filterindex] = uiputfile('*.dep', ['Select new depth file for domain ' upper(handles.model.delft3dflow.domain(id).runid)],'');
        depfiles{id}=filename;
    else
        depfiles{id}='';
    end
end
        
if ~isempty(pathname)
    
    wb = waitbox('Generating initial tsunami wave ...');
    
    try
                
        switch opt
            case{'fromparameters'}
                xs=handles.toolbox.tsunami.segmentX;
                ys=handles.toolbox.tsunami.segmentY;
                wdts=handles.toolbox.tsunami.segmentWidth;
                depths=handles.toolbox.tsunami.segmentDepth;
                dips=handles.toolbox.tsunami.segmentDip;
                sliprakes=handles.toolbox.tsunami.segmentSlipRake;
                slips=handles.toolbox.tsunami.segmentSlip;
                
                % Compute tsunami wave (in projected coordinate system!)
                [xx,yy,zz]=ddb_computeTsunamiWave2(xs,ys,depths,dips,wdts,sliprakes,slips);
                
                if handles.toolbox.tsunami.saveESRIGridFile
                    % Write tsunami asc file (in geographic coordinates)
                    xmn=min(min(xx));
                    xmx=max(max(xx));
                    ymn=min(min(yy));
                    ymx=max(max(yy));
                    oldSys.name=handles.toolbox.tsunami.utmZone;
                    oldSys.type='projected';
                    newSys.name='WGS 84';
                    newSys.type='geographic';
                    [xmn,ymn]=ddb_coordConvert(xmn,ymn,oldSys,newSys);
                    [xmx,ymx]=ddb_coordConvert(xmx,ymx,oldSys,newSys);
                    [xgeo,ygeo]=meshgrid(xmn:0.02:xmx,ymn:0.02:ymx);
                    [xutm,yutm]=ddb_coordConvert(xgeo,ygeo,newSys,oldSys);
                    zgeo=interp2(xx,yy,zz,xutm,yutm);
                    ascfile=[filenames{1}(1:end-4) '.asc'];
                    arcgridwrite(ascfile,xgeo,ygeo,zgeo);
                end

                % Plot figure (first convert to geographic coordinate system)
                if strcmpi(handles.screenParameters.coordinateSystem.type,'geographic')
                    oldSys.name=handles.toolbox.tsunami.utmZone;
                    oldSys.type='projected';
                    newSys.name='WGS 84';
                    newSys.type='geographic';
                    [xx1,yy1]=ddb_coordConvert(xx,yy,oldSys,newSys);
                else
                    oldSys=handles.screenParameters.coordinateSystem;
                    newSys.name='WGS 84';
                    newSys.type='geographic';
                    [xx1,yy1]=ddb_coordConvert(xx,yy,oldSys,newSys);
                end
                
            otherwise
                % Load tsunami wave (in geographic coordinate system!)
                [xx yy zz info] = arc_asc_read(handles.toolbox.tsunami.gridFile);
                xx1=xx;
                yy1=yy;

        end
        
        ddb_plotInitialTsunami(handles,xx1,yy1,zz);
        
        % Interpolate initial tsunami wave onto model grid(s)
        for id=1:handles.model.delft3dflow.nrDomains
                        
            xz=handles.model.delft3dflow.domain(id).gridXZ;
            yz=handles.model.delft3dflow.domain(id).gridYZ;
            dp=handles.model.delft3dflow.domain(id).depth;

            oldSys=handles.screenParameters.coordinateSystem;
            newSys.name='WGS 84';
            newSys.type='geographic';

            switch opt
                case{'fromparameters'}                    
                    % If in geographic coordinate system, convert grids first to
                    % projected coordinate system
                    if strcmpi(handles.screenParameters.coordinateSystem.type,'geographic')
                        newSys.name=handles.toolbox.tsunami.utmZone;
                        newSys.type='projected';
                    end
            end

            adjustBathymetry=handles.toolbox.tsunami.adjustBathymetry;
            
            interpolateTsunamiToGrid('xgrid',xz,'ygrid',yz,'gridcs',oldSys,'tsunamics',newSys, ...
                'xtsunami',xx,'ytsunami',yy,'ztsunami',zz,'inifile',filenames{id}, ...
                'adjustbathymetry',adjustBathymetry,'depth',dp,'newdepfile',depfiles{id});
            
            handles.model.delft3dflow.domain(id).iniFile=filenames{id};
            handles.model.delft3dflow.domain(id).initialConditions='ini';
            
            if handles.toolbox.tsunami.adjustBathymetry
                handles.model.delft3dflow.domain(id).depFile=depfiles{id};
                mmax=handles.model.delft3dflow.domain(id).MMax;
                nmax=handles.model.delft3dflow.domain(id).NMax;
                dp=ddb_wldep('read',handles.model.delft3dflow.domain(id).depFile,[mmax nmax]);
                dp(dp==-999)=NaN;
                handles.model.delft3dflow.domain(id).depth=-dp(1:end-1,1:end-1);
                handles.model.delft3dflow.domain(id).depthZ=getDepthZ(handles.model.delft3dflow.domain(id).depth,handles.model.delft3dflow.domain(id).dpsOpt);
                handles=ddb_Delft3DFLOW_plotBathy(handles,'plot','domain',id);                
            end
                        
        end
        
        close(wb);
        
        % Reset all boundary conditions to Riemann in order to avoid
        % reflections at the boundaries.
        
        % First check whether other boundary types are there
        bndr=1;
        for id=1:handles.model.delft3dflow.nrDomains
            for nb=1:handles.model.delft3dflow.domain(id).nrOpenBoundaries
                switch lower(handles.model.delft3dflow.domain(id).openBoundaries(nb).type)
                    case{'r'}
                    otherwise
                        bndr=0;
                end
            end
        end
        if ~bndr
            ButtonName = questdlg('Reset all boundaries to Riemann in order to avoid boundary reflections?','','No', 'Yes', 'Yes');
            switch ButtonName,
                case 'Yes'
                    for id=1:handles.model.delft3dflow.nrDomains
                        ichanged=0;
                        for nb=1:handles.model.delft3dflow.domain(id).nrOpenBoundaries
                            switch lower(handles.model.delft3dflow.domain(id).openBoundaries(nb).type)
                                case{'r'}
                                otherwise                                    
                                    handles.model.delft3dflow.domain(id).openBoundaries(nb).type='R';
                                    handles.model.delft3dflow.domain(id).openBoundaries(nb).forcing='T';
                                    t0=handles.model.delft3dflow.domain(id).startTime;
                                    t1=handles.model.delft3dflow.domain(id).stopTime;
                                    handles.model.delft3dflow.domain(id).openBoundaries(nb).timeSeriesT=[t0 t1];
                                    handles.model.delft3dflow.domain(id).openBoundaries(nb).timeSeriesA=[0.0 0.0];
                                    handles.model.delft3dflow.domain(id).openBoundaries(nb).timeSeriesB=[0.0 0.0];
                                    handles.model.delft3dflow.domain(id).bctChanged=1;
                                    ichanged=1;
                            end
                        end

                        if ichanged

                            [filename, pathname, filterindex] = uiputfile('*.bnd', ['Select Boundary Definitions File - domain ' handles.model.delft3dflow.domain(id).runid],'');
                            if filename~=0
                                curdir=[lower(cd) '\'];
                                if ~strcmpi(curdir,pathname)
                                    filename=[pathname filename];
                                end
                                handles.model.delft3dflow.domain(id).bndFile=filename;
                                ddb_saveBndFile(handles.model.delft3dflow.domain(id).openBoundaries,handles.model.delft3dflow.domain(id).bndFile);
                            end

                            [filename, pathname, filterindex] = uiputfile('*.bct', ['Select Time Series Conditions File - domain ' handles.model.delft3dflow.domain(id).runid],'');
                            if filename~=0
                                curdir=[lower(cd) '\'];
                                if ~strcmpi(curdir,pathname)
                                    filename=[pathname filename];
                                end
                                handles.model.delft3dflow.domain(id).bctFile=filename;
                                ddb_saveBctFile(handles,id);
                                handles.model.delft3dflow.domain(id).bctChanged=0;
                            end
                        
                        end

                    end                    
            end
        end
        
        % Adjust smoothing time
        if handles.model.delft3dflow.domain(id).smoothingTime>0
            ButtonName = questdlg('Reset smoothing time to 0.0?','','No', 'Yes', 'Yes');
            switch ButtonName,
                case 'Yes'
                    handles.model.delft3dflow.domain(id).smoothingTime=0;
            end
        end

        setHandles(handles);
        
    catch
        close(wb);
        ddb_giveWarning('txt','Some went wrong while generating tsunami wave.');
    end
end

%% Delft3D-FM
function computeWaterLevel_dflowfm(opt)

handles=getHandles;

% First check to see if a grid was loaded
if isempty(handles.model.dflowfm.domain.grid) 
    ddb_giveWarning('text','Please first create or load model grid!');
    return
end

depfiles=[];

for id=1:handles.model.dflowfm.nrDomains 
    [filename, pathname, filterindex] = uiputfile('*.ini', ['Select initial conditions file for domain ' upper(handles.model.dflowfm.domain(id).runid)],'');
    filenames{id}=filename;
    if handles.toolbox.tsunami.adjustBathymetry  %TL: not inplemented yet
%         [filename, pathname, filterindex] = uiputfile('*.xyz', ['Select new depth file for domain ' upper(handles.model.delft3dflow.domain(id).runid)],'');
%         depfiles{id}=filename;
%     else
%         depfiles{id}='';      
    end
end
        
if ~isempty(pathname)
    
    wb = waitbox('Generating initial tsunami wave ...');
    
    try
                
        switch opt
            case{'fromparameters'}
                xs=handles.toolbox.tsunami.segmentX;
                ys=handles.toolbox.tsunami.segmentY;
                wdts=handles.toolbox.tsunami.segmentWidth;
                depths=handles.toolbox.tsunami.segmentDepth;
                dips=handles.toolbox.tsunami.segmentDip;
                sliprakes=handles.toolbox.tsunami.segmentSlipRake;
                slips=handles.toolbox.tsunami.segmentSlip;
                
                % Compute tsunami wave (in projected coordinate system!)
                [xx,yy,zz]=ddb_computeTsunamiWave2(xs,ys,depths,dips,wdts,sliprakes,slips);
                
                if handles.toolbox.tsunami.saveESRIGridFile
                    % Write tsunami asc file (in geographic coordinates)
                    xmn=min(min(xx));
                    xmx=max(max(xx));
                    ymn=min(min(yy));
                    ymx=max(max(yy));
                    oldSys.name=handles.toolbox.tsunami.utmZone;
                    oldSys.type='projected';
                    newSys.name='WGS 84';
                    newSys.type='geographic';
                    [xmn,ymn]=ddb_coordConvert(xmn,ymn,oldSys,newSys);
                    [xmx,ymx]=ddb_coordConvert(xmx,ymx,oldSys,newSys);
                    [xgeo,ygeo]=meshgrid(xmn:0.02:xmx,ymn:0.02:ymx);
                    [xutm,yutm]=ddb_coordConvert(xgeo,ygeo,newSys,oldSys);
                    zgeo=interp2(xx,yy,zz,xutm,yutm);
                    ascfile=[filenames{1}(1:end-4) '.asc'];
                    arcgridwrite(ascfile,xgeo,ygeo,zgeo);
                end

                % Plot figure (first convert to geographic coordinate system)
                if strcmpi(handles.screenParameters.coordinateSystem.type,'geographic')
                    oldSys.name=handles.toolbox.tsunami.utmZone;
                    oldSys.type='projected';
                    newSys.name='WGS 84';
                    newSys.type='geographic';
                    [xx1,yy1]=ddb_coordConvert(xx,yy,oldSys,newSys);
                else
                    oldSys=handles.screenParameters.coordinateSystem;
                    newSys.name='WGS 84';
                    newSys.type='geographic';
                    [xx1,yy1]=ddb_coordConvert(xx,yy,oldSys,newSys);
                end
                
            otherwise
                % Load tsunami wave (in geographic coordinate system!)
                [xx yy zz info] = arc_asc_read(handles.toolbox.tsunami.gridFile);
                xx1=xx;
                yy1=yy;

        end
        
        ddb_plotInitialTsunami(handles,xx1,yy1,zz);
        
        % Interpolate initial tsunami wave onto model grid(s)
        for id=1:handles.model.dflowfm.nrDomains                       

            handles.model.dflowfm.domain(id).waterlevinifile=filenames{id};
                        
            % Make waterlevinifile file as xyz-file with original resolution tsunami calculation:
            delft3d_io_xyz('write', handles.model.dflowfm.domain(id).waterlevinifile,xx1,yy1,zz);  
            
            %handles.model.dflowfm.domain.netstruc.node.mesh2d_node_z  
            
%             interpolateTsunamiToGrid('xgrid',xz,'ygrid',yz,'gridcs',oldSys,'tsunamics',newSys, ...
%                 'xtsunami',xx,'ytsunami',yy,'ztsunami',zz,'inifile',filenames{id}, ...
%                 'adjustbathymetry',adjustBathymetry,'depth',dp,'newdepfile',depfiles{id});
            
            handles.model.delft3dflow.domain(id).iniFile=filenames{id};
            handles.model.delft3dflow.domain(id).initialConditions='ini';
            
            if handles.toolbox.tsunami.adjustBathymetry %TL: not inplemented yet
%                 handles.model.delft3dflow.domain(id).depFile=depfiles{id};
%                 mmax=handles.model.delft3dflow.domain(id).MMax;
%                 nmax=handles.model.delft3dflow.domain(id).NMax;
%                 dp=ddb_wldep('read',handles.model.delft3dflow.domain(id).depFile,[mmax nmax]);
%                 dp(dp==-999)=NaN;
%                 handles.model.delft3dflow.domain(id).depth=-dp(1:end-1,1:end-1);
%                 handles.model.delft3dflow.domain(id).depthZ=getDepthZ(handles.model.delft3dflow.domain(id).depth,handles.model.delft3dflow.domain(id).dpsOpt);
%                 handles=ddb_Delft3DFLOW_plotBathy(handles,'plot','domain',id);                
            end
                        
        end
        
        close(wb);
        
        % Reset all boundary conditions to Riemann in order to avoid
        % reflections at the boundaries.
        
        % First check whether other boundary types are there
        bndr=1;
        for id=1:handles.model.dflowfm.nrDomains
            for nb=1:handles.model.dflowfm.domain(id).nrboundaries   
                switch lower(handles.model.dflowfm.domain(id).boundaries(nb).type)
                    case{'riemannbnd'}
                    otherwise
                        bndr=0; % if any non-Riemann boundary is present
                end
            end
        end
        if ~bndr
            wb = waitbox('All boundaries are not yet automatically reset to Riemann boundaries, must be done by user ...');
            %TL: not inplemented yet
            %{ 
            ButtonName = questdlg('Reset all boundaries to Riemann in order to avoid boundary reflections?','','No', 'Yes', 'Yes');
            switch ButtonName,
                case 'Yes' 
                    for id=1:handles.model.dflowfm.nrDomains
                        ichanged=0;
                        for nb=1:handles.model.dflowfm.domain(id).nrboundaries
                            switch lower(handles.model.dflowfm.domain(id).boundaries(nb).type)
                                case{'riemannbnd'}
                                otherwise                                    
                                    handles.model.dflowfm.domain(id).boundaries(nb).type='riemannbnd';
                                    handles.model.dflowfm.domain(id).openBoundaries(nb).forcing='T';
                                    t0=handles.model.dflowfm.domain(id).startTime;
                                    t1=handles.model.dflowfm.domain(id).stopTime;
                                    handles.model.dflowfm.domain(id).openBoundaries(nb).timeSeriesT=[t0 t1];
                                    handles.model.dflowfm.domain(id).openBoundaries(nb).timeSeriesA=[0.0 0.0];
                                    handles.model.dflowfm.domain(id).openBoundaries(nb).timeSeriesB=[0.0 0.0];
                                    handles.model.dflowfm.domain(id).bctChanged=1;
                                    ichanged=1;
                            end
                        end

                        if ichanged

                            [filename, pathname, filterindex] = uiputfile('*.bnd', ['Select Boundary Definitions File - domain ' handles.model.delft3dflow.domain(id).runid],'');
                            if filename~=0
                                curdir=[lower(cd) '\'];
                                if ~strcmpi(curdir,pathname)
                                    filename=[pathname filename];
                                end
                                handles.model.delft3dflow.domain(id).bndFile=filename;
                                ddb_saveBndFile(handles.model.delft3dflow.domain(id).openBoundaries,handles.model.delft3dflow.domain(id).bndFile);
                            end

                            [filename, pathname, filterindex] = uiputfile('*.bct', ['Select Time Series Conditions File - domain ' handles.model.delft3dflow.domain(id).runid],'');
                            if filename~=0
                                curdir=[lower(cd) '\'];
                                if ~strcmpi(curdir,pathname)
                                    filename=[pathname filename];
                                end
                                handles.model.delft3dflow.domain(id).bctFile=filename;
                                ddb_saveBctFile(handles,id);
                                handles.model.delft3dflow.domain(id).bctChanged=0;
                            end
                        
                        end

                    end                    
            end
            %}
        end
        
        % Adjust smoothing time %TL: not inplemented yet (needed?)
        %{
        if handles.model.delft3dflow.domain(id).smoothingTime>0
            ButtonName = questdlg('Reset smoothing time to 0.0?','','No', 'Yes', 'Yes');
            switch ButtonName,
                case 'Yes'
                    handles.model.delft3dflow.domain(id).smoothingTime=0;
            end
        end
        %} 
        setHandles(handles);
        
    catch
        close(wb);
        ddb_giveWarning('txt','Some went wrong while generating tsunami wave.');
    end
end

%%
function handles=deleteFaultLine(handles)
try
    delete(handles.toolbox.tsunami.faulthandle);
end
handles.toolbox.tsunami.faulthandle=[];
