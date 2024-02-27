function varargout = gui_pointcloud(varargin)
%UIPOLYLINE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = gui_pointcloud(h, opt, varargin)
%
%   Input:
%   h         =
%   opt       =
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   UIPolyline
%
%   See also

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

% $Id: gui_pointcloud.m 15800 2019-10-04 05:51:09Z ormondt $
% $Date: 2019-10-04 13:51:09 +0800 (Fri, 04 Oct 2019) $
% $Author: ormondt $
% $Revision: 15800 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/gui/experimental/gui_pointcloud.m $
% $Keywords: $

%

if ischar(varargin{1})
    opt=varargin{1};
else
    hg=varargin{1};
    opt=varargin{2};
end

% Default values
options.marker='o';
options.markeredgecolor='k';
options.markerfacecolor='y';
options.markersize=5;
options.activemarker='o';
options.activemarkeredgecolor='k';
options.activemarkerfacecolor='r';
options.activemarkersize=6;
options.activepoint=[];
options.text=[];
options.font='Helvetica';
options.fontcolor='k';
options.fontweight='normal';
options.fontsize=10;
options.selectcallback=[];
options.selectinput=[];
options.doubleclickcallback=[];
options.doubleclickinput=[];
options.rightclickcallback=[];
options.rightclickinput=[];
options.axis=gca;
options.tag='';

activepoint=1;

% Not generic yet! DDB specific.
options.windowbuttonupdownfcn=@ddb_setWindowButtonUpDownFcn;

for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'xy'}
                xy=varargin{i+1};
                x=xy(:,1);
                y=xy(:,2);
            case{'activepoint'}
                activepoint=varargin{i+1};
            case{'tag'}
                options.tag=varargin{i+1};
            case{'marker'}
                options.marker=varargin{i+1};
            case{'markeredgecolor'}
                options.markeredgecolor=varargin{i+1};
            case{'markerfacecolor'}
                options.markerfacecolor=varargin{i+1};
            case{'markersize'}
                options.markersize=varargin{i+1};
            case{'activemarker'}
                options.activemarker=varargin{i+1};
            case{'activemarkeredgecolor'}
                options.activemarkeredgecolor=varargin{i+1};
            case{'activemarkerfacecolor'}
                options.activemarkerfacecolor=varargin{i+1};
            case{'activemarkersize'}
                options.activemarkersize=varargin{i+1};
            case{'text'}
                options.text=varargin{i+1};
            case{'font'}
                options.font=varargin{i+1};
            case{'fontcolor'}
                options.fontcolor=varargin{i+1};
            case{'fontsize'}
                options.fontsize=varargin{i+1};
            case{'fontweight'}
                options.fontweight=varargin{i+1};
            case{'font'}
                options.font=varargin{i+1};
            case{'selectcallback'}
                options.selectcallback=varargin{i+1};
            case{'selectinput'}
                options.selectinput=varargin{i+1};
            case{'doubleclickcallback'}
                options.doubleclickcallback=varargin{i+1};
            case{'doubleclickinput'}
                options.doubleclickinput=varargin{i+1};
            case{'rightclickcallback'}
                options.rightclickcallback=varargin{i+1};
            case{'rightclickinput'}
                options.rightclickinput=varargin{i+1};
            case{'windowbuttonupdownfcn'}
                options.windowbuttonupdownfcn=varargin{i+1};
            case{'windowbuttonmotionfcn'}
                options.windowbuttonmotionfcn=varargin{i+1};
            case{'axis'}
                options.axis=varargin{i+1};
        end
    end
end

switch lower(opt)
        
    case{'plot'}

        hg=hggroup;
        h=plot(0,0);
        set(h,'Parent',hg);
        setappdata(hg,'options',options);
        set(hg,'tag',options.tag);
        setappdata(hg,'x',x);
        setappdata(hg,'y',y);
        setappdata(hg,'activepoint',activepoint);

        h=drawPointCloud(hg);
        
    case{'delete'}

        try
            delete(hg);
        end

    case{'change'}
        
        if ~isempty(hg)
            
            for i=1:length(varargin)
                if ischar(varargin{i})
                    switch lower(varargin{i})
                        case{'markeredgecolor'}
                            h=getappdata(hg,'cloudhandle');
                            set(h,'markeredgecolor',varargin{i+1});
                        case{'markerfacecolor'}
                            h=getappdata(hg,'cloudhandle');
                            set(h,'markerfacecolor',varargin{i+1});
                        case{'markersize'}
                            h=getappdata(hg,'cloudhandle');
                            set(h,'markersize',varargin{i+1});
                        case{'activemarkeredgecolor'}
                            h=getappdata(hg,'activepointhandle');
                            set(h,'markeredgecolor',varargin{i+1});
                        case{'activemarkerfacecolor'}
                            h=getappdata(hg,'activepointhandle');
                            set(h,'markerfacecolor',varargin{i+1});
                        case{'activemarkersize'}
                            h=getappdata(hg,'activepointhandle');
                            set(h,'markersize',varargin{i+1});
                        case{'activepoint'}
                            setappdata(hg,'activepoint',activepoint);
                            h=getappdata(hg,'activepointhandle');
                            x=getappdata(hg,'x');
                            y=getappdata(hg,'y');
                            set(h,'XData',x(activepoint),'YData',y(activepoint));
                        case{'xy'}
                            xy=varargin{i+1};
                            x=xy(:,1);
                            y=xy(:,2);
                            h=getappdata(hg,'cloudhandle');
                            mh=getappdata(hg,'activepointhandle');
                            iac=getappdata(hg,'activepoint');
                            set(h,'XData',x,'YData',y);
                            set(mh,'XData',x(iac),'YData',y(iac));
                            setappdata(hg,'x',x);
                            setappdata(hg,'y',y);
                            tx=getappdata(hg,'texthandles');
                            for ii=1:length(tx)
                                pos=[x(ii) y(ii) 0];
%                                set(tx(ii),'XData',x(ii),'YData',y(ii));
                                set(tx(ii),'Position',pos);
                            end
                        case{'text'}
                            txt=varargin{i+1};
                            tx=getappdata(hg,'texthandles');
                            h=getappdata(hg,'cloudhandle');                            
                            for ii=1:length(tx)
                                if isempty(txt)
                                    set(tx(ii),'String','');
                                else
                                    set(tx(ii),'String',txt{ii});
                                end
                            end
                        case{'textvisible'}
                            tx=getappdata(hg,'texthandles');
                            set(tx,'Visible',varargin{i+1});
                        case{'selectcallback'}
                            h=getappdata(hg,'cloudhandle');
                            options=getappdata(hg,'options');
                            options.selectcallback=varargin{i+1};
                            setappdata(hg,'options',options);
                        case{'selectinput'}
                            h=getappdata(hg,'cloudhandle');                            
                            options=getappdata(hg,'options');
                            options.selectinput=varargin{i+1};
                            setappdata(hg,'options',options);
                    end
                end
            end
        end
        
end

if nargout==1
    varargout{1}=h;
elseif nargout==2
    varargout{1}=x;
    varargout{2}=y;
else    
    varargout{1}=h;
end

%%
function hg=drawPointCloud(hg)
% called to plot the polyline

x=getappdata(hg,'x');
y=getappdata(hg,'y');
iac=getappdata(hg,'activepoint');
options=getappdata(hg,'options');

% Delete temporary polyline
delete(hg);

if ~isempty(x)

    hg=hggroup;
    set(hg,'Tag',options.tag);
    setappdata(hg,'options',options);
    
    h=plot(x,y,'g');

    set(h,'Parent',hg);
    set(h,'Marker',options.marker);
    set(h,'MarkerEdgeColor',options.markeredgecolor);
    set(h,'MarkerFaceColor',options.markerfacecolor);
    set(h,'MarkerSize',options.markersize);
    set(h,'LineStyle','none');
%    set(h,'HitTest','off');
    set(h,'Tag',options.tag);
    set(h,'Parent',hg);
    setappdata(hg,'cloudhandle',h);
    setappdata(hg,'x',x);
    setappdata(hg,'y',y);

    set(h,'ButtonDownFcn',{@selectPoint,hg});

    if ~isempty(iac)
        mh=plot(x(iac),y(iac),options.activemarker);
        set(mh,'Marker',options.activemarker);
        set(mh,'MarkerEdgeColor',options.activemarkeredgecolor);
        set(mh,'MarkerFaceColor',options.activemarkerfacecolor);
        set(mh,'MarkerSize',options.activemarkersize);
        setappdata(hg,'activepointhandle',mh);
        set(mh,'Parent',hg);
        set(mh,'Tag',options.tag);
        set(mh,'HitTest','off');
    end

    tx=[];
    if ~isempty(options.text)
        for i=1:length(x)
            tx(i)=text(x(i),y(i),[' ' options.text{i}]);
            set(tx(i),'Tag',options.tag,'HitTest','off','Clipping','on');
            set(tx(i),'FontName',options.font);
            set(tx(i),'FontSize',options.fontsize);
            set(tx(i),'FontWeight',options.fontweight);
            setappdata(tx(i),'number',i);
            set(tx(i),'Tag',options.tag);
            set(tx(i),'Parent',hg);
        end
    end   
    setappdata(hg,'texthandles',tx);
        
end

%%
function selectPoint(imagefig, varargins,hg)

mouseclick=get(gcf,'SelectionType');

options=getappdata(hg,'options');

if strcmp(mouseclick,'normal')
    % Left click
    
    pos=get(options.axis, 'CurrentPoint');
    posx=pos(1,1);
    posy=pos(1,2);

    xl=get(options.axis,'XLim');
    yl=get(options.axis,'YLim');    
    
    if posx>=xl(1) && posx<=xl(2) && posy>=yl(1) && posy<=yl(2)
        
        % Find nearest point
        x=getappdata(hg,'x');
        y=getappdata(hg,'y');
        dist=sqrt((x-posx).^2+(y-posy).^2);
        iac=find(dist==min(dist),1,'first');
        setappdata(hg,'activepoint',iac);        
        h=getappdata(hg,'activepointhandle');
        set(h,'XData',x(iac),'YData',y(iac));

        if ~isempty(options.selectcallback)
            if ~isempty(options.selectinput)
                feval(options.selectcallback,options.selectinput,hg,iac);
            else
                feval(options.selectcallback,hg,iac);
            end
        end
        
    end
    
else
    % Right click
end
