function varargout = jarkus_plot_in_googleEarth(varargin)
%JARKUS_PLOT_IN_GOOGLEEARTH  plot one or more jarkus transects in google Earth
%
%   Specify transect id and year(s) to plot the chosen transects in google
%   Earth. The transect can be specified by the 7 or 8 digit id number, by
%   a logical vector with the length of the available transects (2178), or
%   by vector of identifiers between 1 and 2178. The google Earth plot
%   information is written to a file which can be specified with the
%   keyword 'kmlfilename'. This .kml file can be opened in google Earth. 
%
%   Syntax:
%   varargout = jarkus_plot_in_googleEarth(varargin)
%
%   Input:
%   varargin  =
%               'id': vector of transect id's or logicals.
%               'year':  vector of years, leave empty for all years.
%               'kmlfilename': name of the KML file.
%               'url': url or path to jarkus netcdf.
%
%   Output:
%   varargout =
%               <none>
%
%   Example
%   jarkus_plot_in_googleEarth
%
%   See also: jarkus, googleplot.

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       Kees den Heijer
%
%       C.denHeijer@TUDelft.nl	
%
%       Faculty of Civil Engineering and Geosciences
%       P.O. Box 5048
%       2600 GA Delft
%       The Netherlands
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
% Created: 25 Nov 2009
% Created with Matlab version: 7.7.0.471 (R2008b)

% $Id: jarkus_plot_in_googleEarth.m 16127 2019-12-13 21:25:09Z l.w.m.roest.x $
% $Date: 2019-12-14 05:25:09 +0800 (Sat, 14 Dec 2019) $
% $Author: l.w.m.roest.x $
% $Revision: 16127 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/jarkus/jarkus_plot_in_googleEarth.m $
% $Keywords: $

%%
OPT = struct(...
    'id', [7005375 7005400 7005425],...
    'year', [],... % leave empty for all available years
    'kmlfilename', 'Jarkus.kml',...
    'url', jarkus_url);

OPT = setproperty(OPT, varargin{:});

%%
url = OPT.url;
fname = OPT.kmlfilename;

% interprete the alonshore id
if max(OPT.id ) <= length(nc_varget(url, 'id'))
    if islogical(OPT.id)
        transectid = find(OPT.id);
    else
        transectid = OPT.id;
    end
else
    transectid = find(ismember(nc_varget(url, 'id'), OPT.id));
end

% read time (in days since 1970-01-01 00:00 +1:00) and translate to years
  years = year(nc_cf_time(jarkus_url, 'time'));% instead of years = round(nc_varget(url, 'time') / 365.24) + 1970;

if isempty(OPT.year)
    % select all years if not specified
    yearid = 1:length(years);
else
    % select the predefined years
    yearid = find(ismember(years, OPT.year));
end
years = years(yearid);

stride = max(diff(yearid)) == min(diff(yearid));
if stride
    yearstride = max(diff(yearid));
end

% obtain the relevant data
[lat, lon, z] = deal([]);
for i = 1:length(transectid)
    lat(i,:) = nc_varget(url, 'lat', [transectid(i)-1 0], [1 -1]);
    lon(i,:) = nc_varget(url, 'lon', [transectid(i)-1 0], [1 -1]);
    if stride
        % get altitude (Dimension: {'time'  'alongshore'  'cross_shore'})
        z(:,i,:) = nc_varget(url, 'altitude', [0 transectid(i)-1 0], [length(yearid) 1 -1], [yearstride 1 1]);
    else
        % get altitude (Dimension: {'time'  'alongshore'  'cross_shore'})
        for j = 1:length(yearid)
            z(j,i,:) = nc_varget(url, 'altitude', [yearid(j)-1 transectid(i)-1 0], [1 1 -1]);
        end
    end
end
xRSP = nc_varget(url, 'cross_shore');
no_of_years = size(z,1);
no_of_transects = size(z,2);

%%
% Interpolation of z, notice the use of squeeze.

zi = nan(size(z));
for yy = 1:no_of_years
    for nn = 1:no_of_transects
        not_nan     = squeeze(~isnan(z(yy,nn,:)));
        if any(not_nan)
            zi(yy,nn,:) = interp1(xRSP(not_nan),squeeze(z(yy,nn,not_nan)),xRSP);
        end
    end
end

%% 
% * First step is expanding lat and lon to the same size as z

lat2 = nan(size(z));
lon2 = nan(size(z));
for yy = 1:no_of_years
    lat2(yy,:,:) =  lat;
    lon2(yy,:,:) =  lon;
end

%%
% * Then we reshape the data to a 2D matrix

lat2    = reshape(lat2, no_of_years * no_of_transects, []);
lon2    = reshape(lon2, no_of_years * no_of_transects, []);
zi      = reshape(zi, no_of_years * no_of_transects, []);

%% 
% * Time data also has to be reshaped

years    = repmat(years, no_of_transects, 1)';
timeIn  = datenum(years, 1, 1);
timeOut = datenum(years+1, 1, 1);

%%
% * And finally we can call KMLline

KMLline(lat2', lon2', zi',...
    'timeIn', timeIn,...
    'timeOut', timeOut,...
    'zScaleFun', @(z) (z+20)*5,...
    'fileName', fname);