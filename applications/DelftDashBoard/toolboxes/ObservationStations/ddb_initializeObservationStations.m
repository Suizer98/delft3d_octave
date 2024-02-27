function handles = ddb_initializeObservationStations(handles, varargin)
%DDB_INITIALIZEOBSERVATIONSTATIONS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_initializeObservationStations(handles, varargin)
%
%   Input:
%   handles  =
%   varargin =
%
%   Output:
%   handles  =
%
%   Example
%   ddb_initializeObservationStations
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

% $Id: ddb_initializeObservationStations.m 17406 2021-07-13 13:25:44Z ormondt $
% $Date: 2021-07-13 21:25:44 +0800 (Tue, 13 Jul 2021) $
% $Author: ormondt $
% $Revision: 17406 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/ObservationStations/ddb_initializeObservationStations.m $
% $Keywords: $

%%

ddb_getToolboxData(handles,handles.toolbox.observationstations.dataDir,'observationstations','ObservationStations');

dr=handles.toolbox.observationstations.dataDir;

% JV: Added case-insensitive check for xml file
tmpFiles = dir(dr);
index = find(strcmpi({tmpFiles.name},'ObservationStations.xml') == 1, 1);
s=xml2struct([dr tmpFiles(index).name],'structuretype','supershort');

% s=xml2struct([dr 'ObservationStations.xml'],'structuretype','supershort');

for k=1:length(s.database)

    f=str2func(s.database(k).callback);

    handles.toolbox.observationstations.database(k).callback=f;

    if ~isempty(s.database(k).file)
        database=feval(f,'readdatabase','inputfile',[dr s.database(k).file]);
        fld=fieldnames(database);
        for j=1:length(fld)
            handles.toolbox.observationstations.database(k).(fld{j})=database.(fld{j});
        end
    end
    handles.toolbox.observationstations.databaselongnames{k}=s.database(k).longname;
    handles.toolbox.observationstations.database(k).activeobservationstation=1;
    
end

handles.toolbox.observationstations.starttime=floor(now)-10;
handles.toolbox.observationstations.stoptime=floor(now)-1;
handles.toolbox.observationstations.timestep=10.0;

handles.toolbox.observationstations.activedatabase=1;
handles.toolbox.observationstations.activeobservationstation=1;

handles.toolbox.observationstations.observationstationshandle=[];

handles.toolbox.observationstations.activeparameter=1;

for jj=1:15
    handles.toolbox.observationstations.(['radio' num2str(jj,'%0.2i')]).value=0;
    handles.toolbox.observationstations.(['radio' num2str(jj,'%0.2i')]).enable=0;
    handles.toolbox.observationstations.(['radio' num2str(jj,'%0.2i')]).text='';
end

handles.toolbox.observationstations.downloadeddatasets=[];
handles.toolbox.observationstations.downloadeddatanames=[];

handles.toolbox.observationstations.polygonlength=0;
handles.toolbox.observationstations.exporttype='mat';

% Export options
handles.toolbox.observationstations.includename=1;
handles.toolbox.observationstations.includeid=0;
handles.toolbox.observationstations.includedatabase=0;
handles.toolbox.observationstations.includetimestamp=0;
handles.toolbox.observationstations.exportallparameters=0;

handles.toolbox.observationstations.showstationnames=1;
handles.toolbox.observationstations.showstationids=0;
handles.toolbox.observationstations.stationlist={''};
handles.toolbox.observationstations.textstation='';
