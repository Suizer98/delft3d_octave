function ddb_editD3DDischargeData(ii)
%DDB_EDITD3DDISCHARGEDATA  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_editD3DDischargeData(ii)
%
%   Input:
%   ii =
%
%
%
%
%   Example
%   ddb_editD3DDischargeData
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
% Created: 29 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
handles=getHandles;

Flw=handles.model.delft3dflow.domain(ad);

Dis=Flw.discharges(ii);
nr=length(Dis.timeSeriesT);

k=2;
if Flw.salinity.include
    k=k+1;
end
if Flw.temperature.include
    k=k+1;
end
if Flw.sediments.include
    for j=1:Flw.nrSediments
        k=k+1;
    end
end
if Flw.tracers
    for j=1:Flw.nrTracers
        k=k+1;
    end
end
if strcmpi(Dis.type,'momentum')
    k=k+2;
end

fig=MakeNewWindow('Discharge',[k*80+200 260],'modal',[handles.settingsDir filesep 'icons' filesep 'deltares.gif']);

k=0;

wd=80;
ht=230;

k=k+1;
for i=1:min(nr,8)
    data{i,k}=Dis.timeSeriesT(i);
end
k=k+1;
uicontrol(gcf,'Style','text','String','Discharge','Position',[140+(k-2)*wd ht wd 15],'HorizontalAlignment','center','Tag','UIControl');
for i=1:min(nr,8)
    data{i,k}=Dis.timeSeriesQ(i);
end
if Flw.salinity.include
    k=k+1;
    uicontrol(gcf,'Style','text','String','Salinity','Position',[140+(k-2)*wd ht wd 15],'HorizontalAlignment','center','Tag','UIControl');
    for i=1:min(nr,8)
        data{i,k}=Dis.salinity.timeSeries(i);
    end
end
if Flw.temperature.include
    k=k+1;
    uicontrol(gcf,'Style','text','String','Temperature','Position',[140+(k-2)*wd ht wd 15],'HorizontalAlignment','center','Tag','UIControl');
    for i=1:min(nr,8)
        data{i,k}=Dis.temperature.timeSeries(i);
    end
end
if Flw.sediments.include
    for j=1:Flw.nrSediments
        k=k+1;
        uicontrol(gcf,'Style','text','String',Flw.sediment(j).name,'Position',[140+(k-2)*wd ht wd 15],'HorizontalAlignment','center','Tag','UIControl');
        for i=1:min(nr,8)
            data{i,k}=Dis.sediment(j).timeSeries(i);
        end
    end
end
if Flw.tracers
    for j=1:Flw.nrTracers
        k=k+1;
        uicontrol(gcf,'Style','text','String',Flw.tracer(j).name,'Position',[140+(k-2)*wd ht wd 15],'HorizontalAlignment','center','Tag','UIControl');
        for i=1:min(nr,8)
            data{i,k}=Dis.tracer(j).timeSeries(i);
        end
    end
end
if strcmpi(Dis.type,'momentum')
    k=k+1;
    uicontrol(gcf,'Style','text','String','Cur. Magnitude','Position',[140+(k-2)*wd ht wd 15],'HorizontalAlignment','center','Tag','UIControl');
    for i=1:min(nr,8)
        data{i,k}=Dis.timeSeriesM(i);
    end
    k=k+1;
    uicontrol(gcf,'Style','text','String','Cur. Direction','Position',[140+(k-2)*wd ht wd 15],'HorizontalAlignment','center','Tag','UIControl');
    for i=1:min(nr,8)
        data{i,k}=Dis.timeSeriesD(i);
    end
end

cltp{1}='edittime';
wdt(1)=110;
callbacks{1}=[];
for i=2:k
    cltp{i}='editreal';
    wdt(i)=wd;
    callbacks{i}=[];
end

hh.table=gui_table(gcf,'create','tag','table','position',[30 70],'nrrows',8,'columntypes',cltp,'width',wdt,'data',data,'callbacks',callbacks,'includebuttons',1);

%table2(gcf,'table','create','position',[30 70],'nrrows',8,'columntypes',cltp,'width',wdt,'data',data,'callbacks',callbacks,'includebuttons');

hok=uicontrol(gcf,'Style','pushbutton','String','OK',    'Position',[k*80+100 30 70 20]);
hca=uicontrol(gcf,'Style','pushbutton','String','Cancel','Position',[k*80+20 30 70 20]);

set(hok,'CallBack',{@PushOK_Callback});
set(hca,'CallBack',{@PushCancel_Callback});

guidata(gcf,hh);

SetUIBackgroundColors;

%%
function PushOK_Callback(hObject,eventdata)
handles=getHandles;
hh=guidata(gcf);
data=gui_table(hh.table,'getdata');

nr=size(data,1);
id=ad;
ii=handles.model.delft3dflow.domain(id).activeDischarge;

k=0;

k=k+1;
for i=1:nr
    handles.model.delft3dflow.domain(id).discharges(ii).timeSeriesT(i)=data{i,k};
end
k=k+1;
for i=1:nr
    handles.model.delft3dflow.domain(id).discharges(ii).timeSeriesQ(i)=data{i,k};
end
if handles.model.delft3dflow.domain(id).salinity.include
    k=k+1;
    for i=1:nr
        handles.model.delft3dflow.domain(id).discharges(ii).salinity.timeSeries(i)=data{i,k};
    end
end
if handles.model.delft3dflow.domain(id).temperature.include
    k=k+1;
    for i=1:nr
        handles.model.delft3dflow.domain(id).discharges(ii).temperature.timeSeries(i)=data{i,k};
    end
end
if handles.model.delft3dflow.domain(id).sediments.include
    for j=1:handles.model.delft3dflow.domain(id).nrSediments
        k=k+1;
        for i=1:nr
            handles.model.delft3dflow.domain(id).discharges(ii).sediment(j).timeSeries(i)=data{i,k};
        end
    end
end
if handles.model.delft3dflow.domain(id).tracers
    for j=1:handles.model.delft3dflow.domain(id).nrTracers
        k=k+1;
        for i=1:nr
            handles.model.delft3dflow.domain(id).discharges(ii).tracer(j).timeSeries(i)=data{i,k};
        end
    end
end
if strcmpi(handles.model.delft3dflow.domain(id).discharges(ii).type,'momentum')
    k=k+1;
    for i=1:nr
        handles.model.delft3dflow.domain(id).discharges(ii).timeSeriesM(i)=data{i,k};
    end
    k=k+1;
    for i=1:nr
        handles.model.delft3dflow.domain(id).discharges(ii).timeSeriesM(i)=data{i,k};
    end
end

setHandles(handles);
closereq;

%%
function PushCancel_Callback(hObject,eventdata)
closereq;

