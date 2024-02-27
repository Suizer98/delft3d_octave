function [P P_corr] = prob_is_exponential(P, varargin)
%PROB_IS_EXPONENTIAL  Importance sampling method based on exponential distribution
%
%   Importance sampling method based on exponential distribution.
%
%   Syntax:
%   [P P_corr] = prob_is_exponential(P, varargin)
%
%   Input:
%   P         = Vector with random draws for importance sampling stochast
%   varargin  = #1: lower boundary of u-values
%               #2: upper boundary of u-values
%
%   Output:
%   P         = Modified vector with random draws
%   P_corr    = Correction factor for probability of failure computation
%
%   Example
%   [P P_corr] = prob_is_exponential(P, f)
%
%   See also prob_is, prob_is_factor, prob_is_uniform, prob_is_incvariance

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

% $Id: prob_is_exponential.m 4587 2011-05-23 16:13:21Z hoonhout $
% $Date: 2011-05-24 00:13:21 +0800 (Tue, 24 May 2011) $
% $Author: hoonhout $
% $Revision: 4587 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/engines/MonteCarlo/ImportanceSampling/prob_is_exponential.m $
% $Keywords: $

%% read options

if ~isempty(varargin) && length(varargin)>1
    f1 = min([varargin{1:2}]);
    f2 = max([varargin{1:2}]);
else
    f1 = 0;
    f2 = Inf;
end

%% importance sampling

u       = P*diff([f1 f2]);
P       = exp_cdf(u, 1);

%% correction factor

P_corr  = diff([f1 f2])*exp(-u);