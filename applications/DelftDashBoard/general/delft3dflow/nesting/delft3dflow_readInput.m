function [flow openBoundaries] = delft3dflow_readInput(inpdir, runid, varargin)
%DELFT3DFLOW_READINPUT  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   [flow openBoundaries] = delft3dflow_readInput(inpdir, runid, varargin)
%
%   Input:
%   inpdir         =
%   runid          =
%   varargin       =
%
%   Output:
%   flow           =
%   openBoundaries =
%
%   Example
%   delft3dflow_readInput
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

% $Id: delft3dflow_readInput.m 9986 2014-01-09 16:01:49Z ormondt $
% $Date: 2014-01-10 00:01:49 +0800 (Fri, 10 Jan 2014) $
% $Author: ormondt $
% $Revision: 9986 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/delft3dflow/nesting/delft3dflow_readInput.m $
% $Keywords: $

%% Returns flow structure with required Delft3D-FLOW input as well as boundary structure for nesting

if ~isempty(inpdir)
    if ~strcmpi(inpdir(end),filesep)
        inpdir=[inpdir filesep];
    end
end

%% Read MDF file

MDF=delft3dflow_readMDFText([inpdir runid '.mdf']);

% Dimensions
flow.MMax=MDF.mnkmax(1);
flow.NMax=MDF.mnkmax(2);
flow.KMax=MDF.mnkmax(3);

if isfield(MDF,'anglat')
    flow.latitude=MDF.anglat;
else
    flow.latitude=0;
end

% Constituents
if ~isempty(find(MDF.sub1=='S', 1));
    flow.salinity.include=1;    % Salinity will be included
else
    flow.salinity.include=0;    % Salinity will not be included
end
if ~isempty(find(MDF.sub1=='T', 1));
    flow.temperature.include=1; % Temperature will be included
else
    flow.temperature.include=0;    % Salinity will not be included
end

flow.nrSediments=0;        % No sediments
flow.sediments.include=0;

flow.nrTracers=0;          % No Tracers
flow.tracers=0;

flow.nrConstituents=0;     % One tracer
% flow.Tracer(1).Name='dye';
% flow.Tracer(2).Name='dye decay';

% TODO sediments and tracers
if ~isempty(MDF.sub2)
    if MDF.sub2(2)=='C'
        flow.constituents=1;
    end
    if MDF.sub2(3)=='W'
        flow.waves=1;
    end
end
for i=1:5
    if isfield(MDF,['namc' num2str(i)])
        fld=deblank(getfield(MDF,['namc' num2str(i)]));
        if ~isempty(fld)
            if strcmpi(fld(1:min(8,length(fld))),'sediment')
                flow.sediments.include=1;
                flow.nrSediments=flow.nrSediments+1;
                flow.nrConstituents=flow.nrConstituents+1;
                k=flow.nrSediments;
                flow.sediment(k).name=deblank(fld);
            else
                flow.tracers=1;
                flow.nrConstituents=flow.nrConstituents+1;
                flow.nrTracers=flow.nrTracers+1;
                k=flow.nrTracers;
                flow.tracer(k).name=deblank(fld);
            end
        end
    end
end

% Layers
flow.thick=MDF.thick;
flow.vertCoord='sigma';
if isfield(MDF,'zmodel')
    if strcmpi(MDF.zmodel(1),'y')
        flow.vertCoord='z';
        flow.zBot=MDF.zbot;
        flow.zTop=MDF.ztop;
    end
end

% Times
flow.itDate=datenum(MDF.itdate,'yyyy-mm-dd');

if ~isfield(flow,'StartTime')
    flow.startTime=flow.itDate+MDF.tstart/1440;
    flow.stopTime =flow.itDate+MDF.tstop/1440;
end
if ~isfield(flow,'BccTimeStep')
    flow.bccTimeStep=60;
end
if ~isfield(flow,'BctTimeStep')
    flow.bctTimeStep=10;
end

flow.bctTimes=flow.startTime:flow.bctTimeStep/1440:flow.stopTime;

% Files
flow.gridFile=MDF.filcco;
flow.encFile=MDF.filgrd;

flow.depFile=MDF.fildep;

if isfield(MDF,'filbnd')
    flow.bndFile=MDF.filbnd;
end

if isfield(MDF,'filbct')
    flow.bctFile=MDF.filbct;
end

if isfield(MDF,'filbcc')
    flow.bccFile=MDF.filbcc;
else
    flow.bccFile='';
end
if isfield(MDF,'filic')
    flow.iniFile=MDF.filic;
else
    flow.iniFile='';
end

% Numerics
flow.dpsOpt=MDF.dpsopt;


%% Read grid
[flow.gridX,flow.gridY,enc,cs]=ddb_wlgrid('read',[inpdir flow.gridFile]);

switch lower(cs)
    case{'spherical'}
        flow.cs='geographic';
    otherwise
        flow.cs='projected';
end

[flow.gridXZ,flow.gridYZ]=getXZYZ(flow.gridX,flow.gridY);
mn=ddb_enclosure('read',[inpdir flow.encFile]);
[flow.gridX,flow.gridY]=ddb_enclosure('apply',mn,flow.gridX,flow.gridY);
flow.kcs=determineKCS(flow.gridX,flow.gridY);

%% Read bathy
dp=ddb_wldep('read',[inpdir flow.depFile],[flow.MMax flow.NMax]);
flow.depth=-dp(1:end-1,1:end-1);
flow.depthZ=getDepthZ(flow.depth,flow.dpsOpt);

if isfield(flow,'bndFile')
    
    %% Read boundary
    
    % Set some values for initializing (Dashboard specific)
    t0=flow.startTime;
    t1=flow.stopTime;
    nrsed=flow.nrSediments;
    nrtrac=flow.nrTracers;
    nrharmo=2;
    x=flow.gridX;
    y=flow.gridY;
    z=flow.depthZ;
    kcs=flow.kcs;
    kmax=flow.KMax;
    
    % Read boundaries into structure
    openBoundaries=delft3dflow_readBndFile([inpdir flow.bndFile]);
    
    % Initialize individual boundary sections
    for i=1:length(openBoundaries)
        openBoundaries=delft3dflow_initializeOpenBoundary(openBoundaries,i,t0,t1,nrsed,nrtrac,nrharmo,x,y,z,kcs,kmax,'coordinatesystem',flow.cs);
    end
    
end
