function varargout = poly2contour(varargin)
%POLY2CONTOUR transforms contour array to NaN-delimited polygon vector
%
% [c] = CONTOUR2POLY(x,y,levels) converts a polygon (x,y) to a contourc c vector like this
%
%  c = [level1 x1 x2 x3 ... level2 x2 x2 x3 ...;
%       pairs1 y1 y2 y3 ... pairs2 y2 y2 y3 ...]
%
% from a NaN-delimited polygon vectors like this:
%
%  x = [       x1 x2 x3 ... nan    x2 x2 x3 ...]
%  y = [       x1 x2 x3 ... nan    x2 x2 x3 ...]
%
% or cells arrays for (x,y)as returned by POLYSPLIT.
%
% where level indictes the level for each nan-separated polygon segment.
% Note that level information has to be added that is not in the polygons.
%
% Example that show how to use clabel for a polygon:
%
%    L.h = plot(L.x,L.y);
%    L.c = poly2contour(L.x,L.y,3.141);
%    clabel(L.c,L.h);
%
% See also: CONTOURC, POLYSPLIT, POLYJOIN, CONTOUR2POLY

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
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

      S.x      = varargin{1};
      S.y      = varargin{2};
      S.levels = varargin{3};
      
      %% split polys into cell
      %% -----------------------------------------

      if ~iscell(S.x)
         [S.x,S.y]=polysplit(S.x,S.y);   
      end

      %% pre-allocate for efficient memory (speed)
      %% every [level1 pairs1] becomes a nan
      %% except the first one
      %% -----------------------------------------
      
      %% C = [level1 x1 x2 x3 ... level2 x2 x2 x3 ...;
      %%      pairs1 y1 y2 y3 ... pairs2 y2 y2 y3 ...]
      
      ncontours = length(S.x);
      S.n       = zeros(1, ncontours);
      for ipoly=1:ncontours
         S.n(ipoly) = length(S.x{ipoly});
      end
      length_c  = sum(S.n) + ncontours; % length of data + one 'header' per polygon
      c         = repmat(nan,[2 length_c]);
      
      %% copy array and set delimiets to nan when all positions are known.
      %% -----------------------------------------

      nvertex = 0;
      for ipoly=1:ncontours
         c(1,nvertex+ipoly  )              = S.levels(ipoly);
         c(2,nvertex+ipoly  )              = S.n(ipoly);
         c(1,nvertex+ipoly+[1:S.n(ipoly)]) = S.x{ipoly};
         c(2,nvertex+ipoly+[1:S.n(ipoly)]) = S.y{ipoly};
         nvertex                           = sum(S.n(1:ipoly));
      end
   
      %% Output
      %% -----------------------------------------

      if nargout==1
      
         varargout = {c};

      end
      
%% EOF      
