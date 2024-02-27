function handles = ddb_Delft3DFLOW_initializeMorphology(handles, id)
%DDB_DELFT3DFLOW_INITIALIZEMORPHOLOGY  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_Delft3DFLOW_initializeMorphology(handles, id)
%
%   Input:
%   handles =
%   id      =
%
%   Output:
%   handles =
%
%   Example
%   ddb_Delft3DFLOW_initializeMorphology
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

% $Id: ddb_Delft3DFLOW_initializeMorphology.m 10447 2014-03-26 07:06:47Z ormondt $
% $Date: 2014-03-26 15:06:47 +0800 (Wed, 26 Mar 2014) $
% $Author: ormondt $
% $Revision: 10447 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/models/Delft3DFLOW/initialize/ddb_Delft3DFLOW_initializeMorphology.m $
% $Keywords: $

%% Initializes Delft3D-FLOW morphology

handles.model.delft3dflow.domain(id).morphology=[];

handles.model.delft3dflow.domain(id).morphology.morUpd=1;
handles.model.delft3dflow.domain(id).morphology.densIn=0;
handles.model.delft3dflow.domain(id).morphology.eqmBc=1;
handles.model.delft3dflow.domain(id).morphology.morFac=1;
handles.model.delft3dflow.domain(id).morphology.morStt=720;
handles.model.delft3dflow.domain(id).morphology.thresh=0.05;
handles.model.delft3dflow.domain(id).morphology.sedThr=0.1;
handles.model.delft3dflow.domain(id).morphology.thetSd=0.1;
handles.model.delft3dflow.domain(id).morphology.sus=1.0;
handles.model.delft3dflow.domain(id).morphology.bed=1.0;
handles.model.delft3dflow.domain(id).morphology.susW=1.0;
handles.model.delft3dflow.domain(id).morphology.bedW=1.0;
handles.model.delft3dflow.domain(id).morphology.iOpKcw = 1;
handles.model.delft3dflow.domain(id).morphology.epsPar = 0;
handles.model.delft3dflow.domain(id).morphology.rdc = 0.01;
handles.model.delft3dflow.domain(id).morphology.rdw = 0.02;
handles.model.delft3dflow.domain(id).morphology.aksFac = 1;
handles.model.delft3dflow.domain(id).morphology.rWave = 2;
handles.model.delft3dflow.domain(id).morphology.alphaBs = 1.0;
handles.model.delft3dflow.domain(id).morphology.alphaBn = 1.5;
handles.model.delft3dflow.domain(id).morphology.hMaxTh = 1.5;
handles.model.delft3dflow.domain(id).morphology.fwFac = 1.0;

