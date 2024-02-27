function muppet_aboutMuppet(handles)
%MUPPET_ABOUTMUPPET  Pops up GUI window with version information.

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
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

% $Id: muppet_aboutMuppet.m 8752 2013-06-02 21:06:03Z ormondt $
% $Date: 2013-06-03 05:06:03 +0800 (Mon, 03 Jun 2013) $
% $Author: ormondt $
% $Revision: 8752 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/muppet_v4/src/gui/muppet_aboutMuppet.m $
% $Keywords: $

%%

StatName=[handles.settingsdir 'icons' filesep 'muppets.jpg'];
c = imread(StatName,'jpeg');
sz=size(c);
MakeNewWindow('About Muppet',[sz(2) sz(1)],'modal',[handles.settingsdir 'icons' filesep 'deltares.gif']);
ax=axes;
set(ax,'Units','pixels');
set(ax,'Position',[0 0 sz(2) sz(1)]);

StatName=[handles.settingsdir 'icons' filesep 'muppets.jpg'];
c = imread(StatName,'jpeg');
image(c);
tick(gca,'x','none');tick(gca,'y','none');%axis equal;

font='Arial';
col=[143 188 143]/255;

tx=text(10,15,['Muppet - v ' handles.muppetversion]);
try
    set(tx,'FontSize',15,'Color',[0 0 0],'HorizontalAlignment','left','FontName',font);
catch
    set(tx,'FontSize',15,'Color',col,'HorizontalAlignment','left','FontName','Times New Roman');
end

tx2=text(11,299,'Contact Maarten van Ormondt for more information');
tx=text(10,300,'Contact Maarten van Ormondt for more information');
col='r';
try
    set(tx,'FontSize',12,'Color','y','HorizontalAlignment','left','FontName',font,'FontWeight','bold');
    set(tx2,'FontSize',12,'Color','g','HorizontalAlignment','left','FontName',font,'FontWeight','bold');
catch
    set(tx,'FontSize',12,'Color',col,'HorizontalAlignment','left','FontName','Times New Roman','FontWeight','bold');
end
tx2=text(11,319,'Maarten.vanOrmondt@deltares.nl');
tx=text(10,320,'Maarten.vanOrmondt@deltares.nl');
try
    set(tx,'FontSize',12,'Color','y','HorizontalAlignment','left','FontName',font,'FontWeight','bold');
    set(tx2,'FontSize',12,'Color','g','HorizontalAlignment','left','FontName',font,'FontWeight','bold');
catch
    set(tx,'FontSize',10,'Color',col,'HorizontalAlignment','left','FontName','Times New Roman','FontWeight','bold');
end
