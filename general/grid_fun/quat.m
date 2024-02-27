function q = quat(x,y,varargin)
%QUAT quadrangulates a mesh into quadrangles.
%
%    q = quat(x,y) quadrangulates a plaid mesh into quadrangles.
%
% Behaviour is similar to DELAUNAY(x,y) that
% can be used to triangulate a mesh into triangles.
% 
% It returns an array of indices into the (x,y) matrices
% where the first dimension walks the quadrangles and 
% the second dimension are the 4 1D indices into the 
% (x,y) matrices. Like the results of DELAUNAY where
% the first dimension walks the traingles and the second 
% dimension contains the 3 1D indices into the (x,y) matrices.
%
% Example:
%                                          
%     Array of corner points measures 3 x 2
%     Array of center points measures 2 x 1
%                                          
%     o-------o    indices when treating 2D array as 1D array: x(:) or y(:)
%     |3      |6   walking 1st Matlab dimension first.
%     |   B   |  
%     |       |       
%     o-------o                   o-------o-------o  
%     |2      |5                  |2      |4      |6 
%     |   A   |                   |   A'  |   B'  |  
%     |       |                   |       |       |  
%     o-------o                   o-------o-------o  ---> 2nd Matlab dimension
%     .1       4                   1       3       5
%
%     x = [0 1;0 1;0 1]         % x' = [0 0 0;1;1;1]
%     y = [0 0;1 1;2 2]	        % y' = [0 1 2;0 1 2]
%     quat(x,y)                   
%                                 quat(x',y')   
%
%   % [1 2 5 4] % Quadrangle A    [1 2 4 3] % Quadrangle A'
%   % [2 3 6 5]	% Quadrangle B	  [3 4 6 5] % Quadrangle B'
%                                                          
%     Note that the number of quadrangles is equal to the number of cell centers.                       
%                                                          
% Note: pointers to quadrangles with a NaN-vertex are removed, 
% yet the pointers q still expect the NaNs to be in (x,y). Use
% [] = quat(x,y,'sub2ind',0) to make sure q indexes into x(~isnan(x))
% rather then into x. itself
%
% see also: TRIQUAT, TRI2QUAT, DELAUNAY, quat2net

%   --------------------------------------------------------------------
%   Copyright (C) 2005 Delft University of Technology
%       Gerben J. de Boer
%
%       g.j.deboer@citg.tudelft.nl	
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

OPT.sub2ind = 1;

OPT = setproperty(OPT,varargin);

szcor1 = size(x,1);
szcor2 = size(x,2);

szcen1 = szcor1-1;
szcen2 = szcor2-1;

q   = repmat(0,[szcen1*szcen2 4]);

mncor  = -1;
mncen  = 0;

if ~(OPT.sub2ind)
   index_nonan = cumsum(~isnan(x(:)));
end

% isnan(x):
%  0  0  0  1
%  0  0  1  0
%  0  1  0  0

% index_nonan:
%  1  2  3==3
%  4  5==5  6
%  7==7  8  9

% indices:
%  1  2  3  4
%  5  6  7  8
%  9 10 11 12

%% first walk along 1st dimension, 
%  while keeping the 2nd dimension constant

for ncen=1:szcen2
    
   for mcen=1:szcen1
   
      mncen = mncen + 1;
      mncor = mncor + 1 + (mcen==1); % at the transition from end of row to begining of row skip 1 corner cell.
      
      indices =    [mncor             , ...
                    mncor + 1         , ...
                    mncor + szcor1 + 1, ...
                    mncor + szcor1    ];
                    
      if ~any(isnan(x(indices)))
      
         if OPT.sub2ind
            q(mncen,:) = indices;
         else
            q(mncen,:) = index_nonan(indices);
         end
                    
      end

   end

end

% remove pointers to quadrangles with a NaN-vertex

   mask = all(q==0,2);
   q(mask,:)=[];

% function polygon_around_square(mncor, szcor1,geometry)
% 
% 
% if strcmp(geometry,'open')
% 
% pol = [mncor             , ...
%        mncor + 1         , ...
%        mncor + szcor1 + 1, ...
%        mncor + szcor1    ];
% 
% elseif strcmp(geometry,'open')
% 
% pol = [mncor             , ...
%        mncor + 1         , ...
%        mncor + szcor1 + 1, ...
%        mncor + szcor1    , ...
%        mncor             ];
% 
% end       