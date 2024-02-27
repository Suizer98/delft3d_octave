function [P P_corr] = prob_is_discrete(P, varargin)
%PROB_IS_DISCRETE  Importance sampling method based on discrete functions
%
%   Importance sampling method based on discrete functions
%
%   Syntax:
%   [P P_corr] = prob_is_discrete(P, varargin)
%
%   Input:
%   P         = Vector with random draws for importance sampling stochast
%   varargin  = #1: XP table of real distribution function
%               #2: XP table of importance sampling distribution function
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
%   Copyright (C) 2013 Deltares
%       Ferdinand Diermanse
%
%       Ferdinand.Diermanse@deltares.nl	
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

% $Id: prob_is_discrete.m 7973 2013-01-29 21:30:27Z dierman $
% $Date: 2013-01-30 05:30:27 +0800 (Wed, 30 Jan 2013) $
% $Author: dierman $
% $Revision: 7973 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/engines/MonteCarlo/ImportanceSampling/prob_is_discrete.m $
% $Keywords: $

%% read options

XP1 = varargin{1};
XP2 = varargin{2};

%% importance sampling
X  =  Hist_inv(P, XP2);
P =  Hist_cdf(X, XP1);  % new probability of non-exceedance

%% correction factor
P1 =  Hist_pdf(X, XP1);  % prob. of occurrence according to original distribution
P2 =  Hist_pdf(X, XP2);  % prob. of occurrence according to IS distribution
P_corr = P1./P2;         % ratio
