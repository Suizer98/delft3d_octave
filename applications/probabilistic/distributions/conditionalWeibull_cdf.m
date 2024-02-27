function P = conditionalWeibull_cdf(x, omega, rho, alpha, sigma, lambda)
%CONDITIONALWEIBULL_CDF  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = conditionalWeibull_cdf(varargin)
%
%   Input: For <keyword,value> pairs call conditionalWeibull_cdf() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   conditionalWeibull_cdf
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
%       hengst
%
%       Simon.denHengst@deltares.nl	
%
%       Deltares
%       P.O. Box 177 
%       2600 MH Delft 
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 19 Feb 2013
% Created with Matlab version: 7.14.0.739 (R2012a)

% $Id: conditionalWeibull_cdf.m 8161 2013-02-22 15:26:11Z hengst $
% $Date: 2013-02-22 23:26:11 +0800 (Fri, 22 Feb 2013) $
% $Author: hengst $
% $Revision: 8161 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/distributions/conditionalWeibull_cdf.m $
% $Keywords: $

%% code

if length(omega) > 1 && lambda ~= 1
    error('interpolation between multiple stations not included in this distribution');
end
     
% get the x, using Fe(P) and the coefficients
Fe = rho(1).*exp(-(x./sigma(1)).^alpha(1)+(omega(1)./sigma(1)).^alpha(1)); 

% transform Fe (frequency of exceedance) to P (probability of non-exceedance)
P = exp(-Fe);

