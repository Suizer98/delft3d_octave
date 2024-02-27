function ddb_NestingToolbox_DFlowFM_nest2(varargin)
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

% $Id: ddb_NestingToolbox_DFlowFM_nest2.m 16924 2020-12-15 13:32:32Z ormondt $
% $Date: 2020-12-15 21:32:32 +0800 (Tue, 15 Dec 2020) $
% $Author: ormondt $
% $Revision: 16924 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/Nesting/ddb_NestingToolbox_DFlowFM_nest2.m $
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
        case{'nesthd2'}
            nestHD2;
    end
end

%%
function nestHD2

handles=getHandles;

if isempty(handles.toolbox.nesting.trihFile)
    ddb_giveWarning('text','Please first load history file of overall model!');
    return
end

hisfile=handles.toolbox.nesting.trihFile;
admfile=handles.toolbox.nesting.admFile;
z0=handles.toolbox.nesting.zCor;
opt='';
if handles.toolbox.nesting.nestHydro && handles.toolbox.nesting.nestTransport
    opt='both';
elseif handles.toolbox.nesting.nestHydro
    opt='hydro';
elseif handles.toolbox.nesting.nestTransport
    opt='transport';
end

if ~isempty(opt)
    
    % Make structure info for nesthd2
    
    % Vertical grid info
%     vertGrid.KMax=handles.Model(md).Input(ad).KMax;
%     vertGrid.layerType=handles.Model(md).Input(ad).layerType;
%     vertGrid.thick=handles.Model(md).Input(ad).thick;
%     vertGrid.zTop=handles.Model(md).Input(ad).zTop;
%     vertGrid.zBot=handles.Model(md).Input(ad).zBot;

    % Run Nesthd2
    cs=handles.screenParameters.coordinateSystem.type;
    
    extfile=handles.model.dflowfm.domain(ad).extforcefilenew;
    refdate=handles.model.dflowfm.domain(ad).refdate;

    wb = waitbox('Generating bc file(s) ...');
    
    try
        boundary=nest2_dflowfm_in_dflowfm(hisfile,admfile,extfile,refdate,'zcor',z0,'cstype',cs);
        close(wb);
    catch
        close(wb);
        ddb_giveWarning('text','An error occured in the nesting process ...');
    end    

    handles.model.dflowfm.domain(ad).boundary=boundary;
    
end

setHandles(handles);

