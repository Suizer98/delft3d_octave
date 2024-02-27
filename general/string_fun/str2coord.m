function [x, y] = str2coord(name, varargin)
%STR2COORD  Converts a location string to a coordinate using Open Street Map
%
%   Converts a location string to a coordinate using Open Street Map. By
%   default, RD locations are returned. To return other coordinates in
%   another system, enter the EPSG-code.
%   
%   Syntax:
%   [x y] = str2coord(name, varargin)
%
%   Input:
%   name      = Name of the location (string)
%   varargin  = type: EPSG-code, 'RD' (default) or 'WGS84'
%
%   Output:
%   x         = x-coordinate of location (Easting)
%   y         = y-coordinate of location (Northing)
%
%   Example
%   [x y] = str2coord('Delft')
%   [x y] = str2coord('Bijenkorf Amsterdam')

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
% Created: 27 Dec 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: str2coord.m 16126 2019-12-13 20:38:30Z l.w.m.roest.x $
% $Date: 2019-12-14 04:38:30 +0800 (Sat, 14 Dec 2019) $
% $Author: l.w.m.roest.x $
% $Revision: 16126 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/string_fun/str2coord.m $
% $Keywords: $

%% read options

OPT = struct( ...
    'type', 28992 ... %RD-coordinates
);

OPT = setproperty(OPT, varargin{:});

%% retrieve latlon coordinate data from Open Street Map

x = []; y = [];

url = ['https://nominatim.openstreetmap.org/search?q=',name,'&format=json'];
data=webread(url);

if isstruct(data);
    if length(data)>1;
        address=data(1).display_name;
        warning(['Multiple name matches, using first match [' address ']']);
    end
    x=str2double(data(1).lon);
    y=str2double(data(1).lat);

elseif iscell(data);
    if length(data)>1;
        address=data{1}.display_name;
        warning(['Multiple name matches, using first match [' address ']']);
    end
    x=str2double(data{1}.lon);
    y=str2double(data{1}.lat);
else
    warning(['No results found for [' name ']']);
    return
end
% Google Maps API is depricated!
% url = ['http://maps.google.com/maps/geo?q=' name '&sensor=false&output=xml&oe=utf8&key=ABQIAAAAWIiGwZ4f3ncw4oQSuvUPrBSFwycF0SlTyEowikYlS8xDoCzQghQyGAIqzHZ5BYsm1feFl-x_mSfC9g'];
% xml = xmlread(url);
% 
% if xml.hasChildNodes
%     xml = xml.getElementsByTagName('kml');
%     xml = xml.item(0).getElementsByTagName('Response');
%     xml = xml.item(0).getElementsByTagName('Placemark');
% 
%     if xml.getLength > 0
%         if xml.getLength > 1
%             address = char(xml.item(0).getElementsByTagName('address').item(0).item(0).getData);
%             warning(['Multiple name matches, using first match [' address ']']);
%         end
%         
%         xml = xml.item(0).getElementsByTagName('Point');
% 
%         coords = xml.item(0).getElementsByTagName('coordinates').item(0);
%         coords = char(coords.item(0).getData);
%         coords = str2double(regexp(coords, ',' , 'split'));
% 
%         x = coords(1);
%         y = coords(2);
%     end
% end

%% convert coordinates

if ~isempty(x) && ~isempty(y)
    if isnumeric(OPT.type)
        [x, y] = convertCoordinates(x,y,'CS1.code',4326,'CS2.code',OPT.type);
    elseif ischar(OPT.type) %For backwards compatibility.
        switch OPT.type
            case 'RD'
                [x, y] = convertCoordinates(x,y,'CS1.code',4326,'CS2.code',28992);
            case 'WGS84'
                % do nothing
            otherwise
                warning(['Coordinate type unknown, using WGS84 [' OPT.type ']']);
        end
    end
    if nargout <= 1
        x = [x y];
    end
end

