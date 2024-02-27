function ddb_NestingToolbox_Delft3DFLOW_nest2(varargin)
%DDB_NESTINGTOOLBOX_NESTHD2  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_NestingToolbox_nestHD2(varargin)
%
%   Input:
%   varargin =
%
%
%
%
%   Example
%   ddb_NestingToolbox_nestHD2
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

% $Id: ddb_NestingToolbox_nestHD2.m 11472 2014-11-27 15:12:11Z ormondt $
% $Date: 2014-11-27 16:12:11 +0100 (Thu, 27 Nov 2014) $
% $Author: ormondt $
% $Revision: 11472 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/Nesting/ddb_NestingToolbox_nestHD2.m $
% $Keywords: $

%%
if isempty(varargin)
    
    % New tab selected
    ddb_zoomOff;
    ddb_refreshScreen;
    
    % Check to see if there are any constituents in the model. If not, make
    % sure the transport box is not ticked.
    handles=getHandles;
    handles = ddb_checkForConstituents(handles, ad);
    if ~handles.model.delft3dflow.domain(ad).constituents
        handles.toolbox.nesting.nestTransport=0;
    end
    setHandles(handles);
    
    setInstructions({'Click Run Nesting in order to generate boundary conditions for the nested model', ...
        'The overall model simulation must be finished and a history file must be present','The nested model domain must be selected!'});
else
    %Options selected
    opt=lower(varargin{1});
    switch opt
        case{'nesthd2'}
            nestHD2;
    end
end

%%
function nestHD2

handles=getHandles;

if isempty(handles.toolbox.nesting.trihFile)
    ddb_giveWarning('text','Please first load history file of overall model!');
    return
end

hisfile=handles.toolbox.nesting.trihFile;
nestadm=handles.toolbox.nesting.admFile;
%nestadm='';
z0=handles.toolbox.nesting.zCor;
opt='';
if handles.toolbox.nesting.nestHydro && handles.toolbox.nesting.nestTransport
    opt='both';
elseif handles.toolbox.nesting.nestHydro
    opt='hydro';
elseif handles.toolbox.nesting.nestTransport
    opt='transport';
end
stride=1;

if ~isempty(opt)
    
    wb = waitbox('Nesting your model');

    % Make structure info for nesthd2
    bnd=handles.model.delft3dflow.domain(ad).openBoundaries;
    
    % Vertical grid info
    vertGrid.KMax=handles.model.delft3dflow.domain(ad).KMax;
    vertGrid.layerType=handles.model.delft3dflow.domain(ad).layerType;
    vertGrid.thick=handles.model.delft3dflow.domain(ad).thick;
    vertGrid.zTop=handles.model.delft3dflow.domain(ad).zTop;
    vertGrid.zBot=handles.model.delft3dflow.domain(ad).zBot;

    % Run Nesthd2
    cs=handles.screenParameters.coordinateSystem.type;
    
%    overallmodeltype='dflowfm';
    overallmodeltype='delft3dflow';
    
    switch overallmodeltype
        case{'delft3dflow'}
            bnd=nesthd2('openboundaries',bnd,'vertgrid',vertGrid,'hisfile',hisfile,'admfile',nestadm,'zcor',z0,'stride',stride,'opt',opt,'coordinatesystem',cs,'save','n');
        case{'dflowfm'}
             
            fid=qpfopen(hisfile);            
            stations=qpread(fid,1,'Water level (points)','stations');
            for ib=1:length(handles.model.delft3dflow.domain(ad).openBoundaries)

                % A
                istat=strmatch([handles.model.delft3dflow.domain(ad).openBoundaries(ib).name '_A'],stations,'exact');               
                wl=qpread(fid,1,'Water level (points)','griddata',0,istat);
                bnd(ib).timeSeriesT=wl.Time;
                bnd(ib).timeSeriesA=wl.Val;
                % B
                istat=strmatch([handles.model.delft3dflow.domain(ad).openBoundaries(ib).name '_B'],stations,'exact');               
                wl=qpread(fid,1,'Water level (points)','griddata',0,istat);
                bnd(ib).timeSeriesB=wl.Val;
                
                bnd(ib).profile='Uniform';
                bnd(ib).timeSeriesAV=[];
                bnd(ib).timeSeriesBV=[];
            
            end
            
%             bnd=nesthd2_new('openboundaries',bnd,'vertgrid',vertGrid,'hisfile',hisfile,'admfile',nestadm, ...
%                 'zcor',z0,'stride',stride,'opt',opt,'coordinatesystem',cs,'save','n', ...
%                 'overallmodeltype','dflowfm');
    end

%     bnd=nesthd2_new('input',handles.model.dflowfm.domain,'openboundaries',bnd,'vertgrid',vertGrid,'hisfile',hisfile, ...
%         'admfile',nestadm,'zcor',z0,'stride',stride,'opt',opt,'coordinatesystem',cs,'save','n','overallmodeltype','dflowfm');


    zersunif=zeros(2,1);
    
    for i=1:length(bnd)
        
        if strcmpi(bnd(i).forcing,'T')
            
            if handles.toolbox.nesting.nestHydro
                % Copy boundary data
                % Hydrodynamics
                handles.model.delft3dflow.domain(ad).openBoundaries(i).nrTimeSeries=length(bnd(i).timeSeriesT);
                handles.model.delft3dflow.domain(ad).openBoundaries(i).timeSeriesT=bnd(i).timeSeriesT;
                handles.model.delft3dflow.domain(ad).openBoundaries(i).timeSeriesA=bnd(i).timeSeriesA;
                handles.model.delft3dflow.domain(ad).openBoundaries(i).timeSeriesB=bnd(i).timeSeriesB;
                handles.model.delft3dflow.domain(ad).openBoundaries(i).timeSeriesAV=bnd(i).timeSeriesAV;
                handles.model.delft3dflow.domain(ad).openBoundaries(i).timeSeriesBV=bnd(i).timeSeriesBV;
                handles.model.delft3dflow.domain(ad).openBoundaries(i).profile=bnd(i).profile;
            end
            
            if handles.toolbox.nesting.nestTransport
                % Transport
                
                % Salinity
                
                handles.model.delft3dflow.domain(ad).openBoundaries(i).salinity.nrTimeSeries=2;
                handles.model.delft3dflow.domain(ad).openBoundaries(i).salinity.timeSeriesT=[handles.model.delft3dflow.domain(ad).startTime handles.model.delft3dflow.domain(ad).stopTime];
                
                handles.model.delft3dflow.domain(ad).openBoundaries(i).salinity.profile='uniform';
                handles.model.delft3dflow.domain(ad).openBoundaries(i).salinity.timeSeriesA=zersunif+handles.model.delft3dflow.domain(ad).salinity.ICConst;
                handles.model.delft3dflow.domain(ad).openBoundaries(i).salinity.timeSeriesB=zersunif+handles.model.delft3dflow.domain(ad).salinity.ICConst;
                
                if handles.model.delft3dflow.domain(ad).salinity.include
                    if isfield(bnd(i),'salinity')
                        handles.model.delft3dflow.domain(ad).openBoundaries(i).salinity.nrTimeSeries=length(bnd(i).salinity.timeSeriesT);
                        handles.model.delft3dflow.domain(ad).openBoundaries(i).salinity.timeSeriesT=bnd(i).salinity.timeSeriesT;
                        handles.model.delft3dflow.domain(ad).openBoundaries(i).salinity.timeSeriesA=bnd(i).salinity.timeSeriesA;
                        handles.model.delft3dflow.domain(ad).openBoundaries(i).salinity.timeSeriesB=bnd(i).salinity.timeSeriesB;
                        handles.model.delft3dflow.domain(ad).openBoundaries(i).salinity.profile=bnd(i).salinity.profile;
                    end
                end
                
                % Temperature
                handles.model.delft3dflow.domain(ad).openBoundaries(i).temperature.nrTimeSeries=2;
                handles.model.delft3dflow.domain(ad).openBoundaries(i).temperature.timeSeriesT=[handles.model.delft3dflow.domain(ad).startTime handles.model.delft3dflow.domain(ad).stopTime];
                
                handles.model.delft3dflow.domain(ad).openBoundaries(i).temperature.profile='uniform';
                handles.model.delft3dflow.domain(ad).openBoundaries(i).temperature.timeSeriesA=zersunif+handles.model.delft3dflow.domain(ad).temperature.ICConst;
                handles.model.delft3dflow.domain(ad).openBoundaries(i).temperature.timeSeriesB=zersunif+handles.model.delft3dflow.domain(ad).temperature.ICConst;
                
                if handles.model.delft3dflow.domain(ad).temperature.include
                    if isfield(bnd(i),'temperature')
                        handles.model.delft3dflow.domain(ad).openBoundaries(i).temperature.nrTimeSeries=length(bnd(i).temperature.timeSeriesT);
                        handles.model.delft3dflow.domain(ad).openBoundaries(i).temperature.timeSeriesT=bnd(i).temperature.timeSeriesT;
                        handles.model.delft3dflow.domain(ad).openBoundaries(i).temperature.timeSeriesA=bnd(i).temperature.timeSeriesA;
                        handles.model.delft3dflow.domain(ad).openBoundaries(i).temperature.timeSeriesB=bnd(i).temperature.timeSeriesB;
                        handles.model.delft3dflow.domain(ad).openBoundaries(i).temperature.profile=bnd(i).temperature.profile;
                    end
                end
                
                % Tracers
                for j=1:handles.model.delft3dflow.domain(ad).nrTracers
                    handles.model.delft3dflow.domain(ad).openBoundaries(i).tracer(j).nrTimeSeries=2;
                    handles.model.delft3dflow.domain(ad).openBoundaries(i).tracer(j).timeSeriesT=[handles.model.delft3dflow.domain(ad).startTime handles.model.delft3dflow.domain(ad).stopTime];
                    
                    handles.model.delft3dflow.domain(ad).openBoundaries(i).tracer(j).profile='uniform';
                    handles.model.delft3dflow.domain(ad).openBoundaries(i).tracer(j).timeSeriesA=zersunif;
                    handles.model.delft3dflow.domain(ad).openBoundaries(i).tracer(j).timeSeriesB=zersunif;
                    
                    if isfield(bnd(i),'tracer')
                        if length(bnd(i).tracer)<=j
                            handles.model.delft3dflow.domain(ad).openBoundaries(i).tracer(j).nrTimeSeries=length(bnd(i).tracer(j).timeSeriesT);
                            handles.model.delft3dflow.domain(ad).openBoundaries(i).tracer(j).timeSeriesT=bnd(i).tracer(j).timeSeriesT;
                            handles.model.delft3dflow.domain(ad).openBoundaries(i).tracer(j).timeSeriesA=bnd(i).tracer(j).timeSeriesA;
                            handles.model.delft3dflow.domain(ad).openBoundaries(i).tracer(j).timeSeriesB=bnd(i).tracer(j).timeSeriesB;
                            handles.model.delft3dflow.domain(ad).openBoundaries(i).tracer(j).profile=bnd(i).tracer(j).profile;
                        end
                    end
                end
                
                % Sediments
                for j=1:handles.model.delft3dflow.domain(ad).nrSediments
                    
                    handles.model.delft3dflow.domain(ad).openBoundaries(i).sediment(j).nrTimeSeries=2;
                    handles.model.delft3dflow.domain(ad).openBoundaries(i).sediment(j).timeSeriesT=[handles.model.delft3dflow.domain(ad).startTime handles.model.delft3dflow.domain(ad).stopTime];
                    
                    handles.model.delft3dflow.domain(ad).openBoundaries(i).sediment(j).profile='uniform';
                    handles.model.delft3dflow.domain(ad).openBoundaries(i).sediment(j).timeSeriesA=zersunif;
                    handles.model.delft3dflow.domain(ad).openBoundaries(i).sediment(j).timeSeriesB=zersunif;
                    
                    if isfield(bnd(i),'sediment')
                        if length(bnd(i).sediment)<=j
                            handles.model.delft3dflow.domain(ad).openBoundaries(i).sediment(j).nrTimeSeries=length(bnd(i).sediment(j).timeSeriesT);
                            handles.model.delft3dflow.domain(ad).openBoundaries(i).sediment(j).timeSeriesT=bnd(i).sediment(j).timeSeriesT;
                            handles.model.delft3dflow.domain(ad).openBoundaries(i).sediment(j).timeSeriesA=bnd(i).sediment(j).timeSeriesA;
                            handles.model.delft3dflow.domain(ad).openBoundaries(i).sediment(j).timeSeriesB=bnd(i).sediment(j).timeSeriesB;
                            handles.model.delft3dflow.domain(ad).openBoundaries(i).sediment(j).profile=bnd(i).sediment(j).profile;
                        end
                    end
                end
            end
            
        end
        
    end
    
    
    if handles.toolbox.nesting.nestHydro
        [filename, pathname, filterindex] = uiputfile('*.bct','Select Timeseries Conditions File');
        if pathname~=0
            curdir=[lower(cd) '\'];
            if ~strcmpi(curdir,pathname)
                filename=[pathname filename];
            end
            handles.model.delft3dflow.domain(ad).bctFile=filename;
            ddb_saveBctFile(handles,ad);
        end
    end
    
    
    if handles.toolbox.nesting.nestTransport
        [filename, pathname, filterindex] = uiputfile('*.bcc','Select Transport Conditions File');
        if pathname~=0
            curdir=[lower(cd) '\'];
            if ~strcmpi(curdir,pathname)
                filename=[pathname filename];
            end
            handles.model.delft3dflow.domain(ad).bccFile=filename;
            ddb_saveBccFile(handles,ad);
        end
    end
    
    close(wb);
end

setHandles(handles);

