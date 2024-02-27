function ddb_Delft3DFLOW_editTracers
%DDB_DELFT3DFLOW_EDITTRACERS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_Delft3DFLOW_editTracers
%
%   Input:

%
%
%
%
%   Example
%   ddb_Delft3DFLOW_editTracers
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

% $Id: ddb_Delft3DFLOW_editTracers.m 10501 2014-04-08 22:21:18Z ormondt $
% $Date: 2014-04-09 06:21:18 +0800 (Wed, 09 Apr 2014) $
% $Author: ormondt $
% $Revision: 10501 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/models/Delft3DFLOW/gui/ddb_Delft3DFLOW_editTracers.m $
% $Keywords: $

%%
handles=getHandles;

MakeNewWindow('Processes :  Pollutants and Tracers',[360 290],'modal',[handles.settingsDir filesep 'icons' filesep 'deltares.gif']);

if handles.model.delft3dflow.domain(ad).nrTracers>0
    for i=1:handles.model.delft3dflow.domain(ad).nrTracers
        str{i}=handles.model.delft3dflow.domain(ad).tracer(i).name;
        handles.model.delft3dflow.domain(ad).tracer(i).new=0;
    end
else
    str{1}='';
end

handles.GUIHandles.ListTracers    = uicontrol(gcf,'Style','listbox','String',str,    'Position',[30 30 150 200],'BackgroundColor',[1 1 1]);
handles.GUIHandles.EditTracerName = uicontrol(gcf,'Style','edit',   'String',str{1},'HorizontalAlignment','left','Position',[30 240 150 20],'BackgroundColor',[1 1 1]);

handles.GUIHandles.PushRename     = uicontrol(gcf,'Style','pushbutton','String','Rename','Position',[200 240 60 20]);
handles.GUIHandles.PushAdd        = uicontrol(gcf,'Style','pushbutton','String','Add',   'Position',[200 215 60 20]);
handles.GUIHandles.PushDelete     = uicontrol(gcf,'Style','pushbutton','String','Delete','Position',[200 190 60 20]);

handles.GUIHandles.PushOK     = uicontrol(gcf,'Style','pushbutton','String','OK',    'Position',[270 30 60 30]);
handles.GUIHandles.PushCancel = uicontrol(gcf,'Style','pushbutton','String','Cancel','Position',[200 30 60 30]);

set(handles.GUIHandles.ListTracers, 'CallBack',{@ListTracers_Callback});
set(handles.GUIHandles.PushRename,  'CallBack',{@PushRename_Callback});
set(handles.GUIHandles.PushAdd,     'CallBack',{@PushAdd_Callback});
set(handles.GUIHandles.PushDelete,  'CallBack',{@PushDelete_Callback});

set(handles.GUIHandles.PushOK,      'CallBack',{@PushOK_Callback});
set(handles.GUIHandles.PushCancel,  'CallBack',{@PushCancel_Callback});

guidata(gcf,handles);

uiwait(gcf);

%%
function PushAdd_Callback(hObject,eventdata)
handles=guidata(gcf);

name=deblank(get(handles.GUIHandles.EditTracerName,'String'));
if ~isempty(name)
    iex=0;
    for i=1:handles.model.delft3dflow.domain(ad).nrTracers
        if strcmpi(handles.model.delft3dflow.domain(ad).tracer(i).name,name)
            iex=1;
        end
    end
    if ~iex
        handles.model.delft3dflow.domain(ad).nrTracers=handles.model.delft3dflow.domain(ad).nrTracers+1;
        ii=handles.model.delft3dflow.domain(ad).nrTracers;
        handles.model.delft3dflow.domain(ad).tracer(ii).name=name;
        handles.model.delft3dflow.domain(ad).tracer(ii).new=1;
        handles.model.delft3dflow.domain(ad).bccChanged=1;
        str=[];
        for i=1:handles.model.delft3dflow.domain(ad).nrTracers
            str{i}=handles.model.delft3dflow.domain(ad).tracer(i).name;
        end
        set(handles.GUIHandles.ListTracers,'String',str);
        set(handles.GUIHandles.ListTracers,'Value',ii);
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

%%
function PushRename_Callback(hObject,eventdata)
handles=guidata(gcf);
ii=get(handles.GUIHandles.ListTracers,'Value');
name=deblank(get(handles.GUIHandles.EditTracerName,'String'));
if ~isempty(name)
    handles.model.delft3dflow.domain(ad).tracer(ii).name=name;
    handles.model.delft3dflow.domain(ad).bccChanged=1;
    str=[];
    for i=1:handles.model.delft3dflow.domain(ad).nrTracers
        str{i}=handles.model.delft3dflow.domain(ad).tracer(i).name;
    end
    set(handles.GUIHandles.ListTracers,'String',str);
    guidata(gcf,handles);
end

%%
function PushDelete_Callback(hObject,eventdata)
handles=guidata(gcf);


ii=get(handles.GUIHandles.ListTracers,'Value');
nr=handles.model.delft3dflow.domain(ad).nrTracers;
if nr>0
    handles.model.delft3dflow.domain(ad).bccChanged=1;
    if nr==1
        handles.model.delft3dflow.domain(ad).tracer=[];
        iac=1;
    else
        for i=ii:nr-1
            handles.model.delft3dflow.domain(ad).tracer(i)=handles.model.delft3dflow.domain(ad).tracer(i+1);
        end
        handles.tracer=handles.model.delft3dflow.domain(ad).tracer(1:end-1);
        iac=ii;
    end
    if iac>nr-1
        iac=nr-1;
    end
    iac=max(iac,1);
    handles.model.delft3dflow.domain(ad).nrTracers=nr-1;
    str{1}=' ';
    for i=1:handles.model.delft3dflow.domain(ad).nrTracers
        str{i}=handles.model.delft3dflow.domain(ad).tracer(i).name;
    end
    set(handles.GUIHandles.ListTracers,'Value',iac);
    set(handles.GUIHandles.ListTracers,'String',str);
    guidata(gcf,handles);
end

%%
function ListTracers_Callback(hObject,eventdata)
handles=guidata(gcf);


ii=get(hObject,'Value');
str=get(hObject,'String');
set(handles.GUIHandles.EditTracerName,'String',str{ii});

%%
function PushOK_Callback(hObject,eventdata)

h2=getHandles;
handles=guidata(gcf);


h2.model.delft3dflow.domain(ad).tracer=handles.model.delft3dflow.domain(ad).tracer;
h2.model.delft3dflow.domain(ad).nrTracers=handles.model.delft3dflow.domain(ad).nrTracers;
h2.model.delft3dflow.domain(ad).bccChanged=handles.model.delft3dflow.domain(ad).bccChanged;
for ii=1:handles.model.delft3dflow.domain(ad).nrTracers
    if handles.model.delft3dflow.domain(ad).tracer(ii).new
        h2=ddb_initializeTracer(h2,ad,ii);
    end
end
if handles.model.delft3dflow.domain(ad).nrTracers==0
    h2.model.delft3dflow.domain(ad).tracers=0;
else
    h2.model.delft3dflow.domain(ad).tracers=1;
end

setHandles(h2);

closereq;

%%
function PushCancel_Callback(hObject,eventdata)
closereq;


