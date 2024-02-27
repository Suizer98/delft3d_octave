function val = cellstrrepnum(varargin)
%CELLSTRREPNUM   replace specific strings in cell (e.g. 'NA') with num (e.g. NaN) or other string
%
%    C = cellstrrepnum(C1,S2,SN3) replaces all occurrences of 
%        any of the the strings of S2 in cell C1 with string or number SN3.
%        The new cell is returned.
%
% Note that CELLSTRREPNUM is case-sensitive.
%
% Input SN3 is optional, by default NaN;
% Input S2  is optional, but required 
% before SN3. S2 is by default {'na','NA','Na'}
%
%    Example2:
%        c1 ={'na','NA'  ,'nan',3,'foo'};cellstrrepnum(c1)             
%
%    returns { NaN, NaN  ,'nan',3,'foo'}
%
%        c1 ={'na','NA'  ,'nan',3,'foo'};cellstrrepnum(c1,{'NA','foo'},'oops') 
%
%    returns {'na','oops','nan',3,'oops'}
%
%See also: STRREP, STR2NUM, NUM2STR, NAN

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Gerben de Boer
%
%       gerben.deboer@deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
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
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% $Id: cellstrrepnum.m 496 2009-06-04 15:47:01Z boer_g $
% $Date: 2009-06-04 23:47:01 +0800 (Thu, 04 Jun 2009) $
% $Author: boer_g $
% $Revision: 496 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/string_fun/cellstrrepnum.m $
% $Keywords$

   OPT.strcode = {'na','NA','Na'};
   OPT.numcode = NaN;
   OPT.charout = 0;
   
   val         = varargin{1};
   if ischar(val)
   val         = cellstr(val);
   OPT.numout  = 1;
   end
   
   if nargin >1
   OPT.strcode = varargin{2};
   end
   if nargin >2
   OPT.numcode = varargin{3};
   end
   
   for i=1:length(val)
      if ischar(val{i})
         if any(strcmp(val{i},OPT.strcode))
            val{i} = OPT.numcode;
         end
      end   
   end
   
   if OPT.charout
       val = char(val);
   end

%  %% find which elements are a char
%  
%     mask.char=cellfun(@(x) ischar(x)      ,val);
%  
%  %% of those find which ones match code
%  
%     mask.val =cellfun(@(x) any(strcmp(x,OPT.strcode)),val(mask.char))
%  
%  %% and replaces those
%  
%     val{mask.char(mask.val)}=OPT.num;