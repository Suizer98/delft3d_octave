function position = ddb_dnami_getPlotPosition(location)
%DDB_DNAMI_GETPLOTPOSITION  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   position = ddb_dnami_getPlotPosition(location)
%
%   Input:
%   location =
%
%   Output:
%   position =
%
%   Example
%   ddb_dnami_getPlotPosition
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

% $Id: ddb_dnami_getPlotPosition.m 10889 2014-06-25 08:09:38Z boer_we $
% $Date: 2014-06-25 16:09:38 +0800 (Wed, 25 Jun 2014) $
% $Author: boer_we $
% $Revision: 10889 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/Tsunami/dnami/ddb_dnami_getPlotPosition.m $
% $Keywords: $

%%
switch location
    %                 x          y      width     height
    case 'UL' % Upper left
        position = [0.00    0.60    0.56    0.47];
    case 'UR' % Upper right
        position = [0.45    0.60    0.56    0.47];
    case 'LL' % Lower left
        position = [0.00    0.04    0.56    0.47];
    case 'LR' % Lower right
        position = [0.45    0.04    0.56    0.47];
end

