function handles = ddb_loadTsunamiTableFile(handles, filename)
%DDB_loadTsunamiTableFile  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_loadTsunamiTableFile(handles, filename)
%
%   Input:
%   handles  =
%   filename =
%
%   Output:
%   handles  =
%
%   Example
%   ddb_loadTsunamiTableFile
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
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

% $Id: ddb_loadTsunamiTableFile.m 16900 2020-12-09 10:58:54Z ormondt $
% $Date: 2020-12-09 18:58:54 +0800 (Wed, 09 Dec 2020) $
% $Author: ormondt $
% $Revision: 16900 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/Tsunami/ddb_loadTsunamiTableFile.m $
% $Keywords: $

%%
xml=xml2struct(filename,'structuretype','supershort');
handles.toolbox.tsunami.segmentLon=str2num(xml.longitude);
handles.toolbox.tsunami.segmentLat=str2num(xml.latitude);
handles.toolbox.tsunami.segmentStrike=str2num(xml.strike);
% handles.toolbox.tsunami.segmentLength=str2num(xml.length);
handles.toolbox.tsunami.segmentWidth=str2num(xml.width);
handles.toolbox.tsunami.segmentDepth=str2num(xml.depth);
handles.toolbox.tsunami.segmentDip=str2num(xml.dip);
handles.toolbox.tsunami.segmentSlipRake=str2num(xml.sliprake);
handles.toolbox.tsunami.segmentSlip=str2num(xml.slip);
try
    handles.toolbox.tsunami.EQtype=str2num(xml.eqtype);
catch
    handles.toolbox.tsunami.EQtype = 3;
end
