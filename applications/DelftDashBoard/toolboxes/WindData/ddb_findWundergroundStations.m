function [lon lat id name] = ddb_findWundergroundStations(maxlat, minlat, maxlon, minlon, stationType)
%DDB_FINDWUNDERGROUNDSTATIONS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   [lon lat id name] = ddb_findWundergroundStations(maxlat, minlat, maxlon, minlon, stationType)
%
%   Input:
%   maxlat      =
%   minlat      =
%   maxlon      =
%   minlon      =
%   stationType =
%
%   Output:
%   lon         =
%   lat         =
%   id          =
%   name        =
%
%   Example
%   ddb_findWundergroundStations
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
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
% Created: 02 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%% FINDWUNDERGROUNDSTATIONS - Find wunderground (Weather Underground) stations within certain area
if nargin<4
    maxlat=90;
    minlat=-90;
    maxlon=180;
    minlon=-180;
end

if nargin<5
    stationType=[];
end

lat=[];
lon=[];
id=[];
name=[];

tic;
while toc<3 % look during t seconds for stations
    s=ddb_urlread(['http://stationdata.wunderground.com/cgi-bin/stationdata?maxlat=' num2str(maxlat) '&minlat=' num2str(minlat) '&maxlon=' num2str(maxlon) '&minlon=' num2str(minlon) '&iframe=1&module=1']);
    ss=strread(s,'%s','delimiter',';');
    
    idStation=find(~cellfun('isempty',regexp(ss,'\[''id''\]')));
    idLat=find(~cellfun('isempty',regexp(ss,'\[''lat''\]')));
    idLon=find(~cellfun('isempty',regexp(ss,'\[''lon''\]')));
    idType=find(~cellfun('isempty',regexp(ss,'\[''type''\]')));
    idName=find(~cellfun('isempty',regexp(ss,'\[''adm1''\]')));
    
    lat2=regexprep(ss(idLat),'t\[''lat''\]="','');
    lat2=regexprep(lat2,'"','');
    lat2=str2num(strvcat(lat2{:}));
    
    lon2=regexprep(ss(idLon),'t\[''lon''\]="','');
    lon2=regexprep(lon2,'"','');
    lon2=str2num(strvcat(lon2{:}));
    
    id2=regexprep(ss(idStation),'t\[''id''\]="','');
    id2=regexprep(id2,'"','');
    
    name2=regexprep(ss(idName),'t\[''adm1''\]="','');
    name2=regexprep(name2,'"','');
    
    type=regexprep(ss(idType),'t\[''type''\]="','');
    type=regexprep(type,'"','');
    
    if ~isempty(stationType)
        filterId=find(~cellfun('isempty',regexp(type,stationType)));
        lon=[lon; lon2(filterId)];
        lat=[lat; lat2(filterId)];
        name=[name; name2(filterId)];
        id=[id; id2(filterId)];
        [id, i]=unique(id);
        lon=lon(i);
        lat=lat(i);
        name=name(i);
    end
end

