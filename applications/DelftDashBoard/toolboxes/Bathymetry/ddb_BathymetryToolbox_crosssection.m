function ddb_BathymetryToolbox_crosssection(varargin)
%DDB_BATHYMETRYTOOLBOX_FILLCACHE  DDB Tab for filling the bathymetry cache

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
% Created: 01 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: ddb_BathymetryToolbox_fillcache.m 10436 2014-03-24 22:26:17Z ormondt $
% $Date: 2014-03-24 23:26:17 +0100 (Mon, 24 Mar 2014) $
% $Author: ormondt $
% $Revision: 10436 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/Bathymetry/ddb_BathymetryToolbox_fillcache.m $
% $Keywords: $

%%
if isempty(varargin)
    % New tab selected
    ddb_zoomOff;
    ddb_refreshScreen;
    selectDataset;
    ddb_plotBathymetry('activate');
    h=findobj(gca,'Tag','bathymetrypolygon');
    set(h,'Visible','off');
    h=findobj(gca,'Tag','bathymetryrectangle');
    set(h,'Visible','on');
else
    %Options selected
    opt=lower(varargin{1});
    switch opt
        case{'selectdataset'}
            selectDataset;
        case{'drawline'}
            gui_dragLine('callback',@finish_line);
    end
end

%%
function selectDataset

handles=getHandles;
handles.toolbox.bathymetry.activeZoomLevel=1;
setHandles(handles);


%%
function finish_line(xp,yp)
handles=getHandles;

xl=[min(xp) max(xp)];
yl=[min(yp) max(yp)];

%[x,y,z,ok,varargout] = ddb_getBathymetry(bathymetry, xl, yl, varargin)
    [xx,yy,zz,ok]=ddb_getBathymetry(handles.bathymetry,xl,yl,'bathymetry',handles.bathymetry.dataset(handles.toolbox.bathymetry.activeDataset).name,'maxcellsize',0.1);

    xp=xp(1):(xp(2)-xp(1))/500:xp(2);
    yp=yp(1):(yp(2)-yp(1))/500:yp(2);
    zp=interp2(xx,yy,zz,xp,yp);
figure(20)
dst=pathdistance(xp,yp,'geographic');
plot(dst,zp);
iid=compute_iid(dst,zp,-100);
