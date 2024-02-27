function ddb_TideDatabaseToolbox_export(varargin)
%DDB_TIDEDATABASETOOLBOX_EXPORT  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_TideDatabaseToolbox_export(varargin)
%
%   Input:
%   varargin =
%
%
%
%
%   Example
%   ddb_TideDatabaseToolbox_export
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

% $Id: ddb_TideDatabaseToolbox_export.m 18031 2022-05-09 09:16:18Z leijnse $
% $Date: 2022-05-09 17:16:18 +0800 (Mon, 09 May 2022) $
% $Author: leijnse $
% $Revision: 18031 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/TideDatabase/ddb_TideDatabaseToolbox_export.m $
% $Keywords: $

%%
handles=getHandles;

if isempty(varargin)
    % New tab selected
    ddb_zoomOff;
    ddb_refreshScreen;
    % setUIElements('tidedatabasepanel.export');
    ddb_plotTideDatabase('activate');
else
    %Options selected
    opt=lower(varargin{1});
    switch opt
        case{'selectmodel'}
            selectModel;
        case{'drawrectangle'}
            setInstructions({'','','Use mouse to draw data outline on map'});
            UIRectangle(handles.GUIHandles.mapAxis,'draw','Tag','TideDatabaseBox','Marker','o','MarkerEdgeColor','k','MarkerSize',6,'rotate',0,'callback',@changeTideDatabaseBox,'onstart',@deleteTideDatabaseBox);
        case{'export'}
            exportData;
        case{'view'}
            viewCoTidalChart;
        case{'editoutline'}
            editOutline;
        case{'selectexportformat'}
            selectExportFormat;
        case('download')
            downloadData;
        case('clickpoint')
            setInstructions({'','','Use mouse to click location on map'});
            gui_clickpoint('xy','callback',@selectPoint);
        case('viewtimeseries')
            viewTimeSeries;
        case('exporttimeseries')
            exportTimeSeries;
    end
end

%%
function changeTideDatabaseBox(x0,y0,dx,dy,rotation,h)

setInstructions({'','Left-click and drag markers to change corner points','Right-click and drag yellow marker to move entire box'});
handles=getHandles;
handles.toolbox.tidedatabase.tideDatabaseBoxHandle=h;
handles.toolbox.tidedatabase.xLim(1)=x0;
handles.toolbox.tidedatabase.yLim(1)=y0;
handles.toolbox.tidedatabase.xLim(2)=x0+dx;
handles.toolbox.tidedatabase.yLim(2)=y0+dy;
setHandles(handles);

gui_updateActiveTab;

%%
function downloadData

% Get information about URL en tide database
handles=getHandles;
ii=handles.toolbox.tidedatabase.activeModel;
name=handles.tideModels.model(ii).name;
URL = 'https://opendap.deltares.nl/thredds/fileServer/opendap/deltares/delftdashboard/tidemodels/';
if strcmpi(handles.tideModels.model(ii).URL(1:5),'https')
    tidefile=[URL '/' name '.nc'];
else
    tidefile=[handles.tideModels.model(ii).URL filesep name '.nc'];
end
    
% Get location
pathname = 'd:\projects\ddb\working\tidemodels\';
[pathname] = uigetdir(handles.toolbox.tidedatabase.dataDir,'Select the desired data location');
cd(pathname);


% Download file
if strcmp(handles.tideModels.model(ii).name,'tpxo80')
    size = 'around 12 GB';
else
    size = 'less than 1 GB';
end


wb = waitbox(['Downloading tide database. Size: ', size]);
if strcmp(handles.tideModels.model(ii).name,'tpxo80')
    names = {'grid_tpxo8_atlas6.nc';'grid_tpxo8atlas_30.nc';'hf.k1_tpxo8.nc';'hf.k2_tpxo8.nc';'hf.m2_tpxo8.nc';'hf.m4_tpxo8.nc';'hf.mf_tpxo8.nc';'hf.mm_tpxo8.nc';'hf.mn4_tpxo8.nc';'hf.ms4_tpxo8.nc';'hf.n2_tpxo8.nc';'hf.o1_tpxo8.nc';'hf.p1_tpxo8.nc';'hf.q1_tpxo8.nc';'hf.s2_tpxo8.nc';'tpxo80.nc';'uv.k1_tpxo8.nc';'uv.k2_tpxo8.nc';'uv.m2_tpxo8.nc';'uv.m4_tpxo8.nc';'uv.mf_tpxo8.nc';'uv.mm_tpxo8.nc';'uv.mn4_tpxo8.nc';'uv.ms4_tpxo8.nc';'uv.n2_tpxo8.nc';'uv.o1_tpxo8.nc';'uv.p1_tpxo8.nc';'uv.q1_tpxo8.nc';'uv.s2_tpxo8.nc'};
    tidefile2 = 'https://opendap.deltares.nl/thredds/fileServer/opendap/deltares/delftdashboard/tidemodels/tpxo80/';
    for jj = 1:length(names);
        file3 = [tidefile2, names{jj,:}];
        urlwrite(file3,names{jj,:});
    end
else
    urlwrite(tidefile,[name '.nc'])
end
close(wb);

% Change XML
cd(handles.tideDir);
s=xml2struct('tidemodels.xml','structuretype','supershort');
s.model(ii).URL = pathname;
struct2xml('tidemodels.xml', s,'structuretype','supershort')

   
%%
function selectModel
handles=getHandles;
ii=handles.toolbox.tidedatabase.activeModel;
name=handles.tideModels.model(ii).name;
    if strcmpi(handles.tideModels.model(ii).URL(1:4),'http')
        tidefile=[handles.tideModels.model(ii).URL '/' name '.nc'];
    else
        tidefile=[handles.tideModels.model(ii).URL filesep name '.nc'];
    end
cnst=nc_varget(tidefile,'tidal_constituents');
for ii=1:size(cnst,1)
    cnstlist{ii}=deblank(upper(cnst(ii,:)));
end
handles.toolbox.tidedatabase.constituentList=cnstlist;
handles.toolbox.tidedatabase.activeConstituent=1;

setHandles(handles);

%%
function viewCoTidalChart
handles=getHandles;
ii=handles.toolbox.tidedatabase.activeModel;
iac=handles.toolbox.tidedatabase.activeConstituent;
name=handles.tideModels.model(ii).name;
if strcmpi(handles.tideModels.model(ii).URL(1:4),'http')
    tidefile=[handles.tideModels.model(ii).URL '/' name '.nc'];
else
    tidefile=[handles.tideModels.model(ii).URL filesep name '.nc'];
end

xx=handles.toolbox.tidedatabase.xLim;
yy=handles.toolbox.tidedatabase.yLim;

if xx(2)==xx(1)
    ddb_giveWarning('text','First draw a box around the area of interest!');
    return
end

if ~strcmpi(handles.screenParameters.coordinateSystem.type,'geographic')
    xg=xx(1):(xx(2)-xx(1))/10:xx(2);
    yg=yy(1):(yy(2)-yy(1))/10:yy(2);
    [xg,yg]=meshgrid(xg,yg);
    cs.name='WGS 84';
    cs.type='geographic';
    [xg,yg]=ddb_coordConvert(xg,yg,handles.screenParameters.coordinateSystem,cs);
    xx(1)=min(min(xg))-1;
    yy(1)=min(min(yg))-1;
    xx(2)=max(max(xg))+1;
    yy(2)=max(max(yg))+1;
end

cnst=handles.toolbox.tidedatabase.constituentList{iac};
lon1 = []; lat1 = []; ampz1 = []; phasez1 = [];
lon2 = []; lat2 = []; ampz2 = []; phasez2 = [];

[gt, conList] =  read_tide_model(tidefile,'type','h','xlim',xx,'ylim',yy,'constituent',upper(cnst));
lon = gt.lon;
lat = gt.lat;
ampz = squeeze(gt(1).amp);  phasez = squeeze(gt(1).phi);

% Figures
figure(20)
clf;
subplot(2,1,1)
ampm=reshape(ampz,[1 size(ampz,1)*size(ampz,2)]);
ampm=ampm(~isnan(ampm));
ampm=sort(ampm);
i98=round(0.98*length(ampm));
cmax=ampm(i98);
pcolor(lon,lat,ampz);shading flat;axis equal;caxis([0 cmax]);colorbar;
set(gca,'xlim',[gt.lon(1) gt.lon(end)],'ylim',[gt.lat(1) gt.lat(end)]);
subplot(2,1,2)
pcolor(gt.lon,gt.lat,phasez);shading flat;axis equal;caxis([0 360]);colorbar;
set(gca,'xlim',[gt.lon(1) gt.lon(end)],'ylim',[gt.lat(1) gt.lat(end)]);

    
%%
function selectExportFormat

handles=getHandles;
iac=handles.toolbox.tidedatabase.activeExportFormatIndex;
handles.toolbox.tidedatabase.activeExportFormat=handles.toolbox.tidedatabase.exportFormats{iac};
handles.toolbox.tidedatabase.activeExportFormatExtension=handles.toolbox.tidedatabase.exportFormatExtensions{iac};
setHandles(handles);

%%
function exportData

handles=getHandles;

xx=handles.toolbox.tidedatabase.xLim;
yy=handles.toolbox.tidedatabase.yLim;

if xx(2)==xx(1)
    ddb_giveWarning('text','First draw a box around the area of interest!');
    return
end

wb = waitbox('Exporting tide data ...');pause(0.1);

try
    
    %% Filename
    filename=handles.toolbox.tidedatabase.exportFile;
    filename=filename(1:end-4);
    ii=handles.toolbox.tidedatabase.activeModel;
    name=handles.tideModels.model(ii).name;
    if strcmpi(handles.tideModels.model(ii).URL(1:5),'https')
        tidefile=[handles.tideModels.model(ii).URL '/' name '.nc'];
    else
        tidefile=[handles.tideModels.model(ii).URL filesep name '.nc'];
    end

    %% Export waterlevels: H
    if ~strcmpi(handles.screenParameters.coordinateSystem.type,'geographic')
        xg=xx(1):(xx(2)-xx(1))/10:xx(2);
        yg=yy(1):(yy(2)-yy(1))/10:yy(2);
        [xg,yg]=meshgrid(xg,yg);
        cs.name='WGS 84';
        cs.type='geographic';
        [xg,yg]=ddb_coordConvert(xg,yg,handles.screenParameters.coordinateSystem,cs);
        xx(1)=min(min(xg))-1;
        yy(1)=min(min(yg))-1;
        xx(2)=max(max(xg))+1;
        yy(2)=max(max(yg))+1;
    end
    
    % Get data
    [gt, conList] =  read_tide_model(tidefile,'type','h','xlim',xx,'ylim',yy,'constituent','all');
    lon = gt.lon;
    lat = gt.lat;
        
    ampz = gt.amp; phasez = gt.phi;

    for i=1:length(conList)
        if ~strcmpi(handles.screenParameters.coordinateSystem.type,'geographic')
            xx=handles.toolbox.tidedatabase.xLim;
            yy=handles.toolbox.tidedatabase.yLim;
            xg=xx(1):10000:xx(2);
            yg=yy(1):10000:yy(2);
            [xg,yg]=meshgrid(xg,yg);
            [xglo,ygla]=ddb_coordConvert(xg,yg,handles.screenParameters.coordinateSystem,cs);
            [lo,la]=meshgrid(lon,lat);
            amp{i}=interp2(lo,la,gt(i).amp,xglo,ygla);
            phi{i}=interp2(lo,la,gt(i).phi,xglo,ygla);            
        else
            [xg,yg]=meshgrid(lon,lat);
            amp{i}=gt(i).amp;
            phi{i}=gt(i).phi;
        end
    end

    switch lower(handles.toolbox.tidedatabase.activeExportFormat)
        case{'mat'}
            for icon=1:length(conList)
                ii=icon*2-1;
                s.parameters(ii).parameter.name=['Amplitude - ' conList{icon}];
                s.parameters(ii).parameter.quantity='scalar';
                s.parameters(ii).parameter.x=xg;
                s.parameters(ii).parameter.y=yg;
                s.parameters(ii).parameter.val=amp{icon};
                s.parameters(ii).parameter.size=[0 0 size(xg,1) size(xg,2) 0];
                ii=icon*2;
                s.parameters(ii).parameter.name=['Phase - ' conList{icon}];
                s.parameters(ii).parameter.quantity='scalar';
                s.parameters(ii).parameter.x=xg;
                s.parameters(ii).parameter.y=yg;
                s.parameters(ii).parameter.val=phi{icon};
                s.parameters(ii).parameter.size=[0 0 size(xg,1) size(xg,2) 0];
            end
            save([filename '.mat'],'-struct','s');
            close(wb);
            return
        case{'tek'}
            ddb_saveAstroMapFile([filename '.tek'],xg,yg,conList,amp,phi);
    end

    %% Exporting transports: u

    xx=handles.toolbox.tidedatabase.xLim;
    yy=handles.toolbox.tidedatabase.yLim;

    if ~strcmpi(handles.screenParameters.coordinateSystem.type,'geographic')
        xg=xx(1):(xx(2)-xx(1))/10:xx(2);
        yg=yy(1):(yy(2)-yy(1))/10:yy(2);
        [xg,yg]=meshgrid(xg,yg);
        cs.name='WGS 84';
        cs.type='geographic';
        [xg,yg]=ddb_coordConvert(xg,yg,handles.screenParameters.coordinateSystem,cs);
        xx(1)=min(min(xg))-1;
        yy(1)=min(min(yg))-1;
        xx(2)=max(max(xg))+1;
        yy(2)=max(max(yg))+1;
    end
        
    [gt, conList] =  read_tide_model(tidefile,'type','u','xlim',xx,'ylim',yy,'constituent','all');
    lon = gt.lon;
    lat = gt.lat;    
    ampz = gt.amp; phasez = gt.phi;
    
    for i=1:length(conList)
        if ~strcmpi(handles.screenParameters.coordinateSystem.type,'geographic')
            xx=handles.toolbox.tidedatabase.xLim;
            yy=handles.toolbox.tidedatabase.yLim;
            xg=xx(1):10000:xx(2);
            yg=yy(1):10000:yy(2);
            [xg,yg]=meshgrid(xg,yg);
            [xglo,ygla]=ddb_coordConvert(xg,yg,handles.screenParameters.coordinateSystem,cs);
            [lo,la]=meshgrid(lon,lat);
            amp{i}=interp2(lo,la,gt(i).amp,xglo,ygla);
            phi{i}=interp2(lo,la,gt(i).phi,xglo,ygla);              
        else
            [xg,yg]=meshgrid(lon,lat);
            amp{i}=gt(i).amp;
            phi{i}=gt(i).phi;
        end
    end
    
    switch lower(handles.toolbox.tidedatabase.activeExportFormat)
        case{'tek'}
            ddb_saveAstroMapFile([filename '.u.tek'],xg,yg,conList,amp,phi);
    end

    %% Exporting transports: V

    xx=handles.toolbox.tidedatabase.xLim;
    yy=handles.toolbox.tidedatabase.yLim;

    if ~strcmpi(handles.screenParameters.coordinateSystem.type,'geographic')
        xg=xx(1):(xx(2)-xx(1))/10:xx(2);
        yg=yy(1):(yy(2)-yy(1))/10:yy(2);
        [xg,yg]=meshgrid(xg,yg);
        cs.name='WGS 84';
        cs.type='geographic';
        [xg,yg]=ddb_coordConvert(xg,yg,handles.screenParameters.coordinateSystem,cs);
        xx(1)=min(min(xg))-1;
        yy(1)=min(min(yg))-1;
        xx(2)=max(max(xg))+1;
        yy(2)=max(max(yg))+1;
    end
    
    [gt, conList] =  read_tide_model(tidefile,'type','v','xlim',xx,'ylim',yy,'constituent','all');
    lon = gt.lon;
    lat = gt.lat;
    ampz = gt.amp; phasez = gt.phi;
    
    for i=1:length(conList)
        if ~strcmpi(handles.screenParameters.coordinateSystem.type,'geographic')
            xx=handles.toolbox.tidedatabase.xLim;
            yy=handles.toolbox.tidedatabase.yLim;
            xg=xx(1):10000:xx(2);
            yg=yy(1):10000:yy(2);
            [xg,yg]=meshgrid(xg,yg);
            [xglo,ygla]=ddb_coordConvert(xg,yg,handles.screenParameters.coordinateSystem,cs);
            [lo,la]=meshgrid(lon,lat);
            amp{i}=interp2(lo,la,gt(i).amp,xglo,ygla);
            phi{i}=interp2(lo,la,gt(i).phi,xglo,ygla);           
        else
            [xg,yg]=meshgrid(lon,lat);
            amp{i}=gt(i).amp;
            phi{i}=gt(i).phi;
        end
    end
    
    switch lower(handles.toolbox.tidedatabase.activeExportFormat)
        case{'tek'}
            ddb_saveAstroMapFile([filename '.v.tek'],xg,yg,conList,amp,phi);
    end
    
    close(wb);
    
catch
    close(wb);
    ddb_giveWarning('text','An error occured while generating tide data!');
end

%%
function editOutline
handles=getHandles;
deleteTideDatabaseBox;
x0=handles.toolbox.tidedatabase.xLim(1);
y0=handles.toolbox.tidedatabase.yLim(1);
dx=handles.toolbox.tidedatabase.xLim(2)-x0;
dy=handles.toolbox.tidedatabase.yLim(2)-y0;
h=UIRectangle(handles.GUIHandles.mapAxis,'plot','Tag','ImageOutline','Marker','o','MarkerEdgeColor','k','MarkerSize',6,'rotate',0,'callback',@changeTideDatabaseBox, ...
    'onstart',@deleteTideDatabaseBox,'x0',x0,'y0',y0,'dx',dx,'dy',dy);
handles.toolbox.tidedatabase.tideDatabaseBoxHandle=h;
setHandles(handles);

%%
function deleteTideDatabaseBox
handles=getHandles;
if ~isempty(handles.toolbox.tidedatabase.tideDatabaseBoxHandle)
    try
        delete(handles.toolbox.tidedatabase.tideDatabaseBoxHandle);
    end
end

%%
function selectPoint(x,y)

clearInstructions;

handles=getHandles;
handles.toolbox.tidedatabase.point_x=x;
handles.toolbox.tidedatabase.point_y=y;
setHandles(handles);

gui_updateActiveTab;

%% 
function viewTimeSeries
[tim,wl]=get_timeseries_at_point;
ddb_plotTimeSeries(tim,wl,'Point');

%% 
function exportTimeSeries
handles=getHandles;
[tim,wl]=get_timeseries_at_point;
x=handles.toolbox.tidedatabase.point_x;
y=handles.toolbox.tidedatabase.point_y;
xstr=num2str(x,'%0.3f');
ystr=num2str(y,'%0.3f');
fname=['x' xstr '_y' ystr '.tek']; 
            exportTEK(wl',tim',fname,[xstr '_' ystr]);

%%
function [tim,wl]=get_timeseries_at_point

handles=getHandles;
ii=handles.toolbox.tidedatabase.activeModel;
name=handles.tideModels.model(ii).name;
if strcmpi(handles.tideModels.model(ii).URL(1:4),'http')
    tidefile=[handles.tideModels.model(ii).URL '/' name '.nc'];
else
    tidefile=[handles.tideModels.model(ii).URL filesep name '.nc'];
end

x=handles.toolbox.tidedatabase.point_x;
y=handles.toolbox.tidedatabase.point_y;

cs.name='WGS 84';
cs.type='geographic';
[x,y]=ddb_coordConvert(x,y,handles.screenParameters.coordinateSystem,cs);

[gt, conList] =  read_tide_model(tidefile,'type','h','x',x,'y',y,'constituent','all');

t0=handles.toolbox.tidestations.startTime;
t1=handles.toolbox.tidestations.stopTime;
dt=handles.toolbox.tidestations.timeStep/1440;

% t0=datenum(2017,3,1);
% t1=datenum(2017,4,1);
% t0=floor(now);
% t1=t0+31;
% dt=30/1440;

tim=t0:dt:t1;

latitude=y;
wl=makeTidePrediction(tim,conList,gt.amp,gt.phi,latitude);


