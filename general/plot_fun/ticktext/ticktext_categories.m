function labels = ticktext_categories(ticks, categories)
%TICKTEXT_CATEGORIES  Formatting function for category ticktext labels
%
%   Formatting function for ticktext labels simply replacing integer tick
%   values with pre-defined category strings. Category strings are supplied
%   through a secondary argument.
%
%   Syntax:
%   labels = ticktext_categories(ticks, categories)
%
%   Input:
%   ticks      = Array with tick values
%   categories = Cell array with category strings
%
%   Output:
%   labels     =
%
%   Example
%   labels = ticktext_categories([3:-1:1], {'CAT #1' 'CAT #2' 'CAT #3'})
% 
%   figure; bar(rand(1,5));
%   ticktext(gca,'FormatFcn',@ticktext_categories, ...
%   	'FormatFcnVariables',{{'\alpha' '\beta' '\gamma' '\delta' '\epsilon'}});
%
%   See also ticktext

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
% Created: 10 Oct 2012
% Created with Matlab version: 7.14.0.739 (R2012a)

% $Id: ticktext_categories.m 7423 2012-10-10 08:13:03Z hoonhout $
% $Date: 2012-10-10 16:13:03 +0800 (Wed, 10 Oct 2012) $
% $Author: hoonhout $
% $Revision: 7423 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/plot_fun/ticktext/ticktext_categories.m $
% $Keywords: $

%% determine ticklabels

if ~iscell(categories)
    error('Invalid input');
end

labels = cell(size(ticks));
for i = 1:length(ticks)
    if ticks(i) > 0 && ticks(i) <= length(categories)
        labels{i} = categories{ticks(i)};
    else
        labels{i} = '?';
    end
end