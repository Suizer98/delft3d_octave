function handles = ddb_readCorFile(handles, id)
%DDB_READCORFILE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_readCorFile(handles, id)
%
%   Input:
%   handles =
%   id      =
%
%   Output:
%   handles =
%
%   Example
%   ddb_readCorFile
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
fid=fopen(handles.model.delft3dflow.domain(id).corFile);

for i=1:handles.model.delft3dflow.domain(id).nrAstronomicComponentSets
    componentSets{i}=handles.model.delft3dflow.domain(id).astronomicComponentSets(i).name;
end

ii=[];
k=0;
for i=1:10000
    tx0=fgets(fid);
    if and(ischar(tx0), size(tx0>0))
        v0=strread(tx0,'%q');
    else
        v0='';
    end
    if ~isempty(v0)
        if length(v0)==1
            ii=strmatch(v0{1},componentSets,'exact');
        else
            if ~isempty(ii)
                for j=1:handles.model.delft3dflow.domain(id).astronomicComponentSets(ii).nr
                    components{j}=handles.model.delft3dflow.domain(id).astronomicComponentSets(ii).component{j};
                end
                jj=strmatch(v0{1},components,'exact');
                if ~isempty(jj)
                    handles.model.delft3dflow.domain(id).astronomicComponentSets(ii).correction(jj)=1;
                    handles.model.delft3dflow.domain(id).astronomicComponentSets(ii).amplitudeCorrection(jj)=str2double(v0{2});
                    handles.model.delft3dflow.domain(id).astronomicComponentSets(ii).phaseCorrection(jj)=str2double(v0{3});
                end
            end
        end
    else
        fclose(fid);
        return
    end
end

fclose(fid);



