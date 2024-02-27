function h = UIControlEdit(val, pos, struct1, i1, struct2, i2, par, i3, inptype, txtstr)
%UICONTROLEDIT  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   h = UIControlEdit(val, pos, struct1, i1, struct2, i2, par, i3, inptype, txtstr)
%
%   Input:
%   val     =
%   pos     =
%   struct1 =
%   i1      =
%   struct2 =
%   i2      =
%   par     =
%   i3      =
%   inptype =
%   txtstr  =
%
%   Output:
%   h       =
%
%   Example
%   UIControlEdit
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

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%

switch(lower(inptype))
    case{'string'}
        h = uicontrol(gcf,'Style','edit','String',val,'BackgroundColor',[1 1 1],'HorizontalAlignment','left');
        usd.Type='string';
    case{'real','integer'}
        h = uicontrol(gcf,'Style','edit','String',num2str(val),'BackgroundColor',[1 1 1],'HorizontalAlignment','right');
        usd.Type='real';
end

set(h,'Tag','UIControl','Position',pos);

usd.Struct1=struct1;
usd.Struct2=struct2;
usd.Par=par;
usd.Index1=i1;
usd.Index2=i2;
usd.Index3=i3;

set(h,'UserData',usd);
set(h, 'Callback',{@Edit_Callback});

if ~isempty(txtstr)
    tx=uicontrol(gcf,'Style','text','String',txtstr,'Position',[1 1 200 20],'HorizontalAlignment','right','Tag','UIControl');
    ext=get(tx,'Extent');
    postxt=[pos(1)-ext(3)-5 pos(2)-4 ext(3) 20];
    set(tx,'Position',postxt);
end

%%
function Edit_Callback(hObject,eventdata)

handles=getHandles;

str=get(hObject,'String');

usd=get(hObject,'UserData');

struct1=usd.Struct1;
struct2=usd.Struct2;
par=usd.Par;
i1=usd.Index1;
i2=usd.Index2;
i3=usd.Index3;
tp=usd.Type;

switch(lower(tp))
    case{'string'}
        if ~isempty(struct2)
            if iscell(handles.(struct1)(i1).(struct2)(i2).(par))
                handles.(struct1).(struct2).(par){i3}=str;
            else
                handles.(struct1)(i1).(struct2)(i2).(par)=str;
            end
        else
            if iscell(handles.(struct1)(i1).(par))
                handles.(struct1)(i1).(par){i3}=str;
            else
                handles.(struct1)(i1).(par)=str;
            end
        end
    case{'real','integer'}
        if ~isempty(struct2)
            handles.(struct1)(i1).(struct2)(i2).(par)(i3)=str2double(str);
        else
            handles.(struct1)(i1).(par)(i3)=str2double(str);
        end
end

setHandles(handles);


