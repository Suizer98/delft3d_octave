function xcor = center2corner1(xcen,varargin)
%CENTER2CORNER1  calculates corners enclosing a vector of center points.
%
%   xcor = center2corner1(xcen)
%
%   Inter and extrapolates a 1D vector linearly to obtain corner values
%   from center values. The corner array is one element bigger.
%   Works for non-equidistant grid spacing.
%
%   Do note that only for equidistant grid spacing the following holds:
%   xcor = center2corner1(corner2center1(xcor))
%
%   xcor = center2corner1(xcen,'linear' ) % default
%
%   corner points:   o---o-----o--------o------------o---o-o 
%   center points:     +----+------+----------+--------+--+  
%
%   xcor = center2corner1(xcen,'nearest') % optional
%
%   corner points:     o-o-----o--------o------------o---oo  
%   center points:     +----+------+----------+--------+--+  
%
%   See also: CENTER2CORNER, CORNER2CENTER, CORNER2CENTER1

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
% $Id: center2corner1.m 7108 2012-08-02 11:37:11Z boer_g $
% $Date: 2012-08-02 19:37:11 +0800 (Thu, 02 Aug 2012) $
% $Author: boer_g $
% $Revision: 7108 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/grid_fun/center2corner1.m $
% $Keywords: $

dimensions_of_xcen = fliplr(sort(size(xcen))); % 1st element is biggest

%% Method
   method = 'linear';
   if nargin==2
   method = varargin{1};
   end

%% 1D

if dimensions_of_xcen(2)==1
   
   %% Initialize with nan

      xcor = nan.*zeros([1 length(xcen)+1]);

   %% Give value to those corner points that have 
   %  4 active center points around
   %  and do not change them with 'internal extrapolations

      xcor(2:end-1) = (xcen(1:end-1) + xcen(2:end))./2;

   %% Orthogonal mirroring (only of still empty values)
  
      xcor = mirror_in_1st_dimension1D(xcen ,xcor ,method);
     
%% 2D or more

else

   error('only 1D arrays allowed, use center2corner instead') 

end
     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function xcor = mirror_in_1st_dimension1D(xcen,xcor,method)
     
%MIRROR_IN_1ST_DIMENSION
%
% xcor = mirror_in_1st_dimension1D(xcen,xcor)
%
     
%%% HOW DOES IT WORK:

%%%  + center points,  input, first dimension, m index
%%%  x corner points, output, first dimension, m index
%%%
%%%     1,1    2,1    3,1    4,1    5,1    6,1    7,1
%%%  x   +--x---+--x---+--x---+--x---+--x---+--x---+  x
%%%  


%%%
%%%
%%%            xcen(1,1)         xcen(2,1)
%%% xcor(1,1)       +----xcor(2,1)-----+-     xcor(3,1)
%%%          backward                    
%%%         mirroring                    
%%%           <-----xs-------xm========xs====>                  
%%%                                    forward
%%%                                    mirroring

%%% The scheme above is is also valid for all m and n when one substitues m=1 n=1:
%%%   
%%%
%%%       
%%% x_s = xcen
%%%       
%%%
%%%        x(1,1) + x(1,2)     x(m,n)+ x(m+1,n)
%%% x_m = ----------------- = ------------------
%%%             2	            2		
%%%
%%% For mirroring backwards:
%%%                                                  3*x(1,1) -  x(2,1)
%%% xcor(1,2)  = xcor(m  ,n+1) = x_s + (x_s - x_m) = -------------------
%%%			                                        2
%%%
%%% For mirroring forwards:
%%%                                                  - x(1,1) + 3*x(2,1)
%%% xcor(1,3)  = xcor(m+2,n+1) = x_s + (x_s - x_m) = --------------------
%%%			                                        2
%%%

%%% Of course this is only done for grid points that have not yet been calculated.
%%% so only for points that are nan.

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