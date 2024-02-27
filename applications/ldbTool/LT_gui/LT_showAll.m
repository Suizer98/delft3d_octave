function LT_showAll(fig,varargin)
%LT_SHOWALL ldbTool GUI function to change zoom level so that all objects
%are shown
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
    fig=gcbf;
end

data=get(fig,'userdata');
ldb=cat(1,data(:,5).ldb);

xL=[min(ldb(:,1)) max(ldb(:,1))];
yL=[min(ldb(:,2)) max(ldb(:,2))];

data3=get(findobj(fig,'tag','LT_showGeoBox'),'userdata');
if ~isempty(data3)&get(findobj(fig,'tag','LT_showGeoBox'),'value')==1
    xdata=get(data3,'XData');
    ydata=get(data3,'YData');    
    xMinImage=min(xdata(:));
    xMaxImage=max(xdata(:));
    yMinImage=min(ydata(:));
    yMaxImage=max(ydata(:));
    xL=[min([min(xL) xMinImage]) max([max(xL) xMaxImage])];
    yL=[min([min(yL) yMinImage]) max([max(yL) yMaxImage])];
end

curAx=findobj(fig,'tag','LT_plotWindow');

if ~isempty(varargin)
    v=version;
    if isempty(varargin{1}) & num2str(v(1,strfind(v,'(R')+[2:5]))<2015
        xL = get(curAx,'XLim');
        yL = get(curAx,'YLim');
    elseif strcmp(varargin{1}.EventName,'SizeChanged')
        % The user has changed the size of the window, let's use the old extent
        xL = get(curAx,'XLim');
        yL = get(curAx,'YLim');
    end
end

if unique(isnan(xL))
    xL = get(curAx,'XLim');
end
if unique(isnan(yL))
    yL = get(curAx,'YLim');
end

% pbar=get(curAx,'PlotBoxAspectRatio');
ax_unit_ori  = get(curAx,'Units');
set(curAx,'Units','pixels');
ax_pos  = get(curAx,'OuterPosition');
set(curAx,'Units',ax_unit_ori);
ratio_ax_pos = (diff(ax_pos([1 3]))./diff(ax_pos([2 4])));
% ratio=pbar(1)/pbar(2);
ratioXY=diff(xL)/diff(yL);
if ratioXY < ratio_ax_pos
%     xL=[mean(xL)-ratio*diff(xL)/2 mean(xL)+ratio*diff(xL)/2];
    xL = mean(xL)+(((diff(xL)./2).*(ratio_ax_pos./ratioXY)).*[-1 1]);
    set(curAx,'YLim',yL,'XLim',xL);
else
%     yL=[mean(yL)-diff(xL)/ratio/2 mean(yL)+diff(xL)/ratio/2];
    yL = mean(yL)+(((diff(yL)./2).*(ratioXY./ratio_ax_pos)).*[-1 1]);
    set(curAx,'XLim',xL,'YLim',yL);
end

zoom(curAx,'reset');