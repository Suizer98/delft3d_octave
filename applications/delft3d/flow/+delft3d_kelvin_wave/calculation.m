function varargout = calculation(x,y,d, F, C,varargin)
%DELFT3D_KELVIN_WAVE.CALCULATION   analytical solution (iterative friction) of Kelvin wave
%
%  [ETA,<VEL>] = delft3d_kelvin_wave.calculation(x,y,d, F, C,<ifreq>)
%
% where x is the alongshore axis, y the crossshore axis and d is the depth.
% F and C are strucs with settings provided by delft3d_kelvin_wave.input.
%
% For documentation of the methods please refer to:
%
% * Jacobs, Walter, 2004. Modelling the Rhine River Plume 
%   MSc. thesis, TU Delft, Civil Engineering.
%   http://resolver.tudelft.nl/uuid:cf8e752d-7ba7-4394-9a94-2b73e14f9949
% * de Boer, G.J. 2009. On the interaction between tides and
%   stratification in the Rhine Region of Freshwater Influence
%   PhD thesis TU Delft, Civil Engineering (chapter 3).
%   http://resolver.tudelft.nl/uuid:c5c07865-be69-4db2-91e6-f675411a4136
%
%See also: delft3d_kelvin_wave

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2004 Delft University of Technology
%       Walter Jacobs and Gerben J. de Boer
%
%       g.j.deboer@tudelft.nl	
%
%       Fluid Mechanics Section
%       Faculty of Civil Engineering and Geosciences
%       PO Box 5048
%       2600 GA Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id: calculation.m 7826 2012-12-12 13:26:01Z boer_g $
% $Date: 2012-12-12 21:26:01 +0800 (Wed, 12 Dec 2012) $
% $Author: boer_g $
% $Revision: 7826 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/flow/+delft3d_kelvin_wave/calculation.m $
% $Keywords: $

   if nargin==4
      ifreq  = varargin{1};
      F.eta0 = F.eta0(ifreq);
      C.Tt   = C.Tt  (ifreq);
      C.w    = C.w   (ifreq);
      C.L0   = C.L0  (ifreq);
      C.k0   = C.k0  (ifreq);
   end


   T.t0 = 0;% time sampling points

   OPT.plot_iteration = 0;

%% Iteration parameters

   OPT.v_residue_min = 0.001;
   OPT.n_iterations  = 0;
   OPT.relaxation    = 0.5;
   OPT.v_residue     = Inf;

%% Initialize

   VEL.abs0         = repmat((1+0i),size(x));
   VEL.complex      = repmat((1+0i),size(x));
   VEL.abs          = repmat((1+0i),size(x));
   VEL.arg          = repmat((1+0i),size(x));

   while max(OPT.v_residue(:)) > OPT.v_residue_min; 
       
      OPT.n_iterations = OPT.n_iterations +1;
      
   %% Friction
   
      VEL.abs0         = VEL.abs0 + OPT.relaxation.*(VEL.abs - VEL.abs0);
      VEL.abs          = nan;
   
      kappa            = ((8/(3*pi))*C.Cf).*(VEL.abs0./d);     % [1/s] linearised friction parameter in alongshore direction
      sigma            = kappa./C.w;                           % [-]   relation between friction and inertia
        
   %% General
   
      k                = (i*C.k0).*      (1 - 1i.*sigma).^0.5;  % [-] Alongshore variation
      m                = (C.f./C.c0).*1./(1 - 1i.*sigma).^0.5;  % [-] Cross-shore variation
      
   %% Water level
      
      ETA.complex      = F.eta0.*exp(  x.*m ...        % cross
                                     - y.*k ...        % along
                                     + 1i*C.w.*T.t0...
                                     + i*F.alpha) ;    % [m]   water level
      ETA.abs          = abs  (ETA.complex);           % [m/s] amplitude of velocity
      ETA.arg          = angle(ETA.complex);           % [rad] phase of velocity
   
   %% Velocity
      
      VEL.complex      = ETA.complex.*      (C.g*k./(1i*C.w + kappa));  % [m/s] velocity
      VEL.abs          = ETA.abs    .* abs  (C.g*k./(1i*C.w + kappa));  % [m/s] amplitude of velocity
      VEL.arg          = ETA.arg     + angle(C.g*k./(1i*C.w + kappa));  % [rad] phase of velocity
      
     
      OPT.v_residue         = abs(VEL.abs-VEL.abs0);
       
      if OPT.plot_iteration
   
         subplot(1,2,1)
         surfcorcen(x,y,VEL.abs,[.5 .5 .5])
         view(220,40)
         title(['Velocity, max velocity residue: ',num2str(max(OPT.v_residue(:))),' > limit of ',num2str(OPT.v_residue_min)])
   
         subplot(1,2,2)
         surfcorcen(x,y,ETA.abs,[.5 .5 .5])
         view(220,40)
         title(['Water level, iteration :',num2str(OPT.n_iterations)])
         
         disp('Press key to continue')
         pause
      end
       
   end;

%% Water level gradient

   ETA.complex_d_eta_d_y = ETA.complex.*   (-k);  % [m/m] water level gradient
   ETA.abs_d_eta_d_y     = ETA.abs.*  abs  (-k);  % [m/m] amplitude of water level gradient
   ETA.arg_d_eta_d_y     = ETA.arg +  angle(-k);  % [rad] phase of water level gradient
   
   VEL = rmfield(VEL,'abs0');
   
   VEL.k     = k;
   VEL.m     = m;
   VEL.kappa = kappa;
   VEL.sigma = sigma;
   
   ETA.k     = k;
   ETA.m     = m;
   ETA.kappa = kappa;
   ETA.sigma = sigma;
   
   if nargout==1
      varargout = {ETA};
   elseif nargout== 2
      varargout = {ETA, VEL};
   end

%% EOF