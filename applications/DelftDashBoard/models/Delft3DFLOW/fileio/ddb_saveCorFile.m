function handles = ddb_saveCorFile(handles, id)
%DDB_SAVECORFILE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_saveCorFile(handles, id)
%
%   Input:
%   handles =
%   id      =
%
%   Output:
%   handles =
%
%   Example
%   ddb_saveCorFile
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
fid=fopen(handles.model.delft3dflow.domain(id).corFile,'w');

nr=handles.model.delft3dflow.domain(id).nrAstronomicComponentSets;

for i=1:nr
    k=0;
    for j=1:handles.model.delft3dflow.domain(id).astronomicComponentSets(i).nr
        if handles.model.delft3dflow.domain(id).astronomicComponentSets(i).correction(j)
            k=k+1;
        end
    end
    if k>0
        fprintf(fid,'%s\n',handles.model.delft3dflow.domain(id).astronomicComponentSets(i).name);
        for j=1:handles.model.delft3dflow.domain(id).astronomicComponentSets(i).nr
            if handles.model.delft3dflow.domain(id).astronomicComponentSets(i).correction(j)
                cmp=handles.model.delft3dflow.domain(id).astronomicComponentSets(i).component{j};
                amp=handles.model.delft3dflow.domain(id).astronomicComponentSets(i).amplitudeCorrection(j);
                pha=handles.model.delft3dflow.domain(id).astronomicComponentSets(i).phaseCorrection(j);
                fprintf(fid,'%s %15.7e %15.7e\n',[cmp repmat(' ',1,8-length(cmp))],amp,pha);
            end
        end
    end
end
fclose(fid);

