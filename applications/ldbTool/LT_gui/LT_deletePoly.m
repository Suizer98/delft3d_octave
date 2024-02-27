function LT_deletePoly
%LT_DELETEPOLY ldbTool GUI function to delete the selection polygon
%
% See also: LDBTOOL

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Arjan Mol
%
%       arjan.mol@deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 17 Aug 2012
% Created with Matlab version: 7.14.0.739 (R2012a)

% $Id: LT_deletePoly.m 7149 2012-08-17 09:54:13Z bartgrasmeijer.x $
% $Date: 2012-08-17 17:54:13 +0800 (Fri, 17 Aug 2012) $
% $Author: bartgrasmeijer.x $
% $Revision: 7149 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ldbTool/LT_gui/LT_deletePoly.m $
% $Keywords: $

%% Code
[but,fig]=gcbo;

data=get(fig,'userdata');
data(1,5).ldb=[nan nan];
set(fig,'userdata',data);
LT_plotLdb;
