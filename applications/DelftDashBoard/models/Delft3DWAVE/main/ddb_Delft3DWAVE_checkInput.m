function ddb_Delft3DWAVE_checkInput(handles)
%DDB_DELFT3DWAVE_CHECKINPUT  Checks Delft3D-WAVE input after saving.

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
%       ormondt
%
%       <EMAIL>	
%
%       <ADDRESS>
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
% Created: 02 Jul 2012
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: ddb_Delft3DWAVE_checkInput.m 10447 2014-03-26 07:06:47Z ormondt $
% $Date: 2014-03-26 15:06:47 +0800 (Wed, 26 Mar 2014) $
% $Author: ormondt $
% $Revision: 10447 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/models/Delft3DWAVE/main/ddb_Delft3DWAVE_checkInput.m $
% $Keywords: $

%%

inp=handles.model.delft3dwave.domain;

%% Domains
if inp.nrgrids==0
    ddb_giveWarning('text','No computional grids are specified!');
end

%% Boundaries
if inp.nrboundaries==0
    ddb_giveWarning('text','No open boundaries are specified!');
end

%% Bathymetry
for ii=1:inp.nrgrids
    if isempty(inp.domains(ii).bedlevel)
        ddb_giveWarning('text',['No bathymetry specified for domain ' inp.domains(ii).gridname '!']);
    end
end

%% Quadruplets
if inp.quadruplets
    iwarn=0;
    for ii=1:inp.nrgrids
        if ~inp.domains(ii).flowwind && inp.windspeed==0
            iwarn=1;
        end
    end
    if iwarn
        ddb_giveWarning('text','Quadruplets are turned on with zero wind conditions!');
    end
end

