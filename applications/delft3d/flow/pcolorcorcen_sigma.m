function varargout = pcolorcorcen_sigma(x, sigma, eta, depth, c,varargin)
%PCOLORCORCEN_SIGMA  pcolor for x-sigma plane (cross section, thalweg)
%
% PCOLORCORCEN_SIGMA(x, sigma, eta, depth, c)
% plots pcolor(x,, c) where z is calculated on-the-fly
% according to the CF <a href="http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/apd.html">ocean_sigma_coordinate</a> formulation:
% z = eta + sigma*(eta + depth) with sigma 0 at the water level
% and -1 at the bed/bottom, and depth positive DOWN.
% Note eta and depth can be scalars (constant).
%
% Shading interp when length of x,eta & depth
% is size(c,2), shading flat when lenghth of x, eta & depth
% is one longer AND length(sigma) is size(c,1)+1
%
% Addition of bands with the the lowest and hightest sigma layers 
% stretched to the depth and eta respectively can be chosen with
% keyword pcolorcorcen_sigma(...,'interp','stretched').
%
% The real x-z coordinates can be requested from the handles, e.g.
% h = pcolorcorcen_sigma(...); X = get(h,'XDATA'); Z = get(h,'YDATA');
%
% Example: thalweg slice through an estuary
%
%   x     = linspace(0,10e3,10);
%   sigma = linspace(-1,0,5);
%   [~,c] = meshgrid(x,-100*sigma);
%   eta   = sin(2*pi*x/10e3);
%   depth = 10 - 5e-4*x;
%   pcolorcorcen_sigma(x, sigma, eta, depth, c)
%   colorbarwithvtext('sediment [mg/l]')
%   tickmap('x')
%   ylabel('depth [m]')
%   grid on
%   text(xlim1(1),ylim1(1),' \uparrow sea             ','rotation',90,'verticalalignment','top')
%   text(2e3     ,ylim1(1),' port of Z'                ,'rotation',90)
%   text(7e3     ,ylim1(1),' city of A'                ,'rotation',90)
%   text(xlim1(2),ylim1(1),' \downarrow upstream river','rotation',90,'verticalalignment','bottom')
%
%See also: pcolorcorcen, interp_z2sigma, d3d_sigma

%%  --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
%
%       Gerben de Boer
%
%       gerben.deboer@deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
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

%% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
%  OpenEarthTools is an online collaboration to share and manage data and 
%  programming tools in an open source, version controlled environment.
%  Sign up to recieve regular updates of this function, and to contribute 
%  your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
%  $Id: pcolorcorcen_sigma.m 8123 2013-02-18 15:40:58Z boer_g $
%  $Date: 2013-02-18 23:40:58 +0800 (Mon, 18 Feb 2013) $
%  $Author: boer_g $
%  $Revision: 8123 $
%  $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/flow/pcolorcorcen_sigma.m $
%  $Keywords: $

OPT.shading   = 'interp'; % {'interp','stretched'};

OPT = setproperty(OPT,varargin);

if length(depth)==1
   depth = repmat(depth,size(x));
end

if length(eta)==1
   eta   = repmat(eta  ,size(x));
end

[x,z]=meshgrid(x(:),sigma(:));

for i=1:size(x,2)
    z(:,i) = eta(i) + sigma.*(eta(i) + depth(i));
end

   h    = pcolorcorcen(x,z,c);

if strcmpi(OPT.shading,'stretched')
   holdstate = get(gca,'NextPlot');hold on
   
   zs = [eta(:),  eta(:) + sigma(2).*(eta(:) + depth(:))]'; % start at 2nd layert to have smoth transition
   h(end+1) = pcolorcorcen(x(1:2,:),zs,c(1:2,:));

   zs = [eta(:) + sigma(end-1).*(eta(:) + depth(:)),-depth(:)]';
   h(end+1) = pcolorcorcen(x(end-1:end,:),zs,c(end-1:end,:)); % start at 2nd-last layert to have smoth transition

   set(gca,'NextPlot',holdstate)
end

if nargout > 0
    varargout = {h};
end