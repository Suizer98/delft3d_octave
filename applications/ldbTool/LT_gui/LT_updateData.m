function LT_updateData(outLDB,ldbCell,ldbBegin,ldbEnd,option);
%LT_UPDATEDATA ldbTool GUI function to update the data structure and the
%GUI objects
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

if nargin<5
    option=[];
end

data=LT_getData;

if ~strcmp(lower(option),'noundo')
    for ii=1:4
        data(ii)=data(ii+1);
    end
end

data(5).ldb=outLDB;
data(5).ldbCell=ldbCell;
data(5).ldbBegin=ldbBegin;
data(5).ldbEnd=ldbEnd;
% data(5).oriLDB=data(4).oriLDB;

if ~isempty(data(4).ldb)
    set(findobj(fig,'tag','LT_undoMenu'),'enable','on');
else
    set(findobj(fig,'tag','LT_undoMenu'),'enable','off');
end

LT_setData(data);
LT_setSizeStrings;
LT_plotLdb;

% during update, remove segment selection and plotted selected segments
temp=get(findobj(fig,'tag','LTSE_selectSegmentButton'),'userdata');
if ~isempty(temp)
    hCp=temp{2};
    delete(hCp);
end
set(findobj(fig,'tag','LTSE_selectSegmentButton'),'userdata',[]);
set(findobj(fig,'tag','LTSE_segmentEditButton'),'Enable','off');
set(findobj(fig,'tag','LTSE_selectSegmentButton'),'Value',0);
