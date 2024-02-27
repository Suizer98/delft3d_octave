function ddb_getCoordinateSystems
%DDB_GETCOORDINATESYSTEMS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_getCoordinateSystems
%
%   Input:

%
%
%
%
%   Example
%   ddb_getCoordinateSystems
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

% $Id: ddb_getCoordinateSystems.m 17323 2021-06-08 19:03:34Z ormondt $
% $Date: 2021-06-09 03:03:34 +0800 (Wed, 09 Jun 2021) $
% $Author: ormondt $
% $Revision: 17323 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/main/initialize/ddb_getCoordinateSystems.m $
% $Keywords: $

%%
handles=getHandles;

localdir = handles.superTransDir;
url = 'https://opendap.deltares.nl/static/deltares/delftdashboard/supertrans/SuperTrans.xml';
xmlfile = 'SuperTrans.xml';
supertransdata = ddb_getXmlData(localdir,url,xmlfile);

if ~isempty(supertransdata)
    for ii=1:length(supertransdata.file)
        % Download file is update is required of if it does not yet exist
        if supertransdata.file(ii).update == 1 || ~exist([handles.superTransDir filesep supertransdata.file(ii).name],'file')
            disp(['Download EPSG file ' supertransdata.file(ii).name '. This can take a while ...']);
            ddb_urlwrite(supertransdata.file(ii).URL,[handles.superTransDir filesep supertransdata.file(ii).name],[],[],'timeout',120);
        end
    end
end

handles.EPSG=readEPSGData([handles.superTransDir filesep supertransdata.file(1).name]);

nproj=0;
ngeo=0;

for i=1:length(handles.EPSG.coordinate_reference_system.coord_ref_sys_kind)
    switch lower(handles.EPSG.coordinate_reference_system.coord_ref_sys_kind{i}),
        case{'projected'}
            switch lower(handles.EPSG.coordinate_reference_system.coord_ref_sys_name{i})
                case{'epsg vertical perspective example'}
                    % This thing doesn't work
                otherwise
                    nproj=nproj+1;
                    handles.coordinateData.coordSysCart{nproj}=handles.EPSG.coordinate_reference_system.coord_ref_sys_name{i};
            end
        case{'geographic 2d'}
            if handles.EPSG.coordinate_reference_system.coord_ref_sys_code(i)<1000000
                ngeo=ngeo+1;
                handles.coordinateData.coordSysGeo{ngeo}=handles.EPSG.coordinate_reference_system.coord_ref_sys_name{i};
            end
    end
end

setHandles(handles);

