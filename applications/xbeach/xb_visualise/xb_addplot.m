function xb_addplot(x, data, type, color, name)
%XB_ADDPLOT  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = xb_addplot(varargin)
%
%   Input: For <keyword,value> pairs call xb_addplot() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   xb_addplot
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2015 Deltares
%       Joost den Bieman
%
%       joost.denbieman@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
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
% Created: 24 Apr 2015
% Created with Matlab version: 8.4.0.150421 (R2014b)

% $Id: xb_addplot.m 11911 2015-04-24 09:42:05Z bieman $
% $Date: 2015-04-24 17:42:05 +0800 (Fri, 24 Apr 2015) $
% $Author: bieman $
% $Revision: 11911 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_visualise/xb_addplot.m $
% $Keywords: $

if ~isempty(data);
    if size(data,2) > size(data,1)
        data = data';
    end
    if size(x,2) > size(x,1)
        x = x';
    end
    if length(x) < size(data,1)
        data = data(1:length(x),:);
    elseif length(x) > size(data,1)
        x = linspace(min(x),max(x),size(data,1));
    end
    
    plot(x', data', type, ...
        'Color', color, ...
        'LineWidth', 2, ...
        'DisplayName', name);
end
end