function ddb_plotNavigationCharts(option, varargin)
%DDB_PLOTNAVIGATIONCHARTS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_plotNavigationCharts(option, varargin)
%
%   Input:
%   option   =
%   varargin =
%
%
%
%
%   Example
%   ddb_plotNavigationCharts
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

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
switch lower(option)
    case{'delete'}
        h=findobj(gca,'Tag','BBoxENC');
        if ~isempty(h)
            delete(h);
        end
        h=findobj(gca,'Tag','NavigationChartLayer');
        if ~isempty(h)
            delete(h);
        end
        h=findobj(gca,'Tag','navigationchartspolygon');
        if ~isempty(h)
            delete(h);
        end
        
    case{'activate'}
        
        handles=getHandles;
        
        h=findobj(gca,'Tag','BBoxENC');
        if ~isempty(h)
            set(h,'Visible','on');
            set(h,'HandleVisibility','on');
        end
        
        h=findobj(gca,'Tag','NavigationChartLayer','UserData','LNDARE');
        if ~isempty(h)
            set(h,'HandleVisibility','on');
            if handles.toolbox.navigationcharts.showShoreline
                set(h,'Visible','on');
            else
                set(h,'Visible','off');
            end
        end
        
        h=findobj(gca,'Tag','NavigationChartLayer','UserData','SOUNDG');
        set(h,'HandleVisibility','on');
        if ~isempty(h)
            if handles.Toolbox(ii)Input.showSoundings
                set(h,'Visible','on');
            else
                set(h,'Visible','off');
            end
        end
        
        h=findobj(gca,'Tag','NavigationChartLayer','UserData','DEPCNT');
        set(h,'HandleVisibility','on');
        if ~isempty(h)
            if handles.toolbox.navigationcharts.showContours
                set(h,'Visible','on');
            else
                set(h,'Visible','off');
            end
        end

        h=findobj(gca,'Tag','navigationchartspolygon');
        if ~isempty(h)
            set(h,'Visible','on');
            set(h,'HandleVisibility','on');
        end
    
    case{'deactivate'}
        h=findobj(gca,'Tag','BBoxENC');
        if ~isempty(h)
            set(h,'Visible','off');
%            set(h,'HandleVisibility','off');
        end
        h=findobj(gca,'Tag','NavigationChartLayer');
        if ~isempty(h)
            set(h,'Visible','off');
%            set(h,'HandleVisibility','off');
        end
        h=findobj(gca,'Tag','navigationchartspolygon');
        if ~isempty(h)
            set(h,'Visible','off');
%            set(h,'HandleVisibility','off');
        end
end




