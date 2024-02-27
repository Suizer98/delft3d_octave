function mu = norm_getmu(P,X,sigma)
%norm_getmu  Calculates mu
%
%   Calculates the average of the normal distribution based on the given 
%   standard deviation and probability of non-exceedance of one x-value
%
%   Syntax:
%   varargout = Untitled(varargin)
%
%   Input: For <keyword,value> pairs call Untitled() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   Untitled
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 <COMPANY>
%       hengst
%
%       <EMAIL>
%
%       <ADDRESS>
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
% Created: 15 Aug 2013
% Created with Matlab version: 7.14.0.739 (R2012a)

% $Id: norm_getmu.m 9053 2013-08-15 08:59:54Z hengst $
% $Date: 2013-08-15 16:59:54 +0800 (Thu, 15 Aug 2013) $
% $Author: hengst $
% $Revision: 9053 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/distributions/norm_getmu.m $
% $Keywords: $

%% code

mu = -(erfinv(2*P-1)*sqrt(2*sigma^2)-X);
