function ddb_plotInitialTsunami(handles, xx, yy, zz)
%DDB_PLOTINITIALTSUNAMI  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_plotInitialTsunami(handles, xx, yy, zz)
%
%   Input:
%   handles =
%   xx      =
%   yy      =
%   zz      =
%
%
%
%
%   Example
%   ddb_plotInitialTsunami
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
% Created: 02 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: ddb_plotInitialTsunami.m 10993 2014-07-25 12:06:24Z ormondt $
% $Date: 2014-07-25 20:06:24 +0800 (Fri, 25 Jul 2014) $
% $Author: ormondt $
% $Revision: 10993 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/Tsunami/ddb_plotInitialTsunami.m $
% $Keywords: $

%%
fig3 = figure('Tag','Figure3','Name', 'Result');
set(fig3,'menubar','none');
set(fig3,'toolbar','figure');
set(fig3,'renderer','opengl');
tbh = findall(fig3,'Type','uitoolbar');
delete(findall(tbh,'TooltipString','Edit Plot'));
delete(findall(tbh,'TooltipString','Rotate 3D'));
delete(findall(tbh,'TooltipString','Show Plot Tools and Dock Figure'));
delete(findall(tbh,'TooltipString','New Figure'));
delete(findall(tbh,'TooltipString','Open File'));
delete(findall(tbh,'TooltipString','Save Figure'));
delete(findall(tbh,'TooltipString','Print Figure'));
delete(findall(tbh,'TooltipString','Data Cursor'));
delete(findall(tbh,'TooltipString','Insert Colorbar'));
delete(findall(tbh,'TooltipString','Insert Legend'));
delete(findall(tbh,'TooltipString','Hide Plot Tools'));
delete(findall(tbh,'TooltipString','Show Plot Tools'));

title('Initial Tsunami');
pcolor(xx,yy,zz);
shading flat;
grid on;
hold on;

load([handles.settingsDir 'geo\worldcoastline.mat']);
xldb=wclx;
yldb=wcly;
%z=zeros(size(xldb))+10;
landb=plot(xldb,yldb,'k');

load([handles.toolbox.tsunami.dataDir 'plates.mat']);
%platesz=zeros(size(platesx))+10;
h=plot(platesx,platesy);
set(h,'Color',[1.0 0.5 0.00]);
set(h,'LineWidth',1.5);
set(h,'HitTest','off');

xlabel ('X');
ylabel ('Y');
clbar=colorbar;
set(get(clbar,'YLabel'),'String','Initial water level (m w.r.t. MSL)');
%axis equal;
view(2);

xl=get(handles.GUIHandles.mapAxis,'xlim');
yl=get(handles.GUIHandles.mapAxis,'ylim');

if ~strcmpi(handles.screenParameters.coordinateSystem.type,'geographic')
    oldSys=handles.screenParameters.coordinateSystem;
    newSys.name='WGS 84';
    newSys.type='geographic';
    [xl(1),yl(1)]=ddb_coordConvert(xl(1),yl(1),oldSys,newSys);
    [xl(2),yl(2)]=ddb_coordConvert(xl(2),yl(2),oldSys,newSys);
end

axis equal;
set(gca,'Xlim',xl,'ylim',yl);

figure(handles.GUIHandles.mainWindow);

