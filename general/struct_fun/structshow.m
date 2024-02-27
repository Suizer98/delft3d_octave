function structshow(S)
%STRUCTSHOW   Displays all dimensions of al numeric/char fields.
%
% Circumvents fact that Matlab shows only the first three dimensions.
%
% See also SIZE

% TO DO: align at x sign

%   --------------------------------------------------------------------
%   Copyright (C) Nov 2006 Nov Delft University of Technology
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

   fldnames = fieldnames(S);
   nfld     = length(fldnames);

%% First get to know all field widths
%% ------------------------------------------

   maxlen  = 0;
   maxsize = 0;
   maxdim  = 0;
   for ifld=1:nfld
      fldname = char(fldnames{ifld});
      maxlen  = max(maxlen,length(fldname));
      sz      = size(S.(fldname));
      maxdim  = max(maxdim,length(sz));
      maxsize = pad(maxsize,maxdim,0);
      sz      = pad(sz     ,maxdim,0);
      maxsize = max([maxsize;sz]);
   end
   
   sizeseperator = ' x ';
   
   sizewidth     = length(nums2str(maxsize,sizeseperator)); % ,'%d'

%% Display
%% ------------------------------------------

   for ifld=1:nfld
   fldname = char(fldnames{ifld});
      disp([' ',...
            pad(fldname,-maxlen,' '),...
            ': [',...
            pad(nums2str(size(S.(fldname)),sizeseperator),sizewidth,' '),... %'%d',
            ' ',...
            vartype(S.(fldname)),...
            ']']);
   end
   
%% EOF   