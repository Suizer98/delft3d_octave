function varargout = grid_corner2face(varargin)
%GRID_CORNER2FACE   get cell face coordinates from cell corner coordinates
%
%   corner2face returns the co-ordinates of the middle of all faces 
%   of a curvilear grid, given the co-ordinates of all corner 
%   points. Can also return co-ordonates of cell-centres:
%
%                                                         
%                 (xcorner,     (xyface,     (xcorner,            
%                  ycorner)      yvface)      ycorner)            
%                          o-------+-------o                      
%                          |               |                      
%                          |               |                      
%                          |    (xcentre,  |                      
%                 (xuface, +       +       + (xuface,             
%                 (yuface) |     ycentre)  | (yuface)             
%         eta              |               |                      
%            ^             |               |                      
%            |             o-------+-------o                      
% n ~ y^     |    (xcorner,     (xyface,     (xcorner,            
%      |     |     ycorner)      yvface)      ycorner)            
%      |     |                                                    
%      |     0-------> ksi
%      |
%      0-------> m ~ x
%
%   Use:
%
%   [xuface , yuface, xvface, yvface]  = corner2face(xcor,ycor,mdimension)
%
%   With mdimension the dimension of the m direction has to be given.
%   For data as read by the vs_* toolbox, m is the second direction, so 
%   mdimension  shouidl be 2.
%
%   If an optional extra argument 1 is added, the face and centre matrices are
%   padded with a row and column of NaNs to have thge same zie as the cornert
%   arrays.
%
%   corner2face can also deal with structs for input and output:
%   GRIDout = corner2face(GRIDin) where GRIDin must have fields 'xcorner'
%   and 'ycorner' and GRIDout has the following fields: 
%
%      GRID.xuface 
%      GRID.yuface 
%      GRID.xvface 
%      GRID.yvface 
%    and all fields of the struct GRIDin, among which are at least
%    xcorner and ycorner of course.
%
% Make sure the first dimension is m, the 2nd is n
%
%See also: CORNER2CENTER, CENTER2CORNER, GRID_CORNER2PERIMETER

%   --------------------------------------------------------------------
%    G.J.deboer@citg.tudelft.nl (gerben.deboer@wldelft.nl)
%    Version 1.0, Nov. 2004
%   --------------------------------------------------------------------
%   Copyright (C) 2004 Delft University of Technology
%       Gerben J. de Boer
%
%       g.j.deboer@citg.tudelft.nl	
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


%% INPUT

   samesize=0;

   if isstruct(varargin{1})
      G           = varargin{1};
      mdimension  = varargin{2};
      if nargin==3
         samesize=varargin{3};
      end
   else
      G.xcorner   = varargin{1};
      G.ycorner   = varargin{2};
      mdimension  = varargin{3};
      if nargin==4
         samesize=varargin{4};
      end
   end
   
%% FACES

   x1face                   = (G.xcorner( :     ,1:end-1)+...
                               G.xcorner( :     ,2:end  ))./2;
   y1face                   = (G.ycorner( :     ,1:end-1)+...
                               G.ycorner( :     ,2:end  ))./2;   

   x2face                   = (G.xcorner(1:end-1, :     )+...
                               G.xcorner(2:end  , :     ))./2;
   y2face                   = (G.ycorner(1:end-1, :     )+...
                               G.ycorner(2:end  , :     ))./2;
                               
if mdimension==1

   xuface = x1face;
   yuface = y1face;
   xvface = x2face;
   yvface = y2face;
   
elseif mdimension==2

   xvface = x1face;
   yvface = y1face;
   xuface = x2face;
   yuface = y2face;

end
                              
%% MAKE ARRAY SAME SIZE AS CORNER ARRAYS

   if samesize
   
      xuface0 = xuface;
      yuface0 = yuface;
      xvface0 = xvface;
      yvface0 = yvface;
      
      xuface = nan.*ones(size(G.xcorner));
      yuface = nan.*ones(size(G.xcorner));
      xvface = nan.*ones(size(G.xcorner));
      yvface = nan.*ones(size(G.xcorner));
      
      % in Delft3D FIRST row/column are dummy
      xuface(:    ,2:end) = xuface0;
      yuface(:    ,2:end) = yuface0;

      xvface(2:end,:    ) = xvface0;
      yvface(2:end,:    ) = yvface0;
      
   end                              
                              

%% OUTPUT 

   if nargout==1
      G.xuface  = xuface ;
      G.yuface  = yuface ;
      G.xvface  = xvface ;
      G.yvface  = yvface ;
      varargout={G};
   elseif nargout==4
      varargout={xuface , yuface, xvface, yvface};
   end
   
