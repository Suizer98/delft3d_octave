function transect = jarkus_readTransectDataNetcdf(filename, varargin)
%JARKUS_READTRANSECTDATANETCDF  create transect structure out of jarkus netcdf file
%
%   More detailed description goes here.
%
%   Syntax:
%   transect = jarkus_readTransectDataNetcdf(filename, varargin)
%
%   Input:
%   filename = netcdf file
%   varargin =
%
%   Output:
%   transect =
%
%   Example
%   transect = jarkus_readTransectDataNetcdf('http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/rijkswaterstaat/jarkus/profiles/transect.nc', 7003775, 2006)
%   transect = jarkus_readTransectDataNetcdf('http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/rijkswaterstaat/jarkus/profiles/transect.nc', 'Noord-Holland', 3775, 2006)
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       C.(Kees) den Heijer
%
%       Kees.denHeijer@Deltares.nl	
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

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 25 Aug 2009
% Created with Matlab version: 7.6.0.324 (R2008a)

% $Id: jarkus_readTransectDataNetcdf.m 8635 2013-05-17 08:38:21Z oeveren $
% $Date: 2013-05-17 16:38:21 +0800 (Fri, 17 May 2013) $
% $Author: oeveren $
% $Revision: 8635 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/jarkus/jarkus_readTransectDataNetcdf.m $
% $Keywords: $

%%
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
global areaname areacode alongshoreCoordinates;
if isempty(areaname)
    % temporary read from local file until website is updated
    areaname = cellstr(nc_varget(filename, 'areaname'));
end
if isempty(areacode)
    areacode = nc_varget(filename, 'areacode');
end
if isempty(alongshoreCoordinates)
    alongshoreCoordinates = nc_varget(filename, 'alongshore');
end
global id
if isempty(id)
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
    alongshoreIndex = transectId == alongshoreCoordinates;
    id_index = find(areaIndex & alongshoreIndex);
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
    %time = nc_varget(filename, 'time');
    t=nc_cf_time(filename, 'time');
    date=datestr(t);
end



time_index = find((str2num(date(:,8:11))) == soundingId);


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
transect.datatype     = 1;
transect.datatheme    = '';
transect.area         =                      areaname{id_index};
transect.areacode     = num2str(areacode             (id_index));
transect.transectID   = num2str(alongshoreCoordinates(id_index), '%05d');
transect.year=time_index;
%transect.year         = round(time(time_index)/365+1970); %'1965'

%TODO: store and look up
% transect.dateTopo = num2str(transect.dateTopo);   % '3008'
% transect.dateBathy = num2str(transect.dateBathy); % '1708'
%transect.soundingID = num2str(time(time_index));    % '1965'
transect.soundingID = date(time_index,8:11)

global crossShoreCoordinate
if isempty(crossShoreCoordinate)
    crossShoreCoordinate = nc_varget(filename, 'cross_shore');
end
crossShoreCoordinateZeroIndex = find(crossShoreCoordinate == 0);

x = nc_varget(filename,'x', [id_index-1, 0], [1,length(crossShoreCoordinate)]);


transect.xRD_orig = x(crossShoreCoordinateZeroIndex); %in EPSG:28992
transect.xRD=x;

y = nc_varget(filename,'y', [id_index-1, 0], [1,length(crossShoreCoordinate)]);

%%
transect.yRD_orig = y(crossShoreCoordinateZeroIndex); %in EPSG:28992
transect.yRD=y;
%%

global angle 
if isempty(angle)
    angle = nc_varget(filename,'angle');
end

transect.GRAD              = angle(id_index); %in degrees
transect.contour           = [x(1), y(1); x(end) , y(end)]; %[2x2 double]
transect.contourunit       = 'm';
transect.contourprojection = 'Amersfoort / RD New';
transect.contourreference  = 'origin';
transect.ls_fielddata      = 'parentSeq';

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

transect.xi = crossShoreCoordinate; %[1264x1 double]
height      = nc_varget(filename, 'altitude', [time_index-1, id_index-1, 0], [1, 1, length(crossShoreCoordinate)]);
transect.zi = height; %[1264x1 double]

%TODO: Check where these are calculated
transect.xe = transect.xi; %[1264x1 double]
transect.ze = transect.zi; %[1264x1 double]


end