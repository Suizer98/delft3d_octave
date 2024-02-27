function Area=GetAreaTriangle(x0,y0,x1,y1,x2,y2,varargin)
%GETAREATRIANGLE   calculates areas of array of triangles
%
%  area = GetAreaTriangle(x0,y0,x1,y1,x2,y2) returns area of following triangles:
%
%            (x2,y2)
%           .       .            
%          .          .           
%         .            (x1,y1)
%        .            .                
%       .         .                  
%    (x0,y0)  .
%
%  GetAreaTriangle is vectorized !
%
%  See also: GETAREACURVILINEARGRID, TRIAREA

% Version 1.0, June 2004

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

   method = 1; % DEFAULT
   
   if nargin==7
      method = varargin{1};
   end
   
   if method == 1 % simple

      Area = 0.5*abs((x0-x1).*(y2-y1)-(y0-y1).*(x2-x1));
      
      % Method copied from triarea.m  function of Bert jagers
      
   elseif method==2 

      % This method is always accurate according to its author.
      % However, it DOES NOT WORK in case of the following needle shaped triangle.
      % (x0,y0) = [0   ,0   ];
      % (x1,y1) = [1e4 ,0   ];
      % (x2,y2) = [-1e4,1e-4];
      % The caseu is that thye method requires the face lengths (u,v,w),
      % which I have to calculate first with my own (apparently inaccurate) method.

      u = sqrt((x1 - x0).^2 +  (y1 - y0).^2); % lentgh of side u of tethehedron
      v = sqrt((x2 - x1).^2 +  (y2 - y1).^2); % lentgh of side v of tethehedron
      w = sqrt((x0 - x2).^2 +  (y0 - y2).^2); % lentgh of side w of tethehedron
      
      U_m_V_p_W = (max(u, w) - v) + min(u, w); % (u-v+w)
      V_m_W_p_U = (max(v, u) - w) + min(v, u); % (v-w+u)
      W_m_U_p_V = (max(w, v) - u) + min(w, v); % (w-u+v)
      
      Area      = sqrt((u+v+w) * V_m_W_p_U * W_m_U_p_V * U_m_V_p_W)/4;
                % sqrt(((u+v+w) · (v–w+u)   · (w–u+v)   · (u–v+w))
   
      %   SOURCE METHOD 2
      %   -----------------------------------------------
      %   What has the Volume of a Tetrahedron to do with
      %   Computer Programming Languages?
      %
      %   Prof. W. Kahan
      %   Mathematics Dept., and
      %   Elect. Eng. & Computer Science Dept.
      %   University of California at Berkeley
      %   Prepared for
      %   Prof. B.N. Parlett’s Seminar on Computational Linear Algebra
      %   Wed. 21 March 2001
      %   and Stanford’s Scientific Computing Seminar
      %   Tues. 17 April 2001
      %   
      %   http://www.cs.berkeley.edu/~wkahan/VtetLang.pdf

   end


