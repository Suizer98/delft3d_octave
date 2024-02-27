function handles = ddb_initialize_sfincs_domain(handles, opt, id, runid)
%ddb_initialize_sfincs_domain  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_initialize_sfincs_domain(handles, opt, id, runid)
%
%   Input:
%   handles =
%   opt     =
%   id      =
%   runid   =
%
%   Output:
%   handles =
%
%   Example
%   ddb_ddb_initialize_sfincs_domain
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

% Input structure from sfincs.inp file
handles.model.sfincs.domain(id).input=sfincs_initialize_input;

% Runid is folder name
[fldr,runid]=fileparts(pwd);

handles.model.sfincs.domain(id).directory=[pwd filesep];
handles.model.sfincs.domain(id).runid=runid;
handles.model.sfincs.domain(id).attName='test';

handles.model.sfincs.domain(id).roughness_type='landsea';
handles.model.sfincs.domain(id).wind_type='uniform';
handles.model.sfincs.domain(id).rain_type='uniform';

% handles.model.sfincs.domain(id).tref=floor(now);
% handles.model.sfincs.domain(id).tstart=floor(now);
% handles.model.sfincs.domain(id).tstop =floor(now+1);

% Coast line
handles.model.sfincs.domain(id).coastline.handle=[];
handles.model.sfincs.domain(id).coastline.active_point_handle=[];
handles.model.sfincs.domain(id).coastline.x=0;
handles.model.sfincs.domain(id).coastline.y=0;
handles.model.sfincs.domain(id).coastline.slope=0.01;
handles.model.sfincs.domain(id).coastline.dean=0.05;
handles.model.sfincs.domain(id).coastline.reef_width=1000;
handles.model.sfincs.domain(id).coastline.reef_height=-1;
handles.model.sfincs.domain(id).coastline.type=1;
handles.model.sfincs.domain(id).coastline.length=0;
handles.model.sfincs.domain(id).coastline.active_point=1;
handles.model.sfincs.domain(id).coastline.orientation=0;
handles.model.sfincs.domain(ad).coastline.point_list={''};

% Boundary conditions
handles.model.sfincs.domain(id).flowboundarypoints.handle=[];
handles.model.sfincs.domain(id).flowboundarypoints.x=[];
handles.model.sfincs.domain(id).flowboundarypoints.y=[];
handles.model.sfincs.domain(id).flowboundarypoints.length=0;
handles.model.sfincs.domain(id).flowboundaryconditions.time=0;
handles.model.sfincs.domain(id).flowboundaryconditions.zs=0;

handles.model.sfincs.domain(id).waveboundarypoints.handle=[];
handles.model.sfincs.domain(id).waveboundarypoints.x=[];
handles.model.sfincs.domain(id).waveboundarypoints.y=[];
handles.model.sfincs.domain(id).waveboundarypoints.length=0;
handles.model.sfincs.domain(id).waveboundaryconditions.time=0;
handles.model.sfincs.domain(id).waveboundaryconditions.hs=0;
handles.model.sfincs.domain(id).waveboundaryconditions.tp=0;
handles.model.sfincs.domain(id).waveboundaryconditions.wd=0;

% Sources
handles.model.sfincs.domain(id).sourcepoints.handle=[];
handles.model.sfincs.domain(id).sourcepoints.x=[];
handles.model.sfincs.domain(id).sourcepoints.y=[];
handles.model.sfincs.domain(id).sourcepoints.length=0;
handles.model.sfincs.domain(id).sourcepoints.time=0;
handles.model.sfincs.domain(id).sourcepoints.q=0;

% Observation points
handles.model.sfincs.domain(id).obspoints.handle=[];
handles.model.sfincs.domain(id).obspoints.x=[];
handles.model.sfincs.domain(id).obspoints.y=[];
handles.model.sfincs.domain(id).obspoints.names={''};
handles.model.sfincs.domain(id).obspoints.length=0;

% Quadtree
handles.model.sfincs.domain(id).buq = [];
