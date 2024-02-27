function LT_showAxis
%LT_SHOWAXIS ldbTool GUI function to show or hide axis
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

axes(findobj(fig,'tag','LT_plotWindow'));

if get(findobj(fig,'tag','LT_showAxis'),'value')==1;
    box on; grid on;
    try; set(get(gca,'XAxis'),'Visible','on'); catch; set(findobj(fig,'tag','LT_plotWindow'),'XColor','k'); end;
    try; set(get(gca,'YAxis'),'Visible','on'); catch; set(findobj(fig,'tag','LT_plotWindow'),'YColor','k'); end;
else
    box off; grid off;
    try; set(get(gca,'XAxis'),'Visible','off'); catch; set(findobj(fig,'tag','LT_plotWindow'),'XColor','w'); end;
    try; set(get(gca,'YAxis'),'Visible','off'); catch; set(findobj(fig,'tag','LT_plotWindow'),'YColor','w'); end;
end