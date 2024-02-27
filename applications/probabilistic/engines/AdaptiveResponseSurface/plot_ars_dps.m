function plot_ars_dps(varargin)
%PLOT_ARS_DPS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = plot_ars_dps(varargin)
%
%   Input: For <keyword,value> pairs call plot_ars_dps() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   plot_ars_dps
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
%       Joost den Bieman
%
%       joost.denbieman@deltares.nl
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
% Created: 05 Oct 2012
% Created with Matlab version: 7.12.0.635 (R2011a)

% $Id: plot_ars_dps.m 7528 2012-10-18 16:10:07Z bieman $
% $Date: 2012-10-19 00:10:07 +0800 (Fri, 19 Oct 2012) $
% $Author: bieman $
% $Revision: 7528 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/engines/AdaptiveResponseSurface/plot_ars_dps.m $
% $Keywords: $


%% Settings

OPT = struct(...
    'ARS',      prob_ars_struct_mult ...
);

OPT = setproperty(OPT, varargin{:});

%% Calculating ARS grid

x   = -5:0.1:5;
y   = -5:0.1:5;

z   = NaN(size(x,2),size(y,2));

for i=1:size(x,2)
    for j=1:size(y,2)
        z_grid(i,j) = prob_ars_get_mult([x(i) y(j)],'ARS',OPT.ARS);
    end
end

pcolor(x,y,z_grid);
colorbar
shading flat
axis equal

hold on

U = cat(1,OPT.ARS.u_DP);
scatter(U(:,1),U(:,2),'w')
