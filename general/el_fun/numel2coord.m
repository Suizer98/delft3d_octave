function coord = numel2coord(s, i)
%NUMEL2COORD  Translates an element number to a coordinate within a multi-dimensional matrix
%
%   Calculates the coordinates in a multi-dimensional array of a certain
%   element with a specific element number. The element number is
%   determined by numbering all elements starting at element [1 1 1 ...]
%   and in the first dimension, then the second dimension etcetera. Thus,
%   in a 3x4x5 matrix, element 22 has coordinates [1 4 2] because
%   (2-1)*(3*4)+(4-1)*(3)+1=22.
%
%   TODO: SCRIPT IS PROBABLY SUITIBLE FOR OPTIMIZATION
%
%   Syntax:
%   coord = numel2coord(s, i)
%
%   Input:
%   s           = size of matrix (result of size())
%   i           = list of indices
%
%   Output:
%   coord       = matrix with coordinates of indices i
%
%   Example
%   numel2coord(s, i)
%
%   See also coord2numel numel find

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

% $Id: numel2coord.m 2152 2010-01-18 16:40:11Z bas@hoonhout.com $
% $Date: 2010-01-19 00:40:11 +0800 (Tue, 19 Jan 2010) $
% $Author: bas@hoonhout.com $
% $Revision: 2152 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/el_fun/numel2coord.m $
% $Keywords$

% %% translate indices
% 
% % make sure at least one dimension exists
% if length(s) < 1; s = 1; end;
% 
% % allocate output variable
% coord = ones(length(i),length(s));
% 
% % loop through all provided indices
% for ii = 1:length(i)
%     
%     % check whether index is not out of bounds
%     if ii <= prod(s)
%         
%         % walk from back to front through dimensions
%         for is = length(s):-1:1
%             
%             % determine division factor
%             if is > 1;
%                 dv = prod(s(1:is-1));
%             else
%                 dv = 1;
%             end
% 
%             % calculate modulus
%             md = mod(i(ii),dv);
% 
%             % determine whether index is just at the end of a dimension and
%             % calculate coordinate accordingly
%             if md > 0
%                 coord(ii,is) = max(1,floor(i(ii)./dv)+1);
%                 i(ii) = md;
%             else
%                 coord(ii,is) = max(1,floor(i(ii)./dv));
%                 i(ii) = dv;
%             end
%         end
%     else
%         % skip index, return zeros
%         coord(ii,:) = zeros(1,length(s));
%     end
% end

%% translate indices

c = nan(length(i), length(s));

evalstr = '[';
for k = 1:length(s)
    evalstr = [evalstr 'c(:,' num2str(k) ') '];
end
evalstr = [evalstr '] = ind2sub(s, i);'];

eval(evalstr);

coord = c;