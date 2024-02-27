function XB_Animate_Results(XB, vars, along, varargin)
%XB_ANIMATE_RESULTS  Animates time dependent results from a XBeach result structure
%
%   Animates selected variables from a XBeach result structure in time
%   along either the x-axis, y-axis or coastline.
%
%   Syntax:
%   XB_Animate_Results(XB, vars, along, varargin)
%
%   Input:
%   XB          = XBeach result structure
%   vars        = cell with variables to be animated
%   along       = horizontal axis (x, y or coastline)
%   varargin    = key/value pairs of optional parameters
%                 fh            = figure handle (default: [])
%                 tstart        = time step to start animation (default: 1)
%                 title         = title of figure (default: XBeach output
%                                 plot)
%                 size          = size of figure (default: [800 600])
%                 grid          = flag to enable grid (default: true)
%                 showEnevelope = flag to enable envelope of values plotted
%                                 (default: true)
%                 showAverage   = flag to enable average of values plotted
%                                 (default: true)
%
%   Output: no output
%
%   Example
%   XB_Animate_Results(XB, vars, along)
%
%   See also XB_Read_Results, XB_Plot_Results, XB_Read_Coastline

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       Bas Hoonhout
%
%       bas@hoonhout.com
%
%       Stevinweg 1
%       2628CN Delft
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

% This tool is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 2 Dec 2009
% Created with Matlab version: 7.5.0.338 (R2007b)

% $Id: XB_Animate_Results.m 3489 2010-12-02 13:36:58Z heijer $
% $Date: 2010-12-02 21:36:58 +0800 (Thu, 02 Dec 2010) $
% $Author: heijer $
% $Revision: 3489 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/.old/XB_Animate_Results.m $
% $Keywords: $

%% settings

OPT = struct( ...
    'fh', [], ...
    'pos', 0, ...
    'tstart', 1, ...
    'title', 'XBeach output plot', ...
    'size', [800 600], ...
    'grid', true, ...
    'showEnvelope', true, ...
    'showAverage', true ...
);

OPT = setproperty(OPT, varargin{:});

% make sure variable is a cell structure
if ~iscell(vars); vars = {vars}; end;

if ndims(XB.Output.zb) < 3; error('No 3D XBeach result struct given'); end;

%% initialization

% create figure
if isempty(OPT.fh)
    fig = figure();
else
    fig = OPT.fh;
end
    
% set figure size
pos = get(fig, 'Position'); pos(3:4) = OPT.size;
set(fig, 'Position', pos);

% calculate number of subplots
wPlots = ceil(sqrt(length(vars)));
hPlots = ceil(length(vars)/wPlots);

% create subplots
hSP_cur = [];
hSP_max = [];
hSP_min = [];
hSP_avg = [];

plotMax = [];
plotMin = [];
plotAvg = [];
plotAxes = [];

for i = 1:length(vars)
    hSP(i) = subplot(wPlots, hPlots, i);
    
    hSP_cur(i) = plot([0], [0], '-b'); hold on;
    if OPT.showEnvelope; hSP_max(i) = plot([0], [0], '-r'); end;
    if OPT.showEnvelope; hSP_min(i) = plot([0], [0], '-r'); end;
    if OPT.showAverage; hSP_avg(i) = plot([0], [0], '-g'); end;
    
    if OPT.grid; set(hSP(i), 'XGrid', 'on', 'YGrid', 'on'); end;

    % prepare envelope and average plots
    switch along
        case 'x'
            plotMax(i,:) = -Inf.*ones(1, size(XB.Output.zb, 1));
            plotMin(i,:) = Inf.*ones(1, size(XB.Output.zb, 1));
            plotAvg(i,:) = zeros(1, size(XB.Output.zb, 1));
            plotAxes(i,:) = [min(min(min(XB.Output.x))) max(max(max(XB.Output.x))) ...
                min(min(min(XB.Output.(vars{i})))) max(max(max(XB.Output.(vars{i}))))];
        otherwise
            plotMax(i,:) = -Inf.*ones(1, size(XB.Output.zb, 2));
            plotMin(i,:) = Inf.*ones(1, size(XB.Output.zb, 2));
            plotAvg(i,:) = zeros(1, size(XB.Output.zb, 2));
            plotAxes(i,:) = [min(min(min(XB.Output.y))) max(max(max(XB.Output.y))) ...
                min(min(min(XB.Output.(vars{i})))) max(max(max(XB.Output.(vars{i}))))];
    end
end

%% animate data

% loop through time steps
for t = OPT.tstart:size(XB.Output.zb, 3)

    % loop through variables to animate
    for i = 1:length(vars)
        var = vars{i};
        
        yVar = XB.Output.(var);
    
        switch along
            case 'x'
                plotX = XB.Output.x(:,OPT.pos);
                plotY = yVar(:,OPT.pos,t);
            case 'y'
                plotX = XB.Output.y(OPT.pos,:);
                plotY = yVar(OPT.pos,:,t)';
            case 'coastline'
                [x y ix iy] = XB_Read_Coastline(XB, OPT.pos, 't', t);
                
                plotX = y;
                plotY = [];
                for j = 1:length(x)
                    plotY(j,:) = yVar(ix(j), iy(j), t);
                end
        end
        
        plotMax(i,:) = max(plotY', plotMax(i,:));
        plotMin(i,:) = min(plotY', plotMin(i,:));
        plotAvg(i,:) = (plotAvg(i,:).*(t-1)+plotY')/t;

        set(hSP_cur(i), 'XData', plotX);
        set(hSP_cur(i), 'YData', plotY);
        
        if OPT.showEnvelope
            set(hSP_max(i), 'XData', plotX);
            set(hSP_max(i), 'YData', plotMax(i,:));
            set(hSP_min(i), 'XData', plotX);
            set(hSP_min(i), 'YData', plotMin(i,:));
        end
        
        if OPT.showAverage
            set(hSP_avg(i), 'XData', plotX);
            set(hSP_avg(i), 'YData', plotAvg(i,:));
        end
        
        title(hSP(i), {[OPT.title] ['Variable: ' var ' ; Timestep: ' num2str(t)]});
        xlabel(hSP(i), along); ylabel(hSP(i), var);
    
        axis(hSP(i), plotAxes(i,:));
    end

    drawnow

    pause(0.1);
end