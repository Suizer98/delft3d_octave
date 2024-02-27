function handles = ddb_initializeDrawing(handles, varargin)
%DDB_INITIALIZEDRAWING  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_initializeDrawing(handles, varargin)
%
%   Input:
%   handles  =
%   varargin =
%
%   Output:
%   handles  =
%
%   Example
%   ddb_initializeDrawing
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2017 Deltares
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

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%
handles.toolbox.drawing.nrpolylines=0;
handles.toolbox.drawing.polylinenames={''};
handles.toolbox.drawing.activepolyline=1;
handles.toolbox.drawing.polyline(1).length=0;
handles.toolbox.drawing.polyline(1).x=[];
handles.toolbox.drawing.polyline(1).y=[];
handles.toolbox.drawing.polylinefile='';

handles.toolbox.drawing.nrpolygons=0;
handles.toolbox.drawing.polygonnames={''};
handles.toolbox.drawing.activepolygon=1;
handles.toolbox.drawing.polygon(1).length=0;
handles.toolbox.drawing.polygon(1).x=[];
handles.toolbox.drawing.polygon(1).y=[];
handles.toolbox.drawing.polygonfile='';

handles.toolbox.drawing.nrsplines=0;
handles.toolbox.drawing.splinenames={''};
handles.toolbox.drawing.activespline=1;
handles.toolbox.drawing.spline(1).length=0;
handles.toolbox.drawing.spline(1).x=[];
handles.toolbox.drawing.spline(1).y=[];
handles.toolbox.drawing.splinefile='';
handles.toolbox.drawing.dxspline=0;
handles.toolbox.drawing.dxxspline=0;

handles.toolbox.drawing.persistent=1;
