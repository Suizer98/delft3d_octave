function numel = coord2numel(s, c)
%NUMEL2COORD  Translates a coordinate within a multi-dimensional matrix to an element number
%
%   Calculates the element number of an element in a multi-dimensional
%   matrix with a specific coordinate. The element number is determined by
%   numbering all elements starting at element [1 1 1 ...] and in the first
%   dimension, then the second dimension etcetera. Thus, in a 3x4x5 matrix,
%   element with coordinates [1 4 2] has number 22 because
%   (2-1)*(3*4)+(4-1)*(3)+1=22.
%
%   TODO: SCRIPT IS PROBABLY SUITIBLE FOR OPTIMIZATION
%
%   Syntax:
%   numel = coord2numel(s, c)
%
%   Input:
%   i           = list of coordinates
%   s           = size of matrix (result of size())
%
%   Output:
%   numel       = list with indices
%
%   Example
%   coord2numel(s, c)
%
%   See also numel2coord numel find

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       Bas Hoonhout
%
%       bas@hoonhout.com
%
%       Stevinweg 1
%       2628CN Delft
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

% This tool is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 21 Dec 2009
% Created with Matlab version: 7.5.0.338 (R2007b)

% $Id: coord2numel.m 2152 2010-01-18 16:40:11Z bas@hoonhout.com $
% $Date: 2010-01-19 00:40:11 +0800 (Tue, 19 Jan 2010) $
% $Author: bas@hoonhout.com $
% $Revision: 2152 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/el_fun/coord2numel.m $
% $Keywords$

% %% translate coordinates
% 
% % make sure at least one dimension exists
% if length(s) < 1; s = 1; end;
% 
% % allocate output variable
% numel = zeros(size(c,1),1);
% 
% % loop through all provided coordinates
% for ic = 1:size(c,1)
%     
%     % check whether coordinate is not out of bounds
%     if ~any(s-c(ic,:)<0)
%         
%         % walk from back to front through dimensions
%         for is = length(s):-1:1
%             
%             % update numel
%             if is > 1
%                 numel(ic) = numel(ic)+(c(ic,is)-1)*prod(s(1:is-1));
%             else
%                 numel(ic) = numel(ic)+c(ic,is);
%             end
%         end
%     end
% end

%% translate coordinates

evalstr = 'l = sub2ind(s';
for k = 1:length(s)
    evalstr = [evalstr ', c(' num2str(k) ')'];
end
evalstr = [evalstr ');'];

eval(evalstr);

numel = l;