function varargout = subset1(varargin)
%SUBSET1   Selects subset from 1D arrays based on range.
%                                                    
% [xsub,ysub] = subset1(x,y,xrange)  %  where size(y,1) should be length(x), and
%       ysub  = subset1(x,y,xrange)  %  subsets acts indepedently on all 2nd dimensions.
%                                                    
%       y                                                     
%       ^              O        O                             
%       |        |   /  \     /   \  |                        
%       |        | /     \  /       \|                        
%       |        @        O          @         o              
%       |      / |                   |\       /               
%       |    /   |                   |  \   /                 
%       |  o     |                   |    o                   
%       |        |                   |                        
%       +---------+-------------------+----------->  x          
%              range(1)           range(2)                    
%                                                          
% Of the original input data (o and O) SUBSET1 returns only the O,
% and adds the interpolated @ values to make ysub match xrange exactly.
%
% ysub = subset1(x,y,xrange,<keyword,value>)
% where implemented <keyword,value> pairs are:
% * range:     'exact' (defualt) adds the points @,
%              otherwise only points O are returned.
% * method:    interpolation method for boundary points @
%              passed to interp1(...)
%
% Example:
% ys=subset1([0 1 2 3 4]',[0 1 1 1 0; 0 2 2 2 0]',[.1 3.1])
%
%See also: INTERP1

%   --------------------------------------------------------------------
%   Copyright (C) 2007 Delft University of Technology
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
%   USA or 
%   http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% $Id: subset1.m 390 2009-04-22 09:07:39Z boer_g $
% $Date: 2009-04-22 17:07:39 +0800 (Wed, 22 Apr 2009) $
% $Author: boer_g $
% $Revision: 390 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/el_mat/subset1.m $
% $Keywords$

      OPT.range  = 'exact';
      OPT.method = 'linear';
      
      x      = varargin{1};
      y      = varargin{2};
      xrange = varargin{3};
      
      iargin = 4;
      while iargin<=nargin,
        if ischar(varargin{iargin}),
          switch lower(varargin{iargin})
          case 'range' ;iargin=iargin+1;OPT.range   = varargin{iargin};
          case 'method';iargin=iargin+1;OPT.method  = varargin{iargin};
          otherwise
             error(['Invalid string argument: %s.',varargin{i}]);
          end
        end;
        iargin=iargin+1;
      end;       
      
      mask = (x >= xrange(1) & ...
              x <= xrange(2));
                 
      if strcmp(OPT.range,'exact')
         if x(mask(1))==range(1)
           yborder(1,:) = [];
         else
           yborder(1,:) = interp1(x,y,xrange(1),OPT.method);
         end
         
         if x(mask(1))==range(2)
           yborder(2,:) = [];
         else
           yborder(2,:) = interp1(x,y,xrange(2),OPT.method);
         end

         ysub = [yborder(1,:); y(mask,:); yborder(2,:)];
         
      else

         ysub = [y(mask)];
         
      end % if strcmp(OPT.range,'exact')

if     nargout==1
   varargout = {ysub};
elseif nargout==2
   xsub      = [xrange(1) squeeze(x(mask))' xrange(2)];
   varargout = {xsub,ysub};
end