function X = unif_inv(P, a, b)
%UNIF_INV  inverse of the uniform cumulative distribution function (cdf)
%
%   This function returns the inverse of the cdf of the uniform
%   distribution, evaluated at the values in P.
%
%   Syntax:
%   X = unif_inv(P, a, b)
%
%   Input:
%   P = cdf
%   a = lower limit
%   b = upper limit
%
%   Output:
%   X = variable values
%
%   Example
%   unif_inv
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

% Created: 16 Mar 2009
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id: unif_inv.m 2074 2009-12-17 17:13:32Z heijer $
% $Date: 2009-12-18 01:13:32 +0800 (Fri, 18 Dec 2009) $
% $Author: heijer $
% $Revision: 2074 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/distributions/unif_inv.m $
% $Keywords:

%%
if nargin == 1
    a = 0;
    b = 1;
end

X = nan(size(P));

k = ~(a >= b | P < 0 | P > 1);
if any(k)
    X(k) = a + P(k) .* (b - a);
end