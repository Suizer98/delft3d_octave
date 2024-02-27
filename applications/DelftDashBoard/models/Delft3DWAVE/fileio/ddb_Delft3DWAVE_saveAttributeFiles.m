function handles = ddb_Delft3DWAVE_saveAttributeFiles(handles, opt)
%ddb_Delft3DWAVE_saveAttributeFiles  Saves all Delft3D-WAVE attribute files

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
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

% $Id: ddb_Delft3DWAVE_saveAttributeFiles.m 10447 2014-03-26 07:06:47Z ormondt $
% $Date: 2014-03-26 15:06:47 +0800 (Wed, 26 Mar 2014) $
% $Author: ormondt $
% $Revision: 10447 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/models/Delft3DWAVE/fileio/ddb_Delft3DWAVE_saveAttributeFiles.m $
% $Keywords: $

%%
sall=0;
if strcmpi(opt,'saveallas')
    sall=1;
end
   
if handles.model.delft3dwave.domain.nrobstacles>0

    if isempty(handles.model.delft3dwave.domain.obstaclepolylinesfile)
        [filename, pathname, filterindex] = uiputfile('*.pli','Select Obstacle Polylines File','');
        if pathname~=0
            curdir=[lower(cd) '\'];
            if ~strcmpi(curdir,pathname)
                filename=[pathname filename];
            end
            handles.model.delft3dwave.domain.obstaclepolylinesfile=filename;
        else
            return
        end
    end    

    if sall || isempty(handles.model.delft3dwave.domain.obstaclefile)
        [filename, pathname, filterindex] = uiputfile('*.obs','Select Obstacles File','');
        if pathname~=0
            curdir=[lower(cd) '\'];
            if ~strcmpi(curdir,pathname)
                filename=[pathname filename];
            end
            handles.model.delft3dwave.domain.obstaclefile=filename;
        else
            return
        end
    end    
    ddb_Delft3DWAVE_saveObstacleFile(handles);

end

% Location files
for ii=1:handles.model.delft3dwave.domain.nrlocationsets
    if handles.model.delft3dwave.domain.locationsets(ii).nrpoints>0
       ddb_Delft3DWAVE_saveLocationFile(handles.model.delft3dwave.domain.locationfile{ii},handles.model.delft3dwave.domain.locationsets(ii));
    end
end
