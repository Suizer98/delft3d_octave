function varargout = grid_corner2perimeter(varargin)
%GRID_CORNER2PERIMETER   Calculates length of sides of grid cells from corner coordinates.
%            
%                             G.v.ddim2              
%                           ^ GUV
%                           | 
%                           | G.v.ddim1                                     
%                     <---- |-GVV--->                        
%                    o-------+-------o^                     
%                    |      |        ||    
%                    |      |        ||     G.u.ddim1
%                    |      v <----- |----->GVU                
%        G.u.ddim2   +       +       +|    
%        = GUU       |<------------->||    
%                    |     cen.ddim1 ||G.u.ddim2   
%      ^             |               ||GUU                                 
%  dim |             o-------+-------oV                     
%  2   |                   G.v.ddim1                                 
%  v   |                   = GVV                            
%  n   |                                                    
%      |                                                    
%      0-------> dimension 1
%                u m     
%
% where the main field refers to the position, and the 
% second subfield refers to the direction.
%
% [cen.ddim1,cen.ddim2] = grid_corner2perimeter(cor.x,cor.y)
% [cen.ddim1,cen.ddim2,...
%    u.ddim1,  v.ddim2] = grid_corner2perimeter(cor.x,cor.y)
% [cen.ddim1,cen.ddim2,...
%    u.ddim1,  v.ddim2,...
%    v.ddim1,  u.ddim2] = grid_corner2perimeter(cor.x,cor.y)
%
% [.............] = grid_corner2perimeter(cor.x,cor.y)
%
%See also: CORNER2CENTER, CENTER2CORNER, GRID_CORNER2FACE

%   --------------------------------------------------------------------
%   Copyright (C) 2004-2007 Delft University of Technology
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
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   -------------------------------------------------------------------- 

%% INPUT

   if isstruct(varargin{1})
      G       = varargin{1};
   else
      G.cor.x = varargin{1};
      G.cor.y = varargin{2};
   end

%% FACE LENGTHs
   
   % length of face GUU
   G.u.ddim2   = sqrt( diff(G.cor.x,1,2).^2 + ...
                       diff(G.cor.y,1,2).^2 );
   
   % length of face GVV
   G.v.ddim1   = sqrt( diff(G.cor.x,1,1).^2 + ...
                       diff(G.cor.y,1,1).^2 );
   
   G.v.ddim2   = nan.*ones(size(G.v.ddim1  ));
   G.u.ddim1   = nan.*ones(size(G.u.ddim2  ));
   
   % length perpendicular to face, GUV  = GUU at V-velocity point
   G.v.ddim2  (:,2:end-1) = (G.u.ddim2  (1:end-1,1:end-1) +...
                             G.u.ddim2  (2:end  ,1:end-1) +...   
                             G.u.ddim2  (1:end-1,2:end  ) +...   
                             G.u.ddim2  (2:end  ,2:end  ))./4;
   
   % length perpendicular to face, GVU  = GVV at U-velocity point
   G.u.ddim1  (2:end-1,:) = (G.v.ddim1  (1:end-1,1:end-1) +...
                             G.v.ddim1  (2:end  ,1:end-1) +...   
                             G.v.ddim1  (1:end-1,2:end  ) +...   
                             G.v.ddim1  (2:end  ,2:end  ))./4;   
                               
                               
   % length connection middle of faces
   G.cen.ddim1 = (G.v.ddim1(:      ,1:end-1) + G.v.ddim1(:      ,2:end  ))./2;
  
   % length connection middle of faces
   G.cen.ddim2 = (G.u.ddim2(1:end-1,:      ) + G.u.ddim2(2:end  ,:      ))./2;
   
%% OUTPUT 

   if nargout==1
      varargout={G};
   elseif nargout==2
      varargout={G.cen.ddim1,G.cen.ddim2};
   elseif nargout==4
      varargout={G.cen.ddim1,G.cen.ddim2,...
                   G.u.ddim1,  G.v.ddim2};
   elseif nargout==6
      varargout={G.cen.ddim1,G.cen.ddim2...
                   G.u.ddim1,  G.v.ddim2,...
                   G.v.ddim1,  G.u.ddim2};
   end
   
