function [boundary, error] = ddb_ModelMakerToolbox_Delft3DFM_generate_astronomic_tides(handles, boundary, forcing_file)
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
error = 1;

try
    
    % Determine what to do: Riemmann, velocity or water level
    igetwl  = 0;
    igetvel = 0;
    
    switch boundary.type
        case{'water_level'}
            igetwl              = 1;
            quants={'water_level'};
        case{'water_level_plus_normal_velocity'}
            igetwl              = 1;
            igetvel             = 1;
            quants={'water_level','normal_velocity'};
        case{'water_level_plus_normal_velocity_plus_tangential_velocity'}
            igetwl              = 1;
            igetvel             = 1;
            quants={'water_level','normal_velocity','tangential_velocity'};
        case{'riemann'}
            igetwl              = 1;
            quants={'riemann'};
        case{'normal_velocity'}
            igetwl              = 0;
            igetvel             = 1;
            quants={'normal_velocity'};
%         case{'water_level_plus_uxuyadvection_velocity'}
%             igetwl              = 1;
%             igetvel             = 1;
%             quants={'water_level','uxuyadvection_velocity'};
    end
    
    % Which tidal database?
    ii      = handles.toolbox.modelmaker.activeTideModelBC;
    name    = handles.tideModels.model(ii).name;
    if strcmpi(handles.tideModels.model(ii).URL(1:4),'http')
        tidefile=[handles.tideModels.model(ii).URL '/' name '.nc'];
    else
        tidefile=[handles.tideModels.model(ii).URL filesep name '.nc'];
    end
    
    % Get location, potentially with grid conversion
    cs.name ='WGS 84';
    cs.type ='Geographic';
    [xx,yy] = ddb_coordConvert(boundary.x, boundary.y,handles.screenParameters.coordinateSystem,cs);
    
    % Get waterlevels
    if igetwl
        [gt, conList] = read_tide_model(tidefile,'type','z','x',xx,'y',yy,'constituent','all');
        ampz   = gt.amp;
        phasez = gt.phi;
        ampz(isnan(ampz))=0;
        phasez(isnan(phasez))=0;
    end
    
    % Get velocities
    if igetvel
        [gt, conList] = read_tide_model(tidefile,'type','u','x',xx,'y',yy,'constituent','all');
        ampu   = gt.amp;
        phaseu = gt.phi;
        ampu(isnan(ampu))=0;
        phaseu(isnan(phaseu))=0;
        [gt, conList] = read_tide_model(tidefile,'type','v','x',xx,'y',yy,'constituent','all');
        ampv   = gt.amp;
        phasev = gt.phi;
        ampv(isnan(ampv))=0;
        phasev(isnan(phasev))=0;
        ampu=max(ampu,1e-9);
        ampv=max(ampv,1e-9);
    end
    
    % Constituents
    NrCons=length(conList);
    for i=1:NrCons
        Constituents(i).name=conList{i};
    end
    
    % Set values - to do!!

    nb = boundary.nrnodes;
    
    for iq=1:length(quants)
        
        quant=quants{iq};
        
        boundary.(quant).astronomic_components.forcing_file=forcing_file;
        boundary.(quant).astronomic_components.active=1;
        
        for n=1:nb
            
            if n==1
                dx=boundary.x(2)-boundary.x(1);
                dy=boundary.y(2)-boundary.y(1);
            elseif n==nb
                dx=boundary.x(nb)-boundary.x(nb-1);
                dy=boundary.y(nb)-boundary.y(nb-1);
            else
                dx=boundary.x(n+1)-boundary.x(n-1);
                dy=boundary.y(n+1)-boundary.y(n-1);
            end
            
            if strcmpi(handles.screenParameters.coordinateSystem.type,'geographic')
                % Correct dx
                dx=dx*abs(cos(boundary.y(n)*pi/180));
            end
            
            alfa=180*atan2(dy,dx)/pi + 90; % angle perpendicular to the boundary in the direction of the model domain
            
            for i=1:NrCons
                
                % Set component
                
                switch quant
                    
                    case{'riemann'}
                        
                        amp=ampz(i,n);
                        phi=phasez(i,n);
                        
                        phi=180*phi/pi;
                        phi=mod(phi,360);
                        
                    case{'velocity'}
                        
                    case{'normal_velocity'}
                        
                        [sema,ecc,inc,pha]=ap2ep(ampu(i,n),phaseu(i,n),ampv(i,n),phasev(i,n));
                        
                        inc=inc-alfa;
                        
                        [ampn,phasen,ampt,phaset]=ep2ap(sema,ecc,inc,pha);
                        
%                        amp=ampn/depth(n);
                        amp=ampn;
                        phi=phasen;
                        
                        phi=180*phi/pi;
                        phi=mod(phi,360);
                        
                    case{'tangential_velocity'}
                        
                        [sema,ecc,inc,pha]=ap2ep(ampu(i,n),phaseu(i,n),ampv(i,n),phasev(i,n));
                        
                        inc=inc-alfa;
                        
                        [ampn,phasen,ampt,phaset]=ep2ap(sema,ecc,inc,pha);
                        
%                        amp=ampt/depth(n);
                        amp=ampt;
                        phi=phaset;
                        
                        phi=180*phi/pi;
                        phi=mod(phi,360);
                                                
%                     case{'uxuyadvectionvelocitybnd'}
%                         
                        
                    case{'water_level'}
                        
                        % Set values
                        amp = ampz(i,n);
                        phi = phasez(i,n);

%                     case{'uxuyadvection_velocity'}
%  
%                         
%                         
                        
                end
                
%                 if strcmpi(quant,'uxuyadvection_velocity')
% 
%                     t0=handles.model.dflowfm.domain.tstart;
%                     t1=handles.model.dflowfm.domain.tstop;
%                     dt=600/86400;
%                     tim=t0:dt:t1;
%                     u = makeTidePrediction(tim, conList, ampu(:,n), phaseu(:,n), []);                        
%                     v = makeTidePrediction(tim, conList, ampv(:,n), phasev(:,n), []);                        
%                     boundary.(quant).time_series.nodes(n).name{i}      = Constituents(:,i).name;
%                     boundary.(quant).time_series.nodes(n).time  = tim;
%                     boundary.(quant).time_series.nodes(n).u     = u;
%                     boundary.(quant).time_series.nodes(n).v     = v;
%                     boundary.(quant).astronomic_components.active=0;
%                     boundary.(quant).time_series.active=1;
%                     boundary.normal_velocity.astronomic_components.active=0;
%                     boundary.tangential_velocity.astronomic_components.active=0;
%                     
%                 else
                    boundary.(quant).astronomic_components.nodes(n).name{i}      = Constituents(:,i).name;
                    boundary.(quant).astronomic_components.nodes(n).amplitude(i) = amp;
                    boundary.(quant).astronomic_components.nodes(n).phase(i)     = phi;
%                 end
                
            end
        end
    end
    error = 0;
catch
    error = 1;
end

