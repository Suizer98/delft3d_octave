function OUT = cells2cell(IN)
%CELLS2CELL  Convert the contents of a cell array into a single cell.
%
% M = CELLS2CELL(C) converts a multidimensional cell array with 
% contents of the fixed data type per cell into a single cell. 
%
% Example:
%
%   cells2cell({{'a1'},{'b1','b2'},{'c1','c2','c3'},{1,[2 3],[4 5 6]}})
%
%See also: cell, cell2mat, char

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Delft University of Technology
%       Gerben de Boer
%
%       Gerben J. de Boer
%       g.j.deboer@tudelft.nl	
%       Fluid Mechanics Section
%       Faculty of Civil Engineering and Geosciences
%       PO Box 5048
%       2600 GA Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 08 Apr 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: cells2cell.m 4425 2011-04-08 19:17:36Z boer_g $
% $Date: 2011-04-09 03:17:36 +0800 (Sat, 09 Apr 2011) $
% $Author: boer_g $
% $Revision: 4425 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/el_mat/cells2cell.m $
% $Keywords: $

n = cellfun(@(x)length(x),IN);

OUT = cell(1,sum(n));
jsum = 0;
for i=1:length(IN)
  for j=1:length(IN{i})

   jsum      = jsum + 1;
   
   OUT{jsum} = IN{i}{j};

   end
end
