function x = exp_inv(P, lambda, epsilon)
%EXP_INV  inverse of the exponential cumulative distribution function (cdf)
%
%   This function returns the inverse cdf of the exponential distribution,
%   evaluated at the values in P.
%
%   Syntax:
%   x = exp_inv(P, lambda, epsilon)
%
%   Input:
%   x       = variable values
%
%   Output:
%   P       = cdf
%   lambda  = rate parameter
%   epsilon = offset
%
%   Example
%   exp_inv
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

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 03 Sep 2009
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id: exp_inv.m 2074 2009-12-17 17:13:32Z heijer $
% $Date: 2009-12-18 01:13:32 +0800 (Fri, 18 Dec 2009) $
% $Author: heijer $
% $Revision: 2074 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/distributions/exp_inv.m $
% $Keywords: $

%%
P(P < 0 | 1 < P) = NaN;
x = -1/lambda.*log(1-P) + epsilon;                
