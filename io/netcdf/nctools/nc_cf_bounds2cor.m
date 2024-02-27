 function C = nc_cf_bounds2cor(B,varargin)
%nc_cf_bounds2cor  rewrite 3D CF bounds matrix to 2D matrix of corners
%
%   cor = nc_cf_bounds2cor(bounds)
%
%   where cor = [m n] if bounds = [m-1 x n-1 x 4]
%
%   It is an error if the cells are not contiguous.
%
%   For documentation of the CF bounds standard see:
%   http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/cf-conventions.html#cell-boundaries
%
%   Note: bounds==nc_cf_bounds2cor(nc_cf_cor2bounds(bounds))
%
%   See also nc_cf_cor2bounds, ncwritetutorial_grid, d3d_qp

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

% $Id: nc_cf_bounds2cor.m 8596 2013-05-08 16:08:39Z boer_g $
% $Date: 2013-05-09 00:08:39 +0800 (Thu, 09 May 2013) $
% $Author: boer_g $
% $Revision: 8596 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/netcdf/nctools/nc_cf_bounds2cor.m $
% $Keywords: $

if length(size(B))==2

      sz = size(B);
      
      if all(sz==2)
         error('[2 x 2] CF bounds matrix undetermined, <dim> not implemented')
      end
      
      dim = find(sz==2);
      
      sz2 = sz+1;
      sz2(dim) = sz(dim)-1;
      
      C = repmat(nan(class(B)),sz2);
      
      if dim==2
      
        if all(isequalwithequalnans(B(2:end  ,1), B(1:end-1,2)))
      
          C(1:end-1) = B( : ,1); 
          C(    end) = B(end,2); 
          
        end
         
      elseif dim==1

        if all(isequalwithequalnans(B(1,2:end  ), B(2,1:end-1)))

          C(:,1:end-1) = B(1, : ); 
          C(:,    end) = B(2,end); 
          
        end
            
      end

else

      sz = size(B);
      C = repmat(nan(class(B)),[sz(1:2)+1]);
      
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
   
   % The bounds can be used to decide whether cells are contiguous via the 
   % following relationships. In these equations the variable bnd is used 
   % generically to represent either the latitude or longitude boundary variable.
   
   %For 0 < j < n and 0 < i < m,
   %	If cells (j,i) and (j,i+1) are contiguous, then
   %		bnd(j,i,1)=bnd(j,i+1,0) 
   %		bnd(j,i,2)=bnd(j,i+1,3)
   %	If cells (j,i) and (j+1,i) are contiguous, then	
   %		bnd(j,i,3)=bnd(j+1,i,0) and bnd(j,i,2)=bnd(j+1,i,1)
   							
   % we assume matlab arrays are not swapped as native netcdf library does
   
        if all(all(isequalwithequalnans(B( :     ,2:end  ,1), B( :     ,1:end-1,2)))) & ...
           all(all(isequalwithequalnans(B(2:end  ,2:end  ,1), B(1:end-1,1:end-1,3)))) & ...
           all(all(isequalwithequalnans(B(2:end  , :     ,1), B(1:end-1, :     ,4))))
   
           C(1:end-1,1:end-1) = B( : , : ,1); 
           C(1:end-1,  end  ) = B( : ,end,2); 
           C(  end  ,  end  ) = B(end,end,3); 
           C(  end  ,1:end-1) = B(end, : ,4); 
        else
            error('bounds cells are NOT contiguous')
        end

end