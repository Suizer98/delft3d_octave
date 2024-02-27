function varargout = tri_grad(x,y,z,varargin)
%TRI_GRAD   Gradient vector of triangulated mesh.
%
%    f= tri_grad(x,y,z)
%
% returns the exact solution for the 
% gradient vector of the linear plane 
% spanned by the three points (x,y,z)
% where x,y and z have length 3.
%
% f is based on the first three elements
% of the matrices x,y and z.
%
%    f = tri_grad(x,y,z,p) 
%
% can be used to specificy which elements 
% of x,y,z when these have more than three 
% elementsas returned by tri(...).
% By default p = [1 2 3];
%
% (This also automatically sets the order,
%  which is irrelevant for the solution though).
% 
% f = tri_grad(x,y,z) returns an array where the 
% 2nd dimension is the gradient in x and y direction.
%
% [fx,fy] = tri_grad(x,y,z) returns the
% gradient in x and y direction into seprate variables.
%
% See also: TRI_CORNER2CENTER, GRADIENT2, TRIQUAT, QUAT, TRI2QUAT, 
%           TRISURFCORCEN, DELAUNAY.

% G.J. de Boer, thanx to D.A. Ham, Aug. 2005

%%
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

   %% Set order in which triangles are to be used

   if nargin==4
      p = varargin{1};
   else
      p = [1 2 3]; % default
   end
   
   len   = size(p,1);
   
   %                                       
   %    3    _                             
   %     \        -    _                   
   %      \                 -     _        
   %       \                           2   
   %        \                       _      
   %      vector v               _         
   %          \               _            
   %           \           _               
   %            \       _    vector u      
   %             \   _                     
   %              1                        
   %                                       
   %                                       
   
   udx =  x(p(:,2)) - x(p(:,1));
   udy =  y(p(:,2)) - y(p(:,1));
   udz =  z(p(:,2)) - z(p(:,1));
   
   vdx =  x(p(:,3)) - x(p(:,1));
   vdy =  y(p(:,3)) - y(p(:,1));
   vdz =  z(p(:,3)) - z(p(:,1));
   
   dtrmnt = udx .* vdy - udy .* vdx;
   
   f = repmat(nan,[len 2]);
   
   f(:,1) = [  vdy.*udz - udy.*vdz]./dtrmnt;
   f(:,2) = [- vdx.*udz + udx.*vdz]./dtrmnt;
   
   if nargout ==1
      varargout = {f};
   else
      varargout = {f(:,1),f(:,2)};
   end

%% EOF
