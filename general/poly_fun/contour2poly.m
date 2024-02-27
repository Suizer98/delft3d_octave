function varargout = contour2poly(c,varargin)
%CONTOUR2POLY transforms contour array to NaN-delimited polygon vector
%
% [x,y] = CONTOUR2POLY(c) converts a contourc c vector like this
%
%  c = [level1 x1 x2 x3 level2 x4 x5 x6 x7 ...;
%       n1     y1 y2 y3 n2     y4 y5 y6 x7 ...]
%
% to a NaN-delimited polygon vectors like this:
%
%  x = [       x1 x2 x3 nan    x4 x5 x6 x7 ...]
%  y = [       x1 x2 x3 nan    x4 x5 x6 x7 ...]
%
% [x,y]        = CONTOUR2POLY(c) Note that level information 
%                is lost so this option is useful only for 
%                contours with only 1 level (e.g. coastline).
%
% [x,y,levels,n] = CONTOUR2POLY(c)
%
% where levels contains the c value assiocated with each
% polygonsegment, and n the number of points per segment.
%
% struc        = CONTOUR2POLY(c) Returns struct with fields 
%                'x','y','levels' and 'n'.
%
% Note that although c=contourc also returns the contour x,y data 
% without plotting, it does not work for curvi-linear grids, so 
% there we have to use [c,h]=contour(...); delete(h).
%
% Eaxmple:
% 
%    z=peaks;
%    [c,h]=contour(z,[-3 3])
%    hold on
%    L = contour2poly(c);
%    plot(L.x,L.y,'o')
%
% See also: CONTOURC, POLY_SPLIT, POLY_JOIN, POLY2CONTOUR

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2006 Delft University of Technology
%       Gerben J. de Boer
%
%       g.j.deboer@tudelft.nl	
%
%       Fluid Mechanics Section
%       Faculty of Civil Engineering and Geosciences
%       PO Box 5048
%       2600 GA Delft
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
% Created: 26 Oct 2020
% Created with Matlab version: 9.9.0.1467703 (R2020b)

% $Id: contour2poly.m 17793 2022-02-25 12:52:07Z l.w.m.roest.x $
% $Date: 2022-02-25 20:52:07 +0800 (Fri, 25 Feb 2022) $
% $Author: l.w.m.roest.x $
% $Revision: 17793 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/poly_fun/contour2poly.m $
% $Keywords: $

%% Code
if ~isempty(c)
    S=contour_split(c);
    [P.x,P.y] = poly_join(S.x,S.y);
else
    P = struct('x',[],'y',[],'levels',[],'n',0);
end

if     nargout==1;varargout = {P};          
elseif nargout==2;varargout = {P.x,P.y};
elseif nargout==3;varargout = {P.x,P.y,S.levels};
elseif nargout==4;varargout = {P.x,P.y,S.levels,S.n};
end
   
%% EOF