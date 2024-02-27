function ddb_editD3DFlowConditionsTimeSeries
%DDB_EDITD3DFLOWCONDITIONSTIMESERIES  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_editD3DFlowConditionsTimeSeries
%
%   Input:

%
%
%
%
%   Example
%   ddb_editD3DFlowConditionsTimeSeries
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
h=getHandles;

kmax=h.model.delft3dflow.domain(ad).KMax;
handles.KMax=kmax;

ibnd=h.model.delft3dflow.domain(ad).activeOpenBoundary;

handles.Bnd=h.model.delft3dflow.domain(ad).openBoundaries(ibnd);

prf=handles.Bnd.profile;

MakeNewWindow('Time Series Boundary Conditions',[470 470],'modal',[h.settingsDir filesep 'icons' filesep 'deltares.gif']);

uipanel('Title','Time Series', 'Units','pixels','Position',[40 80 390 230],'Tag','UIControl');

cltp={'edittime','editreal','editreal'};
callbacks={@EditTable,@EditTable,@EditTable};
wdt=[120 60 60];
for it=1:handles.Bnd.nrTimeSeries
    data{it,1}=handles.Bnd.timeSeriesT(it);
    data{it,2}=handles.Bnd.timeSeriesA(it,1);
    data{it,3}=handles.Bnd.timeSeriesB(it,1);
end
handles.GUIHandles.table=gui_table(gcf,'create','tag','timeseriestable','position',[50 90],'nrrows',8,'columntypes',cltp,'width',wdt,'data',data,'callbacks',callbacks,'includebuttons',1);

switch handles.Bnd.type,
    case{'Z'}
        quant='Water Level';
        unit='m';
    case{'C'}
        quant='Velocity';
        unit='m/s';
    case{'N'}
        quant='Water Level Gradient';
        unit='-';
    case{'T'}
        quant='Total Discharge';
        unit='m^3/s';
    case{'Q'}
        quant='Discharge per Cell';
        unit='m^3/s';
    case{'R'}
        quant='Riemann';
        unit='m/s';
end

handles.GUIHandles.TextTime                = uicontrol(gcf,'Style','text','String','Time','Position',[60 275 120 15],'HorizontalAlignment','center');
handles.GUIHandles.Textyyyy                = uicontrol(gcf,'Style','text','String','yyyy mm dd HH MM SS','Position',[60 260 120 15],'HorizontalAlignment','center');
handles.GUIHandles.TextEndA                = uicontrol(gcf,'Style','text','String','End A','Position',[180 275 60 15],'HorizontalAlignment','center');
handles.GUIHandles.TextUnitA               = uicontrol(gcf,'Style','text','String',['(' unit ')'],'Position',[180 260 60 15],'HorizontalAlignment','center');
handles.GUIHandles.TextEndB                = uicontrol(gcf,'Style','text','String','End B','Position',[240 275 60 15],'HorizontalAlignment','center');
handles.GUIHandles.TextUnitB               = uicontrol(gcf,'Style','text','String',['(' unit ')'],'Position',[240 260 60 15],'HorizontalAlignment','center');

uipanel('Title','Boundary Section','Units','pixels','Position',[40 320 390 120]);
handles.GUIHandles.TextBoundary = uicontrol(gcf,'Style','text','String','Boundary :' ,'Position',[50 400 200 20],'HorizontalAlignment','left');
handles.GUIHandles.TextBoundaryName = uicontrol(gcf,'Style','text','String',handles.Bnd.name,'Position',[125 400 150 20],'HorizontalAlignment','left');
handles.GUIHandles.TextQuantity   = uicontrol(gcf,'Style','text','String','Quantity :','Position',[50 380 200 20],'HorizontalAlignment','left');
handles.GUIHandles.TextQuantity   = uicontrol(gcf,'Style','text','String',quant,'Position',[125 380 150 20],'HorizontalAlignment','left');
handles.GUIHandles.TextForcingType = uicontrol(gcf,'Style','text','String','Forcing Type :','Position',[50 360 150 20],'HorizontalAlignment','left');
handles.GUIHandles.TextForcingType = uicontrol(gcf,'Style','text','String','Time Series','Position',[125 360 150 20],'HorizontalAlignment','left');

for k=1:kmax
    str{k}=num2str(k);
end
handles.GUIHandles.TextLayer   = uicontrol(gcf,'Style','text','String','Layer : ','Position',[50 331 50 20],'HorizontalAlignment','left');
handles.GUIHandles.SelectLayer = uicontrol(gcf,'Style','popupmenu','String',str,'Position',[125 335 30 20]);

if kmax==1 || ~strcmpi(prf,'3d-profile')
    set(handles.GUIHandles.TextLayer,'Enable','off');
    set(handles.GUIHandles.SelectLayer,'Enable','off');
end

handles.GUIHandles.PushOK     = uicontrol(gcf,'Style','pushbutton','String','OK',    'Position',[370 30 60 20]);
handles.GUIHandles.PushCancel = uicontrol(gcf,'Style','pushbutton','String','Cancel','Position',[300 30 60 20]);

set(handles.GUIHandles.PushOK,              'CallBack',{@PushOK_CallBack});
set(handles.GUIHandles.PushCancel,          'CallBack',{@PushCancel_CallBack});
set(handles.GUIHandles.SelectLayer,         'CallBack',{@SelectLayer_CallBack});

SetUIBackgroundColors;

guidata(gcf,handles);

%%
function PushOK_CallBack(hObject,eventdata)
h=guidata(gcf);
handles=getHandles;

ibnd=handles.model.delft3dflow.domain(ad).activeOpenBoundary;

handles.model.delft3dflow.domain(ad).openBoundaries(ibnd)=h.Bnd;

setHandles(handles);
closereq;

%%
function PushCancel_CallBack(hObject,eventdata)
closereq;

%%
function PushImport_CallBack(hObject,eventdata)

handles=guidata(gcf);

[data,ok]=ImportFromXLS;
if ok
    gui_table(handles.GUIHandles.table,'setdata',data);
else
    ddb_giveWarning('Warning','Error importing xls file');
end

%%
function PasteFromExcel_CallBack(hObject,eventdata)

handles=guidata(gcf);

str=clipboard('paste');
try
    a=textscan(str,'%s%s%s','delimiter', '\t');
    for i=1:length(a{1})
        data{i,1}=str2double(char(a{1}(i)))+datenum('30-Dec-1899');
        data{i,2}=str2double(char(a{2}(i)));
        data{i,3}=str2double(char(a{3}(i)));
    end
    gui_table(handles.GUIHandles.table,'setdata',data);
catch
    ddb_giveWarning('Warning','Could not copy selection');
end

%%
function SelectLayer_CallBack(hObject,eventdata)
handles=guidata(gcf);
k=get(hObject,'Value');
for i=1:handles.Bnd.nrTimeSeries
    data{i,1}=handles.Bnd.timeSeriesT(i);
    data{i,2}=handles.Bnd.timeSeriesA(i,k);
    data{i,3}=handles.Bnd.timeSeriesB(i,k);
end
gui_table(handles.GUIHandles.table,'setdata',data);

%%
function EditTable
handles=guidata(gcf);
k=get(handles.GUIHandles.SelectLayer,'Value');
data=gui_table(handles.GUIHandles.table,'getdata');
nr=size(data,1);
for i=1:nr
    handles.Bnd.timeSeriesT(i)=data{i,1};
    handles.Bnd.timeSeriesA(i,k)=data{i,2};
    handles.Bnd.timeSeriesB(i,k)=data{i,3};
end
handles.Bnd.nrTimeSeries=nr;
guidata(gcf,handles);


