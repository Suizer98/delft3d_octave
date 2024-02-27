function x = trian_inv(P, a, b, c)
%TRIAN_INV  inverse of the triangular cumulative distribution function (cdf)
%
%   This function returns the inverse cdf of the triangular distribution,
%   evaluated at the values in P.
%
%   Syntax:
%   x = trian_inv(P, a, b, c)
%
%   Input:
%   P = probability
%   a = lower limit of x
%   b = upper limit of x
%   c = mode of x
%
%   Output:
%   x = parameter value
%
%   Example
%   trian_inv
%
%   See also 

%% Copyright notice
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 17 Dec 2009
% Created with Matlab version: 7.7.0.471 (R2008b)

% $Id: trian_inv.m 2108 2009-12-21 15:56:55Z heijer $
% $Date: 2009-12-21 23:56:55 +0800 (Mon, 21 Dec 2009) $
% $Author: heijer $
% $Revision: 2108 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/distributions/trian_inv.m $
% $Keywords: $

%% check input
if ~(a <= c && b >= c)
    error('TRIAN_INV:inputchk', 'Distribution parameters are non-consistent, it should be like: a <= c <= b')
end

%%
% pre-allocate x
x = NaN(size(P));

% calculate x based on lower tail relation
x1 = sqrt(P * (b-a) * (c-a)) + a;
x(x1 <= c) = x1(x1 <= c);

% calculate x based on upper tail relation
x2 = b - sqrt((-P + 1) * (b-a) * (b-c));
x(x2 > c) = x2(x2 > c);