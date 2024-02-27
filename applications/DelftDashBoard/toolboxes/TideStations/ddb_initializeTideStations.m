function handles = ddb_initializeTideStations(handles, varargin)
%DDB_INITIALIZETIDESTATIONS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_initializeTideStations(handles, varargin)
%
%   Input:
%   handles  =
%   varargin =
%
%   Output:
%   handles  =
%
%   Example
%   ddb_initializeTideStations
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

% $Id: ddb_initializeTideStations.m 17406 2021-07-13 13:25:44Z ormondt $
% $Date: 2021-07-13 21:25:44 +0800 (Tue, 13 Jul 2021) $
% $Author: ormondt $
% $Revision: 17406 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/TideStations/ddb_initializeTideStations.m $
% $Keywords: $

%% When enabled on OpenDAP
% % Check xml-file for updates
% dr=handles.toolbox.tidestations.dataDir;
% flist = dir([dr '*.xml']);
% xmlfile = flist(1).name;
% url = ['http://opendap.deltares.nl/thredds/fileServer/opendap/deltares/delftdashboard/toolboxes/TideStations/' xmlfile];
% handles.toolbox.tidestations = ddb_getXmlData(dr,url,xmlfile);
% 
% % Update nc-files when necessary
% fld = fieldnames(handles.toolbox.tidestations);
% for ii=1:length(handles.toolbox.tidestations.(fld{1}))
%     if handles.toolbox.tidestations.(fld{1})(ii).update == 1
%         cstr = strsplit(handles.toolbox.tidestations.(fld{1})(ii).URL,'/');
%         urlwrite(handles.toolbox.tidestations.(fld{1})(ii).URL,[dr cstr{end}]);
%     end
% end
% 
% % Remaining code remains the same from flist = dir([dr '*.nc'])

%% For the time being...

ddb_getToolboxData(handles,handles.toolbox.tidestations.dataDir,'tidestations','TideStations');

dr=handles.toolbox.tidestations.dataDir;
lst=dir([dr '*.nc']);

handles.toolbox.tidestations.databases={''};

if isempty(lst)
    error('No databases for tide stations found!');
end

for i=1:length(lst)

    disp(['Loading tide database ' lst(i).name(1:end-3) ' ...']);
    fname=[dr lst(i).name(1:end-3) '.nc'];
    handles.toolbox.tidestations.database(i).longName=nc_attget(fname,nc_global,'title');
    handles.toolbox.tidestations.databases{i}=handles.toolbox.tidestations.database(i).longName;
    handles.toolbox.tidestations.database(i).shortName=lst(i).name(1:end-3);
    handles.toolbox.tidestations.database(i).x=nc_varget(fname,'lon');
    handles.toolbox.tidestations.database(i).y=nc_varget(fname,'lat');
    handles.toolbox.tidestations.database(i).xLoc=handles.toolbox.tidestations.database(i).x;
    handles.toolbox.tidestations.database(i).yLoc=handles.toolbox.tidestations.database(i).y;
    
    handles.toolbox.tidestations.database(i).coordinateSystem='WGS 84';
    handles.toolbox.tidestations.database(i).coordinateSystemType='geographic';
    
    str=nc_varget(fname,'components');
    str=str';
    for j=1:size(str,1)
        handles.toolbox.tidestations.database(i).components{j}=deblank(str(j,:));
    end
    
    str=nc_varget(fname,'stations');
    str=str';
    for j=1:size(str,1)
        handles.toolbox.tidestations.database(i).stationList{j}=deblank(str(j,:));
        % Short names
        name=deblank(str(j,:));
        name=strrep(name,' ','');
        name=strrep(name,'#','');
        name=strrep(name,'\','');
        name=strrep(name,'/','');
        name=strrep(name,'.','');
        name=strrep(name,',','');
        name=strrep(name,'(','');
        name=strrep(name,')','');
        name=name(double(name)<1000);
        handles.toolbox.tidestations.database(i).stationShortNames{j}=name;
    end
    
    str=nc_varget(fname,'idcodes');
    str=str';
    for j=1:size(str,1)
        handles.toolbox.tidestations.database(i).idCodes{j}=deblank(str(j,:));
    end

    handles.toolbox.tidestations.database(i).timezone=zeros(size(handles.toolbox.tidestations.database(i).x));
    try
        handles.toolbox.tidestations.database(i).timezone=nc_varget(fname,'timezone');
    end
    
end

handles.toolbox.tidestations.startTime=floor(now);
handles.toolbox.tidestations.stopTime=floor(now)+30;
handles.toolbox.tidestations.timeStep=30.0;
handles.toolbox.tidestations.activeDatabase=1;
handles.toolbox.tidestations.activeTideStation=1;
handles.toolbox.tidestations.tideStationHandle=[];
handles.toolbox.tidestations.activeTideStationHandle=[];

handles.toolbox.tidestations.components={''};
handles.toolbox.tidestations.amplitudes=0;
handles.toolbox.tidestations.phases=0;
handles.toolbox.tidestations.timeZone=0;
handles.toolbox.tidestations.verticalOffset=0;

handles.toolbox.tidestations.usestationid=0;
handles.toolbox.tidestations.usemaincomponents=0;

handles.toolbox.tidestations.tidestationshandle=[];

handles.toolbox.tidestations.showstationnames=1;
handles.toolbox.tidestations.stationlist={''};
handles.toolbox.tidestations.textstation='';

handles.toolbox.tidestations.polygonlength=0;
handles.toolbox.tidestations.polygonx=[];
handles.toolbox.tidestations.polygony=[];
handles.toolbox.tidestations.polygonhandle=[];

handles.toolbox.tidestations.tidesignalformat='tek';
handles.toolbox.tidestations.tidalcomponentsformat='mat';

handles.toolbox.tidestations.saseqx=1;
