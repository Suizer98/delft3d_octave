function handles = ddb_sfincs_plot_grid(handles, opt, varargin)
%DDB_sfincs_PLOTGRID  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_sfincs_plotGrid(handles, opt, varargin)
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
%   ddb_sfincs_plotGrid
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

% $Id: ddb_sfincs_plotGrid.m 12131 2015-07-24 15:11:30Z ormondt $
% $Date: 2015-07-24 17:11:30 +0200 (Fri, 24 Jul 2015) $
% $Author: ormondt $
% $Revision: 12131 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/models/sfincs/plot/ddb_sfincs_plotGrid.m $
% $Keywords: $

%%

col=[1 1 0];
vis=1;
id=1;

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
        
        % First delete old grid
        try
            delete(handles.model.sfincs.domain(id).gridoutline.handle);
        end
        
        x0=handles.model.sfincs.domain(id).input.x0;
        y0=handles.model.sfincs.domain(id).input.y0;
        dx=handles.model.sfincs.domain(id).input.dx;
        dy=handles.model.sfincs.domain(id).input.dy;
        mmax=handles.model.sfincs.domain(id).input.mmax;
        nmax=handles.model.sfincs.domain(id).input.nmax;
        dx=dx*mmax;
        dy=dy*nmax;
        rot=handles.model.sfincs.domain(id).input.rotation*pi/180;
        
        xx(1)=x0;
        yy(1)=y0;
        xx(2)=xx(1)+cos(rot)*dx;
        yy(2)=yy(1)+sin(rot)*dx;
        xx(3)=xx(2)+cos(rot+0.5*pi)*dy;
        yy(3)=yy(2)+sin(rot+0.5*pi)*dy;
        xx(4)=xx(3)+cos(rot+1.0*pi)*dx;
        yy(4)=yy(3)+sin(rot+1.0*pi)*dx;
        xx(5)=xx(1);
        yy(5)=yy(1);
        
        p=plot(xx,yy);
        set(p,'Color',col,'LineWidth',1.5);
        
        handles.model.sfincs.domain(id).gridoutline.handle=p;
        
        if vis
            set(p,'Color',col,'Visible','on');
        else
            set(p,'Color',col,'Visible','off');
        end
        
    case{'delete'}
        
        % Delete old grid
        try
            delete(handles.model.sfincs.domain(id).gridoutline.handle);
        end
        
    case{'update'}
        
        try
            p=handles.model.sfincs.domain(id).gridoutline.handle;
            if ~isempty(p)
                try
                    set(p,'Color',col);
                    if vis
                        set(p,'Color',col,'Visible','on');
                    else
                        set(p,'Color',col,'Visible','off');
                    end
                end
            end
        end
end

