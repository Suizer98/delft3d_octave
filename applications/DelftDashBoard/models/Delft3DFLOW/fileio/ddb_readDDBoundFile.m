function handles = ddb_readDDBoundFile(handles, fname)
%DDB_READDDBOUNDFILE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_readDDBoundFile(handles, fname)
%
%   Input:
%   handles =
%   fname   =
%
%   Output:
%   handles =
%
%   Example
%   ddb_readDDBoundFile
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

% $Id: ddb_readDDBoundFile.m 10447 2014-03-26 07:06:47Z ormondt $
% $Date: 2014-03-26 15:06:47 +0800 (Wed, 26 Mar 2014) $
% $Author: ormondt $
% $Revision: 10447 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/models/Delft3DFLOW/fileio/ddb_readDDBoundFile.m $
% $Keywords: $

%%
txt=ReadTextFile(fname);

nbnd=length(txt)/10;

rids={''};

nd=0;

handles.model.delft3dflow.domain.DDBoundaries=[];

k=1;
for i=1:nbnd
    handles.model.delft3dflow.DDBoundaries(i).runid1=txt{k}(1:end-4);
    ii=strmatch(txt{k}(1:end-4),rids,'exact');
    if isempty(ii)
        nd=nd+1;
        rids{nd}=txt{k}(1:end-4);
    end
    handles.model.delft3dflow.DDBoundaries(i).m1a=str2double(txt{k+1});
    handles.model.delft3dflow.DDBoundaries(i).n1a=str2double(txt{k+2});
    handles.model.delft3dflow.DDBoundaries(i).m1b=str2double(txt{k+3});
    handles.model.delft3dflow.DDBoundaries(i).n1b=str2double(txt{k+4});
    handles.model.delft3dflow.DDBoundaries(i).runid2=txt{k+5}(1:end-4);
    ii=strmatch(txt{k+5}(1:end-4),rids,'exact');
    if isempty(ii)
        nd=nd+1;
        rids{nd}=txt{k+5}(1:end-4);
    end
    handles.model.delft3dflow.DDBoundaries(i).m2a=str2double(txt{k+6});
    handles.model.delft3dflow.DDBoundaries(i).n2a=str2double(txt{k+7});
    handles.model.delft3dflow.DDBoundaries(i).m2b=str2double(txt{k+8});
    handles.model.delft3dflow.DDBoundaries(i).n2b=str2double(txt{k+9});
    k=k+10;
end

handles.model.delft3dflow.nrDomains=nd;

for i=1:nd
    handles.model.delft3dflow.domain(i).runid=rids{i};
end

