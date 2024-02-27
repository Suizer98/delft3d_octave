function handles = ddb_readBchFile(handles, id)
%DDB_READBCHFILE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_readBchFile(handles, id)
%
%   Input:
%   handles =
%   id      =
%
%   Output:
%   handles =
%
%   Example
%   ddb_readBchFile
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
fid=fopen(handles.model.delft3dflow.domain(id).bchFile);

nrb=handles.model.delft3dflow.domain(id).nrOpenBoundaries;

tx0=fgets(fid);
if and(ischar(tx0), size(tx0>0))
    v=strread(tx0,'%q');
end
v=str2num(char(v));

handles.model.delft3dflow.domain(id).openBoundaries(1).nrHarmonicComponents=length(v);
nrh=length(v);
handles.model.delft3dflow.domain(id).openBoundaries(1).harmonicComponents=v;

tx0=fgets(fid);

for i=1:nrb
    handles.model.delft3dflow.domain(id).openBoundaries(i).nrHarmonicComponents=handles.model.delft3dflow.domain(id).openBoundaries(1).nrHarmonicComponents;
    handles.model.delft3dflow.domain(id).openBoundaries(i).harmonicComponents=handles.model.delft3dflow.domain(id).openBoundaries(1).harmonicComponents;
    if handles.model.delft3dflow.domain(id).openBoundaries(i).forcing=='H'
        tx0=fgets(fid);
        if and(ischar(tx0), size(tx0>0))
            v=strread(tx0,'%q');
        end
        v=str2num(char(v));
        handles.model.delft3dflow.domain(id).openBoundaries(i).harmonicAmpA=v;
    end
end

for i=1:nrb
    if handles.model.delft3dflow.domain(id).openBoundaries(i).forcing=='H'
        tx0=fgets(fid);
        if and(ischar(tx0), size(tx0>0))
            v=strread(tx0,'%q');
        end
        v=str2num(char(v));
        handles.model.delft3dflow.domain(id).openBoundaries(i).harmonicAmpB=v;
    end
end

tx0=fgets(fid);

for i=1:nrb
    if handles.model.delft3dflow.domain(id).openBoundaries(i).forcing=='H'
        tx0=fgets(fid);
        if and(ischar(tx0), size(tx0>0))
            v=strread(tx0,'%q');
        end
        v=str2num(char(v));
        handles.model.delft3dflow.domain(id).openBoundaries(i).harmonicPhaseA=zeros(1,nrh);
        handles.model.delft3dflow.domain(id).openBoundaries(i).harmonicPhaseA(2:end)=v;
    end
end

for i=1:nrb
    if handles.model.delft3dflow.domain(id).openBoundaries(i).forcing=='H'
        tx0=fgets(fid);
        if and(ischar(tx0), size(tx0>0))
            v=strread(tx0,'%q');
        end
        v=str2num(char(v));
        handles.model.delft3dflow.domain(id).openBoundaries(i).harmonicPhaseB=zeros(1,nrh);
        handles.model.delft3dflow.domain(id).openBoundaries(i).harmonicPhaseB(2:end)=v;
    end
end

fclose(fid);

