function [x y] = DrawLine(LineColor, LineWidth, LineStyle)
%DRAWLINE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   [x y] = DrawLine(LineColor, LineWidth, LineStyle)
%
%   Input:
%   LineColor =
%   LineWidth =
%   LineStyle =
%
%   Output:
%   x         =
%   y         =
%
%   Example
%   DrawLine
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

x=[];
y=[];

set(gcf, 'windowbuttondownfcn',   {@StartTrack});
set(gcf, 'windowbuttonmotionfcn', {@MoveMouse});
set(gcf, 'windowbuttonupfcn',     {@StopTrack});
usd.x=[];
usd.y=[];
usd.Line=[];

usd.LineColor=LineColor;
usd.LineWidth=LineWidth;
usd.LineStyle=LineStyle;

set(0,'UserData',usd);

waitfor(0,'userdata',[]);

h=findall(gcf,'Tag','DraggedLine');
if ~isempty(h)
    usd=get(h,'UserData');
    x=usd.x;
    y=usd.y;
    delete(h);
end

%%
function StartTrack(imagefig, varargins)
set(gcf, 'windowbuttonmotionfcn', {@FollowTrack});
usd=get(0,'UserData');
pos = get(gca, 'CurrentPoint');
posx=pos(1,1);
posy=pos(1,2);
usd.x=posx;
usd.y=posy;
usd.z=9000;
usd.Line=plot3(usd.x,usd.y,usd.z);
set(usd.Line,'LineWidth',usd.LineWidth);
set(usd.Line,'LineStyle',usd.LineStyle);
set(usd.Line,'Color',usd.LineColor);
set(0,'UserData',usd);

%%
function FollowTrack(imagefig, varargins)
usd =get(gca,'UserData');
pos =get(gca, 'CurrentPoint');
posx=pos(1,1);
posy=pos(1,2);
usd.x(2)=posx;
usd.y(2)=posy;
usd.z(2)=9000;
set(usd.Line,'XData',usd.x);
set(usd.Line,'YData',usd.y);
set(usd.Line,'ZData',usd.z);
set(gca,'UserData',usd);
ddb_updateCoordinateText('arrow',[]);

%%
function StopTrack(imagefig, varargins)
handles=getHandles;
set(gcf, 'windowbuttonupfcn', []);
set(gcf, 'windowbuttonmotionfcn', handles.WindowButtonMotionFcn);
usd=get(0,'UserData');
set(usd.Line,'UserData',usd);
set(usd.Line,'Tag','DraggedLine');
set(0,'UserData',[]);

%%
function MoveMouse(imagefig, varargins)
ddb_updateCoordinateText('arrow',@StartTrack);

