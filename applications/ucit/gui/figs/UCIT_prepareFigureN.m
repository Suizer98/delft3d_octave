function [fh, ah] =  UCIT_prepareFigureN(type, figureTag, figurePos, axisTag, callback1, varargin1, callback2, varargin2)
%UCIT_PREPAREFIGURE  makes a new figure with the UCIT look and feel
%
%
%   See also 

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%   Mark van Koningsveld       
%   Ben de Sonneville
%
%       M.vankoningsveld@tudelft.nl
%       Ben.deSonneville@Deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

warning off

fh=figureTag;
ah=axisTag;

try
delete(findall(fh,'Type','uimenu'));
end

c=load('ucit_icons.mat');

switch type
    
    case 0
        
        % standard matlab icons are used
    
    case 1 % this is adapted for ucit transect overview
        delete(findall(fh,'Type','uitoolbar'));
        tbh = uitoolbar;
        h = uitoggletool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Zoom In');
        set(h,'ClickedCallback',{@UCIT_ZoomInOutPan,1,callback1, varargin1, callback2, varargin2});
        set(h,'Tag','UIToggleToolZoomIn');
        set(h,'cdata',c.ico.zoomin16);

        h = uitoggletool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Zoom Out');
        set(h,'ClickedCallback',{@UCIT_ZoomInOutPan,2,callback1, varargin1, callback2, varargin2});
        set(h,'Tag','UIToggleToolZoomOut');
        set(h,'cdata',c.ico.zoomout16);

        h = uitoggletool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Pan');
        set(h,'ClickedCallback',{@UCIT_ZoomInOutPan,3,callback1, varargin1, callback2, varargin2}');
        set(h,'Tag','UIToggleToolPan');
        set(h,'cdata',c.icons.pan);
        
        h = uitoggletool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Zoom reset');
        set(h,'ClickedCallback',{@UCIT_ZoomInOutPan,6,callback1, varargin1, callback2, varargin2}');
        set(h,'Tag','UIToggleToolRefresh');
        set(h,'cdata',c.icons.refresh);

    case 2
        
        delete(findall(fh,'Type','uitoolbar'));
        tbh = uitoolbar;
        h = uitoggletool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Zoom In');
        str='h=findall(gcf,''Tag'',''UIToggleToolZoomOut'');set(h,''State'',''off'');putdowntext(''zoomin'',gcbo)';
        set(h,'ClickedCallback',str);
        set(h,'Tag','UIToggleToolZoomIn');
        set(h,'cdata',c.ico.zoomin16);

        h = uitoggletool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Zoom Out');
        str='h=findall(gcf,''Tag'',''UIToggleToolZoomIn'');set(h,''State'',''off'');putdowntext(''zoomout'',gcbo)';
        set(h,'ClickedCallback',str);
        set(h,'Tag','UIToggleToolZoomOut');
        set(h,'cdata',c.ico.zoomout16);
        
        
end

% frameh = get(fh,'JavaFrame'); % Get Java Frame
% frameh.setFigureIcon(javax.swing.ImageIcon(which('DeltaresLogo.gif')));

set(fh,'Units','normalized','Position', UCIT_getPlotPosition(figurePos),'NumberTitle','Off','Color','w');
warning on
