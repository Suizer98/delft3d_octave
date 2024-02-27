function handles = ddb_initializeNesting(handles, varargin)
%DDB_INITIALIZENESTING  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_initializeNesting(handles, varargin)
%
%   Input:
%   handles  =
%   varargin =
%
%   Output:
%   handles  =
%
%   Example
%   ddb_initializeNesting
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

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%

ddb_getToolboxData(handles,handles.toolbox.nesting.dataDir,'nesting','Nesting');

if nargin>1
    switch varargin{1}
        case{'test'}
            return
        case{'veryfirst'}
            return
    end
end

% Tree structure
handles.toolbox.nesting.overallmodellist={''};
handles.toolbox.nesting.detailmodellist={''};
handles.toolbox.nesting.overallindex=1;
handles.toolbox.nesting.detailindex=1;


% Nest 1

% Delft3D-FLOW
handles.toolbox.nesting.delft3dflow.detailmodeltype   = 'delft3dflow';
handles.toolbox.nesting.delft3dflow.detailmodelcsname = 'unspecified';
handles.toolbox.nesting.delft3dflow.detailmodelcstype = 'unspecified';
handles.toolbox.nesting.delft3dflow.grdFile       = '';
handles.toolbox.nesting.delft3dflow.encFile       = '';
handles.toolbox.nesting.delft3dflow.bndFile       = '';
handles.toolbox.nesting.delft3dflow.depFile       = '';
handles.toolbox.nesting.delft3dflow.extfile       = '';
handles.toolbox.nesting.delft3dflow.sfincs_flow_bnd_file = '';
handles.toolbox.nesting.delft3dflow.admFile       = 'nesting.adm';

% DFlow-FM
handles.toolbox.nesting.dflowfm.detailmodeltype   = 'delft3dflow';
handles.toolbox.nesting.dflowfm.detailmodelcsname = 'unspecified';
handles.toolbox.nesting.dflowfm.detailmodelcstype = 'unspecified';
handles.toolbox.nesting.dflowfm.grdFile           = '';
handles.toolbox.nesting.dflowfm.encFile           = '';
handles.toolbox.nesting.dflowfm.bndFile           = '';
handles.toolbox.nesting.dflowfm.depFile           = '';
handles.toolbox.nesting.dflowfm.extfile           = '';
handles.toolbox.nesting.dflowfm.admFile           = 'nesting.xml';

% Fews
handles.toolbox.nesting.fews.detailmodeltype    = 'dflowfmwave';
handles.toolbox.nesting.fews.detailmodelcsname  = 'unspecified';
handles.toolbox.nesting.fews.detailmodelcstype  = 'unspecified';
handles.toolbox.nesting.fews.modeldir           = '';
handles.toolbox.nesting.fews.dflowfmdir         = '';
handles.toolbox.nesting.fews.wavedir            = '';
handles.toolbox.nesting.fews.mduFile            = '';
handles.toolbox.nesting.fews.mdwFile            = '';
handles.toolbox.nesting.fews.extFile            = '';
handles.toolbox.nesting.fews.xynFile            = '';
handles.toolbox.nesting.fews.csvFile            = '';
handles.toolbox.nesting.fews.runid              = 'DFlowFM_tst';
handles.toolbox.nesting.fews.zsini              = 0;

% Delft3D-WAVE
handles.toolbox.nesting.delft3dwave.detailmodeltype   = 'delft3dwave';
handles.toolbox.nesting.delft3dwave.detailmodelcsname = 'unspecified';
handles.toolbox.nesting.delft3dwave.detailmodelcstype = 'unspecified';
handles.toolbox.nesting.delft3dwave.overallmodelcsname = 'unspecified';
handles.toolbox.nesting.delft3dwave.overallmodelcstype = 'unspecified';
handles.toolbox.nesting.delft3dwave.grdFile       = '';
handles.toolbox.nesting.delft3dwave.depFile       = '';
handles.toolbox.nesting.delft3dwave.nr_cells_per_section=10;
handles.toolbox.nesting.delft3dwave.max_distance_per_section=10000;
handles.toolbox.nesting.delft3dwave.spacing_method='distance'; % Can be either distance of number_of_cells

% WAVEWATCH III
handles.toolbox.nesting.ww3.detailmodeltype   = 'delft3dwave';
handles.toolbox.nesting.ww3.detailmodelcsname = 'unspecified';
handles.toolbox.nesting.ww3.detailmodelcstype = 'unspecified';
handles.toolbox.nesting.ww3.grdFile       = '';
handles.toolbox.nesting.ww3.depFile       = '';
handles.toolbox.nesting.ww3.ww3_grid_file = '';
handles.toolbox.nesting.ww3.nr_cells_per_section=10;

% SFINCS
handles.toolbox.nesting.sfincs.detailmodeltype   = 'sfincs';
handles.toolbox.nesting.sfincs.detailmodelcsname = 'unspecified';
handles.toolbox.nesting.sfincs.detailmodelcstype = 'unspecified';
handles.toolbox.nesting.sfincs.bndfile       = '';
handles.toolbox.nesting.sfincs.admFile       = 'nesting.adm';

% Nest 2
% handles.toolbox.nesting.admFile       = 'nesting.adm';
handles.toolbox.nesting.trihFile      = '';
handles.toolbox.nesting.zCor          = 0;
handles.toolbox.nesting.nestHydro     = 1;
handles.toolbox.nesting.nestTransport = 1;

handles.toolbox.nesting.singleSP2file='';


handles.toolbox.nesting.timestep = 10;
handles.toolbox.nesting.flowwave = 0;
handles.toolbox.nesting.distance = 2000;
handles.toolbox.nesting.sequence = 1;
