function col = colormapbathymetry(m)
%COLORMAPBATHYMETRY   colormap with varying height and shading to represent a bathymetry
%  
%   col = colormapbathymetry(m) where M is the number of colors (default 16).
%
%See also: colormap2Dbathymetry, colormapbluewhitered

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

% $Id: colormapbathymetry.m 2513 2010-05-06 12:46:36Z boer_g $
% $Date: 2010-05-06 20:46:36 +0800 (Thu, 06 May 2010) $
% $Author: boer_g $
% $Revision: 2513 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/color_fun/colormaps/colormapbathymetry.m $
% $Keywords: $

x(1)=0.0;
r(1)=10;
g(1)=10;
b(1)=140;

x(2)=0.45;
r(2)=170;
g(2)=230;
b(2)=254;

x(3)=0.49;
r(3)=235;
g(3)=255;
b(3)=205;

x(4)=0.51;
r(4)=255;
g(4)=255;
b(4)=90;

x(5)=1.0;
r(5)=0.0;
g(5)=127;
b(5)=34;


if nargin < 1
   ncol = 16;
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
