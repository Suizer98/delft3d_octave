function [P P_corr] = prob_is_incvariance(P, varargin)
%PROB_IS_INCVARIANCE  Importance sampling method based on increased variance
%
%   Importance sampling method based on increased variance.
%
%   Syntax:
%   [P P_corr] = prob_is_incvariance(P, varargin)
%
%   Input:
%   P         = Vector with random draws for importance sampling stochast
%   varargin  = Standard deviation multiplication factor
%
%   Output:
%   P         = Modified vector with random draws
%   P_corr    = Correction factor for probability of failure computation
%
%   Example
%   [P P_corr] = prob_is_incvariance(P, a)
%
%   See also prob_is, prob_is_factor, prob_is_uniform, prob_is_exponential

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

% $Id: prob_is_incvariance.m 4584 2011-05-23 10:13:14Z hoonhout $
% $Date: 2011-05-23 18:13:14 +0800 (Mon, 23 May 2011) $
% $Author: hoonhout $
% $Revision: 4584 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/engines/MonteCarlo/ImportanceSampling/prob_is_incvariance.m $
% $Keywords: $

%% read options

if ~isempty(varargin)
    a = varargin{1};
else
    a = 1;
end

%% importance sampling

u1      = norm_inv(P,0,1);
u       = a*u1;
P       = norm_cdf(u,0,1);

%% correction factor

P_corr  = a*exp(-0.5*(u.^2-u1.^2));
