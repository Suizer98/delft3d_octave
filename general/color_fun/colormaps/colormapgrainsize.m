function col = colormapgrainsize(m)
%COLORMAPGRAINSIZE   colormap with varying height and shading to represent grain sizes
%  
%   col = colormapgrainsize(m) where M is the number of colors (default 32).
%
%See also: colormapbathymetry, colormapbluewhitered, copper

%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares for Building with Nature
%       Gerben de Boer
%
%       g.j.deboer@deltares.nl
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

% $Id: colormapgrainsize.m 2513 2010-05-06 12:46:36Z boer_g $
% $Date: 2010-05-06 20:46:36 +0800 (Thu, 06 May 2010) $
% $Author: boer_g $
% $Revision: 2513 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/color_fun/colormaps/colormapgrainsize.m $
% $Keywords: $

x(1)=0; % black mud
r(1)=0;
g(1)=0;
b(1)=0;

x(end+1)=1/8; % brown silt
r(end+1)=174;
g(end+1)=119;
b(end+1)=0;

x(end+1)=2/8; % fine white sane
r(end+1)=255;
g(end+1)=255;
b(end+1)=255;

x(end+1)=3/8; % yellow sand
r(end+1)=255;
g(end+1)=255;
b(end+1)=0;

x(end+1)=4/8; % yellow/brown sand
r(end+1)=191;
g(end+1)=191;
b(end+1)=0;

x(end+1)=4/6; % orange/pinkish sand
r(end+1)=255;
g(end+1)=177;
b(end+1)=100;

x(end+1)=5/6; % purplish
r(end+1)=131;
g(end+1)=97;
b(end+1)=123;

x(end+1)=1.;  % gray pebbles/cobbles
r(end+1)=128;
g(end+1)=128;
b(end+1)=128;


if nargin < 1
   ncol = 32;
else
   ncol=m;
end

for j=1:ncol

    i=(j-1)/(ncol-1);

    for k=1:(size(x,2)-1);
        in=and( i>=x(k), i<=x(k+1) );
        if in
            col(j,1)=r(k) + ((r(k+1)-r(k))/(x(k+1)-x(k)))*(i-x(k));
            col(j,2)=g(k) + ((g(k+1)-g(k))/(x(k+1)-x(k)))*(i-x(k));
            col(j,3)=b(k) + ((b(k+1)-b(k))/(x(k+1)-x(k)))*(i-x(k));
        end
    end
end

col=col/255;
