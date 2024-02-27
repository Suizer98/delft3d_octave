function U0 = prandle_1982(D,E,z,w,Udepthavg,k)
%PRANDLE_1982 tidal velocity profile of Prandle 1982
%
% U0 = prandle_1982(D,E,z,w,Udepthavg,k) returns the
% normalized tidal velocity profile U0 = U(z)/avg(U) where
% D [m]             the depth
% E [m2/s]          the constant eddy viscosity,
% z [m]             the height where U0 should be sampled
% k [-]             a friction constant
% w [rad/s] (omega) the radial frequency and
% Udepthavg [m/s]   the depth averaged current.
%
% Do not forget to multiply the result U0 with Udepthavg to obtain real velocities.
%
% Example: Fig 5 of Prandle, 1982a, CSR.
%
%     Um = 1;
%     k  = 0.0025;
%     D  = 20;
%     T  = 12*60+25;
%     w  = 2*pi/T;
%     alpha = 0.0012;
%     s  = linspace(0,1,100); % z/D
%     S  = 10.^(1:.05:4); % 10--10,000
%     
%     U0 = repmat(nan,[length(S) length(s)]);
%     
%     for is=1:length(S)
%       E  = alpha*Um*D;% S  = Udepthavg*T/D;
%       D = Um*T/S(is);
%       z = s*D; %The height U0 should be sampled
%       U0(is,:) = prandle_1982(D,E,z,w,Um,k);
%     end
%     
%     subplot(2,1,1)
%     pcolor(S,s,abs(U0'))
%     shading interp
%     hold on
%     [c,h]=contour(S,s,abs(U0'),[.64 .7 .8 .9 1.10],'k');clabel(c,h)
%     [c,h]=contour(S,s,abs(U0'),[1.01 1.03 1.07 1.14],'k--');clabel(c,h)
%     colorlable=colorbar;
%     ylabel(colorlable, 'U_{0} [-]')
%     set(gca,'xscale','log')
%     xlabel('Depth [m]')
%     ylabel('z/D [-]')
%     text(0,1,' (a)','units','normalized','vert','top')
%     
%     subplot(2,1,2)
%     pcolor(S,s,180*angle(U0')/pi)
%     shading interp
%     hold on
%     [c,h]=contour(S,s,180*angle(U0')/pi,[-8:8],'k');
%     clabel(c,h)
%     colorbar
%     colorlable=colorbar;
%     ylabel(colorlable, 'Phase Difference [ ^{\circ}]')
%     set(gca,'xscale','log')
%     xlabel('Depth [m]')
%     ylabel('z/D [-]')
%     text(0,1,' (b)','units','normalized','vert','top')
%
%See also: tide, t_tide, <a href="http://dx.doi.org/10.1016/0278-4343(82)90004-8">Prandle, 1982a, CSR</a>, <a href="http://dx.doi.org/10.1080/03091928208221735">Prandle, 1982b, GAFD</a>, <a href="http://dx.doi.org/10.1007/s10236-005-0042-1">de Boer et al, 2006</a>, <a href="http://www.ngfweb.no/docs/NGF_GP_Vol04_no5.pdf">Sverdrup, 1927</a>

%   --------------------------------------------------------------------
%   Copyright (C) 2004 Delft University of Technology
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

% $Id: prandle_1982.m 12294 2015-10-13 09:49:04Z cclaessens.x $
% $Date: 2015-10-13 17:49:04 +0800 (Tue, 13 Oct 2015) $
% $Author: cclaessens.x $
% $Revision: 12294 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/phys_fun/prandle_1982.m $

method = 1;

switch method

   %% explicit one-line notation version 1 of de Boer et al, 2006: dx.doi.org/10.1007/s10236-005-0042-1

case 1

   s  = 8.*k.*abs(Udepthavg)./(3.*pi.*E);
   
   L  = (1-1i).*sqrt(E./(2.*w));
   
   U0 = (cosh((z-D)./L) - cosh(D./L) + (       - 1./(L.*s)).*sinh(D./L))./...
        (               - cosh(D./L) + ((L./D) - 1./(L.*s)).*sinh(D./L));
   

   %%  explicit one-line notation version 2 of de Boer et al, 2006: dx.doi.org/10.1007/s10236-005-0042-1

case 2

   s  = 8.*k.*abs(Udepthavg)./(3.*pi.*E);
   
   a  = (1+1i).*sqrt(w./(2.*E));
   
   U0 = (cosh((z-D).*a) - cosh(D.*a) + (          - a./s).*sinh(D.*a))./...
        (               - cosh(D.*a) + (1./(a.*D) - a./s).*sinh(D.*a));
   

   %%  OR Prandle's multi-line notation (same results), CSR

case 3

   b  = sqrt(1i.*(w)./E); %  Eq. 6
   
   j  = 3.*pi.*E.*b ./(8.*k.*abs(Udepthavg)); % Eq 16 with j=J*sqrt(i)
   
   y  = b.*D;                                 % Eq 17 with y=Y*sqrt(i)
   
   T  =      (1-exp(2.*y)).*(j -(1./y) -1)     - 2.*exp(2.*y);     % Eq 12
   Q  = (    (1-exp(2.*y)).*(j           ) - 1 -    exp(2.*y))./T; % Eq 13
   
   U0 = ( exp( b.*z       ) + ...
          exp(-b.*z + 2.*y))./T + Q;  % Eq 11
         
end
