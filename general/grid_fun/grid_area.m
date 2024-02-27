function AreaAB = grid_area(Xcorner,Ycorner,varargin)
%GRID_AREA   calculate area matrix from (x,y) coordinate matrices
%
%   area = grid_area(xcorner,ycorner) returns the areas 
%
% of the cells with corner points at (xcorner,tcorner) attributed 
% to the cell centres, E.g.:
%
%     + center points (5 x 3 matrix)
%     o corner points (6 x 4 matrix)
%
%     o------o-------o-----------o------o--------o
%     |  +   |   +    \   +      |  +   |  +    / 
%     o------o---------o---------o------o------o
%     |      |         |         |      |      |
%     |  +   |   +    /   +      |  +   |  +   |  
%     |      |       |           |      |      |
%     o------o-------o-----------o------o------o
%    /       |       |           /      \       \    
%   /   +    |   +   |    +     /        \        \   
%  /         |       |         /     +    \   +     \  
% o----------o__     |       o---____      \          \ 
%               --__ |   __--       ---___  \           \
%                   --o--                 ---o-----------o
%
% area = GRID_AREA(XXcorner,Ycorner,<keyword,value>)
% where valid ,<keyword,value> pairs are:
%
% * 'convex': 0,1 (default 0)
%
%   For non-convex quadrangles two calculations have to be performed,
%   otherwise the areas are too large. To skip this action when you are
%   already sure your quadrangles are convex (to save CPU for large matrices)
%   use 'convex' = 1 (default 0).
%
% Tip: The calculate volumes, multiply the area matrix with the depth matrix 
% defined at the centers points (xcenter, ycenter) as well, which is also 
% smaller than the corner matrices.
%
% Note: that this area is not the same as the area that is used in Delft3D
% where the area is incorrectly calculated as (mean_dx x mean_dy) per cell.
%
% See also: CENTER2CORNER, CORNER2CENTER, GETAREATRIANGLE, VS_AREA

% Version 1.0, June 2004, added better comments May 2006.
% 2008, Jun removed samesize option, as dummy rows/cols are a moronic idea.

%   --------------------------------------------------------------------
%   Copyright (C) 2004 Delft University of Technology
%       Gerben J. de Boer
%
%       g.j.deboer@tudelft.nl (gerben.deboer@wldelft.nl)
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

   %% Options
   %% ------------------

   OPTIONS.convex   = 0;
   OPTIONS.samesize = 0;

   i=1;
   while i<=nargin-2,
     if ischar(varargin{i}),
       switch lower(varargin{i})
       case 'convex'    ;i=i+1;OPTIONS.convex   = varargin{i};
       case 'samesize'  ;i=i+1;OPTIONS.samesize = varargin{i};
       otherwise
          error(sprintf('Invalid string argument: %s.',varargin{i}));
       end
     end;
     i=i+1;
   end;

   %% Calculations
   %% ------------------

      % o---------o
      % | B     / | 
      % |    /    |
      % | /     A |
      % o---------o
      
      AreaA(:,:) = GetAreaTriangle(Xcorner(1:end-1,1:end-1),Ycorner(1:end-1,1:end-1),...
                                   Xcorner(2:end  ,1:end-1),Ycorner(2:end  ,1:end-1),...
                                   Xcorner(2:end  ,2:end  ),Ycorner(2:end  ,2:end  ));
      
      AreaB(:,:) = GetAreaTriangle(Xcorner(1:end-1,1:end-1),Ycorner(1:end-1,1:end-1),...
                                   Xcorner(1:end-1,2:end  ),Ycorner(1:end-1,2:end  ),...
                                   Xcorner(2:end  ,2:end  ),Ycorner(2:end  ,2:end  ));
                      
      AreaAB(:,:)  = AreaA + AreaB;  
      
   
   if ~OPTIONS.convex
   
                                
      %            od           Only traingulation 1 gives the correct
      %           /.\           area, with triangulation 2 the area abc  
      %          / . \          is added twice erronously! So we take the 
      %         /  .  \         MINIMUM of the 2 possible triangulations.
      %        /   1   \           
      %       /    .    \          
      %      /     .     \         
      %     /     _ob_    \        
      %    /  _ /     \ _  \       
      %  ao_/......2......\_oc     
   
      % o---------o
      % | \    B  | 
      % |    \    |
      % | A     \ |
      % o---------o
      
      AreaA2(:,:) = GetAreaTriangle(Xcorner(1:end-1,1:end-1),Ycorner(1:end-1,1:end-1),...
                                    Xcorner(2:end  ,1:end-1),Ycorner(2:end  ,1:end-1),...
                                    Xcorner(1:end-1,2:end  ),Ycorner(1:end-1,2:end  ));
       
      AreaB2(:,:) = GetAreaTriangle(Xcorner(2:end  ,1:end-1),Ycorner(2:end  ,1:end-1),...
                                    Xcorner(1:end-1,2:end  ),Ycorner(1:end-1,2:end  ),...
                                    Xcorner(2:end  ,2:end  ),Ycorner(2:end  ,2:end  ));
                       
      AreaAB2(:,:)  = AreaA2 + AreaB2;  
      
      AreaAB = min(AreaAB,AreaAB2);
   
   end   
   
%% EOF   