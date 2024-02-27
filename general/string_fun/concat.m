function str = concat(strs, sep)
%CONCAT  Concatenate a cell array of strings using a seperator
%
%   Concatenate a cell array of strings using a seperator. The default
%   seperator is a space. A cell array will be concatenated over the
%   largest dimension, while a cell matrix will be concatenated over the
%   second dimension.
%
%   Syntax:
%   str = concat(strs, varargin)
%
%   Input:
%   strs      = cell array of strings
%   sep       = separator
%
%   Output:
%   str       = concatenated string
%
%   Example
%   concat({'The' 'bear' 'is' 'loose'});
%   concat({'One' 'two' 'three'}, ',');
%   concat({'First' 'line' ; 'Second' 'line'}, ' ');
%   concat(concat({'key_1' 'value_1' ; 'key_2' 'value_2'}, ' = '), ' AND ');
%
%   See also strtok, regexp, sprintf

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl
%
%       Rotterdamseweg 185
%       2629HD Delft
%       Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 27 Jul 2012
% Created with Matlab version: 7.14.0.739 (R2012a)

% $Id: concat.m 7926 2013-01-18 13:07:55Z hoonhout $
% $Date: 2013-01-18 21:07:55 +0800 (Fri, 18 Jan 2013) $
% $Author: hoonhout $
% $Revision: 7926 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/string_fun/concat.m $
% $Keywords: $

%% concatenate strings

if nargin == 1
    sep = ' ';
end

l = length(sprintf(sep));

if iscell(strs)
    
    if isempty(strs)
        str = [];
    else
        if any(size(strs)==1)

            str = sprintf([sep '%s'], strs{:});

            if length(str) > l
                str = str(l+1:end);
            end

        else

            str = cell(size(strs,1),1);

            for i = 1:size(strs,1)

                str{i} = concat(strs(i,:), sep);

            end

        end
    end
    
elseif ischar(strs)
    
    str = strs;
    
else
    
    error('Invalid input');
    
end