function ZI = nangriddata(varargin)
%NANGRIDDATA   griddata for matrices with NaNs
%
% ZI = NANGRIDDATA(X,Y,Z,XI,YI,<...>) does same as GRIDDATA, but handles
% cases where X,Y and/or Z are NaN in source data X,Y,Z differently 
% (i.e. correctly) while in GRIDDATA these cases either crash or are wrong:
%
% * cases where X or Y are NaN, but Z is not Nan,
%   gaps (''islands'') will end up in Z. This is the
%   default option which can be specified explicitly as well by:
%
%   GRIDDATA('none',...)
%
% * cases where X and Y are not NaN, while Z is NaN, 
%   can be filled (interpolated) optionally ( not default) by:
%
%   GRIDDATA('filled',...)
%
% * Note that cases where X and Y are NaN, irrespective of whether Z is NaN,
%   cannot be filled on theoretical grounds!
%
%See also: GRIDDATA, DELAUNAY

%   --------------------------------------------------------------------
%   Copyright (C) 2004-8 Delft University of Technology
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
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   -------------------------------------------------------------------- 

   if ischar(varargin{1})
      OPT.fill = varargin{1};
      iargin   = 2;
   else
      OPT.fill = 'none';% default 'fill'
      iargin   = 1;
   end
   
   X       = varargin{iargin + 0};
   Y       = varargin{iargin + 1};
   Z       = varargin{iargin + 2};
   XI      = varargin{iargin + 3};
   YI      = varargin{iargin + 4};

%% Remove all places where X,Y are NaN                  from source data: these become holes
%% Remove all places where Z   is  NaN, and X,Y are not from source data: these will be filled in
%% ------------------------------------------

   if strcmpi(OPT.fill,'none')
      mask    = isnan(X) | isnan(Y);
      ZI      = griddata(X(~mask),Y(~mask),Z(~mask),XI,YI,varargin{iargin + 5:end});
   else
      mask    = isnan(X) | isnan(Y) | isnan(Z);
      ZI      = griddata(X(~mask),Y(~mask),Z(~mask),XI,YI,varargin{iargin + 5:end});
   end

%% EOF
