function colormap2D = colormap2Dbathymetry(m)
%% COLORMAP2DBATHYMETRY 2D colormap with varying height and shading to represent a bathymetry
%
% to be used in combination with e.g. hillshade
%
% See also: hillshade, colormapbathymetry

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares for Building with Nature
%       Thijs Damsma
%
%       Thijs.Damsma@deltares.nl	
%
%       Deltares
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

% $Id: colormap2Dbathymetry.m 623 2009-07-06 16:29:00Z damsma $
% $Date: 2009-07-07 00:29:00 +0800 (Tue, 07 Jul 2009) $
% $Author: damsma $
% $Revision: 623 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/color_fun/colormaps/colormap2Dbathymetry.m $
% $Keywords: $

if length(m) ==2;
    n = m(2);
    m = m(1);
else
    n = m(1);
    m = m(1);
end

[xi,yi] = meshgrid(linspace(0,1,n),linspace(0,1,m));

x = [   0, 0.42, 0.49, 0.5,   1;...
        0, 0.42, 0.49, 0.5,   1;...
        0, 0.42, 0.49, 0.5,   1];
y = [   0,    0,    0,   0,   0;...
      0.5,  0.5,  0.5, 0.5, 0.5;...
        1,    1,    1,    1,   1];

r = [ -20,  080,  165,  200,  25;...
        0,  165,  230,  230,  65;...
        0,  225,  255,  245, 140];
g = [ -20,  090,  180,  190, 85;...
       25,  175,  235,  230, 120;...
       60,  225,  255,  245, 165];
b = [  55,  145,  185,   30,  30;...
       75,  205,  255,  030,  45;...
      115,  245,  255,  110,  85];

colormap2D(:,:,1) = interp2(x,y,r,xi,yi)/255;
colormap2D(:,:,2) = interp2(x,y,g,xi,yi)/255;
colormap2D(:,:,3) = interp2(x,y,b,xi,yi)/255;
colormap2D(colormap2D<0) = 0;colormap2D(colormap2D>1) = 1;

