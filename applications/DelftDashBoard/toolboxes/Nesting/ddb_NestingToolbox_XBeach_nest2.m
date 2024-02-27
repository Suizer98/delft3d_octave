function ddb_NestingToolbox_XBeach_nestHD2(varargin)
%DDB_NESTINGTOOLBOX_NESTHD2  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_NestingToolbox_nestHD2(varargin)
%
%   Input:
%   varargin =
%
%
%
%
%   Example
%   ddb_NestingToolbox_nestHD2
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
% Created: 02 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: ddb_NestingToolbox_nestHD2.m 11472 2014-11-27 15:12:11Z ormondt $
% $Date: 2014-11-27 16:12:11 +0100 (Thu, 27 Nov 2014) $
% $Author: ormondt $
% $Revision: 11472 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/Nesting/ddb_NestingToolbox_nestHD2.m $
% $Keywords: $

%%
if isempty(varargin)
    % New tab selected
    ddb_zoomOff;
    ddb_refreshScreen;
    setInstructions({'Click Run Nesting in order to generate boundary conditions for the nested model', ...
        'The overall model simulation must be finished and a history file must be present','The nested model domain must be selected!'});
else
    %Options selected
    opt=lower(varargin{1});
    switch opt
        case{'nest2'}
            nest2;
    end
end

%%
function nest2

handles=getHandles;

if isempty(handles.toolbox.nesting.trihFile)
    ddb_giveWarning('text','Please first load history file of overall model!');
    return
end

hisfile=handles.toolbox.nesting.trihFile;
nestadm=handles.toolbox.nesting.delft3dflow.admFile;
z0=handles.toolbox.nesting.zCor;

    
bnd.name='Sea';
bnd.M1=2;
bnd.N1=1;
bnd.M2=size(handles.model.xbeach.domain.grid.x,1)-1;
bnd.N2=1;
bnd.type='Z';
bnd.forcing='T';

% Run Nesthd2
cs=handles.screenParameters.coordinateSystem.type;
stride=1;

bnd=nesthd2('openboundaries',bnd,'hisfile',hisfile,'admfile',nestadm,'zcor',z0,'stride',stride,'opt','hydro','coordinatesystem',cs,'save','n');
    
[filename, pathname, filterindex] = uiputfile('*.txt','Select Water Level (zs0) File');
if pathname~=0
    curdir=[lower(cd) '\'];
    if ~strcmpi(curdir,pathname)
        filename=[pathname filename];
    end
    handles.model.xbeach.domain(ad).zs0file=filename;
    t  =(bnd.timeSeriesT-bnd.timeSeriesT(1))*86400;
    wla=bnd.timeSeriesA;
    wlb=bnd.timeSeriesB;
    data=[t wla wlb];
    save(filename,'-ascii','data');
end

setHandles(handles);
