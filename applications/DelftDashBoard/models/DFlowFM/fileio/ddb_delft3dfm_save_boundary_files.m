function ddb_delft3dfm_save_boundary_files(handles)
%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
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

% $Id: ddb_DFlowFM_writeComponentsFile.m 9233 2013-09-19 09:19:19Z ormondt $
% $Date: 2013-09-19 11:19:19 +0200 (Thu, 19 Sep 2013) $
% $Author: ormondt $
% $Revision: 9233 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/models/DFlowFM/fileio/ddb_DFlowFM_writeComponentsFile.m $
% $Keywords: $
    
% Saves Delft3D-FM boundaries (pli, ext and bc files)

boundary=handles.model.dflowfm.domain.boundary;

% pli files
for iac=1:handles.model.dflowfm.domain.nrboundaries
    delft3dfm_write_boundary_polyline(boundary(iac).boundary);
end

% ext file
extfile=handles.model.dflowfm.domain.extforcefilenew;
delft3dfm_save_boundary_ext_file(extfile,boundary);

% bc file
delft3dfm_write_bc_file(boundary,floor(now));
