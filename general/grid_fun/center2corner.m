function xcor = center2corner(xcen,varargin)
%CENTER2CORNER  interpolate/extrapolate data from grid centers corners to grid corners
%
%   matrixcornervalues = center2corner(matrixcentervalues)
%
% inter/extrapolates a 2D array linearly to obtain corner values
% from center values. The corner array is one bigger on both 
% dimensions. Works for non-equidistant grid spacing too.
% When a 1D array is passed, an error is generated.
%
% Do note that only for equidistant grid spacing the following holds:
% cor = center2corner(corner2center1(cor))
%
% + center points
% o corner points
%
%      o------o-------o-----------o------o------o
%      |  +   |   +   |    +      |  +   |  +   |  
%      o------o-------o-----------o------o------o
%      |      |       |           |      |      |
%      |  +   |   +   |    +      |  +   |  +   |  
%      |      |       |           |      |      |
%      o------o-------o-----------o------o------o
%      /      |       |           |      |      |
%     /       |       |           |      |      \ 
%    /    +   |   +   |    +      |  +   |  +    | 
%   /         |       |           |      |       \    
%  /          |       |           |      |        |
% o-----------o-------o-----------o-\    |        \
%                                    --  |         |
%                                      \-o---------o
%
% matrixcor = center2corner(matrixcen,'linear' ) % default
% matrixcor = center2corner(matrixcen,'nearest') % optional
%
%See also:  CORNER2CENTER, CORNER2CENTERNAN, CENTER2CORNER1, CORNER2CENTER1

%   --------------------------------------------------------------------
%   Copyright (C) 2005-8 Delft University of Technology
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
% $Id: center2corner.m 7108 2012-08-02 11:37:11Z boer_g $
% $Date: 2012-08-02 19:37:11 +0800 (Thu, 02 Aug 2012) $
% $Author: boer_g $
% $Revision: 7108 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/grid_fun/center2corner.m $
% $Keywords: $

allow1D            = false;
dimensions_of_xcen = fliplr(sort(size(xcen))); % 1st element is biggest

%% Method
   method = 'linear';
   if nargin==2
   method = varargin{1};
   end

%% 1D
if dimensions_of_xcen(2)==1
   
   if ~allow1D
      error('only 2D arrays allowed, use center2corner1 instead for 1D arrays!') 
   else
      xcor = center2corner1(xcen,varargin{:})
   end
     
%% 2D


elseif length(dimensions_of_xcen)==2
 
   %% Initialize with nan

      xcor = nan.*zeros([size(xcen,1)+1,size(xcen,2)+1]);

  %% Give value to those corner points that have 
  %  4 active center points around
  %  and do not change them with internal extrapolations

      xcor(2:end-1,2:end-1) = corner2centernan(xcen);
   
  %% Orthogonal mirroring (only of still empty values)
  
     xcor = mirror_in_1st_dimension(xcen ,xcor ,method) ;
     xcor = mirror_in_1st_dimension(xcen',xcor',method)';

  %% Diagonal mirroring  (only of still empty values)
  
     xcor =        mirror_in_diagonal(       xcen ,       xcor  ,method);
     xcor = fliplr(mirror_in_diagonal(fliplr(xcen),fliplr(xcor) ,method));

%% 3D or more

else

   error('only 2D arrays allowed!') 

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function xcor = mirror_in_1st_dimension(xcen,xcor,method)
     
%MIRROR_IN_1ST_DIMENSION
%
% xcor = mirror_in_1st_dimension(xcen,xcor)
%
% for mirroring in other dimension just transpose
% the in and output arguments.
     
%%% HOW DOES IT WORK:

%  + center points,  input, first dimension, m index
%  x corner points, output, first dimension, m index
%
%  x      x      x      x      x      x      x      x
%     1,1    2,1    3,1    4,1    5,1    6,1    7,1
%      +------+------+------+------+------+------+
%      |ZOOMED|      |      |      |      |      |
%  x   |  IN  |  x   |  x   |  x   |  x   |  x   |  x
%      |BELOW |      |      |      |      |      |
%      +------+------+------+------+------+------+
%      |      |      |      |      |      |      |
%  x   |  x   |  x   |  x   |  x   |  x   |  x   |  x
%      |      |      |      |      |      |      |
%      +------+------+------+------+------+------+
%     1,3    2,3    3,3    4,3    5,3    6,3    7,3
%  x   |  x   |  x   |  x   |  x   |  x   |  x   |  x
%      |      |      |      |      |      |      |
%      +------+------+------+------+------+------+
%     1,4    2,4    3,4    4,4    5,4    6,4    7,4
%  x      x      x      x      x      x      x      x
%  
%

%
% xcor(1,1)            xcor(2,1)            xcor(3,1)
%
%            xcen(1,1)         xcen(2,1)
%                 +------------------+-
%                 |                  | 
%                 |                  | 
%          backward                  | 
%         mirroring                  | 
% xcor(1,2) <-----xs-------xm========xs====> xcor(2,3)
%                 |                  forward
%                 |                  mirroring
%                 |                  | 
%                 |                  | 
%                 +------------------+-
%           xcen(1,2)           xcen(2,2)
%
%
% xcor(1,3)            xcor(1,3)            xcor(3,3)
%
%

% The scheme above is is also valid for all m and n when one substitues m=1 n=1:
%   
%
%        x(1,1) + x(1,2)   x(m,n) + x(m,n+1) 
% x_s = ---------------- = ----------------
%              2		  2
%
%        x(1,1) + x(1,2) + x(2,1) + x(2,2)     x(m,n) + x(m,n+1) + x(m+1,n) + x(m+1,n+1)
% x_m = ----------------------------------- = ----------------------------------- 
%             4				            4		
%
% For mirroring backwards:
%                                                  3*x(1,1) + 3*x(1,2) -  x(2,1) -  x(2,2) 
% xcor(1,2)  = xcor(m  ,n+1) = x_s + (x_s - x_m) = --------------------------------------
%			                                        4				  
%
% For mirroring forwards:
%                                                  -  x(1,1) -  x(1,2) +3*x(2,1) +3*x(2,2) 
% xcor(1,3)  = xcor(m+2,n+1) = x_s + (x_s - x_m) = --------------------------------------
%			                                        4				  
%

% Of course this is only done for grid points that have not yet been calculated.
% so only for points that are nan.

  if strcmpi(method,'linear')

  %% Linear perpendicular to boundary, AND linear along boundary

     for m=1:size(xcen,1)-1
        for n=1:size(xcen,2)-1

           %% mirror back when not yet filled in

           if isnan(xcor(m  ,n+1))
           xcor(m  ,n+1) = (+ 3*xcen(m  ,n  ) ...
                            + 3*xcen(m  ,n+1) ...
                            -   xcen(m+1,n  ) ...
                            -   xcen(m+1,n+1))/4; % is nan when one or more elements are nan
           end
           
           %% mirror forward when not yet filled in
           
           if isnan(xcor(m+2,n+1))
           xcor(m+2,n+1) = (-   xcen(m  ,n  ) ...
                            -   xcen(m  ,n+1) ...
                            + 3*xcen(m+1,n  ) ...
                            + 3*xcen(m+1,n+1))/4; % is nan when one or more elements are nan
           end

        end
     end

  elseif strcmpi(method,'nearest')
  
  %% Nearest perpendicular to boundary, linear along boundary
  
     for m=1:size(xcen,1)-1
        for n=1:size(xcen,2)-1

           %% mirror back when not yet filled in

           if isnan(xcor(m  ,n+1))
           xcor(m  ,n+1) = (+ 1*xcen(m  ,n  ) ...
                            + 1*xcen(m  ,n+1))/2; % is nan when one or more elements are nan
           end
           
           %% mirror forward when not yet filled in
           
           if isnan(xcor(m+2,n+1))
           xcor(m+2,n+1) = (+ 1*xcen(m+1,n  ) ...
                            + 1*xcen(m+1,n+1))/2; % is nan when one or more elements are nan
           end

        end
     end  
  
  else
     error(['Unknown method ',method,', only linear or nearest accepted.'])
  end
     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function xcor = mirror_in_diagonal(xcen,xcor,method)
     
%MIRROR_IN_DIAGONAL
%
% xcor = mirror_in_diagonal(xcen,xcor)
%
% for mirroring in other diagonal just fliplr or flipud
% the in and output arguments.

%%% HOW DOES IT WORK:

%  + center points,  input, first dimension, m index
%  o center points INACTIVE (NaN-valued)
%  x corner points, output, first dimension, m index
%
%  x      x      x      x      x      x      x      x
%     1,1    2,1    3,1    4,1    5,1    6,1    7,1
%      +------+------+------+------+------+......o
%      |      |      |      |      |      |      . 
%  x   |  x   |  x   |  x   |  x   |  x   |   x  .  x        
%      |      |      |      |      |      |      .
%      +------+------+------+------+------+ .. ..o# 
%      |      |      |      |      |      | \    .      with diagonal extrapolation:
%  x   |  x   |  x   |  x   |  x   |  x   |   x. .  x@  prevent this construction by adding zero
%      |      |      |      |      |      |     \. /    times the center values at # and $
%      +------+------+------+------+------+$-----+      so the corner values at @ will also become 
%      |      |      |      |      |      |     /. \    nan, since # is nan.
%  x   |  x   |  x   |  x   |  x   |  x   |   x  .  x@
%      |      |      |      |      |      | /    .   
%      +------+------+------+------+------+......o#    
%  x      x      x      x      x      x      x      x


  if strcmpi(method,'linear')

  %% Linear
  %  --------------------

     for m=1:size(xcen,1)-1
        for n=1:size(xcen,2)-1

           %% mirror back when not yet filled in
           %  -------------------------------------

           if isnan(xcor(m  ,n  ))
           xcor(m  ,n  ) =  + 3*xcen(m  ,n  )/2 ...
                            -   xcen(m+1,n+1)/2 ...
                            + 0*xcen(m+1,n  )   ...
                            + 0*xcen(m  ,n+1)   ; % is nan when one or more elements are nan
           end
           
           %% mirror forward when not yet filled in
           %  -------------------------------------
           
           if isnan(xcor(m+2,n+2))
           xcor(m+2,n+2) =  -   xcen(m  ,n  )/2 ...
                            + 3*xcen(m+1,n+1)/2 ...
                            + 0*xcen(m+1,n  )   ...
                            + 0*xcen(m  ,n+1)   ; % is nan when one or more elements are nan
           end

        end
     end
     
  elseif strcmpi(method,'nearest')
  
  %% Nearest
  %  --------------------
  
     for m=1:size(xcen,1)-1
        for n=1:size(xcen,2)-1

           %% mirror back when not yet filled in
           %  -------------------------------------

           if isnan(xcor(m  ,n  ))
           xcor(m  ,n  ) =  +   xcen(m  ,n  )   ; % is nan when one or more elements are nan
           end
           
           %% mirror forward when not yet filled in
           %  -------------------------------------
           
           if isnan(xcor(m+2,n+2))
           xcor(m+2,n+2) =  +   xcen(m+1,n+1)   ; % is nan when one or more elements are nan
           end

        end
     end  
  
  else
     error(['Unknown method ',method,', only linear or nearest accepted.'])
  end
     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function xcor = mirror_in_1st_dimension1D(xcen,xcor,method)
     
%MIRROR_IN_1ST_DIMENSION
%
% xcor = mirror_in_1st_dimension1D(xcen,xcor)
%
     
% HOW DOES IT WORK:

%  + center points,  input, first dimension, m index
%  x corner points, output, first dimension, m index
%
%     1,1    2,1    3,1    4,1    5,1    6,1    7,1
%  x   +--x---+--x---+--x---+--x---+--x---+--x---+  x
%  


%
%
%            xcen(1,1)         xcen(2,1)
% xcor(1,1)       +----xcor(2,1)-----+-     xcor(3,1)
%          backward                    
%         mirroring                    
%           <-----xs-------xm========xs====>                  
%                                    forward
%                                    mirroring

% The scheme above is is also valid for all m and n when one substitues m=1 n=1:
%   
%
%       
% x_s = xcen
%       
%
%        x(1,1) + x(1,2)     x(m,n)+ x(m+1,n)
% x_m = ----------------- = ------------------
%             2	            2		
%
% For mirroring backwards:
%                                                  3*x(1,1) -  x(2,1)
% xcor(1,2)  = xcor(m  ,n+1) = x_s + (x_s - x_m) = -------------------
%			                                        2
%
% For mirroring forwards:
%                                                  - x(1,1) + 3*x(2,1)
% xcor(1,3)  = xcor(m+2,n+1) = x_s + (x_s - x_m) = --------------------
%			                                        2

% Of course this is only done for grid points that have not yet been calculated.
% so only for points that are nan.

  if strcmpi(method,'linear')

  %% Linear
  %  --------------------

     for m=1:length(xcen)-1

        %% mirror back when not yet filled in
        %  -------------------------------------

        if isnan(xcor(m ))
           xcor(m  ) = (+ 3*xcen(m  ) -   xcen(m+1))/2; % is nan when one or more elements are nan
        end
        
        %% mirror forward when not yet filled in
        %  -------------------------------------
        
        if isnan(xcor(m+2))
           xcor(m+2) = (-   xcen(m  )+ 3*xcen(m+1))/2; % is nan when one or more elements are nan
        end

     end     

  elseif strcmpi(method,'nearest')
  
  %% Nearest
  %  --------------------
  
     for m=1:length(xcen)-1

        %% mirror back when not yet filled in
        %  -------------------------------------

        if isnan(xcor(m ))
           xcor(m  ) = (+ 1*xcen(m  )              )  ; % is nan when one or more elements are nan
        end
        
        %% mirror forward when not yet filled in
        %  -------------------------------------
        
        if isnan(xcor(m+2))
           xcor(m+2) = (             + 1*xcen(m+1))  ; % is nan when one or more elements are nan
        end

     end     

  else
     error(['Unknown method ',method,', only linear or nearest accepted.'])
  end
     
%% EOF     