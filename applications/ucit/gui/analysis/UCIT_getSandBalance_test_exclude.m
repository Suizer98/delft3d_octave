function UCIT_getSandBalance_test()
% UCIT_GETSANDBALANCE_TEST  Test for ucit_getsandbalance
%  
% This function tests UCIT_getSandBalance.
%
%
%   See also UCIT_getSandBalance

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Pieter van Geer
%
%       pieter.vangeer@deltares.nl	
%
%       Rotterdamseweg 185
%       2629 HD Delft
%       P.O. 177
%       2600 MH Delft
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
% Created: 22 Jun 2010
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id: UCIT_getSandBalance_test_exclude.m 4099 2011-02-24 12:57:05Z sonnevi $
% $Date: 2011-02-24 20:57:05 +0800 (Thu, 24 Feb 2011) $
% $Author: sonnevi $
% $Revision: 4099 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ucit/gui/analysis/UCIT_getSandBalance_test_exclude.m $
% $Keywords: $

TeamCity.category('UnCategorized');

% OPT.polygon = [110408.287818882,543577.467188487;104543.995635158,545097.839236119;105955.769679388,552373.905464074;111059.875839296,552265.307460671;110408.287818882,543577.467188487;]

%% then run sand balance
OPT.datatype        = 'vaklodingen';
OPT.thinning        = 1;
OPT.timewindow      = 24;
OPT.inputyears      = [1925:2007];
OPT.min_coverage    = 50;

UCIT_getSandBalance(OPT)