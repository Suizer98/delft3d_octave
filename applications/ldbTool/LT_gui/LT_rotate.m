function LT_rotate
%LT_ROTATE ldbTool GUI function to rotate the ldb
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

rotate=inputdlg({'Specify angle of rotation (clockwise):','Specify (x,y)-coordinates of rotation point:'},'LDBTool',1,{'0','0 0'});
if isempty(rotate{1})
   errordlg('No valid rotation angle specified!','ldbTool');
   return
elseif isempty(rotate{2})
   errordlg('No valid rotation point specified!','ldbTool');
   return
end

rotPoint=str2num(char(rotate{2}));
if length(rotPoint)<2
   errordlg('No valid rotation point specified!','ldbTool');
   return
end

data=LT_getData;
ldb=data(5).ldb;

ldb=rotateLDB(ldb,rotPoint(1),rotPoint(2),str2num(char(rotate{1})));

[ldbCell, ldbBegin, ldbEnd, ldb]=disassembleLdb(ldb);
LT_updateData(ldb,ldbCell,ldbBegin,ldbEnd);