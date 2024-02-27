function [x y z] = ddb_getSRTM(xlim, ylim, res)
%DDB_GETSRTM  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   [x y z] = ddb_getSRTM(xlim, ylim, res)
%
%   Input:
%   xlim =
%   ylim =
%   res  =
%
%   Output:
%   x    =
%   y    =
%   z    =
%
%   Example
%   ddb_getSRTM
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

% $Id: ddb_getSRTM.m 5705 2012-01-14 13:19:34Z mrv.x $
% $Date: 2012-01-14 21:19:34 +0800 (Sat, 14 Jan 2012) $
% $Author: mrv.x $
% $Revision: 5705 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/main/data/ddb_getSRTM.m $
% $Keywords: $

%%
%handles=getHandles;
xlim(1)=max(-179.5,xlim(1));
xlim(2)=min(179.5,xlim(2));
ylim(1)=max(-89.5,ylim(1));
ylim(2)=min(89.5,ylim(2));

[x,y,z,url,ok]=ddb_read_srtm30plus(xlim,ylim,res,0);

% xavg=0.5*(xlim(1)+xlim(2));
% yavg=0.5*(ylim(1)+ylim(2));
%
% xavg=7+floor(12*xavg/360);
% yavg=4+floor(6*yavg/180);
%
% str=['d:\data\gebco\tmp\gebco_' num2str(xavg,'%0.3i') '_' num2str(yavg,'%0.3i') '.mat'];
% %str=['d:\data\etopo2\etopo2_' num2str(xavg,'%0.3i') '_' num2str(yavg,'%0.3i') '.mat'];
% a=load(str);
% ithin=max(1,round(res/(3600*a.data.cellsize(1))));
% x=a.data.interpx(1:ithin:end,1:ithin:end);
% y=a.data.interpy(1:ithin:end,1:ithin:end);
% z=a.data.interpz(1:ithin:end,1:ithin:end);
% ok=1;
% clear a

% sz=size(x);
% xx=reshape(x,sz(1)*sz(2),1);
% yy=reshape(y,sz(1)*sz(2),1);
%
% if strcmp(handles.ScreenParameters.CoordinateSystem,'Cartesian')
%     [lon,lat]=ddb_ddb_deg2utm(xx,yy,handles.ScreenParameters.UTMZone{1});
%     x=reshape(lon,sz(1),sz(2));
%     y=reshape(lat,sz(1),sz(2));
% end

if ok==0
    %     x0=x-360;
    %     y0=y;
    %     z0=z;
    %     handles.GUIData.x=[x0 x];
    %     handles.GUIData.y=[y0 y];
    %     handles.GUIData.z=[z0 z];
    %      handles.GUIData.x=x;
    %      handles.GUIData.y=y;
    %      handles.GUIData.z=z;
    % else
    disp('Could not connect to server ...');
    handles=getHandles;
    x0=handles.ScreenParameters.Etopo05.X;
    y0=handles.ScreenParameters.Etopo05.Y;
    z0=handles.ScreenParameters.Etopo05.Z;
    [x1,y1]=meshgrid(x0(:,1)',y0(1,:)');
    z1=z0';
    x=[x1];
    y=[y1];
    z=[z1];
end

