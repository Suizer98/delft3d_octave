function varargout = locate_datapoint(handle, varargin)
%LOCATE_DATAPOINT  locate individual points in a figure
%
%   Function to select individual data points in a figure and find the
%   coordinates, the index of the point within the dataset and if available
%   the displayname (legend). This function can be useful, for example, to
%   inspect the origin of outliers in a scatter plot.
%
%   Syntax:
%   varargout = locate_datapoint(varargin)
%
%   Input:
%   handle    = figure handle
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   locate_datapoint
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Kees den Heijer
%
%       Kees.denHeijer@Deltares.nl
%
%       Deltares
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
% Created: 03 Aug 2011
% Created with Matlab version: 7.12.0.635 (R2011a)

% $Id: locate_datapoint.m 5103 2011-08-23 10:05:28Z heijer $
% $Date: 2011-08-23 18:05:28 +0800 (Tue, 23 Aug 2011) $
% $Author: heijer $
% $Revision: 5103 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/plot_fun/locate_datapoint.m $
% $Keywords: $

%%
props = {'type' 'xdata' 'ydata' 'DisplayName'};

h = findobj(handle,'-depth', Inf,...
    'type', 'line', '-or', 'type', 'patch');
% the type 'patch' is needed for scatter plots
values = get(h, props);
set(findobj(handle, 'type', 'axes'), 'nextplot', 'add')
ph = plot(NaN, NaN, 'r+', 'MarkerSize', 10);

while true
    fprintf('\nSelect point by clicking the left mouse button\n');
    fprintf('Press any other button or key to exit\n');
    % pre-allocate distance D to infinite
    D = Inf;
    [x y button] = ginput(1);
    if button ~= 1
        set(ph, 'xdata', nan, 'ydata', nan)
        break
    end
    % loop over al available line handles to find the point closest to the
    % clicked point
    for ihandle = 1:size(values,1)
        % obtain the x and y data
        xdata = values{ihandle, strcmp('xdata', props)};
        ydata = values{ihandle, strcmp('ydata', props)};
        % derive the distance from each of the points to the clicked point
        for ir = 1:size(xdata,1)
            for ic = 1:size(xdata,2)
                d(ir,ic) = sqrt(diff([x xdata(ir,ic)])^2 + diff([y ydata(ir,ic)])^2);
            end
        end
        % filter the closest point and its index
        [d ix] = nanmin(d);
        if d < D
            % redefine the closest point sofar and save its handle index
            % and data index
            D = d;
            ih = ihandle;
            IX = ix;
        end
    end
    % summarise the info of the selected point
    xp = values{ih, strcmp('xdata', props)}(IX);
    yp = values{ih, strcmp('ydata', props)}(IX);
    displayname = values{ih, strcmp('DisplayName', props)};
    % show the point in the figure
    set(ph, 'xdata', xp, 'ydata', yp)
    % print its coordinates and index in the command window
    fprintf('  x = %g\n  y = %g\n  index = %i\n', xp, yp, IX);
    if ~isempty(displayname)
        % also print its displayname if available
        fprintf('  displayname: %s\n', displayname);
    end
end