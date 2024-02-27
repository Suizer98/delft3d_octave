function handles = ddb_Delft3DWAVE_plotObstacles(handles, opt, varargin)
%DDB_DELFT3DFLOW_PLOTGRID  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_Delft3DFLOW_plotGrid(handles, opt, varargin)
%
%   Input:
%   handles  =
%   opt      =
%   varargin =
%
%   Output:
%   handles  =
%
%   Example
%   ddb_Delft3DFLOW_plotGrid
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

% $Id: ddb_Delft3DWAVE_plotObstacles.m 10447 2014-03-26 07:06:47Z ormondt $
% $Date: 2014-03-26 15:06:47 +0800 (Wed, 26 Mar 2014) $
% $Author: ormondt $
% $Revision: 10447 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/models/Delft3DWAVE/plot/ddb_Delft3DWAVE_plotObstacles.m $
% $Keywords: $

%%

active=1;
vis=1;

for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'color'}
                col=varargin{i+1};
            case{'visible'}
                vis=varargin{i+1};
            case{'active'}
                active=varargin{i+1};
        end
    end
end

switch lower(opt)
    
    case{'plot'}
        
        % First delete old obstacles
        for ii=1:handles.model.delft3dwave.domain.nrobstacles
            try
                h=handles.model.delft3dwave.domain.obstacles(ii).handle;
                delete(h);
            end
        end
        
        % Now plot new obstacles
        for ii=1:handles.model.delft3dwave.domain.nrobstacles
            x=handles.model.delft3dwave.domain.obstacles(ii).x;
            y=handles.model.delft3dwave.domain.obstacles(ii).y;
            h=gui_polyline('plot','x',x,'y',y,'Tag','delft3dwaveobstacle','Marker','o', ...
                'changecallback',@ddb_Delft3DWAVE_obstacles,'changeinput','changeobstacle','closed',0, ...
                'color','g','markeredgecolor','g','markerfacecolor','g');
            if active && ii==handles.model.delft3dwave.domain.activeobstacle
                gui_polyline(h,'change','color','r','markeredgecolor','r','markerfacecolor','r');        
            end
            handles.model.delft3dwave.domain.obstacles(ii).handle=h;
        end
        
    case{'delete'}
        
        % Delete old obstacles
        for ii=1:handles.model.delft3dwave.domain.nrobstacles
            try
                h=handles.model.delft3dwave.domain.obstacles(ii).handle;
                if ishandle(h)
                    delete(handles.model.delft3dwave.domain.obstacles(ii).handle);
                end
            end
        end
        hh=findobj(gcf,'tag','delft3dwaveobstacle');
        if ~isempty(hh)
            delete(hh);
        end
        
    case{'update'}

        try
            for ii=1:handles.model.delft3dwave.domain.nrobstacles
                h=handles.model.delft3dwave.domain.obstacles(ii).handle;
                if ishandle(h)
                    if ii==handles.model.delft3dwave.domain.activeobstacle && active
                        gui_polyline(h,'change','color','r','markeredgecolor','r','markerfacecolor','r');
                    else
                        gui_polyline(h,'change','color','g','markeredgecolor','g','markerfacecolor','g');
                    end
                    if vis
                        set(h,'Visible','on');
                    else
                        set(h,'Visible','off');
                    end
                    mh=getappdata(h,'markerhandles');
                    if active
                        set(mh,'HitTest','on');
                    else
                        set(mh,'HitTest','off');
                    end
                    try
                        uistack(h,'top');
                    end

                end
            end
        end
end

