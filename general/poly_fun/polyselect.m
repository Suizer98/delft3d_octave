function varargout = polyselect(varargin)
%POLYSELECT   select parts of nan-separated polygon
%
% [x,y]        =polyselect(x,y,        index);
% [x,y,<names>]=polyselect(x,y,<names>,index);
%
% where x and y are nan-separated lists.
%
% See also: POLYJOIN, POLYSPLIT, POLYPLOT

%   --------------------------------------------------------------------
%   Copyright (C) 2005 Delft University of Technology
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

%% input

      xi     = varargin{1};
      yi     = varargin{2};
   if     nargin==3
      index  = varargin{3};
   elseif nargin==4
      namesi = varargin{3};
      index  = varargin{4};
      nameso = namesi(index,:);
   end   

%% split

   [xicells,yicells] = poly_split(xi,yi);

%% select

   for ii = 1:length(index)
      xocells{ii} = xicells{index(ii)};
      yocells{ii} = yicells{index(ii)};
   end
   
   %% join

   [xo,yo] = poly_join(xocells,yocells);

%% output

   if     nargin==3
      varargout = {xo,yo};
   elseif nargin==4
      varargout = {xo,yo,nameso};
   end   

%% EOF