function D = poly2struc(x,y)
%POLY2STRUC   Splits nan-separated list into struct matrix
%
% D = poly2struc(x,y)
%
% where x and y are NaN-separated lists.
%
%See also: POLYSPLIT (matlab mapping toolbox)

%   --------------------------------------------------------------------
%   Copyright (C) 2007 Delft University of Technology
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

OPT.debug = 0;

%% Find beginning and end of all pieces
%% NaN are only between the pieces, so there is
%% one piece more than there are NaNs
%% ------------------------------------
%% #1 #2 #3 NaN #4 #5 #6 NaN #7 #8 #9 
%% piece01      piece02      piece03
%% ------------------------------------

index.nan   = find(isnan(x));
index.begin = [1          ; index.nan(:)+1 ];
index.end   = [index.nan-1; length(x)      ];

%% Do actual splitting
%% ------------------------------------
for i=1:length(index.begin)

   D(i).x = x(index.begin(i):index.end(i));
   D(i).y = y(index.begin(i):index.end(i));

end

%% Print to screen for debugging purposes
%% ------------------------------------
if OPT.debug
   for i=1:length(index.begin)
      disp(['*=====> line piece # ',num2str(i,'%0.3d')])
      disp(['L',num2str(i,'%0.3d')])
      disp(num2str([D(i).x D(i).y],'  %13.6f '))
   end
end

%% EOF