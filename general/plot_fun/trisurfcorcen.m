function varargout = trisurfcorcen(tri,x,y,varargin);
%TRISURFCORCEN   wrapper to fix TRISURF ambiguities
%
%    p = trisurfcorcen(tri,x,y,z,c);
%
% always plots triangle correclty w.r.t height and color.
%
% z and c can be defined at either the centers of the 
% triangle leading to 'shading interp' look, or 
% or the corners (vertices) of the triangle leading to
% 'shading flat' look.
%
% - z at corners: surface is continuous (bilinear)
% - z at centers: surface is stepwise (stairs)
% 
% - c at corners: shading interp (continous, smooth look)
% - c at centers: shading flat   (stepwise, stairs look)
%
% If z or c is a constant, it is assumed to be at the vertices.
%
% There are 2 3D, affecting only colors:
%
%    p = trisurfcorcen(tri,xcor,ycor,zcor,ccor); % shading interp, default of trisurf
%    p = trisurfcorcen(tri,xcor,ycor,zcor,cCEN); % shading flat
%
% There are also two 2D options for which z is set 
% to zero !unlike! TRISURF which sets c = z always.
% This is in fact the pcolor-counterpart for triangles.
%
%    p = trisurfcorcen(tri,xcor,ycor,zcor);
%    p = trisurfcorcen(tri,xcor,ycor,zCEN);
%
% An approximation of c/zdata at the center (face)
% can be obtained with TRI_CORNER2CENTER or:
%
%    tri.z     = mean(z(tri.p),2);
%
% Note that another way to plot center data is using 
% a VORONOI mesh, that allows center data to be 
% plotted as continous shades, rather then shading flat
% as TRISURFCORCEN does.
% 
% See also: SURFCORCEN, PCOLORCORCEN, PCOLOR, SURF, PATCH, 
%           CORNER2CENTER, TRI_CORNER2CENTER


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

if nargin     == 4
   % 2D plot (flat z)
   c = varargin{1};
   z = 0;
elseif nargin == 5
   % 3D plot
   z = varargin{1};
   c = varargin{2};
end   

%% z is constant
%  Surface is flat.

   if isscalar(z)
   
      if equalsize(size(x),size(c))
         
         %  same as trisurf 
         %  z at corners constant (no jumps at edges)
         %  c at corners (shading interp)
         
         p = trisurf(tri,x,y,repmat(z,size(x)),c); 
         set(p,'FaceColor','interp');
         
      else % c
      
         %  same as trisurf 
         %  z at corners constant (no jumps at edges)
         %  c at centers (shading flat)
      
         p = trisurf(tri,x,y,repmat(z,size(x)),c);
         set(p,'FaceColor','flat'); % same as default

      end % c

%% z at corners
%  Surface is continuous (linear).

   elseif equalsize(size(x),size(z))

      if equalsize(size(x),size(c))
      
         %  same as trisurf 
         %  z at corners (no jumps at edges)
         %  c at corners (shading interp)
      
         p = trisurf(tri,x,y,z,c);  % same trisurf(...)
         set(p,'FaceColor','interp');

      else % c
      
         %  same as trisurf 
         %  z at corners (no jumps at edges)
         %  c at centers (shading flat)
      
         % x = x(tri)';
         % y = y(tri)';
         % z = z(tri)';
         % c = repmat(c,[1 3])';
         % p = fill3(x,y,z,c);  % new mode for 2D for c only
         p = trisurf(tri,x,y,z,c); %                        
         set(p,'FaceColor','flat'); % same as default

      end % c

   else % z
   
%% z at centers
%  surface discontinuous (piecewise constant)
%  Make c,z column vectors for replication

      x = x(tri)';
      y = y(tri)';
      if equalsize(size(z),size(c))
      
         
         %  z at centers (do jumps at edges)
         %  c at centers (shading flat)
      
         z = repmat(z(:),[1 3])';
         c = repmat(c(:),[1 3])';
         p = fill3(x,y,z,c);  % new mode for 2D for both z and c
         
      else

         %  z at centers (do jumps at edges)
         %  c at corners (shading interp)

         z = repmat(z(:),[1 3])';
         c = c(:);
         c = c(tri)';
         p = fill3(x,y,z,c);  % new mode for 2D for both z and c
         
      end % c
      
   end % z

data_aspectratio    = daspect;
data_aspectratio(1) = data_aspectratio(2);
daspect(data_aspectratio)

if nargout==1
   varargout = {p};
end

function ok = equalsize(size1,size2)
% equalsize
%
% ok = equalsize(size1,size2)
% is one when all elements of all dimensions 
% of two (size) vectors match.
% Is zero when dimensions do not match or
% dimension sizes do not match.
%
% E.g. :
% x=rand(10); y=rand(10);
% equalsize(size(x),size(y))
%
% ans =
% 
%      1
%
% G.J. de Boer, Aug. 2005

if length(size1)==length(size2)
   ok = prod(double(size1==size2));
else
   ok = 0;
end

%% EOF

