function col = colormapgreenwhitered(m)
%COLORMAPGREENWHITERED  colors from green to red via white.
%
% The middle color(s) is/are always white (1 1 1). 
% colormapgreenwhitered, by itself, is the same length as the 
% current figure's colormap. If no figure exists, MATLAB creates one.
% This is only triggered when m (see below) is not supplied
%
% Syntax:
% col = colormapgreenwhitered(m)
%
% Input:
% m = (Optional) (length of the colormap)
%
% Output:
% col = colormap
%
% See also: JET,HSV, HOT, PINK, FLAG, COLORMAP, RGBPLOT.

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2014 Deltares
%       Freek Scheel
%       freek.scheel@deltares.nl
%       +31 88 335 8241
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

if nargin < 1
   m = size(get(gcf,'colormap'),1);
   if m>256
       warning('Matlab often has problems with colormaps larger than 256 colors');
   end
end

n               = ceil(m/2)-1;
col             = ones(m,3);
col(1:n+1    ,1)=   (0:n)/n;
col(1:n+1    ,3)=   (0:n)/n;
col(end-n:end,2)=(n:-1:0)/n;
col(end-n:end,3)=(n:-1:0)/n;