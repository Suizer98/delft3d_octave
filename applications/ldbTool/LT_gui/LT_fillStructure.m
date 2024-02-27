function data=LT_fillStructure(oriLDB,filterSinglePoints)
%LT_FILLSTRUCTURE ldbTool GUI function to create and fill data structure of
%ldbtool
%
% See also: LDBTOOL

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

%% Code
% oriLDB = [Mx2] matrix with ldb-points
% filterSinglePoints: if 1, single points will be removed

[but,fig]=gcbo;

if size(oriLDB,2)>2
    oriLDB = oriLDB(:,1:2);
end

% remove successive nans
did=find(isnan(oriLDB(:,1)));
if ~isempty(did)
    rid=abs(did(1:end-1)-did(2:end));
    remid=find(rid==1);
    oriLDB(did(remid),:)=[];
end

for ii=1:4
    data(ii).ldb=[];
end

ldb=oriLDB;

if filterSinglePoints==1
    ldb=removeSinglePointsLDB(ldb);
end

[ldbCell, ldbBegin, ldbEnd, ldb]=disassembleLdb(ldb);

start_nan = isnan(oriLDB(1,1));
end_nan   = isnan(oriLDB(end,1));

if start_nan && end_nan
    uiwait(warndlg({'First and last points in the ldb-file are no-data points';'Note that these are removed when saving the ldb'},'ldbTool'));
elseif start_nan
    uiwait(warndlg({'First point in the ldb-file is a no-data point';'Note that it is removed when saving the ldb'},'ldbTool'));
elseif end_nan
    uiwait(warndlg({'Last point in the ldb-file is a no-data point';'Note that it is removed when saving the ldb'},'ldbTool'));
end

data(5).ldb = ldb;
data(5).oriLDB = oriLDB;
data(5).ldbCell=ldbCell;
data(5).ldbBegin=ldbBegin;
data(5).ldbEnd=ldbEnd;


