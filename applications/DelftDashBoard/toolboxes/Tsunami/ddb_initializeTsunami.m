function handles = ddb_initializeTsunami(handles, varargin)
%DDB_INITIALIZETSUNAMI  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_initializeTsunami(handles, varargin)
%
%   Input:
%   handles  =
%   varargin =
%
%   Output:
%   handles  =
%
%   Example
%   ddb_initializeTsunami
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

handles.toolbox.tsunami.nrSegments=0;

% handles.toolbox.tsunami.magnitude=0.0;
% handles.toolbox.tsunami.depthFromTop=0.0;
% handles.toolbox.tsunami.relatedToEpicentre=0;
% handles.toolbox.tsunami.latitude=0.0;
% handles.toolbox.tsunami.longitude=0.0;
% handles.toolbox.tsunami.totalFaultLength=0.0;
% handles.toolbox.tsunami.totalUserFaultLength=0.0;
% handles.toolbox.tsunami.faultWidth=0.0;
% handles.toolbox.tsunami.dislocation=0.0;
% handles.toolbox.tsunami.segment=0.0;
%
% handles.toolbox.tsunami.faultLength=0;
% handles.toolbox.tsunami.strike=0;
% handles.toolbox.tsunami.dip=0;
% handles.toolbox.tsunami.slipRake=0;
% handles.toolbox.tsunami.focalDepth=0;


% Overall info
handles.toolbox.tsunami.relatedToEpicentre=0;
handles.toolbox.tsunami.updateTable=1;
handles.toolbox.tsunami.updateParameters=1;

handles.toolbox.tsunami.faulthandle=[];

handles.toolbox.tsunami.saveESRIGridFile=0;
handles.toolbox.tsunami.adjustBathymetry=0;

% Earthquake info
handles.toolbox.tsunami.Mw=0.0;
handles.toolbox.tsunami.depth=20.0;
handles.toolbox.tsunami.length=0.0;
handles.toolbox.tsunami.theoreticalFaultLength=0.0;
handles.toolbox.tsunami.width=0.0;
handles.toolbox.tsunami.slip=0.0;
handles.toolbox.tsunami.strike=0.0;
handles.toolbox.tsunami.dip=10.0;
handles.toolbox.tsunami.slipRake=90.0;
handles.toolbox.tsunami.lonEpicentre=0.0;
handles.toolbox.tsunami.latEpicentre=0.0;
handles.toolbox.tsunami.EQtype=3;

% Segment info (for table)
handles.toolbox.tsunami.segmentLon=0.0;
handles.toolbox.tsunami.segmentLat=0.0;
handles.toolbox.tsunami.segmentX=0.0;
handles.toolbox.tsunami.segmentY=0.0;
handles.toolbox.tsunami.segmentStrike=0;
handles.toolbox.tsunami.segmentDip=0;
handles.toolbox.tsunami.segmentSlipRake=0;
handles.toolbox.tsunami.segmentDepth=0;
handles.toolbox.tsunami.segmentWidth=0;
handles.toolbox.tsunami.segmentFocalDepth=0;
handles.toolbox.tsunami.segmentSlip=0.0;

% File
handles.toolbox.tsunami.gridFile='';
