function [P P_corr] = prob_is_uniform_OLD(P, varargin)
%PROB_IS_UNIFORM_OLD  Old version of the importance sampling method based on uniform distribution
%
%   Importance sampling method based on uniform distribution. Sampling is
%   performed in x-space and all kind of hacks are included to establish
%   whatever result.
%
%   PLEASE USE PROB_IS_UNIFORM INSTEAD!
%
%   Syntax:
%   [P P_corr] = prob_is_uniform_OLD(P, varargin)
%
%   Input:
%   P         = Vector with random draws for importance sampling stochast
%   varargin  = #1: stochast structure
%               #2: lower boundary of u-values
%               #3: upper boundary of u-values
%
%   Output:
%   P         = Modified vector with random draws
%   P_corr    = Correction factor for probability of failure computation
%
%   Example
%   [P P_corr] = prob_is_uniform_OLD(P, f1, f2)
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
% Created: 25 May 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: prob_is_uniform_OLD.m 4792 2011-07-08 14:47:27Z hoonhout $
% $Date: 2011-07-08 22:47:27 +0800 (Fri, 08 Jul 2011) $
% $Author: hoonhout $
% $Revision: 4792 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/engines/MonteCarlo/ImportanceSampling/prob_is_uniform_OLD.m $
% $Keywords: $

%% read options

if ~isempty(varargin)
    stochast = varargin{1};
    if length(varargin)>2
        f1 = min([varargin{2:3}]);
        f2 = max([varargin{2:3}]);
    else
        f1 = 0;
        f2 = Inf;
    end
else
    stochast = exampleStochastVar;
end

%% importance sampling

warning('OET:probabilistic:deprecated', ['This importance sampling function (%s) '...
    'is deprecated. Please use one of the other prob_is_* functions. '...
    'This functions contains several customized hacks of which the origin '...
    'should be found in the history of Prob2B. The current purpose of these '...
    'hacks in this generic toolbox is unknown.'], mfilename);

Iplus = 1;
NaNsinP = true;

while NaNsinP
    Iplus = Iplus + 1;
    maxpgrid = -log10(f1) + Iplus;
    pgrid = (0.01:0.01:maxpgrid)';
    Ponder = unique([flipud(0.5*(10.^-pgrid)); (0.489:0.001:0.511)';  (1-0.5*10.^-pgrid)]);

    % derive probability distribution and probability density of H as
    % table
    % this distribution is needed to derive the correction coefficient
    % which essential for Importance Sampling
    cdf = feval(stochast.Distr, Ponder, stochast.Params{:});

    [xcentr dPdx] = cdf2pdf(Ponder, cdf(:,end));

    % find boundaries for sampling of the Importance Sampling variable
    Pgrens = exp(-[f2 f1]); % probability of non-exceedance boundaries
    Hgrens = feval(stochast.Distr, Pgrens', stochast.Params{:});% boundaries from CDF
    Hgrens = [0.9; 1.1].*Hgrens(:,end); % make boundaries a bit wider, because of possibly correlated other variables

    % sample Importance Sampling variable
    H = Hgrens(1) + P*(Hgrens(2)-Hgrens(1));

    P = interp1(cdf(:,end), Ponder, H);

    if all(~any(isnan(P)))
        NaNsinP = false;
    elseif all(isnan(P)) || Iplus>100
        warning('Invalid boundaries in CDF');
    end
end

%% correction factor

% correction coefficient for bias in Importance Sampling variable
P_corr = interp1(xcentr, dPdx, H);   % PDF Importance Sampling variable
P_corr = (Hgrens(2)-Hgrens(1))*P_corr;