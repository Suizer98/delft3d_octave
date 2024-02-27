function [dcdx,dcdy]=vs_gradient(x,y,alfa,c)
%VS_GRADIENT calculates spatial gradient of scalar variable
%
%   [dcdx,dcdy] = vs_gradient(x,y,alfa,c)
%
% calculates the spatial gradient vector of scalar c in (x,y) direction.
% x and y are the Delft3d center coordinates, and alfa is the 
% local grid angle (grid orientation). x,y and alfa are 2D matrices, 
% while c can be a 3D matrix (sigma of z layers). The gradient is along  
% the supplied sigma or z layers, i.e. only horizontal for a z plane.
%
% Due to the central difference gradient discreization, [dcdx,dcdy] reside
% in the same (x,y) coordinates as c and alfa.
%
% VS_GRADIENT does the same as GRADIENT2 with the 'fast' discretization, 
% only VS_GRADIENT requires alfa as input (because it is written to  
% Delft3D output anyway) while GRADIENT2 calculates alfa itself.
%
% Example:
%   F      =  vs_use('F:\checkouts\OpenEarthModels\deltares\brazil_patos_lagoon_52S_32E\trim-3d1.dat');
%   D.mask =  vs_let_scalar(F,'map-const' ,'KCS'     ,'quiet'); D.mask(D.mask~=1) = NaN;
%   D.x    =  vs_let_scalar(F,'map-const' ,'XZ'      ,'quiet').*D.mask;
%   D.y    =  vs_let_scalar(F,'map-const' ,'YZ'      ,'quiet').*D.mask;
%   D.alfa =  vs_let_scalar(F,'map-const' ,'ALFAS'   ,'quiet').*D.mask;
%   D.rho  =  vs_let_scalar(F,'map-series',{2},'RHO' ,'quiet');
%   [D.drhodx,D.drhody] = vs_gradient(D.x,D.y,D.alfa,D.rho);
% 
%   subplot(1,2,1); k=1
%   pcolorcorcen(D.x,D.y,D.rho(:,:,k),[.5 .5 .5]);
%   axis equal; axislat; tickmap('ll','format','%.1f'); axis([-52.15  -52.0  -32.3  -32.0])
%   
%   subplot(1,2,2)
%   pcolorcorcen(D.x,D.y,sqrt(D.drhodx(:,:,k).^2 + D.drhody(:,:,k).^2),[.5 .5 .5]);
%   axis equal; axislat; tickmap('ll','format','%.1f'); axis([-52.15  -52.0  -32.3  -32.0])
%
%See also: GRADIENT2, VS_LET

%%  --------------------------------------------------------------------
%   Copyright (C) 2012 Technische Universiteit Delft;Deltares
%       Gerben J. de Boer
%
%       g.j.deboer@tudelft.nl;gerben.deboer@deltares.nl
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

%% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
%  OpenEarthTools is an online collaboration to share and manage data and 
%  programming tools in an open source, version controlled environment.
%  Sign up to recieve regular updates of this function, and to contribute 
%  your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
%  $Id: vs_gradient.m 6844 2012-07-10 10:37:00Z boer_g $
%  $Date: 2012-07-10 18:37:00 +0800 (Tue, 10 Jul 2012) $
%  $Author: boer_g $
%  $Revision: 6844 $
%  $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/vs_gradient.m $
%  $Keywords: $

   kmax = size(c,3);
   
%% calculate dx/dy along grid lines (curvi-linearly)

   dm = sqrt((x(:,3:end) -  x(:,1:end-2)).^2 + (y(:,3:end) -  y(:,1:end-2)).^2);
   dn = sqrt((x(3:end,:) -  x(1:end-2,:)).^2 + (y(3:end,:) -  y(1:end-2,:)).^2);

   dcdm = repmat(nan, size(x));
   dcdn = repmat(nan, size(x));
   dcdx = repmat(nan,[size(x) kmax]);
   dcdy = repmat(nan,[size(x) kmax]);
   
%% Calculate gradients along grid lines (curvi-linearly)
%  and then reorient them with the local grid angle to be along x/y axes.

   for k = 1:kmax
   
      dcdm(:,2:end-1) = (c( :     ,3:end  ,k) - ...
                         c( :     ,1:end-2,k))./dm;
      dcdn(2:end-1,:) = (c(3:end  , :     ,k) - ...
                         c(1:end-2, :     ,k))./dn;
      dcdx(:,:,k)     =  dcdm.*cosd(alfa(:,:)) - ...
                         dcdn.*sind(alfa(:,:));
      dcdy(:,:,k)     =  dcdm.*sind(alfa(:,:)) + ...
                         dcdn.*cosd(alfa(:,:));
   end
