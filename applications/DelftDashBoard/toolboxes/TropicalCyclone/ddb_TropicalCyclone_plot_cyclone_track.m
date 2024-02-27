function ddb_TropicalCyclone_plot_cyclone_track
%ddb_TropicalCyclone_plot_cyclone_track  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_TropicalCyclone_plot_cyclone_track
%
%   Input:

%
%
%
%
%   Example
%   ddb_TropicalCyclone_plot_cyclone_track
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

% $Id: ddb_TropicalCyclone_plot_cyclone_track.m 10436 2014-03-24 22:26:17Z ormondt $
% $Date: 2014-03-24 23:26:17 +0100 (Mon, 24 Mar 2014) $
% $Author: ormondt $
% $Revision: 10436 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/TropicalCyclone/ddb_TropicalCyclone_plot_cyclone_track.m $
% $Keywords: $

%%
handles=getHandles;

for it=1:handles.toolbox.tropicalcyclone.nrTrackPoints
    txt{it}=datestr(handles.toolbox.tropicalcyclone.track.time(it),'dd-mmm-yyyy HH:MM');
end

handles.toolbox.tropicalcyclone.trackhandle=gui_polyline('plot','tag','cyclonetrack','marker','o', ...
    'changecallback',@ddb_TropicalCyclone_change_cyclone_track,'rightclickcallback',@ddb_selectCyclonePoint, ...
    'closed',0,'x',handles.toolbox.tropicalcyclone.track.x,'y',handles.toolbox.tropicalcyclone.track.y,'text',txt);
%    'closed',0,'x',handles.toolbox.tropicalcyclone.track.x,'y',handles.toolbox.tropicalcyclone.track.y,'text',txt,'type','spline','dxspline',5000);

setHandles(handles);
