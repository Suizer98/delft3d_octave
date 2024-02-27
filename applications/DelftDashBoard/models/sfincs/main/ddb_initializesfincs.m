function handles = ddb_initializesfincs(handles, varargin)
%DDB_INITIALIZEsfincs  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_initializesfincs(handles, varargin)
%
%   Input:
%   handles  =
%   varargin =
%
%   Output:
%   handles  =
%
%   Example
%   ddb_initializeDelft3DFLOW
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2015 Deltares
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


handles.model.sfincs.domain=[];

%runid='tst';

handles=ddb_initialize_sfincs_domain(handles,'dummy',1,'dummy');

handles.model.sfincs.menuview.grid=1;
handles.model.sfincs.menuview.bathymetry=1;
handles.model.sfincs.menuview.mask=1;

handles.model.sfincs.boundaryspline.handle=[];
handles.model.sfincs.boundaryspline.filename='';
handles.model.sfincs.boundaryspline.length=0;
handles.model.sfincs.boundaryspline.x=[];
handles.model.sfincs.boundaryspline.y=[];
handles.model.sfincs.boundaryspline.flowdx=5000;
handles.model.sfincs.boundaryspline.wavedx=20000;

handles.model.sfincs.boundaryconditions.zs=0.0;
handles.model.sfincs.boundaryconditions.hs=0.0;
handles.model.sfincs.boundaryconditions.tp=5.0;
handles.model.sfincs.boundaryconditions.wd=0.0;

handles.model.sfincs.structurespline.handle=[];


handles.model.sfincs.depthcontour.handle=[];
handles.model.sfincs.depthcontour.value=-2;

handles.model.sfincs.coastspline.handle=[];
handles.model.sfincs.coastspline.filename='';
handles.model.sfincs.coastspline.length=0;
handles.model.sfincs.coastspline.x=[];
handles.model.sfincs.coastspline.y=[];
handles.model.sfincs.coastspline.flowdx=500;

