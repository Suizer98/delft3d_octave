function x = logistic_inv(P, a, b)
%LOGISTIC_INV  inverse of the triangular cumulative distribution function (cdf)
%
%   This function returns the inverse cdf of the logistic distribution,
%   evaluated at the values in P.
%
%   Syntax:
%   x = logistic_inv(P, a, b)
%
%   Input:
%   P = probability
%   a = location parameter
%   b = scale parameter
%
%
%   Output:
%   x = parameter value
%
%   Example
%   logistic_inv
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Delft University of Technology
%       Vaia Tsimopoulou
%
%       vanatsimop@gmail.com	
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
% Created: 29 Jul 2010
% Created with Matlab version: 7.5.0.342 (R2007b)

% $Id: logistic_inv.m 2898 2010-07-30 08:31:10Z heijer $
% $Date: 2010-07-30 16:31:10 +0800 (Fri, 30 Jul 2010) $
% $Author: heijer $
% $Revision: 2898 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/distributions/logistic_inv.m $
% $Keywords: $

%% check input
if b <= 0
    error('LOGISTIC_INV:inputchk', 'Distribution parameter b invalid, it should be like: b>0')
end

%%
if max(P)>1 && min(P)<0
    error('values should be between 0 and 1')
end

%%

x = a - b * log(1 / P);    % Logistic distributed value(s)
