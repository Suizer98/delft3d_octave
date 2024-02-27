function ddb_makeColorBar(ColorMap)
%DDB_MAKECOLORBAR  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_makeColorBar(ColorMap)
%
%   Input:
%   ColorMap =
%
%
%
%
%   Example
%   ddb_makeColorBar
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

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
h=findobj(gcf,'Tag','colorbar');

if ~isempty(h)
    pos=get(h,'Position');
    delete(h);
else
    pos=[930 210 25 420];
end

clim=get(gca,'CLim');

%nocol=128;
nocol=64;

clmap=ddb_getColors(ColorMap,nocol)*255;

ax=gca;

clrbar=axes;

for i=1:nocol
    col=clmap(i,:);
    x(1)=0;x(2)=1;x(3)=1;x(4)=0;x(5)=0;
    y(1)=clim(1)+(clim(2)-clim(1))*(i-1)/nocol;
    y(2)=y(1);
    y(3)=clim(1)+(clim(2)-clim(1))*(i)/nocol;
    y(4)=y(3);
    y(5)=y(1);
    fl=fill(x,y,'b');hold on;
    set(fl,'FaceColor',col,'LineStyle','none');
end

handles=getHandles;

set(clrbar,'Parent',handles.GUIHandles.mapPanel);
set(clrbar,'xlim',[0 1],'ylim',[clim(1) clim(2)]);
set(clrbar,'Units','pixels');
set(clrbar,'Position',pos);
set(clrbar,'XTick',[]);
set(clrbar,'YAxisLocation','right');
set(clrbar,'HitTest','off');
set(clrbar,'Tag','colorbar');

axes(ax);

