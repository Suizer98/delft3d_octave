function varargout = griddata_near2(X,Y,Z,XI,YI,PI,WI,varargin)
%griddata_near2  2-step data gridding and surface fitting
%
%     [PI,RI,<WI>] = GRIDDATA_NEAR1(X,Y,  XI,YI,npts); % NO Z !!!
%      ZI          = GRIDDATA_NEAR2(X,Y,Z,XI,YI,PI,WI);
%
%   griddata_near2 fits a surface of the form ZI = F(XI,YI) to the
%   data in the (usually) non-uniformly-spaced vectors (X,Y,Z).
%   GRIDDATA_NEAREST interpolates this surface at the points specified by
%   (XI,YI) to produce ZI. GRIDDATA_NEAREST1 is used first to 
%   determine the required index pointers PI and interpolation weights WI.
%   (X,Y) and (XI,YI) can be row vectors, column vectors or 2D matrices
%   as for instance produced by MESHGRID.
%
%   Unlike GRIDDATA, Z can optionally have one extra dimension compared 
%   to X,Y (e.g. time), that is returned also as extra dimension in ZI such
%   that ZI has an extra dimension compared to XI,YI.
%
%See also: GRIDDATA_NEAR1, GRIDDATA, GRIDDATA_NEAREST, GRIDDATA_REMAP, INTERP2, BIN2
%          TriScatteredInterp, DELFT3D_IO_ADM, NESTING, arbcross

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012
%       Dr.ir. Gerben J. de Boer, Deltares
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
%   along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id: griddata_near2.m 8001 2013-02-01 15:09:24Z boer_g $
% $Date: 2013-02-01 23:09:24 +0800 (Fri, 01 Feb 2013) $
% $Author: boer_g $
% $Revision: 8001 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/grid_fun/griddata_near2.m $
% $Keywords: $

OPT = struct([]);

if nargin==0;ZI = OPT;return;end

OPT  = setproperty(OPT,varargin);

npts = size(WI,1);
RANK = ndims(Z);
if (isvector(X) & isvector(Z))
   samesize=1;%'a'
elseif (isvector(X) & ~isvector(Z))
   samesize=0;%'b'
   X = X(:);Y = Y(:);
   if isrow(X) % X([1 x n]), then Z([1 x n x :])
       if length(size(Z))==3
           RANK = 3;
       else
           error('if isrow(X), Z should be Z(:,:,:)')
       end
   elseif iscolumn(X) % [n x 1], then 
       if length(size(Z))==3     % Z([n x 1 x :]) or ...
           RANK = 3;
       elseif length(size(Z))==2 % ... or  Z([n x :])
           RANK = 2;
       else
           error('if isrow(X), Z should be Z(:,:,:)')
       end
   end
elseif ndims(Z) == (ndims(X))
   samesize=1;%'c'
elseif ndims(Z) == (ndims(X)+1)
   samesize=0;%'d'
else
   error('Z should have size(X) with one optionel extra dim');
end
ranki = ndims(PI);
if samesize
   ZI   = zeros(size(XI));
   for ipts = 1:npts
      DW = WI(ipts,:);
      DZ = reshape(Z(PI(ipts,:)),size(DW));
      DZ = DZ.*DW;
      ZI = ZI + reshape(DZ,size(ZI));
   end
else
   ZI   = zeros([size(Z,RANK) (size(XI))]); % permute extra dim from end to start, permute ZI later to make it the last again
   Z    = permute(Z,[RANK (1:RANK-1)]);
   for ipts = 1:npts
      DW = WI(ipts,:);
      DZ = Z(:,PI(ipts,:));
      for it=1:size(DZ,1)
      DZ(it,:) = DZ(it,:).*DW;
      end
      ZI = ZI + reshape(DZ,size(ZI));
   end
   %ranki = length(size(ZI));
   ZI = permute(ZI,[2:ranki 1]); % permute extra dimension from start to end
end


varargout = {ZI};