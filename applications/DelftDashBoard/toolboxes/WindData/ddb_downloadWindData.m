function handles = ddb_downloadWindData(handles, startDate, numOfDays)
%DDB_DOWNLOADWINDDATA  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_downloadWindData(handles, startDate, numOfDays)
%
%   Input:
%   handles   =
%   startDate =
%   numOfDays =
%
%   Output:
%   handles   =
%
%   Example
%   ddb_downloadWindData
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
ii=get(handles.GUIHandles.ListStations,'Value');
stations=handles.Toolbox(tb).Input.WindDataStations.id;
if isempty(stations)
    giveWarning([],'No station selected!');
    return
end
outputFile=[getenv('temp') filesep 'WindData_' stations{ii} '.txt'];

switch handles.Toolbox(tb).Input.Source
    case 'Weather Underground'
        stationID = ['/airport/' stations{ii} '/'];
        windData=ddb_getOnlineWindDataEngine(stationID,startDate,numOfDays,outputFile,'No');
    case 'NOAA'
        windData=ddb_getNOAAWindData(stations{ii},startDate,numOfDays,outputFile);
end
if ~isempty(windData)
    handles.Toolbox(tb).Input.windData=windData;
end

