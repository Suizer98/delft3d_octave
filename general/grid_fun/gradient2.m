function varargout = gradient2(varargin)
%GRADIENT2   first order spatial gradient in global co-ordinates in curvi-linear grid
%
%      gradient2(x,y,z) 
%
%   calculates gradient dz/dx and dz/dy (in global co-ordinates)
%   for data on curvilinear grid (x,y) (unlike GRADIENT, wich only
%   calculates gradients in orthogonal matrix-space).
%
%    out    = GRADIENT2(...) returns a struct with fields fx and fy
%   [fx,fy] = GRADIENT2(...) returns 2 matrices with vector components (fx,fy)
%
%   Note that by default fx and fy are given at the centers of the grid (x,y)
%   The size of fx and fy is therefore 1 element smaller in both
%   matrix directions. With the default GRADIENT2 there are no border
%   effects: the total area covered with data is reduced with 
%   0.5 grid cell at every boundary (also internal holes where you have NaN's).
%   Optionally a central scheme can be chosen as used in GRADIENT. 
%   In this case the gradients are defined at the data points, with the
%   border containing gradients filled in with NaN (no confusing lower 
%   order approximations at all). 
%
%   out    = GRADIENT2(x,y,z,<'keyword',value>) where the following options 
%   are implemented:
%
%  * 'average': GRADIENT2(x,y,z,'average',value) with value 'min','max','mean' or 'rand'.
%
%      The input grid is triangulated. For each triangle the 
%      gradient is determined by fitting a plane through the 3 corner
%      points, by solving the exact equations of a plane. Thus, every quadrangle
%      contains 2 triangles. By default the gradient values in these 2 triangles
%      are averaged to get the gradient of the quadrangles. An extra (optional) 
%      argument can be provided to choose between 'min', 'max, and 'mean'. This 
%      can be used for example to check the accuracy for example. Note that the 
%      direction of the gradient might be a bit off when triangulation is 
%      performed oddly.
%
%  * 'discretisation': GRADIENT2(x,y,z,'discretisation',value) with 
%     value 'upwind', or 'central' or 'fast'. 
%
%      By default an upwind gradient method is used, where the results is 
%      staggered with respect to the input co-ordinates (x,y).
%      An alternative central differentiation method is also available.
%      In this method the gradients are defined at the same location as 
%      the input co-ordinates (x,y). The 'upwind' method is vectorized, 
%      the 'central' method not yet. For the borders no lower order discretisation
%      is used, but simply NaN are returned.
%
%      'discretisation' = 'fast' does technicaly not allow for an 'average' option (YET).
%                                                                            
%      |       |       |       |           |       |       |       |         
%      +   x   +   x   +   x   +   x       +   x   +   x   +   x   +   x     
%      |       |       |       |           |       |       |       |         
%      o---+---o---+---o---+---o---+-      o---+--2o3--+---o---+---o---+-    
%      |       |       |       |           |       |       |       |         
%      +   x   +   x   +   x   +   x       +   x   +   x   +   x   +   x     
%      |       |       |       |           |       |       |       |         
%     1o2--+--2o2--+---o---+---o---+-     1o2--+--2o2--+--3o2--+---o---+-    
%      |       |       |       |           |       |       |       |         
%      +  axa  +   x   +   x   +   x       +   x   +   x   +   x   +   x     
%      |       |       |       |           |       |       |       |         
%     1o1--+--2o1--+---o---+---o---+-      o---+--2o1--+---o---+---o---+-    
%                                                                            
%      discretisation: 'upwind'            discretisation: 'central'         
%                                                                            
%      the corner values at                the corner values at
%      (1,1), (1,2), (2,1), (2,2)          (2,1), (1,2), (2,3), (3,2)
%      are used to get a gradient at       are used to get a gradient at
%      CERNTER points (a,a)                CORNER points (2,2), corner points
%                                          at the boundary like (1,1), (2,1),(1,2)
% o: input corner data point               will get no gradient data but NaN.
% x: center point
%
%   See also: GRADIENT, QUAT, TRIQUAT, TRI2QUAT, TRI_GRAD, PCOLORCORCEN

% GRADIENT2 calls:
% - triquat
% - tri_grad
% - samesize

%%
%   --------------------------------------------------------------------
%   Copyright (C) 2005-2007 Delft University of Technology
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

%% In

   x   = squeeze(varargin{1});
   y   = squeeze(varargin{2});
   z   = squeeze(varargin{3});
   
   sx = size(x);
   sy = size(y);
   sz = size(z);
   
   if ~isequal(sx,sy)
      error('x and y do not have same size')
   end
   
   if ~isequal(sx,sz(1:2))
      error('x and z(1:2) do not have same size')
   end
   
   szcor  = size(x);
   
   sz1cor = size(x,1);
   sz2cor = size(x,2);
   
   sz1cen = sz1cor - 1;
   sz2cen = sz2cor - 1;
   
%% Keywords

   OPT.discretisation = 'upwind';
   OPT.average        = 'mean';

   OPT = setproperty(OPT,varargin{4:end});

   if strcmp(OPT.discretisation,'upwind')

%% Triangulate curvi-linear grid
%  and calculate gradients in all separate triangles.
      
      map     = triquat(x,y,'active',0); % we want to put data back into the full matrix, so we also want holes back here: 'active',0
         
%% replaces below 3 calls becuase it's faster, 
%  becuase we know the structure of the data,
%  while delaunay considers the co-ordinates 
%  randomly distributed.
         
      % map.quat = quat(x,y);
      % tri      = delaunay(x,y);
      % map      = tri2quat(tri,quat);
      
%% Calculate gradient per triangle

      fx =  zeros([sz1cen,sz2cen,size(z,3)]);
      fy =  zeros([sz1cen,sz2cen,size(z,3)]);
      
      for k=1:size(z,3)
         
         [tri.fx,tri.fy] = tri_grad(x,y,z(:,:,k),map.tri);
         
%% Map value at centres of trangles to centers
%  of quadrangles using mapper provided by triquat.
      
      % 1ST traingle per quadrangle : tri_per_quat(:,1)
      % 2ND traingle per quadrangle : tri_per_quat(:,2)
      
         if     strcmp(OPT.average,'min')
            fx(:,:,k) = reshape(min( tri.fx(map.tri_per_quat(:,1)),...
                                     tri.fx(map.tri_per_quat(:,2))),[sz1cen,sz2cen]);
            fy(:,:,k) = reshape(min( tri.fy(map.tri_per_quat(:,1)),...
                                     tri.fy(map.tri_per_quat(:,2))),[sz1cen,sz2cen]);
         elseif strcmp(OPT.average,'mean')
            fx(:,:,k) = reshape(    (tri.fx(map.tri_per_quat(:,1))+...
                                     tri.fx(map.tri_per_quat(:,2)))./2,[sz1cen,sz2cen]);
            fy(:,:,k) = reshape(    (tri.fy(map.tri_per_quat(:,1))+...
                                     tri.fy(map.tri_per_quat(:,2)))./2,[sz1cen,sz2cen]);
         elseif strcmp(OPT.average,'max')
            fx(:,:,k) = reshape(max( tri.fx(map.tri_per_quat(:,1)),...
                                     tri.fx(map.tri_per_quat(:,2))),[sz1cen,sz2cen]);
            fy(:,:,k) = reshape(max( tri.fy(map.tri_per_quat(:,1)),...
                                     tri.fy(map.tri_per_quat(:,2))),[sz1cen,sz2cen]);
         elseif strcmp(OPT.average,'rand')
            fx(:,:,k) = reshape(     tri.fx(map.tri_per_quat(:,1)),[sz1cen,sz2cen]);
            fy(:,:,k) = reshape(     tri.fy(map.tri_per_quat(:,1)),[sz1cen,sz2cen]);
         else
            error(['gradient2: averaging method unknown: either ''min'', ''max'', ''mean'' or ''rand'', not: ''',OPT.average,''''])
         end
         
      end % k
   
   elseif strcmp(OPT.discretisation,'central')
   
         fx  =  nan.*zeros([szcor size(z,3)]);
         fy  =  nan.*zeros([szcor size(z,3)]);   
         fxA =  nan.*zeros( szcor);
         fyA =  nan.*zeros( szcor);   
         fxB =  nan.*zeros( szcor);
         fyB =  nan.*zeros( szcor);   
         
%% Calculations

%     |       |       |       |         
%     +   x   +   x   +   x   +   x     
%     |      B|3      |       |         
%     o---+---o---+---o---+---o---+-    
%     |     /:|:\     |       |         
%     +   /:::+:::\   +   x   +   x     
%     | /:::B:|:B:::\ |       |         
% AB1 o---+---o---+---oAB2+---o---+-    
%     | \%%%A%|%A%%%/ |       |         
%     +   \%%%+%%%/   +   x   +   x     
%     |     \%|%/     |       |         
%     o---+---o---+---o---+---o---+-    
%            A3

%% Looped approach

   n_triangles = 1; % one triangle per time in a looped manner
   
%% tri indices into corner (x,y) matrices.

   triA     = zeros(n_triangles,3);
   triB     = zeros(n_triangles,3);
  
     for k=1:size(z,3)
       for ind1=2:szcor(1)-1
       for ind2=2:szcor(2)-1

          triA(:,1) = sub2ind(szcor,ind1-1,ind2  ); % 1st corner point AB1
          triA(:,2) = sub2ind(szcor,ind1+1,ind2  ); % 2nd corner point AB2
          triA(:,3) = sub2ind(szcor,ind1  ,ind2-1); % 3rd corner point A 3
          
          triB(:,1) = sub2ind(szcor,ind1-1,ind2  ); % 1st corner point AB1
          triB(:,2) = sub2ind(szcor,ind1+1,ind2  ); % 2nd corner point AB2
          triB(:,3) = sub2ind(szcor,ind1  ,ind2+1); % 3rd corner point  B3
          
          [fxA(ind1,ind2),...
           fyA(ind1,ind2)] = tri_grad(x,y,z(:,:,k),triA);
          
          [fxB(ind1,ind2),...
           fyB(ind1,ind2)] = tri_grad(x,y,z(:,:,k),triB);
       
       end
       end
   
%% Vectorized attempt
  
  %   %% all inpout excpet outer rows and columns
  %   n_triangles = (szcor(1)-2)*(szcor(2)-2)
  %   
  %   %% tri indices into corner (x,y) matrices
  %   triA     = zeros(n_triangles,3)
  %   triB     = zeros(n_triangles,3)
  %   
  %   [sub1,sub2]=meshgrid(1:szcor(1)-2,2:szcor(2)-1);
  %   [sub1,sub2]=meshgrid(3:szcor(1)  ,2:szcor(2)-1);
  %   [sub1,sub2]=meshgrid(2:szcor(1)-1,1:szcor(2)-2);
  %   
  %   triA(:,1) = sub2ind(szcor,1:szcor(1)-2,2:szcor(2)-1); % 1st corner point AB1
  %   triA(:,2) = sub2ind(szcor,3:szcor(1)  ,2:szcor(2)-1); % 2nd corner point AB2
  %   triA(:,3) = sub2ind(szcor,2:szcor(1)-1,1:szcor(2)-2); % 3rd corner point A 3
  %   
  %   triB(:,1) = sub2ind(szcor,1:szcor(1)-2,2:szcor(2)-1); % 1st corner point AB1
  %   triB(:,2) = sub2ind(szcor,3:szcor(1)  ,2:szcor(2)-1); % 2nd corner point AB2
  %   triB(:,3) = sub2ind(szcor,2:szcor(1)-1,3:szcor(2)  ); % 3rd corner point  B3
  %   
  %   [fxA(2:end-1,2:end-1),...
  %    fyA(2:end-1,2:end-1)] = tri_grad(x,y,z,triA);
  %    
  %   [fxB(2:end-1,2:end-1),...
  %    fyB(2:end-1,2:end-1)] = tri_grad(x,y,z,triB);
  %                    

%% Average

       if     strcmp(OPT.average,'min')
          fx(:,:,k)  = min(fxA, fxB);  
          fy(:,:,k)  = min(fyA, fyB);  
       elseif strcmp(OPT.average,'mean')
          fx(:,:,k)  = (fxA + fxB)./2;  
          fy(:,:,k)  = (fyA + fyB)./2;  
       elseif strcmp(OPT.average,'max')
          fx(:,:,k)  = max(fxA, fxB);  
          fy(:,:,k)  = max(fyA, fyB);  
       else
          error(['gradient2: averaging method unknown: either ''min'', ''max'' or ''mean'', not: ''',OPT.average,''''])
       end
     end % k
   
   elseif strcmp(OPT.discretisation,'fast')

       fx  = repmat(nan,[szcor size(z,3)]);
       fy  = repmat(nan,[szcor size(z,3)]);   
       dx  = repmat(nan,size(x));
       dy  = repmat(nan,size(x));
       dm  = repmat(nan,size(x));
       dn  = repmat(nan,size(x));
       ang = repmat(nan,size(x));
       dzm = repmat(nan,size(x));
       dzn = repmat(nan,size(x));

       dx  = x(:,3:end) -  x(:,1:end-2);
       dy  = y(:,3:end) -  y(:,1:end-2);
       dm  = sqrt(dx.^2 + dy.^2);

       ang(2:end-1,2:end-1) = atan2(dy(2:end-1,:),dx(2:end-1,:)); % can also take angle in other direction, average keyword not applicable.

       dx  = x(3:end,:) -  x(1:end-2,:);
       dy  = y(3:end,:) -  y(1:end-2,:);
       dn  = sqrt(dx.^2 + dy.^2);
       
       % TO DO take gradient with two different ang sets, and then calculate 
       % min, mean and max.

      %ang(2:end-1,2:end-1) = atan2(dy(:,2:end-1),dx(:,2:end-1)); % can also take angle in other direction, average keyword not applicable.

       for k = 1:size(z,3)
       
          dzm(:,2:end-1) = (z( :     ,3:end  ,k) - ...
                            z( :     ,1:end-2,k))./dm;
          dzn(2:end-1,:) = (z(3:end  , :     ,k) - ...
                            z(1:end-2, :     ,k))./dn;
          fx(:,:,k)     =  dzm.*cos(ang) - ...
                           dzn.*sin(ang);
          fy(:,:,k)     =  dzm.*sin(ang) + ...
                           dzn.*cos(ang);
       end

   else
   
      error(['gradient2: discretisation method unknown: either ''upwind'' or ''central'', not: ''',OPT.discretisation,''''])

   end


%% Out

if nargout<2
   out.fx    = fx;
   out.fy    = fy;
   varargout = {out};
elseif nargout==2
   varargout = {fx,fy};
end

%% EOF