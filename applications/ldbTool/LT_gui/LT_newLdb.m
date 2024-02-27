function LT_newLdb
%LT_NEWLDB ldbTool GUI function to create new ldb
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
drawnow

if nargin==0
[but,fig]=gcbo;
end

% data=LT_getData;
    
data(1).ldb=[];
data(2).ldb=[];
data(3).ldb=[];
data(4).ldb=[];
data(5).ldb=[nan nan];

data(5).ldbCell=[];
data(5).ldbBegin=[];
data(5).ldbEnd=[];
data(5).oriLDB=[nan nan];

LT_setData(data);
% set(findobj(fig,'tag','LT_showGeoBox'),'userdata',[]);
set(findobj(fig,'tag','LTSP_plotStartEndBox'),'value',0);

hBox=findobj(fig,'style','checkbox');
for ij=1:length(hBox)
      set(hBox(ij),'enable','on');
end 

set(findobj(fig,'tag','LT_showOriBox'),'enable','off');
set(findobj(fig,'tag','LT_saveMenu'),'enable','on');
set(findobj(fig,'tag','LT_save2Menu'),'enable','on');
LT_plotLdb;