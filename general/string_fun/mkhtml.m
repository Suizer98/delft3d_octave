function strout = mkhtml(strin);
%MKHTML   Make char string into valid html string.
%
% strout = mkhtml(strin)
%
% Replaces soem special characters with codes '%number'
%
% Special HTML symbols are encoded as hex value with ISO 8859-1 Latin alphabet No. 1
% http://www.ascii.cl/htmlcodes.htm:ISO 8859-1 Latin alphabet No. 1
%
% ' '    becomes %20 (space)
% '%'    becomes %25
% '&'    becomes %38
% '|'    becomes %7C
% '/'    becomes %2F
% '<'    becomes %3C
% ','    becomes %2C
% '('    becomes %28
% ')'    becomes %29
% ':'    becomes %%3A
%
% See also: ISLETTER, MKVAR, MKTEX, urlencode, urldecode

%   --------------------------------------------------------------------
%   Copyright (C) 2010 Delft University of Technology
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
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   -------------------------------------------------------------------- 

   
   OPT.symbols  = {' ','%','&','|','/','<',',','(',')','''','>'};  % NOTE do '%' first, as all are replaced by %hex

   disp(['mkhtml: processed only following characters: ',char(OPT.symbols)']);
   
   strout = strin;
   for isymbol=1:length(OPT.symbols)
   symbol = OPT.symbols{isymbol};
   strout = strrep(strout,symbol,['%',dec2hex(unicode2native(symbol, 'ISO-8859-1'))]);
   end
   
%% EOF   
