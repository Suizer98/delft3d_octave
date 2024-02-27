function ddb_plotTropicalCyclone(option, varargin)
%DDB_PLOTTROPICALCYCLONE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_plotTropicalCyclone(option, varargin)
%
%   Input:
%   option   =
%   varargin =
%
%
%
%
%   Example
%   ddb_plotTropicalCyclone
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

% $Id: ddb_plotTropicalCyclone.m 12609 2016-03-17 13:34:40Z ormondt $
% $Date: 2016-03-17 21:34:40 +0800 (Thu, 17 Mar 2016) $
% $Author: ormondt $
% $Revision: 12609 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/TropicalCyclone/ddb_plotTropicalCyclone.m $
% $Keywords: $

%%
switch lower(option)
    case{'delete'}
        h=findobj(gca,'Tag','cyclonetrack');
        if ~isempty(h)
            delete(h);
        end
        h=findobj(gca,'Tag','rawensemble');
        if ~isempty(h)
            delete(h);
        end
        h=findobj(gca,'Tag','finalensemble');
        if ~isempty(h)
            delete(h);
        end
    case{'activate'}
        h=findobj(gca,'Tag','cyclonetrack');
        if ~isempty(h)
            set(h,'Visible','on');
            try
            uistack(h,'Top');
            end
        end
        h=findobj(gca,'Tag','rawensemble');
        if ~isempty(h)
            set(h,'Visible','on');
        end
        h=findobj(gca,'Tag','finalensemble');
        if ~isempty(h)
            set(h,'Visible','on');
        end
    case{'deactivate'}
        h=findobj(gca,'Tag','cyclonetrack');
        if ~isempty(h)
            set(h,'Visible','off');
        end
        h=findobj(gca,'Tag','rawensemble');
        if ~isempty(h)
            set(h,'Visible','off');
        end
        h=findobj(gca,'Tag','finalensemble');
        if ~isempty(h)
            set(h,'Visible','off');
        end
end


