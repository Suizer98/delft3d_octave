function LT_clickPoly
%LT_CLICKPOLY ldbTool GUI function to click a polygon
%
% See also: LDBTOOL

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

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 17 Aug 2012
% Created with Matlab version: 7.14.0.739 (R2012a)

% $Id: LT_clickPoly.m 14359 2018-05-18 09:59:39Z scheel $
% $Date: 2018-05-18 17:59:39 +0800 (Fri, 18 May 2018) $
% $Author: scheel $
% $Revision: 14359 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ldbTool/LT_gui/LT_clickPoly.m $
% $Keywords: $

%% Code
[but,fig]=gcbo;

% pick some boundaries
uo = []; vo = []; button = [];

curAx=findall(0,'tag','LT_plotWindow');

set(findobj(fig,'tag','LT_ldbText6'),'String','Instructions: use left mouse button to add points, right click when done');
set(findobj(gcf,'tag','LT_showPolygonBox'),'value',1);

set(fig,'Pointer','crosshair');
waitforbuttonpress;
action = guidata(curAx); guidata(curAx,[]);
if isempty(action)
    % Possibly, this is an old Matlab version, check this:
    if ~isempty(get(fig,'ResizeFcn'));
        % This only exists in the old version, lets continue:
        if strcmp(get(fig,'SelectionType'),'normal')
            pt = get(curAx,'CurrentPoint');
            action.Button = 1;
            action.IntersectionPoint(1) = pt(1,1);
            action.IntersectionPoint(2) = pt(1,2);
        else
            insertPoints=0;
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
        hold on;
        data=get(fig,'userdata');
        data(1,5).ldb=[uo vo];
        set(fig,'userdata',data);
        LT_plotLdb;
    else
        set(fig,'Pointer','arrow');
        set(findobj(fig,'tag','LT_ldbText6'),'String','Instructions:');
        return
    end
end

insertPoints = 1;
while insertPoints==1
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
                insertPoints=0;
            end
        else
            set(fig,'Pointer','arrow');
            set(findobj(fig,'tag','LT_ldbText6'),'String','Instructions:');
            return
        end
    end
    if ~isempty(action)
        b = action.Button;
        u = action.IntersectionPoint(1);
        v = action.IntersectionPoint(2);
        if b~=3
            uo=[uo;u]; vo=[vo;v];
            data=get(fig,'userdata');
            data(1,5).ldb=[uo vo];
            set(fig,'userdata',data);
            LT_plotLdb;
        else
            insertPoints=0;
        end
    end
end

set(fig,'Pointer','arrow');

set(findobj(fig,'tag','LT_ldbText6'),'String','Instructions:');
LTSE_selectSegmentsInPoly;
