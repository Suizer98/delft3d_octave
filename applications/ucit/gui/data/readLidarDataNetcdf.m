function [transect] = readLidarDataNetcdf(filename, varargin)
%READLIDARDATANETCDF   transforms processed lidar data to UCIT data structure d
%
%   
%
%   Syntax: d = readLidarDataNetcdf(filename, 'or','14444','20020902')
%   
%
%   Input:
%   
%
%   Output: d structure
%   
%
%   Example
%   
%
%   See also readTransectDataNetCDF

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares  
%   Ben de Sonneville
%
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


if (nargin == 4)
    areaId = varargin{1};
    transectId = varargin{2};
    soundingId = varargin{3};
elseif (nargin == 3)
    transectId = varargin{1};
    soundingId = varargin{2};
else 
    error('expecting 3 or 4 arguments')
end

% make sure that transectId and soundingId are doubles
if ischar(transectId)
    transectId = str2double(transectId);
end
if ischar(soundingId)
    soundingId = str2double(soundingId);
end

% we need to lookup the index of transect and the year 


%% lookup the header variables
% global areaname areacode alongshoreCoordinates;
if ~exist('areaname') | isempty(areaname)
    % temporary read from local file until website is updated
    areaname = cellstr(nc_varget(filename, 'areaname'));
end
if ~exist('areacode') | isempty(areacode)
    areacode = nc_varget(filename, 'areacode');
end
if ~exist('alongshoreCoordinates') | isempty(alongshoreCoordinates)
    alongshoreCoordinates = nc_varget(filename, 'alongshore');
end
% global id
if ~exist('id') | isempty(id)
    id = nc_varget(filename, 'id');
end

%% first lookup the transect index

if (nargin == 4)
    % we use a double key, areaId + transectId
    % first find the areaIndices
    if isempty(str2num(areaId))
        areaIndex = ~cellfun(@isempty, strfind(areaname, areaId));
    else
        areaIndex = areacode == str2num(areaId);
    end
    % next find the alongshore indices
    alongshoreIndex = transectId == id;
    id_index = find(alongshoreIndex); % areaIndex & 
    if isempty(id_index)
        error(['transect not found with id: ' num2str(transectId)]);
    end    
elseif (nargin == 3)
    % we use the id as stored in the file

    id_index = find(id == transectId);
    if isempty(id_index)
        error(['transect not found with id: ' num2str(transectId)]);
    end
end

%% lookup the year

 global year
if isempty(year)
    time = nc_varget(filename, 'time');
end
time_index = find(time == soundingId);
if isempty(time_index)
    error(['year not found: ' time_index]);
end


%% create transect structure
transect.seq = 0;
global title
if isempty(title)
     title = nc_attget(filename, nc_global, 'title');
 end
transect.datatypeinfo = title;

transect.datatype = 1;

transect.datatheme = '';

transect.area = areaname{id_index};

transect.areacode = num2str(areacode(id_index));

transect.transectID = num2str(id(id_index), '%05d');

transect.year = num2str(time(time_index)); %'1965'

%TODO: store and look up
% transect.dateTopo = num2str(transect.dateTopo); % '3008'
% transect.dateBathy = num2str(transect.dateBathy); % '1708'
transect.soundingID = num2str(time(time_index)); % '1965'


global crossShoreCoordinate
if isempty(crossShoreCoordinate)
    crossShoreCoordinate = nc_varget(filename, 'cross_shore');
end
crossShoreCoordinateZeroIndex = find(crossShoreCoordinate == 1);

% x = nc_varget(filename,'x', [id_index-1, 0], [1, length(crossShoreCoordinate)]);
% transect.xRD = x(crossShoreCoordinateZeroIndex); %in EPSG:28992
% 
% y = nc_varget(filename,'y', [id_index-1, 0], [1, length(crossShoreCoordinate)]);
% transect.yRD = y(crossShoreCoordinateZeroIndex); %in EPSG:28992

global angle 
if isempty(angle)
    angle = nc_varget(filename,'angle');
end

% transect.GRAD = angle(id_index); %in degrees

% transect.contour = [max(x), min(y); min(x) , max(y)]; %[2x2 double]

transect.contour = nc_varget(filename, 'contour',[id_index-1, 0], [1,4]);

transect.contourunit = 'm';

transect.contourprojection = 'Amersfoort / RD New';

transect.contourreference = 'origin';

transect.ls_fielddata = 'parentSeq';
%TODO: Check where these are calculated
timestamp = 0; %1.1933e+009;?
%TODO: Check where these are calculated
transect.fielddata = []; %[1x1 struct]

global MHW 
if isempty(MHW)
    MHW = nc_varget(filename,'mean_high_water');
end
transect.MHW = MHW(id_index); 

global MLW
if isempty(MLW)
    MLW = nc_varget(filename,'mean_low_water');
end
transect.MLW = MLW(id_index); 

transect.lon = nc_varget(filename, 'lon',[time_index-1, id_index-1, 0], [1, 1, length(crossShoreCoordinate)]);
transect.lat = nc_varget(filename, 'lat',[time_index-1, id_index-1, 0], [1, 1, length(crossShoreCoordinate)]);


transect.xi = nc_varget(filename, 'cross_shore_distance',[time_index-1, id_index-1, 0], [1, 1, length(crossShoreCoordinate)]);
transect.zi = nc_varget(filename, 'altitude', [time_index-1, id_index-1, 0], [1, 1, length(crossShoreCoordinate)]);


%TODO: Check where these are calculated
transect.xe = transect.xi; %[1264x1 double]
transect.ze = transect.zi; %[1264x1 double]

transect.regression = nc_varget(filename, 'regression',[time_index-1, id_index-1, 0], [1, 1, length(crossShoreCoordinate)]);
transect.shorePos = nc_varget(filename, 'shorepos', [id_index-1], [1]);
transect.MHW = nc_varget(filename, 'mean_high_water', [id_index-1], [1]);

transect.slope = nc_varget(filename,'beach_slope', [id_index-1], [1]);

end








