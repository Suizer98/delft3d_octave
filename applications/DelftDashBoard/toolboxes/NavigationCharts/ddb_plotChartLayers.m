function ddb_plotChartLayers(handles)
%DDB_PLOTCHARTLAYERS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_plotChartLayers(handles)
%
%   Input:
%   handles =
%
%
%
%
%   Example
%   ddb_plotChartLayers
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
% Created: 02 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
figure(handles.GUIHandles.mainWindow);

s=handles.toolbox.navigationcharts.layers;
p=handles.toolbox.navigationcharts.plotLayer;

orisys.name='WGS 84';
orisys.type='geographic';
newsys=handles.screenParameters.coordinateSystem;

h=findobj(gca,'Tag','NavigationChartLayer');
if ~isempty(h)
    delete(h);
end

fn=fieldnames(s);
nf=length(fn);

for i=1:nf
    n=length(s.(fn{i}));
    iplot=p.(fn{i});
    if iplot>-1
        for j=1:n
            if isfield(s.(fn{i})(j),'Type')
                if ~isempty(lower(s.(fn{i})(j).Type))
                    switch(lower(s.(fn{i})(j).Type))
                        case{'polygon'}
                            if isfield(s.(fn{i})(j),'Outer')
                                np=length(s.(fn{i})(j).Outer);
                                for k=1:np
                                    x=s.(fn{i})(j).Outer(k).Coordinates(:,1);
                                    y=s.(fn{i})(j).Outer(k).Coordinates(:,2);
                                end
                                x(isnan(y))=NaN;
                                y(isnan(x))=NaN;
                                [x,y]=ddb_coordConvert(x,y,orisys,newsys);
                                ptch=patch(x,y,'y');hold on;%drawnow;
                                set(ptch,'Tag','NavigationChartLayer','UserData',fn{i});
                            end
                            if isfield(s.(fn{i})(j),'Inner')
                                if ~isempty(s.(fn{i})(j).Inner)
                                    np=length(s.(fn{i})(j).Inner);
                                    for k=1:np
                                        x=s.(fn{i})(j).Inner(k).Coordinates(:,1);
                                        y=s.(fn{i})(j).Inner(k).Coordinates(:,2);
                                    end
                                    x(isnan(y))=NaN;
                                    y(isnan(x))=NaN;
                                    [x,y]=ddb_coordConvert(x,y,orisys,newsys);
                                    ptch=patch(x,y,'y');hold on;
                                    set(ptch,'Tag','NavigationChartLayer','UserData',fn{i});
                                end
                            end
                            if iplot
                                set(ptch,'Visible','on');
                            else
                                set(ptch,'Visible','off');
                            end
                        case{'point'}
                            x=s.(fn{i})(j).Coordinates(:,1);
                            y=s.(fn{i})(j).Coordinates(:,2);
                            [x,y]=ddb_coordConvert(x,y,orisys,newsys);
                            plt=plot(x,y,'.');hold on;
                            set(plt,'MarkerSize',5,'MarkerEdgeColor','k','MarkerFaceColor','k');
                            set(plt,'Tag','NavigationChartLayer','UserData',fn{i});
                            if iplot
                                set(plt,'Visible','on');
                            else
                                set(plt,'Visible','off');
                            end
                        case{'polyline'}
                            x=s.(fn{i})(j).Coordinates(:,1);
                            y=s.(fn{i})(j).Coordinates(:,2);
                            [x,y]=ddb_coordConvert(x,y,orisys,newsys);
                            plt=plot(x,y,'k');hold on;
                            set(plt,'Tag','NavigationChartLayer','UserData',fn{i});
                            if iplot
                                set(plt,'Visible','on');
                            else
                                set(plt,'Visible','off');
                            end
                        case{'multipoint'}
                            x=s.(fn{i})(j).Coordinates(:,1);
                            y=s.(fn{i})(j).Coordinates(:,2);
                            [x,y]=ddb_coordConvert(x,y,orisys,newsys);
                            sz=zeros(size(x))+5;
                            c=-s.(fn{i})(j).Coordinates(:,3);
                            sc=scatter(x,y,sz,c,'filled');hold on;
                            set(sc,'Tag','NavigationChartLayer','UserData',fn{i});
                            if iplot
                                set(sc,'Visible','on');
                            else
                                set(sc,'Visible','off');
                            end
                    end
                end
                %                 if isfield(s.(fn{i})(j),'OBJNAM')
                %                     name=['  ' s.(fn{i})(j).OBJNAM];
                %                     if ~isempty(name)
                %                         xt=mean(x);
                %                         yt=mean(y);
                %                         tx=text(xt,yt,name);
                %                         set(tx,'FontSize',6);
                %                         set(tx,'Tag','NavigationChartLayer','UserData',fn{i});
                %                         if s.(fn{i})(j).Plot
                %                             set(tx,'Visible','on');
                %                         else
                %                             set(tx,'Visible','off');
                %                         end
                %                     end
                %                 end
            end
        end
    end
end

