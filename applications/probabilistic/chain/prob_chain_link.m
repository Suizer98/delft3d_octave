function chain = prob_chain_link(chain, last_chain, last_output, varargin)
%PROB_CHAIN_LINK  Links the result of a probabilistic computation to the input of another
%
%   Links the result of a probabilistic computation in a probabilistic
%   computational chain to the input of another computation in the same
%   chain. Linking is based on the design point which is read from a FORM
%   result and approximated from a Monte Carlo result.
%
%   A FORM computation is started in the last known (approximated) design
%   point. A Monte Carlo computation is started using normally distributed
%   importance sampling around the last known (approximated) design point
%   and with a given standard deviation in u-space.
%
%   Syntax:
%   chain = prob_chain_link(chain, last_chain, last_output, varargin)
%
%   Input:
%   chain       = Item from a probabilistic computational chain to be
%                 executed next
%   last_chain  = Item from a probabilistic computational chain last
%                 executed
%   last_output = Output from the last executed item from a probabilistic
%                 computational chain
%   varargin    = sigma:    standard deviation to use in Monte Carlo linker
%
%   Output:
%   chain       = Chain item adapted to results of last computation
%
%   Example
%   chain = prob_chain_link(chain, last_chain, last_output)
%   chain = prob_chain_link(chain, last_chain, last_output, 'sigma', .1)
%
%   See also prob_chain, exampleChainVar, FORM, MC

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl
%
%       Rotterdamseweg 185
%       2629HD Delft
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

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 23 May 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: prob_chain_link.m 5102 2011-08-23 07:23:17Z hoonhout $
% $Date: 2011-08-23 15:23:17 +0800 (Tue, 23 Aug 2011) $
% $Author: hoonhout $
% $Revision: 5102 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/chain/prob_chain_link.m $
% $Keywords: $

%% read options

OPT = struct(   ...
    'sigma', 1  ...
);

OPT = setproperty(OPT, varargin{:});

%% analyze last output

if ~isstruct(last_output) || isempty(last_output) || isempty(fieldnames(last_output)); return; end;
if ~isstruct(last_chain)  || isempty(last_chain)  || isempty(fieldnames(last_chain));  return; end;
if ~isstruct(chain)       || isempty(chain)       || isempty(fieldnames(chain));       return; end;

%% estimate design point

switch func2str(last_chain.Method)
    case 'FORM'
        DP = last_output.Output.designpoint.finalU;
    case 'MC'
        last_output = approxMCDesignPoint(last_output, 'method', 'COG');
        DP = last_output.Output.designPoint.u;
end

%% link chain

% switch methods
switch func2str(chain.Method)
    case 'FORM'
        chain.Params = set_optval('startU',DP,chain.Params{:});
    case 'MC'

        % determine active stochasts
        active = find(~cellfun(@isempty, {chain.Stochast.Distr}) &     ...
            ~strcmp('deterministic', cellfun(@func2str, {chain.Stochast.Distr}, 'UniformOutput', false)));

        if any(active)
            IS = exampleISVar;

            n = 1;
            for i = active
                IS(n)           = exampleISVar;
                IS(n).Name      = chain.Stochast(i).Name;
                IS(n).Method    = @prob_is_normal;
                IS(n).Params    = {DP(i) OPT.sigma};

                n = n + 1;
            end

            chain.Params = set_optval('IS',IS,chain.Params{:});
        end
end