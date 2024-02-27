function col = colormapbluewhitered(m)
%COLORMAPBLUEWHITERED  colors from blue to red via white.
%
% The middle color(s) is/are always white (1 1 1). 
% BlueWhiteRed, by itself, is the same length as the 
% current figure's colormap. If no figure exists, MATLAB creates one.
%
% Syntax:
% col = colormapbluewhitered(m)
%
% Input:
% m = (Optional)
%
% Output:
% col = colormap
%
% See also: JET,HSV, HOT, PINK, FLAG, COLORMAP, RGBPLOT.

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares 2004 - 2007,  September 2008
%       Gerben de Boer
%
%       Thijs Damsma	
%
%       <ADDRESS>
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

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 05 Jul 2010
% Created with Matlab version: 7.7.0.471 (R2008b)

% $Id: colormapbluewhitered.m 2781 2010-07-05 13:06:02Z boer_g $
% $Date: 2010-07-05 21:06:02 +0800 (Mon, 05 Jul 2010) $
% $Author: boer_g $
% $Revision: 2781 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/color_fun/colormaps/colormapbluewhitered.m $
% $Keywords: $

if nargin < 1
   m = size(get(gcf,'colormap'),1);
end

n               = ceil(m/2)-1;
col             = ones(m,3);
col(1:n+1    ,1)=   (0:n)/n;
col(1:n+1    ,2)=   (0:n)/n;
col(end-n:end,2)=(n:-1:0)/n;
col(end-n:end,3)=(n:-1:0)/n;











