function N = netica_get_beliefs(filename, varargin)
%NETICA_GET_BELIEFS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   N = netica_get_beliefs(filename, varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   N =
%
%   Example
%   netica_get_beliefs
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
%       Kees den Heijer
%
%       Kees.denHeijer@Deltares.nl
%
%       Deltares
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
% Created: 15 Jun 2012
% Created with Matlab version: 7.12.0.635 (R2011a)

% $Id: netica_get_beliefs.m 6713 2012-06-29 11:15:39Z heijer $
% $Date: 2012-06-29 19:15:39 +0800 (Fri, 29 Jun 2012) $
% $Author: heijer $
% $Revision: 6713 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/netica/netica_get_beliefs.m $
% $Keywords: $

%%
OPT = struct(...
    'netica_password', '',...
    'node', [] ...
    );

OPT = setproperty(OPT, varargin);

%% check whether file exists
assert(exist(filename, 'file') == 2)

import norsys.netica.*;
env = Environ.getDefaultEnviron;
env = Environ(OPT.netica_password);
try
    stream = Streamer(filename);
catch
    env.finalize()
    error
end
% open net
net = Net(stream);
% make sure the net is compiled
net.compile()

%% read node info
nodes = net.getNodes;
nodeids = (1:nodes.size())-1;
nodenames = cellfun(@(x) char(nodes.getNode(x).getLabel), num2cell(nodeids),...
    'UniformOutput', false);

if ~isempty(OPT.node)
    % make selection of nodes
    if ~iscell(OPT.node)
        OPT.node = {OPT.node};
    end
    selectids = ismember(nodeids, OPT.node{cellfun(@isnumeric, OPT.node)}) | ...
        ismember(nodenames, OPT.node(cellfun(@ischar, OPT.node)));
    [nodeids nodenames] = deal(nodeids(selectids), nodenames(selectids));
end

%% read beliefs and levels
[beliefs levels numstates] = cellfun(@(x) deal(nodes.getNode(x).getBeliefs,...
    nodes.getNode(x).getLevels,...
    nodes.getNode(x).getNumStates),...
    num2cell(nodeids), 'UniformOutput', false);

states = cell(size(numstates));
for inode = find(cellfun(@isempty, levels))
    states{inode} = cellfun(@(x) char(nodes.getNode(inode-1).state(x)),...
        num2cell((1:numstates{inode})-1), 'UniformOutput', false);
end

%% create output structure
N = struct(...
    'id', num2cell(nodeids),...
    'name', nodenames,...
    'beliefs', beliefs,...
    'levels', levels,...
    'numstates', numstates,...
    'states', states);

%% finalize net and environment
net.finalize()
env.finalize()