function y = range(x,varargin)
%RANGE  difference between maximum and minimum values.
%
%   Y = range(X) returns the range of the values in X. For a vector input,
%   Y is the difference between the maximum and minimum values. For a
%   matrix input, Y is a vector containing the range for each column. For
%   N-D arrays, range operates along the first non-singleton dimension.
%
%   RANGE treats NaNs as missing values, and ignores them.
%         just like min(...) and max(...).
%
%   Y = RANGE(X,DIM)    operates along the dimension DIM.
%   Y = RANGE(X,[],dim) operate along the dimension dim.
%                       to allow for same syntax as min and max
%
%   Y = RANGE(X,0)      is same as range(x(:))
%   Y = RANGE(X,[],0)   is same as range(x(:))
%
%   See also IQR, MAD, MAX, MIN, STD, MEAN, RSS, RMS, RANGESIGNED.

%   --------------------------------------------------------------------
%   Copyright (C) Dec 2004 Delft University of Technology
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
%   --------------------------------------------------------------------

% $Id: range.m 390 2009-04-22 09:07:39Z boer_g $
% $Date: 2009-04-22 17:07:39 +0800 (Wed, 22 Apr 2009) $
% $Author: boer_g $
% $Revision: 390 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/el_mat/range.m $
% $Keywords$

if nargin < 2
   y = max(x) - min(x);
else
   if nargin==2
      dim = varargin{1};
   elseif nargin==3
      dim = varargin{2}; % to have same syntax as min and max
   end
   
   if dim==0
      y = max(x(:)) - min(x(:));
   else
     y = max(x,[],dim) - min(x,[],dim);
   end
end

%% EOF