function varargout = griddata_nearest(X,Y,Z,XI,YI,varargin)
%GRIDDATA_NEAREST Data gridding and surface fitting.
%
%     ZI = griddata_nearest(X,Y,Z,XI,YI)
%
%   GRIDDATA_NEAREST fits a surface of the form ZI = F(XI,YI) to the
%   data in the (usually) nonuniformly-spaced vectors (X,Y,Z).
%   GRIDDATA_NEAREST interpolates this surface at the points specified by
%   (XI,YI) to produce ZI. XI and YI are usually a uniform grid (as
%   produced by MESHGRID).
%
%   Unlike GRIDDATA, GRIDDATA_NEAREST does not connect
%   all points [X,Y] in a (delaunay triangulation) mesh
%   before interpolation. Instead GRIDDATA_NEAREST
%   finds the closest point in the random set of points
%   [X,Y] for all points [XI,YI] one-at-a-time and
%   copies the associated value.
%
%   Note: GRIDDATA_NEAREST is much slower than GRIDDATA, but
%   owes it existence to those cases where:
%    i) GRIDDATA leads to (DELAUNAY) triangulation errors.
%   ii) large X and Y matrixes lead to MEMORY issues in GRIDDATA
%
%   ZI = griddata_nearest(X,Y,Z,XI,YI,'Rmax',Rmax,<keyword,value>,...)
%   where keyword 'Rmax' discards cases where the distance > Rmax.
%   This prevents for instance filling through clouds or land 
%   with neighbouring sea pixel values.
%
%   [ZI,I] = griddata_nearest(..) optionally returns index I into 
%   (X,Y,Z) to retrieve the position (X(I),Y(I)) of the nearest
%   pixel used to construct ZI.
%
%   For interpolation of lat-lon grids, make sure to convert both the X,Y
%   and XI,YI to an X,Y coordinate system using convertCoordinates().
%
%   See also: GRIDDATA, GRIDDATA_AVERAGE, GRIDDATA_REMAP, INTERP2, BIN2

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
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

% This tool is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

% TO DO: find closest of 3 points and interpolate value using
%        analytical fit of linear surface (if inside the triangle),
%        or use inverse distance
% TO DO: throw away any points outside (note: they can be nearest !!)
% TO DO: make space varying Rmax official ?

OPT.ndisp = 100;
OPT.Rmax  = Inf; % make this optionally same size as X and Y.
OPT.quiet = false;

if nargin==0;ZI = OPT;return;end

OPT  = setproperty(OPT,varargin);

ZI   = NaN((size(XI)));
R    = NaN((size(X )));
npix = length(XI(:));

if nargout==2
   index = zeros(size(XI));
end

%% print commandline waitbar
if ~OPT.quiet
    s = arrayfun(@(n) sprintf('|%d%%',n),0:10:100,'UniformOutput',false);
    s{end} = [s{end} '     '];
    fprintf('%s',char(s)');
    fprintf('\n');
end

pix.distance = 0;
for ipix = 1:npix % index in new (orthogonal) grid
    % the following if statements check if the distance between the current
    % point in the output grid is possibly within the search range of a
    % gridpoint. This is checked by comparing the previous distance to the
    % closest point and the distance between two consecutive points on the
    % new grid.
    if pix.distance > OPT.Rmax
        dR    = sqrt((XI(ipix) - XI(ipix-1)).^2 + ...
                     (YI(ipix) - YI(ipix-1)).^2);
        if pix.distance > OPT.Rmax + dR;
           pix.distance = pix.distance-dR;
        else % update distance
            R = sqrt((XI(ipix) - X).^2 + ...
                     (YI(ipix) - Y).^2);
            [pix.distance,pix.index] = min(R(:)); % index in old (random point) grid
        end
    else % update distance
        R = sqrt(...
            (XI(ipix) - X).^2 + ...
            (YI(ipix) - Y).^2);
        [pix.distance,pix.index] = min(R(:)); % index in old (random point) grid
    end
    
    %% take care of max distance
    
    if (pix.distance < OPT.Rmax)
        ZI(ipix)                 = Z(pix.index);
    end

    if ~OPT.quiet 
        if mod(ipix-1,floor(npix/100))==0
            if mod(ipix-1,floor(npix/10))==0
                fprintf('|');
            else
                fprintf('.');
            end
        end
    end
    
   if nargout==2
      index(ipix) = pix.index;
   end

end % ipix

if ~OPT.quiet
    fprintf('\n');
end
%% EOF

if nargout==1
   varargout = {ZI};
elseif nargout==2
   varargout = {ZI,index};
end