function LTPE_newPoint
%LTPE_NEWPOINT ldbTool GUI function to add a new point to the ldb, starting
%a new segment
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

%% Code

[but,fig]=gcbo;

curAx=findobj(fig,'tag','LT_plotWindow');

set(findobj(fig,'tag','LT_zoomBut'),'String','Zoom is off','value',0);
zoom off
set(fig,'pointer','arrow');

data=LT_getData;
ldb=data(5).ldb;
ldbCell=data(5).ldbCell;
ldbEnd=data(5).ldbEnd;
ldbBegin=data(5).ldbBegin;

if ~isnan(ldb(end,1))
ldb = [ldb ; nan nan];
end

ldb = [ldb ; nan nan];

insertPoints=1;
set(findobj(fig,'tag','LT_ldbText6'),'String','Instructions: click location of new points, right click when done');

tempId=length(ldbCell)+1;
while insertPoints==1
    set(fig,'Pointer','crosshair');
    waitforbuttonpress;
    action = guidata(curAx); guidata(curAx,[]);
    if isempty(action)
        % Possibly, this is an old Matlab version, check this:
        if ~isempty(get(fig,'ResizeFcn'));
            % This only exists in the old version, lets continue:
            if strcmp(get(fig,'SelectionType'),'extend')
                action.Button = 1;
                if new_pt_length > 2
                    b = 2;
                    action.Button = 2;
                end
                pt = get(curAx,'CurrentPoint');
                action.IntersectionPoint(1) = pt(1,1);
                action.IntersectionPoint(2) = pt(1,2);
            elseif strcmp(get(fig,'SelectionType'),'normal')
                pt = get(curAx,'CurrentPoint');
                action.Button = 1;
                action.IntersectionPoint(1) = pt(1,1);
                action.IntersectionPoint(2) = pt(1,2);
            else
                insertPoints=0;
            end
        else
            insertPoints=0;
        end
    end
    
    if ~isempty(action)
        b      = action.Button;
        xClick = action.IntersectionPoint(1);
        yClick = action.IntersectionPoint(2);
        new_pt_length = (size(ldb,1)-1) - max(find(isnan(ldb(1:end-1,1))));
        if b == 2 & new_pt_length > 2
            insertPoints=0;
            xClick = ldb(max(find(isnan(ldb(1:end-1,1))))+1,1);
            yClick = ldb(max(find(isnan(ldb(1:end-1,1))))+1,2);
        end
        if b~=3
            ldb=[ldb(1:end-1,:) ; xClick yClick; nan nan];
            nanId=find(isnan(ldb(:,1)));
            ldbCell{tempId}=ldb(nanId(end-1)+1:nanId(end)-1,:);
            ldbBegin(tempId,:)=ldbCell{tempId}(1,:);
            ldbEnd(tempId,:)=ldbCell{tempId}(end,:);
            LT_updateData(ldb,ldbCell,ldbBegin,ldbEnd);
        else
            insertPoints=0;
        end
        if new_pt_length == 2 & insertPoints
            set(findobj(fig,'tag','LT_ldbText6'),'String','Instructions: click location of new points, middle mouse to close the ldb-section, right click when done');
        end
    end
end

set(fig,'Pointer','arrow');

set(findobj(fig,'tag','LT_ldbText6'),'String','Instructions:');
set(findobj(fig,'tag','LT_saveMenu'),'enable','on');
set(findobj(fig,'tag','LT_save2Menu'),'enable','on');