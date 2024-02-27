function [dataIn, dataOut]=LT_getSelectedCells(data)
%LT_GETSELECTEDCELLS ldbTool GUI function to find selected ldb cells
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
[but,fig]=gcbo;

dataIn=data;
temp=get(findobj(gcf,'tag','LTSE_selectSegmentButton'),'userdata');

if isempty(temp) % check if segments are already selected
dataOut=[];
else
    dataOut=data;
    id=temp{1};
    hCp=temp{2};
    dataIn.ldbCell=dataIn.ldbCell(id);
    dataIn.ldbBegin=dataIn.ldbBegin(id,:);
    dataIn.ldbEnd=dataIn.ldbEnd(id,:);
    dataIn.ldb=rebuildLdb(dataIn.ldbCell);
    dataOut.ldbCell(id)=[];
    dataOut.ldbBegin(id,:)=[];
    dataOut.ldbEnd(id,:)=[];
    dataOut.ldb=rebuildLdb(dataOut.ldbCell)    
end