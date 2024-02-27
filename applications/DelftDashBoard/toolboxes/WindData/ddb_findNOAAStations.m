function [x y id name] = ddb_findNOAAStations(maxlat, minlat, maxlon, minlon)
%DDB_FINDNOAASTATIONS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   [x y id name] = ddb_findNOAAStations(maxlat, minlat, maxlon, minlon)
%
%   Input:
%   maxlat =
%   minlat =
%   maxlon =
%   minlon =
%
%   Output:
%   x      =
%   y      =
%   id     =
%   name   =
%
%   Example
%   ddb_findNOAAStations
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

%%
% NOAA Weather data station locator
stationInfo=ddb_getTableFromWeb(['http://data.nssl.noaa.gov/dataselect/nssl_result.php?datatype=sf&sdate=2009-05-24&outputtype=stnlist&area=worldwide&minlon='...
    num2str(minlon) '&maxlat=' num2str(maxlat) '&maxlon=' num2str(maxlon) '&minlat=' num2str(minlat)],2);
id=stationInfo(2:end,1);
name=stationInfo(2:end,3);
x=str2lon(stationInfo(2:end,5));
y=str2lat(stationInfo(2:end,6));

%%
function lon=str2lon(lonStr);
[deg, mi]=cellfun(@strtok,lonStr,'UniformOutput',false);
deg=cellfun(@str2num,deg);
minutes=cellfun(@str2num,cellfun(@(x) x(1:end-1),mi,'UniformOutput',false));
hemisphere=cellfun(@(x) x(end),mi);
lon=deg+minutes/60;
hs=zeros(size(hemisphere));
hs(findstr(hemisphere','E'))=1;
hs(findstr(hemisphere','W'))=-1;
lon=hs.*lon;

%%
function lat=str2lat(latStr);
[deg, mi]=cellfun(@strtok,latStr,'UniformOutput',false);
deg=cellfun(@str2num,deg);
minutes=cellfun(@str2num,cellfun(@(x) x(1:end-1),mi,'UniformOutput',false));
hemisphere=cellfun(@(x) x(end),mi);
lat=deg+minutes/60;
hs=zeros(size(hemisphere));
hs(findstr(hemisphere','N'))=1;
hs(findstr(hemisphere','S'))=-1;
lat=hs.*lat;


