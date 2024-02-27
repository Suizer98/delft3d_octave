function smatrix = interp_z2sigma(z, zmatrix, sigma, eta, depth, varargin)
%INTERP_Z2SIGMA interpolate z layer values to sigma layers
%
%   smatrix = INTERP_Z2SIGMA(z, zmatrix, sigma, eta, depth)
%
% where z[m] is positive UP, sigma [-1 ..0] is positive UP,
% eta [m] is the waterlevel positive UP, depth is the 
% depth positive UP, and zmatrix is a vector or matrix
% where the LAST dimension matches length(z). smatrix
% is a vector or matrix where the LAST dimension matches length(sigma).
% eta and depth can either be a scaler (constant) or 
% vector or matrix with the same size as sz(1:end-1) when
% sz = size(zmatrix) or sz = size(smatrix).
%
% The interpolation method can also be supplied as <keyword,value>
% pairs (not as direct arguments as in INTERP1) and are passed to INTERP1.
% By default method is 'linear' in the z-range, and 'nearest' outside
% the z-range, meaning that linear interpolation will "saturate" outside the values
% at the extremes of the z-domain (NB a combination not available in INTERP1).
%
%   smatrix = INTERP_Z2SIGMA(z, zmatrix, sigma, eta, 'method',method,'extrap',extrap)
%
% Example: A waterlevel of 0m (MSL) at a 20m deep location. We have
%          salinity data [34 32 31] at 3 z-levels positive down: [0 20 40] m  relative to
%          a reference level at zmax=-40 (the deepest z-model location is
%          40 m deep) and want to interpolate to 30 sigma layers
%          spaces between 0 (MSL) and -20 (the depth)
%
%          zmax = 40;
%          interp_z2sigma(-[0 20 40],[34 32 31],linspace(0,1,30),0,-20)
%
%See also: interp1, d3d_sigma, d3d_z

%%  --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
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
%  $Id: interp_z2sigma.m 7911 2013-01-14 21:36:06Z boer_g $
%  $Date: 2013-01-15 05:36:06 +0800 (Tue, 15 Jan 2013) $
%  $Author: boer_g $
%  $Revision: 7911 $
%  $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/flow/interp_z2sigma.m $
%  $Keywords: $

   OPT.method = 'linear';
   OPT.extrap = 'nearest';
  %OPT.debug  = 0;

OPT = setproperty(OPT,varargin);

sz0 = size(zmatrix);sz0 = sz0(1:end-1);
if  isvector(zmatrix)
    zmatrix = reshape(zmatrix,[1 1 length(zmatrix)]);
elseif  ndims(zmatrix)==2
    zmatrix = reshape(zmatrix,[1 size(zmatrix)]);
elseif ndims(zmatrix)>3
    error('ndims(zmatrix)>3 not implemented')
end
sz = size(zmatrix);

if isscalar(eta)
    eta = repmat(eta,sz(1:2));
end

if isscalar(depth)
    depth = repmat(depth,sz(1:2));
end

smatrix = repmat(0,[sz(1:2) length(sigma)]);

if strcmpi(OPT.extrap,'nearest')
   OPT.extrap = nan; % will be filled later on
   nearest    = 1;
   else
   nearest    = 0;
end

% check whether array order of z is in positive z direction (k=1 is surface or bottom)
if z(1) > z(end);
   top=1;bot=length(z);
else
   bot=1;top=length(z);
end

for m=1:sz(1)
   for n=1:sz(2)
   
      sigma_z_values = sigma.*(eta(m,n) - depth(m,n)) + depth(m,n);
      
      smatrix(m,n,:) = interp1(z,permute(zmatrix(m,n,:),[3 2 1]),sigma_z_values,OPT.method,OPT.extrap);
      
      % if OPT.debug
      %    TMP = figure();
      %    plot(permute(zmatrix(m,n,:),[3 2 1]),z,'r.-','DisplayName','z input');
      %    hold on
      %    plot(permute(smatrix(m,n,:),[3 2 1]),sigma_z_values,'b.','DisplayName','\sigma output');
      % end
      
      % chop upper and lower layer to nearest values where sigma exceeds z-domain
      if nearest
         zmask = sigma_z_values > z(top);smatrix(m,n,zmask) = zmatrix(m,n,top);
         zmask = sigma_z_values < z(bot);smatrix(m,n,zmask) = zmatrix(m,n,bot);
      end
      
      % if OPT.debug
      %    plot(permute(smatrix(m,n,:),[3 2 1]),sigma_z_values,'bo','DisplayName','\sigma output filtered');
      %    grid on
      %    legend show
      %    xlabel('data')
      %    ylabel('z')
      %    pausedisp
      %    try;close(TMP);end
      % end
   
   end
end

smatrix = reshape(smatrix,[sz0(:)' length(sigma)]);
