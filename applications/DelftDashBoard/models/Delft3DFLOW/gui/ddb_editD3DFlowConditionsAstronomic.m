function ddb_editD3DFlowConditionsAstronomic
%DDB_EDITD3DFLOWCONDITIONSASTRONOMIC  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_editD3DFlowConditionsAstronomic
%
%   Input:

%
%
%
%
%   Example
%   ddb_editD3DFlowConditionsAstronomic
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

handles=h.model.delft3dflow.domain(ad);
iac=handles.activeOpenBoundary;

a=load([h.settingsDir 'tidalconstituents\t_constituents.mat']);
handles.componentNames=cellstr(a.const.name);

if handles.nrAstronomicComponentSets==0
    handles.nrAstronomicComponentSets=1;
    handles.astronomicComponentSets.name='unnamed';
    handles.astronomicComponentSets.nr=2;
    handles.astronomicComponentSets.component{1}='M2';
    handles.astronomicComponentSets.component{2}='S2';
    handles.astronomicComponentSets.amplitude(1)=1.0;
    handles.astronomicComponentSets.amplitude(2)=1.0;
    handles.astronomicComponentSets.phase(1)=0.0;
    handles.astronomicComponentSets.phase(2)=0.0;
    handles.astronomicComponentSets.correction(1)=0;
    handles.astronomicComponentSets.correction(2)=0;
    handles.astronomicComponentSets.amplitudeCorrection(1)=0;
    handles.astronomicComponentSets.amplitudeCorrection(2)=0;
    handles.astronomicComponentSets.phaseCorrection(1)=0;
    handles.astronomicComponentSets.phaseCorrection(2)=0;
else
    for i=1:handles.nrAstronomicComponentSets
        str{i}=handles.astronomicComponentSets(i).name;
    end
    k1=strmatch('unnamed',str,'exact');
    if isempty(k1) && (strcmp(handles.openBoundaries(iac).compA,'unnamed') || strcmp(handles.openBoundaries(iac).compB,'unnamed'))
        n=handles.nrAstronomicComponentSets+1;
        handles.nrAstronomicComponentSets=n;
        handles.astronomicComponentSets(n).name='unnamed';
        handles.astronomicComponentSets(n).nr=2;
        handles.astronomicComponentSets(n).component{1}='M2';
        handles.astronomicComponentSets(n).component{2}='S2';
        handles.astronomicComponentSets(n).amplitude(1)=1.0;
        handles.astronomicComponentSets(n).amplitude(2)=1.0;
        handles.astronomicComponentSets(n).phase(1)=0.0;
        handles.astronomicComponentSets(n).phase(2)=0.0;
        handles.astronomicComponentSets(n).correction(1)=0;
        handles.astronomicComponentSets(n).correction(2)=0;
        handles.astronomicComponentSets(n).amplitudeCorrection(1)=0;
        handles.astronomicComponentSets(n).amplitudeCorrection(2)=0;
        handles.astronomicComponentSets(n).phaseCorrection(1)=0;
        handles.astronomicComponentSets(n).phaseCorrection(2)=0;
    end
end

wnd=MakeNewWindow('Astronomic Boundary Conditions',[750 600],'modal',[h.settingsDir filesep 'icons' filesep 'deltares.gif']);

uipanel('Title','Component Sets','Units','pixels','Position',[20 370 360 210],'Tag','UIControl');
for i=1:handles.nrAstronomicComponentSets
    handles.componentSets{i}=handles.astronomicComponentSets(i).name;
end
ii=strmatch(handles.openBoundaries(iac).compA,handles.componentSets,'exact');
handles.ActiveComponentSet=handles.componentSets{ii};
handles.GUIHandles.TextSelectedComponentSets=uicontrol(gcf,'Style','text','String','Selected Component Sets','Position',[510 450 130 20],'HorizontalAlignment','center');
handles.GUIHandles.ListComponentSets      = uicontrol(gcf,'Style','listbox','String',handles.componentSets,'Value',ii,'Position',[40 390 150 150],'HorizontalAlignment','left',  'BackgroundColor',[1 1 1]);
handles.GUIHandles.TextComponentSets      = uicontrol(gcf,'Style','text','String','Available Sets','Position',[40 540 150 20], 'HorizontalAlignment','center');
handles.GUIHandles.PushAddComponentSet    = uicontrol(gcf,'Style','pushbutton','String','Add',   'Position',[210 520 60 20]);
handles.GUIHandles.PushDeleteComponentSet = uicontrol(gcf,'Style','pushbutton','String','Delete','Position',[210 490 60 20]);
handles.GUIHandles.EditComponentSetName   = uicontrol(gcf,'Style','edit','Position',[210 390 150 20],'BackgroundColor',[1 1 1],'HorizontalAlignment','left');
handles.GUIHandles.TextComponentSetName   = uicontrol(gcf,'Style','text','String','Selected Set','Position',[210 410 150 20],'HorizontalAlignment','center');

set(handles.GUIHandles.EditComponentSetName,'String',handles.ActiveComponentSet);
set(handles.GUIHandles.PushAddComponentSet,'Enable','off');
set(handles.GUIHandles.PushDeleteComponentSet,'Enable','off');

set(handles.GUIHandles.ListComponentSets,   'CallBack',{@ListComponentSets_CallBack});
set(handles.GUIHandles.EditComponentSetName,'CallBack',{@EditComponentSetName_CallBack});

handles.GUIHandles.PushViewTimeSeries    = uicontrol(gcf,'Style','pushbutton','String','View',   'Position',[210 460 60 20]);
set(handles.GUIHandles.PushViewTimeSeries,   'CallBack',{@PushViewTimeSeries_CallBack});

cltp={'popupmenu','editreal','editreal','checkbox'};
wdt=[80 80 80 20];
callbacks={'','','',@RefreshCorrections};
% for i=1:length(handles.componentNames)
%     ppm{i,1}=handles.componentNames{i};
%     ppm{i,2}='';
%     ppm{i,3}='';
% end
for i=1:length(handles.componentNames)
    ppm1{i}=handles.componentNames{i};
end
ppm2={''};
ppm3={''};
ppm={ppm1,ppm2,ppm3};
handles.GUIHandles.componentSetTable=gui_table(wnd,'create','tag','componentSetTable','position',[50 110],'nrrows',8,'columntypes',cltp,'width',wdt,'popuptext',ppm,'callbacks',callbacks,'includebuttons',1);

%
cltp={'pushbutton','editreal','editreal'};
enab=zeros(8,3)+1;
enab(:,1)=0;
wdt=[80 60 60];
pushtext={'a','b','c'};
handles.GUIHandles.correctionTable=gui_table(wnd,'create','tag','correctiontable','position',[460 110],'nrrows',8,'columntypes',cltp,'width',wdt,'enable',enab,'pushtext',pushtext);


switch handles.openBoundaries(iac).type,
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

uipanel('Title','Boundary Section','Units','pixels','Position',[450 370 250 210]);
handles.GUIHandles.TextBoundary = uicontrol(gcf,'Style','text','String','Boundary :' ,'Position',[470 530 200 20],'HorizontalAlignment','left');
handles.GUIHandles.TextBoundaryName = uicontrol(gcf,'Style','text','String',handles.openBoundaries(iac).name,'Position',[545 530 150 20],'HorizontalAlignment','left');
handles.GUIHandles.TextQuantity   = uicontrol(gcf,'Style','text','String','Quantity :','Position',[470 510 200 20],'HorizontalAlignment','left');
handles.GUIHandles.TextQuantity   = uicontrol(gcf,'Style','text','String',quant,'Position',[545 510 150 20],'HorizontalAlignment','left');
handles.GUIHandles.TextForcingType = uicontrol(gcf,'Style','text','String','Forcing Type :','Position',[470 490 150 20],'HorizontalAlignment','left');
handles.GUIHandles.TextForcingType = uicontrol(gcf,'Style','text','String','Astronomic','Position',[545 490 150 20],'HorizontalAlignment','left');

handles.GUIHandles.TextBoundarySectionA=uicontrol(gcf,'Style','text','String','End A','Position',[470 427 100 20],'HorizontalAlignment','left');
handles.GUIHandles.SelectBoundarySectionA =uicontrol(gcf,'Style','popupmenu','String',handles.componentSets,'Position',[510 430 130 20],'BackgroundColor',[1 1 1]);
ii=strmatch(handles.openBoundaries(iac).compA,handles.componentSets,'exact');
if ~isempty(ii)
    set(handles.GUIHandles.SelectBoundarySectionA,'Value',ii);
else
    ddb_giveWarning('Warning',[handles.openBoundaries(iac).compA ' does not exist!']);
    return
end

handles.GUIHandles.TextBoundarySectionB=uicontrol(gcf,'Style','text','String','End B','Position',[470 397 100 20],'HorizontalAlignment','left');
handles.GUIHandles.SelectBoundarySectionB =uicontrol(gcf,'Style','popupmenu','String',handles.componentSets,'Position',[510 400 130 20],'BackgroundColor',[1 1 1]);
ii=strmatch(handles.openBoundaries(iac).compB,handles.componentSets,'exact');
if ~isempty(ii)
    set(handles.GUIHandles.SelectBoundarySectionB,'Value',ii);
else
    ddb_giveWarning('Warning',[handles.openBoundaries(iac).compA ' does not exist!']);
    return
end

set(handles.GUIHandles.SelectBoundarySectionA,'CallBack',{@SelectBoundarySectionA_CallBack});
set(handles.GUIHandles.SelectBoundarySectionB,'CallBack',{@SelectBoundarySectionB_CallBack});

handles.GUIHandles.panel2=uipanel('Title','Astronomical Data for Set ...','Units','pixels','Position',[20 80 710 280],'Tag','UIControl');
set(handles.GUIHandles.panel2,'Title',['Astronomical Data for Set ' handles.ActiveComponentSet]);

uipanel('Title','Conditions', 'Units','pixels','Position',[40 100 390 230],'Tag','UIControl');

RefreshComponentSet(handles);
guidata(findobj('Name','Astronomic Boundary Conditions'),handles);
RefreshCorrections;

handles.GUIHandles.TextComponentName       = uicontrol(gcf,'Style','text','String','Name','Position',[60 280 80 30],'HorizontalAlignment','center');
handles.GUIHandles.TextAmplitude           = uicontrol(gcf,'Style','text','String',['Amplitude (' unit ')'],'Position',[150 280 50 30],'HorizontalAlignment','center');
handles.GUIHandles.TextPhase               = uicontrol(gcf,'Style','text','String','Phase (deg)','Position',[230 280 50 30],'HorizontalAlignment','center');
handles.GUIHandles.TextCorrection          = uicontrol(gcf,'Style','text','String','Correction','Position',[280 280 50 30],'HorizontalAlignment','left');

uipanel('Title','Corrections','Units','pixels','Position',[450 100 250 230],'Tag','UIControl');
handles.GUIHandles.TextCorrectionName       = uicontrol(gcf,'Style','text','String','Name','Position',[470 280 80 30],'HorizontalAlignment','center');
handles.GUIHandles.TextCorrectionAmplitude  = uicontrol(gcf,'Style','text','String','Amplitude (m)','Position',[550 280 50 30],'HorizontalAlignment','center');
handles.GUIHandles.TextCorrectionPhase      = uicontrol(gcf,'Style','text','String','Phase (deg)','Position',[600 280 50 30],'HorizontalAlignment','center');

handles.GUIHandles.PushOK     = uicontrol(gcf,'Style','pushbutton','String','OK',    'Position',[670 30 60 30]);
handles.GUIHandles.PushCancel = uicontrol(gcf,'Style','pushbutton','String','Cancel','Position',[600 30 60 30]);

set(handles.GUIHandles.PushOK,              'CallBack',{@PushOK_CallBack});
set(handles.GUIHandles.PushCancel,          'CallBack',{@PushCancel_CallBack});

SetUIBackgroundColors;

guidata(findobj('Name','Astronomic Boundary Conditions'),handles);

%%
function ListComponentSets_CallBack(hObject,eventdata)
handles=guidata(findobj('Name','Astronomic Boundary Conditions'));
str=handles.componentSets;
str=str{get(hObject,'Value')};
%if ~strcmp(str,handles.ActiveComponentSet)
[handles,ok]=ChangeData(handles);
if ok==1
    handles.ActiveComponentSet=str;
    set(handles.GUIHandles.EditComponentSetName,'String',handles.ActiveComponentSet);
    set(handles.GUIHandles.panel2,'Title',['Astronomical Data for Set ' handles.ActiveComponentSet]);
    RefreshComponentSet(handles);
    guidata(findobj('Name','Astronomic Boundary Conditions'),handles);
    RefreshCorrections;
else
    ii=strmatch(handles.ActiveComponentSet,handles.componentSets,'exact');
    set(hObject,'Value',ii);
end
%end

%%
function EditComponentSetName_CallBack(hObject,eventdata)
handles=guidata(findobj('Name','Astronomic Boundary Conditions'));
ii=get(handles.GUIHandles.ListComponentSets,'Value');
name=get(hObject,'String');
handles.astronomicComponentSets(ii).name=name;
handles.componentSets{ii}=name;
set(handles.GUIHandles.ListComponentSets,'String',handles.componentSets);
set(handles.GUIHandles.SelectBoundarySectionA,'String',handles.componentSets);
set(handles.GUIHandles.SelectBoundarySectionB,'String',handles.componentSets);
k=get(handles.GUIHandles.SelectBoundarySectionA,'Value');
str=get(handles.GUIHandles.SelectBoundarySectionA,'String');
if strcmp(str{k},handles.ActiveComponentSet)
    handles.openBoundaries(iac).compA=name;
end
set(handles.GUIHandles.SelectBoundarySectionA,'String',handles.componentSets);
k=get(handles.GUIHandles.SelectBoundarySectionB,'Value');
str=get(handles.GUIHandles.SelectBoundarySectionB,'String');
if strcmp(str{k},handles.ActiveComponentSet)
    handles.openBoundaries(iac).compB=name;
end
set(handles.GUIHandles.SelectBoundarySectionB,'String',handles.componentSets);
handles.ActiveComponentSet=handles.componentSets{ii};
set(handles.GUIHandles.panel2,'Title',['Astronomical Data for Set ' handles.ActiveComponentSet]);
guidata(findobj('Name','Astronomic Boundary Conditions'),handles);

%%
function SelectBoundarySectionA_CallBack(hObject,eventdata,icomp)
handles=guidata(findobj('Name','Astronomic Boundary Conditions'));
ii=get(hObject,'Value');
str=get(hObject,'String');
handles.openBoundaries(handles.activeOpenBoundary).compA=str{ii};
guidata(findobj('Name','Astronomic Boundary Conditions'),handles);

%%
function SelectBoundarySectionB_CallBack(hObject,eventdata,icomp)
handles=guidata(findobj('Name','Astronomic Boundary Conditions'));
ii=get(hObject,'Value');
str=get(hObject,'String');
handles.openBoundaries(handles.activeOpenBoundary).compB=str{ii};
guidata(findobj('Name','Astronomic Boundary Conditions'),handles);

%%
function PushOK_CallBack(hObject,eventdata)

h2=guidata(findobj('Name','Astronomic Boundary Conditions'));

handles=getHandles;

[h2,ok]=ChangeData(h2);
if ok==1
    for i=1:h2.nrOpenBoundaries
        if strcmp(h2.openBoundaries(i).forcing,'A')
            stra{i}=h2.openBoundaries(i).compA;
            strb{i}=h2.openBoundaries(i).compB;
        else
            stra{i}=' ';
            strb{i}=' ';
        end
    end
    for i=1:h2.nrAstronomicComponentSets
        str{i}=h2.astronomicComponentSets(i).name;
    end
    k1=strmatch('unnamed',stra,'exact');
    k2=strmatch('unnamed',strb,'exact');
    k3=strmatch('unnamed',str,'exact');
    if isempty(k1) && isempty(k2) && ~isempty(k3>0)
        % component set unname has become unnecessary
        for j=k3:h2.nrAstronomicComponentSets-1
            h2.astronomicComponentSets(j)=h2.astronomicComponentSets(j+1);
        end
        h2.astronomicComponentSets=h2.astronomicComponentSets(1:end-1);
        h2.nrAstronomicComponentSets=h2.nrAstronomicComponentSets-1;
    end
    handles.model.delft3dflow.domain(ad).astronomicComponentSets=h2.astronomicComponentSets;
    handles.model.delft3dflow.domain(ad).nrAstronomicComponentSets=h2.nrAstronomicComponentSets;
    handles.model.delft3dflow.domain(ad).openBoundaries=h2.openBoundaries;
    setHandles(handles);
    closereq;
end

%%

function PushCancel_CallBack(hObject,eventdata)
closereq;

%%

function RefreshComponentSet(handles)

cltp={'popupmenu','editreal','editreal','checkbox'};
wdt=[80 80 80 20];
callbacks={'','','',@RefreshCorrections};

ii=get(handles.GUIHandles.ListComponentSets,'Value');
for i=1:handles.astronomicComponentSets(ii).nr
    data{i,1}=handles.astronomicComponentSets(ii).component{i};
    data{i,2}=handles.astronomicComponentSets(ii).amplitude(i);
    data{i,3}=handles.astronomicComponentSets(ii).phase(i);
    data{i,4}=handles.astronomicComponentSets(ii).correction(i);
end
for i=1:length(handles.componentNames)
    ppm{i,1}=handles.componentNames{i};
    ppm{i,2}='';
    ppm{i,3}='';
end

gui_table(handles.GUIHandles.componentSetTable,'setdata',data);

%%

function RefreshCorrections

handles=guidata(findobj('Name','Astronomic Boundary Conditions'));
[handles,ok]=ChangeData(handles);
guidata(findobj('Name','Astronomic Boundary Conditions'),handles);

cltp={'pushbutton','editreal','editreal'};
enab=zeros(8,3)+1;
enab(:,1)=0;
wdt=[80 60 60];
ii=get(handles.GUIHandles.ListComponentSets,'Value');
k=0;
for i=1:handles.astronomicComponentSets(ii).nr
    if handles.astronomicComponentSets(ii).correction(i)
        k=k+1;
        data{k,1}=handles.astronomicComponentSets(ii).component{i};
        data{k,2}=handles.astronomicComponentSets(ii).amplitudeCorrection(i);
        data{k,3}=handles.astronomicComponentSets(ii).phaseCorrection(i);
    end
end
if k>0
    gui_table(handles.GUIHandles.correctionTable,'setdata',data);
    set(handles.GUIHandles.correctionTable,'Visible','on');
else
    set(handles.GUIHandles.correctionTable,'Visible','off');
end

%%
function [handles,ok]=ChangeData(handles)
ok=1;
data=gui_table(handles.GUIHandles.componentSetTable,'getdata');
for i=1:size(data,1)
    for j=i:size(data,1)
        if strcmp(data{i,1},data{j,1}) && i~=j
            ok=0;
            ddb_giveWarning('Warning',['Component ' data{i,1} ' found more than once!']);
            return;
        end
    end
end
ii=strmatch(handles.ActiveComponentSet,handles.componentSets,'exact');
handles.astronomicComponentSets(ii).nr=size(data,1);
handles.astronomicComponentSets(ii).component=[];
handles.astronomicComponentSets(ii).amplitude=[];
handles.astronomicComponentSets(ii).phase=[];
handles.astronomicComponentSets(ii).correction=[];
for i=1:handles.astronomicComponentSets(ii).nr
    handles.astronomicComponentSets(ii).component{i}=data{i,1};
    handles.astronomicComponentSets(ii).amplitude(i)=data{i,2};
    handles.astronomicComponentSets(ii).phase(i)=data{i,3};
    handles.astronomicComponentSets(ii).correction(i)=data{i,4};
    if handles.astronomicComponentSets(ii).correction(i)
        data2=gui_table(handles.GUIHandles.correctionTable,'getdata');
        for j=1:size(data2,1)
            if strcmp(data2{j,1},handles.astronomicComponentSets(ii).component{i})
                handles.astronomicComponentSets(ii).amplitudeCorrection(i)=data2{j,2};
                handles.astronomicComponentSets(ii).phaseCorrection(i)=data2{j,3};
            end
        end
    end
end

%%
function PushViewTimeSeries_CallBack(hObject,eventdata)
handles=guidata(findobj('Name','Astronomic Boundary Conditions'));
h=guidata(findobj('Tag','MainWindow'));
ii=get(handles.GUIHandles.ListComponentSets,'Value');
for i=1:handles.astronomicComponentSets(ii).nr
    cmp{i}=handles.astronomicComponentSets(ii).component{i};
    A(i,1)=handles.astronomicComponentSets(ii).amplitude(i);
    G(i,1)=handles.astronomicComponentSets(ii).phase(i);
    data{i,4}=handles.astronomicComponentSets(ii).correction(i);
end
t0=h.Model(strcmp('Delft3DFLOW',{h.Model.name})).Input(h.ActiveDomain).StartTime;
t1=h.Model(strcmp('Delft3DFLOW',{h.Model.name})).Input(h.ActiveDomain).StopTime;
dt=h.Model(strcmp('Delft3DFLOW',{h.Model.name})).Input(h.ActiveDomain).TimeStep/60;

[prediction,times]=delftPredict2007(cmp,A,G,t0,t1,dt);
ddb_plotTimeSeries(times,prediction,'');

