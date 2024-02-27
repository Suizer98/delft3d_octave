function maxdata = running_max_filter(data,window)
%RUNNING_MAX_FILTER  Fast running max calculation
%
%   More detailed description goes here.
%
%   Syntax:
%   data = running_max_filter(data,window)
%
%   Example
%     % calculate running max over 100k points with a window width of 1k
%     d = 1:1e5;
%     data = randn(size(d))+2*sind(d/15)+sind(d/16)+sind(d/17)+sind(d/18)+sind(d/19);
%     window = uint16(1000);
%     filtered = running_max_filter(data,window);
%     plot(d,data,'.',d,filtered,'r');
%     hold on
%     filtered2 = running_median_filter(data,window);
%     plot(d,filtered2,'g')
%
%   See also: running_median_filter, signal_fun

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2014 Deltares 4 Van Oord, based on running_median_filter.m
%       Gerben de Boer
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
% Created: 09 Nov 2012
% Created with Matlab version: 8.0.0.783 (R2012b)

% $Id: running_max_filter.m 8369 2013-03-22 12:02:48Z tda.x $
% $Date: 2013-03-22 13:02:48 +0100 (Fri, 22 Mar 2013) $
% $Author: tda.x $
% $Revision: 8369 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/signal_fun/running_max_filter.m $
% $Keywords: $

%% code
narginchk(2,2)
assert(~isempty(data),'data is empty');
assert(isvector(data),'data is not a vector');
assert(~isempty(window),'window is empty');
assert(isscalar(window),'window is not a scalar');
assert(~(isnan(window)| isinf(window)),'window must be a real number');
assert(~any(isnan(data) | isinf(data)),'NaN''s and Inf''s are not accepted by running_max_filter');
window = min(window,numel(data));

maxdata = nan(size(data));

window1 = double(ceil(window/2)); % mind that ceil yield int32 which is too small (65536)

for ii=1:length(data)
    ii0 = max(1           ,ii-window1);
    ii1 = min(length(data),ii+window1);
    maxdata(ii) = max(data(ii0:ii1));
end