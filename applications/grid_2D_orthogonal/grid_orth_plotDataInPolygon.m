function grid_orth_plotDataInPolygon(X, Y, Z, Ztime, varargin)
%GRID_ORTH_PLOTDATAINPOLYGON Plots data from netCDF grid collection in polygon.
%
%   grid_orth_plotDataInPolygon(X, Y, Z, Ztime, <keyword,value>)
%
% See also: grid_2D_orthogonal

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       Mark van Koningsveld
%
%       m.vankoningsveld@tudelft.nl
%
%       Hydraulic Engineering Section
%       Faculty of Civil Engineering and Geosciences
%       Stevinweg 1
%       2628CN Delft
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

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

% $Id: grid_orth_plotDataInPolygon.m 5303 2011-10-04 14:33:46Z boer_g $
% $Date: 2011-10-04 22:33:46 +0800 (Tue, 04 Oct 2011) $
% $Author: boer_g $
% $Revision: 5303 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/grid_2D_orthogonal/grid_orth_plotDataInPolygon.m $
% $Keywords: $

OPT.polygon      = [];
OPT.datathinning = 1;
OPT.ldburl       = []; % x of coastline

OPT = setproperty(OPT,varargin{:});

if ~isempty(OPT.ldburl)
    try % included to enable off line working
        OPT.x = nc_varget(OPT.ldburl, nc_varfind(OPT.ldburl, 'attributename', 'standard_name', 'attributevalue', 'projection_x_coordinate'));
        OPT.y = nc_varget(OPT.ldburl, nc_varfind(OPT.ldburl, 'attributename', 'standard_name', 'attributevalue', 'projection_y_coordinate'));
    end
end

%% find unqiue date values

v = unique(Ztime(find(~isnan(Ztime))));
%if length(v)==1;v=[v(1) - 1 v];end
nv = length(v);

if nv == 0
   warning('no data found: only selection polygon plotted')
end

%% Step 1: plot resulting X, Y and Z grid

figure(2);clf;

% plot
   pcolorcorcen(X(1:OPT.datathinning:end,1:OPT.datathinning:end),...
                Y(1:OPT.datathinning:end,1:OPT.datathinning:end),...
                Z(1:OPT.datathinning:end,1:OPT.datathinning:end));
   hold on; 
   plot(OPT.polygon(:,1), OPT.polygon(:,2),'g','linewidth',2)

   % layout
   if nv > 0
   colorbar;
   end

   axis    equal
   axis    tight
   box     on
   
   title   ('z-values available in polygon')
   tickmap ('xy','texttype','text','format','%0.1f','dellast',1)
   try % included to enable offline working
   plot    (OPT.x,OPT.y,'k', 'linewidth', 2)
   end

%% Step 2: plot X, Y and Ztime
%-----------------
figure(3); clf; 


   % make matrix so you can plot index of unique values
   V=Ztime;
   for iv=1:nv
       mask = (Ztime==v(iv));
       V(mask)=iv;
   end
   
   % plot
   pcolorcorcen(X(1:OPT.datathinning:end,1:OPT.datathinning:end),...
                Y(1:OPT.datathinning:end,1:OPT.datathinning:end),...
                V(1:OPT.datathinning:end,1:OPT.datathinning:end));
   hold on; 
   plot(OPT.polygon(:,1), OPT.polygon(:,2),'g','linewidth', 2)
   
   % layout
   if nv > 0
   caxis   ([1-.5 nv+.5])
   colormap(jet(nv));
   [ax,c1] =  colorbarwithtitle('',1:nv+1); %#ok<NASGU>
   set(ax,'yticklabel',datestr(v,29))
   end
   
   axis    equal
   axis    tight
   box     on
   
   title   ('timestamps of z-values available in polygon')
   tickmap ('xy','texttype','text','format','%0.1f','dellast',1)
   try % included to enable offline working
       plot    (OPT.x,OPT.y,'k', 'linewidth', 2)
   end
