function X = logn_inv(P, mu, sigma, varargin)
%LOGN_INV  inverse of the lognormal cumulative distribution function (cdf)
%
%   This function returns the inverse cdf of the lognormal distribution,
%   evaluated at the values in P. The last optional argument 
%
%   Syntax:
%   X = logn_inv(P, mu, sigma)
%
%   Input:
%   P     = cdf
%   mu    = mean value
%   sigma = standard deviation
%   varargin may contain an optional location parameter to shift the distribution
%
%   Output:
%   X     = variable values
%
%   Example
%   logn_inv
%
%   See also logn_moments2lambda logn_moments2zeta

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       Kees den Heijer
%
%       C.denHeijer@TUDelft.nl	
%
%       Faculty of Civil Engineering and Geosciences
%       P.O. Box 5048
%       2600 GA Delft
%       The Netherlands
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

% Created: 25 May 2009
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id: logn_inv.m 10443 2014-03-25 13:55:58Z heijer $
% $Date: 2014-03-25 21:55:58 +0800 (Tue, 25 Mar 2014) $
% $Author: heijer $
% $Revision: 10443 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/distributions/logn_inv.m $
% $Keywords: $

%% Code

% Assign a value to the location parameter xloc, the variable which shifts the distribution
if isempty(varargin)
    x_loc = 0;
else
    x_loc = cell2mat(varargin(1));
end

% Return NaN for out of range parameters or probabilities.
sigma(sigma <= 0) = NaN;
P(P < 0 | 1 < P) = NaN;

% Apply lognormal distribution
logx0 = -sqrt(2).*erfcinv(2*P);
X = exp(sigma.*logx0 + mu) + x_loc;
