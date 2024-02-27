function detran_loadLandboundary
%DETRAN_LOADTRANSECTS Detran GUI function to load landboundary file
%
%   See also detran

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Arjan Mol
%
%       arjan.mol@deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

[but,fig]=gcbo;
data=get(fig,'userdata');

% check if wlsettings are available
wldir = which('landboundary');
if isempty(wldir)
    try % try wlsettings
        wlsettings;
    catch % wlsettings not found, check if Delft3D has been installed
        d3ddir = getenv('D3D_HOME');
        arch = getenv('ARCH');
        if isempty(d3ddir)
            error('Delft3D installation is required...');
            return
        else
            addpath([d3ddir filesep arch filesep 'matlab']);
        end
    end
end

data.ldb=landboundary('read');

set(fig,'userdata',data);