function ddb_Delft3DFLOW_editSediments
%DDB_DELFT3DFLOW_EDITSEDIMENTS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_Delft3DFLOW_editSediments
%
%   Input:

%
%
%
%
%   Example
%   ddb_Delft3DFLOW_editSediments
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

% $Id: ddb_Delft3DFLOW_editSediments.m 10501 2014-04-08 22:21:18Z ormondt $
% $Date: 2014-04-09 06:21:18 +0800 (Wed, 09 Apr 2014) $
% $Author: ormondt $
% $Revision: 10501 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/models/Delft3DFLOW/gui/ddb_Delft3DFLOW_editSediments.m $
% $Keywords: $

%%
handles=getHandles;

MakeNewWindow('Processes :  Sediments',[360 290],'modal',[handles.settingsDir filesep 'icons' filesep 'deltares.gif']);

if handles.model.delft3dflow.domain(ad).nrSediments>0
    for i=1:handles.model.delft3dflow.domain(ad).nrSediments
        str{i}=handles.model.delft3dflow.domain(ad).sediment(i).name;
        handles.model.delft3dflow.domain(ad).sediment(i).new=0;
    end
else
    str{1}='';
end

handles.GUIHandles.ListSediments    = uicontrol(gcf,'Style','listbox','String',str,    'Position',[30 30 150 200],'BackgroundColor',[1 1 1]);
handles.GUIHandles.EditSedimentName = uicontrol(gcf,'Style','edit','HorizontalAlignment','left','Position',[30 240 150 20],'BackgroundColor',[1 1 1]);

handles.GUIHandles.selectSedimentType = uicontrol(gcf,'Style','popupmenu',   'String',{'non-cohesive','cohesive'},'Position',[200 240 100 20],'BackgroundColor',[1 1 1]);

handles.GUIHandles.PushRename     = uicontrol(gcf,'Style','pushbutton','String','Rename','Position',[200 210 60 20]);
handles.GUIHandles.PushAdd        = uicontrol(gcf,'Style','pushbutton','String','Add',   'Position',[200 185 60 20]);
handles.GUIHandles.PushDelete     = uicontrol(gcf,'Style','pushbutton','String','Delete','Position',[200 160 60 20]);

handles.GUIHandles.PushOK     = uicontrol(gcf,'Style','pushbutton','String','OK',    'Position',[270 30 60 30]);
handles.GUIHandles.PushCancel = uicontrol(gcf,'Style','pushbutton','String','Cancel','Position',[200 30 60 30]);

set(handles.GUIHandles.ListSediments, 'CallBack',{@ListSediments_Callback});
set(handles.GUIHandles.PushRename,  'CallBack',{@PushRename_Callback});
set(handles.GUIHandles.PushAdd,     'CallBack',{@PushAdd_Callback});
set(handles.GUIHandles.PushDelete,  'CallBack',{@PushDelete_Callback});
set(handles.GUIHandles.selectSedimentType, 'CallBack',{@selectSedimentType_Callback});

set(handles.GUIHandles.PushOK,      'CallBack',{@PushOK_Callback});
set(handles.GUIHandles.PushCancel,  'CallBack',{@PushCancel_Callback});

guidata(gcf,handles);

refreshSedimentType(handles);
refreshSedimentName(handles);

uiwait(gcf);

%%
function PushAdd_Callback(hObject,eventdata)
handles=guidata(gcf);

name=deblank(get(handles.GUIHandles.EditSedimentName,'String'));
if length(name)>8
    if strcmpi(name(1:8),'sediment')
        if ~isempty(name)
            iex=0;
            for i=1:handles.model.delft3dflow.domain(ad).nrSediments
                if strcmpi(handles.model.delft3dflow.domain(ad).sediment(i).name,name)
                    iex=1;
                end
            end
            if ~iex
                handles.model.delft3dflow.domain(ad).bccChanged=1;
                handles.model.delft3dflow.domain(ad).nrSediments=handles.model.delft3dflow.domain(ad).nrSediments+1;
                ii=handles.model.delft3dflow.domain(ad).nrSediments;
                handles.model.delft3dflow.domain(ad).sediment(ii).name=name;
                
                it=get(handles.GUIHandles.selectSedimentType,'Value');
                if it==1
                    handles.model.delft3dflow.domain(ad).sediment(ii).type='non-cohesive';
                else
                    handles.model.delft3dflow.domain(ad).sediment(ii).type='cohesive';
                end
                
                handles.model.delft3dflow.domain(ad).sediment(ii).new=1;
                str=[];
                for i=1:handles.model.delft3dflow.domain(ad).nrSediments
                    str{i}=handles.model.delft3dflow.domain(ad).sediment(i).name;
                end
                set(handles.GUIHandles.ListSediments,'String',str);
                set(handles.GUIHandles.ListSediments,'Value',ii);
                
                guidata(gcf,handles);
                
                switch lower(handles.model.delft3dflow.domain(ad).initialConditions)
                    case{'ini'}
                        ddb_giveWarning('text',['The initial conditions file (*.ini) may not contain values for ' name '! If it does not, regenerate it with the Model Maker toolbox.']);
                    case{'trim','rst'}
                        ddb_giveWarning('text',['The initial conditions file may not contain values for ' name '!']);
                end
                
            else
                ddb_giveWarning('text','A constituent with this name already exists!')
            end
        end
    else
        set(handles.GUIHandles.EditSedimentName,'String','Sediment');
        ddb_giveWarning('text','Name must start with "Sediment"!')
    end
else
    set(handles.GUIHandles.EditSedimentName,'String','Sediment');
    ddb_giveWarning('text','Name must start with "Sediment"!')
end

%%
function PushRename_Callback(hObject,eventdata)
handles=guidata(gcf);
ii=get(handles.GUIHandles.ListSediments,'Value');
name=deblank(get(handles.GUIHandles.EditSedimentName,'String'));
if length(name)>8
    if strcmpi(name(1:8),'sediment')
        if ~isempty(name)
            handles.model.delft3dflow.domain(ad).bccChanged=1;
            handles.model.delft3dflow.domain(ad).sediment(ii).name=name;
            str=[];
            for i=1:handles.model.delft3dflow.domain(ad).nrSediments
                str{i}=handles.model.delft3dflow.domain(ad).sediment(i).name;
            end
            set(handles.GUIHandles.ListSediments,'String',str);
            guidata(gcf,handles);
        end
    else
        set(handles.GUIHandles.EditSedimentName,'String',handles.model.delft3dflow.domain(ad).sediment(ii).name);
        ddb_giveWarning('text','Name must start with "Sediment"!')
    end
else
    set(handles.GUIHandles.EditSedimentName,'String',handles.model.delft3dflow.domain(ad).sediment(ii).name);
    ddb_giveWarning('text','Name must start with "Sediment"!')
end

%%
function PushDelete_Callback(hObject,eventdata)
handles=guidata(gcf);
ii=get(handles.GUIHandles.ListSediments,'Value');
nr=handles.model.delft3dflow.domain(ad).nrSediments;
if nr>0
    handles.model.delft3dflow.domain(ad).bccChanged=1;
    if nr==1
        handles.model.delft3dflow.domain(ad).sediment=[];
        iac=1;
    else
        for i=ii:nr-1
            handles.model.delft3dflow.domain(ad).sediment(i)=handles.model.delft3dflow.domain(ad).sediment(i+1);
        end
        handles.sediment=handles.model.delft3dflow.domain(ad).sediment(1:end-1);
        iac=ii;
    end
    if iac>nr-1
        iac=nr-1;
    end
    iac=max(iac,1);
    handles.model.delft3dflow.domain(ad).nrSediments=nr-1;
    str{1}=' ';
    for i=1:handles.model.delft3dflow.domain(ad).nrSediments
        str{i}=handles.model.delft3dflow.domain(ad).sediment(i).name;
    end
    set(handles.GUIHandles.ListSediments,'Value',iac);
    set(handles.GUIHandles.ListSediments,'String',str);
    guidata(gcf,handles);
    refreshSedimentType(handles);
    refreshSedimentName(handles);
end

%%
function ListSediments_Callback(hObject,eventdata)
handles=guidata(gcf);
if handles.model.delft3dflow.domain(ad).nrSediments>0
    ii=get(hObject,'Value');
    str=get(hObject,'String');
    set(handles.GUIHandles.EditSedimentName,'String',str{ii});
    refreshSedimentType(handles);
end

%%
function selectSedimentType_Callback(hObject,eventdata)
handles=guidata(gcf);
% ii=get(hObject,'Value');
% iac=get(handles.GUIHandles.ListSediments,'Value');
% if ii==1
%     handles.model.delft3dflow.domain(ad).sediment(iac).type='non-cohesive';
% else
%     handles.model.delft3dflow.domain(ad).sediment(iac).type='cohesive';
% end
guidata(gcf,handles);

%%
function PushOK_Callback(hObject,eventdata)

h2=getHandles;
handles=guidata(gcf);

h2.model.delft3dflow.domain(ad).sediment=handles.model.delft3dflow.domain(ad).sediment;
h2.model.delft3dflow.domain(ad).nrSediments=handles.model.delft3dflow.domain(ad).nrSediments;
h2.model.delft3dflow.domain(ad).bccChanged=handles.model.delft3dflow.domain(ad).bccChanged;
h2.model.delft3dflow.domain(ad).sedimentNames=[];
for ii=1:handles.model.delft3dflow.domain(ad).nrSediments
    if handles.model.delft3dflow.domain(ad).sediment(ii).new
        h2=ddb_initializeSediment(h2,ad,ii);
    end
    h2.model.delft3dflow.domain(ad).sediments.sedimentNames{ii}=handles.model.delft3dflow.domain(ad).sediment(ii).name;
end
if handles.model.delft3dflow.domain(ad).nrSediments==0
    h2.model.delft3dflow.domain(ad).sediments.include=0;
else
    h2.model.delft3dflow.domain(ad).sediments.include=1;
end
setHandles(h2);

closereq;

%%
function PushCancel_Callback(hObject,eventdata)
closereq;

%%
function refreshSedimentType(handles)
if handles.model.delft3dflow.domain(ad).nrSediments>0
    ii=get(handles.GUIHandles.ListSediments,'Value');
    switch handles.model.delft3dflow.domain(ad).sediment(ii).type
        case{'non-cohesive'}
            set(handles.GUIHandles.selectSedimentType,'Value',1);
        case{'cohesive'}
            set(handles.GUIHandles.selectSedimentType,'Value',2);
    end
end

%%
function refreshSedimentName(handles)
if handles.model.delft3dflow.domain(ad).nrSediments>0
    ii=get(handles.GUIHandles.ListSediments,'Value');
    set(handles.GUIHandles.EditSedimentName,'String',handles.model.delft3dflow.domain(ad).sediment(ii).name);
else
    set(handles.GUIHandles.EditSedimentName,'String','Sediment');
end

