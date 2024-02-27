function varargout = nc_plot_coastline(varargin)
%NC_PLOT_COASTLINE  Plots a coastline based on a netCDF datasource
%
%   Retrieves a coastline from a netCDF datasource and returns either the x
%   and y coordinates or plots the coastline and returns the line handle.
%
%   Syntax:
%   varargout = nc_plot_coastline(varargin)
%
%   Input:
%   varargin  = coordsys:   Coordinate system (RD/WGS84)
%               coastline:  Type of coastline (holland/northsea/user
%                           defined url to nc file)
%               plot:       Boolean that determines if to plot or to return
%                           the x and y coordinates
%
%   Output:
%   varargout = Either a handle to the plotted line or two vectors
%               containing x and y coordinates of the coastline
%
%   Example
%   h = nc_plot_coastline
%   h = nc_plot_coastline('holland')
%   h = nc_plot_coastline('northsea')
%   [x y] = nc_plot_coastline('plot', false)
%   h = nc_plot_coastline('coordsys', 'WGS84')
%
%   See also nc_varget

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
% Created: 29 Dec 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: nc_plot_coastline.m 5353 2011-10-20 07:45:39Z hoonhout $
% $Date: 2011-10-20 15:45:39 +0800 (Thu, 20 Oct 2011) $
% $Author: hoonhout $
% $Revision: 5353 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/plot_fun/nc_plot_coastline.m $
% $Keywords: $

%% read options

OPT = struct( ...
    'coordsys', 'RD', ...
    'coastline', 'holland', ...
    'fill', 'y', ...
    'plot', true ...
);

OPT = setproperty(OPT, varargin{:});

%% determine url

urls = struct( ...
    'holland', 'http://opendap.deltares.nl/thredds/dodsC/opendap/deltares/landboundaries/holland_fillable.nc', ...
    'northsea', 'http://opendap.deltares.nl/thredds/dodsC/opendap/deltares/landboundaries/northsea.nc' ...
);

if isfield(urls, OPT.coastline)
    url = urls.(OPT.coastline);
elseif strcmpi(OPT.coastline(end-2:end), '.nc')
    url = OPT.coastline;
else
    error(['Coastline not found [' OPT.coastline ']']);
end

%% get data

switch OPT.coordsys
    case 'WGS84'
        x = nc_varget(url, 'lon');
        y = nc_varget(url, 'lat');
    otherwise
        x = nc_varget(url, 'x');
        y = nc_varget(url, 'y');
end

%% plot data

if OPT.plot
    if ~isempty(OPT.fill)
        varargout = {fillpolygon([x y], 'k', OPT.fill)};
    else
        varargout = {plot(x, y)};
    end
else
    varargout = {x y};
end
