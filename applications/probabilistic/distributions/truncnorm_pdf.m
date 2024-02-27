function P = truncnorm_pdf(X, mu, sigma, LowLim, UppLim)
%TRUNCNORM_pdf  pdf of the normal cumulative distribution function
%with fixed upper and lower limits
%
%
% input
%    - X:      X-values
%    - mu:     mean of the Gaussion distribution function
%    - sigma:  standard deviation of the Gaussion distribution function
%    - LowLim, UppLim: upper and lower limit of truncated normal
% output
%    - P:      array of probabilty densities 
%
%   Example
%   truncnorm_pdf
%
%   See also

%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares 
%       F.L.M. Diermanse
%
%       Fedrinand.diermanse@Deltares.nl	
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

% Created: 29 Nov 2012
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id: truncnorm_pdf.m 8551 2013-05-01 08:16:11Z dierman $
% $Date: 2013-05-01 16:16:11 +0800 (Wed, 01 May 2013) $
% $Author: dierman $
% $Revision: 8551 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/distributions/truncnorm_pdf.m $

%% checks
if LowLim>UppLim
   error('lower limit should be <= upper limit'); 
end
if ~((isscalar(LowLim) || isequal(size(LowLim),size(mu))) && (isscalar(UppLim) || isequal(size(UppLim),size(mu))))
   error('limits of truncated normal should be scalars or size of mu and sigma');
end

%% deal probabilities of non-exceedance for upper and lower limits
PL = norm_cdf(LowLim, mu, sigma);
PU = norm_cdf(UppLim, mu, sigma);

% call pdf of the normal distribution function
P1 = norm_pdf(X, mu, sigma);  % Normally distributed value(s) with mean "mu" and standard deviation "sigma"  

% transform P, taking upper and lower limit into account
P = P1./(PU-PL);
P(X<LowLim)=0;
P(X>UppLim)=0;

