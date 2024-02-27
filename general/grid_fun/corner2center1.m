function xcen = corner2center1(xcor,dim);
%CORNER2CENTER1  calculates centers in between vector of corner points.
%
%   xcen = corner2center1(xcor) 
%
%   Interpolates a 1D vector linearly to obtain center values
%   from corner values. The center array is one element smaller.
%   Works for non-equidistant grid spacing too.
%
%   Do note that only for equidistant grid spacing the following holds:
%   xcor = center2corner1(corner2center1(xcor))
%
%   corner points:   o---o-----o--------o------------o---o-o 
%   center points:     +----+------+----------+--------+--+  
%
%   xcen = corner2center1(xcor,<dim>)
%
%   Interpolates matrix linearly in one dimension only,
%   to obtain center values in that dimension.
%
%   See also: CORNER2CENTER, CENTER2CORNER, CENTER2CORNER1, CONV

%   --------------------------------------------------------------------
%   Copyright (C) 2006-2011 Delft University of Technology
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

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id: corner2center1.m 5374 2011-10-28 12:54:54Z boer_g $
% $Date: 2011-10-28 20:54:54 +0800 (Fri, 28 Oct 2011) $
% $Author: boer_g $
% $Revision: 5374 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/grid_fun/corner2center1.m $
% $Keywords: $

%% 1D vectors

if isvector(xcor)
   
   %% Initialize with nan

     %xcen = nan(1:length(xcor)-1);% not in R6
      xcen = nan.*zeros(length(xcor)-1,1);

   %% Give value to those corner points that have 
   %  4 active center points around
   %  and do not change them with 'internal extrapolations'

      xcen = (xcor(1:end-1) + xcor(2:end))./2;
     
%% 2D or more matrices

else

   if ~(nargin==2)
      error('for matrices you need to specify a dimension')
   end

% swap requested dimension into dim 1

   cor.size      = size(xcor);
   cor.dim       = 1:length(cor.size);

   cor1.dim      = cor.dim;
   cor1.dim(dim) = 1; 
   cor1.dim(1)   = dim; 
   cor1.size     = cor.size(cor1.dim);
   xcor          = permute(xcor,cor1.dim);

% now apply corner2center in this dim 1 (now requested one)

   cen.size     = cor.size;
   cen.size(cor.dim==dim) = cen.size(cor.dim==dim)-1;
   cen.dim      = cor.dim;
   cen1.size    = cor1.size;
   cen1.size(1) = cen1.size(1)-1;
   cen1.dim     = cor1.dim;
   xcen = (xcor(1:end-1,:) + xcor(2:end,:))./2;

% no reshape/swap result back into input dimension order

   xcen = reshape(xcen,cen1.size);
   xcen = permute(xcen,cen1.dim);

end
