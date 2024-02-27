function LT_undoLdb
%LT_UNDOLDB ldbTool GUI function to undo last actions (max. 5 undo steps)
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

if isempty(data(4).ldb)
    errordlg('No undo possilble','Error');
    set(findobj(fig,'tag','LT_undoMenu'),'enable','off');    
    return
end

for ii=-5:-2
    data(-ii)=data(-ii-1);
end
data(1).ldb=[];
data(1).ldbCell=[];
data(1).ldbBegin=[];
data(1).ldbEnd=[];
data(1).oriLDB=[];

if isempty(data(4).ldb)
    set(findobj(fig,'tag','LT_undoMenu'),'enable','off');    
end

LT_setData(data);
LT_setSizeStrings;
LT_plotLdb;