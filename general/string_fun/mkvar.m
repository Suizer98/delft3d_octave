function stringout = mkvar(stringin,varargin);
%MKVAR   Make char string into valid variable name.
%
% stringout = mkvar(stringin)
%
% Replaces everything in s1 that's not a letter or digit with '_'
% so s2 can be used as variable name or as fieldname in a struct.
% s1 cna be a 2D char or a cellstr.
%
% If necesarry the first position is filled with 'x' rather than '_'.
% stringout = mkvar(stringin,letter) replaces the first position with the 
% user specified letter.
%
% stringout = mkvar(stringin,letter,'add'/'replace') replaces / adds first
% character, default 'add'.
%
% GENVARNAME does the same but insert nasty hex codes, whereas MKVAR inserts a '_'.
%
% See also: ISVARNAME, ISLETTER, MKTEX, MKHTML, GENVARNAME

%   --------------------------------------------------------------------
%   Idea: Howard E. Motteler from http://www.csee.umbc.edu/%7Emotteler/index.html
%   --------------------------------------------------------------------
%   Copyright (C) 2004-2006 Delft University of Technology
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

% $Id: mkvar.m 12475 2016-01-04 11:59:22Z gerben.deboer.x $
% $Date: 2016-01-04 19:59:22 +0800 (Mon, 04 Jan 2016) $
% $Author: gerben.deboer.x $
% $Revision: 12475 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/string_fun/mkvar.m $
% $Keywords$

   OPT.whattodo1st = 'add';
   OPT.excludes    = char([181 223 228 239 240]); % [µ ß ä ï ð], special problemetic chars that are a true letter nevertheless
   OPT.firstletter = 'x';
   
   if isempty(stringin)
       stringout = 'x';
       return
   end
   
   if nargin==2
      OPT.firstletter = varargin{1}';
   end
   
   if nargin>2
       OPT.whattodo1st = varargin{2};
   end    
   
       makechar = 0;
   if ischar(stringin)
       stringin = cellstr(stringin);
       makechar = 1;
   end
   
   stringout = stringin;
   for i=1:length(stringin)
      keep                = (isletter(stringin{i}) | ('0' <= stringin{i} & stringin{i} <= '9')) & ~ismember(stringin{i},OPT.excludes);
      stringout{i}(~keep) = '_';
      if stringout{i}(1)  == '_' | ...
         ('0' <= stringout{i}(1) & stringout{i}(1) <= '9')
          if strcmpi(OPT.whattodo1st(1),'r');
             stringout{i}(1)  = OPT.firstletter;
          elseif strcmpi(OPT.whattodo1st(1),'a');
             stringout{i}  = [OPT.firstletter, stringout{i}];
          end
      end
   end
   
   if makechar
       stringout = char(stringout);
   end
