function x = bino_inv(P, p_success)
%BINO_INV  inverse of the binominal cumulative distribution function (cdf)
%
%   This routine returns the inverse cdf for the binominal distribution,
%   evaluated at the values in P.
%
%   Syntax:
%   x = bino_inv(P, p_success)
%
%   Input:
%   P         = probability array (between 0 and 1)
%   p_success = probability of success
%
%   Output:
%   x         = logical with same size as P
%
%   Example
%   bino_inv
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

% $Id: bino_inv.m 2072 2009-12-17 16:19:05Z heijer $
% $Date: 2009-12-18 00:19:05 +0800 (Fri, 18 Dec 2009) $
% $Author: heijer $
% $Revision: 2072 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/distributions/bino_inv.m $
% $Keywords: $

%%
x = false(size(P));

x(P <= p_success) = true;