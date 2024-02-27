function boundary = delft3dfm_read_boundaries(extfile)
% ddb_DFlowFM_readExternalForcing  One line description goes here.

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

% $Id: ddb_DFlowFM_readExternalForcing.m 15813 2019-10-04 06:15:03Z ormondt $
% $Date: 2019-10-04 14:15:03 +0800 (vr, 04 okt 2019) $
% $Author: ormondt $
% $Revision: 15813 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/models/DFlowFM/fileio/ddb_DFlowFM_readExternalForcing.m $
% $Keywords: $

%% Reads DFlow-FM boundary conditions (ext and bc files)
% Reorders boundaries and merges boundaries with the same pli file

if ~isempty(fileparts(extfile))
    pth=[fileparts(extfile) filesep];
else
    pth='.\';
end

[boundary,forcingfiles]=delft3dfm_read_ext_file(extfile);

% Now read the pli files
for ibnd=1:length(boundary)
    [x,y]=landboundary('read',[pth filesep boundary(ibnd).locationfile]);
    boundary(ibnd).x=x;
    boundary(ibnd).y=y;
end

frc=[];
for ifrcf=1:length(forcingfiles)
    if exist([pth filesep forcingfiles{ifrcf}],'file')
        frc0=delft3dfm_read_bc_file([pth forcingfiles{ifrcf}]);
    else
        % File does not exist (yet)
        frc0=[];
    end
    frc=[frc frc0];
end

boundary=ddb_reorder_fm_boundaries(boundary,frc);

for ib=1:length(boundary)
    name=boundary(ib).boundary.location_file(1:end-4);
    boundary(ib).boundary.name=name;
    boundary(ib).boundary.activenode=1;
    boundary(ib).boundary.handle=-999;
    for ip=1:length(boundary(ib).boundary.x)
        boundary(ib).boundary.nodenames{ip}=[name '_' num2str(ip,'%0.4i')];
    end
end

