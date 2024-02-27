function [P P_corr] = prob_is_uniform(P, varargin)
%PROB_IS_UNIFORM  Importance sampling method based on uniform distribution
%
%   Importance sampling method based on uniform distribution.
%
%   Syntax:
%   [P P_corr] = prob_is_uniform(P, varargin)
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
%   [P P_corr] = prob_is_uniform(P, f1, f2)
%
%   See also prob_is, prob_is_factor, prob_is_incvariance,
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

% $Id: prob_is_uniform.m 7716 2012-11-22 13:24:29Z heijer $
% $Date: 2012-11-22 21:24:29 +0800 (Thu, 22 Nov 2012) $
% $Author: heijer $
% $Revision: 7716 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/engines/MonteCarlo/ImportanceSampling/prob_is_uniform.m $
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

% convert P to u, between boundaries f1 and f2 (actually u1, u2)
u       = f1+P*diff([f1 f2]);
% since u is standard normally distributed, convert u back to uniformly
% distributed P with norm_cdf
P       = norm_cdf(u,0,1);

%% correction factor

P_corr  = diff([f1 f2])*norm_pdf(u,0,1);
