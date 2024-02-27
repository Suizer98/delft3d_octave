function [p,plo,pup] = exp_cdf(x,mu,pcov,alpha)
%EXP_CDF Exponential cumulative distribution function.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = exp_cdf(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   exp_cdf
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl	
%
%       Rotterdamseweg 185
%       2629HD Delft
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
% Created: 19 May 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: exp_cdf.m 4584 2011-05-23 10:13:14Z hoonhout $
% $Date: 2011-05-23 18:13:14 +0800 (Mon, 23 May 2011) $
% $Author: hoonhout $
% $Revision: 4584 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/distributions/exp_cdf.m $
% $Keywords: $

%%

if nargin<1
    error('stats:expcdf:TooFewInputs','Input argument X is undefined.');
end
if nargin < 2
    mu = 1;
end

% More checking if we need to compute confidence bounds.
if nargout>1
   if nargin<3
      error('stats:expcdf:TooFewInputs',...
            'Must provide parameter variance to compute confidence bounds.');
   end
   if numel(pcov)~=1
      error('stats:expcdf:BadVariance','Variance must be a scalar.');
   end
   if nargin<4
      alpha = 0.05;
   elseif ~isnumeric(alpha) || numel(alpha)~=1 || alpha<=0 || alpha>=1
      error('stats:expcdf:BadAlpha',...
            'ALPHA must be a scalar between 0 and 1.');
   end
end

% Return NaN for out of range parameters.
mu(mu <= 0) = NaN;

try
    z = x./mu;
catch
    error('stats:expcdf:InputSizeMismatch',...
          'Non-scalar arguments must match in size.');
end
p = 1 - exp(-z);

% Force a zero for negative x.
p(z < 0) = 0;

% Compute confidence bounds if requested.
if nargout>=2
   % Work on log scale.
   logz = log(z);
   if pcov<0
      error('stats:expcdf:BadVariance','PCOV must be non-negative.');
   end
   normz = -norminv(alpha/2);
   halfwidth = normz * sqrt(pcov ./ (mu.^2));
   zlo = logz - halfwidth;
   zup = logz + halfwidth;
   
   % Convert back to original scale
   plo = 1 - exp(-exp(zlo));
   pup = 1 - exp(-exp(zup));
end
