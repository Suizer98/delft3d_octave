function x = conditionalWeibull_inv(P, omega, rho, alpha, sigma, lambda)
%CONDITIONALWEIBULL  inverse of the conditional weibull cumulative density function
%
%   This function returns the inverse cdf of the conditional weibull
%   distribution, evaluated at the values in P.
%
%   Syntax:
%   x = conditionalWeibull(P, omega, rho, alpha, sigma)
%
%   Input:
%   varargin  =
%
%   Output:
%   x =
%
%   Example
%   conditionalWeibull
%
%   See also

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

% Created: 06 Feb 2009
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id: conditionalWeibull_inv.m 8131 2013-02-19 08:47:00Z heijer $
% $Date: 2013-02-19 16:47:00 +0800 (Tue, 19 Feb 2013) $
% $Author: heijer $
% $Revision: 8131 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/distributions/conditionalWeibull_inv.m $

%%
if length(omega) == 2 && lambda ~= 1
    % in case of interpolation between 2 reference points: get x values of
    % reference point 2
    x2 = conditionalWeibull_inv(P, omega(2), rho(2), alpha(2), sigma(2));
end
    
% transform P (probability of non-exceedance) to Fe (frequency of
% exceedance)
Fe = -log(P);

% get the x, using Fe(P) and the coefficients
x = sigma(1).*(log(rho(1)) + (omega(1)./sigma(1)).^alpha(1) - log(Fe)).^(1./alpha(1));
if ~isreal(x)
    x = real(x);
end

if length(omega) == 2 && lambda ~= 1
    % interpolate between reference points based on lambda value
    x = [x x2 lambda*x + (1-lambda)*x2];
end