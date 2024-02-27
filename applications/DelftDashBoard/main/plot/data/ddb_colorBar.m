function ddb_colorBar(opt, varargin)
%DDB_COLORBAR  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_colorBar(opt, varargin)
%
%   Input:
%   opt      =
%   varargin =
%
%
%
%
%   Example
%   ddb_colorBar
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

% $Id: ddb_colorBar.m 18435 2022-10-12 16:12:30Z ormondt $
% $Date: 2022-10-13 00:12:30 +0800 (Thu, 13 Oct 2022) $
% $Author: ormondt $
% $Revision: 18435 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/main/plot/data/ddb_colorBar.m $
% $Keywords: $

%%
handles=getHandles;

switch lower(opt)
    case{'make'}
        mapPanel=handles.GUIHandles.mapPanel;
        ppos=get(mapPanel,'Position');
        pos(1)=ppos(3)-40;
        pos(2)=10;
        pos(3)=20;
        pos(4)=ppos(4)-50;
        handles.GUIHandles.colorBarPanel=uipanel('Units','pixels','Parent',mapPanel,'Position',[70 200 870 440]);
        if verLessThan('matlab', '8.4')
            set(handles.GUIHandles.colorBarPanel,'BorderType','beveledout','BorderWidth',1,'BackgroundColor','none');
        else
            set(handles.GUIHandles.colorBarPanel,'BorderType','none','BorderWidth',1,'BackgroundColor',handles.backgroundColor);
        end
        set(handles.GUIHandles.colorBarPanel,'Position',pos);
        clrbar=axes;
        set(clrbar,'Units','pixels');
        set(clrbar,'Parent',handles.GUIHandles.colorBarPanel);
        pos(1)=1;
        pos(2)=1;
        pos(3)=pos(3);
        pos(4)=pos(4);
        set(clrbar,'Position',pos);
        set(clrbar,'xlim',[0 1],'ylim',[0 1]);
        set(clrbar,'XTick',[]);
        set(clrbar,'HitTest','off');
        set(clrbar,'Tag','colorbar');
        set(clrbar,'Box','off');
        set(clrbar,'TickLength',[0 0]);
        set(clrbar,'NextPlot','add');
        clrbar.YLabel.String='meters';
        handles.GUIHandles.colorBar=clrbar;
        setHandles(handles);
    case{'update'}
        set(handles.GUIHandles.mainWindow,'CurrentAxes',handles.GUIHandles.colorBar);
        %        axes(handles.GUIHandles.colorBar);
        cla;
        colormap=varargin{1};
        clim=get(handles.GUIHandles.mapAxis,'CLim');
        nocol=64;
        clmap=ddb_getColors(colormap,nocol)*255;
        x(1)=0;x(2)=1;x(3)=1;x(4)=0;x(5)=0;
        for i=1:nocol
            col=clmap(i,:);
            y(1)=clim(1)+(clim(2)-clim(1))*(i-1)/nocol;
            y(2)=y(1);
            y(3)=clim(1)+(clim(2)-clim(1))*(i)/nocol;
            y(4)=y(3);
            y(5)=y(1);
            fl=fill(x,y,'b');hold on;
            set(fl,'FaceColor',col,'LineStyle','none');
        end
        set(handles.GUIHandles.colorBar,'XTick',[]);
        set(handles.GUIHandles.colorBar,'xlim',[0 1],'ylim',[clim(1) clim(2)]);
        set(handles.GUIHandles.colorBar,'Box','off');
        set(handles.GUIHandles.colorBar,'TickLength',[0 0]);
    case{'resize'}
        mapPanel=handles.GUIHandles.mapPanel;
        ppos=get(mapPanel,'Position');
        pos(1)=ppos(3)-40;
        pos(2)=10;
        pos(3)=20;
        pos(4)=ppos(4)-50;
        set(handles.GUIHandles.colorBar,'Position',pos);
end
set(handles.GUIHandles.mainWindow,'CurrentAxes',handles.GUIHandles.mapAxis);


