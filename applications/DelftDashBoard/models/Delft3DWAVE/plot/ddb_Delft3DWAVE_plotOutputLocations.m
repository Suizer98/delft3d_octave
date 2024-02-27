function handles = ddb_Delft3DWAVE_plotOutputLocations(handles, opt, varargin)
%ddb_Delft3DWAVE_plotOutputLocations  Plots Delft3D-WAVE output locations

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
% Created: 29 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: ddb_Delft3DWAVE_plotOutputLocations.m 10447 2014-03-26 07:06:47Z ormondt $
% $Date: 2014-03-26 15:06:47 +0800 (Wed, 26 Mar 2014) $
% $Author: ormondt $
% $Revision: 10447 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/models/Delft3DWAVE/plot/ddb_Delft3DWAVE_plotOutputLocations.m $
% $Keywords: $

%%

active=1;
vis=1;

for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'visible'}
                vis=varargin{i+1};
            case{'active'}
                active=varargin{i+1};
        end
    end
end

switch lower(opt)
    
    case{'plot'}
        
        % First delete old locations
        for ii=1:handles.model.delft3dwave.domain.nrlocationsets
            try
                h=handles.model.delft3dwave.domain.locationsets(ii).handle;
                delete(h);
            end
        end
        
        % Now plot new obstacles
        for ii=1:handles.model.delft3dwave.domain.nrlocationsets
            if handles.model.delft3dwave.domain.locationsets(ii).nrpoints>0
                x=handles.model.delft3dwave.domain.locationsets(ii).x;
                y=handles.model.delft3dwave.domain.locationsets(ii).y;
                xy=[x' y'];
                h=gui_pointcloud('plot','xy',xy,'Tag','delft3dwavelocationset','Marker','o', ...
                    'selectcallback',@ddb_Delft3DWAVE_output_locations,'selectinput','selectpointfrommap', ...
                    'marker','o','markeredgecolor','none','markerfacecolor',[0.5 0.5 0.5], ...
                    'activemarker','o','activemarkeredgecolor','none','activemarkerfacecolor',[0.5 0.5 0.5], ...
                    'activepoint',1);
                if active
                    if ii==handles.model.delft3dwave.domain.activelocationset
                        gui_pointcloud(h,'change','markeredgecolor','k','markerfacecolor','y', ...
                            'activemarkeredgecolor','k','activemarkerfacecolor','r');
                    else
                        gui_pointcloud(h,'change','markeredgecolor','k','markerfacecolor','g', ...
                            'activemarkeredgecolor','k','activemarkerfacecolor','g');
                    end
                else
                    gui_pointcloud(h,'change','markeredgecolor','none','markerfacecolor',[0.5 0.5 0.5], ...
                        'activemarkeredgecolor','none','activemarkerfacecolor',[0.5 0.5 0.5]);
                end
                handles.model.delft3dwave.domain.locationsets(ii).handle=h;
            else
                handles.model.delft3dwave.domain.locationsets(ii).handle=[];
            end
        end
        
    case{'delete'}
        
        % Delete old obstacles
        for ii=1:handles.model.delft3dwave.domain.nrlocationsets
            try
                h=handles.model.delft3dwave.domain.locationsets(ii).handle;
                if ishandle(h)
                    delete(handles.model.delft3dwave.domain.locationsets(ii).handle);
                end
            end
        end
        hh=findobj(gcf,'tag','delft3dwavelocationset');
        if ~isempty(hh)
            delete(hh);
        end
        
    case{'update'}

        try
            for ii=1:handles.model.delft3dwave.domain.nrlocationsets
                h=handles.model.delft3dwave.domain.locationsets(ii).handle;
                if ishandle(h)
                    if active
                        iac=handles.model.delft3dwave.domain.locationsets(ii).activepoint;
                        if ii==handles.model.delft3dwave.domain.activelocationset
                            gui_pointcloud(h,'change','markeredgecolor','k','markerfacecolor','y', ...
                                'activemarkeredgecolor','k','activemarkerfacecolor','r','activepoint',iac);
                        else
                            gui_pointcloud(h,'change','markeredgecolor','k','markerfacecolor','g', ...
                                'activemarkeredgecolor','k','activemarkerfacecolor','g','activepoint',iac);
                        end
                    else
                        gui_pointcloud(h,'change','markeredgecolor','none','markerfacecolor',[0.5 0.5 0.5], ...
                            'activemarkeredgecolor','none','activemarkerfacecolor',[0.5 0.5 0.5]);                        
                    end
                    if vis
                        set(h,'Visible','on');
                    else
                        set(h,'Visible','off');
                    end
                    if active
                        set(h,'HitTest','on');
                        hh=getappdata(h,'cloudhandle');
                        set(hh,'HitTest','on');
                    else
                        set(h,'HitTest','off');
                        hh=getappdata(h,'cloudhandle');
                        set(hh,'HitTest','off');
                    end
                    try
                        uistack(h,'top');
                    end

                end
            end
        end
end

