function [S]=skewness2(X)
% skewness2 - computes skewness of a distribution
%   [S]=skewness2(X) computes row-wise skewness
% The unbiased Fisher's skewness for finite samples, a.k.a. G1, is used.
%   skewness = n/(n-1)/(n-2) * sum( ((X-mean)/std)^3 ) 
% Note: 
%   Positive skewness reflects an asymmetrical distribution with tail in positive values.
%   Standard Error of skewness for normal distribution is: SES ~ sqrt(6/n)
%   i.e. if abs(skew) > 2*SES, your data are significantly skewed (2 is the
%   T value à.05)
%   
%   See also kurtosis2

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2018 Deltares
%       grasmeij
%
%       bart.grasmeijer@deltares.nl
%
%       P.O.Box 177
%       2600 MH Delft, The Netherlands
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
% Created: 23 May 2018
% Created with Matlab version: 9.3.0.713579 (R2017b)

% $Id: skewness2.m 14368 2018-05-23 13:28:53Z bartgrasmeijer.x $
% $Date: 2018-05-23 21:28:53 +0800 (Wed, 23 May 2018) $
% $Author: bartgrasmeijer.x $
% $Revision: 14368 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/stat_fun/skewness2.m $
% $Keywords: skewness$

if isvector(X)
    X=X(:);
end
sz=[size(X) 1 ];
n=sz(1);
if n<3
    error('Skewness needs sample of size > 2')
end
S=sum((X-repmat(mean(X),n,1)).^3);
S=S./(var(X).^1.5);
S=S.*(n/(n-1)/(n-2));
