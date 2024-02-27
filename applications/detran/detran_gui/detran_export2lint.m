function detran_export2lint
%DETRAN_EXPORT2LINT Detran GUI function to save transort rates to lint-file
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

if isempty(data.transectData)
    return
end

period=detran_getPeriod;
pores=detran_getPoreVolume;
CS=period.*data.transectData(:,1)./(1-pores);

[namL,patL]=uiputfile('*.int','Save transports of reduced climate to');
tekal('write',[patL filesep namL],[[1:length(CS)]' CS]);

if get(findobj(fig,'tag','detran_plotGrossBox'),'Value')==1
    CSPlus=period.*data.transectData(:,2)./(1-pores);
    CSMin=period.*data.transectData(:,3)./(1-pores);
    tekal('write',fillExtension([patL filesep namL '_grossPlus'],'int'),[[1:length(CSPlus)]' CSPlus]);
    tekal('write',fillExtension([patL filesep namL '_grossMin'],'int'),[[1:length(CSMin)]' CSMin]);
end
