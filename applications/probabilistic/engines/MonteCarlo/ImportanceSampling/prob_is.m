function [P P_corr] = prob_is(stochast, IS, P)
%PROB_IS  Performs importance sampling on one or more stochasts
%
%   Performs importance sampling on one or more stochasts using a stochast
%   and importance sampling structure and a set of random draws.
%
%   Syntax:
%   [P P_corr] = prob_is(stochast, sampling, P)
%
%   Input:
%   sampling  = Importance sampling structure array
%   P         = Matrix with random draws for each stochast
%
%   Output:
%   P         = Modified matrix with random draws
%   P_corr    = Correction factor for probability of failure computation
%
%   Example
%   [P P_corr] = prob_is(stochast, sampling, P)
%
%   See also MC, prob_is_factor, prob_is_uniform, prob_is_incvariance,
%            prob_is_exponential

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
% Created: 19 May 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: prob_is.m 4748 2011-07-04 13:28:31Z hoonhout $
% $Date: 2011-07-04 21:28:31 +0800 (Mon, 04 Jul 2011) $
% $Author: hoonhout $
% $Revision: 4748 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/engines/MonteCarlo/ImportanceSampling/prob_is.m $
% $Keywords: $

%% call sampling routines

P_corr = ones(size(P));

if ~isempty(IS) && ~isempty(fieldnames(IS))
    for i = 1:length(stochast)
        idx = strcmpi(stochast(i).Name, {IS.Name});
        if any(idx)
            if isa(IS(idx).Method,'function_handle')

                params = IS(idx).Params;
                
                if ~iscell(params); params = {params}; end;
                
                for j = 1:length(params)
                    if iscell(params{j})
                        if ~isempty(params{j})
                            if isa(params{j}{1}, 'function_handle')
                                params{j} = feval(params{j}{:});
                            end
                        end
                    end
                end
                
                [P(:,i) P_corr(:,i)] = feval(   ...
                    IS(idx).Method,             ...
                    P(:,i),                     ...
                    params{:}                       );

            end
        end
    end
end

P_corr = prod(P_corr,2);
