function handles = ddb_countOpenBoundaries(handles, id)
%DDB_COUNTOPENBOUNDARIES  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_countOpenBoundaries(handles, id)
%
%   Input:
%   handles =
%   id      =
%
%   Output:
%   handles =
%
%   Example
%   ddb_countOpenBoundaries
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

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
nb=handles.model.delft3dflow.domain(id).nrOpenBoundaries;

ncor=0;
nastro=0;
nharmo=0;
ntime=0;
nqh=0;

for i=1:nb
    switch handles.model.delft3dflow.domain(id).openBoundaries(i).forcing,
        case{'A'}
            nastro=nastro+1;
            for j=1:handles.model.delft3dflow.domain(id).nrAstronomicComponentSets
                for k=1:handles.model.delft3dflow.domain(id).astronomicComponentSets(j).nr
                    if handles.model.delft3dflow.domain(id).astronomicComponentSets(j).correction(k)
                        ncor=ncor+1;
                    end
                end
            end
        case{'H'}
            nharmo=nharmo+1;
        case{'T'}
            ntime=ntime+1;
        case{'Q'}
            nqh=nqh+1;
    end
end

handles.model.delft3dflow.domain(id).nrAstro=nastro;
handles.model.delft3dflow.domain(id).nrCor=ncor;
handles.model.delft3dflow.domain(id).nrHarmo=nharmo;
handles.model.delft3dflow.domain(id).nrTime=ntime;
handles.model.delft3dflow.domain(id).nrQH=nqh;

