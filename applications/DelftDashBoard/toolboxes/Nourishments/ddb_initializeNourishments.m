function handles = ddb_initializeNourishments(handles, varargin)
%DDB_INITIALIZENOURISHMENTS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_initializeNourishments(handles, varargin)
%
%   Input:
%   handles  =
%   varargin =
%
%   Output:
%   handles  =
%
%   Example
%   ddb_initializeNourishments
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
% Created: 01 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: ddb_initializeNourishments.m 10436 2014-03-24 22:26:17Z ormondt $
% $Date: 2014-03-25 06:26:17 +0800 (Tue, 25 Mar 2014) $
% $Author: ormondt $
% $Revision: 10436 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/Nourishments/ddb_initializeNourishments.m $
% $Keywords: $

%%

if nargin>1
    switch varargin{1}
        case{'test'}
            return
        case{'veryfirst'}
            handles.toolbox.nourishments.longName='Nourishments';
            return
    end
end

%% Domain
handles.toolbox.nourishments.modelOutlineHandle=[];
handles.toolbox.nourishments.xLim      = [0 0];
handles.toolbox.nourishments.yLim      = [0 0];
handles.toolbox.nourishments.dX        = 100;

handles.toolbox.nourishments.currentsFile='';
handles.toolbox.nourishments.currentSource='file';
handles.toolbox.nourishments.currentU=0;
handles.toolbox.nourishments.currentV=0;

%% Nourishments
handles.toolbox.nourishments.nourishments(1).polygonX=[];
handles.toolbox.nourishments.nourishments(1).polygonY=[];
handles.toolbox.nourishments.nourishments(1).polyLength=0;
handles.toolbox.nourishments.nourishments(1).type='volume';
handles.toolbox.nourishments.nourishments(1).volume=1e6;
handles.toolbox.nourishments.nourishments(1).thickness=1;
handles.toolbox.nourishments.nourishments(1).height=1;
handles.toolbox.nourishments.nourishments(1).area=0;

handles.toolbox.nourishments.nrNourishments=0;
handles.toolbox.nourishments.activeNourishment=1;
handles.toolbox.nourishments.nourishmentNames={''};

%% Concentration areas
handles.toolbox.nourishments.concentrationPolygons(1).polygonX=[];
handles.toolbox.nourishments.concentrationPolygons(1).polygonY=[];
handles.toolbox.nourishments.concentrationPolygons(1).polyLength=0;
handles.toolbox.nourishments.concentrationPolygons(1).concentration=0.02;

handles.toolbox.nourishments.nrConcentrationPolygons=0;
handles.toolbox.nourishments.activeConcentrationPolygon=1;
handles.toolbox.nourishments.concentrationNames={''};

%% Runtime
handles.toolbox.nourishments.nrYears=5;
handles.toolbox.nourishments.outputInterval=1;

%% Parameters
handles.toolbox.nourishments.equilibriumConcentration=0.02;
handles.toolbox.nourishments.diffusionCoefficient=10;
handles.toolbox.nourishments.settlingVelocity=0.02;


