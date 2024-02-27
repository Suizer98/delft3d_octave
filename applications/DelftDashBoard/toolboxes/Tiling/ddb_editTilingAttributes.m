function attr = ddb_editTilingAttributes(attr)
%DDB_EDITTILINGATTRIBUTES  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   attr = ddb_editTilingAttributes(attr)
%
%   Input:
%   attr =
%
%   Output:
%   attr =
%
%   Example
%   ddb_editTilingAttributes
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

% $Id: ddb_editTilingAttributes.m 5560 2011-12-02 11:26:29Z boer_we $
% $Date: 2011-12-02 19:26:29 +0800 (Fri, 02 Dec 2011) $
% $Author: boer_we $
% $Revision: 5560 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/Tiling/ddb_editTilingAttributes.m $
% $Keywords: $

%%
f=fieldnames(attr);

nat=length(f);

sz=[480 nat*20+140];

handles.SearchWindow    = MakeNewWindow('Edit Attributes',sz,'modal');
bgc = get(gcf,'Color');

for i=1:nat
    handles.txt(i)=uicontrol(gcf,'Style','text','String',f{i},'Position', [  10 351-i*25 135 20],'HorizontalAlignment','right','Tag','UIControl');
    handles.obj(i)=uicontrol(gcf,'Style','edit','String','','Position', [ 150 355-i*25 300 20],'BackgroundColor',[1 1 1],'HorizontalAlignment','left','Tag','UIControl');
    set(handles.obj(i),'String',attr.(f{i}));
end

handles.PushCancel = uicontrol(gcf,'Style','pushbutton','String','Cancel','Position', [ 315 20 70 20],'Tag','UIControl');
handles.PushOK     = uicontrol(gcf,'Style','pushbutton','String','OK','Position', [ 390 20 70 20],'Tag','UIControl');

set(handles.PushCancel,     'CallBack',{@PushCancel_CallBack});
set(handles.PushOK,         'CallBack',{@PushOK_CallBack});

SetUIBackgroundColors;

guidata(gcf,handles);

uiwait;

handles=guidata(gcf);

if handles.ok
    for i=1:nat
        attr.(f{i})=get(handles.obj(i),'String');
    end
end

close(gcf);

%%
function EditString_CallBack(hObject,eventdata)

handles=guidata(gcf);
str=get(hObject,'String');

fnd=strfind(lower(handles.Strings),lower(str));
fnd = ~cellfun('isempty',fnd);
iind=find(fnd>0);

strs={''};
%handles.Code=[];
%handles.FoundCodes=[];
if ~isempty(iind)
    for i=1:length(iind)
        strs{i}=handles.Strings{iind(i)};
        %        handles.FoundCodes(i)=handles.Codes(iind(i));
    end
    set(handles.ListCS,'String',strs);
    handles.foundStingNr=iind(1);
    %    handles.Code=handles.Codes(iind(1));
end
guidata(gcf,handles);

%%
function ListCS_CallBack(hObject,eventdata)
handles=guidata(gcf);
strs=get(handles.ListCS,'String');
foundString=strs{get(hObject,'Value')};
handles.foundStringNr=strmatch(foundString,handles.Strings,'exact');
%handles.Code=handles.FoundCodes(get(hObject,'Value'));
guidata(gcf,handles);

%%
function PushCancel_CallBack(hObject,eventdata)
handles=guidata(gcf);
handles.ok=0;
guidata(gcf,handles);
uiresume;

%%
function PushOK_CallBack(hObject,eventdata)
handles=guidata(gcf);
handles.ok=1;
guidata(gcf,handles);
uiresume;

