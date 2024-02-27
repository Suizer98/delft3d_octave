function Zeta = logn_moments2zeta(Mu, Sigma)
%LOGN_MOMENTS2ZETA  transform lognormal parameters Mu/Sigma to Zeta
%
%   More detailed description goes here.
%
%   Syntax:
%   Zeta = logn_moments2zeta(Mu, Sigma)
%
%   Input:
%   Mu    =
%   Sigma =
%
%   Output:
%   Zeta  =
%
%   Example
%   logn_moments2zeta
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

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 16 Sep 2009
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id: logn_moments2zeta.m 9334 2013-10-04 12:06:26Z heijer $
% $Date: 2013-10-04 20:06:26 +0800 (Fri, 04 Oct 2013) $
% $Author: heijer $
% $Revision: 9334 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/distributions/logn_moments2zeta.m $
% $Keywords: $

%%
Zeta = sqrt(log(1+(Sigma./Mu).^2));