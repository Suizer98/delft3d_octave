function ddb_zoomScrollWheel(src, evnt)
%DDB_ZOOMSCROLLWHEEL  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_zoomScrollWheel(src, evnt)
%
%   Input:
%   src  =
%   evnt =
%
%
%
%
%   Example
%   ddb_zoomScrollWheel
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
handles=getHandles;

xl=get(handles.GUIHandles.mapAxis,'xlim');
yl=get(handles.GUIHandles.mapAxis,'ylim');

posax=get(handles.GUIHandles.mapAxis,'Position');

zm=0.8;

pgcf=get(gcf,'CurrentPoint');

dx0=(xl(2)-xl(1))*(pgcf(1)-posax(1))/posax(3);
dy0=(yl(2)-yl(1))*(pgcf(2)-posax(2))/posax(4);
x0=xl(1)+dx0;
y0=yl(1)+dy0;

point = get(handles.GUIHandles.mapAxis,'CurrentPoint');

if point(1,1)>xl(1) && point(1,1)<xl(2) && point(1,2)>yl(1) && point(1,2)<yl(2)
    
    if evnt.VerticalScrollCount<0
        p1(1)=x0-zm*dx0;
        p1(2)=y0-zm*dy0;
        offset(1)=((xl(2)-xl(1))*zm);
        offset(2)=((yl(2)-yl(1))*zm);
    else
        p1(1)=x0-dx0/zm;
        p1(2)=y0-dy0/zm;
        offset(1)=((xl(2)-xl(1))/zm);
        offset(2)=((yl(2)-yl(1))/zm);
    end
    
    [xl,yl]=CompXYLim([p1(1) p1(1)+offset(1) ],[p1(2) p1(2)+offset(2)],handles.screenParameters.xMaxRange,handles.screenParameters.yMaxRange);
    
    set(handles.GUIHandles.mapAxis,'xlim',xl,'ylim',yl);
    handles.screenParameters.xLim=xl;
    handles.screenParameters.yLim=yl;
    setHandles(handles);
    
end

