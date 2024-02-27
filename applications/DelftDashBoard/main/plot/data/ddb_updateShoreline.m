function ddb_updateShoreline(handles)
%DDB_UPDATESHORELINE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_updateShoreline(handles)
%
%   Input:
%   handles =
%
%
%
%
%   Example
%   ddb_updateShoreline
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

iac=strmatch(lower(handles.screenParameters.shoreline),lower(handles.shorelines.names),'exact');

%% Determine limits
xl=get(gca,'xlim');
yl=get(gca,'ylim');
handles.shorelines.shoreline(iac).horizontalCoordinateSystem.name;
ldbCoord.name=handles.shorelines.shoreline(iac).horizontalCoordinateSystem.name;
ldbCoord.type=handles.shorelines.shoreline(iac).horizontalCoordinateSystem.type;
coord=handles.screenParameters.coordinateSystem;
if ~strcmpi(coord.name,ldbCoord.name)
    dx=(xl(2)-xl(1))/10;
    dy=(yl(2)-yl(1))/10;
    [xtmp,ytmp]=meshgrid(xl(1)-dx:dx:xl(2)+dx,yl(1)-dy:dy:yl(2)+dy);
    [xtmp2,ytmp2]=ddb_coordConvert(xtmp,ytmp,coord,ldbCoord);
    xl0(1)=min(min(xtmp2));
    xl0(2)=max(max(xtmp2));
    yl0(1)=min(min(ytmp2));
    yl0(2)=max(max(ytmp2));
else
    xl0=xl;
    yl0=yl;
end

%% Find require scale
dx=xl0(2)-xl0(1);
switch lower(ldbCoord.type)
    case{'geo','geographic','geographic 2d','geographic 3d','spherical','latlon'}
        dx=dx*111111*cos(pi*0.5*(yl0(1)+yl0(2))/180);
end
screenWidth=0.4;
requiredScale=dx/screenWidth;
ires=find(handles.shorelines.shoreline(iac).scale<requiredScale,1,'last');
if isempty(ires)
    ires=1;
end

%% Get Shoreline
[x,y]=ddb_getShoreline(handles,xl0,yl0,ires);
[x,y]=ddb_coordConvert(x,y,ldbCoord,coord);

%% Plot shoreline
%z=zeros(size(x))+500;
h=findobj(handles.GUIHandles.mainWindow,'Tag','shoreline','type','line');
%set(h,'XData',x,'YData',y,'ZData',z);
set(h,'XData',x,'YData',y);

