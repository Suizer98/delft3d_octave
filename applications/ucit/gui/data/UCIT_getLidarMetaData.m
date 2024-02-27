function [d] = UCIT_getLidarMetaData
%UCIT_GETLIDARMETADATA   this routine gets lidar meta data from the
%database
%
% This routine gets meta data from the most convenient place. The most
% convenient place is the userdata of the UCIT console. If no data is
% available there or if the available data does not match the puldown
% selection on the UCIT console a database query is performed. At the end
% of this query the data will be stored in the userdata of the UCIT console
% again.
%
% input:
%    function has no input
%
% output:
%    function has no output
%
% see also ucit, displayTransectOutlines, plotDotsInPolygon

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%   Mark van Koningsveld
%   Ben de Sonneville
%
%       M.vankoningsveld@tudelft.nl
%       Ben.deSonneville@Deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
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

datatypes = UCIT_getDatatypes;
url = datatypes.transect.urls{find(strcmp(UCIT_getInfoFromPopup('TransectsDatatype'),datatypes.transect.names))};
url = url{strcmp(datatypes.transect.areas{2},UCIT_getInfoFromPopup('TransectsArea'))};

d = get(findobj('tag','UCIT_mainWin'),'UserData');

if ~isfield(d,'shorepos')

    % load all metadata from netcdf
    crossshore = nc_varget(url, 'cross_shore');
    alongshore = nc_varget(url, 'alongshore');
    areacodes  = nc_varget(url, 'areacode');
    areanames  = nc_varget(url, 'areaname');
    years  = nc_varget(url, 'time');
    ids = nc_varget(url, 'id');
    contours = nc_varget(url, 'contour');
    
    areanames = cellstr(areanames);
    transectID = cellstr(num2str(ids));
    soundingID = cellstr(num2str(years));

    mean_high_water = nc_varget(url, 'mean_high_water');
    shorepos = nc_varget(url, 'shorepos');
    shore_north = nc_varget(url, 'shore_north');
    shore_east = nc_varget(url, 'shore_east');
    significant_wave_height = nc_varget(url, 'significant_wave_height');
    deep_water_wave_length = nc_varget(url, 'deep_water_wave_length');
    beach_slope = nc_varget(url, 'beach_slope');
    bias = nc_varget(url, 'bias');
    



    areanames = cellstr(areanames);
    transectID = cellstr(num2str(ids));
    soundingID = cellstr(num2str(years)); 

    % make d-structure
    d.datatypeinfo = repmat({UCIT_getInfoFromPopup('TransectsDatatype')},length(alongshore),1);
    d.contour =  [contours(:,1) contours(:,2) contours(:,3) contours(:,4)];
    d.area = areanames;
    d.areacode = areacodes;
    d.soundingID = soundingID;
    d.transectID = transectID;
    d.year = years;

    d.mean_high_water = mean_high_water;
    d.shorepos = shorepos;
    d.shore_north = shore_north;
    d.shore_east = shore_east;
    d.significant_wave_height = significant_wave_height;
    d.deep_water_wave_length = deep_water_wave_length;
    d.beach_slope = beach_slope;
    d.bias = bias;
    
    d.shore_north_1930 = nc_varget(url, 'shore_north_1930');
    d.shore_east_1930 = nc_varget(url, 'shore_east_1930');
    d.shore_north_1880 = nc_varget(url, 'shore_north_1880');
    d.shore_east_1880 = nc_varget(url, 'shore_east_1880');

    set(findobj('tag','UCIT_mainWin'),'UserData',d);
else
    disp('Lidar metadata loaded from UCIT console');
end


