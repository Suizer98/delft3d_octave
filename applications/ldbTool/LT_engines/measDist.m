function measDist
%MEASDIST Measure distance in figure
%
% See also: LDBTOOL, DISTANCE, DRAWBAR

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Arjan Mol
%
%       arjan.mol@deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Code
% pick some boundaries

[but,fig]=gcbo;

uo = []; vo = []; button = [];

curAx=findall(0,'tag','LT_plotWindow');

set(findobj(fig,'tag','LT_ldbText6'),'String','Instructions: Click first point on the map, right click to cancel');

set(fig,'Pointer','crosshair');
waitforbuttonpress;
action = guidata(curAx); guidata(curAx,[]);
if isempty(action)
    if ~isempty(get(fig,'ResizeFcn'));
        % This only exists in the old version, lets continue:
        if strcmp(get(fig,'SelectionType'),'normal')
            pt = get(curAx,'CurrentPoint');
            action.Button = 1;
            action.IntersectionPoint(1) = pt(1,1);
            action.IntersectionPoint(2) = pt(1,2);
        else
            set(fig,'Pointer','arrow');
            set(findobj(fig,'tag','LT_ldbText6'),'String','Instructions:');
            return
        end
    else
        set(fig,'Pointer','arrow');
        set(findobj(fig,'tag','LT_ldbText6'),'String','Instructions:');
        return
    end
end
if ~isempty(action)
    b  = action.Button;
    uo = action.IntersectionPoint(1);
    vo = action.IntersectionPoint(2);
    if b~=3
        hold on; hp(1) = plot(uo,vo,'r+-');
    else
        set(fig,'Pointer','arrow');
        set(findobj(fig,'tag','LT_ldbText6'),'String','Instructions:');
        return
    end
end

set(findobj(fig,'tag','LT_ldbText6'),'String','Instructions: Click second point on the map, right click to cancel');

waitforbuttonpress;
action = guidata(curAx); guidata(curAx,[]);
if isempty(action)
    if ~isempty(get(fig,'ResizeFcn'));
        % This only exists in the old version, lets continue:
        if strcmp(get(fig,'SelectionType'),'normal')
            pt = get(curAx,'CurrentPoint');
            action.Button = 1;
            action.IntersectionPoint(1) = pt(1,1);
            action.IntersectionPoint(2) = pt(1,2);
        else
            set(fig,'Pointer','arrow');
            set(findobj(fig,'tag','LT_ldbText6'),'String','Instructions:');
            delete(hp);
            return
        end
    else
        sset(fig,'Pointer','arrow');
        set(findobj(fig,'tag','LT_ldbText6'),'String','Instructions:');
        delete(hp);
        return
    end
end
if ~isempty(action)
    b      = action.Button;
    un = action.IntersectionPoint(1);
    vn = action.IntersectionPoint(2);
    if b~=3
        hold on; hp(2) = plot(un,vn,'r+-');
    else
        set(fig,'Pointer','arrow');
        set(findobj(fig,'tag','LT_ldbText6'),'String','Instructions:');
        delete(hp);
        return
    end
end

set(findobj(fig,'tag','LT_ldbText6'),'String','Instructions:');
set(fig,'Pointer','arrow');

uiwait(msgbox(['Distance is ' num2str(sqrt(diff([uo un])^2+diff([vo vn])^2),'%12.3f')]));

delete(hp);