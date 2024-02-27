function varargout = corner2centernan(varargin)
%CORNER2CENTERNAN  interpolate data from grid corners to grid centers
%
%   matrixcentervalues = center2corner(matrixcornervalues)
%
% interpolates a 2D array linearly to obtain center values
% from corner values. The corner array is one bigger on both 
% dimensions. Works for non-equidistant grid spacing too.
% When a 1D array is passed, an error is generated.
%
% grid center values are calculated using MEAN, so CORNER2CENTER 
% gives NaN when only 1 nan-valued data point 
% lies directy adjacent, in contrast to CORNER2CENTER.
%
% See also: CORNER2CENTER, CENTER2CORNER, CENTER2CORNER1, CORNER2CENTER1

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

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id: corner2centernan.m 816 2009-08-13 15:28:45Z boer_g $
% $Date: 2009-08-13 23:28:45 +0800 (Thu, 13 Aug 2009) $
% $Author: boer_g $
% $Revision: 816 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/grid_fun/corner2centernan.m $
% $Keywords: $

for iarg=1:nargin
   cor = varargin{iarg};
   sz  = size(cor);
   if length(sz) > 2
      error('only 1D or 2D arrays')
   elseif min(size(cor))==1
   
      M = repmat(0,[2 max(sz)-1]);
      
      M(1,:,:) = cor(1:end-1);
      M(2,:,:) = cor(2:end  );
      
      cen = nanmean(M);
      
   else
   
      M = repmat(0,[4 sz(1)-1 sz(2)-1]);
      
      M(1,:,:) = cor(1:end-1,1:end-1);
      M(2,:,:) = cor(1:end-1,2:end  );
      M(3,:,:) = cor(2:end  ,1:end-1);
      M(4,:,:) = cor(2:end  ,2:end  );
      
      cen = squeeze(mean(M));
   
   end
   
   varargout{iarg} = cen;

end   

%% EOF