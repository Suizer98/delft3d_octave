function ddb_Delft3DFLOW_fourier(varargin)
%DDB_DELFT3DFLOW_FOURIER  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_Delft3DFLOW_fourier(varargin)
%
%   Input:
%   varargin =
%
%
%
%
%   Example
%   ddb_Delft3DFLOW_fourier
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

% $Id: ddb_Delft3DFLOW_fourier.m 12596 2016-03-17 10:04:25Z ormondt $
% $Date: 2016-03-17 18:04:25 +0800 (Thu, 17 Mar 2016) $
% $Author: ormondt $
% $Revision: 12596 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/models/Delft3DFLOW/gui/ddb_Delft3DFLOW_fourier.m $
% $Keywords: $

%%
if isempty(varargin)
    ddb_zoomOff;
    ddb_refreshScreen;
    handles=getHandles;
    
    handles.model.delft3dflow.domain(ad).fourier.parameterList={'water level','velocity','discharge'};
    handles.model.delft3dflow.domain(ad).fourier.pList={'wl','uv','qf'};
    k=3;
    for i=1:handles.model.delft3dflow.domain(ad).salinity.include
        k=k+1;
        handles.model.delft3dflow.domain(ad).fourier.parameterList{k}='salinity';
        handles.model.delft3dflow.domain(ad).fourier.pList{k}='cs';
    end
    for i=1:handles.model.delft3dflow.domain(ad).temperature.include
        k=k+1;
        handles.model.delft3dflow.domain(ad).fourier.parameterList{k}='temperature';
        handles.model.delft3dflow.domain(ad).fourier.pList{k}='ct';
    end
    ncon=0;
    for i=1:handles.model.delft3dflow.domain(ad).nrTracers
        k=k+1;
        ncon=ncon+1;
        handles.model.delft3dflow.domain(ad).fourier.parameterList{k}=handles.model.delft3dflow.domain(ad).tracer(i).name;
        handles.model.delft3dflow.domain(ad).fourier.pList{k}=['c' num2str(ncon)];
    end
    for i=1:handles.model.delft3dflow.domain(ad).nrSediments
        k=k+1;
        ncon=ncon+1;
        handles.model.delft3dflow.domain(ad).fourier.parameterList{k}=handles.model.delft3dflow.domain(ad).sediment(i).name;
        handles.model.delft3dflow.domain(ad).fourier.pList{k}=['c' num2str(ncon)];
    end
    
    for k=1:handles.model.delft3dflow.domain(ad).KMax
        handles.model.delft3dflow.domain(ad).fourier.layerList{k}=num2str(k);
    end
    
    setHandles(handles);
    
else
    handles=getHandles;
    opt=varargin{1};
    switch(lower(opt))
            
        case{'maketable'}
            
            components={'M2','S2','N2','K2','K1','O1','P1','Q1'};
            
            handles.model.delft3dflow.domain(ad).fourier.generateTable.parameterNumber=[];
            handles.model.delft3dflow.domain(ad).fourier.generateTable.componentNumber=[];
            handles.model.delft3dflow.domain(ad).fourier.generateTable.layer=[];
            handles.model.delft3dflow.domain(ad).fourier.generateTable.fourier=[];
            handles.model.delft3dflow.domain(ad).fourier.generateTable.max=[];
            handles.model.delft3dflow.domain(ad).fourier.generateTable.min=[];
            handles.model.delft3dflow.domain(ad).fourier.generateTable.ellipse=[];
            
            tt=t_getconsts;
            names=tt.name;
            
            for i=1:size(names,1)
                cnsts{i}=deblank(names(i,:));
            end
            
            for i=1:length(components)
                ii=strmatch(components{i},cnsts,'exact');
                handles.model.delft3dflow.domain(ad).fourier.generateTable.parameterNumber(i)=1;
                handles.model.delft3dflow.domain(ad).fourier.generateTable.componentNumber(i)=ii;
                handles.model.delft3dflow.domain(ad).fourier.generateTable.layer(i)=1;
                handles.model.delft3dflow.domain(ad).fourier.generateTable.fourier(i)=1;
                handles.model.delft3dflow.domain(ad).fourier.generateTable.max(i)=0;
                handles.model.delft3dflow.domain(ad).fourier.generateTable.min(i)=0;
                handles.model.delft3dflow.domain(ad).fourier.generateTable.ellipse(i)=0;
            end
            
            setHandles(handles);
            
            % setUIElements('delft3dflow.output.outputpanel.fourier');
            
        case{'generateinput'}
            
            % Compute mean latitude of model
            xm=nanmean(nanmean(handles.model.delft3dflow.domain(ad).gridX));
            ym=nanmean(nanmean(handles.model.delft3dflow.domain(ad).gridY));
            cs.name='WGS 84';
            cs.type='Geographic';
            [xm,ym]=ddb_coordConvert(xm,ym,handles.screenParameters.coordinateSystem,cs);
            
            spinuptime=handles.model.delft3dflow.domain(ad).fourier.spinUpTime/1440;
            
            tt=t_getconsts;
            names=tt.name;
            freqs=tt.freq;
            
            for i=1:size(names,1)
                cnsts{i}=deblank(names(i,:));
            end
            
            handles.model.delft3dflow.domain(ad).fourier.editTable=[];
            
            k=0;
            
            for j=1:length(handles.model.delft3dflow.domain(ad).fourier.generateTable.componentNumber)
                
                % Find index of component
                ii=handles.model.delft3dflow.domain(ad).fourier.generateTable.componentNumber(j);
                
                freq=freqs(ii);
                
                % Compute argument based on argument at reference time and correction of the mean model time
                [v,u,f]=t_vuf('nodal',0.5*(handles.model.delft3dflow.domain(ad).startTime+handles.model.delft3dflow.domain(ad).stopTime),ii,ym);
                [vref,uref,fref]=t_vuf('nodal',handles.model.delft3dflow.domain(ad).itDate,ii,ym);
                u=(vref+u)*360;
                u=mod(u,360);
                
                ttot=handles.model.delft3dflow.domain(ad).stopTime-handles.model.delft3dflow.domain(ad).startTime-spinuptime;
                
                if freq==0
                    period=ttot;
                else
                    period=1/freq/24;
                end
                
                ncyc=floor(ttot/period);
                dt=handles.model.delft3dflow.domain(ad).timeStep;
                ttot=ncyc*period;
                ntimesteps=round(1440*ttot/dt);
                tstart=handles.model.delft3dflow.domain(ad).stopTime-ntimesteps*dt/1440;
                tstop=handles.model.delft3dflow.domain(ad).stopTime;
                
                nopt=0;
                optNr=[];
                if handles.model.delft3dflow.domain(ad).fourier.generateTable.fourier(j)
                    nopt=nopt+1;
                    optNr(nopt)=1;
                end
                if handles.model.delft3dflow.domain(ad).fourier.generateTable.max(j)
                    nopt=nopt+1;
                    optNr(nopt)=2;
                end
                if handles.model.delft3dflow.domain(ad).fourier.generateTable.min(j)
                    nopt=nopt+1;
                    optNr(nopt)=3;
                end
                if handles.model.delft3dflow.domain(ad).fourier.generateTable.ellipse(j)
                    nopt=nopt+1;
                    optNr(nopt)=4;
                end
                
                for n=1:nopt
                    k=k+1;
                    handles.model.delft3dflow.domain(ad).fourier.editTable.parameterNumber(k)=handles.model.delft3dflow.domain(ad).fourier.generateTable.parameterNumber(j);
                    handles.model.delft3dflow.domain(ad).fourier.editTable.period(k)=period;
                    handles.model.delft3dflow.domain(ad).fourier.editTable.startTime(k)=tstart;
                    handles.model.delft3dflow.domain(ad).fourier.editTable.startTime(k)=tstart;
                    handles.model.delft3dflow.domain(ad).fourier.editTable.stopTime(k)=tstop;
                    handles.model.delft3dflow.domain(ad).fourier.editTable.nrCycles(k)=ncyc;
                    handles.model.delft3dflow.domain(ad).fourier.editTable.nodalAmplificationFactor(k)=f;
                    handles.model.delft3dflow.domain(ad).fourier.editTable.astronomicalArgument(k)=u;
                    handles.model.delft3dflow.domain(ad).fourier.editTable.layer(k)=handles.model.delft3dflow.domain(ad).fourier.generateTable.layer(j);
                    handles.model.delft3dflow.domain(ad).fourier.editTable.option(k)=optNr(n);
                end
            end
            
            handles.model.delft3dflow.domain(ad).fourier.include=1;
            
            setHandles(handles);
            
        case{'savefoufile'}
            ddb_saveFouFile(handles,ad);
            
        case{'openfoufile'}
            
            %            ddb_readFouFile(handles,id);
            
    end
end

