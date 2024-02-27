function s = distance(x,y,varargin);
%DISTANCE   calculate distance along polygon
%
% s = distance(x,y) calculates distance along line. 
%
% when x and y have more dimensions, be default the
% distance along the first dimension is given.
%
% s = distance(x,y,dim)
%
% Presence of NaN leads to NaN in distance.
% Distance between NaN-seperated coordinates is assumed 0.
%
% Example:
%
% distance([0 1 nan 1 3],[0 1 nan 1 3],1) = 0    1.4142       NaN    1.4142    4.2426
% distance([0 1 nan 2 3],[0 1 nan 2 3],1) = 0    1.4142       NaN    1.4142    4.2426
%
%See also: poly_fun, pathdistance

%   --------------------------------------------------------------------
%   Copyright (C) 2004 Delft University of Technology
%       Gerben J. de Boer
%
%       g.j.deboer@citg.tudelft.nl	
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

% $Id: distance.m 6956 2012-07-18 14:37:28Z boer_g $
% $Date: 2012-07-18 16:37:28 +0200 (Wed, 18 Jul 2012) $
% $Author: boer_g $
% $Revision: 6956 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/el_mat/distance.m $
% $Keywords$

   dim =1;
   if nargin==3
      dim = varargin{1};
   end

   if size(x,1)==1
    x = x';
   end
   
   if size(y,1)==1
    y = y';
   end

   if ~prod(real(size(x)==size(y)))
     error('x and y should have equal sizes')
   end
   
   ndim = length(size(x));
   
   if dim > ndim
      error('dim should not be > than dimensions of data')
   end
   
   s   = zeros(size(x));
   ds  = zeros(size(x));
   ds0 = sqrt((diff(x,1,dim)).^2 + ...
              (diff(y,1,dim)).^2 );
   
   % to make sure distance([0 1]',[0 1]',1) = [0 sqrt2] when calling cumsum   
   if dim==1
      ds(2:end,:) = ds0;

      mask = zeros(size(x));
      mask(1:end-1,:) = ds0;
      mask = isnan(mask);
   else
      ds(:,2:end) = ds0;

      mask = zeros(size(x));
      mask(:,1:end-1) = ds0;
      mask = isnan(mask);
   end
   
   mask = isnan(x) | isnan(y);

   ds(isnan(ds))=0;
   
   s = cumsum(ds,dim);
   
   s(mask)=nan;
   
   if size(x,2)==1
    s = s';
   end


