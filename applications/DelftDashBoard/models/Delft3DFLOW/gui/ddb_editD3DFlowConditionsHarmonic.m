function ddb_editD3DFlowConditionsHarmonic
%DDB_EDITD3DFLOWCONDITIONSHARMONIC  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_editD3DFlowConditionsHarmonic
%
%   Input:

%
%
%
%
%   Example
%   ddb_editD3DFlowConditionsHarmonic
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

MakeNewWindow('Harmonic Boundary Conditions',[750 600],[h.settingsDir filesep 'icons' filesep 'deltares.gif']);

uipanel('Title','Harmonics', 'Units','pixels','Position',[40 100 540 245],'Tag','UIControl');

cltp={'text','editreal','editreal','editreal','editreal','editreal'};
wdt=[70 60 60 60 60 60];
for i=1:handles.nrHarmonicComponents
    data{i,1}='';
    data{i,2}=handles.harmonicComponents(i);
    data{i,3}=handles.openBoundaries(handles.activeOpenBoundary).harmonicAmpA(i);
    data{i,4}=handles.openBoundaries(handles.activeOpenBoundary).harmonicPhaseA(i);
    data{i,5}=handles.openBoundaries(handles.activeOpenBoundary).harmonicAmpB(i);
    data{i,6}=handles.openBoundaries(handles.activeOpenBoundary).harmonicPhaseB(i);
end
data{1,1}='Mean';
callbacks={'',@refreshPeriod,'','','',''};
handles.GUIHandles.table=gui_table(gcf,'create','tag','table','position',[50 120],'nrrows',8,'columntypes',cltp,'width',wdt,'data',data,'callbacks',callbacks,'includebuttons',1);

switch handles.openBoundaries(handles.activeOpenBoundary).type,
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

handles.GUIHandles.Text2Period           = uicontrol(gcf,'Style','text','String','Period',      'Position',[ 50 310 70 15],'HorizontalAlignment','center');
handles.GUIHandles.TextFreq              = uicontrol(gcf,'Style','text','String','Frequency',   'Position',[120 310 60 15],'HorizontalAlignment','center');
handles.GUIHandles.TextFreq              = uicontrol(gcf,'Style','text','String','deg/hour',    'Position',[120 280 60 15],'HorizontalAlignment','center');
handles.GUIHandles.TextAmpEndA           = uicontrol(gcf,'Style','text','String','Amplitude',   'Position',[180 310 60 15],'HorizontalAlignment','center');
handles.GUIHandles.TextAmpEndA           = uicontrol(gcf,'Style','text','String','End A',       'Position',[180 295 60 15],'HorizontalAlignment','center');
handles.GUIHandles.TextAmpEndA           = uicontrol(gcf,'Style','text','String',['(' unit ')'],'Position',[180 280 60 15],'HorizontalAlignment','center');
handles.GUIHandles.TextPhaEndA           = uicontrol(gcf,'Style','text','String','Phase',       'Position',[240 310 60 15],'HorizontalAlignment','center');
handles.GUIHandles.TextPhaEndA           = uicontrol(gcf,'Style','text','String','End A',       'Position',[240 295 60 15],'HorizontalAlignment','center');
handles.GUIHandles.TextPhaEndA           = uicontrol(gcf,'Style','text','String',['(degrees)'], 'Position',[240 280 60 15],'HorizontalAlignment','center');
handles.GUIHandles.TextAmpEndB           = uicontrol(gcf,'Style','text','String','Amplitude',   'Position',[300 310 60 15],'HorizontalAlignment','center');
handles.GUIHandles.TextAmpEndB           = uicontrol(gcf,'Style','text','String','End B',       'Position',[300 295 60 15],'HorizontalAlignment','center');
handles.GUIHandles.TextAmpEndB           = uicontrol(gcf,'Style','text','String',['(' unit ')'],'Position',[300 280 60 15],'HorizontalAlignment','center');
handles.GUIHandles.TextPhaEndB           = uicontrol(gcf,'Style','text','String','Phase',       'Position',[360 310 60 15],'HorizontalAlignment','center');
handles.GUIHandles.TextPhaEndB           = uicontrol(gcf,'Style','text','String','End B',       'Position',[360 295 60 15],'HorizontalAlignment','center');
handles.GUIHandles.TextPhaEndB           = uicontrol(gcf,'Style','text','String',['(degrees)'], 'Position',[360 280 60 15],'HorizontalAlignment','center');

uipanel('Title','Boundary Section','Units','pixels','Position',[470 480 250 100]);
handles.GUIHandles.TextBoundary = uicontrol(gcf,'Style','text','String','Boundary :' ,'Position',[490 530 200 20],'HorizontalAlignment','left');
handles.GUIHandles.TextBoundaryName = uicontrol(gcf,'Style','text','String',handles.openBoundaries(handles.activeOpenBoundary).name,'Position',[565 530 150 20],'HorizontalAlignment','left');
handles.GUIHandles.TextQuantity   = uicontrol(gcf,'Style','text','String','Quantity :','Position',[490 510 200 20],'HorizontalAlignment','left');
handles.GUIHandles.TextQuantity   = uicontrol(gcf,'Style','text','String',quant,'Position',[565 510 150 20],'HorizontalAlignment','left');
handles.GUIHandles.TextForcingType = uicontrol(gcf,'Style','text','String','Forcing Type :','Position',[490 490 150 20],'HorizontalAlignment','left');
handles.GUIHandles.TextForcingType = uicontrol(gcf,'Style','text','String','Harmonic','Position',[565 490 150 20],'HorizontalAlignment','left');

handles.GUIHandles.PushOK     = uicontrol(gcf,'Style','pushbutton','String','OK',    'Position',[670 30 60 30]);
handles.GUIHandles.PushCancel = uicontrol(gcf,'Style','pushbutton','String','Cancel','Position',[600 30 60 30]);

set(handles.GUIHandles.PushOK,              'CallBack',{@PushOK_CallBack});
set(handles.GUIHandles.PushCancel,          'CallBack',{@PushCancel_CallBack});

SetUIBackgroundColors;

guidata(gcf,handles);

refreshPeriod;

%%
function PushOK_CallBack(hObject,eventdata)

h=guidata(gcf);
handles=getHandles;
data=gui_table(h.GUIHandles.table,'getdata');
handles.model.delft3dflow.domain(ad).harmonicComponents=[];
% handles.activeOpenBoundary.harmonicAmpA=[];
% handles.activeOpenBoundary.harmonicPhaseA=[];
% handles.activeOpenBoundary.harmonicAmpB=[];
% handles.activeOpenBoundary.harmonicPhaseB=[];
j=handles.model.delft3dflow.domain(ad).activeOpenBoundary;
for i=1:size(data,1)
    handles.model.delft3dflow.domain(ad).harmonicComponents(i)=data{i,2};
    handles.model.delft3dflow.domain(ad).openBoundaries(j).harmonicAmpA(i)=data{i,3};
    handles.model.delft3dflow.domain(ad).openBoundaries(j).harmonicPhaseA(i)=data{i,4};
    handles.model.delft3dflow.domain(ad).openBoundaries(j).harmonicAmpB(i)=data{i,5};
    handles.model.delft3dflow.domain(ad).openBoundaries(j).harmonicPhaseB(i)=data{i,6};
end
if size(data,1)<handles.model.delft3dflow.domain(ad).nrHarmonicComponents
    for j=1:handles.model.delft3dflow.domain(ad).nrOpenBoundaries
        if j~=handles.activeOpenBoundary
            handles.model.delft3dflow.domain(ad).openBoundaries(j).harmonicAmpA=handles.model.delft3dflow.domain(ad).openBoundaries(j).harmonicAmpA(1:size(data,1));
            handles.model.delft3dflow.domain(ad).openBoundaries(j).harmonicPhaseA=handles.model.delft3dflow.domain(ad).openBoundaries(j).harmonicPhaseA(1:size(data,1));
            handles.model.delft3dflow.domain(ad).openBoundaries(j).harmonicAmpB=handles.model.delft3dflow.domain(ad).openBoundaries(j).harmonicAmpB(1:size(data,1));
            handles.model.delft3dflow.domain(ad).openBoundaries(j).harmonicPhaseB=handles.model.delft3dflow.domain(ad).openBoundaries(j).harmonicPhaseB(1:size(data,1));
        end
    end
elseif size(data,1)>handles.model.delft3dflow.domain(ad).nrHarmonicComponents
    for j=1:handles.model.delft3dflow.domain(ad).nrOpenBoundaries
        if j~=handles.model.delft3dflow.domain(ad).activeOpenBoundary
            for i=handles.model.delft3dflow.domain(ad).nrHarmonicComponents:size(data,1)
                handles.model.delft3dflow.domain(ad).openBoundaries(j).harmonicAmpA(i)=0;
                handles.model.delft3dflow.domain(ad).openBoundaries(j).harmonicPhaseA(i)=0;
                handles.model.delft3dflow.domain(ad).openBoundaries(j).harmonicAmpB(i)=0;
                handles.model.delft3dflow.domain(ad).openBoundaries(j).harmonicPhaseB(i)=0;
            end
        end
    end
end
handles.model.delft3dflow.domain(ad).nrHarmonicComponents=size(data,1);
setHandles(handles);
closereq;

%%
function PushCancel_CallBack(hObject,eventdata)
closereq;

%%
function refreshPeriod

handles=guidata(gcf);

data=gui_table(handles.GUIHandles.table,'getdata');

nr=size(data,1);

for i=2:min(nr,8)
    frq=data{i,2};
    if frq>0
        per=360/frq;
        perh=floor(per);
        perm=floor((per-perh)*60);
        k=(per-perh-perm/60);
        pers=round((per-perh-perm/60)*3600);
        data{i,1}=[num2str(perh,'%0.2i') 'h ' num2str(perm,'%0.2i') 'm ' num2str(pers,'%0.2i') 's '];
    else
        data{i,1}='';
    end
end
gui_table(handles.GUIHandles.table,'setdata',data);

