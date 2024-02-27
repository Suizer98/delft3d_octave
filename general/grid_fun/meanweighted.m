function varargout = meanweighted(varargin)
%MEANWEIGHTED   Calculate weighted mean and shear in one matrix dimension.
%
%   xmean         = meanweighted(x,<dim>)
%   xmean         = meanweighted(x, dim,<weights>)
%  [xmean,xshear] = meanweighted(x,<dim>)
%  [xmean,xshear] = meanweighted(x, dim,<weights>)
%
%  where xmean is the mean in the summing dimension, 
%  while xshear is x minus xmean for the specified dimension.
%
%  The working is similar to sum, but with weights vector is 
%  applied in the summing dimension. Works for vectors
%  and multi dimensional matrices.
%
%  The weights are internally normalized, 
%  e.g. weights [1 3] and [.25 .75], so have the same effect.
%
%  See also: MEAN, SUM, CORNER2CENTER1, CONV, D3D_SIGMA

%   --------------------------------------------------------------------
%   Copyright (C) 2006-2011 Delft University of Technology
%       Gerben J. de Boer
%
%       g.j.deboer@tudelft.nl	
%
%       Fluid Mechanics Section
%       Faculty of Civil Engineering and Geosciences, TU Delft
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

%% Handle input

   X               = varargin{1};
   if nargin==1
      dim = min(find(size(X)~=1));
      if isempty(dim), dim = 1; end
   else
      dim          = varargin{2};
      if isempty(dim) & isvector(X)
      dim = min(find(size(X)~=1));
      elseif isempty(dim) & ~isvector(X)
      error(['syntax:',mfilename,'(x,DIM,weights): dimension required for matrices.'])
      end
   end
   
%% Weights

   if nargin>2
      weights  = varargin{3};
   else
      weights  = ones(1,size(X,dim));
   end
   weights  = weights./sum(weights);
   if ~isvector(X)
      if ~(length(weights)==size(X,dim))
         error(['weights vector has different length (',num2str(length(weights)),...
                ') than requested matrix dimension ('   ,num2str(size(X,dim))    ,')'])
      end
   else
      if ~(length(weights)==length(X))
         error(['weights vector has different length (',num2str(length(weights)),...
                ') than vector length ('   ,num2str(size(X,dim))    ,')'])
      end
   end
   
%% Handle vector case

if isvector(X)

   Xmean = sum(X(:).*weights(:));
   
   if nargout==2
   
      X1 = X - Xmean;
   
   end

else

%% Handle matrix case

   % swap requested dimension into dim 1
   
      var.size      = size(X);
      var.dim       = 1:length(var.size);
   
      var1.dim      = var.dim;
      var1.dim(dim) = 1; 
      var1.dim(1)   = dim; 
      var1.size     = var.size(var1.dim);
      
      avg.size      = var.size;
      avg.dim       = var.dim;
      avg.size(dim) = 1;

      avg1.dim      = avg.dim;
      avg1.dim(dim) = 1; 
      avg1.dim(1)   = dim; 
      avg1.size     = avg.size(avg1.dim);

      X             = permute(X,var1.dim);
      X1            = repmat(nan,size(X));
   
   % now apply weights in this dim 1 (now requested one)
   
      for i=1:size(X,1)
      
         X1(i,:) = X(i,:).*weights(i);
      
      end
      
      Xmean = sum(X1,1);
      
   % calculate shear if requested
   
      if nargout==2
      
        sz = size(X);

        for j=1:prod(sz(2:end))
        
          X1(:,j) = X(:,j) - Xmean(j);
      
        end
      
      end
      
   % no reshape/swap result back into input dimension order
   
      Xmean = reshape(Xmean,avg1.size);
      Xmean = permute(Xmean,avg1.dim);
      
      if nargout==2
      
      X1 = reshape(X1,var1.size);
      X1 = permute(X1,var1.dim);
      
      end

end      
   
%% Handle output
   
if     nargout<2
   varargout = {Xmean};
elseif nargout==2

   varargout = {Xmean,X1};
end
