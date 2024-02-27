function period=detran_getPeriod
%DETRAN_GETPERIOD Detran GUI function to read selected period from GUI
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
if isempty(fig); fig=gcf; end

timeWindow=get(findobj(fig,'tag','detran_timeWindow'),'Value');

switch timeWindow
    case 1
        period = 1;
    case 2
        period = 60;
    case 3
        period = 3600;
    case 4
        period = 24*3600;
    case 5
        period = 7*24*3600;
    case 6
        period = 30*24*3600;
    case 7
        period = 365*24*3600;
    case 8
        period = eval(get(findobj(fig,'tag','detran_specTimeWindow'),'String'));
    otherwise
        
end
