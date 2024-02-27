%NANINTERP Interpolation, data gridding and surface fitting ignoring NANs.
%   ZI = NANINTERP(X,Y,Z,XI,YI,METHOD) fits a surface of the form
%   Z = F(X,Y) to the data in the (usually) nonuniformly-spaced vectors 
%      (X,Y,Z). 
%   NANINTERP use GETINTERP and then TriScatteredInterp to interpolate 
%   this surface at the points specified by (XI,YI) to produce ZI
%   The surface always goes through the data points. XI and YI are
%   usually a uniform grid (as produced by MESHGRID).
%   This routine excludes nan values. If there are any nan, the
%   routine will take out those values and only interpolates the non-nan part.
%
%   [...] = NANINTERP(X,Y,Z,XI,YI,METHOD) where METHOD is one of
%         'linear'    - Triangle-based linear interpolation (default)
%         'nearest'   - Nearest neighbor interpolation
%         'block'     - Averaging data in a cell 
%         'wblock'    - Weigthed average of data in a cell 
%                       NOTE: the block is definded acording with the grid
%                       presented in XI,YI,
%   See also: GRIDDATA INDOMAIN GRIDPERIM

%   Copyright: Deltares, the Netherlands
%        http://www.delftsoftware.com
%        Date: 05.06.2009
%      Author: S. Gaytan Aguilar
%--------------------------------------------------------------------------

function zi  = naninterp(x,y,z,xi,yi,method)

if nargin <6 ;
   method = 'linear';
end

%If z is 3D
nz = size(z,3);
zi = nan([size(xi) nz]);
for iz = 1:nz
    zi(:,:,iz) = getInterp(x,y,z(:,:,iz),xi,yi,method); 
end

function zi  = getInterp(x,y,z,xi,yi,method)

ii = ~isnan(xi) & ~isnan(yi);
i = ~isnan(x) & ~isnan(y) &~isnan(z);
zi = nan(size(xi));

if sum(i(:))>=3
    % Interpolation
    Fz = TriScatteredInterp(x(i),y(i),z(i),method);
    zi(ii) = Fz(xi(ii),yi(ii));
end