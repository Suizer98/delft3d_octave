function ph = jarkus_plot_locations_on_map(varargin)
%JARKUS_PLOT_LOCATIONS_ON_MAP  shows locations of selected jarkus transects on map
%
%   Function to plot a map of the Dutch coast with the locations of
%   selected jarkus transects indicated. The transects can be provided as
%   jarkus_transect structure or by directly providing jarkus_transects
%   input arguments to the current function.
%
%   Syntax:
%   ph = jarkus_plot_locations_on_map(varargin)
%
%   Input:
%   varargin  = either propertyname-propertyvalue pairs as expected by
%               jarkus_transects or a structure obtained from jarkus_transects
%       'projection'   either 'lonlat' (default) or 'xy'
%       'marker'       marker (default 'o') for the transect locations
%       'location'     legend location (default 'NorthWest')
%
%   Output:
%   ph = plot handles
%
%   Example
%    jarkus_plot_locations_on_map('id', [4001740 7001503 7003775])
%    jarkus_plot_locations_on_map('id', [4001740 7001503 7003775], 'projection', 'xy')
%
%   See also jarkus_transects

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Delft University of Technology
%       Kees den Heijer
%
%       C.denHeijer@TUDelft.nl	
%
%       Faculty of Civil Engineering and Geosciences
%       P.O. Box 5048
%       2600 GA Delft
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
% Created: 13 Sep 2011
% Created with Matlab version: 7.7.0.471 (R2008b)

% $Id: jarkus_plot_locations_on_map.m 12995 2016-11-21 12:45:12Z l.w.m.roest.x $
% $Date: 2016-11-21 20:45:12 +0800 (Mon, 21 Nov 2016) $
% $Author: l.w.m.roest.x $
% $Revision: 12995 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/jarkus/jarkus_plot_locations_on_map.m $
% $Keywords: $

%% defaults and input check
% check number of input arguments
error(nargchk(1, Inf, nargin))

OPT = struct(...
    'parent', [],...
    'projection', 'lonlat',...
    'marker', 'o',...
    'location', 'NorthWest');

% identify varargin elements that relate to OPT
OPTid = cellfun(@(x) ischar(x) && any(strcmp(x, fieldnames(OPT))), varargin);
OPTid = OPTid | [false OPTid(1:end-1)];

% set properties
OPT = setproperty(OPT, varargin{OPTid});
varargin(OPTid) = [];

projection = reshape(OPT.projection', length(OPT.projection)/2, 2)';
[projectionx projectiony] = deal(projection(1,:), projection(2,:));
[rsp_x rsp_y] = deal(['rsp_' projectionx], ['rsp_' projectiony]);

requiredfields = {'id' rsp_x rsp_y};
if isscalar(varargin) && isstruct(varargin{1})
    % structure input argument is assumed to be created by jarkus_transects
    tr = varargin{1};
    % check validity of tr structure
    [valid message] = jarkus_check(tr, requiredfields{:});
    if ~valid
        % pass error message
        error(message{1})
    end
else
    % transect structure is obtained by jarkus_transects
    try
        tr = jarkus_transects(varargin{:}, 'output', requiredfields);
    catch E
        if strcmp(E.identifier, 'MATLAB:Java:GenericException')
            error('Memory problems occured, confine your selection by specifying "id" and "year".')
        end
    end
end

% url of map
url = 'http://opendap.tudelft.nl/thredds/dodsC/data2/deltares/deltares/landboundaries/holland_fillable.nc';

%% obtain data
x = nc_varget(url, projectionx);
y = nc_varget(url, projectiony);

xytr = num2cell([tr.(rsp_x); tr.(rsp_y)]);

%% plot
if isempty(OPT.parent)
    figure
    parent = gca;
else
    parent = OPT.parent;
end
ph = plot(x, y, xytr{:},...
    'parent', parent);

%% set displaynames and markers
%lh = findobj(ph, 'XData', x, 'YData', y);
set(ph(1), 'DisplayName', 'Coastline')
th = ph(2:end);
set(th,...
    'marker', OPT.marker,...
    'linestyle', 'none');
cellfun(@(xt,yt,thh) set(thh, 'DisplayName', sprintf('%i', tr.id(xt == tr.(rsp_x) & yt == tr.(rsp_y)))), get(th, 'XData'), get(th, 'YData'), num2cell(th))
legh = legend('show');
set(legh,...
    'location', OPT.location)

%% set x and y labels
projections = {'lat' 'lon' 'x' 'y'};
labels = {'Latitude [degrees north]' 'Longitude [degrees east]' 'x-coordinate [m]' 'y-coordinate [m]'};

xlabel(labels(ismember(projections, projectionx)))
ylabel(labels(ismember(projections, projectiony)))
if strncmpi(OPT.projection,'xy',2); %Set axis to equal to keep aspect ratio of the Rijksdriehoek (XY) projection.
    axis equal
end