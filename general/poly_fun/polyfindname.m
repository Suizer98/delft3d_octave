function found = polyfindname(namecells,searchterm)
%POLYFINDNAME  find indices of names of nan-separed polygon
%
%    index = polyfindname(namecells,searchterm)
%
% find all positions in namecells where
% searchterm appears somewhere in the namecells-strings.
%
% Note: case-insenstitive as  all strings are converted to
% lowercase internally.
%
% See also: POLYSELECT, POLYPLOT

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

   if ischar(namecells)
      namecells = cellstr(namecells);
   end

   found = [];
   
   for i=1:length(namecells)
   
      f = findstr(lower(namecells{i}),lower(searchterm));
      if ~isempty(f)
       found = [found i];
      end
      
   end

%% EOF
