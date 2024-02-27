function result = MCEstimator(gx, P_corr, Confidence)
% MCEstimator  computes Monte Carlo estimator and convidence intervals
%
%   This routine derives the Monte Carlo estimator of:
%
%           int(f(x)g(x)dx)
%
% in which x is a vector of random variables, f(x) is the pdf and g(x) can
% be any function of x. In case of reliability analysis, g(x)=1 if x is in
% the failure area and g(x)=0 otherwise. gx can also be the damage, or profit as
% a function of x. The actual sampling procedure is executed
% elsewhere (e.g. with module mc.m). The modules takes into account that
% importance sampling has been applied.
%
%   the module derives the variance of all N samples of Pi. Pi is the value of the
%   the Monte Carlo estimator.
%
%   Syntax:
%   result = MC(stochast)
%   result = MC(..
%       'stochast', stochast,...
%       'NrSamples', 1000);
%
%   Input:
%   gx:         function g(x)
%   P_corr:     Corrections for importance sampling: f(x)/h(x)
%   Confidence: confidence interval (in case of 95%, put 0.95)
%
%   Output:
%   result = structure with results:
%       Pi:              % individual values of the MC estimator
%       P_f:             % resulting end value of the MC estimator
%       P_z:             % evolution of the MC estimator
%       Acy_abs:         % absolute error in P_f (with certainty related to confidence interval)
%       Acy_absV:        % evolution of 'Acy_abs'
%       Acy_rel:         % Acy_rel
%
%   Example
%   result = MCEstimator(gx, P_corr, Confidence)
%   See also MC
%
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
%       ferdinand Diermanse
%
%       ferdinand.diermanse@deltares.nl
%
%       Faculty of Civil Engineering and Geosciences
%       P.O. Box 5048
%       2600 GA Delft
%       The Netherlands
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% Created: 06 sept 2012
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id: MCEstimator.m 8052 2013-02-09 16:53:08Z dierman $
% $Date: 2013-02-10 00:53:08 +0800 (Sun, 10 Feb 2013) $
% $Author: dierman $
% $Revision: 8052 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/engines/MonteCarlo/MCEstimator.m $

%% derive MC estimator
N = length(P_corr);                           % number of samples
cumNsamps = repmat((1:N)', 1, size(gx,2));    % numbers 1:n in 1 vector (or matrix)
Pi = gx .* repmat(P_corr, 1, size(gx,2));     % individual values of the MC estimator
P_z = cumsum(Pi)./cumNsamps;                  % evolution of the MC estimator
P_f = P_z(end,:);                             % resulting end value of the MC estimator

%% compute accurracy of estimate
kk=norm_inv((Confidence+1)/2,0,1);       % k-value for desired confidence interval
diff = Pi - P_z;                         % deviation of individual estimators from mean
Variance = cumsum(diff.^2)./(cumNsamps.^2); % variance
Id1 = find(abs(Pi)>0, 1, 'first');        % first 'failure'
Variance(1:Id1-1) = NaN;                  % no valid variance estimate until at least 1 non-zero is sampled

Sigma = sqrt(Variance);    % standard deviation
Acy_absV = Sigma*kk;       % limit of the absolute error in P_f (with certainty related to kk)
Acy_abs = Acy_absV(end,:); % last value of the absoluut error
Acy_rel =Acy_abs./P_f;     % relative error

% store results in strcuture
result = struct(...
    'Pi',           Pi,   ...           % individual values of the MC estimator
    'P_f',          P_f,       ...      % resulting end value of the MC estimator
    'P_z',          P_z,       ...      % evolution of the MC estimator
    'Sigma',        Sigma,     ...      % evolution of the standard deviation of the error
    'Acy_abs',      Acy_abs,    ...     % absolute error in P_f (with certainty related to confidence interval)
    'Acy_absV',     Acy_absV,   ...     % evolution of 'Acy_abs'
    'Acy_rel',      Acy_rel     ...     % Acy_rel
    );