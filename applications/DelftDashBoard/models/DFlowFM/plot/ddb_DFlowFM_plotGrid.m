function handles = ddb_DFlowFM_plotGrid(handles, opt, varargin)
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

% $Id: ddb_DFlowFM_plotGrid.m 15813 2019-10-04 06:15:03Z ormondt $
% $Date: 2019-10-04 14:15:03 +0800 (Fri, 04 Oct 2019) $
% $Author: ormondt $
% $Revision: 15813 $
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
            case{'color'}
                col=varargin{i+1};
            case{'visible'}
                vis=varargin{i+1};
            case{'domain'}
                id=varargin{i+1};
            case{'active'}
                iactive=varargin{i+1};
        end
    end
end

vis=vis*handles.model.dflowfm.menuview.grid;

switch lower(opt)
    
    case{'plot'}
        
        % First delete old grid
        if isfield(handles.model.dflowfm.domain(id).grid,'handle')
            if ~isempty(handles.model.dflowfm.domain(id).grid.handle)
                try
                    delete(handles.model.dflowfm.domain(id).grid.handle);
                end
            end
        end
        
        h=pltnet(handles.model.dflowfm.domain(id).netstruc);
%         p=dflowfm.plotNet(handles.model.dflowfm.domain(id).netstruc,'cor',[],'cen',[]);
%         handles.model.dflowfm.domain(id).grid.handle=p.per;
        handles.model.dflowfm.domain(id).grid.handle=h;
        set(h,'Tag','dflowfmnet');
        set(h,'HitTest','off');

        if vis
            set(h,'Color',col,'Visible','on');
        else
            set(h,'Color',col,'Visible','off');
        end
                
    case{'delete'}
        
        % Delete old grid
        if isfield(handles.model.dflowfm.domain(id).grid,'handle')
            if ~isempty(handles.model.dflowfm.domain(id).grid.handle)
                try
                    delete(handles.model.dflowfm.domain(id).grid.handle);
                end
            end
        end
        
        if id==0
            h=findobj(gcf,'Tag','dflowfmnet');
            if ~isempty(h)
                delete(h);
            end
        end
        
    case{'update'}
        if isfield(handles.model.dflowfm.domain(id).grid,'handle')
            if ~isempty(handles.model.dflowfm.domain(id).grid.handle)
                try
                    set(handles.model.dflowfm.domain(id).grid.handle,'HitTest','off');
                    set(handles.model.dflowfm.domain(id).grid.handle,'Color',col);
                    if vis
                        set(handles.model.dflowfm.domain(id).grid.handle,'Color',col,'Visible','on');
                    else
                        set(handles.model.dflowfm.domain(id).grid.handle,'Color',col,'Visible','off');
                    end
                end
            end
        end
end

