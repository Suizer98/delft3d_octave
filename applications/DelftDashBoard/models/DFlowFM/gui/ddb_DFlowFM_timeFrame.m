function ddb_DFlowFM_timeFrame(varargin)
%DDB_DFlowFM_TIMEFRAME  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_DFlowFM_timeFrame(varargin)
%
%   Input:
%   varargin =
%
%
%
%
%   Example
%   ddb_DFlowFM_timeFrame
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
%
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
% Created: 29 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: ddb_DFlowFM_timeFrame.m 9264 2013-09-24 11:36:17Z ormondt $
% $Date: 2013-09-24 19:36:17 +0800 (Tue, 24 Sep 2013) $
% $Author: ormondt $
% $Revision: 9264 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/models/DFlowFM/gui/ddb_DFlowFM_timeFrame.m $
% $Keywords: $

%%
ddb_zoomOff;

if isempty(varargin)
    ddb_refreshScreen;
end

