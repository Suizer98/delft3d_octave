function OUT = addrowcol(IN,varargin);
%ADDROWCOL   expand matrix with rows/columns on either of 4 sides
%
%  addrowcol adds a row and column to a numeric or 
%  char array (by default filled with nans or space).
%
%  WORKS FOR THE MOMENT ONLY FOR 2dimensional ARRAYS!
%
%  out = addrowcol(in,marker) adds a row and column
%  filled with the value of marker.
%
%  out = addrowcol(in,dm,dn) adds dm rows and 
%  dm columns with nans.
%
%  out = addrowcol(in,dm,dn,marker) adds dm rows and 
%  dm columns with the value of marker.
%
%  If either dm and/or dn is negative, existing 
%  rows/columns are shifted by |dn| or |dm|
%  and the first |dn| or |dm| columns are given the 
%  value nan (default) or marker.
%
%  Example:
%     addrowcol(ones(2), 1, 1,Inf) yields
%     
%          1     1   Inf
%          1     1   Inf
%        Inf   Inf   Inf
%     
%     addrowcol(ones(2),-1,-1,Inf)  yields
%     
%        Inf   Inf   Inf
%        Inf     1     1
%        Inf     1     1
%
% Works also for adding 1D real or character arrays. 
% The character array concatanation can be useful when 
% preparing an char array for a vectorized text(...) call.
%
% * NOTE that when adding an 1D array, dm or dn should be 1.
%   as the array is added character by character 
%   so when adding 'ab' with dm =2, then 'aabb' is added
%   and not 'abab' as expected. Example:
%
%   >> addrowcol('a',0,2,'bc') = abbcc
%
% * NOTE that the first element of boerder is added
%   close to the original array. Example:
%
%   >> addrowcol('a',0, 1,'bc') = abc
%
%   >> addrowcol('a',0,-1,'bc') = cba
%
% * NOTE that addrowcol is ALSO vectorized for dm or dn!
%
%   >> addrowcol('a',0,[-1 1],'bc') = cbabc
%
% see also : PAD

%   --------------------------------------------------------------------
%   Copyright (C) 2004 Delft University of Technology
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
%   http://www.gnu.org/licenses/licenses.html,
%   http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% $Id: addrowcol.m 8044 2013-02-06 21:48:42Z boer_g $
% $Date: 2013-02-07 05:48:42 +0800 (Thu, 07 Feb 2013) $
% $Author: boer_g $
% $Revision: 8044 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/el_mat/addrowcol.m $
% $Keywords$

   dm            = 1;
   dn            = 1;
   
   if isnumeric(IN)
   border        = NaN;
   else
   border        = ' ';
   end

      makecellstr = 0;
   if iscellstr(IN)
      IN = char(IN);
      makecellstr = 1;
   end

   if nargin==2
      border        = varargin{1};
   elseif nargin==3
      dm            = varargin{1};
      dn            = varargin{2};
   elseif nargin==4
      dm            = varargin{1};
      dn            = varargin{2};
      border        = varargin{3};
   end
   
%% Recursive algorithm

   if length(border) ==0
         OUT = IN;       
   elseif length(border) >1
      
         OUT = IN;
         
         for ichar=1:length(border)
         
            OUT = addrowcol(OUT,dm,dn,border(ichar));
         
         end
   
   else
       
      sizedm = length(dm);
      sizedn = length(dn);

      %% Add border with zeros
      
      if sizedm > sizedn
      
      dn(sizedn+1:sizedm) = 0;
      
      else

      dm(sizedm+1:sizedn) = 0;

      end
      
      for imn=1:max(length(dm))
      
          OUT = repmat(border,size(IN,1)+abs(dm(imn)) ,...
                              size(IN,2)+abs(dn(imn)));
          
          OUT(1-min(dm(imn),0):end-max(dm(imn),0),...
              1-min(dn(imn),0):end-max(dn(imn),0))=IN;
              
          IN = OUT;
  
      end
   end

   if makecellstr
      OUT = cellstr(OUT);
   end
