function LT_initialGuiSettings;
%LT_INITIALGUISETTINGS ldbTool GUI function to set initial GUI settings
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
data=LT_getData;

LT_setSizeStrings;

hBut=findobj(fig,'style','pushbutton');
for ij=1:length(hBut)
    set(hBut(ij),'enable','on');
end

hBox=findobj(fig,'style','checkbox');
for ij=1:length(hBox)
    set(hBox(ij),'enable','on');
end

% set(findobj(fig,'tag','LT_plotWindow'),'XLim',[min(data(5).oriLDB(:,1)) max(data(5).oriLDB(:,1))],'YLim',[min(data(5).oriLDB(:,2)) max(data(5).oriLDB(:,2))]);
set(findobj(fig,'tag','LT_saveMenu'),'enable','on');
set(findobj(fig,'tag','LT_save2Menu'),'enable','on');
set(findobj(fig,'tag','LT_resetMenu'),'enable','on');
set(findobj(fig,'tag','LT_undoMenu'),'enable','off');
set(findobj(fig,'tag','LT_layerSelectMenu'),'enable','on');
