function matches = strfilter(vars, filters)
%STRFILTER  Find matches between strings and different kind of filters
%
%   Find matches between strings and different kind of filters. A string or
%   cell array of strings is compared to a filterstring or cell array of
%   filterstrings. The result is a logical array which indicates for each
%   provided string if a match is found with one of the provided
%   filterstrings. A filter string can be a regular string which needs an
%   exact match, a dos-like filter using asterix (which is internally
%   translated to a regexp) or a regexp. Regexp filters should start with
%   an / and may end with the same character.
%
%   Syntax:
%   matches = strfilter(vars, filters)
%
%   Input:
%   vars    = string or cell array with strings
%   filters = filterstring or cell array with filterstrings
%
%   Output:
%   matches = logical array of the size of vars indicating for each for if
%             a match is found
%
%   Example
%   matches = strfilter(vars, filters)
%   if ~any(strfilter(vars, filters)); continue; end;
%
%   See also regexp

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl	
%
%       Rotterdamseweg 185
%       2629HD Delft
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 03 Dec 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: strfilter.m 6215 2012-05-16 08:52:38Z hoonhout $
% $Date: 2012-05-16 16:52:38 +0800 (Wed, 16 May 2012) $
% $Author: hoonhout $
% $Revision: 6215 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/string_fun/strfilter.m $
% $Keywords: $

%% check input

if ~exist('vars', 'var'); filters = {}; end;
if ~exist('filters', 'var'); filters = {}; end;

if ~iscell(vars); vars = {vars}; end;
if ~iscell(filters); filters = {filters}; end;

%% search matches

if isempty(filters) || all(cellfun(@isempty,filters))
    matches = true(size(vars));
else
    matches = false(size(vars));

    for i = 1:length(filters)
        if filters{i}(1) == '/'
            % regexp filter
            f = regexp(filters{i}, '^/(.*?)/{0,1}$', 'tokens'); f = f{1};
            matches(~cellfun('isempty', regexpi(vars, f, 'start'))) = true;
        elseif ismember('*', filters{i})
            % dos filter
            f = ['^' strrep(filters{i}, '*', '.*') '$'];
            matches(~cellfun('isempty', regexpi(vars, f, 'start'))) = true;
        else
            % exact match
            matches(strcmpi(filters{i}, vars)) = true;
        end
    end
end