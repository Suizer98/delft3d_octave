function LT_showImage
%LT_SHOWIMAGE ldbTool GUI function to show or hide a loaded georeferenced
%image
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

data3=get(findobj(fig,'tag','LT_showGeoBox'),'userdata');

if get(findobj(fig,'tag','LT_showGeoBox'),'value')==1
    if isempty(data3)
        uiwait(warndlg('First open image','ldbTool'));
        set(findobj(fig,'tag','LT_showGeoBox'),'value',0);
    else
        set(fig,'renderer','zbuffer');    
%         axes(findobj(fig,'tag','LT_plotWindow'));
        set(data3,'visible','on');
    end
else
    set(data3,'visible','off');
end
LT_plotLdb;