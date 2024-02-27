function b = poly_isclockwise(x,y)
%POLY_ISCLOCKWISE   test whether a polygon is clockwise
%
%    bool = poly_isclockwise(X,Y)
%
% returns whether a polygon is clockwise (1) or
% anti-clockwise (0). For self-intersecting polygons
% the net overall enclosed area determined the result,
% using the sign of POLY_AREA.
%
% Note that the definition of POLY_ISCLOCKWISE
% differs from the stupid one in ISPOLYCW the native 
% (expensive) Matlab mapping toolbox !
%
%See also: POLY_AREA

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares for Rijkswaterstaat Kustlijnzorg
%       Gerben J. de Boer
%
%       gerben.deboer@deltares.nl
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

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id: poly_isclockwise.m 2299 2010-03-05 12:45:43Z boer_g $
% $Date: 2010-03-05 20:45:43 +0800 (Fri, 05 Mar 2010) $
% $Author: boer_g $
% $Revision: 2299 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/poly_fun/poly_isclockwise.m $
% $Keywords: $

   b = sign(poly_area(x,y))==-1; % poly_area is positive for anti-clockwise.

%% OEF