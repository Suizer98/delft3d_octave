function catalog = mvbMap(varargin)
%MVBMAP  Shows a map with stations from Meetnet Vlaamse Banken.
%
%   This script shows a map with the locations of stations from Meetnet
%   Vlaamse Banken (Flemish Banks Monitoring Network API). The catalog is
%   optionally returned in a struct.
%
%   A login token is required, which can be obtained with MVBLOGIN. A login
%   can be requested freely from https://meetnetvlaamsebanken.be/
%
%   Syntax:
%   varargout = mvbMap(varargin);
%
%   Input: For <keyword,value> pairs call mvbMap() without arguments.
%   varargin  =
%       token: <weboptions object>
%           Weboptions object containing the accesstoken. Generate this
%           token via mvbLogin.
%       language: string of preferred language: 'NL','FR' or 'EN',
%           officially 'nl-BE', 'fr-FR' or 'en-GB'.
%       apiurl: url to Meetnet Vlaamse Banken API.
%       epsg_out: EPSG code for the map's coordinate system. E.g.:
%           4326 (WGS'84)
%           25831 (ETRS89 / UTM zone 31N)
%           31370 (Belge Lambert'72, default)
%           28992 (Rijksdriehoek/Amersfoort)
%
%   Output:
%   varargout =
%       catalog: struct
%           Contains overview of locations, parameters and meta-data.
%
%   Example
%   mvbMap('token',token);
%
%   See also: MVBLOGIN, MVBCATALOG, MVBTABLE, MVBGETDATA.

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2021 KU Leuven
%       Bart Roest
%
%       bart.roest@kuleuven.be 
%       l.w.m.roest@tudelft.nl
%
%       KU Leuven campus Bruges,
%       Spoorwegstraat 12,
%       8200 Bruges,
%       Belgium
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
% Created: 18 Jan 2021
% Created with Matlab version: 9.9.0.1538559 (R2020b) Update 3

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%% Input arguments
OPT.apiurl='https://api.meetnetvlaamsebanken.be/V2/';
OPT.token=weboptions;
%OPT.epsg_in=31370;
OPT.epsg_map=31370;
OPT.xlim=[ 10000, 90000];
OPT.ylim=[190000,255000];
OPT.tzl=nan;
OPT.language='en-GB';
OPT.ax=gca;

% return defaults (aka introspection)
if nargin==0;
    catalog = {OPT};
    return
elseif mod(nargin,2)==1;
    OPT.token=varargin{end};
else
    % overwrite defaults with user arguments
    OPT = setproperty(OPT, varargin);
end

if isnan(OPT.tzl);
    OPT.tzl=round(log2(360*60*1852*2/diff(OPT.xlim)));
end
% if ischar(OPT.language);
%     if strncmpi(OPT.language,'NL',1);
%         OPT.language='nl-BE';
%     elseif strncmpi(OPT.language,'FR',1);
%         OPT.language='fr-FR';
%     elseif strncmpi(OPT.language,'EN',1);
%         OPT.language='en-GB';
%     else
%         fprintf(1,'Unknown language option "%s", using en-GB instead. \n',OPT.language);
%         OPT.language='en-GB';
%     end
% % elseif isscalar(OPT.language) && OPT.language >=1 && OPT.language <=3;
% %     %Use number
% else
%     fprintf(1,'Unknown language option "%s", using en-GB instead. \n',OPT.language);
%     OPT.language='en-GB';
% end
% % Find index for locale/language.
% % Try for chosen language.
% langIdx=find(strcmpi({catalog.Locations(1).Name.Culture},{OPT.language}),1);
% % When choosen language is not available in catalog, fall back to 'en-GB'.
% if isempty(langIdx);
%     fprintf(1,'Language "%s" not available in catalog, using en-GB instead.\n',OPT.language);
%     langIdx=find(strcmpi({catalog.Locations(1).Name.Culture},{'en-GB'}),1);
% end

%% Login Check
% Check if login is still valid!
response=webread([OPT.apiurl,'ping'],OPT.token);
if isempty(response.Customer) %Check if login has expired.
    fprintf(1,['Your login token is invalid, please login using mvbLogin \n'...
        'Use the obtained token from mvbLogin in this function. \n']);
    catalog=cell(nargout);
    return
end
%% Get Catalog
catalog = mvbCatalog(OPT.token);
%% Create a Map figure
if ~exist('plotMapTiles.m','file')==2
    error('Map plot function not found, sign up to or update OpenEarthTools');
end
[~,ax,~]=plotMapTiles('xlim',OPT.xlim,'ylim',OPT.ylim,'epsg_in',OPT.epsg_map,'epsg_out',OPT.epsg_map,'tzl',OPT.tzl,'han_ax',OPT.ax);
%xlim(ax,OPT.xlim);
%ylim(ax,OPT.ylim);
xlabel(OPT.ax,'Easting [m]');
ylabel(OPT.ax,'Northing [m]');
title(OPT.ax,'Locations of Measurement Stations');

%% Plot stations
for n = 1:length(catalog.Locations);
    lonlat=str2num(catalog.Locations(n).PositionWKT(8:end-1)); %#ok<ST2NM>
    [x,y]=convertCoordinates(lonlat(1),lonlat(2),'CS1.code',4326,'CS2.code',OPT.epsg_map);
    plot(x,y,'xk');
    %text(x,y,{ctl.Locations(n).ID;ctl.Locations(n).Name(OPT.language).Message});
    text(x,y,{catalog.Locations(n).ID})
end

% %% Print
% print(fullfile(fileparts(mfilename('fullpath')),['map_',OPT.epsg_map]),'-dpng')
