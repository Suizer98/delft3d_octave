function OPT = grid_orth_getOverview(OPT)
%GRID_ORTH_GETOVERVIEW Plots geographical extents of netcdf tiles on overview.
%
%See also: grid_2D_orthogonal

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

% $Id: grid_orth_getOverview.m 10966 2014-07-17 10:47:35Z heijer $
% $Date: 2014-07-17 18:47:35 +0800 (Thu, 17 Jul 2014) $
% $Author: heijer $
% $Revision: 10966 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/grid_2D_orthogonal/grid_orth_getOverview.m $
% $Keywords: $

%OPT0.tag     = [];
%OPT0.dataset = [];
%OPT0.urls    = [];
%
%if nargin==0
%   varargout = {OPT0};
%   return
%end
%OPT = setproperty(OPT0,OPT);

if ~isfield(OPT, 'tag'); OPT.tag = OPT.dataset; end


%% Step 0.1: get fixed map urls from OPeNDAP server
if ~isempty(OPT.urls)
    urls = OPT.urls;
else
    OPT = setproperty(OPT, {grid_orth_getMapInfoFromDataset(OPT.dataset)},...
        'onExtraField', 'warnAppend');
end

if OPT.plotoverview
    
    axes = findobj('type','axes');
    if isempty(axes) || ~any(ismember(get(axes, 'tag'), {OPT.tag})) % if an overview figure is already present don't run this function again
                
        %% Step 0.2: create a figure with tagged patches
        figure(10);clf;axis equal;box on;hold on
        
        %% Step 0.3: plot landboundary
        try % try loop to prevent crashing when no internet connection is available
            OPT.x = nc_varget(OPT.ldburl, nc_varfind(OPT.ldburl, 'attributename', 'standard_name', 'attributevalue', 'projection_x_coordinate'));
            OPT.y = nc_varget(OPT.ldburl, nc_varfind(OPT.ldburl, 'attributename', 'standard_name', 'attributevalue', 'projection_y_coordinate'));
            plot(OPT.x, OPT.y, 'k', 'linewidth', 2);
        end
        
        %% Step 0.4: plot fixed map patches on axes and return the axes handle
        ah = grid_orth_createFixedMapsOnAxes(gca, OPT, 'tag', OPT.tag); %#ok<*NODEF,*NASGU>
    end
    
end
