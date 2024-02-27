function varargout = tri_corner2center(tri,x,y,varargin)
%TRI_CORNER2CENTER   Calculate coordinates of triangle centers from corner vertices.
%
% [xc,yc   ] = tri_corner2center(tri,x,y)
% [xc,yc,zc] = tri_corner2center(tri,x,y,zc)
%
% Calculates coordinates of triangle centers,
% which are the centers of gravity of the triangle,
% and the origin of the ?outer? circle.
%
% tri is the numt-by-3 pointer table describing 
% which points from the 1D arrays x,y,z are the corner 
% vertices of the numt triangles. xc,yc,zc are 1D arrays
% with length numt.
%
% tri can be obtained with for example DELAUNAY
% for scatter data or with TRIQUAT for curvi-linear data.
%
%See also: TRI_GRAD, TRISURFCORCEN, TRIQUAT, DELAUNAY.

%% [xc,yc   ] = tri_corner2center(tri,x,y,<keyword,value>)
%% where keyword method can be:
%% TO DO: implement different methods:
%% * cog : centre of gravity
%% * oocc: origin of circumcenter
%% * ooic: origin of inner cirlce

%   --------------------------------------------------------------------
%   Copyright (C) 2005-2008 Delft University of Technology
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
%   USA or 
%   http://www.gnu.org/licenses/licenses.html,
%   http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

   %% We average the positions of the corner vertices,
   %% which gives us de facto the center of the 
   %% ?outer? circle.
   
      xc = sum([x(tri(:,1))  x(tri(:,2))  x(tri(:,3))],2)./3;%xc = mean(x(tri),2);
      yc = sum([y(tri(:,1))  y(tri(:,2))  y(tri(:,3))],2)./3;%yc = mean(y(tri),2);

   if nargin ==3 % odd(nargin)

      varargout = {xc,yc};

   elseif nargin ==4 % ~odd(nargin)

      z  = varargin{1};
      zc = sum([z(tri(:,1))  z(tri(:,2))  z(tri(:,3))],2)./3;%zc = mean(z(tri),2);

      varargout = {xc,yc,zc};
      
   else
   
      error('syntax TRI_CORNER2CENTER(tri,x,y) or (tri,x,y,z)')

   end

%% EOF