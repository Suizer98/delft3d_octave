function varargout = subplot_meshgrid(nx,ny,dx1,dy1,varargin)
%SUBPLOT_MESHGRID  create non-equidistant mesh of subplots
%
% subplot_meshgrid(nx,ny,dx1,dy1)
% subplot_meshgrid(nx,ny,dx1,dy1,<dx2,dy2>)
%
% subplotgrid sets up an orthogonal array of subplots using the 
% dx/dy array specified as the width of the seperation borders to 
% calculate the width of the subplot windows.
%
% nx , ny : integers
% dx1, dy1: arrays of border dimensions:      dx1 with length 1 or nx+1
%                                             dy1 with length 1 or ny+1
% dx2, dy2: arrays of plot panel dimensions:  dx2 with length nx
%                                             dy2 with length ny
%
% Border arrays dx1,dy1 need to be 1 bigger than the subplot arrays dx2,dy2.
% They contain sizes in relative dimensions.
%
% -----------------------------------> direction of x array
%
%     dx1       dx1         dx1                                                    
%    |  |  dx2 |  |   dx2  |  |       |                                    
%   -+--+------+--+-~------+--+-      |                                    
%   -+--+------+--+-~------+--+-      |                                    
%    |  |      |  |        |  |       |                                    
%    |  |      |  |        |  |       v direction of y array
%    ~  ~      ~  ~        ~  ~
%   -+--+------+--+-~------+--+-      
%   -+--+------+--+-~------+--+-                                          
%    |  |      |  |        |  |                                           
%    |  |      |  |        |  |                                           
%   -+--+------+--+-~------+--+-                                          
%   -+--+------+--+-~------+--+-                                          
%    |  |      |  |        |  |                                           
%                                                                        
%  AX     = subplot_meshgrid(...) returns handle struct
% [AX,OUT] = subplot_meshgrid(...) returns also struct OUT with fields
%
% You start plotting in one of the axes with axes(AX(i))
%
% Example: 
% create two subplots: big on top (e.g. 4 map), thin below (e.g. 4 timeseries)
%
%    AX = subplot_meshgrid(2,2,.05,.05,[nan .02],[nan .15])
%    axes    (AX(1,1));surf(peaks)
%    axes    (AX(1,2));plot(peaks)
%    colorbar(AX(2,1))
%    delete  (AX(2,2))
%
%See also: SUBPLOT, AXES

% Version 1.00 Oct 2005 G.J. de Boer

%   --------------------------------------------------------------------
%   Copyright (C) 2005 Delft University of Technology
%
%       Gerben J. de Boer
%       g.j.deboer@citg.tudelft.nl	
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

U.debug = 0;
if nargin==5
   U.debug = 1;
elseif nargin==7
   U.debug = 1;
end

   if length(dx1)==1
       dx1 = repmat(dx1,[1,nx+1]);
      %dx1 = repmat(dx1,[1,nx +1]) = wrong (DON'T USE A SPACE AFTER nx!!)
   elseif ~(length(dx1)==(nx +1));
       error('length dx1 should be (nx + 1)')
   end    
   if length(dy1)==1
       dy1 = repmat(dy1,[1,ny+1]);
      %dy1 = repmat(dy1,[1,ny +1]); % = wrong (DON'T USE A SPACE AFTER nx!!)
   elseif ~(length(dy1)==(ny +1));
       error('length dy1 should be (ny + 1)')
   end    
   
if nargin==6
   
   dx2 = varargin{1};
   dy2 = varargin{2};
   
	if length(dx2)==1 %| all(isnan(dx2)) % this is wrong when [nan nan .. nan nan ] is supplied
	   dx2 = repmat(dx2,[1 nx]);
	elseif ~(length(dx2)==(nx))
	   if ~all(isnan(dx2))
              error('length dx2 should be (nx) or (1 without nans)');
           elseif length(dx2)==1
              dx2 = repmat(dx2,[1 nx]);
           end
	end    
	
	if length(dy2)==1 %| all(isnan(dy2)) % this is wrong when [nan nan .. nan nan ] is supplied
	   dy2 = repmat(dy2,[1 ny]);
	elseif ~(length(dy2)==(ny ))
	   if ~all(isnan(dy2))
              error('length dy2 should be (ny) or (1 without nans)');
           else
              dy2 = repmat(dy2,[1 ny]);
           end
	end    

   % Replace all nan's with same calculated value
   % Either value from d_1 or from d_2 can be nan;
   % for x

   if sum(isnan(dx1)>0)

      if sum(isnan(dx2)>0)
         error('Either dx1 of dx2 may contain nans.')
      end

      mask      = isnan(dx1);
      if sum(mask)==(nx+1)
         if sum(dx2)>=1
            error('sum(dx2)>=1')
         end
         dx1(mask) = (1               - sum(dx2))./sum(mask);
      else
         if (nansum(dx1) + sum(dx2))>=1
            error('(nansum(dx1) + sum(dx2))>=1')
         end
         dx1(mask) = (1 - nansum(dx1) - sum(dx2))./sum(mask);
      end


   elseif sum(isnan(dx2)>0)

      if sum(isnan(dx1)>0)
         error('Either dx1 of dx2 may contain nans.')
      end

      mask      = isnan(dx2);
      if sum(mask)==(nx)
         if sum(dx1)>=1
            error('sum(dx2)>=1')
         end
         dx2(mask) = (1               - sum(dx1))./sum(mask);
      else
         if nansum(dx2) + sum(dx1)>=1
            error('nansum(dx2) - sum(dx1)>=1')
         end
         dx2(mask) = (1 - nansum(dx2) - sum(dx1))./sum(mask);
      end

   end
   
   % Replace all nan's with same calculated value
   % Either value from d_1 or from d_2 can be nan;
   % for y

   if sum(isnan(dy1)>0)

      if sum(isnan(dy2)>0)
         error('Either dy1 of dy2 may contain nans.')
      end

      mask      = isnan(dy1);
      if sum(mask)==(ny+1)
         if sum(dy2)>=1
            error('sum(dy2)>=1')
         end
         dy1(mask) = (1               - sum(dy2))./sum(mask);
      else
         if nansum(dy1) + sum(dy2)>=1
            error('nansum(dy1) - sum(dy2)>=1')
         end
         dy1(mask) = (1 - nansum(dy1) - sum(dy2))./sum(mask);
      end

   elseif sum(isnan(dy2)>0)

      if sum(isnan(dy1)>0)
         error('Either dy1 of dy2 may contain nans.')
      end
   
      mask      = isnan(dy2);
      if sum(mask)==(ny)
         if sum(dy1)>=1
            error('sum(dy1)>=1')
         end
         dy2(mask) = (1               - sum(dy1))./sum(mask);
      else
         if nansum(dy2) + sum(dy1)>=1
            error('nansum(dy2) - sum(dy1)>=1')
         end
         dy2(mask) = (1 - nansum(dy2) - sum(dy1))./sum(mask);
      end

   end
   
else   

   dx2 = repmat((1 - sum(dx1))./nx,[nx 1]);
   dy2 = repmat((1 - sum(dy1))./ny,[ny 1]);

end

%dx2
%dy2

%disp([dx1 dx2])
%disp([dy1 dy2])

%dx1 = dx1 + eps;
%dy1 = dy1 + eps;

%dx2 = dx2 + eps;
%dy2 = dy2 + eps;

for ix = 1:nx
   for iy = 1:ny
   
      iiy = ny-iy+1;

      % Account for fact that subplots start counting upper left
      % whereas 'position' starts counting lower left:
      % Adjust so that (1,1) is upper left
   
          if ix==1 &     iy==ny & ~(iy==1)
          x0 = sum(dx1(1:ix    ));
          y0 = sum(dy1(iy+1:end));
         dx0 =     dx2(  ix    ) ;
         dy0 =     dy2(  iy    ) ; 
      elseif ix==1 & ~(  iy==ny)
          x0 = sum(dx1(1:ix    ));
          y0 = sum(dy1(iy+1:end))+ sum(dy2(iy+1:end));
         dx0 =     dx2(  ix    ) ;
         dy0 =     dy2(  iy    ) ; 
      elseif ~(ix==1) &  iy==1
          x0 = sum(dx1(1:ix    ))+ sum(dx2(1:ix-1));
          y0 = sum(dy1(iy+1:end))+ sum(dy2(iy+1:end));
         dx0 = dx2(ix      ) ;
         dy0 = dy2(iy      ) ; 
      else
          x0 = sum(dx1(1:ix    ))+ sum(dx2(1:ix-1));
          y0 = sum(dy1(iy+1:end))+ sum(dy2(iy+1:end));
         dx0 =     dx2(ix      ) ;
         dy0 =     dy2(iy      ) ; 
      end

      if U.debug
         disp(num2str([x0 y0 dx0 dy0]))
      end

      AX(ix,iy) = subplot('position',[x0 y0 dx0 dy0]);

      if U.debug
         text(x0+dx0/2,y0+dy0/2,[num2str(ix),'-',num2str(iy)])
         disp('Press key to continue')
         pause
      end

      if nargout==2
          OUT.x0(ix,iiy) =  x0;
          OUT.y0(ix,iiy) =  y0;
         OUT.dx0(ix,iiy) = dx0;
         OUT.dy0(ix,iiy) = dy0;      
      end
   end
end


if nargout<2
   varargout = {AX};
elseif nargout==2
   OUT.nx  = nx;
   OUT.ny  = ny;
   OUT.dx1 = dx1;
   OUT.dx2 = dx2;
   OUT.dy1 = dy1;
   OUT.dy2 = dy2;
   varargout = {AX,OUT};
end
