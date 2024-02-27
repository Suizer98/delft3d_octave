function fh = UCIT_plotGridOverview(datatype,varargin)
%UCIT_PLOTGRIDOVERVIEW   this routine displays all grid outlines
%
% This routine displays all grid outlines.
%
%  <figure_handle> = UCIT_plotGridOverview(datatype)
%
% see also ucit_netcdf, UCIT_getInfoFromPopup

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

OPT.refreshonly = 0;
OPT = setproperty(OPT,varargin{:});

%% get metadata (either from the console or the database)

d   = UCIT_getMetaData(2);

if ~isempty(findobj('tag','gridOverview'));
        h = findobj('tag','gridOverview');
   figure(h)
   OPT.axis = axis;
   close(h);
end

%% set up figure
fh=figure('tag','mapWindow');clf;
ah=axes;
[fh,ah] = UCIT_prepareFigureN(2, fh, 'LL', ah);
set(fh,'name','UCIT - Grid overview');
set(gca, 'fontsize',8);

hold on

if nargin == 0

   datatype = UCIT_getInfoFromPopup('GridsDatatype');

end

disp('plotting landboundary...');
UCIT_plotLandboundary(d.ldb);

%% plot kaartbladen
for i = 1:size(d.contour,1)
    ph(i)=patch([d.contour(i,1),d.contour(i,2),d.contour(i,2),d.contour(i,1),d.contour(i,1)],...
                [d.contour(i,3),d.contour(i,3),d.contour(i,4),d.contour(i,4),d.contour(i,3)], 'k');
    set(ph(i),'edgecolor','k','facecolor','none');
    set(ph(i),'tag',[d.names{i}]);
    set(gca  ,'tag',[datatype]);
end

set(gcf,'tag','gridOverview');

%% Adjust axis and labels
   box on
   if OPT.refreshonly
      axis    equal;
      axis(OPT.axis)
   else
      axis    equal;
      axis   ([d.axes])
   end
   tickmap('xy','dellast',1)

%% Make figure visible
set(fh,'visible','on');

