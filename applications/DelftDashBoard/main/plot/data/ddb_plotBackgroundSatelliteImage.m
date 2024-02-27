function handles = ddb_plotBackgroundSatelliteImage(handles, x, y, cdata)
%DDB_PLOTBACKGROUNDSATELLITEIMAGE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_plotBackgroundSatelliteImage(handles, x, y, cdata)
%
%   Input:
%   handles =
%   x       =
%   y       =
%   cdata   =
%
%   Output:
%   handles =
%
%   Example
%   ddb_plotBackgroundSatelliteImage
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

% $Id: ddb_plotBackgroundSatelliteImage.m 5539 2011-11-29 13:24:17Z boer_we $
% $Date: 2011-11-29 21:24:17 +0800 (Tue, 29 Nov 2011) $
% $Author: boer_we $
% $Revision: 5539 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/main/plot/data/ddb_plotBackgroundSatelliteImage.m $
% $Keywords: $

%%
h=handles.mapHandles.backgroundImage;
set(h,'XData',x,'YData',y,'CData',cdata);
set(handles.GUIHandles.mapAxis,'YDir','normal');

