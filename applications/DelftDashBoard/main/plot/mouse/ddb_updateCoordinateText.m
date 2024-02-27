function ddb_updateCoordinateText(pnt, dummy)
%DDB_UPDATECOORDINATETEXT  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_updateCoordinateText(pnt, dummy)
%
%   Input:
%   pnt   =
%   dummy =
%
%
%
%
%   Example
%   ddb_updateCoordinateText
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
ax=handles.GUIHandles.mapAxis;

pos = get(ax, 'CurrentPoint');
posx=pos(1,1);
posy=pos(1,2);
xlim=get(ax,'xlim');
ylim=get(ax,'ylim');
strx='X : ';
stry='Y : ';
strz='Z : ';
stranchor='';

if posx<=xlim(1) || posx>=xlim(2) || posy<=ylim(1) || posy>=ylim(2)
    set(gcf,'Pointer','arrow');
else
    setptr(gcf,pnt);
    if strcmpi(handles.screenParameters.coordinateSystem.type,'geographic')
        strx=['X : ' num2str(posx,'%10.4f')];
        stry=['Y : ' num2str(posy,'%10.4f')];
    else
        strx=['X : ' num2str(posx,'%10.0f')];
        stry=['Y : ' num2str(posy,'%10.0f')];
    end
    if strcmp(get(handles.GUIHandles.toolBar.anchor,'State'),'on')
        if ~isempty(handles.GUIHandles.anchorhandle)
            xa=get(handles.GUIHandles.anchorhandle,'XData');
            ya=get(handles.GUIHandles.anchorhandle,'YData');
            dx=posx-xa;
            dy=posy-ya;
            if strcmpi(handles.screenParameters.coordinateSystem.type,'geographic')
                dist=1000*pos2dist(ya,xa,posy,posx,2);
            else
                dist=sqrt(dx^2+dy^2);
            end
            if dist<10000
                stranchor=['Distance : ' num2str(dist,'%0.2f') ' m'];
            else
                stranchor=['Distance : ' num2str(0.001*dist,'%0.2f') ' km'];
            end
        end
    end
    try
        ix=round((posx-handles.GUIData.x(1))/(handles.GUIData.x(2)-handles.GUIData.x(1)));
        iy=round((posy-handles.GUIData.y(1))/(handles.GUIData.y(2)-handles.GUIData.y(1)));
        if ix>0 && ix<length(handles.GUIData.x) && iy>0 && iy<length(handles.GUIData.y)
            strz=['Z : ' num2str(handles.GUIData.z(iy,ix),'%10.1f')];
        end
    catch
        strz='Z : ';
    end
end

set(handles.GUIHandles.textXCoordinate,'String',strx);
set(handles.GUIHandles.textYCoordinate,'String',stry);
set(handles.GUIHandles.textZCoordinate,'String',strz);
set(handles.GUIHandles.textAnchor,'String',stranchor);

% set(gca,'FontSize',8);
% grid on;

function dist = pos2dist(lag1,lon1,lag2,lon2,method)
% function dist = pos2dist(lag1,lon1,lag2,lon2,method)
% calculate distance between two points on earth's surface
% given by their latitude-longitude pair.
% Input lag1,lon1,lag2,lon2 are in degrees, without 'NSWE' indicators.
% Input method is 1 or 2. Default is 1.
% Method 1 uses plane approximation,
% only for points within several tens of kilometers (angles in rads):
% d =
% sqrt(R_equator^2*(lag1-lag2)^2 + R_polar^2*(lon1-lon2)^2*cos((lag1+lag2)/2)^2)
% Method 2 calculates sphereic geodesic distance for points farther apart,
% but ignores flattening of the earth:
% d =
% R_aver * acos(cos(lag1)cos(lag2)cos(lon1-lon2)+sin(lag1)sin(lag2))
% Output dist is in km.
% Returns -99999 if input argument(s) is/are incorrect.
% Flora Sun, University of Toronto, Jun 12, 2004.
if nargin < 4
    dist = -99999;
    disp('Number of input arguments error! distance = -99999');
    return;
end
if abs(lag1)>90 | abs(lag2)>90 | abs(lon1)>360 | abs(lon2)>360
    dist = -99999;
    disp('Degree(s) illegal! distance = -99999');
    return;
end
if lon1 < 0
    lon1 = lon1 + 360;
end
if lon2 < 0
    lon2 = lon2 + 360;
end
% Default method is 1.
if nargin == 4
    method == 1;
end
if method == 1
    km_per_deg_la = 111.3237;
    km_per_deg_lo = 111.1350;
    km_la = km_per_deg_la * (lag1-lag2);
    % Always calculate the shorter arc.
    if abs(lon1-lon2) > 180
        dif_lo = abs(lon1-lon2)-180;
    else
        dif_lo = abs(lon1-lon2);
    end
    km_lo = km_per_deg_lo * dif_lo * cos((lag1+lag2)*pi/360);
    dist = sqrt(km_la^2 + km_lo^2);
else
    R_aver = 6374;
    deg2rad = pi/180;
    lag1 = lag1 * deg2rad;
    lon1 = lon1 * deg2rad;
    lag2 = lag2 * deg2rad;
    lon2 = lon2 * deg2rad;
    dist = R_aver * acos(cos(lag1)*cos(lag2)*cos(lon1-lon2) + sin(lag1)*sin(lag2));
end

