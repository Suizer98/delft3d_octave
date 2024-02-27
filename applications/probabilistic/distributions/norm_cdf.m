function P = norm_cdf(X, mu, sigma)
%NORM_CDF  normal cumulative distribution function (cdf)
%
% The Gaussian (normal) distribution function with mean "mu" and standard
% deviation "sigma".
%
% input
%    - X:      standard normaly distributed value(s)
%    - mu:     mean of the Gaussion distribution function
%    - sigma:  standard deviation of the Gaussion distribution function
% output
%    - P: probabilties of non-exceedance. 
%
%   Example
%   norm_cdf
%
%   See also

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       Kees den Heijer
%       adapted by Ferdinand Diermanse
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

% $Id: norm_cdf.m 8550 2013-05-01 08:00:00Z dierman $
% $Date: 2013-05-01 16:00:00 +0800 (Wed, 01 May 2013) $
% $Author: dierman $
% $Revision: 8550 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/distributions/norm_cdf.m $

%%
if sigma > 0
    X = (X-mu)./sigma;                % Standard normally distributed value(s)
elseif sigma == 0
    X = X-mu;
else
    error('sigma should be possitive')
end
P = (1 + (erf(X/sqrt(2))))./2;
P(P==1) = 1-1e-16;
