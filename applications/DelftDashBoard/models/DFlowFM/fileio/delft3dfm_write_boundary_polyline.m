function delft3dfm_write_boundary_polyline(boundary)
%DDB_GENERATEBOUNDARYSECTIONSDFLOWFM  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_generateBoundarySectionsDFlowFM(handles)
%
%   Input:
%   handles  =
%   id       =
%   varargin =
%
%   Output:
%   handles  =
%
%   Example
%   ddb_generateBoundaryLocationsDelft3DFLOW
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

% $Id: ddb_DFlowFM_saveBoundaryPolygons.m 12761 2016-06-01 15:19:32Z nederhof $
% $Date: 2016-06-01 17:19:32 +0200 (Wed, 01 Jun 2016) $
% $Author: nederhof $
% $Revision: 12761 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/models/DFlowFM/fileio/ddb_DFlowFM_saveBoundaryPolygons.m $
% $Keywords: $

fid=fopen(boundary.location_file,'wt');
fprintf(fid,'%s\n',boundary.name);
fprintf(fid,'%i %i\n',length(boundary.x),2);
for ip=1:length(boundary.x)
    nodename=[boundary.name '_' num2str(ip,'%0.4i')];
    fprintf(fid,'%14.7e %14.7e %s\n',boundary.x(ip),boundary.y(ip),nodename);
end
fclose(fid);

