function detran_plotLdb
%DETRAN_PLOTLDB Detran GUI function to plot landboundary
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

if isempty(data.ldb)
    set(findobj(fig,'tag','detran_plotLdbBox'),'Value',0);
    return
end

axes(findobj(fig,'tag','axes1'));
hold on;
try
    delete(findobj(fig,'tag','ldb'));
end

if get(findobj(fig,'tag','detran_plotLdbBox'),'Value')==1
%     ldbCell=disassembleLdb(data.ldb);
%     for ii=1:length(ldbCell)
%         l(ii)=fill(ldbCell{ii}(:,1),ldbCell{ii}(:,2),[0 0.5 0]);
%     end
%     set(l,'FaceVertexCData',[0 0.5 0],'tag','ldb'); % dit is blijkbaar nodig om de volgende warning te voorkomen: Warning: Patch FaceVertexCData of size 0 cannot be used with Flat shading.
    l=filledLDB(data.ldb,[0 0 0],[0 0.5 0],[],1000);
    set(l,'tag','ldb');
end

set(gca,'tag','axes1');
