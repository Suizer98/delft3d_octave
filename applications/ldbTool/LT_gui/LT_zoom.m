function LT_zoom(but)
%LT_ZOOM ldbTool GUI function to enable zooming
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
if nargin==0
    [but,fig]=gcbo;
else
    fig=get(but,'parent');
end

val=get(findobj(fig,'tag','LT_zoomBut'),'userdata');
if isempty(val)|val==0
    val=1;
else
    val=0;
end


switch val
    case 1
        set(findobj(fig,'tag','LT_zoomBut'),'String','Zoom is on','value',1,'userdata',1);
        set(gcf,'pointer','circle');
        zoom on
    case 0
        set(findobj(fig,'tag','LT_zoomBut'),'String','Zoom is off','value',0,'userdata',0);
        set(gcf,'pointer','arrow');
        zoom off
end
