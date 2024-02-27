function [handles err] = ddb_ModelMakerToolbox_Delft3DFLOW_generateBoundaryConditions(handles, id, filename)
%DDB_GENERATEBOUNDARYCONDITIONSDELFT3DFLOW  One line description goes here.
%
%   This will determine the amplitude and phases per location
%   a) Makes on row of x's and y's
%   b) Calculates ampltiudes and phases with readtidemodel
%   -> this includes a diffusion if there are NaNs
%   -> uses a linear interpolation to boundary locations
%   c) default is a water level type, can be changed in 'boundaries'
%
%   Syntax:
%   [handles err] = ddb_generateBoundaryConditionsDelft3DFLOW(handles, id, varargin)
%
%   Input:
%   handles  =
%   id       =
%   varargin =
%
%   Output:
%   handles  =
%   err      =
%
%   Example
%   ddb_generateBoundaryConditionsDelft3DFLOW
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
err='';

% model=handles.model.delft3dflow.domain(id);

if handles.model.delft3dflow.domain(id).nrOpenBoundaries==0
    err='First generate or load open boundaries';
    return
end

wb = waitbox('Generating Boundary Conditions ...');

try
    
    ii=handles.toolbox.modelmaker.activeTideModelBC;
    name=handles.tideModels.model(ii).name;
    if strcmpi(handles.tideModels.model(ii).URL(1:4),'http')
        tidefile=[handles.tideModels.model(ii).URL '/' name '.nc'];
    else
        tidefile=[handles.tideModels.model(ii).URL filesep name '.nc'];
    end
    
    % Generate boundary conditions
    
    nb=handles.model.delft3dflow.domain(id).nrOpenBoundaries;
    
    cs.name='WGS 84';
    cs.type='Geographic';
    
    for i=1:nb
        xa(i)=handles.model.delft3dflow.domain(id).openBoundaries(i).x(1);
        ya(i)=handles.model.delft3dflow.domain(id).openBoundaries(i).y(1);
        xb(i)=handles.model.delft3dflow.domain(id).openBoundaries(i).x(end);
        yb(i)=handles.model.delft3dflow.domain(id).openBoundaries(i).y(end);
        [xa(i),ya(i)]=ddb_coordConvert(xa(i),ya(i),handles.screenParameters.coordinateSystem,cs);
        [xb(i),yb(i)]=ddb_coordConvert(xb(i),yb(i),handles.screenParameters.coordinateSystem,cs);
    end
    
    xx=[xa xb];
    yy=[ya yb];
    
    igetwl=0;
    for i=1:nb
        if strcmpi(handles.model.delft3dflow.domain(id).openBoundaries(i).forcing,'A')
            switch lower(handles.model.delft3dflow.domain(id).openBoundaries(i).type)
                case{'r','z','n'}
                    igetwl=1;
            end
        end
    end
    
    if igetwl
        
        [ampz,phasez,conList] = readTideModel(tidefile,'type','h','x',xx,'y',yy,'constituent','all');

        % Add A0 as first component
        a0=0.0;
        conList0=conList;
        conList{1}='A0';
        for ic=1:length(conList0)
            conList{ic+1}=conList0{ic};
        end
        ampz(2:end+1,:)=ampz;
        phasez(2:end+1,:)=phasez;
        ampz(1,:)=a0;
        phasez(1,:)=0;
                
        if handles.model.delft3dflow.domain(id).timeZone~=0
            % Try to make time zone changes
            cnst=t_getconsts;
            for ic=1:size(cnst.name,1)
                cns{ic}=deblank(cnst.name(ic,:));
                frq(ic)=cnst.freq(ic);
            end
            
            for ic=1:length(conList)
                ii=strmatch(conList{ic},cns,'exact');
                freq=frq(ii); % Freq in cycles per hour
                for jj=1:size(phasez,2)
                    phasez(ic,jj)=phasez(ic,jj)+360*handles.model.delft3dflow.domain(id).timeZone*freq;
                end
            end
            phasez=mod(phasez,360);
        end
        
        ampaz=ampz(:,1:nb);
        ampbz=ampz(:,nb+1:end);
        phaseaz=phasez(:,1:nb);
        phasebz=phasez(:,nb+1:end);
        
        ampaz(isnan(ampaz))=0.0;
        ampbz(isnan(ampbz))=0.0;
        phaseaz(isnan(phaseaz))=0.0;
        phasebz(isnan(phasebz))=0.0;
        
    end
    
    igetvel=0;
    for i=1:nb
        if strcmpi(handles.model.delft3dflow.domain(id).openBoundaries(i).forcing,'A')
            switch lower(handles.model.delft3dflow.domain(id).openBoundaries(i).type)
                case{'r','c'}
                    igetvel=1;
            end
        end
    end
    
    if igetvel
        
        icor=1;
        dpcorfac=1;
        
        % Riemann or current boundaries present
        if icor
            [ampu,phaseu,ampv,phasev,depth,conList] = readTideModel(tidefile,'type','q','x',xx,'y',yy,'constituent','all','includedepth');
        else
            [ampu,phaseu,ampv,phasev,depth,conList] = readTideModel(tidefile,'type','vel','x',xx,'y',yy,'constituent','all','includedepth');
        end

        % Add A0 as first component
        ua0=0.0;
        va0=0.0;
        conList0=conList;

        % First the rest
        for ic=1:length(conList0)
            conList{ic+1}=conList0{ic};
        end
        ampu(2:end+1,:)=ampu;
        ampv(2:end+1,:)=ampv;
        phaseu(2:end+1,:)=phaseu;
        phasev(2:end+1,:)=phasev;

        % A0
        conList{1}='A0';
        if ua0>0
            phaseu(1,:)=0;
        else
            phaseu(1,:)=180;
        end
        if va0>0
            phasev(1,:)=0;
        else
            phasev(1,:)=180;
        end
        ampu(1,:)=abs(ua0);
        ampv(1,:)=abs(va0);
       
        if handles.model.delft3dflow.domain(id).timeZone~=0
            % Try to make time zone changes
            cnst=t_getconsts;
            for ic=1:size(cnst.name,1)
                cns{ic}=deblank(cnst.name(ic,:));
                frq(ic)=cnst.freq(ic);
            end
            for ic=1:length(conList)
                ii=strmatch(conList{ic},cns,'exact');
                freq=frq(ii); % Freq in cycles per hour
                for jj=1:size(phasez,2)
                    phaseu(ic,jj)=phaseu(ic,jj)+360*handles.model.delft3dflow.domain(id).timeZone*freq;
                    phasev(ic,jj)=phasev(ic,jj)+360*handles.model.delft3dflow.domain(id).timeZone*freq;
                end
            end
            phaseu=mod(phaseu,360);
            phasev=mod(phasev,360);
        end
        
        % Units are m2/s
        
        % A
        ampau=ampu(:,1:nb);
        ampav=ampv(:,1:nb);
        % B
        ampbu=ampu(:,nb+1:end);
        ampbv=ampv(:,nb+1:end);
        
        % A
        phaseau=phaseu(:,1:nb);
        phaseav=phasev(:,1:nb);
        % B
        phasebu=phaseu(:,nb+1:end);
        phasebv=phasev(:,nb+1:end);
        
        % Depth
        deptha=-depth(1:nb);
        depthb=-depth(nb+1:end);
        
        [semaa,ecca,inca,phaa]=ap2ep(ampau,phaseau,ampav,phaseav);
        [semab,eccb,incb,phab]=ap2ep(ampbu,phasebu,ampbv,phasebv);
        
        for n=1:nb
            
            bnd=handles.model.delft3dflow.domain(id).openBoundaries(n);
            dx=bnd.x(2)-bnd.x(1);
            dy=bnd.y(2)-bnd.y(1);
            
            if strcmpi(handles.screenParameters.coordinateSystem.type,'geographic')
                % Correct dx
                dx=dx*abs(cos(bnd.y(1)*pi/180));
            end
            
            if strcmpi(bnd.orientation,'negative')
                dx=dx*-1;
                dy=dy*-1;
            end
            
            alphaa=180*atan2(dy,dx)/pi;
            alphab=180*atan2(dy,dx)/pi;
            
            switch lower(handles.model.delft3dflow.domain(id).openBoundaries(n).side)
                case{'left','right'}
                    % u-point
                    alphaa=alphaa-90;
                    alphab=alphab-90;
                case{'bottom','top'}
                    % v-point
                    alphaa=alphaa+90;
                    alphab=alphab+90;
            end
            
            for i=1:size(inca,1)
                inca(i,n)=inca(i,n)-alphaa;
                incb(i,n)=incb(i,n)-alphab;
            end
        end
        
        [ampau,phaseau,ampav,phaseav]=ep2ap(semaa,ecca,inca,phaa);
        [ampbu,phasebu,ampbv,phasebv]=ep2ap(semab,eccb,incb,phab);
        
        ampau(isnan(ampau))=0.0;
        ampbu(isnan(ampbu))=0.0;
        phaseau(isnan(phaseau))=0.0;
        phasebu(isnan(phasebu))=0.0;
        ampav(isnan(ampav))=0.0;
        ampbv(isnan(ampbv))=0.0;
        phaseav(isnan(phaseav))=0.0;
        phasebv(isnan(phasebv))=0.0;
        
    end
    
    NrCons=length(conList);
    for i=1:NrCons
        Constituents(i).name=conList{i};
    end
    
    k=0;
    
    for n=1:nb
        if strcmp(handles.model.delft3dflow.domain(id).openBoundaries(n).forcing,'A')
            
            handles.model.delft3dflow.domain(id).openBoundaries(n).compA=[handles.model.delft3dflow.domain(id).openBoundaries(n).name 'A'];
            handles.model.delft3dflow.domain(id).openBoundaries(n).compB=[handles.model.delft3dflow.domain(id).openBoundaries(n).name 'B'];
            
            % Side A
            k=k+1;
            if igetvel && icor
                dpcorfac=-1/handles.model.delft3dflow.domain(id).openBoundaries(n).depth(1);
            end
            handles.model.delft3dflow.domain(id).astronomicComponentSets(k).name=handles.model.delft3dflow.domain(id).openBoundaries(n).compA;
            handles.model.delft3dflow.domain(id).astronomicComponentSets(k).nr=NrCons;
            for i=1:NrCons
                
                handles.model.delft3dflow.domain(id).astronomicComponentSets(k).component{i}=upper(Constituents(i).name);
                
                switch lower(handles.model.delft3dflow.domain(id).openBoundaries(n).type)
                    case{'z','n'}
                        handles.model.delft3dflow.domain(id).astronomicComponentSets(k).amplitude(i)=ampaz(i,n);
                        handles.model.delft3dflow.domain(id).astronomicComponentSets(k).phase(i)=phaseaz(i,n);
                    case{'c'}
                        handles.model.delft3dflow.domain(id).astronomicComponentSets(k).amplitude(i)=ampau(i,n)*dpcorfac;
                        handles.model.delft3dflow.domain(id).astronomicComponentSets(k).phase(i)=phaseau(i,n);
                    case{'r'}
                        a1=ampau(i,n)*dpcorfac;
                        phi1=phaseau(i,n);
                        pp(n,i)=phi1;
                        % Minimum depth of 1 m !
                        a2=ampaz(i,n)*sqrt(9.81/max(-handles.model.delft3dflow.domain(id).openBoundaries(n).depth(1),1));
                        phi2=phaseaz(i,n);
                        
                        phi1=pi*phi1/180;
                        phi2=pi*phi2/180;
                        
                        if ~strcmpi(handles.model.delft3dflow.domain(id).astronomicComponentSets(k).component{i},'a0')
                            switch lower(handles.model.delft3dflow.domain(id).openBoundaries(n).side)
                                case{'left','bottom'}
                                    [a3,phi3]=combinesin(a1,phi1,a2,phi2);
                                case{'top','right'}
                                    [a3,phi3]=combinesin(a1,phi1,-a2,phi2);
                            end
                        else
                            switch lower(handles.model.delft3dflow.domain(id).openBoundaries(n).side)
                                case{'left','bottom'}
                                    if phi1>0.5*pi && phi1<1.5*pi
                                        % A0 velocity is in grid direction
                                        a3=-a1+a2;
                                    else
                                        % A0 velocity is against grid direction
                                        a3=a1+a2;
                                    end
                                    phi3=0;
                                case{'top','right'}
                                    if phi1>0.5*pi && phi1<1.5*pi
                                        % A0 velocity is in grid direction
                                        a3=-a1-a2;
                                    else
                                        % A0 velocity is against grid direction
                                        a3=a1-a2;
                                    end
                                    phi3=0;
                            end
                        end
                        
                        phi3=180*phi3/pi;
                        phi3=mod(phi3,360);
                        
                        handles.model.delft3dflow.domain(id).astronomicComponentSets(k).amplitude(i)=a3;
                        handles.model.delft3dflow.domain(id).astronomicComponentSets(k).phase(i)=phi3;
                end
                
                handles.model.delft3dflow.domain(id).astronomicComponentSets(k).correction(i)=0;
                handles.model.delft3dflow.domain(id).astronomicComponentSets(k).amplitudeCorrection(i)=1;
                handles.model.delft3dflow.domain(id).astronomicComponentSets(k).phaseCorrection(i)=0;
            end
            
            % Side B
            k=k+1;
            if igetvel && icor
                dpcorfac=-1/handles.model.delft3dflow.domain(id).openBoundaries(n).depth(2);
            end
            handles.model.delft3dflow.domain(id).astronomicComponentSets(k).name=handles.model.delft3dflow.domain(id).openBoundaries(n).compB;
            handles.model.delft3dflow.domain(id).astronomicComponentSets(k).nr=NrCons;
            for i=1:NrCons
                handles.model.delft3dflow.domain(id).astronomicComponentSets(k).component{i}=upper(Constituents(i).name);
                
                switch lower(handles.model.delft3dflow.domain(id).openBoundaries(n).type)
                    case{'z','n'}
                        handles.model.delft3dflow.domain(id).astronomicComponentSets(k).amplitude(i)=ampbz(i,n);
                        handles.model.delft3dflow.domain(id).astronomicComponentSets(k).phase(i)=phasebz(i,n);
                    case{'c'}
                        handles.model.delft3dflow.domain(id).astronomicComponentSets(k).amplitude(i)=ampbu(i,n)*dpcorfac;
                        handles.model.delft3dflow.domain(id).astronomicComponentSets(k).phase(i)=phasebu(i,n);
                    case{'r'}
                        a1=ampbu(i,n)*dpcorfac;
                        phi1=phasebu(i,n);
                        % Minimum depth of 1 m !
                        a2=ampbz(i,n)*sqrt(9.81/max(-handles.model.delft3dflow.domain(id).openBoundaries(n).depth(2),1));
                        phi2=phasebz(i,n);
                        
                        phi1=pi*phi1/180;
                        phi2=pi*phi2/180;
                        
                        if ~strcmpi(handles.model.delft3dflow.domain(id).astronomicComponentSets(k).component{i},'a0')
                            switch lower(handles.model.delft3dflow.domain(id).openBoundaries(n).side)
                                case{'left','bottom'}
                                    [a3,phi3]=combinesin(a1,phi1,a2,phi2);
                                case{'top','right'}
                                    [a3,phi3]=combinesin(a1,phi1,-a2,phi2);
                            end
                        else
                            switch lower(handles.model.delft3dflow.domain(id).openBoundaries(n).side)
                                case{'left','bottom'}
                                    if phi1>0.5*pi && phi1<1.5*pi
                                        % A0 velocity is in grid direction
                                        a3=-a1+a2;
                                    else
                                        % A0 velocity is against grid direction
                                        a3=a1+a2;
                                    end
                                    phi3=0;
                                case{'top','right'}
                                    if phi1>0.5*pi && phi1<1.5*pi
                                        % A0 velocity is in grid direction
                                        a3=-a1-a2;
                                    else
                                        % A0 velocity is against grid direction
                                        a3=a1-a2;
                                    end
                                    phi3=0;
                            end
                        end
                                                
                        phi3=180*phi3/pi;
                        phi3=mod(phi3,360);
                        
                        handles.model.delft3dflow.domain(id).astronomicComponentSets(k).amplitude(i)=a3;
                        handles.model.delft3dflow.domain(id).astronomicComponentSets(k).phase(i)=phi3;
                end
                
                handles.model.delft3dflow.domain(id).astronomicComponentSets(k).correction(i)=0;
                handles.model.delft3dflow.domain(id).astronomicComponentSets(k).amplitudeCorrection(i)=1;
                handles.model.delft3dflow.domain(id).astronomicComponentSets(k).phaseCorrection(i)=0;
            end
        end
    end
    handles.model.delft3dflow.domain(id).nrAstronomicComponentSets=k;
    
    attName=filename(1:end-4);
    handles.model.delft3dflow.domain(id).bcaFile=[attName '.bca'];
    
    ddb_saveBcaFile(handles,id);
    ddb_saveBndFile(handles.model.delft3dflow.domain(id).openBoundaries,handles.model.delft3dflow.domain(id).bndFile);
    
catch
    err='An error occured while generating boundary conditions!';
    a=lasterror;
    disp(a.message);
end

close(wb);

