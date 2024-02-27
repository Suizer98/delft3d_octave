function ddb_pan(src, eventdata, opt, callback1, varargin1, callback2, varargin2)
%DDB_ZOOMINOUTPAN  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_zoomInOutPan(src, eventdata, zoommode, callback1, varargin1, callback2, varargin2)
%
%   Input:
%   src       =
%   eventdata =
%   zoommode  =
%   callback1 =
%   varargin1 =
%   callback2 =
%   varargin2 =
%
%
%
%
%   Example
%   ddb_zoomInOutPan
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

%% Update Data, Figure handle

handles=getHandles;

switch eventdata.Key
    case{'a'}
        if strcmp(get(handles.GUIHandles.toolBar.anchor,'State'),'on')
            setAnchorPoint;
        end
        return
    case{'control'}
        
    otherwise
        return
end


if strcmp(opt,'stop') && handles.GUIHandles.panning
    stopPan(callback1, varargin1);
    return
end

if handles.GUIHandles.panning
    % Already panning
    return
end

% Current axis position
ax=handles.GUIHandles.mapAxis;
xl=get(ax,'xlim');
yl=get(ax,'ylim');
point1 = get(ax,'CurrentPoint');
point1=point1(1,1:2);

% Check if mouse is in current axis
if point1(1)>=xl(1) && point1(1)<=xl(2) && point1(2)>=yl(1) && point1(2)<=yl(2)
    % Start panning
    handles.GUIHandles.panning=1;
    % Set original functions
    handles.GUIHandles.windowbuttondownfcn=get(gcf,'windowbuttondownfcn');
    handles.GUIHandles.windowbuttonupfcn=get(gcf,'windowbuttonupfcn');
    handles.GUIHandles.windowbuttonmotionfcn=get(gcf,'windowbuttonmotionfcn');
    set(gcf, 'windowbuttonmotionfcn', {@PanMove,xl,yl,point1,handles.screenParameters.xMaxRange,handles.screenParameters.yMaxRange});
    setptr(gcf,'closedhand');    
    setHandles(handles);    
end

pan off;


%%
function PanMove(imagefig, varargins,xl0,yl0,pos0,xrange,yrange)
handles=getHandles;
xl1=get(handles.GUIHandles.mapAxis,'XLim');
yl1=get(handles.GUIHandles.mapAxis,'YLim');
pos1=get(handles.GUIHandles.mapAxis,'CurrentPoint');
pos1=pos1(1,1:2);
pos1(1)=xl0(1)+(xl0(2)-xl0(1))*(pos1(1)-xl1(1))/(xl1(2)-xl1(1));
pos1(2)=yl0(1)+(yl0(2)-yl0(1))*(pos1(2)-yl1(1))/(yl1(2)-yl1(1));
dpos=pos1-pos0;
xl=xl0-dpos(1);
yl=yl0-dpos(2);
[xl,yl]=CompXYLim(xl,yl,xrange,yrange);
set(handles.GUIHandles.mapAxis,'XLim',xl,'YLim',yl);
ddb_updateCoordinateText('closedhand');

%%
function stopPan(callback, varargin)

handles=getHandles;

handles.screenParameters.xLim=get(handles.GUIHandles.mapAxis,'XLim');
handles.screenParameters.yLim=get(handles.GUIHandles.mapAxis,'YLim');
handles.GUIHandles.panning=0;

setHandles(handles);

h=handles.GUIHandles.toolBar.autoRefreshBathymetry;

if ~isempty(h)
    if strcmp(get(h,'State'),'on')
        if isa(callback,'function_handle')
            if ~isempty(varargin)
                feval(callback, varargin{:});
            else
                feval(callback);
            end
        end
    end
else
    if isa(callback,'function_handle')
        if ~isempty(varargin)
            feval(callback, varargin{:});
        else
            feval(callback);
        end
    end
end

set(gcf,'windowbuttondownfcn',handles.GUIHandles.windowbuttondownfcn);
set(gcf,'windowbuttonupfcn',handles.GUIHandles.windowbuttonupfcn);
set(gcf,'windowbuttonmotionfcn',handles.GUIHandles.windowbuttonmotionfcn);

%%
function setAnchorPoint

handles=getHandles;

ax=handles.GUIHandles.mapAxis;
xl=get(ax,'xlim');
yl=get(ax,'ylim');
point1 = get(ax,'CurrentPoint');
point1=point1(1,1:2);

% Check if mouse is in current axis
if point1(1)>=xl(1) && point1(1)<=xl(2) && point1(2)>=yl(1) && point1(2)<=yl(2)
    if isempty(handles.GUIHandles.anchorhandle)
        p=plot(point1(1),point1(2),'r+');
        set(p,'MarkerSize',10);
        handles.GUIHandles.anchorhandle=p;
        setHandles(handles);
    else
        set(handles.GUIHandles.anchorhandle,'XData',point1(1));
        set(handles.GUIHandles.anchorhandle,'YData',point1(2));
    end    
end
