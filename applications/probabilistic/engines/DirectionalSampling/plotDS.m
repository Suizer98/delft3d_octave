function plotDS(varargin)
%PLOTDS Plots results from DS function
%
%   Plots results of DS function. Can also be used to plot intermediate
%   results and create animations by updating data.
%
%   Syntax:
%   plotDS(varargin)
%
%   Input:
%   varargin  = DS result structure
%                   or
%               separate DS result variables in order:
%                   un beta ARS P_f P_e P_a Accuracy Calc Calc_ARS Calc_dir
%                   progress exact notexact converged
%
%   Output:
%   none
%
%   Example
%   plotDS(result)
%   plotDS(un,beta,ARS,P_f,P_e,P_a,Accuracy,Calc,Calc_ARS,Calc_dir,progress,exact,notexact,converged)
%
%   See also DS

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl	
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
% Created: 17 Aug 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: plotDS.m 7544 2012-10-22 08:00:25Z hoonhout $
% $Date: 2012-10-22 16:00:25 +0800 (Mon, 22 Oct 2012) $
% $Author: hoonhout $
% $Revision: 7544 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/engines/DirectionalSampling/plotDS.m $
% $Keywords: $

%% read input

if isempty(varargin)
    error('No data');
else
    if isstruct(varargin{1})
        r = varargin{1};
        f = fieldnames(r.Output);
        for i = 1:length(f)
            eval([f{i} '=r.Output.(f{i});']);
            progress = 1;
        end
    else
        [un beta ARS P_f P_e P_a Accuracy Calc Calc_ARS Calc_dir progress exact notexact converged] = deal(varargin{:});
    end
end

%% plot

fh = findobj('Tag','DSprogress');

% initialize plot
if isempty(fh)
    fh = figure('Tag','DSprogress');

    s    = [];
    s(1) = subplot(3,1,[1 2]); hold on;
    s(2) = axes('Position',get(s(1),'Position')); hold on;
    
    linkaxes(s,'xy');
    
    set(s, 'Color', 'none'); box on;
    set(s(1),'XTick',[],'YTick',[],'Tag','axARS');
    set(s(2),'Tag','axSamples');
    
    axis(s,'equal')

    uitable( ...
        'Units','normalized', ...
        'Position',[0.09 0.05 0.82 0.25],...
        'Data', [], ...
        'ColumnName', {'total', 'exact', 'approx', 'not converged' 'model'},...
        'RowName', {'N' 'P' 'Accuracy' 'Ratio'});
end

ax  = findobj(fh,'Type','axes','Tag','axSamples');
uit = findobj(fh,'Type','uitable');

d = find(ARS(1).active, 2);

% plot response surface
axARS = findobj(fh,'Type','axes','Tag','axARS');
[gx gy gz] = plotARS(ARS);

% plot DS samples
up = un.*repmat(beta(:),1,size(un,2));

phr = findobj(ax,'Tag','PRS');
ph1 = findobj(ax,'Tag','P1');
ph2 = findobj(ax,'Tag','P2');
ph3 = findobj(ax,'Tag','P3');
dps = findobj(ax,'Tag','DPs');
prs = findobj(axARS,'Tag','ARS');

u_dps = cat(1,ARS.u_DP);
u_ARS = cat(1,ARS.u);

if isempty(ph1) || isempty(ph2) || isempty(ph3) || isempty(dps) || isempty(prs)
    
    prs = pcolor(axARS,gx,gy,gz);
    
    phr = scatter(u_ARS(:,1),u_ARS(:,2),20,'.c');
    ph1 = scatter(ax,un(~converged,d(1)),un(~converged,d(2)),'MarkerEdgeColor','b');
    ph2 = scatter(ax,up(notexact,  d(1)),up(notexact,  d(2)),'MarkerEdgeColor','r');
    ph3 = scatter(ax,up(exact,     d(1)),up(exact,     d(2)),'MarkerEdgeColor','g');
    if ~isempty(u_dps)
        dps = scatter(ax,u_dps(:,1),u_dps(:,2),[],'c','filled','MarkerEdgeColor','k');
    end

    set(prs,'Tag','ARS','DisplayName','ARS');
    set(phr,'Tag','PRS','DisplayName','ARS evaluations');
    set(ph1,'Tag','P1','DisplayName','not converged');
    set(ph2,'Tag','P2','DisplayName','approximated');
    set(ph3,'Tag','P3','DisplayName','exact');
    
    if ~isempty(u_dps)
        set(dps,'Tag','DPs','DisplayName','design points');
    end
else
    set(prs,'CData',gz)
    set(phr,'XData',u_ARS(:,1),'YData',u_ARS(:,2));
    set(ph1,'XData',un(~converged,d(1)),'YData',un(~converged,d(2)));
    set(ph2,'XData',up(notexact,  d(1)),'YData',up(notexact,  d(2)));
    set(ph3,'XData',up(exact,     d(1)),'YData',up(exact,     d(2)));
    
    if ~isempty(u_dps)
        set(dps,'XData',u_dps(:,1),'YData',u_dps(:,2));
    end
end

% plot beta sphere
[x1,y1] = cylinder(min([ARS.betamin]),100);
[x2,y2] = cylinder(min([ARS.betamin])+max([ARS.dbeta]),100);

ph1 = findobj(ax,'Tag','B1');
ph2 = findobj(ax,'Tag','B2');

if isempty(ph1) || isempty(ph2)
    plot(ax,0,0,'+k','DisplayName','origin');
    
    ph1 = plot(ax,x1(1,:),y1(1,:),':r');
    ph2 = plot(ax,x2(1,:),y2(1,:),'-r');

    set(ph1,'Tag','B1','DisplayName','\beta_{min}');
    set(ph2,'Tag','B2','DisplayName','\beta_{threshold}');
else
    set(ph1,'XData',x1(1,:),'YData',y1(1,:));
    set(ph2,'XData',x2(1,:),'YData',y2(1,:));
end

% create labels
xlabel(ax,'u_1');
ylabel(ax,'u_2');

cm = colormap('gray');

colorbar('peer',axARS);
colormap(axARS,[flipud(cm) ; cm]);
shading(axARS,'flat');

if ~isempty(gz) && ~all(isnan(gz(:)))
    clim(axARS,[-1 1]*std(abs(gz(:))));
else
    clim(axARS,[-1 1]);
end

title(ax,sprintf('%4.3f%%', progress*100));

legend(ax,'-DynamicLegend','Location','NorthWestOutside');
legend(ax,'show');

% update table contents
data = { ...
    length(beta) sum(exact) sum(notexact) sum(~converged)   Calc                ; ...
    P_f          P_e        P_a           ''                Calc_ARS            ; ...
    Accuracy     ''         ''            ''                Calc_dir            ; ...
    Accuracy*P_f P_e/P_f    P_a/P_f       ''                Calc/length(beta)   };

set(uit,'Data',data);
set(ax,'XLim',[min(gx(:)) max(gx(:))],'YLim',[min(gy(:)) max(gy(:))]);

set(axARS,'Position',get(ax,'Position'));

drawnow;