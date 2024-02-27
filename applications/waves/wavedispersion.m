function varargout = wavedispersion(varargin)
%WAVEDISPERSION   Approximates the dispersion relation for ocean surface waves
%
% L = wavedispersion(T,d); % T = period      [s]
%                          % d = depth       [m]
%                          % L = wave length [m]
%
% Wave length according to linear wave dispersion relation:
%
% L = g*T^2/2/pi*tanh(kd)
%
% Note that for shallow water (h<L/20 or hd<<1): L = T*sqrt(g*d)
% Note that for deep    water (h>L/2  or hd>>1): L = g*T^2/2/pi
%
% L = wavedispersion(T,d,method) where method is
%
% 'guo' (DEFAULT)  (0.7% accurate over all wave lengths)
%
%     Approximation by Guo, 2002. "Simple and explicit solution of wave 
%     dispersion eqution.", Coastal Engineering, 45, 71--74.
%
% 'pade' (2% accurate over all wave lengths)
%
%     Pade approximation by Eq. (2.17) in Ian Young, 1999, 
%     "Wind generated Ocean Waves". Elsevier Ocean engineering Book Series, Volume 2.
%     Note: This relation is used in SWAN.
%
% wavedispersion('test') or 
% wavedispersion('test',method) shows plot of accuracy of method.
%
% See also: GADE1958, WAVELENGTH (Mathworks downloadcentral)

%   --------------------------------------------------------------------
%   Copyright (C) 2007 Delft University of Technology
%       Gerben J. de Boer
%
%       g.j.deboer@tudelft.nl	
%
%       Fluid Mechanics Section
%       Faculty of Civil Engineering and Geosciences
%       PO Box 5048
%       2600 GA Delft
%       The Netherlands
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA or
%   http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

OPT.method = 'guo';
OPT.g      = 9.81;

if ~ischar(varargin{1})

   period = varargin{1};
   depth  = varargin{2};
   L      = nan.*zeros(size(depth)); % to maintain correct 2D, or 3D shape, if any
   
   if nargin==3
      OPT.method = varargin{3};
   end

   if strcmpi(OPT.method,'pade')

      w = (2*pi./period).^2.*depth./OPT.g;
      L = period.*sqrt(OPT.g.*depth./(w + 1./(+ 1.000       ... 
                                          + 0.666.*w    ...
                                          + 0.445.*w.^2 ...
                                          - 0.105.*w.^3 ...
                                          + 0.272.*w.^2)));
                                          
   elseif strcmpi(OPT.method,'guo')
   
      sigma = 2*pi./period;
      L     = 2*pi*OPT.g./(sigma.^2.*((1-exp(-(sigma.*sqrt(depth./OPT.g)).^(5/2))).^(-2/5)));
      
   else
   
      error(['Method unknown: ',OPT.method])
   end
   
   varargout = {L};
   
elseif ischar(varargin{1})

   if nargin==2
      OPT.method = varargin{2};
   end

   if strcmp(varargin{1},'test')
  
   legendtext1 = [];
   legendtext2 = [];
   
   i=0;
   
   for h=[1 10 100]

      i=i+1;
   
      T        = 0.5:0.5:40;
      L        = wavelength    (T,h);
      L_approx = wavedispersion(T,h,OPT.method);
      
      subplot(3,1,1)
      plot(T,L,'k-' ,'linewidth',i);
      legendtext1 = strvcat(legendtext1,['h= ',num2str(h),', L']);

      hold on;
      plot(T,L_approx,'k--','linewidth',i);
      legendtext1 = strvcat(legendtext1,['h= ',num2str(h),', L_{',OPT.method,'}']);

      subplot(3,1,2)
      plot(T,L./L_approx,'k--','linewidth',i);
      hold on
      legendtext2 = strvcat(legendtext2,['h= ',num2str(h),', L/ L_{',OPT.method,'}']);

      subplot(3,1,3)
      plot(2*pi./T,2.*pi./L,'k--','linewidth',i);
      hold on

   end
   
   subplot(3,1,1)
   legend (legendtext1)
   grid on
   xlabel ('T [s]')
   ylabel ('L [m]')
  %set    (gca,'xscale','log')
   set    (gca,'yscale','log')
   title  (['Accuracy of wavelength by method: ',OPT.method])
   grid on
   
   subplot(3,1,2)
   legend (legendtext2)
   grid on
   xlabel ('T [s]')
   ylabel (['L/ L_{',OPT.method,'} [m]'])
  %set    (gca,'xscale','log')
   grid on
  
   subplot(3,1,3)
   xlabel ('k [rad/m]');
   ylabel ('\omega [rad/s]');
   grid on

   end
   
end

%% EOF