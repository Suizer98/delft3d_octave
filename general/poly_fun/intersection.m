function varargout = intersection(varargin)
%INTERSECTION  calculates exact intersections of two lines with the same x-coordinates.
%
%   [xi   ] = intersection(x1,y1,y2)
%   [xi,yi] = intersection(x1,y1,y2,<keyword,value>)
%
%   [xi   ] = intersection(x1,   y1,value) replicates value to y2 of size y1
%   [xi   ] = intersection(x1,value,   y2) replicates value to y1 of size y2
%
%   [xi   ] = intersection(y1,y2) assumes x1 = 1:lenght(y1)
%
%   where (xi,yi) are the vertices of the intersection.
%   (x1,y1) is the 1st line, and (x1,y2) or a horizontal line
%   at y=y2 is the 2nd line.
%
%   <keyword,value> pairs are:
%   * debug    :   1, 0 (default)
%   * direction:   'u<p>','d<own>','b<oth>' (default) to calculate 
%                  only the points where y1 goes up/down through level y2.
%
%   © G.J. de Boer, Delft University of Technology 
%
%   See also: INTERP1, FINDPOSITION, POLYINTERSECT

%15-06-2006

%   --------------------------------------------------------------------
%   Copyright (C) 2006-2008 Delft University of Technology
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
%   --------------------------------------------------------------------

   % TO DO; calculate inersection of two lines with different x vertices:
   % intersection(x1,y1,x2,y2)
   %
   % how: make a unique set of all points [x1 x2] and 
   % interpolate y1 and y2 to these new vertices, then apply existing procedure.

   %  x1 = 1:5;   
   %  y1 = [1 3 1 6 1];
   %  y2 = 2;
   
   %% Options
   %% ------------------

   OPTIONS.debug     = false;
   OPTIONS.direction = 'both';
   
   if odd(nargin)
      x1 = varargin{1};
      y1 = varargin{2};
      y2 = varargin{3};
      i = 4;
   else
      y1 = varargin{1};
      y2 = varargin{2};
      x1 = 1:length(y1);
      i = 3;
   end

   while i<=nargin,
     if ischar(varargin{i}),
       switch lower(varargin{i})
       case 'debug'    ;i=i+1;OPTIONS.debug     = varargin{i};
       case 'direction';i=i+1;OPTIONS.direction = varargin{i};
       otherwise
          error(sprintf('Invalid string argument: %s.',varargin{i}));
       end
     end;
     i=i+1;
   end;
   
   %% Pre process
   %% ------------------

   if length(y2)==1
      y2 = repmat(y2,size(y1));
   end   
   
   if length(y1)==1
      y1 = repmat(y1,size(y2));
   end   
   
   %% Calculate
   %% ------------------

   y2_y1        = y2-y1;
   through_zero = diff(sign(y2_y1));
   
   if     strcmp(lower(OPTIONS.direction(1)),'u');  % y1 goes up  , so y2 - y1 is lower (-2) in x direction
      indices      = find(through_zero==-2);
   elseif strcmp(lower(OPTIONS.direction(1)),'d')   % y1 goes down, so y2 - y1 is higher (+2) in x direction
      indices      = find(through_zero==+2);
   elseif strcmp(lower(OPTIONS.direction(1)),'b')   % both
      indices      = find(abs(through_zero)==2);
   else
      error('unknown option for keyword ''direction'': choose from ''u<p>'',''d<own>'' or ''b<oth>''')
   end
   
   xintersect = nan.*ones(1,length(indices));
   yintersect = nan.*ones(1,length(indices));
   
   for i=1:length(indices)
   
      index         = indices(i);
      xintersect(i) = interp1(y2_y1(index:index+1),x1(index:index+1),0);
      yintersect(i) = interp1(x1   (index:index+1),y1(index:index+1),xintersect(i));
      
   end
   
   %% Plot
   %% ------------------

   if OPTIONS.debug
      TMP = figure
      plot(x1,y1,'g')
      hold on
      plot(x1,y2,'r')
      plot(xintersect,yintersect,'ko')   
      legend('y1','y2','intersections')
      disp('Press key to continue')
      pause
      try
         close(TMP); % in case user closed figure already himself
      end
   end
   
   %% Output
   %% ------------------

   if nargout==1
      varargout = {xintersect};
   else
      varargout = {xintersect,yintersect};
   end
   
%% EOF   