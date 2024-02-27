function TH = grid_angle(varargin)
%GRID_ANGLE  get local angle (orientation,slope) of all grid nodes
%
%    TH = grid_angle(x,y,<keyword,value>) 
%
% gives cell orientation TH for each grid cell defined as the 
% angle in radians between the m axis (1st dimension, say x-ish) 
% and the n-axis (2nd dimension, say y-ish) of the grid points.
%
% TH is defined in radians (positive anti-clockwise, and 
% zero for regular straight-up cube) [x,y]=meshgrid(0:1,0:1)
%
% TH is calculated as the average angle of the four lines that 
% span a quadrangle around the grid centres (location='cen') or the
% average angle of the 2 lines that cross a node (location='cor').
% So there is no need for the grid(mesh) to be orthogonal.
%
% The following <keyword,value> pairs have been implemented.
% * dim       which dimension to use as (1st dimension, say x-ish)
%             default 1 (appropriate for NDGRID). Setting dim=2 
%             does: x=x', y'y' (i.e. appropriate for MESHGRID)
% * location 'cen<ter>' (default) or 'cor<ner>' determines
%             whether TH is defines at the cell centers  
%             (one smaller in both dimension) or at the coners 
%             (TH same size as x and y)
%
% Works well for grids created with NDGRID, and not with MESH_GRID.
%
% See also: GRID_FUN, NDGRID

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2005 Delft University of Technology
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
% $Id: grid_angle.m 2616 2010-05-26 09:06:00Z geer $
% $Date: 2010-05-26 17:06:00 +0800 (Wed, 26 May 2010) $
% $Author: geer $
% $Revision: 2616 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/grid_fun/grid_angle.m $
% $Keywords: $

%% Input

   cor.x = varargin{1};
   cor.y = varargin{2};
   
   OPT.location  = 'cen';
   OPT.dim       = 1;
   OPT.debug     = 0;
   
   OPT = setproperty(OPT,varargin{3:end});

%% Swap

   if OPT.dim==2
     cor.x = cor.x';
     cor.y = cor.y';
   end
   
%% Calculate

   if strcmpi(OPT.location(1:3),'cen')
   
      %cen.dxdksi                  = (+ cor.x(2:end  ,2:end  ) - cor.x(1:end-1,2:end  ) ...
      %                               + cor.x(2:end  ,1:end-1) - cor.x(1:end-1,1:end-1))./2;
      %
      %cen.dydksi                  = (+ cor.y(2:end  ,2:end  ) - cor.y(1:end-1,2:end  ) ...
      %                               + cor.y(2:end  ,1:end-1) - cor.y(1:end-1,1:end-1))./2;
      %          
      %TH = atan2(cen.dydksi, cen.dxdksi);
      
      TH = repmat(nan,[size(cor.x,1)-1,size(cor.x,2)-1,4]);
      
      % left                                 top     LEFT             bottom  LEFT
      cen.dxdksi                  =  + cor.x(2:end  ,1:end-1) - cor.x(1:end-1,1:end-1);
      cen.dydksi                  =  + cor.y(2:end  ,1:end-1) - cor.y(1:end-1,1:end-1);
      TH(:,:,1) =  atan2(cen.dydksi, cen.dxdksi);
      
      % top                                  TOP     right            TOP     left
      cen.dxdksi                  =  + cor.y(2:end  ,2:end  ) - cor.y(2:end  ,1:end-1);
      cen.dydksi                  =  + cor.x(2:end  ,2:end  ) - cor.x(2:end  ,1:end-1);
      TH(:,:,2) = -atan2(cen.dydksi, cen.dxdksi);
      
      % right                                top     RIGHT            bottom  RIGHT
      cen.dxdksi                  =  + cor.x(2:end  ,2:end  ) - cor.x(1:end-1,2:end  );
      cen.dydksi                  =  + cor.y(2:end  ,2:end  ) - cor.y(1:end-1,2:end  );
      TH(:,:,3) =  atan2(cen.dydksi, cen.dxdksi);
      
      % bottom                               BOTTOM  right            BOTTOM  left
      cen.dxdksi                  =  + cor.y(1:end-1,2:end  ) - cor.y(1:end-1,1:end-1);
      cen.dydksi                  =  + cor.x(1:end-1,2:end  ) - cor.x(1:end-1,1:end-1);
      TH(:,:,4) = -atan2(cen.dydksi, cen.dxdksi);
      
      if OPT.debug
      rad2deg(TH)
      end
      
      TH = mean(TH,3);

   elseif strcmpi(OPT.location(1:3),'cor')
   
      TH = repmat(nan,[size(cor.x,1),size(cor.x,2),2]);

      cor.dxdksi = repmat(nan,size(cor.x));
      cor.dydksi = repmat(nan,size(cor.x));

      % right-left                           right   center           left    center
      cor.dxdksi(2:end-1,2:end-1) = (+ cor.x(3:end  ,2:end-1) - cor.x(1:end-2,2:end-1));
      cor.dydksi(2:end-1,2:end-1) = (+ cor.y(3:end  ,2:end-1) - cor.y(1:end-2,2:end-1));
      TH(:,:,1) =  atan2(cor.dydksi, cor.dxdksi);
      
      % top-bottom                           center  top              center  bottom
      cor.dxdksi(2:end-1,2:end-1) = (+ cor.y(2:end-1,3:end  ) - cor.y(2:end-1,1:end-2));
      cor.dydksi(2:end-1,2:end-1) = (+ cor.x(2:end-1,3:end  ) - cor.x(2:end-1,1:end-2));
      TH(:,:,2) = -atan2(cor.dydksi, cor.dxdksi);

      if OPT.debug
      rad2deg(TH)
      end
      
      TH = mean(TH,3);

   end

%% EOF