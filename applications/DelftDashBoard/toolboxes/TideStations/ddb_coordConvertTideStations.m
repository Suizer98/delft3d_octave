function handles = ddb_coordConvertTideStations(handles)
%DDB_COORDCONVERTTIDESTATIONS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_coordConvertTideStations(handles)
%
%   Input:
%   handles =
%
%   Output:
%   handles =
%
%   Example
%   ddb_coordConvertTideStations
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
% Created: 02 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: ddb_coordConvertTideStations.m 10436 2014-03-24 22:26:17Z ormondt $
% $Date: 2014-03-25 06:26:17 +0800 (Tue, 25 Mar 2014) $
% $Author: ormondt $
% $Revision: 10436 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/TideStations/ddb_coordConvertTideStations.m $
% $Keywords: $

%%

ddb_plotTideStations('delete');
handles.toolbox.tidestations.tideStationHandle=[];
handles.toolbox.tidestations.ActiveTideStationHandle=[];

for iac=1:length(handles.toolbox.tidestations.databases)
    x=handles.toolbox.tidestations.database(iac).x;
    y=handles.toolbox.tidestations.database(iac).y;
    cs.name=handles.toolbox.tidestations.database(iac).coordinateSystem;
    cs.type=handles.toolbox.tidestations.database(iac).coordinateSystemType;
    [x,y]=ddb_coordConvert(x,y,cs,handles.screenParameters.coordinateSystem);
    handles.toolbox.tidestations.database(iac).xLoc=x;
    handles.toolbox.tidestations.database(iac).yLoc=y;
end

