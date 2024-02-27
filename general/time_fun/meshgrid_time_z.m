function varargout = meshgrid_time_z(time,thick,bottom,waterlevel,varargin)
%MESHGRID_TIME_Z  generate curvilinear grid of columns
%
%   DAT = meshgrid_time_z(time, thick, bottom, waterlevel)
%
%   Makes 2D arrays suitable for surf and pcolor plots from 1D arrays
%   centered at the time/transect points and at 3 different z points 
%   (so use shading interp) where
%   * thick are fractions that should add up to 1.
%   * bottom is positive up (unlike delft3d)
%   * waterlevel is positive up
%
%   time       (1:no_of_times/no_of_transect_points)
%   thick      (1:no_of_layers)
%   waterlevel (1:no_of_times/no_of_transect_points) or (1)
%   bottom     (1:no_of_times/no_of_transect_points) or (1)
%
%   and where DAT has fields 'cen<ters>', 'int<erface>' and 'cen<ters>_bounded'
%   each having subfields:
%   'x'  (time) and 'z'  (vertical)
%   'x2' (time) and 'z2' (vertical) which are staggered in time 
%                               after extrapolating the 1st and last timestep
%
%      +-#-+-#-+-#-+-#-+   *-*-+-*-+-*-+-*-*
%      | o | o | o | o |   * * | * | * | * *
%      +-#-+-#-+-#-+-#-+   +---+---+---+---+
%      | o | o | o | o |   * * | * | * | * *
%      +-#-+-#-+-#-+-#-+   +---+---+---+---+
%      | o | o | o | o |   * * | * | * | * *
%      +-#-+-#-+-#-+-#-+   +---+---+---+---+
%      | o | o | o | o |   * * | * | * | * *
%      +-#-+-#-+-#-+-#-+   *-*-+-*-+-*-+-*-*
%
%      + int_2
%      o cen
%      * cen_bounded
%      # int
%
%   or in case of array output
%
%   [  times_centers,         z_centers          ,...
%    < times_interfaces,      z_interfaces      >,...
%    < times_centers_bounded, z_centers_bounded >
%    ] = meshgrid_time_z(time,thick,bottom,waterlevel)
%
%
%      ^ vertical                                               colorbar     
%      |       ...       ...       ...       ...       ..       legend       
%      |..    ......    ..%...    ......    ......    ....      +-+   1-  10 
%      |...  ........  ..%%%...  ........  ........  ......     |%|  10- 100 
%      |................%%%%%.................%%.........%.     |#| 100-1000 
%      |%.......#.......%%%%%................%#%.........%%     +-+          
%      |%%...%%###%...%%%#%#%...%%%#.........###%.....%%%%%                  
%      |%%%%%%%###%%%%%%.########%#####......####%....%###%                  
%      +-------------------------------------------------> x time / transect   
%                                                                          
%   handles coordinates as a special case of curvilinear grids 
%   that are orthogonal in time/transect direction, but 
%   are varying in x (time) direction.
%                                                           
%      +                                
%      |                    +            
%      |             +      |     +       
%      |        +    |      |     | layer 1
%      |        |    |      +     +      
%      +        +    +      |     |      
%      |        +    |      +     | layer 2
%      +             +            +      
%
%      bin 1      bin 2   bin 3
%
%   use pcolorcorcen(G.int.x2,G.int.z2,...); for scaling flat   look (cells visible)
%   use pcolorcorcen(G.cen.x ,G.cen.x ,...); for scaling interp look (no cells visible, 
%                                            with half a cell blank around spatio-temporal domain)
%
% NOTE that griddata suffers from issues when interpolating from this grid.
%
%   See also: D3D_SIGMA, MESHGRID, griddata_error

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2006 Delft University of Technology
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
% $Id: meshgrid_time_z.m 8950 2013-07-29 15:22:34Z boer_g $
% $Date: 2013-07-29 23:22:34 +0800 (Mon, 29 Jul 2013) $
% $Author: boer_g $
% $Revision: 8950 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/time_fun/meshgrid_time_z.m $
% $Keywords: $

% TO DO: make also fit for z-planes using arguments (time,ZK,bottom,waterlevel,varargin)
% TO DO: use DEAL

%% Get sigma cooordinates

   [sigma_centres,sigma_interfaces,sigma_centres_bounded] = d3d_sigma(thick);

%% Initialize 2D arrays

   [cen.z        ,cen.x        ] = meshgrid(sigma_centres        (:),time);
   [int.z        ,int.x        ] = meshgrid(sigma_interfaces     (:),time);
   [cen_bounded.z,cen_bounded.x] = meshgrid(sigma_centres_bounded(:),time);
   

%% Initialize also 2D arrays that are staggered in time (x axis)
%  We extrapolate the time array half a timesteps prior to and after the array.

   time2  = center2corner1(time);
   [int.z2       ,int.x2        ] = meshgrid(sigma_interfaces     (:),time2);
   
   % first dimension = lenght time (x)
   % first dimension = lenght vertical coordinates (z)
   
%% Make 2D arrays

   time       = time(:);
   if length(waterlevel)==1
      waterlevel  = repmat(waterlevel,size(time));
   else
      waterlevel  = waterlevel(:);
   end
   if length(bottom)==1
      bottom  = repmat(bottom,size(time));
   else
      bottom  = bottom(:);
   end

   for j=1:length(time(:))
       cen.z        (j,:) = (-bottom(j) + waterlevel(j)) .*cen.z        (j,:) + bottom(j);
       int.z        (j,:) = (-bottom(j) + waterlevel(j)) .*int.z        (j,:) + bottom(j);
       cen_bounded.z(j,:) = (-bottom(j) + waterlevel(j)) .*cen_bounded.z(j,:) + bottom(j);
   end   
   
%% Initialize also 2D arrays that are staggered in time (x axis)
%  We extrapolate the bottom and waterlevel half a timesteps prior to and after the array.

   bottom2      = center2corner1(bottom    );
   waterlevel2  = center2corner1(waterlevel);
   for j=1:length(time2(:))
       int.z2       (j,:) = (-bottom2(j) + waterlevel2(j)) .*int.z2     (j,:) + bottom2(j);
   end   

%% Output

   if nargout==1
      DAT.cen         = cen;
      DAT.int         = int;
      DAT.cen_bounded = cen_bounded;
      varargout = {DAT};
   elseif nargout==2
      varargout = {cen.x,cen.z};
   elseif nargout==4
      varargout = {cen.x,cen.z,int.x,int.z};
   elseif nargout==6
      varargout = {cen.x,cen.z,int.x,int.z,cen_bounded.x,cen_bounded.z};
   end