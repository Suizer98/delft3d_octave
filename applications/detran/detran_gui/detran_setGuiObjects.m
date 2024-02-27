function detran_setGuiObjects
%DETRAN_SETGUIOBJECTS Detran GUI function to set GUI objects to default values
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

[but, fig]=gcbo;

data=get(fig,'userdata');

% first, put everything on
set(findobj(fig,'Enable','Inactive'),'Enable','On');

if ~isfield(data.input,'xcor') % in case of trih-files!
    set(findobj(fig,'tag','detran_transType'),'Enable','On');
    if size(data.namSed,1)==1
        set(findobj(fig,'tag','detran_fraction'),'Enable','off');
    else
        set(findobj(fig,'tag','detran_fraction'),'Enable','on');
        set(findobj(fig,'tag','detran_fraction'),'String',strvcat(data.namSed,'sum of fractions'));
    end
    set(findobj(fig,'tag','detran_loadTransectsBut'),'Enable','Inactive');
    set(findobj(fig,'tag','detran_saveTransectsBut'),'Enable','Inactive');
    set(findobj(fig,'tag','detran_adjustTransectBut'),'Enable','Inactive');
    set(findobj(fig,'tag','detran_addTransectBut'),'Enable','Inactive');
else % in case of trim-files
    if size(data.input.namSed{1},1)==1
        set(findobj(fig,'tag','detran_fraction'),'Enable','off');
    else
        set(findobj(fig,'tag','detran_fraction'),'Enable','on');
        set(findobj(fig,'tag','detran_fraction'),'String',strvcat(data.input.namSed{1},'sum of fractions'));
    end
end