function foundStringNr = findStringUI(strs)
%FINDSTRINGUI  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = findStringUI(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   findStringUI
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
% Created: 27 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: findStringUI.m 6828 2012-07-09 15:30:22Z ormondt $
% $Date: 2012-07-09 23:30:22 +0800 (Mon, 09 Jul 2012) $
% $Author: ormondt $
% $Revision: 6828 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/gui/findStringUI.m $
% $Keywords: $

%%

handles.SearchWindow    = MakeNewWindow('Find',[295 320],'modal');
bgc = get(gcf,'Color');

handles.ListCS     = uicontrol(gcf,'Style','listbox','String',{''},'Position', [ 20 100 255 200],'BackgroundColor',[1 1 1]);
handles.TextString = uicontrol(gcf,'Style','text','string','search :','Position', [ 20 66 50 20],'BackgroundColor',bgc,'HorizontalAlignment','left');
handles.EditString = uicontrol(gcf,'Style','edit','String','','Position', [ 70 70 205 20],'BackgroundColor',[1 1 1],'HorizontalAlignment','left');
handles.PushCancel = uicontrol(gcf,'Style','pushbutton','String','Cancel','Position', [ 170 20 50 20]);
handles.PushOK     = uicontrol(gcf,'Style','pushbutton','String','OK','Position', [ 225 20 50 20]);

set(handles.EditString,     'CallBack',{@EditString_CallBack});
set(handles.ListCS,         'CallBack',{@ListCS_CallBack});
set(handles.PushCancel,     'CallBack',{@PushCancel_CallBack});
set(handles.PushOK,         'CallBack',{@PushOK_CallBack});

handles.Strings=strs;

handles.foundStringNr=[];

guidata(gcf,handles);

uiwait;

handles=guidata(gcf);

if ~isempty(handles.foundStringNr)
    foundStringNr=handles.foundStringNr;
else
    foundStringNr=[];
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
%handles=guidata(gcf);
%handles.Code=[];
%guidata(gcf,handles);
uiresume;

%%
function PushOK_CallBack(hObject,eventdata)
uiresume;

