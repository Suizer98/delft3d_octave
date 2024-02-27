function ddb_plotTimeSeries2(opt,varargin)
%DDB_PLOTTIMESERIES  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_plotTimeSeries(times, prediction, name)
%
%   Input:
%   times      =
%   prediction =
%   name       =
%
%
%
%
%   Example
%   ddb_plotTimeSeries
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 29 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: ddb_plotTimeSeries2.m 8254 2013-03-01 13:55:47Z ormondt $
% $Date: 2013-03-01 21:55:47 +0800 (Fri, 01 Mar 2013) $
% $Author: ormondt $
% $Revision: 8254 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/main/plot/data/ddb_plotTimeSeries2.m $
% $Keywords: $

%%

switch opt
    case{'makefigure'}
        data=varargin{1};
        makefigure(data);
    case{'selectparameter'}
        changeparameter;
end

%%
function makefigure(data)

handles=getHandles;

xmldir=[handles.settingsDir 'xml' filesep];
xmlfile='delftdashboard.plottimeseries.xml';

n=0;
for ii=1:length(data.parameters)
    data.allparameternames{ii}=data.parameters(ii).parameter.name;
    if sum(data.parameters(ii).parameter.size(2:5))==0
        % timeseries
        n=n+1;
        data.parameternames{n}=data.parameters(ii).parameter.name;
    end
end

data.activeparameter=data.parameternames{1};

gui_newWindow(data,'xmldir',xmldir,'xmlfile',xmlfile,'iconfile',[handles.settingsDir filesep 'icons' filesep 'deltares.gif'],'modal',0);

iac=strmatch(data.parameternames{1},data.allparameternames,'exact');
elements=getappdata(gcf,'elements');
h=elements(1).element.handle;
p=plot(h,data.parameters(iac).parameter.time,data.parameters(iac).parameter.val);
datetick('x');
title(h,data.stationname);
xlabel(h,data.timezone);
ylabel(h,data.parameters(iac).parameter.unit);
set(h,'XGrid','on','YGrid','on');
usd=get(gcf,'UserData');
usd.plothandle=p;
set(gcf,'UserData',usd);
set(gcf,'Name',data.stationname);

tbh=uitoolbar(gcf);

c=load([handles.settingsDir filesep 'icons' filesep 'icons_muppet.mat']);

h = uitoggletool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Zoom In');
set(h,'ClickedCallback',{@zoomInOutPan,1,'dummy',[],[],[]});
set(h,'Tag','UIToggleToolZoomIn');
set(h,'cdata',c.ico.zoomin16);
setappdata(gcf,'zoominhandle',h);

h = uitoggletool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Zoom Out');
set(h,'ClickedCallback',{@zoomInOutPan,2,'dummy',[],[],[]});
set(h,'Tag','UIToggleToolZoomOut');
set(h,'cdata',c.ico.zoomout16);
setappdata(gcf,'zoomouthandle',h);

%%
function changeparameter
data=get(gcf,'UserData');
par=data.activeparameter;
iac=strmatch(par,data.allparameternames,'exact');
y=data.parameters(iac).parameter.val;
set(data.plothandle,'YData',y);
ylabel(gca,data.parameters(iac).parameter.unit);
if sum(~isnan(y))>0
    ylim=[floor(min(y)) ceil(max(y))];
    if ylim(2)==ylim(1)
        ylim(1)=ylim(1)-1;
        ylim(2)=ylim(2)+1;
    end
    set(gca,'ylim',ylim)
end
