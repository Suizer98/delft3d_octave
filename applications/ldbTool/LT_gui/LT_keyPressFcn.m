function LT_keyPressFcn(fig)
%LT_KEYPRESSFCN ldbTool GUI function to use shortcut keys
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
curC=get(fig,'currentCharacter');

if double(get(fig,'currentCharacter')) == 27
    LT_undoLdb;
end

switch curC
    
    case 'z'
        
        LT_zoom(findobj(fig,'tag','LT_zoomBut'));
        
    case 'Z'
        
        LT_showAll(fig);
        
    case 'i'
        
        LTPE_insertPoint(fig);
        
    case 'r'
        
        LTPE_replacePoint(fig);
        
    case 'd'
        
        LTPE_deletePoint(fig);
        
    case 'x'
        
        LTPE_cutPoint(fig);
        
    case '?'
        
        uiwait(msgbox(strvcat('z = Zoom on/off','Z = Show all','i = Insert point','r = Replace point','d = Delete point','x = Cut point'),'Shortcut keys'));
        
end