function [values, dates] = read_waterinfo(filename)
% read_waterinfo function to read in waterinfo csv files
%
% [values, dates] = read_waterinfo(filename)
%
% URL: https://waterinfo.rws.nl/

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
% Created: 11-May-2017
% $Id: read_waterinfo 12732 2016-05-12 15:47:18Z nederhof $
% $Date: 2016-05-12 17:47:18 +0200 (Thu, 12 May 2016) $
% $Author: nederhof $
% $Revision: 12732 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/Bathymetry/ddb_BathymetryToolbox_fillcache.m $
% $Keywords: $

%% 1) Read in the data
% Initialize variables.
delimiter = {',',';'};
startRow = 2;
formatSpec = '%*q%*q%*q%*q%*q%*q%*q%*q%*q%*q%*q%*q%q%q%q%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'HeaderLines' ,startRow-1, 'ReturnOnError', false)
fclose(fileID);

%% 2) Convert the contents of columns containing numeric strings to numbers.
% Replace non-numeric strings with NaN.
raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
for col=1:length(dataArray)-1
    raw(1:length(dataArray{col}),col) = dataArray{col};
end
numericData = NaN(size(dataArray{1},1),size(dataArray,2));

% Converts strings in the input cell array to numbers. Replaced non-numeric
% strings with NaN.
rawData = dataArray{3};
for row=1:size(rawData, 1);
    % Create a regular expression to detect and remove non-numeric prefixes and
    % suffixes.
    regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
    try
        result = regexp(rawData{row}, regexstr, 'names');
        numbers = result.numbers;
        
        % Detected commas in non-thousand locations.
        invalidThousandsSeparator = false;
        if any(numbers==',');
            thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
            if isempty(regexp(numbers, thousandsRegExp, 'once'));
                numbers = NaN;
                invalidThousandsSeparator = true;
            end
        end
        % Convert numeric strings to numbers.
        if ~invalidThousandsSeparator;
            numbers = textscan(strrep(numbers, ',', ''), '%f');
            numericData(row, 3) = numbers{1};
            raw{row, 3} = numbers{1};
        end
    catch me
    end
end
rawNumericColumns = raw(:, 3);
rawCellColumns = raw(:, [1,2]);
R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),rawNumericColumns); % Find non-numeric cells
rawNumericColumns(R) = {NaN}; % Replace non-numeric cells
COMPARTIMENT_CODE = rawCellColumns(:, 1);
WAARDEBEWERKINGSMETHODE_OMSCHRIJVING = rawCellColumns(:, 2);
WAARDEBEWERKINGSMETHODE_CODE = cell2mat(rawNumericColumns(:, 1));

% Clear variables
clearvars filename delimiter startRow formatSpec fileID dataArray ans raw col numericData rawData row regexstr result numbers invalidThousandsSeparator thousandsRegExp me rawNumericColumns rawCellColumns R;


%% 3) Convert to matlab time and values
nx = size(WAARDEBEWERKINGSMETHODE_OMSCHRIJVING, 1);
clear dates
for ii = 1:nx
    time_y      = str2double(COMPARTIMENT_CODE{ii,1}(7:end));
    time_mo     = str2double(COMPARTIMENT_CODE{ii,1}(4:5));
    time_d      = str2double(COMPARTIMENT_CODE{ii,1}(1:2));
    time_h      = str2double(WAARDEBEWERKINGSMETHODE_OMSCHRIJVING{ii,1}(1:2));
    time_mi     = str2double(WAARDEBEWERKINGSMETHODE_OMSCHRIJVING{ii,1}(4:5));
    dates(ii)   = datenum(time_y, time_mo, time_d, time_h, time_mi, 0);
end
dates   = dates';
values  = WAARDEBEWERKINGSMETHODE_CODE;    

%% 4) Take at NaNs, no data, double
id          = find(values == 999999999);
values(id)  = NaN;

id          = isempty(values);
values(id)  = NaN;

id          = isempty(dates);
values(id)  = []; dates(id) = [];

[n, bin]            = histc(dates, unique(dates));
multiple            = find(n > 1);
values(multiple)    = [];
dates(multiple)     = [];

%% 5) sort the data
[dates id2] = sort(dates);
values      = values(id2);
