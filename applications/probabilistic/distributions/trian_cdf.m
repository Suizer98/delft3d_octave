function P = trian_cdf(x, a, b, c)
%TRIAN_CDF  triangular cumulative distribution function (cdf)
%
%   This function returns the cdf of the triangular distribution function,
%   evaluated at the values in x.
%
%   Syntax:
%   P = trian_cdf(x, a, b, c)
%
%   Input:
%   x = variable value
%   a = lower limit of x
%   b = upper limit of x
%   c = mode of x
%
%   Output:
%   P = probability
%
%   Example
%   trian_cdf
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

% $Id: trian_cdf.m 2073 2009-12-17 16:34:35Z heijer $
% $Date: 2009-12-18 00:34:35 +0800 (Fri, 18 Dec 2009) $
% $Author: heijer $
% $Revision: 2073 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/distributions/trian_cdf.m $
% $Keywords: $

%% check input
if ~(a <= c && b >= c)
    error('TRIAN_CDF:inputchk', 'Distribution parameters are non-consistent, it should be like: a <= c <= b')
end

%%
% pre-allocate P
P = zeros(size(x));
% set P values at x > b to 1
P(x > b) = 1;

% calculate lower tail P values
lowerx = x > a & x <= c;
P(lowerx) = (x(lowerx) - a).^2 / (b-a) / (c-a);

% calculate upper tail P values
upperx = x > c & x <= b;
P(upperx) = 1 - (b - x(upperx)).^2 / (b-a) / (b-c);