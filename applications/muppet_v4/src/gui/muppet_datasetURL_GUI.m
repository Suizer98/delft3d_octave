function handles = muppet_datasetURL_GUI(handles, varargin)
%MUPPET_DATASETURL_GUI  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = muppet_datasetURL_GUI(varargin)
%
%   Input: For <keyword,value> pairs call muppet_datasetURL_GUI() without arguments.
%   varargin  =
%
%   Output:
%   handles =
%
%   Example
%   muppet_datasetURL_GUI
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
%       Kees den Heijer
%
%       Kees.denHeijer@Deltares.nl
%
%       Deltares
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
% Created: 01 Feb 2013
% Created with Matlab version: 8.0.0.783 (R2012b)

% $Id: muppet_datasetURL_GUI.m 9307 2013-10-01 12:32:10Z heijer $
% $Date: 2013-10-01 20:32:10 +0800 (Tue, 01 Oct 2013) $
% $Author: heijer $
% $Revision: 9307 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/muppet_v4/src/gui/muppet_datasetURL_GUI.m $
% $Keywords: $

%%
s = struct();
[s, ok] = gui_newWindow(s, 'xmldir', handles.xmlguidir, 'xmlfile', 'newurldataset.xml','iconfile',[handles.settingsdir 'icons' filesep 'deltares.gif']);

iscatalog = ~isempty(regexpi(s.url, 'catalog.nc$', 'once'));

if iscatalog
    urlPath = cellstr(nc_varget(s.url, 'urlPath'));
    % check whether urlPath is correct (sometimes cropped to 64 characters, possibly leading to all identical urls)
    if isequal(size(unique(urlPath)), size(urlPath))
        urls = urlPath;
        x_ranges = nc_varget(s.url, 'projectionCoverage_x');
        y_ranges = nc_varget(s.url, 'projectionCoverage_y');
    else
        [urls, x_ranges, y_ranges] = grid_orth_getMapInfoFromDataset(s.url(1:end-10));
    end
else
    [urls, x_ranges, y_ranges] = grid_orth_getMapInfoFromDataset(s.url);
end

pg = landboundary('read', s.polygonfile);

[X, Y, Z, Ztime, OPT] = grid_orth_getDataInPolygon(...
    'polygon', pg,...
    'urls', urls,...
    'x_ranges', x_ranges,...
    'y_ranges', y_ranges);

