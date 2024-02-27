function ddb_initializeScreenParameters
%DDB_INITIALIZESCREENPARAMETERS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_initializeScreenParameters
%
%   Input:

%
%
%
%
%   Example
%   ddb_initializeScreenParameters
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

handles.screenParameters.xMaxRange=[-360 360];
handles.screenParameters.yMaxRange=[-90 90];

handles.GUIData.backgroundImageType=handles.configuration.background_image;

if ~isempty(handles.configuration.bathymetry)
    % Use bathymetry defined in xml file
    handles.screenParameters.backgroundBathymetry=handles.configuration.bathymetry;
else
    % Use first available dataset
    for i=1:handles.bathymetry.nrDatasets
        if handles.bathymetry.dataset(i).isAvailable
            handles.screenParameters.backgroundBathymetry=handles.bathymetry.dataset(i).name;
            break
        end
    end
end

for i=1:handles.shorelines.nrShorelines
    if handles.shorelines.shoreline(i).isAvailable
        handles.screenParameters.shoreline=handles.shorelines.shoreline(i).name;
        break
    end
end

handles.screenParameters.backgroundQuality='Medium';
handles.screenParameters.hillShading=10;

handles.screenParameters.satelliteImageType='roads';

handles.screenParameters.coordinateSystem.name=handles.configuration.cs.name;
handles.screenParameters.coordinateSystem.type=handles.configuration.cs.type;
handles.screenParameters.oldCoordinateSystem.name='WGS 84';
handles.screenParameters.oldCoordinateSystem.type='Geographic';
% handles.screenParameters.coordinateSystem.name='WGS 84';
% handles.screenParameters.coordinateSystem.type='Geographic';
% handles.screenParameters.oldCoordinateSystem.name='WGS 84';
% handles.screenParameters.oldCoordinateSystem.type='Geographic';

handles.screenParameters.UTMZone={31,'U'};

handles.screenParameters.cMin=-10000;
handles.screenParameters.cMax=10000;
handles.screenParameters.automaticColorLimits=1;
handles.screenParameters.colorMap='Earth';


handles.screenParameters.xLim=[-180 180];
handles.screenParameters.yLim=[-90 90];

handles.screenParameters.activeTab='Toolbox';

% if ~strcmpi(handles.configuration.include_toolboxes{1},'all')
%     handles.activeToolbox.name=handles.configuration.include_toolboxes{1};    
% else
%     handles.activeToolbox.name='modelmaker';
% end
% handles.activeToolbox.nr=1;

setHandles(handles);

