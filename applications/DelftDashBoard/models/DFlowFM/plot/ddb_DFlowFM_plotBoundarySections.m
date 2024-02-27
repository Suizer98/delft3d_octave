function handles = ddb_DFlowFM_plotBoundaries(handles, opt, varargin)
%DDB_DFlowFM_plotBoundarySections  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_DFlowFM_plotBoundarySections(handles, opt, varargin)
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
%   ddb_DFlowFM_plotGridop
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

% $Id: ddb_DFlowFM_plotBoundarySections.m 10447 2014-03-26 07:06:47Z ormondt $
% $Date: 2014-03-26 15:06:47 +0800 (Wed, 26 Mar 2014) $
% $Author: ormondt $
% $Revision: 10447 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/models/DFlowFM/plot/ddb_DFlowFM_plotBoundarySections.m $
% $Keywords: $

%%

col=[0 0 1];
vis=1;
id=ad;

for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'color'}
                col=varargin{i+1};
            case{'visible'}
                vis=varargin{i+1};
            case{'domain'}
                id=varargin{i+1};
        end
    end
end

switch lower(opt)
    
    case{'plot'}
        
        % First delete old sections
        try
            delete(handles.model.dflowfm.domain(id).plotHandles.boundarySections);
        end
                
        for isec=1:length(handles.model.dflowfm.domain(id).boundarySections)
            xx=handles.model.dflowfm.domain(id).boundarySections(isec).x;
            yy=handles.model.dflowfm.domain(id).boundarySections(isec).y;
            p=plot(xx,yy,'o-');
            set(p,'Color',[0 0 1]);
            set(p,'LineWidth',2);
            set(p,'MarkerEdgeColor',[0 0 0]);
            set(p,'MarkerFaceColor',[1 0 0]);
            handles.model.dflowfm.domain(id).plotHandles.boundarySections(isec)=p;
        end
        
        if vis
            set(handles.model.dflowfm.domain(id).plotHandles.boundarySections,'Color',col,'Visible','on');
        else
            set(handles.model.dflowfm.domain(id).plotHandles.boundarySections,'Color',col,'Visible','off');
        end
        
    case{'delete'}
        
        % Delete old grid
        try
            delete(handles.model.dflowfm.domain(id).plotHandles.boundarySections);
        end
        
    case{'update'}
        if isfield(handles.model.dflowfm.domain(id).plotHandles,'boundarySections')
            if ~isempty(handles.model.dflowfm.domain(id).plotHandles.boundarySections)
                try
                    set(handles.model.dflowfm.domain(id).plotHandles.boundarySections,'Color',col);
                    if vis
                        set(handles.model.dflowfm.domain(id).plotHandles.boundarySections,'Color',col,'Visible','on');
                    else
                        set(handles.model.dflowfm.domain(id).plotHandles.boundarySections,'Color',col,'Visible','off');
                    end
                end
            end
        end
end

