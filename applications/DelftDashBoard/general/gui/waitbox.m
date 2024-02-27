function fout = waitbox(name,varargin)
%WAITBOX  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   fout = waitbox(name)
%
%   Input:
%   name =
%
%   Output:
%   fout =
%
%   Example
%   waitbox
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
% Created: 27 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
%WAITBOX Display wait box.

global figureiconfile

tag='';
closefcn=[];

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'tag'}
                tag=varargin{ii+1};
            case{'closefcn'}
                closefcn=varargin{ii+1};
        end
    end
end

% Current axis
% hax=gca;

vertMargin = 0;

oldRootUnits = get(0,'Units');

set(0, 'Units', 'points');
screenSize = get(0,'ScreenSize');

axFontSize=get(0,'FactoryAxesFontSize');

pointsPerPixel = 72/get(0,'ScreenPixelsPerInch');

width = 360 * pointsPerPixel;
height = 75 * pointsPerPixel;
pos = [screenSize(3)/2-width/2 screenSize(4)/2-height/2 width height];

f = figure(...
    'Units', 'points', ...
    'BusyAction', 'queue', ...
    'Position', pos, ...
    'Resize','off', ...
    'CreateFcn','', ...
    'NumberTitle','off', ...
    'IntegerHandle','off', ...
    'MenuBar', 'none', ...
    'Visible','off');

set(f,'tag',tag);
if ~isempty(closefcn)
    set(f,'CloseRequestFcn',closefcn);
end

axNorm=[.05 .3 .9 .1];
axPos=axNorm.*[pos(3:4),pos(3:4)] + [0 vertMargin 0 0];

h = axes('XLim',[0 100],...
    'YLim',[0 1],...
    'Units','Points',...
    'FontSize', axFontSize,...
    'Position',axPos,...
    'XTickMode','manual',...
    'YTickMode','manual',...
    'XTick',[],...
    'YTick',[],...
    'XTickLabelMode','manual',...
    'XTickLabel',[],...
    'YTickLabelMode','manual',...
    'YTickLabel',[]);
set(h,'box','off');
axis off;
set(f,'WindowStyle','modal');

tHandle=get(h,'title');
oldTitleUnits=get(tHandle,'Units');
set(tHandle,...
    'Units',      'points',...
    'String',     name);

tExtent=get(tHandle,'Extent');
set(tHandle,'Units',oldTitleUnits);

titleHeight=tExtent(4)+axPos(2)+axPos(4)+5;
if titleHeight>pos(4)
    pos(4)=titleHeight;
    pos(2)=screenSize(4)/2-pos(4)/2;
    figPosDirty=true;
else
    figPosDirty=false;
end

if tExtent(3)>pos(3)*1.10;
    pos(3)=min(tExtent(3)*1.10,screenSize(3));
    pos(1)=screenSize(3)/2-pos(3)/2;
    
    axPos([1,3])=axNorm([1,3])*pos(3);
    set(h,'Position',axPos);
    
    figPosDirty=true;
end

if figPosDirty
    set(f,'Position',pos);
end

set(f,'HandleVisibility','callback','visible','on');

if ~isempty(figureiconfile)
        fh = get(f,'JavaFrame'); % Get Java Frame
        fh.setFigureIcon(javax.swing.ImageIcon(figureiconfile));
end

set(0, 'Units', oldRootUnits);
drawnow;

if nargout==1,
    fout = f;
end

% Return to current axis
% pause(1.0);

% axes(hax);

% drawnow;
