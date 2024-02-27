function ddb_DFlowFM_saveObsFile(handles, id)
%DDB_SAVEOBSFILE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_saveObsFile(handles, id)
%
%   Input:
%   handles =
%   id      =
%
%
%
%
%   Example
%   ddb_saveObsFile
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

% $Id: ddb_DFlowFM_saveObsFile.m 15813 2019-10-04 06:15:03Z ormondt $
% $Date: 2019-10-04 14:15:03 +0800 (Fri, 04 Oct 2019) $
% $Author: ormondt $
% $Revision: 15813 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/models/DFlowFM/fileio/ddb_DFlowFM_saveObsFile.m $
% $Keywords: $

%%

if handles.model.dflowfm.domain(id).nrobservationpoints>0
    fid=fopen(handles.model.dflowfm.domain(id).obsfile,'w');
    for ip=1:handles.model.dflowfm.domain(id).nrobservationpoints
        x=handles.model.dflowfm.domain(id).observationpoints(ip).x;
        y=handles.model.dflowfm.domain(id).observationpoints(ip).y;
        name=handles.model.dflowfm.domain(id).observationpoints(ip).name;
        fprintf(fid,'%14.6f %14.6f %s\n',x,y,['"' name '"']);
    end
    fclose(fid);
end

