function detran_loadTransects
%DETRAN_LOADTRANSECTS Detran GUI function to load transects from file
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

if isempty(data.edit)
    errordlg('First load transport data')
    return
end

[nam,pat]=uigetfile('*.pol','Select file with transects');
if nam==0
    return
end

ldb=landboundary('read',[pat nam]);
[ldbCell, ldbBegin, ldbEnd, ldbIn]=detran_disassembleLdb(ldb);
ldb=[ldbBegin ldbEnd];
edit=data.edit;
strucNames=fieldnames(edit);
for ii=1:length(strucNames)
    eval([strucNames{ii} '=edit.' strucNames{ii} ';']);
end
hw=waitbar(0,'Please wait while loading transects...');
for ii=1:size(ldb,1)
    [xt,yt]=detran_uvData2xyData(yatu,yatv,alfa);
    [CS(ii),plusCS(ii),minCS(ii)]=detran_TransArbCSEngine(xcor,ycor,xt,yt,ldb(ii,1:2),ldb(ii,3:4));
    waitbar(ii/size(ldb,1),hw);
end
close(hw);
data.transectData=[CS' plusCS' minCS'];
data.transects=ldb;
set(fig,'userdata',data);