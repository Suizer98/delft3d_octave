function ddb_ObservationStationsToolbox(varargin)
%DDB_OBSERVATIONSTATIONSTOOLBOX  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_ObservationStationsToolbox(varargin)
%
%   Input:
%   varargin =
%
%
%
%
%   Example
%   ddb_ObservationStationsToolbox
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

% $Id: ddb_ObservationStationsToolbox.m 12724 2016-05-12 15:18:38Z nederhof $
% $Date: 2016-05-12 23:18:38 +0800 (Thu, 12 May 2016) $
% $Author: nederhof $
% $Revision: 12724 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/ObservationStations/ddb_ObservationStationsToolbox.m $
% $Keywords: $

%%
if isempty(varargin)
    % New tab selected
    ddb_zoomOff;
    ddb_refreshScreen;
    handles=getHandles;
    ddb_plotObservationStations('activate');
    h=handles.toolbox.observationstations.observationstationshandle;
    if isempty(h)
        plotObservationStations;
        refreshObservations;
        refreshStationList;
    end
    gui_updateActiveTab;
else
    %Options selected
    opt=lower(varargin{1});
    switch opt
        case{'makeobservationpoints'}
            addObservationPoints;
        case{'selectobservationdatabase'}
            selectObservationDatabase;
        case{'selectobservationstation'}
            selectObservationStation;
        case{'selectparameter'}
            opt2=lower(varargin{2});
            selectParameter(opt2);
        case{'viewsignal'}
            viewObservationSignal;
        case{'exportsignal'}
            exportObservationSignal;
        case{'exportallsignals'}
            exportAllObservationSignals;
        case{'drawpolygon'}
            drawPolygon;
        case{'deletepolygon'}
            deletePolygon;
        case{'exportoptions'}
            editExportOptions;
        case{'selectstationlistoption'}
            refreshStationList;
            refreshStationText;
        case{'saveannotationfile'}
            saveAnnotationFile;
    end
end

%%
function selectObservationDatabase

handles=getHandles;

% First delete existing stations
try
    delete(handles.toolbox.observationstations.observationstationshandle);
end

handles.toolbox.observationstations.activeobservationstation=handles.toolbox.observationstations.database(handles.toolbox.observationstations.activedatabase).activeobservationstation;

handles.toolbox.observationstations.observationstationshandle=[];

% xl=handles.screenParameters.xLim;
% yl=handles.screenParameters.yLim;
% if (xl(2)-xl(1))*(yl(2)-yl(1))<25   
%     k=handles.toolbox.observationstations.activedatabase;    
%     database=ddb_ObservationStations_usgs('readdatabase','xlim',xl,'ylim',yl);
%     fld=fieldnames(database);
%     for j=1:length(fld)
%         handles.toolbox.observationstations.database(k).(fld{j})=database.(fld{j});
%     end
%     handles.toolbox.observationstations.databaselongnames{k}=database.longname;
%     handles.toolbox.observationstations.database(k).activeobservationstation=1;
% end

setHandles(handles);

refreshStationList;
plotObservationStations;
selectObservationStation;

%%
function refreshStationList

handles=getHandles;
if handles.toolbox.observationstations.showstationnames
    handles.toolbox.observationstations.stationlist=handles.toolbox.observationstations.database(handles.toolbox.observationstations.activedatabase).stationnames;
else
    handles.toolbox.observationstations.stationlist=handles.toolbox.observationstations.database(handles.toolbox.observationstations.activedatabase).stationids;
end
setHandles(handles);

%%
function addObservationPoints

handles=getHandles;
model=handles.activeModel.name;
switch lower(model)
    case{'delft3dflow'}
        if isempty(handles.model.delft3dflow.domain(ad).grdFile)
            ddb_giveWarning('text','Please first generate or load a model grid!');
        else
            [filename, pathname, filterindex] = uiputfile('*.obs', 'Observation File Name',[handles.model.delft3dflow.domain(ad).attName '.obs']);
            if pathname~=0
                ddb_Delft3DFLOW_addObservationStations;
                handles=getHandles;
                handles.model.delft3dflow.domain(ad).obsFile=filename;
                ddb_saveObsFile(handles,ad);
                setHandles(handles);
            end
        end
    case{'dflowfm'}
            [filename, pathname, filterindex] = uiputfile('*.xyn', 'Observation File Name',[handles.model.dflowfm.domain(ad).attName '.xyn']);
            if pathname~=0
                ddb_DFlowFM_addObservationStations;
                handles=getHandles;
                handles.model.dflowfm.domain(ad).obsfile=filename;
                ddb_DFlowFM_saveObsFile(handles,ad);
                setHandles(handles);
            end
    otherwise
        ddb_giveWarning('text',['Sorry, generation of observation points from stations is not supported for ' handles.model.(model).longName ' ...']);
end

%%
function selectObservationStationFromMap(h,nr)
handles=getHandles;
handles.toolbox.observationstations.activeobservationstation=nr;    
setHandles(handles);    
selectObservationStation;
gui_updateActiveTab;

%%
function selectObservationStation

handles=getHandles;

iac=handles.toolbox.observationstations.activedatabase;

istat=handles.toolbox.observationstations.activeobservationstation;
gui_pointcloud(handles.toolbox.observationstations.observationstationshandle,'change','activepoint',istat);

handles.toolbox.observationstations.database(iac).activeobservationstation=istat;

handles.toolbox.observationstations.activeparameter=1;
parameters=handles.toolbox.observationstations.database(iac).parameters(istat);
for j=1:length(parameters.name)
    if parameters.status(j)
        handles.toolbox.observationstations.activeparameter=j;
        break
    end
end

setHandles(handles);

refreshObservations;

refreshStationText;

%%
function refreshStationText

handles=getHandles;

iac=handles.toolbox.observationstations.activedatabase;
istat=handles.toolbox.observationstations.activeobservationstation;

if handles.toolbox.observationstations.showstationnames
    handles.toolbox.observationstations.textstation=['Station ID : ' handles.toolbox.observationstations.database(iac).stationids{istat}];
else
    handles.toolbox.observationstations.textstation=['Station Name : ' handles.toolbox.observationstations.database(iac).stationnames{istat}];
end

setHandles(handles);

%%
function plotObservationStations

handles=getHandles;

iac=handles.toolbox.observationstations.activedatabase; 

x=handles.toolbox.observationstations.database(iac).xlocal;
y=handles.toolbox.observationstations.database(iac).ylocal;

[x,y]=ddb_coordConvert(x,y,handles.toolbox.observationstations.database(iac).coordinatesystem,handles.screenParameters.coordinateSystem);

handles.toolbox.observationstations.database(iac).xLocLocal=x;
handles.toolbox.observationstations.database(iac).yLocLocal=y;

xy=[x' y'];

h=gui_pointcloud('plot','xy',xy,'selectcallback',@selectObservationStationFromMap,'tag','observationstations', ...
    'MarkerSize',5,'MarkerEdgeColor','k','MarkerFaceColor','y', ...
    'ActiveMarkerSize',6,'ActiveMarkerEdgeColor','k','ActiveMarkerFaceColor','r', ...
    'activepoint',handles.toolbox.observationstations.activeobservationstation);

handles.toolbox.observationstations.observationstationshandle=h;

setHandles(handles);

%%
function refreshObservations

handles=getHandles;
iac=handles.toolbox.observationstations.activedatabase;
ii=handles.toolbox.observationstations.activeobservationstation;
parameters=handles.toolbox.observationstations.database(iac).parameters(ii);
for j=1:length(parameters.name)
    iradio=num2str(j,'%0.2i');
    handles.toolbox.observationstations.(['radio' iradio]).value=0;
    handles.toolbox.observationstations.(['radio' iradio]).text=parameters.name{j};
    if parameters.status(j)
        handles.toolbox.observationstations.(['radio' iradio]).enable=1;
    else
        handles.toolbox.observationstations.(['radio' iradio]).enable=0;
    end
end
for j=length(parameters.name)+1:14
    iradio=num2str(j,'%0.2i');
    handles.toolbox.observationstations.(['radio' iradio]).value=-1;
    handles.toolbox.observationstations.(['radio' iradio]).text=['radio' iradio];
    handles.toolbox.observationstations.(['radio' iradio]).enable=0;
end

iradio=num2str(handles.toolbox.observationstations.activeparameter,'%0.2i');
handles.toolbox.observationstations.(['radio' iradio]).value=1;

setHandles(handles);

%%
function selectParameter(opt)

handles=getHandles;

iopt=str2double(opt);
handles.toolbox.observationstations.activeparameter=iopt;

for j=1:14
    iradio=num2str(j,'%0.2i');
    if handles.toolbox.observationstations.(['radio' iradio]).value==1
        handles.toolbox.observationstations.(['radio' iradio]).value=0;
    end
end
iradio=num2str(iopt,'%0.2i');
handles.toolbox.observationstations.(['radio' iradio]).value=1;

setHandles(handles);

%%
function drawPolygon

handles=getHandles;

ddb_zoomOff;

h=findobj(gcf,'Tag','observationspolygon');
if ~isempty(h)
    delete(h);
end

handles.toolbox.observationstations.polygonx=[];
handles.toolbox.observationstations.polygony=[];
handles.toolbox.observationstations.polygonlength=0;

handles.toolbox.observationstations.polygonhandle=gui_polyline('draw','tag','observationspolygon','marker','o', ...
    'createcallback',@createPolygon,'changecallback',@changePolygon, ...
    'closed',1);

setHandles(handles);

%%
function createPolygon(h,x,y)
handles=getHandles;
handles.toolbox.observationstations.polygonhandle=h;
handles.toolbox.observationstations.polygonx=x;
handles.toolbox.observationstations.polygony=y;
handles.toolbox.observationstations.polygonlength=length(x);
setHandles(handles);
gui_updateActiveTab;

%%
function deletePolygon
handles=getHandles;
handles.toolbox.observationstations.polygonx=[];
handles.toolbox.observationstations.polygony=[];
handles.toolbox.observationstations.polygonlength=0;
h=findobj(gcf,'Tag','observationspolygon');
if ~isempty(h)
    delete(h);
end
setHandles(handles);

%%
function changePolygon(h,x,y,varargin)
handles=getHandles;
handles.toolbox.observationstations.polygonx=x;
handles.toolbox.observationstations.polygony=y;
handles.toolbox.observationstations.polygonlength=length(x);
setHandles(handles);

%%
function data=downloadObservations(iac,istation,ipar,iquiet)

% Start
handles=getHandles;

% Get settings
t0=handles.toolbox.observationstations.starttime;
t1=handles.toolbox.observationstations.stoptime;
idcode=handles.toolbox.observationstations.database(iac).stationids{istation};
datum=handles.toolbox.observationstations.database(iac).datum;
subset=handles.toolbox.observationstations.database(iac).subset;
timezone=handles.toolbox.observationstations.database(iac).timezone;

% Download
data=[];
if ~isfield(handles.toolbox.observationstations,'downloadeddatasetnames')
    handles.toolbox.observationstations.downloadeddatasetnames=[];
end
if ~isfield(handles.toolbox.observationstations,'downloadeddatasets')
    handles.toolbox.observationstations.downloadeddatasets=[];
end

%% Try to download
if ~strcmpi(handles.toolbox.observationstations.database(iac).name, 'USGS')
    
    %% NON-USGS data
    try    
    if ~iquiet
        wb = waitbox(['Downloading ' handles.toolbox.observationstations.database(iac).parameters(istation).name{ipar} ' from station ' handles.toolbox.observationstations.database(iac).stationnames{istation}]);
    end

    parameter=handles.toolbox.observationstations.database(iac).parameters(istation).name{ipar};
    
    downloadeddatasetname=[parameter '.' idcode '.' handles.toolbox.observationstations.database(iac).name '.' ...
        datestr(t0,'yyyymmddHHMMSS') '.' datestr(t1,'yyyymmddHHMMSS') '.' ...
        handles.toolbox.observationstations.database(iac).datum '.' handles.toolbox.observationstations.database(iac).subset '.' handles.toolbox.observationstations.database(iac).timezone];
    
    ii=strmatch(downloadeddatasetname,handles.toolbox.observationstations.downloadeddatasetnames,'exact');
    
    if isempty(ii)
        % data not yet there       
        f=handles.toolbox.observationstations.database(iac).callback;
        % Now download
        data=feval(f,'getobservations','tstart',t0,'tstop',t1,'id',idcode,'parameter',parameter,'datum',datum,'subset',subset,'timezone',timezone);        
        if ~isempty(data)
            n=length(handles.toolbox.observationstations.downloadeddatasets)+1;
            if isempty(data.stationname)
                data.stationname=handles.toolbox.observationstations.database(iac).stationnames{istation};
            end
            handles.toolbox.observationstations.downloadeddatasets(n).downloadeddataset=data;
            handles.toolbox.observationstations.downloadeddatasetnames{n}=downloadeddatasetname;
        end        
    else
        % data already there
        data=handles.toolbox.observationstations.downloadeddatasets(ii).downloadeddataset;

    end
    
    if ~iquiet
        close(wb);
    end
    catch
    if ~iquiet
        close(wb);    
    end
    end

else
    
    try
        
    %% USGS data
    if ~iquiet
        wb = waitbox(['Downloading ' handles.toolbox.observationstations.database(iac).parameters(istation).name{ipar} ' from station ' handles.toolbox.observationstations.database(iac).stationnames{istation}]);
    end
    
    usgs_data = load([handles.toolbox.observationstations.dataDir, '\usgs.mat']);
    SiteNo    = usgs_data.s.stationids(istation); SiteNo = SiteNo{1,1}; SiteNo = SiteNo{1,1};
    tstart    = datestr(t0, 'yyyy-mm-dd');
    tend      = datestr(t1, 'yyyy-mm-dd');
    Dir       = handles.toolbox.observationstations.dataDir;

    % Load river data for Tijuana
    if ipar == 1;
    ParCode = {'00060'};                % Discharge
    else
    ParCode = {'00065'};                % Gauge height
    end
    data_usgs = nwi_usgs_read(SiteNo,tstart,tend,ParCode,Dir);
    
    % Finalize
    data.stationid  = SiteNo;
    data.stationname = usgs_data.s.stationnames(istation); data.stationname = data.stationname{1,1};
    data.lat        = usgs_data.s.x(istation);
    data.lon        = usgs_data.s.y(istation);
    data.source     = data_usgs.agency_cd(1,:);
    data.stationid  = SiteNo;
    
    if strcmpi(ParCode, '00065')
        data.parameters.parameter.name     = 'Gage height';
        data.parameters.parameter.dbname   = 'Gage height';
        try
        data.parameters.parameter.val =  data_usgs.par_01_00065_00003*0.3048; % feet to  meter
        catch
        data.parameters.parameter.val =  data_usgs.par_02_00065_00003*0.3048; % feet to  meter
        end
        data.parameters.parameter.unit      = 'meter';

    else
        data.parameters.parameter.name     = 'Discharge';
        data.parameters.parameter.dbname   = 'Discharge';
        try
        data.parameters.parameter.val =  data_usgs.par_01_00060_00003*0.0283168466; % cubic feet to meter
        catch
        data.parameters.parameter.val =  data_usgs.par_02_00060_00003*0.0283168466; % cubic feet to meter
        end
        data.parameters.parameter.unit     = 'cubic meter per second';
    end
    data.parameters.parameter.time =  data_usgs.datenum;
    data.parameters.parameter.size = zeros(1,5);
    data.parameters.parameter.size(1) = length(data_usgs.datenum);
    data.timezone = 'GMT';
    
    if ~iquiet
        close(wb);
    end
  
    catch
    if ~iquiet
        data = [];
        close(wb);    
    end
    end
end

setHandles(handles);

%%
function viewObservationSignal

handles=getHandles;

iac=handles.toolbox.observationstations.activedatabase;
istation=handles.toolbox.observationstations.activeobservationstation;
ipar=handles.toolbox.observationstations.activeparameter;

data=downloadObservations(iac,istation,ipar,0);

if ~isempty(data)
    ddb_plotTimeSeries2('makefigure',data);
else
    ddb_giveWarning('text','Sorry, there is no data available for this time period ...');
end

%%
function exportObservationSignal

handles=getHandles;

iac=handles.toolbox.observationstations.activedatabase;
istation=handles.toolbox.observationstations.activeobservationstation;
ipar=handles.toolbox.observationstations.activeparameter;
t0=handles.toolbox.observationstations.starttime;
t1=handles.toolbox.observationstations.stoptime;

% Download the data
data=downloadObservations(iac,istation,ipar,0);

if isempty(data)
    ddb_giveWarning('text','Sorry, there is no data available for this time period ...');
    return
end

parameter=handles.toolbox.observationstations.database(iac).parameters(istation).name{ipar};

parameter(parameter==' ')='';
fname=parameter;
if handles.toolbox.observationstations.includename
    name=lower(handles.toolbox.observationstations.database(iac).stationnames{istation});
    name=justletters(lower(name));
    fname=[fname '.' name];
end
if handles.toolbox.observationstations.includeid
    idcode=handles.toolbox.observationstations.database(iac).stationids{istation};
    fname=[fname '.' idcode];
end
if handles.toolbox.observationstations.includedatabase
    fname=[fname '.' handles.toolbox.observationstations.database(iac).name];
end
if handles.toolbox.observationstations.includetimestamp
    fname=[fname '.' datestr(t0,'yyyymmdd') '.' datestr(t1,'yyyymmdd')];
end

if ~isempty(data)
    switch(handles.toolbox.observationstations.exporttype)
        case{'mat'}
            [filename, pathname, filterindex] = uiputfile('*.mat', 'Select Mat File',[fname '.mat']);
            if filename==0
                return
            end
            filename=[pathname filename];
            save(filename,'-struct','data');
        case{'tek'}           
            [filename, pathname, filterindex] = uiputfile('*.tek', 'Select Tekal File',[fname '.tek']);
            if filename==0
                return
            end
            filename=[pathname filename];
            exportTEK2(data,filename);            
    end
end

%%
function exportAllObservationSignals

handles=getHandles;

iac=handles.toolbox.observationstations.activedatabase;

x=handles.toolbox.observationstations.database(iac).xLocLocal;
y=handles.toolbox.observationstations.database(iac).yLocLocal;

inpol=inpolygon(x,y,handles.toolbox.observationstations.polygonx,handles.toolbox.observationstations.polygony);

t0=handles.toolbox.observationstations.starttime;
t1=handles.toolbox.observationstations.stoptime;

wb = awaitbar(0,'Downloading data ...');

% Count how many datasets there are
nrdatasets=0;
for istation=1:length(inpol)
    if inpol(istation)
        if handles.toolbox.observationstations.exportallparameters
            nrdatasets=nrdatasets+length(handles.toolbox.observationstations.database(iac).parameters(istation).name);
        else
            % Find matching parameter for this station
            ipar0=handles.toolbox.observationstations.activeparameter;
            istat0=handles.toolbox.observationstations.activeobservationstation;
            iparmatch=strmatch(handles.toolbox.observationstations.database(iac).parameters(istat0).name{ipar0},handles.toolbox.observationstations.database(iac).parameters(istation).name,'exact');
            if ~isempty(iparmatch)
                nrdatasets=nrdatasets+1;
            end
        end        
    end
end

nr=0;

[hh,abort2]=awaitbar(0.001,wb,'Downloading data ...');

errorstrings=[];
for istation=1:length(inpol)
    
    
    
    % Loop through stations
    
    if inpol(istation)
        
        ok=1;
        if handles.toolbox.observationstations.exportallparameters
            ipar1=1;
            ipar2=length(handles.toolbox.observationstations.database(iac).parameters(istation).name);
        else
            % Find matching parameter for this station
            ipar0=handles.toolbox.observationstations.activeparameter;
            istat0=handles.toolbox.observationstations.activeobservationstation;
            iparmatch=strmatch(handles.toolbox.observationstations.database(iac).parameters(istat0).name{ipar0},handles.toolbox.observationstations.database(iac).parameters(istation).name,'exact');
            if isempty(iparmatch)
                ok=0;
            else
                ipar1=iparmatch;
                ipar2=ipar1;
            end
        end
        
        if ok
            for ipar=ipar1:ipar2
                
                % Loop through parameters
                nr=nr+1;
                
                parstr=handles.toolbox.observationstations.database(iac).parameters(istation).name{ipar};
                ststr=handles.toolbox.observationstations.database(iac).stationnames{istation};
                str=['Downloading ' parstr ' from ' ststr ' - dataset ' num2str(nr) ' of ' ...
                    num2str(nrdatasets) ' ...'];
                
                [hh,abort2]=awaitbar(nr/nrdatasets,wb,str);
                
                if abort2 % Abort the process by clicking abort button
                    break;
                end;
                if isempty(hh); % Break the process when closing the figure
                    break;
                end;
                
                data=downloadObservations(iac,istation,ipar,1);
                
                if isempty(data)
                    
                    n=length(errorstrings);
                    errorstrings{n+1}=[handles.toolbox.observationstations.database(iac).stationnames{istation} ' - ' handles.toolbox.observationstations.database(iac).parameters(istation).name{ipar}];
                    
                else
                    
                    parameter=handles.toolbox.observationstations.database(iac).parameters(istation).name{ipar};
                    
                    parameter(parameter==' ')='';
                    fname=parameter;
                    if handles.toolbox.observationstations.includename
                        name=lower(handles.toolbox.observationstations.database(iac).stationnames{istation});
                        name=justletters(lower(name));
                        fname=[fname '.' name];
                    end
                    if handles.toolbox.observationstations.includeid
                        idcode=handles.toolbox.observationstations.database(iac).stationids{istation};
                        fname=[fname '.' idcode];
                    end
                    if handles.toolbox.observationstations.includedatabase
                        fname=[fname '.' handles.toolbox.observationstations.database(iac).name];
                    end
                    if handles.toolbox.observationstations.includetimestamp
                        fname=[fname '.' datestr(t0,'yyyymmdd') '.' datestr(t1,'yyyymmdd')];
                    end
                    
                    if ~isempty(data)
                        switch(handles.toolbox.observationstations.exporttype)
                            case{'mat'}
                                filename=[fname '.mat'];
                                save(filename,'-struct','data');
                            case{'tek'}
                                filename=[fname '.tek'];
                                exportTEK2(data,filename);
                        end
                    end
                end
            end
        end
    end
    if abort2 % Abort the process by clicking abort button
        break;
    end;
    if isempty(hh); % Break the process when closing the figure
        break;
    end;
end

% close waitbar
if ~isempty(hh)
    close(wb);
end

if ~isempty(errorstrings)
    h.errorstrings=errorstrings;
    h.dummy=1;
    xmldir=handles.toolbox.observationstations.xmlDir;
    xmlfile='observationstations.showerrors.xml';    
    [h,ok]=gui_newWindow(h,'xmldir',xmldir,'xmlfile',xmlfile,'iconfile',[handles.settingsDir filesep 'icons' filesep 'deltares.gif']);    
end

%%
function saveAnnotationFile

handles=getHandles;

[filename, pathname, filterindex] = uiputfile('*.ann', 'Select Annotation File','');
if filename==0
    return
end
filename=[pathname filename];

iac=handles.toolbox.observationstations.activedatabase;

x=handles.toolbox.observationstations.database(iac).xLocLocal;
y=handles.toolbox.observationstations.database(iac).yLocLocal;

inpol=inpolygon(x,y,handles.toolbox.observationstations.polygonx,handles.toolbox.observationstations.polygony);

switch lower(handles.screenParameters.coordinateSystem.type)
    case{'geographic'}
        fmt='%11.6f %11.6f';
    otherwise
        fmt='%11.1f %11.1f';
end

fid=fopen(filename,'wt');
for ii=1:length(inpol)
    if inpol(ii)
        if handles.toolbox.observationstations.showstationnames
            name=handles.toolbox.observationstations.database(iac).stationnames{ii};
        else
            name=handles.toolbox.observationstations.database(iac).stationids{ii};
        end
        name=['"' name '"'];
        fprintf(fid,[fmt ' %s\n'],x(ii),y(ii),name);
    end
end
fclose(fid);

%%
function editExportOptions

handles=getHandles;

xmldir=handles.toolbox.observationstations.xmlDir;
xmlfile='toolbox.observationstations.exportoptions.xml';

h=handles.toolbox.observationstations;

[h,ok]=gui_newWindow(h,'xmldir',xmldir,'xmlfile',xmlfile,'iconfile',[handles.settingsDir filesep 'icons' filesep 'deltares.gif']);

if ok
    
    handles.toolbox.observationstations=h;
    
    setHandles(handles);

end
