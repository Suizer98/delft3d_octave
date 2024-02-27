function varargout = d3d_sigma(thick,varargin);
%D3D_SIGMA   calculates the relative vertical sigma positions in %
%
% [centres]                            = d3d_sigma(thick);
% [centres,interfaces]                 = d3d_sigma(thick);
% [centres,interfaces,centres_bounded] = d3d_sigma(thick);
%
% where thick are the relative layer thicknesses from top to bottom in percents
% (reverse with respect to D3D_Z)
%
% D3D_SIGMA calculates the 
% - sigma positions of the cell interfaces  [1:kmax  ]
% - sigma positions of the cell centres     [1:kmax+1]
% - sigma positions of the cell centres + the surface and bottom boundary
%                                           [1:kmax+2]
%
% N.B. The first element of thick and centres and inferterfaces
% give refer to the uppermost layer (close to water level)
% 
% The reference of the sigma coordinates is located at the bottom 
% and points upward: (same as D3D_Z), i.e. 1 refers to the water level.
%
%                    centres                        interface             centres_bounded
%                                                                         
%                                                                         
%  WATERLEVEL     . ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~  interface(1)      =  centres_bounded(1) = 1
% 1 /|\   |       .  centre(1)    * thick(1)       *                      centres_bounded(2)    
%    |    |       .               ------------------ interface(2)         
%    |   (k)      .  centre(2)    * thick(2)       *                      centres_bounded(3)    
%    |    |       .               ------------------ interface(3)         
% (sigma) |       .               *  ...           *                      
%    |    |       .                                                       
%    |    |       .               *  ...           *                      
%    |    |       .               ------------------ interface(kmax)      
% 0 _|_  \|/ kmax .  centre(kmax) * thick(kmax)    *                      centres_bounded)(kmax+1)
%    BOTTOM       . ///\\\///\\\///\\\///\\\///\\\// interface(kmax+1) =  centres_bounded)(kmax+2) = 0
%
%  D3D_SIGMA(thick,epsilon) checks whether the fractions 
%  add up to 1 within accuracy 'epsilon', which is by default 0.001.
%
% See also: delft3d, D3D_Z, interp_z2sigma, pcolorcorcen_sigma

% Subfunctions:
% ------------------------------------------
% sigma_i(thick)
% sigma_c(thick)

%   --------------------------------------------------------------------
%   Copyright (C) 2003-2007 Delft University of Technology
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
%   USA
%   --------------------------------------------------------------------

% $Id: d3d_sigma.m 8049 2013-02-08 14:48:17Z boer_g $
% $Date: 2013-02-08 22:48:17 +0800 (Fri, 08 Feb 2013) $
% $Author: boer_g $
% $Revision: 8049 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/d3d_sigma.m $

epsilon = 0.001;

if nargin==2
   epsilon = varargin{1};
end

if abs(1.0-sum(thick)) < epsilon;
   centres         = sigma_c(thick(:));
   interfaces      = sigma_t(thick(:));
   centres_bounded = [1;centres;0];
else
   error(['Layer thickness do not add up to 1. Difference = ',num2str(1.0-sum(thick))])
end

    if nargout<2
   varargout = {centres};
elseif nargout==2
   varargout = {centres,interfaces};
elseif nargout==3
   varargout = {centres,interfaces,centres_bounded};
end   

% =============================================

function centres    = sigma_c(thick),

   kmax             = length(thick);
   centres          = zeros(size(thick));
   centres(1)       = thick(1).*0.5;
   for k=2:kmax
    centres(k)      = sum(thick(1:k-1))+0.5*thick(k);
   end
   centres          = 1 - centres;
   
% =============================================

function interfaces = sigma_t(thick),

   kmax             = length(thick);
   if size(thick,1) == 1
      interfaces    = [0 cumsum(thick)];
   else
      interfaces    = [0 cumsum(thick)']';
   end
   interfaces       = 1 - interfaces;
   
   % interfaces       = 1 - interfaces(1:kmax);

% = EOF =======================================
