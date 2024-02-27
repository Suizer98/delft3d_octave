function varargout = pad_char(prepad,L,varargin)
%PAD_CHAR   Pads 2D char/numeric array on either side to required length.
%
% pad_char(array,L)
% pad_char(array,L,symbol)
% pad_char(array,symbol,L) % also, but for ASCII padding only !
%
% Pads an array with symbol 'symbol'
% until it has width abs(L). More precise, 
% it adds symbols until the second 
% dimension has size L. pad does not perform checks.
%
% When the second dimension is already equal or
% larger than L, nothing is done and the full array 
% is returned. An optional 2bn output argument can 
% be supplied. It gets the value 1 when the array is padded,
% and 0 when the array is not padded and left intect:
%
% [paddedarray, padstatus] = pad(array,L,symbol)
%
% - Left  pads when L is negative.
% - Rigth pads when L is positive.
%
% By default symbol is:
% - space for character arrays 
% - 0 for numeric arrays.
%
% Example:
%
% pad_char(['aaa';'bbb'],-4,'_') =
% _aaa
% _bbb
%
% pad_char(['aaa';'bbb'],-4,'_') =
% aaa_
% bbb_
%
% Note: always returns emtpy matrix for empty array
%
% See also: ADDROWCOL, NUM2STR (number,'%0.nd')

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

% $Id: pad_char.m 17097 2021-02-25 15:35:12Z l.w.m.roest.x $
% $Date: 2021-02-25 23:35:12 +0800 (Thu, 25 Feb 2021) $
% $Author: l.w.m.roest.x $
% $Revision: 17097 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/el_mat/pad_char.m $
% $Keywords$

displaywarning = 0;
if nargin==3
    if ischar(prepad) | isempty(prepad)
      if     ischar(L)
         symbol = L;
         L      = varargin{1};
      elseif isnumeric(L)
         symbol = varargin{1};
      end
   elseif isnumeric(prepad)
   symbol = varargin{1};
   end
else
   if ischar(prepad)
   symbol = ' ';
   elseif isnumeric(prepad)
   symbol = 0;
   end
end

%% pad

   absL = abs(L);
   
   if isempty(prepad)
      prepad = symbol;
   end
   
   if (size(prepad,2) < absL)
           
      if isempty(symbol)
   	
         error('syntax: pad(array,L,symbol) where symbol should not be empty');
   	
      else  
   	
         padded = repmat(symbol,[size(prepad,1) absL]);
   	
         if sign(L) < 0
         
         padded(:,absL-size(prepad,2)+1:end) = prepad(:,:);
         
         elseif sign(L) > 0
         
         padded(:,1:size(prepad,2)) = prepad(:,:);
         
         end
   	
      end
       
       iostat = 1;
   
   else
       
       if displaywarning
       disp(['Array not padded, as its length ',num2str(length(prepad)),' >= ',num2str(absL)]);
       end
       
       padded = prepad;
       
       iostat = 0;
       
   end    

%% output

   if nargout < 2
   
      varargout = {padded};
   
   elseif nargout == 2
   
      varargout = {padded,iostat};
   
   end
