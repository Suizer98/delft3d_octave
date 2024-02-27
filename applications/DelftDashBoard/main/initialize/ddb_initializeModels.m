function ddb_initializeModels
%DDB_INITIALIZEMODELS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_initializeModels
%
%   Input:

%
%
%
%
%   Example
%   ddb_initializeModels
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

% $Id: ddb_initializeModels.m 17881 2022-03-31 12:28:55Z ormondt $
% $Date: 2022-03-31 20:28:55 +0800 (Thu, 31 Mar 2022) $
% $Author: ormondt $
% $Revision: 17881 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/main/initialize/ddb_initializeModels.m $
% $Keywords: $

%%
handles=getHandles;
handles.activeDomain=1;
handles.activeWaveGrid=1;
models=fieldnames(handles.model);
for k=1:length(models)
    model=models{k};
    if ~strcmpi(model,'none')
        disp(['Initializing model ' handles.model.(model).longName ' ...']);
    end
    f=handles.model.(model).iniFcn;
    handles.activeModel.nr=k;
    setHandles(handles);
    handles=f(handles);
    handles.activeModel.nr=1;
    handles.model.(model).nrDomains=1;
end
setHandles(handles);

% handles.toolbox.modelmaker.D50 = 250;
% handles.toolbox.modelmaker.depth = 20;
% handles.toolbox.modelmaker.dean = 0;
% handles.toolbox.modelmaker.transects = 0;
% handles.toolbox.modelmaker.average_z = 0;
% handles.toolbox.modelmaker.average_dx = 0;
% handles.toolbox.modelmaker.average_z = 0;
% handles.toolbox.modelmaker.bathymetry.intertidalbathy = 0;
% handles.modelmaker.activeinterpolationtype = 3;
% handles.modelmaker.interpolationtypes = {'spline', 'linear', 'pchip'};
% setHandles(handles);
% 
% s.toolbox.nesting.activebox = 1;
% s.toolbox.nesting.drawboxes(s.toolbox.nesting.activebox).startTime = now;
% s.toolbox.nesting.drawboxes(s.toolbox.nesting.activebox).stopTime = now-3;
% s.toolbox.nesting.drawboxes(s.toolbox.nesting.activebox).timestep = 1;
% s.toolbox.nesting.drawboxes(s.toolbox.nesting.activebox).xOri = 0;
% s.toolbox.nesting.drawboxes(s.toolbox.nesting.activebox).nX = 1;
% s.toolbox.nesting.drawboxes(s.toolbox.nesting.activebox).dX = 1;
% s.toolbox.nesting.drawboxes(s.toolbox.nesting.activebox).rotation = 0;
% s.toolbox.nesting.drawboxes(s.toolbox.nesting.activebox).yOri = 0; 
% s.toolbox.nesting.drawboxes(s.toolbox.nesting.activebox).nY = 1;
% s.toolbox.nesting.drawboxes(s.toolbox.nesting.activebox).dY = 1;
% 
% s.toolbox.xbeachvegetation.listname = '';
% s.toolbox.xbeachvegetation.polyLength = 0;
