function result = prob_chain(chain, varargin)
%PROB_CHAIN  Executes a chain of probabilistic computations
%
%   Executes a chain of probabilistic computations defined by a chain
%   structure (see exampleChainVar). The probabilistic computations can
%   either be a FORM or a Monte Carlo routine. Linker function link the
%   results of one computation to the input of another. The result is a
%   cell array with for each computation an output structure.
%
%   Syntax:
%   result = prob_chain(chain, varargin)
%
%   Input:
%   chain     = Chain definition structure
%   varargin  = none
%
%   Output:
%   result    = Cell array with output structures
%
%   Example
%   result = prob_chain(chain)
%
%   See also prob_chain_link, exampleChainVar, FORM, MC

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

% $Id: prob_chain.m 4595 2011-05-24 15:37:45Z hoonhout $
% $Date: 2011-05-24 23:37:45 +0800 (Tue, 24 May 2011) $
% $Author: hoonhout $
% $Revision: 4595 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/chain/prob_chain.m $
% $Keywords: $

%% read options

OPT = struct( ...
);

OPT = setproperty(OPT, varargin{:});

%% execute chain

last_chain      = struct();
last_output     = struct();
result          = {};

for i = 1:length(chain)
    
    try
        if isa(chain(i).Link, 'function_handle')
            chain(i)    = feval(chain(i).Link, chain(i), last_chain, last_output, chain(i).LinkParams{:});
        end

        if isa(chain(i).Method, 'function_handle')
            result{i}   = feval(chain(i).Method, 'stochast', chain(i).Stochast, chain(i).Params{:});
            last_output = result{i};
        end

        last_chain  = chain(i);
    catch err
        warning('Chain link #%d failed, skipping to next link [%s]', i, err.message);
    end
    
end
