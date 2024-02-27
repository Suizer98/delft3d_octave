function handles = ddb_DFlowFM_plotBathymetry(handles, opt, varargin)
%DDB_DFlowFM_PLOTGRID  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_DFlowFM_plotGrid(handles, opt, varargin)
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
%   ddb_DFlowFM_plotGrid
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

% $Id: ddb_DFlowFM_plotGrid.m 13494 2017-07-27 12:08:29Z ormondt $
% $Date: 2017-07-27 14:08:29 +0200 (Thu, 27 Jul 2017) $
% $Author: ormondt $
% $Revision: 13494 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/models/DFlowFM/plot/ddb_DFlowFM_plotGrid.m $
% $Keywords: $

%%

col=[0.35 0.35 0.35];
vis=1;
id=ad;
iactive=0;

for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'visible'}
                vis=varargin{i+1};
            case{'domain'}
                id=varargin{i+1};
            case{'active'}
                iactive=varargin{i+1};
        end
    end
end

vis=vis*handles.model.dflowfm.menuview.bathymetry;

switch lower(opt)
    
    case{'plot'}
        
        % First delete old grid
        if isfield(handles.model.dflowfm.domain(id).bathymetry,'handle')
            if ~isempty(handles.model.dflowfm.domain(id).bathymetry.handle)
                try
                    delete(handles.model.dflowfm.domain(id).bathymetry.handle);
                end
            end
        end
        node=handles.model.dflowfm.domain(id).netstruc.node;
        h=fastscatter(node.mesh2d_node_x,node.mesh2d_node_y,node.mesh2d_node_z);

        clims=get(gca,'CLim');
        zmin=clims(1);
        zmax=clims(2);
        colormap(ddb_getColors(handles.mapData.colorMaps.earth,64)*255);
        caxis([zmin zmax]);
        
        handles.model.dflowfm.domain(id).bathymetry.handle=h;
        set(h,'Tag','dflowfmbathymetry');
        set(h,'HitTest','off');

        if vis
            set(h,'Visible','on');
        else
            set(h,'Visible','off');
        end
                
    case{'delete'}
        
        % Delete old grid
        if isfield(handles.model.dflowfm.domain(id).bathymetry,'handle')
            if ~isempty(handles.model.dflowfm.domain(id).bathymetry.handle)
                try
                    delete(handles.model.dflowfm.domain(id).bathymetry.handle);
                end
            end
        end
        
        if id==0
            h=findobj(gcf,'Tag','dflowfmbathymetry');
            if ~isempty(h)
                delete(h);
            end
        end
        
    case{'update'}
        if isfield(handles.model.dflowfm.domain(id).bathymetry,'handle')
            if ~isempty(handles.model.dflowfm.domain(id).bathymetry.handle)
                try
                    set(handles.model.dflowfm.domain(id).bathymetry.handle,'HitTest','off');
                    if vis
                        set(handles.model.dflowfm.domain(id).bathymetry.handle,'Visible','on');
                    else
                        set(handles.model.dflowfm.domain(id).bathymetry.handle,'Visible','off');
                    end
                end
            end
        end
end

