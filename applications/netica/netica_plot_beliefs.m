function varargout = netica_plot_beliefs(filename, node, varargin)
%NETICA_PLOT_BELIEFS  Plot belief bars from a Netica Bayesian Network.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = netica_plot_beliefs(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   netica_plot_beliefs
%
%   See also netica

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Delft University of Technology
%       Kees den Heijer
%
%       C.denHeijer@TUDelft.nl
%
%       Faculty of Civil Engineering and Geosciences
%       P.O. Box 5048
%       2600 GA Delft
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
% Created: 13 Jun 2012
% Created with Matlab version: 7.12.0.635 (R2011a)

% $Id: netica_plot_beliefs.m 6897 2012-07-11 14:39:30Z boer_g $
% $Date: 2012-07-11 22:39:30 +0800 (Wed, 11 Jul 2012) $
% $Author: boer_g $
% $Revision: 6897 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/netica/netica_plot_beliefs.m $
% $Keywords: $

%%
OPT = struct(...
    'netica_password', '',...
    'color', struct('apriori', [0 166 214]/255, 'aposteriori', [166 0 88]/255, 'selected', [173 198 16]/255),...
    'alpha', struct('apriori', .1, 'aposteriori', .4, 'selected', .6),...
    'format', '%g',...
    'figure', @figure,...
    'axes', @gca);

OPT = setproperty(OPT, varargin);

%%
import norsys.netica.*;
env = Environ.getDefaultEnviron;
env = Environ(OPT.netica_password);
stream = Streamer(filename);
net = Net(stream);
net.compile();
nodes = net.getNodes;

if isnumeric(node)
    nnodes = nodes.size();
    if round(node) == node && node >= 0 && node < nnodes
        nodeid = node;
        nodename = char(nodes.getNode(nodeid).getLabel);
    else
        net.finalize();
        env.finalize();
        error('node should be integer between 0 and %i', nnodes-1)
    end
elseif ischar(node)
    names = cellfun(@(x) char(nodes.getNode(x).getLabel), num2cell((1:nodes.size())-1), 'uniformoutput', false);
    nodename = node;
    nodeid = find(strcmp(nodename, names)) - 1;
end

if ~isempty(nodeid)
    beliefs(:,2) = nodes.getNode(nodeid).getBeliefs;
    net.retractFindings()
    beliefs(:,1) = nodes.getNode(nodeid).getBeliefs;
    levels = nodes.getNode(nodeid).getLevels;
    if all(diff(beliefs, 1, 2) == 0)
        beliefs = beliefs(:,1);
    end
else
    error('node "%s" invalid', nodename)
end

net.finalize();
env.finalize();

infids = abs(levels) > 1e308;
if any(infids)
    levels(infids) = sign(levels(infids)) * inf;
end
% x = 0.5:length(levels)-1;
% yticklabel = cellfun(@(x,y) sprintf([OPT.format ' to ' OPT.format], x, y), num2cell(levels(1:end-1)), num2cell(levels(2:end)), 'uniformoutput', false);
x = 0:length(levels)-1;
yticklabel = cellfun(@(x) sprintf(OPT.format, x), num2cell(levels), 'uniformoutput', false);

try
    fh = feval(OPT.figure);
catch
    fh = OPT.figure;
end

try
    ah = feval(OPT.axes);
catch
    ah = OPT.axes;
end

ph = barh(...
    x(1:end-1)+.5, beliefs(:,1),...
    'parent', ah,...
    'edgecolor', 'none',...
    'facecolor', OPT.color.apriori);
if size(beliefs,2) == 2
    hold on
    ph(end+1) = barh(...
        x(1:end-1)+.5, beliefs(:,2),...
        'parent', ah,...
        'edgecolor', 'none',...
        'facecolor', OPT.color.aposteriori);
    set(cell2mat(get(ph, 'children')),...
        {'facealpha'}, {OPT.alpha.apriori; OPT.alpha.aposteriori})
%     set(ph(1), 'facecolor', [.5 .5 .5])
    if any(beliefs(:,2) == 1)
        set(ph(2), 'facecolor', OPT.color.selected)
        set(get(ph(2), 'children'),...
            'facealpha', OPT.alpha.selected);
    end
end


title(nodename);
set(ah,...
    'ydir', 'reverse',...
    'ytick', x,...
    'yticklabel', yticklabel,...
    'xlim', [0 min([max(beliefs(:))*1.5 1])],...
    'ylim', [0 length(levels)-1])
% alternatively remove ticks and add ticklabels as text
% set(gca, 'ydir', 'reverse', 'ytick', []);
% cellfun(@(y, txt) text(0,y,txt,'horizontalalignment', 'right', 'verticalalignment', 'middle'), num2cell(x), yticklabel)

varargout = {ph ah fh nodename};