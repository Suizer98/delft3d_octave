function ddb_dragLine(fcn, varargin)
%DDB_DRAGLINE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_dragLine(fcn, varargin)
%
%   Input:
%   fcn      =
%   varargin =
%
%
%
%
%   Example
%   ddb_dragLine
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

% $Id: ddb_dragLine.m 6807 2012-07-06 17:02:23Z ormondt $
% $Date: 2012-07-07 01:02:23 +0800 (Sat, 07 Jul 2012) $
% $Author: ormondt $
% $Revision: 6807 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/plot/ddb_dragLine.m $
% $Keywords: $

%%

x=[];
y=[];
method='free';

for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'method'}
                method=lower(varargin{i+1});
            case{'x'}
                x=varargin{i+1};
            case{'y'}
                y=varargin{i+1};
        end
    end
end

set(gcf, 'windowbuttondownfcn',{@dragLine,fcn,method,x,y});
set(gcf, 'windowbuttonmotionfcn',[]);

%%
function dragLine(src,eventdata,fcn,method,xg,yg)

set(gcf, 'windowbuttonmotionfcn', {@followTrack});
set(gcf, 'windowbuttonupfcn',     {@stopTrack});

pos = get(gca, 'CurrentPoint');
posx=pos(1,1);
posy=pos(1,2);

if strcmp(method,'alonggridline')
    [m1,n1]=findcornerpoint(posx,posy,xg,yg);
    posx=xg(m1,n1);
    posy=yg(m1,n1);
end

% usd.opt=opt;

usd.x=[posx posx];
usd.y=[posy posy];
usd.z=[9000 9000];
usd.Line=plot3(usd.x,usd.y,usd.z);

usd.LineColor='g';
usd.LineWidth=2;
usd.LineStyle='-';

set(usd.Line,'LineWidth',usd.LineWidth);
set(usd.Line,'LineStyle',usd.LineStyle);
set(usd.Line,'Color',usd.LineColor);

set(0,'UserData',usd);

waitfor(0,'userdata',[]);

h=findobj(gcf,'Tag','DraggedLine');
if ~isempty(h)
    usd=get(h,'UserData');
    x=usd.x;
    y=usd.y;
    delete(h);
    xax=get(gca,'XLim');
    yax=get(gca,'YLim');
    % Make sure line is inside axis
    if x(1)>xax(1) && x(1)<xax(2) && x(2)>xax(1) && x(2)<xax(2) && y(1)>yax(1) && y(1)<yax(2) && y(2)>yax(1) && y(2)<yax(2)
        fcn(x,y);
    end
end

%%
function followTrack(imagefig, varargins)
usd=get(0,'UserData');
pos = get(gca, 'CurrentPoint');
posx=pos(1,1);
posy=pos(1,2);
usd.x(2)=posx;
usd.y(2)=posy;
usd.z(2)=9000;
set(usd.Line,'XData',usd.x);
set(usd.Line,'YData',usd.y);
set(usd.Line,'ZData',usd.z);
set(0,'UserData',usd);
%ddb_updateCoordinateText('arrow');

%%
function stopTrack(imagefig, varargins)
ddb_setWindowButtonMotionFcn;
set(gcf, 'windowbuttonupfcn',[]);
usd=get(0,'UserData');
set(usd.Line,'UserData',usd);
set(usd.Line,'Tag','DraggedLine');
set(0,'UserData',[]);

