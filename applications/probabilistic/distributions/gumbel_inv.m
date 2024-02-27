function X = gumbel_inv(P, mu, sigma)
%GUMBEL_INV  Inverse of the gumbel cumulative distribution function.
%
%   This routine retruns the inverse cdf for the gumbel (type 1) extreme
%   value distribution with location parameter "mu" and scale parameter
%   "sigma", evaluated at the values in P.  The size of X is the common size
%   of the input arguments.  A scalar input functions as a constant matrix
%   of the same size as the other inputs.
%   
%   Default values for "mu" and "sigma" are 0 and 1, respectively.
%
%   Syntax:
%   X = gumbel_inv(P, mu, sigma)
%
%   Input:
%   P     = cdf
%   mu    = location parameter
%   sigma = scale parameter
%
%   Output:
%   x     = variable values
%
%   Example
%   gumbel_inv
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Delft University of Technology
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 07 Apr 2010
% Created with Matlab version: 7.7.0.471 (R2008b)

% $Id: gumbel_inv.m 2418 2010-04-07 07:37:18Z heijer $
% $Date: 2010-04-07 15:37:18 +0800 (Wed, 07 Apr 2010) $
% $Author: heijer $
% $Revision: 2418 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/distributions/gumbel_inv.m $
% $Keywords: $

%%
if nargin<1
    error('Input argument P is undefined.');
end
if nargin < 2
    mu = 0;
end
if nargin < 3
    sigma = 1;
end

%%
id = 0 <= P & P < 1 & ~isnan(P);

q = NaN(size(P));
q(id) = log(-log(1-P(id)));

% Return NaN for out of range parameters.
sigma(sigma <= 0) = NaN;

try
    X = sigma .* q + mu;
catch
    error('Non-scalar arguments must match in size.');
end