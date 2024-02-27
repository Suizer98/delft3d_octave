function varargout = ddb_WindDataToolbox(varargin)
%DDB_WINDDATATOOLBOX  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = ddb_WindDataToolbox(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   ddb_WindDataToolbox
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
handles=getHandles;

ddb_plotWindData(handles,'activate');

uipanel('Title','Wind Data','Units','pixels','Position',[50 20 960 160],'Tag','UIControl');
uipanel('Title','Analyse Wind Data','Units','pixels','Position',[550 30 450 140],'Tag','UIControl');

handles.GUIHandles.PopupSource       = uicontrol(gcf,'Style','popupmenu','String',{'Weather Underground','NOAA'},'Position',[230 140 150 20],'BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.ListStations      = uicontrol(gcf,'Style','listbox','String','','Position',[60 40 160 120],'BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.PushUpdateStations= uicontrol(gcf,'Style','pushbutton','String','Update Stations',      'Position',[230 115 150 20],'Tag','UIControl');
handles.GUIHandles.PushView          = uicontrol(gcf,'Style','pushbutton','String','Download/View Data',      'Position',[230 90 150 20],'Tag','UIControl');
handles.GUIHandles.PushExportData    = uicontrol(gcf,'Style','pushbutton','String','Export Data',      'Position',[230  65 150 20],'Tag','UIControl');
handles.GUIHandles.PushUseInModel    = uicontrol(gcf,'Style','pushbutton','String','Use In Model',      'Position',[230  40 150 20],'Tag','UIControl');
handles.GUIHandles.TextStartTime     = uicontrol(gcf,'Style','text','String','Start Date',         'Position',    [380 136  80 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.TextStopTime      = uicontrol(gcf,'Style','text','String','Stop Date',          'Position',    [380 111  80 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.EditStartTime     = uicontrol(gcf,'Style','edit','String',datestr(handles.Toolbox(tb).Input.StartTime,29),'Position',[465 140 65 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditStopTime      = uicontrol(gcf,'Style','edit','String',datestr(handles.Toolbox(tb).Input.StopTime,29), 'Position',[465 115 65 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');

handles.GUIHandles.PushAnalyzeData   = uicontrol(gcf,'Style','pushbutton','String','Analyze data',      'Position',[560 125 150 20],'Tag','UIControl');
handles.GUIHandles.PushUseAnalyzed   = uicontrol(gcf,'Style','pushbutton','String','Use Selected Set In Model',      'Position',[560 100 150 20],'Tag','UIControl');
handles.GUIHandles.ListAnalyzedData  = uicontrol(gcf,'Style','listbox','String','','Position',[720 40 270 120],'Tag','UIControl');

set(handles.GUIHandles.PopupSource,       'CallBack',{@PopupSource_Callback});
set(handles.GUIHandles.ListStations,      'CallBack',{@ListStations_Callback});
set(handles.GUIHandles.PushUpdateStations,'CallBack',{@PushUpdateStations_Callback});
set(handles.GUIHandles.PushView,          'CallBack',{@PushViewData_Callback});
set(handles.GUIHandles.PushExportData,    'Callback',{@PushExportData_Callback});
set(handles.GUIHandles.PushUseInModel,    'Callback',{@PushUseInModel_Callback});
set(handles.GUIHandles.EditStopTime,      'Callback',{@EditStopTime_Callback});
set(handles.GUIHandles.EditStartTime,      'Callback',{@EditStartTime_Callback});

set(handles.GUIHandles.PushAnalyzeData,   'Callback',{@PushAnalyzeData_Callback});
set(handles.GUIHandles.PushUseAnalyzed,   'Callback',{@PushUseAnalyzed_Callback});

if isempty(handles.Toolbox(tb).Input.WindDataStations.xy)
    handles=ddb_findStations(handles,tb);
    handles.GUIData.ActiveWindDataStation=1;
end

SetUIBackgroundColors;
setHandles(handles);
RefreshWindData(handles);

%%
function PopupSource_Callback(hObject,eventdata)

handles=getHandles;

ii=get(hObject,'Value');
sources=get(hObject,'String');
if strcmp(handles.Toolbox(tb).Input.Source,sources{ii})
    return; % no change of source, so return
end
handles.Toolbox(tb).Input.Source=sources{ii};

handles.Toolbox(tb).Input.windData=[]; % delete downloaded data
handles=ddb_findStations(handles,tb); % download new station locations
handles.GUIData.ActiveWindDataStation=1;

setHandles(handles);
RefreshWindData(handles);

%%
function PushViewData_Callback(hObject,eventdata)

handles=getHandles;

if isempty(handles.Toolbox(tb).Input.windData)
    startDate=handles.Toolbox(tb).Input.StartTime;
    stopDate=handles.Toolbox(tb).Input.StopTime;
    numOfDays=stopDate-startDate;
    handles=ddb_downloadWindData(handles,startDate,numOfDays);
end

setHandles(handles);
RefreshWindData(handles);

ddb_makeWindDataPlot(handles);

%%
function ListStations_Callback(hObject,eventdata)

handles=getHandles;


ii=get(hObject,'Value');
handles.GUIData.ActiveWindDataStation=ii;
handles.Toolbox(tb).Input.windData=[]; % delete downloaded data

setHandles(handles);
RefreshWindData(handles);

%%
function PushUpdateStations_Callback(hObject,eventdata)
handles=getHandles;

handles=ddb_findStations(handles,tb);
handles.GUIData.ActiveWindDataStation=1;

setHandles(handles);
RefreshWindData(handles);

%%
function EditStartTime_Callback(hObject,eventdata)
handles=getHandles;

handles.Toolbox(tb).Input.StartTime=datenum(get(hObject,'String'),'yyyy-mm-dd');
handles.Toolbox(tb).Input.windData=[]; % delete downloaded data

setHandles(handles);
RefreshWindData(handles);

%%
function EditStopTime_Callback(hObject,eventdata)
handles=getHandles;

handles.Toolbox(tb).Input.StopTime=datenum(get(hObject,'String'),'yyyy-mm-dd');
handles.Toolbox(tb).Input.windData=[]; % delete downloaded data

setHandles(handles);
RefreshWindData(handles);

%%
function PushExportData_Callback(hObject,eventdata)
handles=getHandles;

if isempty(handles.Toolbox(tb).Input.windData)
    startDate=handles.Toolbox(tb).Input.StartTime;
    stopDate=handles.Toolbox(tb).Input.StopTime;
    numOfDays=stopDate-startDate;
    handles=ddb_downloadWindData(handles,startDate,numOfDays);
end

ii=get(handles.GUIHandles.ListStations,'Value');
station=handles.Toolbox(tb).Input.WindDataStations.name{ii};
outputFile=[pwd filesep 'windData_' station '.tek'];

if ~isempty(handles.Toolbox(tb).Input.windData)
    Comments={'* column 1 : Date','* column 2 : Time','* column 3 : Wind Speed [m/s]','* column 4 : Wind Direction [deg N]','* column 5 : Air Pressure [hPa]'};
    exportTEK(handles.Toolbox(tb).Input.windData(:,2:4),handles.Toolbox(tb).Input.windData(:,1),outputFile,station,Comments);
else
    giveWarning([],'No data available for this station and period');
end

setHandles(handles);

%%
function PushUseInModel_Callback(hObject,eventdata)
handles=getHandles;

id=handles.ActiveDomain;
t0=floor(handles.Model(handles.ActiveModel.Nr).Input(id).StartTime);
t1=ceil(handles.Model(handles.ActiveModel.Nr).Input(id).StopTime);
numOfDays=t1-t0;
handles=ddb_downloadWindData(handles,t0,numOfDays);

if ~isempty(handles.Toolbox(tb).Input.windData)
    f=str2func(['UseWindData' handles.Model(handles.ActiveModel.Nr).Name]);
    try
        handles=feval(f,handles,handles.ActiveDomain,0,'ddb_test');
    catch
        ddb_giveWarning('text',['Use of downloaded wind data not supported for ' handles.Model(handles.ActiveModel.Nr).LongName]);
        return
    end
    handles=feval(f,handles,id,handles.Toolbox(tb).Input.windData(:,1:3));
else
    giveWarning([],'No data available for this station and period');
end

% clear the downloaded data immediately, because it probably does not match the
% toolbox start and stop time!
handles.Toolbox(tb).Input.windData=[];
setHandles(handles);

%%
function PushAnalyzeData_Callback(hObject,eventdata)
handles=getHandles;

ii=get(handles.GUIHandles.ListStations,'Value');
station=handles.Toolbox(tb).Input.WindDataStations.name{ii};
windData=handles.Toolbox(tb).Input.windData;

fig=MakeNewWindow('Analyzed Wind Data',[600 400],[handles.SettingsDir filesep 'icons' filesep 'deltares.gif']);
set(fig,'renderer','painters');
figure(fig);
[hS,hD]=ddb_windAnalyzer(windData,'Daily');
md_paper('a4p','wl',{strvcat(['Daily variation of wind data at station:' station],['Period data: ' datestr(windData(1,1),1) ' - ' datestr(windData(end,1),1)],['Source: ' handles.Toolbox(tb).Input.Source]),'','','','',''});
handles.Toolbox(tb).Input.analyzedWindData(end+1).Name    = handles.Toolbox(tb).Input.WindDataStations.name{ii};
handles.Toolbox(tb).Input.analyzedWindData(end).ID        = handles.Toolbox(tb).Input.WindDataStations.id{ii};
handles.Toolbox(tb).Input.analyzedWindData(end).xy        = handles.Toolbox(tb).Input.WindDataStations.xy(ii,:);
handles.Toolbox(tb).Input.analyzedWindData(end).Source    = handles.Toolbox(tb).Input.Source;
handles.Toolbox(tb).Input.analyzedWindData(end).StartDate = windData(1,1);
handles.Toolbox(tb).Input.analyzedWindData(end).StopDate  = windData(end,1);
handles.Toolbox(tb).Input.analyzedWindData(end).Data      = [hS(2,:)' hD(2,:)'];
setHandles(handles);
RefreshWindData(handles);

%%
function PushUseAnalyzed_Callback(hObject,eventdata)
handles=getHandles;


ii=get(handles.GUIHandles.ListAnalyzedData,'Value');
windData=handles.Toolbox(tb).Input.analyzedWindData(ii).Data;

id=handles.ActiveDomain;
t0=floor(handles.Model(handles.ActiveModel.Nr).Input(id).StartTime);
t1=ceil(handles.Model(handles.ActiveModel.Nr).Input(id).StopTime);
numOfDays=t1-t0;

windData=[[t0:1/24:t1]' [repmat(windData,numOfDays,1); windData(1,:)]];

f=str2func(['UseWindData' handles.Model(handles.ActiveModel.Nr).Name]);
try
    handles=feval(f,handles,handles.ActiveDomain,0,'ddb_test');
catch
    ddb_giveWarning('text',['Use of downloaded wind data not supported for ' handles.Model(handles.ActiveModel.Nr).LongName]);
    return
end
handles=feval(f,handles,id,windData);
setHandles(handles);

%%
function handles=ddb_findStations(handles,tb)

ddb_plotWindData(handles,'delete');

minlon=handles.ScreenParameters.XLim(1);
maxlon=handles.ScreenParameters.XLim(2);
minlat=handles.ScreenParameters.YLim(1);
maxlat=handles.ScreenParameters.YLim(2);

switch handles.Toolbox(tb).Input.Source
    case 'Weather Underground'
        [x,y,id,name]=ddb_findWundergroundStations(maxlat,minlat,maxlon,minlon,'ICAO');
    case 'NOAA'
        [x,y,id,name]=ddb_findNOAAStations(maxlat,minlat,maxlon,minlon);
end
cs.Name='WGS 84';
cs.Type='Geographic';
[x,y]=ddb_coordConvert(x,y,cs,handles.ScreenParameters.CoordinateSystem);
handles.Toolbox(tb).Input.WindDataStations.xy=[x y];
handles.Toolbox(tb).Input.WindDataStations.id=[id];
handles.Toolbox(tb).Input.WindDataStations.name=[name];
handles.GUIData.ActiveWindDataStation=1;

%%
function plotStations(data,activeStation)

fig=findobj('Tag','MainWindow');
figure(fig);

h0=findobj(fig,'Tag','ActiveWindDataStation'); % delete previous plot
delete(h0);
h1=findobj(fig,'Tag','WindDataStations');
delete(h1);

x=data.WindDataStations.xy(:,1);
y=data.WindDataStations.xy(:,2);
z=zeros(size(x))+500;

plt=plot3(x,y,z,'o');hold on;
set(plt,'MarkerSize',5,'MarkerEdgeColor','k','MarkerFaceColor','y');
set(plt,'Tag','WindDataStations');
set(plt,'ButtonDownFcn',{@SelectWindDataStation});

plt=plot3(x(activeStation),y(activeStation),1000,'o');
set(plt,'MarkerSize',5,'MarkerEdgeColor','k','MarkerFaceColor','r','Tag','ActiveWindDataStation');

%%
function SelectWindDataStation(imagefig, varargins)
h=gco;
if strcmp(get(h,'Tag'),'WindDataStations')
    handles=getHandles;
    
    pos = get(gca, 'CurrentPoint');
    posx=pos(1,1);
    posy=pos(1,2);
    dxsq=(handles.Toolbox(tb).Input.WindDataStations.xy(:,1)-posx).^2;
    dysq=(handles.Toolbox(tb).Input.WindDataStations.xy(:,2)-posy).^2;
    dist=(dxsq+dysq).^0.5;
    [y,n]=min(dist);
    handles.Toolbox(tb).Input.windData=[]; % delete downloaded data
    handles.GUIData.ActiveWindDataStation=n;
    setHandles(handles);
    RefreshWindData(handles);
end

%%
function RefreshWindData(handles)

set(handles.GUIHandles.PopupSource,'Value',(find(strcmp(get(handles.GUIHandles.PopupSource,'String'),handles.Toolbox(tb).Input.Source))));

% update station list
set(handles.GUIHandles.ListStations,'String',handles.Toolbox(tb).Input.WindDataStations.name);
set(handles.GUIHandles.ListStations,'Value',handles.GUIData.ActiveWindDataStation);

% plot stations and active station
plotStations(handles.Toolbox(tb).Input,handles.GUIData.ActiveWindDataStation);

% enable or disable analyse buttons
if isempty(handles.Toolbox(tb).Input.windData)
    set(handles.GUIHandles.PushAnalyzeData,'Enable','off');
else
    set(handles.GUIHandles.PushAnalyzeData,'Enable','on');
end

% look for analyzed data sets
if isfield(handles.Toolbox(tb).Input.analyzedWindData,'Name')
    set(handles.GUIHandles.PushUseAnalyzed,'Enable','on');
    set(handles.GUIHandles.ListAnalyzedData,'String',...
        [strvcat({handles.Toolbox(tb).Input.analyzedWindData.Name}')... % station name
        repmat(' | ',length(handles.Toolbox(tb).Input.analyzedWindData),1) ...
        strvcat({datestr(floor([handles.Toolbox(tb).Input.analyzedWindData.StartDate]))}')... % start date of analyzed wind data
        repmat(' to ',length(handles.Toolbox(tb).Input.analyzedWindData),1)...
        strvcat({datestr(ceil([handles.Toolbox(tb).Input.analyzedWindData.StopDate]))}')... % stop date of analyzed wind data
        repmat(' | Source: ',length(handles.Toolbox(tb).Input.analyzedWindData),1) ...
        strvcat({handles.Toolbox(tb).Input.analyzedWindData.Source}')]) % source of wind data
else
    set(handles.GUIHandles.ListAnalyzedData,'String','');
    set(handles.GUIHandles.PushUseAnalyzed,'Enable','off');
end

