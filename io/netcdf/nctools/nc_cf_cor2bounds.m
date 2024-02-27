function B = nc_cf_cor2bounds(C,varargin)
%nc_cf_cor2bounds  rewrite vector or matrix of corners to CF bounds matrix
%
%   bounds = nc_cf_cor2bounds(cor)
%
%   where bounds = [m-1 x 2      ] if cor = [m 1] col vectors
%         bounds = [2   x n-1    ] if cor = [1 n] row vectors
%         bounds = [m-1 x n-1 x 4] if cor = [m n] for 2D matrices
%
%   For documentation of the CF bounds standard see:
%   http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/cf-conventions.html#cell-boundaries
%
%   Note: cor==nc_cf_cor2bounds(nc_cf_bounds2cor(cor))
%
%   Note that native Matlab write functions (ncwrite) require
%   dimensions to be swapped, hence:
%
%   bounds = permute(bounds,[2 1])   for 1D cor matrices
%   bounds = permute(bounds,[3 1 2]) for 2D cor matrices
%
%   See also nc_cf_bounds2cor, ncwritetutorial_grid, d3d_qp

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares for Rijkswaterstaat (Resmon projects)
%       Gerben J. de Boer
%
%       gerben.deboer@Deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% $Id: nc_cf_cor2bounds.m 8596 2013-05-08 16:08:39Z boer_g $
% $Date: 2013-05-09 00:08:39 +0800 (Thu, 09 May 2013) $
% $Author: boer_g $
% $Revision: 8596 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/netcdf/nctools/nc_cf_cor2bounds.m $
% $Keywords: $

if isvector(C)

      sz = size(C);
      sz2 = sz;
      sz2(sz >1)=sz(sz >1)-1;
      sz2(sz==1)=2;
      B  = repmat(nan(class(C)),sz2);

      if iscolumn(C)
      B(:,1) = C(1:end-1);
      B(:,2) = C(2:end  );
      else
      B(1,:) = C(1:end-1);
      B(2,:) = C(2:end  );
      end

else

      sz = size(C);
      B = repmat(nan(class(C)),[(sz-1) 4]);
      
   % Bounds for 2-D coordinate variables with 4-sided cells
   % In the case where the horizontal grid is described by two-dimensional 
   % auxiliary coordinate variables in latitude lat(n,m) and longitude 
   % lon(n,m), and the associated cells are four-sided, then the boundary 
   % variables are given in the form latbnd(n,m,4) and lonbnd(n,m,4), where 
   % the trailing index runs over the four vertices of the cells. Let us call
   % the side of cell (j,i) facing cell (j,i-1) the "i-1" side, the side 
   % facing cell (j,i+1) the "i+1" side, and similarly for "j-1" and "j+1". 
   % Then we can refer to the vertex formed by sides i-1 and j-1 as (j-1,i-1).
   % With this notation, the four vertices are indexed as follows: 
   % 0=(j-1,i-1),
   % 1=(j-1,i+1), 
   % 2=(j+1,i+1), 
   % 3=(j+1,i-1).    
   % If i-j-upward is a right-handed coordinate system (like lon-lat-upward), 
   % this ordering means the vertices will be traversed anticlockwise on the 
   % lon-lat surface seen from above. If i-j-upward is left-handed, they will 
   % be traversed clockwise on the lon-lat surface. 
   
   % we assume matlab arrays are not swapped as native netcdf library does
   
      B(:,:,1) = C(1:end-1,1:end-1);
      B(:,:,2) = C(1:end-1,2:end  );
      B(:,:,3) = C(2:end  ,2:end  );
      B(:,:,4) = C(2:end  ,1:end-1);

end