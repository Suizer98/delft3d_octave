function X = norm_inv(P, mu, sigma)
%NORM_INV  inverse of the normal cumulative distribution function (cdf)
%
% The inverse of the Gaussian (normal) distribution function with mean "mu"
% and standard deviation "sigma"
%
% input
%    - P:      array of probabilties of non-exceedance. All elements of this array have to be between 0 and 1
%    - mu:     mean of the Gaussion distribution function
%    - sigma:  standard deviation of the Gaussion distribution function
% output
%    - X:  Normally distributed value(s) with mean "mu" and standard deviation "sigma" distributed value(s)
%
%   Example
%   norm_inv
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

% $Id: norm_inv.m 2074 2009-12-17 17:13:32Z heijer $
% $Date: 2009-12-18 01:13:32 +0800 (Fri, 18 Dec 2009) $
% $Author: heijer $
% $Revision: 2074 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/distributions/norm_inv.m $

%%
if max(P)>1 & min(P)<0 %#ok<AND2>
    error('values should be between 0 and 1')
end

X = sqrt(2) * erfinv(2*P-1);    % Standard normally distributed value(s)
X = mu + sigma .* X;            % Normally distributed value(s) with mean "mu" and standard deviation "sigma"