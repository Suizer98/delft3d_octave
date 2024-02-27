function C = strtokens2cell(STR,DELIM)
%STRTOKENS2CELL   rewrites space delimitered keyword list to cell array
%
% C = strtokens2cell(STR) rewrites space delimitered keyword 
% list into cell array
%
% C = strtokens2cell(STR,DELIM) rewrites space delimitered string 
% list into cell array using first token in DELIM as delimiter
%
% Text embraced by double quotes (") is returned as one (textscan format '%q')
%
% example:
%
%    C = strtokens2cell('a b "something else"')
%
% gives C{1}='a';C{2}='b';C{3}='something else'
%
%   C = 
%  
%      'a'    'b'    'something else'
%
% See also: STRTOK, STR2LINE

%   --------------------------------------------------------------------
%   Copyright (C) 2006 Deltares
%       Gerben de Boer
%
%       gerben.deboer@deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
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

% $Id: strtokens2cell.m 11686 2015-02-06 14:42:36Z gerben.deboer.x $
% $Date: 2015-02-06 22:42:36 +0800 (Fri, 06 Feb 2015) $
% $Author: gerben.deboer.x $
% $Revision: 11686 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/string_fun/strtokens2cell.m $

format = '%q';
if nargin<2
    DELIM = ' ';
end

C = textscan(STR,format,'Delimiter',DELIM,'MultipleDelimsAsOne',1);
C = C{1};C = {C{:}};

%% EOF