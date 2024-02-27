%KML_curvedArrows  particle tracking arrows
%
%    [xp,yp,xax,yax]=KML_curvedArrows(x0,y0,x,y,u,v,dt,nt,hdthck,arthck,relwdt);
%
% with input:
%   x0,y0        = seed coordinates
%   x,y,u,v      = velocity field
%   nt           = numel(x) {needed because KML_curvedArrows is fortran77 mex file}
%   dt           = time (determines length of arrows) ~ duration particle tracking
%   hdthck       = head thickness (scalar)
%   arthck       = arrow thickness (scalar)
%   relwdt       = relative width, leave at one, same size as x (numel(x))
% with output:
%   xp,yp        = 1D vector with all arrows edges as polygons, 
%                  separated with 999.999 values
%                  each arrows has 35 points, so use
%                  xp(xp<1000.0 & xp>999.998)=NaN;xp = reshape(xp,35,[]);xp(end,:) = [];
%                  yp(yp<1000.0 & yp>999.998)=NaN;yp = reshape(yp,35,[]);yp(end,:) = [];
%   xax,yax      = 1D vector with all arrows centerline polygons, 
%                  separated with 999.999 values
%
%See also: KMLcurvedArrows, KMLquiver

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 200x Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl  
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

warning([mfilename,' should be adapted to use curvec.m'])