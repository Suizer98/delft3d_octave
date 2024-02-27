function handles = ddb_DFlowFM_plotBoundaries(handles, opt, varargin)
%ddb_DFlowFM_plotBoundaries  One line description goes here.

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

% $Id: ddb_DFlowFM_plotBoundaries.m 9233 2013-09-19 09:19:19Z ormondt $
% $Date: 2013-09-19 11:19:19 +0200 (Thu, 19 Sep 2013) $
% $Author: ormondt $
% $Revision: 9233 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/models/DFlowFM/plot/ddb_DFlowFM_plotBoundaries.m $
% $Keywords: $

%%

vis=1;
id=ad;
iactive=1;

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

if iactive
    linecolor='g';
    markercolor='r';
else
    linecolor=[0.5 0.5 0.5];
    markercolor=[0.5 0.5 0.5];
end

for ib=1:handles.model.dflowfm.domain(id).nrcrosssections
    plothandles(ib)=handles.model.dflowfm.domain(id).crosssections(ib).handle;
end

switch lower(opt)
    
    case{'plot'}
        
        % First delete old sections
        try
            delete(plothandles);
        end

        plothandles=[];
        
        if handles.model.dflowfm.domain(id).nrcrosssections>0

            for isec=1:length(handles.model.dflowfm.domain(id).crosssections)
                x=handles.model.dflowfm.domain(id).crosssections(isec).x;
                y=handles.model.dflowfm.domain(id).crosssections(isec).y;
                if isec==handles.model.dflowfm.domain(id).activecrosssection
                    markercolor='r';
                else
                    markercolor=[1 1 0];
                end
                p=gui_polyline('plot','x',x,'y',y,'tag','dflowfmcrosssection', ...
                    'changecallback',@ddb_DFlowFM_crossSections,'changeinput','changecrosssection','closed',0, ...
                    'Marker','o','color',linecolor,'markeredgecolor',markercolor,'markerfacecolor',markercolor);
                handles.model.dflowfm.domain(id).crosssections(isec).handle=p;

                plothandles(isec)=p;
                
            end
            
            if vis
                set(plothandles,'Visible','on');
            else
                set(plothandles,'Visible','off');
            end
        end
        
        
    case{'delete'}
        
        % Delete old grid
        try
            delete(plothandles);
        end
        
        % And now (just to make sure) delete all objects with tag
        h=findobj(gcf,'Tag','dflowfmcrosssection');
        if ~isempty(h)
            delete(h);
        end
        
    case{'update'}
        try

            if handles.model.dflowfm.domain(id).nrcrosssections>0
                
                for ip=1:length(plothandles)

                    if iactive
                        if ip==handles.model.dflowfm.domain(id).activecrosssection
                            markercolor='r';
                        else
                            markercolor=[1 1 0];
                        end
                        set(plothandles(ip),'HitTest','on');
                        ch=get(plothandles(ip),'Children');
                        for ipp=1:length(ch)
                            set(ch(ipp),'HitTest','on');
                        end
                    else
                        markercolor=[0.5 0.5 0.5];
                        set(plothandles(ip),'HitTest','off');
                        ch=get(plothandles(ip),'Children');                        
                        for ipp=1:length(ch)
                            set(ch(ipp),'HitTest','off');
                        end                        
                    end
                    
                    gui_polyline(plothandles(ip),'change','color',linecolor,'markeredgecolor',markercolor,'markerfacecolor',markercolor);
                    
                end
                
                if vis
                    set(plothandles,'Visible','on');
                else
                    set(plothandles,'Visible','off');
                end
            end
        end
end

