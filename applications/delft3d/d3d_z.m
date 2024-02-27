function varargout = d3d_z(thick,ztop,zbot,varargin);
%D3D_Z   calculates the absolute z-layer positions in m
%
% [centres]                            = D3D_Z(thick,ztop,zbot);
% [centres,interfaces]                 = D3D_Z(thick,ztop,zbot);
% [centres,interfaces,centres_bounded] = D3D_Z(thick,ztop,zbot);
%
% where thick are the relative layer thicknesses from top to bottom in percents
% (reverse with respect to D3D_SIGMA).
%
% This function is meant to obtain the Z-MODEL layer description 
% required based from a SIGMA-MODEL estimate. To obtain z centres
% from z interfaces ZK, simply do corner2center1(ZK).
%
% D3D_Z calculates the 
% - z-layer positions of the cell interfaces  [1:kmax  ]
% - z-layer positions of the cell centres     [1:kmax+1]
% - z-layer positions of the cell centres + the surface and bottom boundary
%
% N.B. The first element of thick and centres and interfaces
% given refers to the lowermost layer (close to bottom)
% 
% The reference of the z-coordinates is located at the bottom 
% and points upward: (same as D3D_SIMGA).
%
%                    centres                        interface             centres_bounded
%                                                                         
%                                                                         
%  WATERLEVEL     . ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~  interface(kmax)   =  centres_bounded(1) = 1
%        /|\ kmax .  centre(kmax) * thick(kmax)    *                      centres_bounded(2)    
%         |       .               ------------------                      
%        (k)      .               *                *                      centres_bounded(3)    
%         |       .               ------------------                      
%         |       .               *  ...           *                      
%         |       .                                                       
%         |       .               *  ...           *                      
%         |       .               ------------------ interface(2)         
%         |       .  centre(1)    * thick(1)       *                      centres_bounded)(kmax+1)
%    BOTTOM       . ///\\\///\\\///\\\///\\\///\\\// interface(1)      =  centres_bounded)(kmax+2) = 0
%
%  D3D_SIGMA(thick,epsilon) checks whether the fractions 
%  add up to 1 within accuracy 'epsilon', which is by default 0.001.
%
% See also: delft3d, D3D_SIGMA, interp_z2sigma

% Subfunctions:
% ------------------------------------------
% sigma_i(thick)
% sigma_c(thick)

%   --------------------------------------------------------------------
%   Copyright (C) 2008 Delft University of Technology
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

% $Id: d3d_z.m 7882 2013-01-07 15:41:47Z boer_g $
% $Date: 2013-01-07 23:41:47 +0800 (Mon, 07 Jan 2013) $
% $Author: boer_g $
% $Revision: 7882 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/d3d_z.m $

epsilon = 0.001;

if nargin==4
   epsilon = varargin{1};
end

if abs(1.0-sum(thick)) < epsilon;

%  |      |                                         
%  *------*----------------------------------- ztop = interface(end) WATER LEVEL
%  |      |                                         
%  |     dz(3)  * centres(end)                      
%  |      |     |                                   
%  |   ---*---  |                  * interface(end-1)
%  |      |     |                  |                
%  ztot  dz(2)  |  * centres(2)    |                
%  |      |     |  |               |                
%  |   ---*---  |  |               |  * interface(2)
%  |      |     |  |               |  |             
%  |     dz(1)  |  |  * centres(1) |  |             
%  |      |     |  |  |            |  |             
%  *------*-----*--*--*------------*--*------  zbot = interface(1)   BOTTOM
%  |      |                                         

   ztot            = ztop - zbot;
   dz              = thick.*ztot;
   interfaces      = [0 cumsum(dz)];  % first interface is a zbot, so add a leading zero
   interfaces      = zbot + interfaces; % shift upwards so first, bottom layer is at zbot
   centres         = corner2center1(interfaces);
   centres_bounded = [zbot;centres(:);ztop]'; % transpose to have same dimensions

else
   error(['Layer thickness do not add up to 1. Difference = ',num2str(1.0-sum(thick))])
end

    if nargout==1
   varargout = {centres};
elseif nargout==2
   varargout = {centres,interfaces};
elseif nargout==3
   varargout = {centres,interfaces,centres_bounded};
end   
