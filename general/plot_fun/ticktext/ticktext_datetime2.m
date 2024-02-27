function labels = ticktext_datetime2(ticks)
%TICKTEXT_DATETIME2  Multiline scalable datetime formatting function for ticktext labels
%
%   Multiline scalable datetime formatting function for ticktext labels.
%   This function differs from ticktext_datetime in that it minimizes the
%   number of ticktext label lines.
%   It uses the following formats, but only selects the lowest level
%   distinct value from the resulting labels and uses the entire labels
%   only for the first tick:
%
%       {'yyyy' 'mmm' 'dd' 'HH:MM' 'SS'}
%
%   Syntax:
%   labels = ticktext_datetime2(ticks)
%
%   Input:
%   ticks     = Array with datenum tick values
%
%   Output:
%   labels    = Cell array with ticktext labels
%
%   Example
%   labels = ticktext_datetime2(now+[0:.25:3])
%
%   See also ticktext, ticktext_multiline_scalable, ticktext_datestr

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

% $Id: ticktext_datetime2.m 7430 2012-10-11 06:38:48Z hoonhout $
% $Date: 2012-10-11 14:38:48 +0800 (Thu, 11 Oct 2012) $
% $Author: hoonhout $
% $Revision: 7430 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/plot_fun/ticktext/ticktext_datetime2.m $
% $Keywords: $

%% determine ticklabels

formats = {{'yyyy' 'mmm' 'dd' 'HH:MM' 'SS'}};

fcn = @datestr;

labels0 = ticktext_multiline_scalable(ticks, fcn, formats);
labels  = cell(size(labels0));

% flatten ticklabels as much as possible by selecting lowest distinct level
% of ticktext label lines. Include the entire range of ticklabels for the
% first and last tick to set the scope.
for i = 1:length(labels0)
    n  = length(labels0{i});
    j2 = n;
    eq = true(1,n);
    
    for j = 0:n-1
        % skip zero time and first day of the month (e.g. 00:00, 00:00:00, 01 or Jan)
        if isempty(regexp(labels0{i}{end-j},'^[0:]+$','once')) && ...
           isempty(regexp(labels0{i}{end-j},'^01$','once')) && ...
           isempty(regexp(labels0{i}{end-j},'^Jan$','once'))
            j2 = n-j;
            break;
        end
    end
        
    if i == 1
        % use full notation for first tick
        j1 = 1;
    else
        for j = 0:n-1
            eq(n-j) = strcmpi(labels0{i}{end-j}, labels0{i-1}{end-j});
        end
        j1 = find(~eq,1,'first');
    end
    
    labels{i} = {};
    
    if j1 <= 3
        % date
        labels{i} = [labels{i} {concat(labels0{i}(min(j2,3):-1:min(j1,2)),'-')}];
    end
    if j2 > 3
        % time
        labels{i} = [labels{i} {concat(labels0{i}(max(j1,4):j2),':')}];
    end
    
    labels{i} = labels{i}(~cellfun(@isempty, labels{i}));
end
