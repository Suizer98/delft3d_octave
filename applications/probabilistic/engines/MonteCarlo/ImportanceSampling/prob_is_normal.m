function [P P_corr] = prob_is_normal(P, varargin)
%PROB_IS_NORMAL  Importance sampling method based on normal distribution
%
%   Importance sampling method based on normal distribution.
%
%   Syntax:
%   [P P_corr] = prob_is_uniform(P, varargin)
%
%   Input:
%   P         = Vector with random draws for importance sampling stochast
%   varargin  = #1: mean of normal distribution
%               #2: standard deviation of normal distribution
%
%   Output:
%   P         = Modified vector with random draws
%   P_corr    = Correction factor for probability of failure computation
%
%   Example
%   [P P_corr] = prob_is_uniform(P, m, s)
%
%   See also prob_is, prob_is_factor, prob_is_uniform, prob_is_incvariance,
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
% Created: 20 May 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: prob_is_normal.m 4587 2011-05-23 16:13:21Z hoonhout $
% $Date: 2011-05-24 00:13:21 +0800 (Tue, 24 May 2011) $
% $Author: hoonhout $
% $Revision: 4587 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/engines/MonteCarlo/ImportanceSampling/prob_is_normal.m $
% $Keywords: $

%% read options

if ~isempty(varargin) && length(varargin)>1
    f1 = varargin{1};
    f2 = varargin{2};
else
    f1 = 0;
    f2 = Inf;
end

%% importance sampling

u       = norm_inv(P,f1,f2);
P       = norm_cdf(u,0,1);

%% correction factor

P_corr  = norm_pdf(u,0,1)./norm_pdf(u,f1,f2);
