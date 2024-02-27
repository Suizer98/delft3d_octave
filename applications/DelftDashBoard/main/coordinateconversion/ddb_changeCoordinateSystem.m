function ddb_changeCoordinateSystem
%DDB_CHANGECOORDINATESYSTEM  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_changeCoordinateSystem
%
%   Input:

%
%
%
%
%   Example
%   ddb_changeCoordinateSystem
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

NewSystem=handles.screenParameters.coordinateSystem;
OldSystem=handles.screenParameters.oldCoordinateSystem;

if ~strcmpi(NewSystem.name,OldSystem.name) || ~strcmpi(NewSystem.type,OldSystem.type)
    
    % This should only happen upon initialization
    
    xl=get(gca,'XLim');
    yl=get(gca,'YLim');
    
    [xl1,yl1]=ddb_coordConvert(xl,yl,OldSystem,NewSystem);
    
    lngth=length(NewSystem.name);
    nsys=lower(NewSystem.name(1:min(lngth,12)));
    
    if strcmpi(NewSystem.type,'Cartesian')
        set(handles.GUIHandles.textCoordinateSystem,'String',[NewSystem.name ' - Projected']);
    else
        set(handles.GUIHandles.textCoordinateSystem,'String',[NewSystem.name ' - Geographic']);
    end
    
    switch nsys,
        case{'wgs 84'}
            handles.screenParameters.xMaxRange=[-360 360];
            handles.screenParameters.yMaxRange=[-90 90];
        case{'wgs 84 / utm'}
            utmzone1=handles.screenParameters.UTMZone{1};
            utmzone2=handles.screenParameters.UTMZone{2};
            zn={'C','D','E','F','G','H','J','K','L','M','N','P','Q','R','S','T','U','V','W','X'};
            ii=strmatch(utmzone2,zn,'exact');
            dy=10000000*8/90;
            if ii>10
                % Northern Hemispere
                yutm1=(ii-11)*dy;
                yutm2=yutm1+dy;
            else
                % Southern Hemispere
                yutm1=(ii-11)*dy+10000000;
                yutm2=(ii-10)*dy+10000000;
            end
            xutm1=-200000;
            xutm2=1000000;
            handles.screenParameters.xMaxRange=[-2000000 3000000];
            handles.screenParameters.yMaxRange=[-2000000 10000000];
            if yl1(1)<yutm1 || yl1(1)>yutm2 || yl1(2)<yutm1 || yl1(2)>yutm2
                yl1(1)=yutm1;
                yl1(2)=yutm2;
            end
            if xl1(1)<xutm1 || xl1(1)>xutm2 || xl1(2)<xutm1 || xl1(2)>xutm2
                xl1(1)=xutm1;
                xl1(2)=xutm2;
            end
        otherwise
            handles.screenParameters.xMaxRange=[-5000000 5000000];
            handles.screenParameters.yMaxRange=[0 8000000];
    end
    
    [xl,yl]=CompXYLim(xl1,yl1,handles.screenParameters.xMaxRange,handles.screenParameters.yMaxRange);
    
    handles.screenParameters.xLim=xl;
    handles.screenParameters.yLim=yl;
    
    set(gca,'XLim',xl,'YLim',yl);
    
    setHandles(handles);
    
end

%% Bathymetry and shoreline are taken care of in ddb_updateDataInScreen
%ddb_updateDataInScreen;

handles=getHandles;

% Cities
geoSystem.type='geographic';
geoSystem.name='WGS 84';
[xc,yc]=ddb_coordConvert(handles.mapData.cities.lon,handles.mapData.cities.lat,geoSystem,NewSystem);
for i=1:length(handles.mapData.cities.lon)
    set(handles.mapHandles.textCities(i),'Position',[xc(i) yc(i) 500]);
end
set(handles.mapHandles.cities,'XData',xc,'YData',yc);

%% Now reset everything ... Eventually, each model and toolbox should have
%% its own coordinate conversion script.

setHandles(handles);

%ddb_resetAll;

% % Models
% for i=1:length(handles.Model)
%     f=handles.Model(i).coordConvertFcn;
%     try
%         handles=f(handles);
%     end
% end
%
% % Toolboxes
% for i=1:length(handles.Toolbox)
%     f=handles.Toolbox(i).coordConvertFcn;
%     try
%         handles=f(handles);
%     end
% end
% setHandles(handles);

