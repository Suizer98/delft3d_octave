function LTSE_copySegment(id)
%LTSE_COPYSEGMENT ldbTool GUI function to copy a ldb segment to another
%layer
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

if isempty(id)
    return
end

data=LT_getData;
ldbCell=data(5).ldbCell;
ldbEnd=data(5).ldbEnd;
ldbBegin=data(5).ldbBegin;
ldb=data(5).ldb;
nanId=find(isnan(ldb(:,1)));

ldbCell=ldbCell(id);
ldbBegin=ldbBegin(id,:);
ldbEnd=ldbEnd(id,:);
ldb=rebuildLdb(ldbCell);

numOfLayers=size(get(findobj(fig,'tag','LT_layerSelectMenu'),'String'),1);
curLayer=get(findobj(fig,'tag','LT_layerSelectMenu'),'value');

% check if number of layers is > 1 (cannot delete a layer if there is only one)
if numOfLayers==1
    errordlg('Only one layer available');
    return
end

layerIDs=[1:numOfLayers];

layerIDs=layerIDs(~ismember(layerIDs,curLayer));
popUpChoices=[repmat('Layer ',length(layerIDs),1) num2str(layerIDs')];
[layer,v] = listdlg('promptString','Select a layer to copy to:','SelectionMode','single','ListString',popUpChoices);
layer=layerIDs(layer);

data=LT_getData(layer);
data(5).ldb=[data(5).ldb; ldb];
data(5).ldbCell=[data(5).ldbCell; ldbCell];
data(5).ldbBegin=[data(5).ldbBegin; ldbBegin];
data(5).ldbEnd=[data(5).ldbEnd; ldbEnd];

LT_setData(data,layer);
LT_plotLdb;