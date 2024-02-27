function LTSE_selectSegmentsInPoly
%LTSE_SELECTSEGMENTSINPOLY ldbTool GUI function to select segments in
%selection polygon
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

set(findobj(fig,'tag','LT_zoomBut'),'String','Zoom is off','value',0);
zoom off
set(gcf,'pointer','arrow');

temp=get(findobj(gcf,'tag','LTSE_selectSegmentButton'),'userdata');

if isempty(temp) % check if segments are already selected
    idSel=[];
    hCp=[];
else
    idSel=temp{1};
    hCp=temp{2};
end

pol=LT_getData(0);

if numel(pol(5).ldb(~isnan(pol(5).ldb)))==0 % check if polygon exists
    return
else
    pol=pol(5).ldb; % load polygon
end

data=LT_getData; % load ldb data from current layer

if isempty(data(5).ldbEnd)
    return
else
    idStart=find(inpolygon(data(5).ldbEnd(:,1),data(5).ldbEnd(:,2),pol(:,1),pol(:,2))); % find start points within poly
    idEnd=find(inpolygon(data(5).ldbBegin(:,1),data(5).ldbBegin(:,2),pol(:,1),pol(:,2))); % find end points within poly
end

idInPoly=intersect(idStart,idEnd); % both start and end point must be in polygon

for ii=1:length(idInPoly)
    hCp(end+1)=plot(data(5).ldbCell{idInPoly(ii)}(:,1),data(5).ldbCell{idInPoly(ii)}(:,2),'color','b','linewidth',2);
end

idSel=[idSel; idInPoly];

set(findobj(fig,'tag','LTSE_segmentEditButton'),'Enable','on');
idSel=unique(idSel);
set(findobj(gcf,'tag','LTSE_selectSegmentButton'),'userdata',{idSel,hCp},'value',1);
set(findobj(fig,'tag','LT_ldbText6'),'String','Instructions: perform action on selected segments, or click button again to deselect');