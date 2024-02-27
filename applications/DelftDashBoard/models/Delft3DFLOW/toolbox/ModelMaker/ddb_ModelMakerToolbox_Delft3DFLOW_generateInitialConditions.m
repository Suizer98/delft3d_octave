function handles = ddb_generateInitialConditionsDelft3DFLOW(handles, id, fname, varargin)
%DDB_GENERATEINITIALCONDITIONSDELFT3DFLOW  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_generateInitialConditionsDelft3DFLOW(handles, id, fname, varargin)
%
%   Input:
%   handles  =
%   id       =
%   fname    =
%   varargin =
%
%   Output:
%   handles  =
%
%   Example
%   ddb_generateInitialConditionsDelft3DFLOW
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

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
if ~isempty(varargin)
    % Check if routine exists
    if strcmpi(varargin{1},'ddb_test')
        return
    end
end

wb = waitbox('Generating Initial Conditions ...');%pause(0.1);

%% Water Level

xz=handles.model.delft3dflow.domain(id).gridXZ;
yz=handles.model.delft3dflow.domain(id).gridYZ;

mmax=size(xz,1);
nmax=size(xz,2);
kmax=handles.model.delft3dflow.domain(id).KMax;

if ~strcmpi(handles.model.delft3dflow.domain(id).waterLevel.ICOpt,'constant')
    
    % Tide Model
    
    cs.name='WGS 84';
    cs.type='Geographic';
    [xz,yz]=ddb_coordConvert(xz,yz,handles.screenParameters.coordinateSystem,cs);
    
    %     for i=1:mmax
    %         for j=1:nmax
    %             if xz(i,j)<0
    %                 xz(i,j)=xz(i,j)+360;
    %             end
    %         end
    %     end
    
    x00=reshape(xz,mmax*nmax,1);
    y00=reshape(yz,mmax*nmax,1);
    
    
    if length(x00)>100000
        % Limitation in delftPredict.mexw32
        disp('Too many grid points (>100000)! Cannot continue operation.');
        close(wb);
        ddb_giveWarning('Warning','Number of grid points exceeds 100000! Cannot continue this operation.');
        return
    end
    
    %     x00(x00<0.125 & x00>0)=360;
    %     x00(x00<0.250 & x00>0.125)=0.25;
    %     x00(x00>360)=360;
    
    t0=handles.model.delft3dflow.domain(id).startTime;
    
    ii=handles.toolbox.modelmaker.activeTideModelIC;
    name=handles.tideModels.model(ii).name;
    
    if strcmpi(handles.tideModels.model(ii).URL(1:4),'http')
        tidefile=[handles.tideModels.model(ii).URL '/' name '.nc'];
    else
        tidefile=[handles.tideModels.model(ii).URL filesep name '.nc'];
    end
    %    [ampz,phasez,depth,conList]=ddb_extractTidalConstituents(tidefile,x00,y00,'z');
    [ampz,phasez,conList] = readTideModel(tidefile,'type','h','x',x00,'y',y00,'constituent','all');
    
    % TODO this does not work yet for large grids
    % delftPredict2007 must be updated
    
    [prediction,tdummy]=delftPredict2007(conList,ampz,phasez,t0,t0+2/24,1);
    h=squeeze(prediction(:,1));
    
    h0=zeros(mmax+1,nmax+1);
    h=reshape(h,mmax,nmax);
    h0(1:end-1,1:end-1)=h;
    h=h0;
    h(isnan(h))=0;
    
else
    % Constant
    h=zeros(mmax+1,nmax+1)+handles.model.delft3dflow.domain(id).waterLevel.ICConst;
end

if exist(fname,'file')
    delete(fname);
end

ddb_wldep('append',fname,h,'negate','n','bndopt','n');

%% Velocities

u=zeros(size(h));

for i=1:kmax
    ddb_wldep('append',fname,u,'negate','n','bndopt','n');
    ddb_wldep('append',fname,u,'negate','n','bndopt','n');
end

mmax=mmax+1;
nmax=nmax+1;

dp=zeros(mmax,nmax);
dp(dp==0)=NaN;
dp(1:end-1,1:end-1)=-handles.model.delft3dflow.domain(id).depthZ;
thick=handles.model.delft3dflow.domain(id).thick;

%% Salinity
if handles.model.delft3dflow.domain(id).salinity.include
    switch lower(handles.model.delft3dflow.domain(id).salinity.ICOpt)
        case{'constant'}
            s=zeros(mmax,nmax,kmax)+handles.model.delft3dflow.domain(id).salinity.ICConst;
        case{'linear'}
            pars=handles.model.delft3dflow.domain(id).salinity.ICPar;
            s=ddb_interpolateInitialConditions(dp,thick,pars,'linear');
        case{'block'}
            pars=handles.model.delft3dflow.domain(id).salinity.ICPar;
            s=ddb_interpolateInitialConditions(dp,thick,pars,'block');
        case{'per layer'}
            for k=1:kmax
                s(:,:,k)=zeros(mmax,nmax)+handles.model.delft3dflow.domain(id).salinity.ICPar(k,1);
            end
    end
    for k=1:kmax
        ddb_wldep('append',fname,squeeze(s(:,:,k)),'negate','n','bndopt','n');
    end
end

%% Temperature
if handles.model.delft3dflow.domain(id).temperature.include
    switch lower(handles.model.delft3dflow.domain(id).temperature.ICOpt)
        case{'constant'}
            s=zeros(mmax,nmax,kmax)+handles.model.delft3dflow.domain(id).temperature.ICConst;
        case{'linear'}
            pars=handles.model.delft3dflow.domain(id).temperature.ICPar;
            s=ddb_interpolateInitialConditions(dp,thick,pars,'linear');
        case{'block'}
            pars=handles.model.delft3dflow.domain(id).temperature.ICPar;
            s=ddb_interpolateInitialConditions(dp,thick,pars,'block');
        case{'per layer'}
            for k=1:kmax
                s(:,:,k)=zeros(mmax,nmax)+handles.model.delft3dflow.domain(id).temperature.ICPar(k,1);
            end
    end
    for k=1:kmax
        ddb_wldep('append',fname,squeeze(s(:,:,k)),'negate','n','bndopt','n');
    end
end

%% Sediments
if handles.model.delft3dflow.domain(id).sediments.include
    for i=1:handles.model.delft3dflow.domain(id).nrSediments
        switch lower(handles.model.delft3dflow.domain(id).sediment(i).ICOpt)
            case{'constant'}
                s=zeros(mmax,nmax,kmax)+handles.model.delft3dflow.domain(id).sediment(i).ICConst;
            case{'linear'}
                pars=handles.model.delft3dflow.domain(id).sediment(i).ICPar;
                s=ddb_interpolateInitialConditions(dp,thick,pars,'linear');
            case{'block'}
                pars=handles.model.delft3dflow.domain(id).sediment(i).ICPar;
                s=ddb_interpolateInitialConditions(dp,thick,pars,'block');
            case{'per layer'}
                for k=1:kmax
                    s(:,:,k)=zeros(mmax,nmax)+handles.model.delft3dflow.domain(id).sediment(i).ICPar(k,1);
                end
        end
        for k=1:kmax
            ddb_wldep('append',fname,squeeze(s(:,:,k)),'negate','n','bndopt','n');
        end
    end
end

%% Tracers
if handles.model.delft3dflow.domain(id).tracers
    for i=1:handles.model.delft3dflow.domain(id).nrTracers
        switch lower(handles.model.delft3dflow.domain(id).tracer(i).ICOpt)
            case{'constant'}
                s=zeros(mmax,nmax,kmax)+handles.model.delft3dflow.domain(id).tracer(i).ICConst;
            case{'linear'}
                pars=handles.model.delft3dflow.domain(id).tracer(i).ICPar;
                s=ddb_interpolateInitialConditions(dp,thick,pars,'linear');
            case{'block'}
                pars=handles.model.delft3dflow.domain(id).tracer(i).ICPar;
                s=ddb_interpolateInitialConditions(dp,thick,pars,'block');
            case{'per layer'}
                for k=1:kmax
                    s(:,:,k)=zeros(mmax,nmax)+handles.model.delft3dflow.domain(id).tracer(i).ICPar(k,1);
                end
        end
        for k=1:kmax
            ddb_wldep('append',fname,squeeze(s(:,:,k)),'negate','n','bndopt','n');
        end
    end
end

close(wb);

